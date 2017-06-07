#include <stdio.h>
//#include "lmdb.h"
#include <curand.h>
#include <curand_kernel.h>
#include <stdlib.h>
#include <chrono>
#include <cudaProfiler.h>
#include <lmdb.h>
#include <fstream>
#include "addressbook.pb.h"


// ./4cell_debug1 65376 123

// vs 

// ./4cell_debug1 0 123

// should be printing out results of same automation but they aint


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

#define blockMult 2
#define Blocks (640 * blockMult)
#define size 128
#define N (Blocks * size)
#define CHECK_BIT(var,pos) (var>>pos & 1)
#define time 
#define PLUS_ONE    1.0f
#define MINUS_ONE   -1.0f
#define simDuration 400
#define rounds      100

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
void combinedKernel(unsigned char *a1, unsigned char *a2, 
 unsigned char *b1, unsigned char *b2, int *direction, unsigned int ruleBase) {

    unsigned int rule = blockBase + threadIdx.x; //(threadIdx.x*8);
	
    // rule per block
    // 256 threads per block so 256 cells in automation 
	
	unsigned char a1[size];
	unsigned char a2[size];

	unsigned char b1[size];
	unsigned char b2[size];
	
	int index1;
	int index2;
	int index3;
	int index4;
	
	unsigned char mask;
	
	    // im going to pack 8 bits in each char to save some memory	
	
        // it's a bit hard to visualize because the bit order is opposite between bits in chars and chars, but I don't think it actually matters
	
	for (int j = 0; j < rounds; j ++){
	
	    // TURTLE STEP 1
	
	    for (int i = 0; i < size * 8; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhoodT = CHECK_BIT( a1[(i-2)/8], (i-2)%8) << 3 +    
		           	                       CHECK_BIT( a1[(i-1)/8], (i-1)%8) << 2 +
		    	                           CHECK_BIT( a1[(i+1)/8], (i+1)%8) << 1 +
                                           CHECK_BIT( a1[(i+2)/8], (i+2)%8);
	
	        // 1111 1110 is 254
		
	    	mask = 254;                                                             // defalt mask for no bit shift
	
	        mask = (mask >> 8-i%8) | (mask << i%8);                                 // create proper mask to preserve other bits
	
            a2[i/8] = (a2[i/8] & mask) + ( CHECK_BIT(rule, neighboorhood) << i%8);  // use mask and add in new bit
	
	    }
	
	    // TURTLE STEP 2
	
	    for (int i = 0; i < size * 8; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhoodT = CHECK_BIT( a2[(i-2)/8], (i-2)%8) << 3 +    
		        	                       CHECK_BIT( a2[(i-1)/8], (i-1)%8) << 2 +
		    	                           CHECK_BIT( a2[(i+1)/8], (i+1)%8) << 1 +
                                          CHECK_BIT( a2[(i+2)/8], (i+2)%8);
	
	        // 1111 1110 is 254
		
		    mask = 254;                                                             // defalt mask for no bit shift
	
	        mask = (mask >> 8-i%8) | (mask << i%8);                                 // create proper mask to preserve other bits
	
            a1[i/8] = (a1[i/8] & mask) + ( CHECK_BIT(rule, neighboorhood) << i%8);  // use mask and add in new bit
	
	    }
	
	    // RABBIT STEP 1
	
	    for (int i = 0; i < size * 8; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhoodT = CHECK_BIT( b1[(i-2)/8], (i-2)%8) << 3 +    
		         	                       CHECK_BIT( b1[(i-1)/8], (i-1)%8) << 2 +
		    	                           CHECK_BIT( b1[(i+1)/8], (i+1)%8) << 1 +
                                           CHECK_BIT( b1[(i+2)/8], (i+2)%8);
	
	        // 1111 1110 is 254
		
		    mask = 254;                                                             // default mask for no bit shift
	
	        mask = (mask >> 8-i%8) | (mask << i%8);                                 // create proper mask to preserve other bits
	
            b2[i/8] = (b2[i/8] & mask) + ( CHECK_BIT(rule, neighboorhood) << i%8);  // use mask and add in new bit
	
	    }
	
	    // RABBIT STEP 2
	
	    for (int i = 0; i < size * 8; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhoodT = CHECK_BIT( b2[(i-2)/8], (i-2)%8) << 3 +    
		         	                       CHECK_BIT( b2[(i-1)/8], (i-1)%8) << 2 +
		    	                           CHECK_BIT( b2[(i+1)/8], (i+1)%8) << 1 +
                                          CHECK_BIT( b2[(i+2)/8], (i+2)%8);
	
	        // 1111 1110 is 254
		
		    mask = 254;                                                             // default mask for no bit shift
	
	        mask = (mask >> 8-i%8) | (mask << i%8);                                 // create proper mask to preserve other bits
	
            b1[i/8] = (b1[i/8] & mask) + ( CHECK_BIT(rule, neighboorhood) << i%8);  // use mask and add in new bit
	
	    }
	
	    // RABBIT STEP 3
	
	    for (int i = 0; i < size * 8; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhoodT = CHECK_BIT( b1[(i-2)/8], (i-2)%8) << 3 +    
		         	                       CHECK_BIT( b1[(i-1)/8], (i-1)%8) << 2 +
		    	                           CHECK_BIT( b1[(i+1)/8], (i+1)%8) << 1 +
                                           CHECK_BIT( b1[(i+2)/8], (i+2)%8);
	
	        // 1111 1110 is 254
		
		    mask = 254;                                                             // default mask for no bit shift
	
	        mask = (mask >> 8-i%8) | (mask << i%8);                                 // create proper mask to preserve other bits
	
            b2[i/8] = (b2[i/8] & mask) + ( CHECK_BIT(rule, neighboorhood) << i%8);  // use mask and add in new bit
	 
	    }
	
	    // RABBIT STEP 4
	
	    for (int i = 0; i < size * 8; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhoodT = CHECK_BIT( b2[(i-2)/8], (i-2)%8) << 3 +    
	    	     	                       CHECK_BIT( b2[(i-1)/8], (i-1)%8) << 2 +
	    		                           CHECK_BIT( b2[(i+1)/8], (i+1)%8) << 1 +
                                           CHECK_BIT( b2[(i+2)/8], (i+2)%8);
	
	        // 1111 1110 is 254
		
		    mask = 254;                                                             // default mask for no bit shift
	
	        mask = (mask >> 8-i%8) | (mask << i%8);                                 // create proper mask to preserve other bits
	
            b1[i/8] = (b1[i/8] & mask) + ( CHECK_BIT(rule, neighboorhood) << i%8);  // use mask and add in new bit
	 
	    }
	
	    // it would be great to detect any sort of cycle here
	
	    // is a1 and b1 the same state just rotated?
		
		// I need a bitshift invariant hash
	
	
	
    }
}

	
	


__global__
void autoStep1(unsigned char *a, unsigned char *b, int *direction, unsigned int ruleBase) {

    unsigned int blockBase = blockIdx.x  * size;

    unsigned int tid = blockBase + threadIdx.x; //(threadIdx.x*8);
	
    // rule per block
    // 256 threads per block so 256 cells in automation 
	
	
	unsigned char neighboorhood = ((a[(threadIdx.x - 2)% size + blockBase]) << 3) +
			                      ((a[(threadIdx.x - 1)% size + blockBase]) << 2) +
	    	                      //((a[(threadIdx.x    )% size + blockBase]) << 2) +
			                      ((a[(threadIdx.x + 1)% size + blockBase]) << 1) +
                                    a[(threadIdx.x + 2)% size + blockBase];
    
	
	b[tid] = CHECK_BIT(blockIdx.x + ruleBase, neighboorhood );
	
    //half one = __float2half(ONE);
	
	if (b[tid] == CHECK_BIT( neighboorhood , 3 )){
			direction[tid] -= 1;}
	if (b[tid] == CHECK_BIT( neighboorhood , 2 )){
			direction[tid] -= 1;}
	if (b[tid] == CHECK_BIT( neighboorhood , 1 )){
			direction[tid] += 1;}
	if (b[tid] == CHECK_BIT( neighboorhood , 0 )){
			direction[tid] += 1;}
			

	/*
	unsigned char ll = a[(threadIdx.x - 2)% 128 + blockBase];
	unsigned char l  = a[(threadIdx.x - 1)% 128 + blockBase];
	unsigned char c  = a[(threadIdx.x    )% 128 + blockBase];
	unsigned char r  = a[(threadIdx.x + 1)% 128 + blockBase];
	unsigned char rr = a[(threadIdx.x + 2)% 128 + blockBase];
  
	b[tid] = (ll << 4) + (l << 3) + (c << 2) + (r << 1) + (rr);//ll * 16 + l * 8 + c * 4 + r * 2 + rr;
 
	b[tid] = CHECK_BIT(blockIdx.x + ruleBase, b[tid]);

		// the original way was b[tid] == l || b[tid] == ll maybe for some weird reason that's better 
	
	
	//if (b[tid] == ll || b[tid] == l){
	//	direction[tid] -= 1;}
	//  if (b[tid] == rr || b[tid] == r){
	//	direction[tid] += 1;}
	
	
	
	if (b[tid] == ll){
			direction[tid] -= 1;}
	if (b[tid] == l){
			direction[tid] -= 1;}
	if (b[tid] == rr){
			direction[tid] += 1;}
	if (b[tid] == r){
			direction[tid] += 1;}
			
    */
			
}

__global__
void autoStep2(unsigned char *a, unsigned char *b, int *direction, unsigned int ruleBase) {

    unsigned int blockBase = blockIdx.x  * size;

    unsigned int tid = blockBase + threadIdx.x;
	
    // rule per block
    // 256 threads per block so 256 cells in automation 
	
	
	unsigned char neighboorhood = ((b[(threadIdx.x - 2)% size + blockBase]) << 3) +
			                      ((b[(threadIdx.x - 1)% size + blockBase]) << 2) +
	    	                      //((b[(threadIdx.x    )% size + blockBase]) << 2) +
			                      ((b[(threadIdx.x + 1)% size + blockBase]) << 1) +
                                   b[(threadIdx.x + 2)% size + blockBase];
    
	a[tid] = CHECK_BIT(blockIdx.x + ruleBase, neighboorhood );
	
    //half one = __float2half(ONE);
	
	if (a[tid] == CHECK_BIT( neighboorhood , 3 )){
			direction[tid] -= 1;}
	if (a[tid] == CHECK_BIT( neighboorhood , 2 )){
			direction[tid] -= 1;}
	if (a[tid] == CHECK_BIT( neighboorhood , 1 )){
			direction[tid] += 1;}
	if (a[tid] == CHECK_BIT( neighboorhood , 0 )){
			direction[tid] += 1;}
			
			
	/*
	
	
	unsigned char ll = b[(threadIdx.x - 2)% 128 + blockBase];
	unsigned char l  = b[(threadIdx.x - 1)% 128 + blockBase];
	unsigned char c  = b[(threadIdx.x    )% 128 + blockBase];
	unsigned char r  = b[(threadIdx.x + 1)% 128 + blockBase];
	unsigned char rr = b[(threadIdx.x + 2)% 128 + blockBase];
  
	a[tid] = (ll << 4) + (l << 3) + (c << 2) + (r << 1) + (rr);//ll * 16 + l * 8 + c * 4 + r * 2 + rr; //ll << 4 + l << 3 + c << 2 + r << 1 + rr;
 
	a[tid] = CHECK_BIT(blockIdx.x + ruleBase, a[tid]);

		// the original way was b[tid] == l || b[tid] == ll maybe for some weird reason that's better
	
	
	//if (a[tid] == ll || a[tid] == l){
	//	direction[tid] -= 1;}
	//if (a[tid] == rr || a[tid] == r){
	//		direction[tid] += 1;}
	
	
	if (a[tid] == ll){
			direction[tid] -= 1;}
	if (a[tid] == l){
			direction[tid] -= 1;}
	if (a[tid] == rr){
			direction[tid] += 1;}
	if (a[tid] == r){
			direction[tid] += 1;}
    */
 
}


__global__ void equals(unsigned char *a, unsigned char *b, unsigned char *resultArray) {

    unsigned int blockBase = blockIdx.x  * size;

    unsigned int tid = blockBase + threadIdx.x;
	
    // rule per block
    // 256 threads per block so 256 cells in automation 
	
	
    if(a[threadIdx.x % size + blockBase] == b[threadIdx.x % size + blockBase]){
        resultArray[threadIdx.x % size + blockBase] = 1;
	}
	else{
        resultArray[threadIdx.x % size + blockBase] = 0;
	}

}

__global__ void setup_kernel(curandState *state)
{
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    /* Each thread gets different seed, a different sequence
       number, no offset */
    curand_init(1231+id, id, 0, &state[id]);
}

__global__ void curand_kernel(curandState *state,
                                unsigned char *a)
{
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    float x;
    /* Copy state to local memory for efficiency */
    curandState localState = state[id];
    /* Generate pseudo-random uniforms */
    x = (curand(&localState))%2;
    /* Copy state back to global memory */
    state[id] = localState;
    /* Store last generated result per thread */
    a[id] = (unsigned char) x;
}


//30

// 128  64  32  16   8   4   2   1
//  0   0    0   1   1   1   1   0
 
 
// 1024, 1024, 64
 
int main( int argc, char *argv[] ) {

    // DB allocations

	int rc;
	MDB_env *env;
	MDB_dbi dbi;
	MDB_val key, data;
	MDB_txn *txn;
	MDB_cursor *cursor;
	
	rc = mdb_env_create(&env);
	rc = mdb_env_set_mapsize(env, (68719476736 * 2));
	rc = mdb_env_open(env, argv[2], 0, 0664);


    //
    // Create int arrays on the CPU.
    // ('h' stands for "host".)
    //
    unsigned char ha[N];

    int directionArray[N];
	
    //
    // Create corresponding int arrays on the GPU.
    // ('d' stands for "device".)
    //
    curandState *devStates;
    cudaMalloc((void **)&devStates, N *  sizeof(curandState));
	
    setup_kernel<<<Blocks, size>>>(devStates);
	
	unsigned char *daR, *dbR;
    cudaMalloc((void **)&daR, N*sizeof(char));
    cudaMalloc((void **)&dbR, N*sizeof(char));
	
	unsigned char *daT, *dbT;
    cudaMalloc((void **)&daT, N*sizeof(char));
    cudaMalloc((void **)&dbT, N*sizeof(char));

    unsigned int *repeatState;
    cudaMalloc((void **)&rpeateState, N*sizeof(char));
	
	
    int *resultArrayD;
    cudaMalloc((void **)&resultArrayD, N*sizeof(char));

    //time_point<Clock> start = Clock::now();
	
    //
    // Initialise the input data on the CPU.
    //
	
	//srand(time(NULL));

	int score1[Blocks];
	int score2[Blocks];
    int state[Blocks];
	
	int finalScore[Blocks];
	
    int rule = 0; //atoi( argv[1]);
	//                  2769351843   // 2769351763;  // + 465
	//                  2769352740
	
	// 2769352362
	// 2769352228

	//  

    std::ofstream logs;
	
    int loop = 0;
	
	while (loop < 52 ){
	
		for (int i = 0; i<Blocks; ++i) {
			score1[i] = 0;
			score2[i] = 0;
		}
	
		for (int iters = 0; iters < rounds; iters++) {
	
			srand(time(NULL) + iters);
	
	        // http://stackoverflow.com/questions/14289378/generating-random-numbers-within-cuda-kernel
			
			// GENERATING RANDOM NUMBERS WITH CUDA WILL SPEED THIS UP ALOT MAYBE
	
	
			//for (int i = 0; i<N; ++i) {
			//	ha[i] = rand()%2;
				//if(i%256 - 128 == 0){ ha[i] = 1;}
			//}

			//for (int i = 0; i<N; ++i) {
			//	hb[i] = 0;
			//}
	
			//for (int i = 0; i<N; ++i) {
			//	directionArray[i] = 0;
			//}

			//
			// Copy input data to array on GPU.
			//
			//cudaMemcpy(da, ha, N*sizeof(char), cudaMemcpyHostToDevice);
			
			cudaMemset(da, 0, N * sizeof(char));

            curand_kernel<<<Blocks, size>>>(devStates, da);
			
            //cudaMemcpy(ha, da, N*sizeof(char), cudaMemcpyDeviceToHost);		
			
			cudaMemset(directionArrayD, 0, N*sizeof(int));
			//cudaMemcpy(directionArrayD, directionArray, N*sizeof(char), cudaMemcpyHostToDevice);
			//
			// Launch GPU code with N threads, one per
			// array element.
			//
	
			int scan = 0;
	
			int sum = 0;
			
			for (int i = 0; i < simDuration; i++) {
			
			    
                // this is the turtle automation, stepping forward one at at time
				autoStep1<<<Blocks, size>>>(daT, dbT, directionArrayD, rule);
				autoStep2<<<Blocks, size>>>(daT, dbT, directionArrayD, rule);
				
				// this is the rabbit automation, stepping forward two at a time
				autoStep1<<<Blocks, size>>>(daR, dbR, directionArrayD, rule);
				autoStep2<<<Blocks, size>>>(daR, dbR, directionArrayD, rule);
				autoStep1<<<Blocks, size>>>(daR, dbR, directionArrayD, rule);
				autoStep2<<<Blocks, size>>>(daR, dbR, directionArrayD, rule);

				// if they produce the same result, then they have found a cycle
				
			}
	
			//cudaMemcpy(ha, da, N*sizeof(char), cudaMemcpyDeviceToHost);
			cudaMemcpy(directionArray, directionArrayD, N*sizeof(int), cudaMemcpyDeviceToHost);
	
			sum = 0;
	
			int count = 0;
	
			for (int i = 0+scan; i<N; ++i) {
				if(i%size == 0 && i > 0){
		       
					//score1[count] += sum;
				    //score2[count] += abs(int(sum));
				
				    if (sum > 0){score1[count] = score1[count] + 1;}
					
					if (sum < 0){score2[count] = score2[count] + 1;}
					
					//if (rule + count == 65376){printf("score1: %05d score2: %05d\n", score1[count], score2[count]);}
				
                    //if(sum < 0){printf("auto %ud score2: %d ", rule + count, sum);} //score1[count]);
				
					sum = 0;
					count++;
				}
				
				//if (directionArray[i] < 0 ) {printf("%d", directionArray[i]);}
				sum += directionArray[i];
			}
			
			//count++;
			
			if (sum > 0){score1[count] = score1[count] + 1;}
					
			if (sum < 0){score2[count] = score2[count] + 1;}
			
			//score1[count] += sum;
			//score2[count] += abs(int(sum));
				
		
		}

		
		for (int i = 0; i<(Blocks); i++){
	
			//printf("score1: %8d, score2: %8d", score1[i], score2[i]);

            if (score1[i] > score2[i]){finalScore[i] = score2[i];}
            if (score2[i] > score1[i]){finalScore[i] = score1[i];}
			
			//finalScore[i] = score2[i] - abs(score1[i]); // score1[i] - score2[i];//
	        //if(rule + i == 65376){
			//printf("i:  %d ,rule: %u ,score: %d \n" , i , rule + i, finalScore[i]);}
		
			//if (finalScore[i] > 0) { loop = 0;}
		}
	
        time_point<Clock> end = Clock::now();
	
		//std::cout << "before db" << std::endl;
	
		// write results to db here
		char keyValue[16];
		char dataValue[16];
	
		//std::cout << "db 1" << std::endl;
	
		rc = mdb_txn_begin(env, NULL, 0, &txn);
		rc = mdb_open(txn, NULL, 0, &dbi);
	
		//std::cout << "db 2" << std::endl;
	
		key.mv_size = 8;
		key.mv_data = keyValue;
		data.mv_size = 8;
		data.mv_data = dataValue;
	
		//unsigned int autoID;
	
		//std::cout << "db 3" << std::endl;
	
		for(int i = 0; i < (Blocks); i++){
	
			//std::cout << "1 writing to db #" << i << std::endl;
	
			sprintf(keyValue,   "%08x", rule + i);
			sprintf(dataValue,  "%08x", finalScore[i]);//score1[i]);//
		
			//std::cout << "Key: " << keyValue << " Score: " << dataValue << std::endl;
	
			//std::cout << "2 writing to db #" << i << std::endl;
	
			rc = mdb_put(txn, dbi, &key, &data, 0);
	
		}
		
		rc = mdb_txn_commit(txn);
	
		if (rc) {
			fprintf(stderr, "mdb_txn_commit: (%d) %s\n", rc, mdb_strerror(rc));
			mdb_close(env, dbi);
			mdb_env_close(env);
			return 0;
		}
	
		//printf("MDB commit rc#: %d\n", rc);
	
		//std::cout << "db 4" << std::endl;
	   
	
		if ((rule % 124000) == 0) { 
			printf("Completed section from Rule %d, loop %d\n", rule, loop); 
			logs.open("auto1d_log2.txt");
			logs << "Completed section from Rule %d, loop %d\n", rule, loop;
			logs.close();
		}
		loop++;
	
		rule += Blocks;
	
	}
	
	//for (int i = 0; i<Blocks; i++){
	
	//	printf("auto %u, score: %d\n", rule + i, finalScore[i]);
	//}
	
	//printf("Direction Sum: %d\n", sum);
	
    //milliseconds diff = duration_cast<milliseconds>(end - start);
    //std::cout << diff.count() << "ms" << std::endl;

    //
    // Free up the arrays on the GPU.
    //
    cudaFree(da);
    cudaFree(db);

    return 0;
}



// 0011001100100011001100110010001000110011001000110011001100100100100100100100100100100100100100100100
// 0011001100100011001100110010001000110011001000110011001100100100100100100100100100100100100100100100