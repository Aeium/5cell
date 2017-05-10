#include <stdio.h>
//#include "lmdb.h"
#include <curand.h>
#include <curand_kernel.h>
#include <stdlib.h>
#include <chrono>
#include <cudaProfiler.h>
#include <lmdb.h>



using Clock = std::chrono::steady_clock;
using std::chrono::time_point;
using std::chrono::duration_cast;
using std::chrono::milliseconds;


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

#define N 20480
#define size 256
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
void autoStep1(int *a, int *b, int *direction, unsigned int ruleBase) {

    unsigned int blockBase = blockIdx.x  * blockDim.x;

    unsigned int tid = blockBase + threadIdx.x;
	
    // rule per block
    // 256 threads per block so 256 cells in automation 

    unsigned int rule = blockIdx.x;
	unsigned int j = threadIdx.x;
	
    rule = rule + ruleBase;
	
    unsigned int ll = a[(j - 2)% blockDim.x + blockBase];
    unsigned int l  = a[(j - 1)% blockDim.x + blockBase];
    unsigned int c  = a[(j    )% blockDim.x + blockBase];
    unsigned int r  = a[(j + 1)% blockDim.x + blockBase];
    unsigned int rr = a[(j + 2)% blockDim.x + blockBase];
  
    unsigned  int neighboorhood = ll * 16 + l * 8 + c * 4 + r * 2 + rr;
 
    //if (a[j % blockDim.x + blockBase] == a[tid]){ printf(" MATCH ");}
 
    b[tid] = CHECK_BIT(rule, neighboorhood);

    /* the original way was b[tid] == l || b[tid] == ll maybe for some weird reason that's better */
	
    if (b[tid] == ll){
			direction[tid] -= 1;}
    if (b[tid] == l){
			direction[tid] -= 1;}
    if (b[tid] == rr){
			direction[tid] += 1;}
    if (b[tid] == r){
			direction[tid] += 1;}

}

__global__
void autoStep2(int *a, int *b, int *direction, unsigned int ruleBase) {

    unsigned int blockBase = blockIdx.x  * blockDim.x;

    unsigned int tid = blockBase + threadIdx.x;
	
    // rule per block
    // 256 threads per block so 256 cells in automation 

    unsigned int rule = blockIdx.x;
	unsigned int j = threadIdx.x;
	
    rule = rule + ruleBase;
	
    unsigned int ll = b[(j - 2)% blockDim.x + blockBase];
    unsigned int l  = b[(j - 1)% blockDim.x + blockBase];
    unsigned int c  = b[(j    )% blockDim.x + blockBase];
    unsigned int r  = b[(j + 1)% blockDim.x + blockBase];
    unsigned int rr = b[(j + 2)% blockDim.x + blockBase];
  
    unsigned  int neighboorhood = ll * 16 + l * 8 + c * 4 + r * 2 + rr;
 
    a[tid] = CHECK_BIT(rule, neighboorhood);
	
    if (a[tid] == ll){
			direction[tid] -= 1;}
    if (a[tid] == l){
			direction[tid] -= 1;}
    if (a[tid] == rr){
			direction[tid] += 1;}
    if (a[tid] == r){
			direction[tid] += 1;}
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
    int ha[N], hb[N];

    int directionArray[N];
	
    //
    // Create corresponding int arrays on the GPU.
    // ('d' stands for "device".)
    //
    int *da, *db;
    cudaMalloc((void **)&da, N*sizeof(int));
    cudaMalloc((void **)&db, N*sizeof(int));

    int *directionArrayD;
    cudaMalloc((void **)&directionArrayD, N*sizeof(int));

    time_point<Clock> start = Clock::now();
	
    //
    // Initialise the input data on the CPU.
    //
	
	//srand(time(NULL));

	int score1[80];
	int score2[80];
	
	int finalScore[80];
	
	unsigned int rule = 2769351763;

    int loop = 1;
	
	while (loop){
	
		for (int i = 0; i<80; ++i) {
			score1[i] = 0;
			score2[i] = 0;
		}
	
		for (int iters = 0; iters<5000; iters++) {
	
			srand(time(NULL) + iters);
	
			for (int i = 0; i<N; ++i) {
				ha[i] = rand()%2;
				//if(i%256 - 128 == 0){ ha[i] = 1;}
			}

			for (int i = 0; i<N; ++i) {
				hb[i] = 0;
			}
	
			for (int i = 0; i<N; ++i) {
				directionArray[i] = 0;
			}

			//
			// Copy input data to array on GPU.
			//
			cudaMemcpy(da, ha, N*sizeof(int), cudaMemcpyHostToDevice);
			cudaMemcpy(directionArrayD, directionArray, N*sizeof(int), cudaMemcpyHostToDevice);
			//
			// Launch GPU code with N threads, one per
			// array element.
			//
	
			int scan = 0;
	
			unsigned int sum = 0;
	
			for (int i = 0; i<40; i++) {

				autoStep1<<<80, 256>>>(da, db, directionArrayD, rule);
				autoStep2<<<80, 256>>>(da, db, directionArrayD, rule);

			}
	
			cudaMemcpy(ha, da, N*sizeof(int), cudaMemcpyDeviceToHost);
			cudaMemcpy(directionArray, directionArrayD, N*sizeof(int), cudaMemcpyDeviceToHost);
	
			sum = 0;
	
			int count = 0;
	
			for (int i = 0+scan; i<N; ++i) {
				//printf (" %d ", directionArray[i]);
				if(i%256 == 0){
		       
					score1[count] += sum;
					score2[count] += abs(int(sum));
				
					sum = 0;
					count++;
				}
				sum += directionArray[i];
			}
		
		}

		/*
		for (int i = 0; i<80; i++){
	
			printf("score1: %8d, score2: %8d\n", score1[i], score2[i]);
	
			finalScore[i] = score2[i] - abs(score1[i]);
		
			if (finalScore[i] > 0) { loop = 0;}
		}
		*/
	
		std::cout << "before db" << std::endl;
	
		// write results to db here
		char keyValue[16];
		char dataValue[16];
	
		std::cout << "db 1" << std::endl;
	
		rc = mdb_txn_begin(env, NULL, 0, &txn);
		rc = mdb_open(txn, NULL, 0, &dbi);
	
		std::cout << "db 2" << std::endl;
	
		key.mv_size = 8;
		key.mv_data = keyValue;
		data.mv_size = 16;
		data.mv_data = dataValue;
	
		unsigned int autoID;
	
		std::cout << "db 3" << std::endl;
	
		for(int i = 0; i < 80; i++){
	
			//std::cout << "1 writing to db #" << i << std::endl;
	
			sprintf(keyValue,  "%08x", results[i].autoID);
			sprintf(dataValue,  "%08.0f", results[i].score);
		
			//std::cout << "Key: " << keyValue << " Score: " << dataValue << std::endl;
	
			//std::cout << "2 writing to db #" << i << std::endl;
	
			rc = mdb_put(txn, dbi, &key, &data, 0);
	
		}
		
		rc = mdb_txn_commit(txn);
	
		if (rc) {
			fprintf(stderr, "mdb_txn_commit: (%d) %s\n", rc, mdb_strerror(rc));
			goto leave;
		}
	
		printf("MDB commit rc#: %d\n", rc);
	
		std::cout << "db 4" << std::endl;
	
		rule += 80;
	
	}
	
    time_point<Clock> end = Clock::now();
	
	for (int i = 0; i<80; i++){
	
		printf("auto %u, score: %d\n", rule + i, finalScore[i]);
	}
	
	//printf("Direction Sum: %d\n", sum);
	
    milliseconds diff = duration_cast<milliseconds>(end - start);
    std::cout << diff.count() << "ms" << std::endl;

    //
    // Free up the arrays on the GPU.
    //
    cudaFree(da);
    cudaFree(db);

    return 0;
}

// 0011001100100011001100110010001000110011001000110011001100100100100100100100100100100100100100100100
// 0011001100100011001100110010001000110011001000110011001100100100100100100100100100100100100100100100