#include <stdio.h>           
#include <stdlib.h>        
#include <cuda_runtime.h>
#include "device_launch_parameters.h"


constexpr int N = 1024;

static  __global__ void matrixMul(const int* a, const int* b, int* c, int N) {
	// Compute each thread's global row and column index
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;

	// Iterate over row, and down column
	c[row * N + col] = 0;
	for (int k = 0; k < N; k++) {
		// Accumulate results for a single element
		c[row * N + col] += a[row * N + k] * b[k * N + col];
	}
}

void verify_result(int* a, int* b, int* c, int N) {
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			for (int k = 0; k < N; k++) {
				c[i * N + j] += a[i * N + k] * b[k * N + j];
			}
		}
	}
}


int main() {
	int size = N * N * sizeof(int);

	// Allocate CPU Memory
	int* h_a = (int*)malloc(size);
	int* h_b = (int*)malloc(size);
	int* h_c = (int*)malloc(size);

	// Initialize Matrix
	for (int i = 0; i < N * N; i++) {
		h_a[i] = rand() % 100;  // Random integer between 0 and 99
		h_b[i] = rand() % 100;
	}

	// Initialize GPU Var
	int* d_a, * d_b, * d_c;

	// Allocate device memory
	cudaMalloc(&d_a, size);
	cudaMalloc(&d_b, size);
	cudaMalloc(&d_c, size);

	// Copy data to the device
	cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

	// Threads per CTA dimension
	int THREADS = 32;

	// Blocks per grid dimension (assumes THREADS divides N evenly)
	int BLOCKS = N / THREADS;

	// Use dim3 structs for block  and grid dimensions
	dim3 threads(THREADS, THREADS);
	dim3 blocks(BLOCKS, BLOCKS);

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaEventRecord(start, 0);

	// Launch kernel
	matrixMul << <blocks, threads >> > (d_a, d_b, d_c, N);
	cudaDeviceSynchronize();

	// Copy back to the host
	cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);

	// Check result
	verify_result(h_a, h_b, h_c, N);

	printf("COMPLETED SUCCESSFULLY\n");

	float GPU_time = 0.0f;
	cudaEventElapsedTime(&GPU_time, start, stop);
	printf("%f ms \n",GPU_time);

	// Free memory on device
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
	system("pause");
	return 0;
}