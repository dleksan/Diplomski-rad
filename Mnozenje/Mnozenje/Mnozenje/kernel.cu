
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <chrono> 
#include <iostream>
using namespace std;

#define BLOCK_SIZE 16
const int matrixSize = 512;




//Mnozenje matrica
__global__ void gpu_matrix_mult(int* A, int* B, int* C, int matrixSize)
{

    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int sum = 0;

    if (col < matrixSize && row < matrixSize)
    {
        for (int i = 0; i < matrixSize; i++)
        {
            
            sum += A[row * matrixSize + i] * B[i * matrixSize + col];
        }

        
        C[row * matrixSize + col] = sum;
    }
}



void cpu_matrix_mult(int* A, int* B, int* C, int matrixSize) {
    for (int i = 0; i < matrixSize; ++i)
    {
        for (int j = 0; j < matrixSize; ++j)
        {
            int tmp = 0.0;
            for (int h = 0; h < matrixSize; ++h)
            {
                tmp += A[i * matrixSize + h] * B[h * matrixSize + j];
            }
            C[i * matrixSize + j] = tmp;
        }
    }
}



//Popunjavanje matrica
void initializeMatrices(int matrixSize, int* A, int* B)
{
    for (int i = 0; i < matrixSize; ++i) {
        for (int j = 0; j < matrixSize; ++j) {
            A[i * matrixSize + j] = rand() % 1024;
        }
    }


    for (int i = 0; i < matrixSize; ++i) {
        for (int j = 0; j < matrixSize; ++j) {
            B[i * matrixSize + j] = rand() % 1024;
        }
    }

}


//Provjera tocnosti
bool isValid(int matrixSize, int* hC, int* dC)
{

    for (int i = 0; i < matrixSize; ++i)
    {
        for (int j = 0; j < matrixSize; ++j)
        {
            
            if (dC[i * matrixSize + j] != hC[i * matrixSize + j])
            {
                return false;
            }
        }
        
    }

    return true;
}



int main(int argc, char const* argv[])
{



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          GPU verzija                                                                    //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    int* hA, * hB, * hC, * hCC;
    
    cudaMallocHost((void**)&hA, sizeof(int) * matrixSize * matrixSize);
    cudaMallocHost((void**)&hB, sizeof(int) * matrixSize * matrixSize);
    cudaMallocHost((void**)&hC, sizeof(int) * matrixSize * matrixSize);

    //Za CPU rezultat
    cudaMallocHost((void**)&hCC, sizeof(int) * matrixSize * matrixSize);

   
    initializeMatrices(matrixSize, hA, hB);
 

    float GPU_time;
   

    // Alociranje memorije na GPU-u
    int* dA, * dB, * dC;
    cudaMalloc((void**)&dA, sizeof(int) * matrixSize * matrixSize);
    cudaMalloc((void**)&dB, sizeof(int) * matrixSize * matrixSize);
    cudaMalloc((void**)&dC, sizeof(int) * matrixSize * matrixSize);


    //Pokretanje timera
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start, 0);


    //Kopiranje podataka na device
    cudaMemcpy(dA, hA, sizeof(int) * matrixSize * matrixSize, cudaMemcpyHostToDevice);
    cudaMemcpy(dB, hB, sizeof(int) * matrixSize * matrixSize, cudaMemcpyHostToDevice);

    unsigned int gridSize = (matrixSize + BLOCK_SIZE - 1) / BLOCK_SIZE;
    
    dim3 dimGrid(gridSize, gridSize);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  
    //Poziv CUDA funkcije
    gpu_matrix_mult << <dimGrid, dimBlock >> > (dA, dB, dC, matrixSize);


    //Kopiranje podataka na host-a
    cudaMemcpy(hC, dC, sizeof(int) * matrixSize * matrixSize, cudaMemcpyDeviceToHost);

    cudaThreadSynchronize();
   
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);  

    cudaEventElapsedTime(&GPU_time, start, stop);
    
    cout << "Vrijeme na GPU:" << GPU_time << "ms" << endl;



    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          CPU verzija                                                                    //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    auto clock_start_CPU = std::chrono::system_clock::now();

    cpu_matrix_mult(hA, hB, hCC, matrixSize);


    auto clock_now_CPU = std::chrono::system_clock::now();

    float CPU_time = float(std::chrono::duration_cast 
    <std::chrono::milliseconds> (clock_now_CPU - clock_start_CPU).count());


    std::cout << "Vrijeme na CPU: " << CPU_time << " ms \n";


   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          Provjera tocnosti                                                                  //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (isValid(matrixSize, hC, hCC))
    {
        
        cout << "Rezultat je tocan!" << endl;
    }
    else
    {
        cout << "Rezultati nije tocan" << endl;
        
    }

    // oslobodi memoriju
    cudaFree(dA);
    cudaFree(dB);
    cudaFree(dC);
    cudaFreeHost(hA);
    cudaFreeHost(hB);
    cudaFreeHost(hC);
    cudaFreeHost(hCC);
    return 0;
}