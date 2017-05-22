#include <stdio.h>
#include "lmdb.h"
#include <curand.h>
#include <curand_kernel.h>
#include <stdlib.h>

//#include <cub/cub.cuh>
#include <cuda.h>

#include <iostream>
//#include "Utilities.cuh"


//
// Nearly minimal CUDA example.
// Compile with:
//
// nvcc -o example example.cu
//

#define Blocks 640 * 2
#define size 256
#define N Blocks * size

#define CHECK_BIT(var,pos) (var>>pos & 1)

//
// A function marked __global__
// runs on the GPU but can be called from
// the CPU.
//
// This function multiplies the elements of an array
// of ints by 2.
//
// The entire computation can be thought of as running
// with one thread per array element with blockIdx.x
// identifying the thread.
//
// The comparison i<N is because often it isn't convenient
// to have an exact 1-1 correspondence between threads
// and array elements. Not strictly necessary here.
//
// Note how we're mixing GPU and CPU code in the same source
// file. An alternative way to use CUDA is to keep
// C/C++ code separate from CUDA code and dynamically
// compile and load the CUDA code at runtime, a little
// like how you compile and load OpenGL shaders from
// C/C++ code.
//
__global__
void autoStep1(unsigned char *a, unsigned char *b, int *direction, unsigned int ruleBase) {

    unsigned int blockBase = blockIdx.x  * size;

    unsigned int tid = blockBase + (threadIdx.x*(size/32));
	
    // rule per block
    // 256 threads per block so 256 cells in automation 

    unsigned int rule = blockIdx.x;
	unsigned int j = threadIdx.x*(size/32);
	
    rule = rule + ruleBase;
	
	for (int i = 0; i<size/32; i++){
	

		unsigned int ll = a[(j+i - 2)% size + blockBase];
		unsigned int l  = a[(j+i - 1)% size + blockBase];
		//unsigned int c  = a[(j+i    )% size + blockBase];
		unsigned int r  = a[(j+i + 1)% size + blockBase];
		unsigned int rr = a[(j+i + 2)% size + blockBase];
		
		
		unsigned  int neighboorhood = (ll << 3) + (l << 2) + (r << 1) + rr;
 
		//if (a[j % blockDim.x + blockBase] == a[tid]){ printf(" MATCH ");}
 
		b[tid+i] = CHECK_BIT(rule, neighboorhood);
		
	    //if(blockIdx.x == 0){
	    //printf("cell: %3d , neigh: %3d , write: %3d\n", i + tid, neighboorhood, b[tid+i]);
		
		//}

		/* the original way was b[tid] == l || b[tid] == ll maybe for some weird reason that's better */
	
		if (b[tid+i] == ll){
				direction[tid+i] -= 1;}
		if (b[tid+i] == l){
				direction[tid+i] -= 1;}
		if (b[tid+i] == rr){
				direction[tid+i] += 1;}
		if (b[tid+i] == r){
				direction[tid+i] += 1;}
	}

}

__global__
void autoStep2(unsigned char *a, unsigned char *b, int *direction, unsigned int ruleBase) {

    unsigned int blockBase = blockIdx.x  * size;

    unsigned int tid = blockBase + (threadIdx.x*(size/32));
	
    // rule per block
    // 256 threads per block so 256 cells in automation 

    unsigned int rule = blockIdx.x;
	unsigned int j = threadIdx.x*size/32;
	
    rule = rule + ruleBase;
	
	for (int i = 0; i<(size/32); i++){
	
		unsigned int ll = b[(j+i - 2)% size + blockBase];
		unsigned int l  = b[(j+i - 1)% size + blockBase];
		//unsigned int c  = b[(j+i    )% size + blockBase];
		unsigned int r  = b[(j+i + 1)% size + blockBase];
		unsigned int rr = b[(j+i + 2)% size + blockBase];
  
		unsigned  int neighboorhood = (ll << 3) + (l << 2) + (r << 1) + rr;
 
		//if (a[j % blockDim.x + blockBase] == a[tid]){ printf(" MATCH ");}
 
		a[tid+i] = CHECK_BIT(rule, neighboorhood);
		
	    //if(blockIdx.x == 0){
	    //printf("cell: %3d , neigh: %3d , write: %3d\n", i + tid, neighboorhood, b[tid+i]);
		
		//}
		

		/* the original way was b[tid] == l || b[tid] == ll maybe for some weird reason that's better */
	
		if (a[tid+i] == ll){
				direction[tid+i] -= 1;}
		if (a[tid+i] == l){
				direction[tid+i] -= 1;}
		if (a[tid+i] == rr){
				direction[tid+i] += 1;}
		if (a[tid+i] == r){
				direction[tid+i] += 1;}
	}

}


//30

// 128  64  32  16   8   4   2   1
//  0   0    0   1   1   1   1   0
 
 
// 1024, 1024, 64
 
int main( int argc, char *argv[] ) {
    //
    // Create int arrays on the CPU.
    // ('h' stands for "host".)
    //
    unsigned char ha[N], hb[N];

    int directionArray[N];
	
	// DB allocations
	/*
	int rc;
	MDB_env *env;
	MDB_dbi dbi;
	MDB_val key, data;
	MDB_txn *txn;
	MDB_cursor *cursor;
	
	rc = mdb_env_create(&env);
	rc = mdb_env_set_mapsize(env, (68719476736 * 2));
	rc = mdb_env_open(env, "./automationDB", 0, 0664);
	*/
	
    //
    // Create corresponding int arrays on the GPU.
    // ('d' stands for "device".)
    //
    unsigned char *da, *db;
    cudaMalloc((void **)&da, N*sizeof(char));
    cudaMalloc((void **)&db, N*sizeof(char));

    int *directionArrayD;
    cudaMalloc((void **)&directionArrayD, N*sizeof(int));

    //
    // Initialise the input data on the CPU.
    //
	
    srand(time(NULL) + 5);
	
    for (int i = 0; i<N; ++i) {
        ha[i] = rand()%2;
		//ha[i] = 0;
        //if(i%256 - 128 == 0){ ha[i] = 1;}
		
    }
    for (int i = 0; i<N; ++i) {
        directionArray[i] = 0;
    }
    for (int i = 0; i<N; ++i) {
        hb[i] = 0;
    }
	
	//ha[] = 1;
    //ha[] = 1;
	
    //
    // Copy input data to array on GPU.
    //
    cudaMemcpy(da, ha, N*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(directionArrayD, directionArray, N*sizeof(int), cudaMemcpyHostToDevice);
    //
    // Launch GPU code with N threads, one per
    // array element.
    //
	
    //for (int i = 0; i<N; ++i) {
    //    printf("%d", ha[i]);
    //}
	
	// 
	
    unsigned int rule = atoi(argv[1]);  //2769352740;//2769351763;  // + 465 is best in local range
    //                  2769351843
	
	printf("\n returning values:\n");
	
	int scan = 0; //atoi(argv[1]) *size;
	
	int sum = 0;
		
	    for (int i = 0+scan; i<size+scan; ++i) {
			if(ha[i] == 1){ printf("X");}
			else          { printf(" ");}
        }
		
		//printf("\n");
		
	    for (int i = 0+scan; i<size+scan; ++i) {
	        //printf ("%3d  ", directionArray[i]);
            sum += directionArray[i];
        }
		
	    printf("sum: %d\n", sum);
	
	
	for (int i = 0; i<40; i++) {


		autoStep1<<<Blocks, 32>>>(da, db, directionArrayD, rule);
		
	    cudaMemcpy(hb, db, N*sizeof(char), cudaMemcpyDeviceToHost);
	    cudaMemcpy(directionArray, directionArrayD, N*sizeof(int), cudaMemcpyDeviceToHost);
	
		sum = 0;
		
	    for (int i = 0+scan; i<size+scan; ++i) {
			if(hb[i] == 1){ printf("X");}
			else          { printf(" ");}
        }
		
		//printf("\n");
	
	    for (int i = 0+scan; i<size+scan; ++i) {
	        //printf ("%3d  ", directionArray[i]);
            sum += directionArray[i];
        }
	
	    printf("sum: %d\n", sum);
		
		
		autoStep2<<<640, 32>>>(da, db, directionArrayD, rule);
	
	    cudaMemcpy(ha, da, N*sizeof(char), cudaMemcpyDeviceToHost);
	    cudaMemcpy(directionArray, directionArrayD, N*sizeof(int), cudaMemcpyDeviceToHost);
		
		sum = 0;
		
	    for (int i = 0+scan; i<size+scan; ++i) {
			if(ha[i] == 1){ printf("X");}
			else          { printf(" ");}
        }
		
		//printf("\n");
		
	    for (int i = 0+scan; i<size+scan; ++i) {
	        //printf ("%3d  ", directionArray[i]);
            sum += directionArray[i];
        }
		
	    printf("sum: %d\n", sum);
	

	
	}
	
	cudaMemcpy(ha, da, N*sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(directionArray, directionArrayD, N*sizeof(int), cudaMemcpyDeviceToHost);
	
    //for (int i = 0; i<100; ++i) {
	//	printf("%d", ha[i]);
	//}

		
	printf("\nDirection: ");
	
    sum = 0;
    sum = 0;
	
	for (int i = 0+scan; i<size+scan; ++i) {
	    //printf (" %d ", directionArray[i]);
        sum += directionArray[i];
    }
	
	printf("Direction Sum: %d\n", sum);

    //
    // Free up the arrays on the GPU.
    //
    cudaFree(da);
    cudaFree(db);

    return 0;
}

// 0011001100100011001100110010001000110011001000110011001100100100100100100100100100100100100100100100
// 0011001100100011001100110010001000110011001000110011001100100100100100100100100100100100100100100100