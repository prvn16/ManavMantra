/* Copyright 2016 The MathWorks, Inc. */

#include "cnn_exec.hpp"
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <iostream>
#include "opencv2/opencv.hpp"
using namespace cv;

int readData(void* inputBuffer, char* inputImage) {


    Mat inpImage, intermImage;

    inpImage = imread(inputImage, 1);

    Size size(227, 227);
    resize(inpImage, intermImage, size);
    if (!intermImage.data) {
        printf(" No image data \n ");
        exit(1);
    }
    float* input = (float*)inputBuffer;

    for (int j = 0; j < 227 * 227; j++) {
        // BGR to RGB
        input[2 * 227 * 227 + j] = (float)(intermImage.data[j * 3 + 0]);
        input[1 * 227 * 227 + j] = (float)(intermImage.data[j * 3 + 1]);
        input[0 * 227 * 227 + j] = (float)(intermImage.data[j * 3 + 2]);
    }

    return 1;
}

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) || defined(_WIN64)

int cmpfunc(void* r, const void* a, const void* b) {
    float x = ((float*)r)[*(int*)b] - ((float*)r)[*(int*)a];
    return (x > 0 ? ceil(x) : floor(x));
}
#else

int cmpfunc(const void* a, const void* b, void* r) {
    float x = ((float*)r)[*(int*)b] - ((float*)r)[*(int*)a];
    return (x > 0 ? ceil(x) : floor(x));
}

#endif

void top(float* r, int* top5) {
    int t[32];
    for (int i = 0; i < 32; i++) {
        t[i] = i;
    }
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) || defined(_WIN64)
    qsort_s(t, 32, sizeof(int), cmpfunc, r);
#else
    qsort_r(t, 32, sizeof(int), cmpfunc, r);
#endif
    top5[0] = t[0];
    top5[1] = t[1];
    top5[2] = t[2];
    top5[3] = t[3];
    top5[4] = t[4];
    return;
}


int prepareSynset(char synsets[32][100]) {
    FILE* fp1 = fopen("synsetWords.txt", "r");
    if (fp1 == 0) {
        return -1;
    }

    for (int i = 0; i < 32; i++) {
        if (fgets(synsets[i], 100, fp1) != NULL)
            ;
        strtok(synsets[i], "\n");
    }
    fclose(fp1);
    return 0;
}

void writeData(float* output, char synsetWords[32][100]) {
    int top5[5], j;

    top(output, top5);
    printf("CNNCodegen Top 5 Predictions: \n");
    printf("----------------------------- \n");
    printf("%4.3f%% %s\n", output[top5[0]] * 100, synsetWords[top5[0]]);
    printf("%4.3f%% %s\n", output[top5[1]] * 100, synsetWords[top5[1]]);
    printf("%4.3f%% %s\n", output[top5[2]] * 100, synsetWords[top5[2]]);
    printf("%4.3f%% %s\n", output[top5[3]] * 100, synsetWords[top5[3]]);
    printf("%4.3f%% %s\n", output[top5[4]] * 100, synsetWords[top5[4]]);
}

// Main function
int main(int argc, char* argv[]) {
    int n = 1;int i;
    char synsetWords[32][100];
    float inputBuffer[227*227*3];
    float outputBuffer[32];
    if (argc != 2) {
        printf("Input image missing \nSample Usage-./logodetdemo image.png\n");
        exit(1);
    }
    if (prepareSynset(synsetWords) == -1) {
        printf("ERROR: Unable to find synsetWords.txt\n");
        return -1;
    }


    CnnMain* net = new CnnMain;
    net->batchSize = n;
    net->setup();
    readData(inputBuffer, argv[1]);

    cudaMemcpy( net->inputData, inputBuffer, sizeof(float)*227*227*3,cudaMemcpyHostToDevice );
    net->predict();
    cudaMemcpy( outputBuffer, net->outputData , sizeof(float)*32,cudaMemcpyDeviceToHost );
    writeData(outputBuffer, synsetWords);
    delete net;
    return 0;
}
