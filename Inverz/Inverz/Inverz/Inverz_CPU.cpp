//#include<stdio.h>
//#include<math.h>
//#include<iostream>
//#include<fstream>
//#include<time.h>
//#include <chrono>
//
//using namespace std;
//using namespace std::chrono;
//
//
//const int matrixSize = 1000;//dimension
//double augmentedmatrix[matrixSize][2 * matrixSize];    
//
//
//int i, j, k, temp;     /* declaring counter variables for loops */
//
//using namespace std;
//
//
//
//void printInverseMatrix() {
//
//	int row, col;
//	for (row = 0; row < matrixSize; row++) 
//	{
//		for (col = matrixSize; col < 2*matrixSize; col++)
//		{
//			cout << augmentedmatrix[row][col] << " ";
//		}
//
//		cout << endl;
//
//	}
//}
//
//void printMatrix() {
//
//	int row, col;
//	for (row = 0; row < matrixSize; row++)
//	{
//		for (col = 0; col <  matrixSize; col++)
//		{
//			cout << augmentedmatrix[row][col] << " ";
//		}
//
//		cout << endl;
//
//	}
//}
//
//void printAugmentedMatrix()
//{
//	int row, col;
//	for (row = 0; row < matrixSize; row++)
//	{
//		for (col = 0; col <2* matrixSize; col++)
//		{
//			cout << augmentedmatrix[row][col] << " ";
//		}
//
//		cout << endl;
//
//	}
//}
//
//
//void matrixRead(){
//	
//	int row, col;
//	
//	srand(3333);
//	for (row = 0; row < matrixSize; row++){
//		for (col = 0; col < 2 * matrixSize; col++){
//			if (col < matrixSize){
//				
//				augmentedmatrix[row][col]= rand() % 10;
//			}
//			else
//			{
//				if (row == col%matrixSize)
//					augmentedmatrix[row][col] = 1;
//				else
//					augmentedmatrix[row][col] = 0;
//
//			}
//		}
//		
//	}
//
//}
//
//
//void calculateInverse(){
//	double temporary, r;
//
//	for (j = 0; j<matrixSize; j++)
//	{
//
//		temp = j;
//
//		/* finding maximum jth column element in last (dimension-j) rows */
//
//		for (i = j + 1; i<matrixSize; i++)
//		if (augmentedmatrix[i][j]>augmentedmatrix[temp][j])
//			temp = i;
//
//		
//
//		/* swapping row which has maximum jth column element */
//
//		if (temp != j)
//		for (k = 0; k<2 * matrixSize; k++){
//			temporary = augmentedmatrix[j][k];
//			augmentedmatrix[j][k] = augmentedmatrix[temp][k];
//			augmentedmatrix[temp][k] = temporary;
//		}
//
//		/* performing row operations to form required identity matrix out of the input matrix */
//
//		for (i = 0; i<matrixSize; i++)
//		if (i != j)
//		{
//			r = augmentedmatrix[i][j];
//			for (k = 0; k<2 * matrixSize; k++)
//				augmentedmatrix[i][k] -= (augmentedmatrix[j][k] / augmentedmatrix[j][j])*r;
//		}
//		else
//		{
//			r = augmentedmatrix[i][j];
//			for (k = 0; k<2 * matrixSize; k++)
//				augmentedmatrix[i][k] /= r;
//		}
//
//	}
//}
//
//bool isValid()
//{
//	bool flag=true;
//
//	int row, col;
//	for (row = 0; row < matrixSize; row++)
//	{
//		for (col = 0; col < matrixSize; col++)
//		{
//			if (row == col)
//			{
//				if (augmentedmatrix[row][col] != 1)
//				{
//					
//					flag = false;
//				}
//			}
//
//			else
//			{
//				if (augmentedmatrix[row][col] != 0)
//				{
//					
//					flag = false;
//				}
//			}
//			
//		}
//	}
//
//
//	return flag;
//}
//
//int main(){
//	
//	
//	/*   storing augmented matrix as a matrix of dimension
//	(dimension)x(2*dimension) in 2D array  */
//	matrixRead();
//
//	
//
//
//
//	
//	auto start = high_resolution_clock::now();
//
//	/* using gauss-jordan elimination */
//	calculateInverse();
//
//	
//	auto stop = high_resolution_clock::now();
//
//
//	auto duration = duration_cast<milliseconds>(stop - start);
//	
//	cout << "CPU Time - inverse:\n" << duration.count() << " ms" << endl;
//
//
//
//	//printMatrix();
//	//Provjera toènosti
//	if (isValid())
//	{
//		cout << "Rezultat je tocan!" << endl;
//	}
//
//	else {
//		cout << "Rezultat je netocan!" << endl;
//	}
//
//
//	system("pause");
//	return 0;
//
//}
