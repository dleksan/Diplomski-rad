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
//const int matrixSize = 1000;
//double A[matrixSize][2 * matrixSize];    
//
//
//
//
//using namespace std;
//
//
////Funkcija za popunjavanje
//void matrixRead(){
//	
//	int row, col;
//	
//	srand(3333);
//	for (row = 0; row < matrixSize; row++){
//		for (col = 0; col < 2 * matrixSize; col++){
//			if (col < matrixSize){
//				
//				A[row][col]= rand() % 10;
//			}
//			else
//			{
//				if (row == col%matrixSize)
//					A[row][col] = 1;
//				else
//					A[row][col] = 0;
//
//			}
//		}
//		
//	}
//
//}
//
//
////Funkcije za ispis
//void printInverseMatrix() {
//
//	int row, col;
//	for (row = 0; row < matrixSize; row++) 
//	{
//		for (col = matrixSize; col < 2*matrixSize; col++)
//		{
//			cout << A[row][col] << " ";
//		}
//
//		cout << endl;
//
//	}
//}
//
//
//
//void printMatrix() {
//
//	int row, col;
//	for (row = 0; row < matrixSize; row++)
//	{
//		for (col = 0; col <  matrixSize; col++)
//		{
//			cout << A[row][col] << " ";
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
//			cout << A[row][col] << " ";
//		}
//
//		cout << endl;
//
//	}
//}
//
//
//
//
//void calculateInverse(){
//
//
//	int temp;
//	double temp1, r;
//
//	for (int j = 0; j<matrixSize; j++)
//	{
//
//		temp = j;
//
//		/* finding maximum jth column element in last (dimension-j) rows */
//
//		for (int i = j + 1; i<matrixSize; i++)
//		if (A[i][j]>A[temp][j])
//			temp = i;
//
//		
//
//		/* swapping row which has maximum jth column element */
//
//		if (temp != j)
//		for (int k = 0; k<2 * matrixSize; k++){
//			temp1 = A[j][k];
//			A[j][k] = A[temp][k];
//			A[temp][k] = temp1;
//		}
//
//		/* performing row operations to form required identity matrix out of the input matrix */
//
//		for (int i = 0; i<matrixSize; i++)
//		if (i != j)
//		{
//			r = A[i][j];
//			for (int k = 0; k<2 * matrixSize; k++)
//				A[i][k] -= (A[j][k] / A[j][j])*r;
//		}
//		else
//		{
//			r = A[i][j];
//			for (int k = 0; k<2 * matrixSize; k++)
//				A[i][k] /= r;
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
//				if (A[row][col] != 1)
//				{
//					
//					flag = false;
//				}
//			}
//
//			else
//			{
//				if (A[row][col] != 0)
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
//	//Uèitavanja matrice
//	matrixRead();
//
//	
//
//
//
//	//Pokretanje timera
//	auto start = high_resolution_clock::now();
//
//	//Raèunanje inverza
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
//	
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
