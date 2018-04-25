/* Copyright 2016 The MathWorks, Inc. */

#include "time.h"
#include <stdio.h>
#include <string.h>
#include <cuda.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>

/********** INCLUDE FILES **********/
// Insert include files here
/***********************************/

/********** IMAGE PARAMETERS **********/
// Define the image parameters here
#define FRAME_COLS    1920    /* image width (number of columns) */
#define FRAME_ROWS    1080    /* image height (number of rows) */
#define FRAME_DEPTH   3       /* image depth (number of channels) */
#define FRAME_FOURCC  CV_8UC3 /* image format (OpenCV FOURCC format) */
/***********************************/

static const char* windowName = "DEMO";

using namespace std;
using namespace cv;

/* Error checking macro */
#define OCVCHECK(errCall) ocvErrCheck(errCall, __LINE__, __FILE__);

/* OpenCV Error Checking Function */
void ocvErrCheck(bool errFlag, int line, const char* file) {
    if (!errFlag) {
        printf("OPENCV Error detected at %d in %s\n", line, file);
    }
}

// Main function
int main(int argc, char* argv[]) {
    cudaEvent_t start, stop;
    Mat inFrame, outFrame;
    void *inFrameData = NULL, *outFrameData = NULL;
    float fps = 0;

    // Open the default camera, use something different from 0 otherwise. Check VideoCapture documentation.
    VideoCapture cap(0);
    if (!cap.isOpened()) {
        printf("Could not open the video capture device.\n");
        return -1;
    }

    // Set the video stream properties
    OCVCHECK(cap.set(CV_CAP_PROP_FOURCC, INPUT_FOURCC));
    OCVCHECK(cap.set(CV_CAP_PROP_FRAME_WIDTH, FRAME_COLS));
    OCVCHECK(cap.set(CV_CAP_PROP_FRAME_HEIGHT, FRAME_ROWS));

    // Allocate the input and output video frames
    inFrame.create(FRAME_ROWS, FRAME_COLS, FRAME_FOURCC);
    outFrame.create(FRAME_ROWS, FRAME_COLS, FRAME_FOURCC);

    // Allocate the host-side input and output data buffers 
    int dataSize = FRAME_ROWS*FRAME_COLS*FRAME_DEPTH*inFrame.elemSize1();
    inFrameData = cudaMalloc(dataSize);
    outFrameData = cudaMalloc(dataSize);

    if ((inFrameData == NULL) || (outFrameData == NULL)) {
        printf("ERROR: Could not allocate host-side data buffers\n");
        return -1;
    }

    // Create cuda timing events
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Initialize output display window
    namedWindow(windowName, CV_WINDOW_AUTOSIZE);    

    for (;;)
    {
        // Read input video frame 
        cap >> inFrame;
        if (inFrame.empty()) { break; }

        // Start CUDA timing
        cudaEventRecord(start);

        // Copy data from host video frame to device data buffer
        cudaMemcpy(inFrameData, inFrame.data, dataSize, cudaMemcpyHostToDevice);

        /* KERNEL LAUNCH */
        /* Call your custome image-in-image-out CUDA kernel here */

        // Copy data from output data buffer to host output video frame
        cudaMemcpy(outFrame.data, outFrameData, dataSize, cudaMemcpyDeviceToHost);

        // End CUDA timing and synchronize
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        // Calculate frame rate and display it within the output frame
        char strbuf[50];
        float milliseconds = -1.0;        
        cudaEventElapsedTime(&milliseconds, start, stop);
        fps = fps*.9+1000.0/milliseconds*.1;
        sprintf (strbuf, "%.2f FPS", fps);
        OCVCHECK(putText(outFrame, strbuf, cvPoint(30,30), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(220,220,220), 1));

        // Display output frame
        imshow(windowName, outFrame);

        // Stop capturing video and exit the program by pressing ESC
        if( waitKey(1)%256 == 27 ) { break; }
    }

    // Clean up created/allocated objects
    destroyWindow(windowName);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    free(outFrameData);
    free(inFrameData);
    inFrame.release();
    outFrame.release();
    cap.release();
    
    return 0;
}

