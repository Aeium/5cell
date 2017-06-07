#include <stdio.h>
//#include "lmdb.h"
#include <curand.h>
#include <curand_kernel.h>
#include <stdlib.h>
#include <chrono>
#include <cudaProfiler.h>
#include <lmdb.h>
#include <fstream>
//#include "addressbook.pb.h"


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
// nvcc -llmdb -std=c++11 -o example example.cu
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
#define rSize       32

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

__global__ void print_kernel(unsigned int start, unsigned int *loop, unsigned int ruleBase) {

	
    unsigned int rule = ruleBase +  blockIdx.x * 10 + threadIdx.x; 
	
	if(rule == 9){ rule = 28086;}
	
	//for(int j = 0; j < 5; j++){
	
	//    printf("Hello from block %d, thread %d, rule %d, j %d\n", blockIdx.x, threadIdx.x, rule, j);
	
	//}
	
    unsigned int a1 = start;
    unsigned int a2 = 0;
	
    unsigned int mask;
	
	unsigned char write;
	
	if(rule == 28086){
	    for (int b = 0; b < rSize; b++){
	
	        printf("%d", CHECK_BIT(a1,b));
	
    	}
		
		printf("\n");
	}
	
    for (int j = 0; j < 3; j ++){
	
	    if(rule == 28086){
        printf("1.. %d %d\n", j, rounds);
	    }
	    // TURTLE STEP 1
	
	    for (int i = 0; i < rSize; i++){
		
		    //if(rule == 28086){
		    //printf("2.. %d %d\n", i, rSize);
	        //}
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhood =  (CHECK_BIT( a1, (i-2)%rSize) << 3 )+    
		           	                       (CHECK_BIT( a1, (i-1)%rSize) << 2 )+
		    	                           (CHECK_BIT( a1, (i+1)%rSize) << 1 )+
                                            CHECK_BIT( a1, (i+2)%rSize);
						
						
	        if(rule == 28086){
			     printf("bit1 %d\n", CHECK_BIT( a1, (i-2)%rSize) << 3 );
			     printf("bit2 %d\n", CHECK_BIT( a1, (i-1)%rSize) << 2);
			     printf("bit3 %d\n", CHECK_BIT( a1, (i+1)%rSize) << 1);
			     printf("bit4 %d\n", CHECK_BIT( a1, (i+2)%rSize) );
                 printf("neighboorhood %d\n", neighboorhood);
	        }						
            
	
	        // 1111 1110 is 254
		
	    	mask = 1;                       // defalt mask for no bit shift
	
	        mask = (mask << i);             // create proper mask to preserve other bits
	
        	//if(rule == 28086){
	        //    for (int b = 0; b < rSize; b++){
	
	        //       printf("%d", CHECK_BIT(~mask,b));
	
    	    //}
		
		   //printf("\n");
	       //}
	
            write = CHECK_BIT(rule, neighboorhood);
			
	        if(rule == 28086){
                 printf("%d\n",write);
				 //printf("a2 & mask %d\n", (a2 & mask));
	        }
	
            a2 = (a2 & ~mask);
			
			a2 = a2 + (write << i);
			
        	if(rule == 28086){
	            for (int b = 0; b < rSize; b++){
	
	                printf("%d", CHECK_BIT(a2,b));
	
    	        }
				
				printf("\n");
			
			}

	        //if(rule == 28086){
            //     printf("a2 %d\n", a2);
	        //}
			
			//+ ( write << i);  // use mask and add in new bit
	
            //if(rule == 9){
            //     printf("write %d\n", write);
	        //}
	
	    }
		
		if(rule == 28086){
		     printf("\n");
	    }
	
	    // TURTLE STEP 2
	
 for (int i = 0; i < rSize; i++){
		
		    //if(rule == 28086){
		    //printf("2.. %d %d\n", i, rSize);
	        //}
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhood =  (CHECK_BIT( a2, (i-2)%rSize) << 3 )+    
		           	                       (CHECK_BIT( a2, (i-1)%rSize) << 2 )+
		    	                           (CHECK_BIT( a2, (i+1)%rSize) << 1 )+
                                            CHECK_BIT( a2, (i+2)%rSize);
						
						
	        if(rule == 28086){
			     printf("bit1 %d\n", CHECK_BIT( a2, (i-2)%rSize) << 3 );
			     printf("bit2 %d\n", CHECK_BIT( a2, (i-1)%rSize) << 2);
			     printf("bit3 %d\n", CHECK_BIT( a2, (i+1)%rSize) << 1);
			     printf("bit4 %d\n", CHECK_BIT( a2, (i+2)%rSize) );
                 printf("neighboorhood %d\n", neighboorhood);
	        }						
            
	
	        // 1111 1110 is 254
		
	    	mask = 1;                       // defalt mask for no bit shift
	
	        mask = (mask << i);             // create proper mask to preserve other bits
	
        	//if(rule == 28086){
	        //    for (int b = 0; b < rSize; b++){
	
	        //       printf("%d", CHECK_BIT(~mask,b));
	
    	    //}
		
		   //printf("\n");
	       //}
	
            write = CHECK_BIT(rule, neighboorhood);
			
	        if(rule == 28086){
                 printf("%d\n",write);
				 //printf("a1 & mask %d\n", (a1 & mask));
	        }
	
            a1 = (a1 & ~mask);
			
			a1 = a1 + (write << i);
			
        	if(rule == 28086){
	            for (int b = 0; b < rSize; b++){
	
	                printf("%d", CHECK_BIT(a2,b));
	
    	        }
				
				printf("\n");
			
			}

	        //if(rule == 28086){
            //     printf("a1 %d\n", a1);
	        //}
			
			//+ ( write << i);  // use mask and add in new bit
	
            //if(rule == 9){
            //     printf("write %d\n", write);
	        //}
	
	    }
		
	    if(rule == 28086){
		     printf("\n");
	    }
		
	}
	
	
	
}

__global__ void combinedKernel(unsigned int start, unsigned int *loop, unsigned int ruleBase) {

    if (threadIdx.x == 0) {
        printf("DOES THIS WORK");
    }

 
    unsigned int rule = ruleBase + threadIdx.x; //(threadIdx.x*8);

	
    // rule per block
    // 256 threads per block so 256 cells in automation 
	
	unsigned int a1 = start;
	unsigned int a2;

	unsigned int b1 = start;
	unsigned int b2;
	
	unsigned char write;
	
	unsigned char mask;
	
	    // im going to pack 8 bits in each char to save some memory	
	
        // it's a bit hard to visualize because the bit order is opposite between bits in chars and chars, but I don't think it actually matters
	
	for (int j = 0; j < rounds; j ++){
	
	    // TURTLE STEP 1
	
	    for (int i = 0; i < rSize; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhood = CHECK_BIT( a1, (i-2)%rSize) << 3 +    
		           	                       CHECK_BIT( a1, (i-1)%rSize) << 2 +
		    	                           CHECK_BIT( a1, (i+1)%rSize) << 1 +
                                           CHECK_BIT( a1, (i+2)%rSize);
	
	        // 1111 1110 is 254
		
	    	mask = 254;                                                             // defalt mask for no bit shift
	
	        mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
            write = CHECK_BIT(rule, neighboorhood);
	
            a2 = (a2 & mask) + ( write << i);  // use mask and add in new bit
	
            if(rule == 9){
			
	            printf("%s",write);
			
			}
	
	    }
		
		printf("\n");
	
	    // TURTLE STEP 2
	
	    for (int i = 0; i < rSize; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhood = CHECK_BIT( a2, (i-2)%rSize) << 3 +    
		        	                       CHECK_BIT( a2, (i-1)%rSize) << 2 +
		    	                           CHECK_BIT( a2, (i+1)%rSize) << 1 +
                                           CHECK_BIT( a2, (i+2)%rSize);
	
	        // 1111 1110 is 254
		
		    mask = 254;                                                             // defalt mask for no bit shift
	
	        mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
            write = CHECK_BIT(rule, neighboorhood);
	
            a1 = (a1 & mask) + ( write << i);  // use mask and add in new bit
	
            if(rule == 521){
			
	            printf("%s",write);
			
			}
	
	    }
		
		printf("\n");
	
	    // RABBIT STEP 1
	
	    for (int i = 0; i < rSize; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhood =  CHECK_BIT( b1, (i-2)%rSize) << 3 +    
		           	                       CHECK_BIT( b1, (i-1)%rSize) << 2 +
		    	                           CHECK_BIT( b1, (i+1)%rSize) << 1 +
                                           CHECK_BIT( b1, (i+2)%rSize);
	
	        // 1111 1110 is 254
		
	    	mask = 254;                                                             // defalt mask for no bit shift
	
	        mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
            b2 = (b2 & mask) + ( CHECK_BIT(rule, neighboorhood) << i);  // use mask and add in new bit
	
	    }
	
	    // RABBIT STEP 2
	
	    for (int i = 0; i < rSize; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhood =  CHECK_BIT( b2, (i-2)%rSize) << 3 +    
		           	                       CHECK_BIT( b2, (i-1)%rSize) << 2 +
		    	                           CHECK_BIT( b2, (i+1)%rSize) << 1 +
                                           CHECK_BIT( b2, (i+2)%rSize);
	
	        // 1111 1110 is 254
		
	    	mask = 254;                                                             // defalt mask for no bit shift
	
	        mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
            b1 = (b1 & mask) + ( CHECK_BIT(rule, neighboorhood) << i);  // use mask and add in new bit
	
	    }
	
	    // RABBIT STEP 3
	
	    for (int i = 0; i < rSize; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhood =  CHECK_BIT( b1, (i-2)%rSize) << 3 +    
		           	                       CHECK_BIT( b1, (i-1)%rSize) << 2 +
		    	                           CHECK_BIT( b1, (i+1)%rSize) << 1 +
                                           CHECK_BIT( b1, (i+2)%rSize);
	
	        // 1111 1110 is 254
		
	    	mask = 254;                                                             // defalt mask for no bit shift
	
	        mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
            b2 = (b2 & mask) + ( CHECK_BIT(rule, neighboorhood) << i);  // use mask and add in new bit
	
	    }
	
	    // RABBIT STEP 4
	
	    for (int i = 0; i < rSize; i++){
		
	
	        // unpack cells from char and bitshift and add to create neighboorhood number
	    
	        unsigned char neighboorhood =  CHECK_BIT( b2, (i-2)%rSize) << 3 +    
		           	                       CHECK_BIT( b2, (i-1)%rSize) << 2 +
		    	                           CHECK_BIT( b2, (i+1)%rSize) << 1 +
                                           CHECK_BIT( b2, (i+2)%rSize);
	
	        // 1111 1110 is 254
		
	    	mask = 254;                                                             // defalt mask for no bit shift
	
	        mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
            b1 = (b1 & mask) + ( CHECK_BIT(rule, neighboorhood) << i);  // use mask and add in new bit
	
	    }
		
		// rotate through register and check for cycles
		
		int match = 0;
		
		for (int i =0; i< rSize; i++){
		
		    if(a1 == b1){
			
			    match = 1;
			    break;
			
			}
			
			a1 = (mask >> rSize-1) | (mask << 1);   // rotate to check for symmetries
		
		}
		
		if (match == 1){
		
            printf("Match in %08d, state: %32%d\n", rule , a1);
		    match = a1;
		
		
		
		    // need to run one iteration before checking for match or it will just match right away
		
	        // TURTLE STEP 1
	
	        for (int i = 0; i < rSize; i++){
		
	
	            // unpack cells from char and bitshift and add to create neighboorhood number
	    
	            unsigned char neighboorhood = CHECK_BIT( a1, (i-2)%rSize) << 3 +    
		           	                       CHECK_BIT( a1, (i-1)%rSize) << 2 +
		    	                           CHECK_BIT( a1, (i+1)%rSize) << 1 +
                                           CHECK_BIT( a1, (i+2)%rSize);
	
	            // 1111 1110 is 254
		
	    	    mask = 254;                                                             // defalt mask for no bit shift
	
	            mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
                a2 = (a2 & mask) + ( CHECK_BIT(rule, neighboorhood) << i);  // use mask and add in new bit
	
	        }
	
	        // TURTLE STEP 2
	
	        for (int i = 0; i < rSize; i++){
		
	
	            // unpack cells from char and bitshift and add to create neighboorhood number
	    
	            unsigned char neighboorhood = CHECK_BIT( a2, (i-2)%rSize) << 3 +    
		        	                       CHECK_BIT( a2, (i-1)%rSize) << 2 +
		    	                           CHECK_BIT( a2, (i+1)%rSize) << 1 +
                                           CHECK_BIT( a2, (i+2)%rSize);
	
	            // 1111 1110 is 254
		
		        mask = 254;                                                             // defalt mask for no bit shift
	
	            mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
                a1 = (a1 & mask) + ( CHECK_BIT(rule, neighboorhood) << i);  // use mask and add in new bit
	
	        }
		
            loop[rule] = 1;
		
		    while(a1 != match){
		
	            // TURTLE STEP 1
	
	             for (int i = 0; i < rSize; i++){
		
	
	                // unpack cells from char and bitshift and add to create neighboorhood number
	    
	               unsigned char neighboorhood = CHECK_BIT( a1, (i-2)%rSize) << 3 +    
		              	                      CHECK_BIT( a1, (i-1)%rSize) << 2 +
		    	                              CHECK_BIT( a1, (i+1)%rSize) << 1 +
                                              CHECK_BIT( a1, (i+2)%rSize);
	
	                // 1111 1110 is 254
		
 
	                mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
                    a2 = (a2 & mask) + ( CHECK_BIT(rule, neighboorhood) << i);  // use mask and add in new bit
	
	            }
	
	            // TURTLE STEP 2
	
	            for (int i = 0; i < rSize; i++){
		
	
	                // unpack cells from char and bitshift and add to create neighboorhood number
	    
	                unsigned char neighboorhood = CHECK_BIT( a2, (i-2)%rSize) << 3 +    
		        	                          CHECK_BIT( a2, (i-1)%rSize) << 2 +
		    	                              CHECK_BIT( a2, (i+1)%rSize) << 1 +
                                              CHECK_BIT( a2, (i+2)%rSize);
	
	                // 1111 1110 is 254
		
		            mask = 254;                                                             // defalt mask for no bit shift
	
	                mask = (mask >> rSize-i) | (mask << i);                                 // create proper mask to preserve other bits
	
                    a1 = (a1 & mask) + ( CHECK_BIT(rule, neighboorhood) << i);  // use mask and add in new bit
	
	            }
		
		    loop[rule] = loop[rule] + 1; // increment counter to check for loop duration
		
		    }
		
		}
		
        loop[rule] = a1;
		
	
	    // it would be great to detect any sort of cycle here
	
	    // is a1 and b1 the same state just rotated?
		
		// I need a bitshift invariant hash
	
        // or just put the entire automation in one register
	
	
    }
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

	
	unsigned int resultArray[Blocks];
	
    unsigned int *resultArrayD;
    cudaMalloc((void **)&resultArrayD, Blocks*sizeof(int));

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
	
	unsigned int randomStart = 0;

    for (int i = 0; i<Blocks; ++i) {
			score1[i] = 0;
			score2[i] = 0;
			finalScore[i] = 0;
    }
	
	while (loop < 2 ){
	
       
	
		for (int iters = 0; iters < 2; iters++) {
	
			srand(time(0) + iters);
	
            randomStart = rand();
			
			cudaMemset(resultArrayD, 0, Blocks*sizeof(int));

			// Launch GPU code with N threads, one per
			// array element.

	
			int scan = 0;
	
			int sum = 0;
			
			//printf("~~~~~~~~~~~ start: %d\n", randomStart);
            //printf("~~~~~~~~~~~ rule : %d\n", rule);
			
			//combinedKernel<<<Blocks, size>>>(randomStart, resultArrayD, rule);
	
            //cudaDeviceSynchronize();
			
            print_kernel<<<10, 10>>>(randomStart, resultArrayD, rule);
            cudaDeviceSynchronize();
	
			cudaMemcpy(resultArray, resultArrayD, Blocks*sizeof(int), cudaMemcpyDeviceToHost);
	
	
	
			sum = 0;
	
			int count = 0;
	
			for (int i = 0; i<Blocks; ++i) {

                //printf("Result for %08d: %d\n", i + rule, resultArray[i]);
                score1[i] += resultArray[i] / rounds;
				
				//if (directionArray[i] < 0 ) {printf("%d", directionArray[i]);}
			}
			
			//count++;
			
			if (sum > 0){score1[count] = score1[count] + 1;}
					
			if (sum < 0){score2[count] = score2[count] + 1;}
			
			//score1[count] += sum;
			//score2[count] += abs(int(sum));
				
		
		}

        printf("probe1\n");
	
 
	
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
			sprintf(dataValue,  "%08x", score1[i]);//
		
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
    cudaFree(resultArrayD);

    return 0;
}



// 0011001100100011001100110010001000110011001000110011001100100100100100100100100100100100100100100100
// 0011001100100011001100110010001000110011001000110011001100100100100100100100100100100100100100100100