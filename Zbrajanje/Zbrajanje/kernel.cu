
#include <iostream>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include "device_launch_parameters.h"
#include <chrono>
#include <ctime>
using namespace std;


#define matrixSize 3000



int A[matrixSize][matrixSize];
int B[matrixSize][matrixSize];
int C_GPU[matrixSize][matrixSize];
int C_CPU[matrixSize][matrixSize];




//Zbrajanje matrica
__global__ void matrixAddition_GPU(int* A, int* B, int* C) {

    int x = blockIdx.x;
    int y = blockIdx.y;
    int id = gridDim.x * y + x;
    C[id] = A[id] + B[id];

}


void matrixAddition_CPU() {

    int row, col;
    for (row = 0; row < matrixSize; row++)
    {
        for (col = 0; col < matrixSize; col++)
        {
            C_CPU[row][col] = A[row][col] + B[row][col];
        }
    }
}


//Popunjavanje matrica
void fillMatrices()
{
    int row, col;
    for (row = 0; row < matrixSize; row++)
    {
        for (col = 0; col < matrixSize; col++)
        {
            A[row][col] = rand() % 10;
            B[row][col] = rand() % 10;
        }
    }
}


//Ispis matrica
void printResult()
{
    cout << "Result matrix:" << endl;
    int row, col;
    for (row = 0; row < matrixSize; row++)
    {
        for (col = 0; col < matrixSize; col++)
        {
            cout << C_GPU[row][col] << " ";
        }

        cout << endl;
    }


    cout << "Na CPU:" << endl;
    for (row = 0; row < matrixSize; row++)
    {
        for (col = 0; col < matrixSize; col++)
        {
            cout << C_CPU[row][col] << " ";
        }

        cout << endl;
    }
}



void printMatrices()
{

    int row, col;

    cout << "First matrix:" << endl;
    for (row = 0; row < matrixSize; row++)
    {
        for (col = 0; col < matrixSize; col++)
        {
            cout << A[row][col] << " ";
        }

        cout << endl;
    }


    cout << "Second matrix:" << endl;
    for (row = 0; row < matrixSize; row++)
    {
        for (col = 0; col < matrixSize; col++)
        {
            cout << B[row][col] << " ";
        }

        cout << endl;
    }
}


//Provjera tocnosti
bool isValid()
{
    int row, col;
    for (row = 0; row < matrixSize; row++)
    {
        for (col = 0; col < matrixSize; col++)
        {
            if (C_GPU[row][col] != C_CPU[row][col]) {
                return false;
            }
        }
    }

    return true;
}

int main() {

    ////////////////////////////////////////////
    //               GPU verzija             //
    ////////////////////////////////////////////
    float time_GPU;
    int* A_d, * B_d, * C_d;

    cudaEvent_t start_GPU, stop_GPU;
    cudaEventCreate(&start_GPU);
    cudaEventCreate(&stop_GPU);

    
    fillMatrices();

    //printMatrices();


    //Alociranje memorije na GPU-u
    cudaMalloc((void**)&A_d, matrixSize * matrixSize * sizeof(int));
    cudaMalloc((void**)&B_d, matrixSize * matrixSize * sizeof(int));
    cudaMalloc((void**)&C_d, matrixSize * matrixSize * sizeof(int));


    //Pokretanje timera
    cudaEventRecord(start_GPU, 0);

    cudaMemcpy(A_d, A, matrixSize * matrixSize * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B, matrixSize * matrixSize * sizeof(int), cudaMemcpyHostToDevice);



    dim3 dimGrid(matrixSize, matrixSize);


    //Pozivanje CUDA funkcije
    matrixAddition_GPU << < dimGrid, 1 >> > (A_d, B_d, C_d);


    cudaMemcpy(C_GPU, C_d, matrixSize * matrixSize * sizeof(int), cudaMemcpyDeviceToHost);
    cudaEventRecord(stop_GPU, 0);
    cudaEventSynchronize(stop_GPU);
    cudaEventElapsedTime(&time_GPU, start_GPU, stop_GPU);
    cudaEventDestroy(start_GPU);
    cudaEventDestroy(stop_GPU);

    cout << "Vrijeme na GPU: " << time_GPU << "ms\n";



    //////////////////////////////////////////////////
    //                    CPU verzija               //
    //////////////////////////////////////////////////
    auto start_CPU = chrono::high_resolution_clock::now();
    matrixAddition_CPU();
    auto stop_CPU = chrono::high_resolution_clock::now();

    auto time_CPU = chrono::duration_cast<chrono::milliseconds>(stop_CPU - start_CPU);

    cout << "Vrijeme na CPU:" << time_CPU.count() << endl;;


    ///////////////////////////////////////////////
    //             Provjera točnosti            //
   ////////////////////////////////////////////////

    //printMatrices();
   // printResult();

    if (isValid())
    {
        cout << "Rezultat je tocan!";
    }

    else
    {
        cout << "Rezultat je netocan!";
    }


    cudaFree(A_d);
    cudaFree(B_d);
    cudaFree(C_d);
    return 0;


}