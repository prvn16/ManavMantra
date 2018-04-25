/* Copyright 2016 The MathWorks, Inc. */

|>HEADERINCLUDE<|

#include <stdio.h>
#include <cuda.h>

extern void readData(void *inputBuffer);
extern void writeData(void *outputBuffer);

static |>INDATATYPE<| *inputBuffer = NULL;
static |>OUTDATATYPE<| *outputBuffer = NULL;
static |>NETWORKTYPE<| *net = NULL;

// Main function
void cnnMain_mex_setup()
{
    
    inputBuffer = (|>INDATATYPE<|*)calloc(sizeof(|>INDATATYPE<|),|>INDATASIZE<|*|>BATCHSIZE<|);
    outputBuffer = (|>OUTDATATYPE<|*)calloc(sizeof(|>OUTDATATYPE<|),|>OUTDATASIZE<|*|>BATCHSIZE<|);
    
    net = new |>NETWORKTYPE<|;
    net->batchSize = |>BATCHSIZE<|;
    net->setup();

}

void cnnMain_mex_run() {

    readData((void*)inputBuffer);
    cudaMemcpy( net->inputData, inputBuffer, sizeof(|>INDATATYPE<|)*|>INDATASIZE<|*|>BATCHSIZE<|, cudaMemcpyHostToDevice );

    net->predict();

    cudaMemcpy( outputBuffer, net->outputData, sizeof(|>OUTDATATYPE<|)*|>OUTDATASIZE<|*|>BATCHSIZE<|, cudaMemcpyDeviceToHost );
    writeData((void*)outputBuffer);

}

void cnnMain_mex_cleanup() {

    net->cleanup();
    delete net;
    
    if (inputBuffer != NULL) {
        free(inputBuffer);
    }
    if (outputBuffer != NULL) {
        free(outputBuffer);
    }
    
}

