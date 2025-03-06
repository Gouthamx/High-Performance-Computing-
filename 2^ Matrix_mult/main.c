#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define SIZE 32 // 2**5

void multiplyMatrices(int firstMatrix[SIZE][SIZE], int secondMatrix[SIZE][SIZE], int result[SIZE][SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            result[i][j] = 0;
            for (int k = 0; k < SIZE; k++) {
                result[i][j] += firstMatrix[i][k] * secondMatrix[k][j];
            }
        }
    }
}

void printMatrix(int matrix[SIZE][SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
}

int main() {
    int firstMatrix[SIZE][SIZE], secondMatrix[SIZE][SIZE], result[SIZE][SIZE];
    
    srand(time(NULL));

    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            firstMatrix[i][j] = rand() % 100; // Random values between 0 and 99
            secondMatrix[i][j] = rand() % 100;
        }
    }

    multiplyMatrices(firstMatrix, secondMatrix, result);

    printf("Resultant Matrix:\n");
    printMatrix(result);

    return 0;
}