#include <stdio.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>

#pragma comment(lib, "cuda.lib")
#pragma comment(lib, "cudart.lib")
#include <cuda.h>
#include <math.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include "device_launch_parameters.h"
#include <cublas_v2.h>

using namespace std;

#define BLOCK_SIZE 16

const int n = 512;



//Popunjavanje matrice
void initializeMatrix(double* L, int matrixSize) {
	int row, col;
	
	
	srand(3333);
	for (row = 0; row < matrixSize; row++) {
		for (col = 0; col < matrixSize; col++)
		{
			L[row * matrixSize + col]= rand()%10;
		
		}
	}
	
}

void initializeIdentityMatrix(double* I, int matrixSize)
{

	int row, col;
	for (row = 0; row < matrixSize; row++) {
		for (col  = 0; col < matrixSize; col++) {
			if (row == col) I[row * matrixSize + row] = 1.0;
			else I[row *matrixSize + col] = 0.0;
		}
	}
}




//Funkcije za računanje inverza
__global__ void nodiag_normalize(double* A, double* I, int n, int i) {
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < n && y < n)
		if (x == i && x != y) {
			I[x * n + y] /= A[i * n + i];
			A[x * n + y] /= A[i * n + i];
		}

}




__global__ void diag_normalize(double* A, double* I, int n, int i) {
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < n && y < n)
		if (x == y && x == i) {
			I[x * n + y] /= A[i * n + i];
			A[x * n + y] /= A[i * n + i];
		}

}

__global__ void gaussjordan(double* A, double* I, int n, int i)
{
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < n && y < n) {
		if (x != i) {
			I[x * n + y] -= I[i * n + y] * A[x * n + i];
			if (y != i) {
				A[x * n + y] -= A[i * n + y] * A[x * n + i];
			}
		}
	}

}

__global__ void set_zero(double* A, double* I, int n, int i) {
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < n && y < n) {
		if (x != i) {
			if (y == i) {
				A[x * n + y] = 0;
			}
		}
	}
}



//Funkcije za ispis
void printMatrix(double* L, int matrixSize) {

	int row, col;
	for (row = 0; row < matrixSize; row++) {
		for (col = 0; col < matrixSize; col++)
		{
			cout << L[row * matrixSize + col] << " ";
		}
			
		cout << endl;
		
	}
}

void printInverse(double* iL, int dimension)
{
	int row, col;
	for (row = 0; row < dimension; row++) {
		for (col = 0; col < dimension; col++)
		{
			cout << iL[row * dimension + col] << " ";
		}

		cout << endl;

	}
}



bool isValid(double *L, double *iL)
{
	int row, col;
	bool flag = true;
	double* c = new double[n * n];

	for (row = 0; row < n; row++)
	{
		for (col = 0; col < n; col++)
		{
			c[row * n + col] = 0;  
			for (int x = 0; x < n; x++)
			{
				c[row * n + col] += L[row * n + x] * iL[x * n + col]; 

			}

			
		}

	}

	//Provjerja je li matrica s lijeve strane jedinična
	for (row = 0; row < n; row++)
	{
		for (col = 0; col < n; col++)
		{
			if (row == col)
			{
				if (c[row * n + col] >1+ 1e-09 || c[row * n + col] < 1-1e-09)
				{
					
					
					flag = false;
					
				}
				//cout << c[row * n + col]<< " ";
				//printf("%.16f", c[row * n + col]);
			}

			else
			{
				if (c[row * n + col] > 1e-09 || c[row * n + col] < -1e-09)
				{
					
					flag = false;
					
				}
			}

		}



	}

	return flag;

}


int main()
{
	
	// creating input
	double* iL = new double[n * n];
	double* L = new double[n * n];
	initializeMatrix(&L[0], n);
	
	//printMatrix(&L[0], n);

	
	double* d_A, * d_L, * I, * d_I;
	float time;
	cudaError_t err;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	int allocationSize = n * n * sizeof(double);

	dim3 threadsPerBlock(BLOCK_SIZE, BLOCK_SIZE);
	dim3 numBlocks((n + BLOCK_SIZE - 1) / BLOCK_SIZE, (n + BLOCK_SIZE - 1) / BLOCK_SIZE);

	// alokacija memorije    
	cudaMalloc((void**)&d_A, allocationSize);
	
	cudaMalloc((void**)&d_I, allocationSize);
	
	I = new double[n * n];


	initializeIdentityMatrix(I, n);
	
	//Pokretanje timera
	cudaEventRecord(start, 0);

	//kopiranje s hosta na device
	cudaMemcpy(d_A, L, allocationSize, cudaMemcpyHostToDevice);
	
    cudaMemcpy(d_I, I, allocationSize, cudaMemcpyHostToDevice);
	


	// Racunanje inverza    
	for (int i = 0; i < n; i++) {
		nodiag_normalize << <numBlocks, threadsPerBlock >> > (d_A, d_I, n, i);
		diag_normalize << <numBlocks, threadsPerBlock >> > (d_A, d_I, n, i);
		gaussjordan << <numBlocks, threadsPerBlock >> > (d_A, d_I, n, i);
		set_zero << <numBlocks, threadsPerBlock >> > (d_A, d_I, n, i);
	}


	//kopiranje s devicea na hosta
	cudaMemcpy(iL, d_I, allocationSize, cudaMemcpyDeviceToHost);
	
	cudaMemcpy(I, d_A, allocationSize, cudaMemcpyDeviceToHost);
	

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time, start, stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);

	cout << "Vrijeme: " << time << "ms\n";
	
	
	//printMatrix(L, n);
	//printInverse(iL,n);

	/////////////////////////////////////////////////////////////////
	///						Provjera tocnosti					  ///
	/////////////////////////////////////////////////////////////////
	if (isValid(L, iL))
	{
		cout << "Rezultat je tocan!" << endl;
	}

	else {
		cout << "Rezultat je netocan" << endl;
	}
	



	cudaFree(d_A);
	cudaFree(d_I);

	
	

	delete[]I;
	delete[]L;
	delete[]iL;

	system("Pause");
	return 0;
}