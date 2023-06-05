#include <iostream>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include "device_launch_parameters.h"
#include <chrono>
#include <ctime>
using namespace std;


#define matrixSize 3000


//int** A=NULL;
//int** B=NULL;
//int** C_GPU= NULL;
//int** C_CPU= NULL;
#define BLOCK_SIZE 50


//void allocateMatrices()
//{
//    A = new int* [matrixSize];
//    B = new int* [matrixSize];
//    C_GPU = new int* [matrixSize];
//    C_CPU = new int* [matrixSize];
//
//    for (int i = 0; i < matrixSize; i++) {
//
//        // Declare a memory block
//        // of size n
//        A[i] = new int[matrixSize];
//        B[i] = new int[matrixSize];
//        C_GPU[i] = new int[matrixSize];
//        C_CPU[i] = new int[matrixSize];
//    }
//
//}




int A[matrixSize][matrixSize];
int B[matrixSize][matrixSize];
int C_GPU[matrixSize][matrixSize];
int C_CPU[matrixSize][matrixSize];




 //Matrix addition kernel
__global__ void matrixAddition_GPU(int* A, int* B, int* C) {
    
    int x = blockIdx.x;
    int y = blockIdx.y;
    int id = gridDim.x * y + x;
    C[id] = A[id] + B[id];

    /*int x = blockIdx.x + threadIdx.x;
    int y= blockIdx.y + threadIdx.y;
    int id =gridDim.x * y + x;
    C[id] = A[id] + B[id];
    */
    
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

void printResult()
{
    cout << "Result matrix:" << endl;
    int row, col;
    for (row = 0; row < matrixSize; row++)
    {
        for (col = 0; col < matrixSize; col++)
        {
            cout<<C_GPU[row][col]<<" ";
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
            cout << A[row][col]<<" ";
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
    //               GPU                     //
    ////////////////////////////////////////////
    float time_GPU;
    int* A_d, * B_d, * C_d;
    
	cudaEvent_t start_GPU, stop_GPU;
	cudaEventCreate(&start_GPU);
	cudaEventCreate(&stop_GPU);

    //allocateMatrices();
    fillMatrices();

    //printMatrices();

   

    cudaMalloc((void**)&A_d, matrixSize * matrixSize * sizeof(int));
    cudaMalloc((void**)&B_d, matrixSize * matrixSize * sizeof(int));
    cudaMalloc((void**)&C_d, matrixSize * matrixSize * sizeof(int));

    cudaMemcpy(A_d, A, matrixSize * matrixSize * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B, matrixSize * matrixSize * sizeof(int), cudaMemcpyHostToDevice);

   
   /* dim3 dimBlock(BLOCK_SIZE,BLOCK_SIZE);
    
    dim3 dimGrid((matrixSize + BLOCK_SIZE - 1) / BLOCK_SIZE, (matrixSize + BLOCK_SIZE - 1) / BLOCK_SIZE);*/

    dim3 dimGrid(matrixSize, matrixSize);
    cudaEventRecord(start_GPU, 0);

                            //grid matrix size i 1 thread
    matrixAddition_GPU << < dimGrid, 1 >> > (A_d, B_d, C_d);

    cudaEventRecord(stop_GPU, 0);
    cudaMemcpy(C_GPU, C_d, matrixSize * matrixSize * sizeof(int), cudaMemcpyDeviceToHost);
    
	cudaEventSynchronize(stop_GPU);
	cudaEventElapsedTime(&time_GPU, start_GPU, stop_GPU);
	cudaEventDestroy(start_GPU);
	cudaEventDestroy(stop_GPU);

    cout << "Vrijeme na GPU: " << time_GPU << "ms\n";

    

    //////////////////////////////////////////////////
      //                    CPU                       //
    //////////////////////////////////////////////////

    

    auto start_CPU = chrono::high_resolution_clock::now();
    matrixAddition_CPU();
    auto stop_CPU = chrono::high_resolution_clock::now();

    auto time_CPU = chrono::duration_cast<chrono::milliseconds>(stop_CPU - start_CPU);

    cout << "Vrijeme na CPU:" << time_CPU.count() << endl;;

    ///////////////////////////////////////////////
     //             Provjera ispravnosti       //
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

//#include <iostream>
//#include <cuda_runtime.h>
//#include <cuda_runtime_api.h>
//#include "device_launch_parameters.h"
//#include <chrono>
//
//using namespace std;
//
//#define matrixSize 100
//
//int A[matrixSize][matrixSize];
//int B[matrixSize][matrixSize];
//int C_GPU[matrixSize][matrixSize];
//int C_CPU[matrixSize][matrixSize];
//
//using namespace std;
//
//__global__ void matrixAddition_GPU(int A[][matrixSize], int B[][matrixSize], int C_GPU[][matrixSize]) {
//
//    int i = threadIdx.x;
//    int j = threadIdx.y;
//
//    C_GPU[i][j] = A[i][j] + B[i][j];
//}
//
//
//void matrixAddition_CPU() {
//
//    int row, col;
//    for (row = 0; row < matrixSize; row++)
//    {
//        for (col = 0; col < matrixSize; col++)
//        {
//            C_CPU[row][col] = A[row][col] + B[row][col];
//        }
//    }
//}
//
//void fillMatrices()
//{
//    int row, col;
//    for (row = 0; row < matrixSize; row++)
//    {
//        for (col = 0; col < matrixSize; col++)
//        {
//            A[row][col] = rand() % 10;
//            B[row][col] = rand() % 10;
//        }
//    }
//}
//
//bool isValid()
//{
//    int row, col;
//    for (row = 0; row < matrixSize; row++)
//    {
//        for (col = 0; col < matrixSize; col++)
//        {
//            if (C_GPU[row][col] != C_CPU[row][col]) {
//                return false;
//            }
//        }
//    }
//
//    return true;
//}
//
//void printResult()
//{
//    cout << "Result matrix:" << endl;
//    int row, col;
//    cout << "GPU:"<<endl;
//    for (row = 0; row < matrixSize; row++)
//    {
//        for (col = 0; col < matrixSize; col++)
//        {
//            cout<<C_GPU[row][col]<<" ";
//        }
//
//        cout << endl;
//    }
//
//    cout << "CPU:" << endl;
//    for (row = 0; row < matrixSize; row++)
//    {
//        for (col = 0; col < matrixSize; col++)
//        {
//            cout << C_CPU[row][col] << " ";
//        }
//
//        cout << endl;
//    }
//}
//
//int main() {
//
//    //////////////////////////////////////////////////////////
//    //////////              GPU                     //////////
//    //////////////////////////////////////////////////////////
// 
//    cudaEvent_t start_GPU, stop_GPU;
//	cudaEventCreate(&start_GPU);
//	cudaEventCreate(&stop_GPU);
//
//    float time_GPU;
//
//
//    int(*A_d)[matrixSize], (*B_d)[matrixSize], (*C_d)[matrixSize];
//
//    fillMatrices();
//
//    cudaMalloc((void**)&A_d, (matrixSize * matrixSize) * sizeof(int));
//    cudaMalloc((void**)&B_d, (matrixSize * matrixSize) * sizeof(int));
//    cudaMalloc((void**)&C_d, (matrixSize * matrixSize) * sizeof(int));
//
//
//    cudaEventRecord(start_GPU, 0);
//
//    cudaMemcpy(A_d, A, (matrixSize * matrixSize) * sizeof(int), cudaMemcpyHostToDevice);
//    cudaMemcpy(B_d, B, (matrixSize * matrixSize) * sizeof(int), cudaMemcpyHostToDevice);
//    cudaMemcpy(C_d, C_GPU, (matrixSize * matrixSize) * sizeof(int), cudaMemcpyHostToDevice);
//
//    int numBlocks = 1;
//    dim3 threadsPerBlock(matrixSize, matrixSize);
//    matrixAddition_GPU << < 1, threadsPerBlock>> > (A_d, B_d, C_d);
//
//    cudaMemcpy(C_GPU, C_d, (matrixSize * matrixSize) * sizeof(int), cudaMemcpyDeviceToHost);
//    cudaEventRecord(stop_GPU, 0);
//   
//    cudaEventSynchronize(stop_GPU);
//	cudaEventElapsedTime(&time_GPU, start_GPU, stop_GPU);
//	cudaEventDestroy(start_GPU);
//	cudaEventDestroy(stop_GPU);
//
//    cout << "Vrijeme na GPU: " << time_GPU << "ms\n";
//
//        //////////////////////////////////////////////////
//       //                   CPU                       //
//    //////////////////////////////////////////////////
//
//    
//
//    auto start_CPU = chrono::high_resolution_clock::now();
//    matrixAddition_CPU();
//    auto stop_CPU = chrono::high_resolution_clock::now();
//
//    auto time_CPU = chrono::duration_cast<chrono::microseconds>(stop_CPU - start_CPU);
//
//    cout << "Vrijeme na CPU:" << time_CPU.count() << endl;;
//
//    ///////////////////////////////////////////////
//       //               Provjera ispravnosti       //
//   ////////////////////////////////////////////////
//
//    if (isValid())
//    {
//        cout << "Rezultat je tocan!";
//    }
//
//    else
//    {
//        cout << "Rezultat je netocan!";
//    }
//
//    printResult();
//
//    cudaFree(A_d);
//    cudaFree(B_d);
//    cudaFree(C_d);
//
//    printf("\n");
//
//    return 0;
//}