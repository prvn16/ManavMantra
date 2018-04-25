/* Copyright 2016 The MathWorks, Inc. */

|>HEADERINCLUDE<|

#include <stdio.h>
#include <cuda.h>

void readData(void *inputBuffer)
{
    /* DATA INPUT CODE
     *   The code inserted here should write to the pre-allocated
     *   buffer 'inputBuffer'. This is the data that will be consumed
     *   by one iteration of the neural network.
     */
}

void writeData(void *outputBuffer)
{
    /* DATA OUTPUT CODE
     *   The code inserted here should read from the pre-allocated
     *   buffer 'outputBuffer'. This is the data that will be produced
     *   by one iteration of the neural network.
     */
}

// Main function
int main(int argc, char* argv[])
{

    |>INDATATYPE<| *inputBuffer = (|>INDATATYPE<|*)calloc(sizeof(|>INDATATYPE<|),|>INDATASIZE<|*|>BATCHSIZE<|);
    |>OUTDATATYPE<| *outputBuffer = (|>OUTDATATYPE<|*)calloc(sizeof(|>OUTDATATYPE<|),|>OUTDATASIZE<|*|>BATCHSIZE<|);

    if ((inputBuffer == NULL) || (outputBuffer == NULL)) {
        printf("ERROR: Input/Output buffers could not be allocated!\n");
        exit(-1);
    }
    
    |>NETWORKTYPE<|* net = new |>NETWORKTYPE<|;

    net->batchSize = |>BATCHSIZE<|;
    net->setup();

    for (;;)
    {
        readData(inputBuffer);
        
        cudaMemcpy( net->inputData, inputBuffer, sizeof(|>INDATATYPE<|)*|>INDATASIZE<|*|>BATCHSIZE<|, cudaMemcpyHostToDevice );

        net->predict();

        cudaMemcpy( outputBuffer, net->outputData, sizeof(|>OUTDATATYPE<|)*|>OUTDATASIZE<|*|>BATCHSIZE<|, cudaMemcpyDeviceToHost );

        writeData(outputBuffer);
    }

    net->cleanup();
    delete net;

    free(inputBuffer);
    free(outputBuffer);
        
    return 0;
}

