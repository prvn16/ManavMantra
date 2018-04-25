/* Copyright 2016 The MathWorks, Inc. */

|>HEADERINCLUDE<|

#include <stdio.h>
#include <cuda.h>
#include "opencv2/opencv.hpp"

using namespace cv;

// Main function
int main(int argc, char* argv[])
{
    int n = 1;

    if (argc > 1) {
        n = atoi(argv[1]);
    }
    
    |>NETWORKTYPE<|* net = new |>NETWORKTYPE<|;

    net->batchSize = n;
    net->setup();

    VideoCapture cap(0); // Open the default camera, use something different from 0 otherwise. Check VideoCapture documentation.

    if (!cap.isOpened()) {
        printf("Could not open the video capture device.\n");
        return -1;
    }

    cudaEvent_t start, stop;
    Mat inFrame, outFrame;
    float fps = 0;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    for (;;)
    {
        cudaEventRecord(start);

        cap >> inFrame;
        if (inFrame.empty()) { break; }
        
        cudaMemcpy( net->inputData, inFrame.data, sizeof(|>INDATATYPE<|)*|>INDATASIZE<|, cudaMemcpyHostToDevice );

        net->predict();

        cudaMemcpy( outFrame.data, net->outputData, sizeof(|>OUTDATATYPE<|)*|>OUTDATASIZE<|, cudaMemcpyDeviceToHost );
        
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        char strbuf[50];
        float milliseconds = -1.0;
        
        cudaEventElapsedTime(&milliseconds, start, stop);
        fps = fps*.9+1000.0/milliseconds*.1;
        sprintf (strbuf, "%.2f FPS", fps);
        putText(outFrame, strbuf, cvPoint(30,30), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(220,220,220), 1);

        imshow("DEMO", outFrame);

        if( waitKey(1)%256 == 27 ) { break; } // stop capturing by pressing ESC
    }

    net->cleanup();
    delete net;
    
    return 0;
}

