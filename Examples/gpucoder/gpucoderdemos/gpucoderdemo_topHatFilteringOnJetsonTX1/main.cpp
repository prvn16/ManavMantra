/* Headers */
#include <iostream>
/* Opencv includes*/
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

/* CUDA includes*/
#include<cuda.h>
#include<cuda_runtime.h>


/* define input image width and Height (Here: rice.png)*/
#define IMG_WIDTH 256
#define IMG_HEIGHT 256

using namespace cv;
using namespace std;

/* imtophat source headers*/
#include "imtophatDemo_gpu.h"

// Header to include chrono timers.
#include <chrono>
using namespace std::chrono;


int main(int argc, const char * const argv[])
{
    /* Input arguments */
    if(argc!=2)
    {
        cout<<"usage:<topHatFiltering_exe> <imagefile> "<<endl;
        return -1;
    }
    
    /* GPU warm up */
    double* CudaTemp = NULL;
    cudaMalloc(&CudaTemp,500*sizeof(double));
    cudaFree(CudaTemp);
    
    /*Input and Output Mat objects*/
    Mat inImg, outImg;
    unsigned char output[IMG_HEIGHT*IMG_WIDTH];
    
    char mode[100];
    double totalTime = 0;
    int frameCount = 1;
    /* Start reading frame */
    inImg = imread("rice.png",CV_LOAD_IMAGE_GRAYSCALE);
    // running operations on same image.
    while(1)
    {
        // Process the input frame
        high_resolution_clock::time_point gpuTimerStart = high_resolution_clock::now();//Start Timer
        
        // Entry point function for generated GPU code.
        imtophatDemo_gpu(inImg.data,output);
                
        high_resolution_clock::time_point gpuTimePointEnd = high_resolution_clock::now(); //End Timer
        totalTime += (double)duration_cast<milliseconds>(gpuTimePointEnd - gpuTimerStart).count();
        
        // Copy the output to a Mat buffer for display
        Mat outImg(inImg.size(),inImg.type(),output);
        
        /* used gamma correction for contrast streching*/
        Mat finalOutImg = Mat::zeros( outImg.size(), outImg.type() );
        double alpha = 2.0; /*< Simple contrast control */
        int beta = 0;
        for( int y = 0; y < outImg.rows; y++ ) {
            for( int x = 0; x < outImg.cols; x++ ) {
                finalOutImg.at<uchar>(y,x) =
                        saturate_cast<uchar>( alpha*( outImg.at<uchar>(y,x) ) + beta );
            }
        }
        
        // Displaying content on frame.
        char fname[100];
        imshow("input image",inImg);
        // Calculating FPS
        double avgFPS = 1000/(totalTime/frameCount);
        sprintf(fname,"FPS:%.2f",avgFPS);
        
        cv::rectangle(finalOutImg,
                cv::Rect((int)(0.78*finalOutImg.cols),(int)(0.01*finalOutImg.rows),(int)(0.97*finalOutImg.cols),(int)(0.12*finalOutImg.rows)),
                cv::Scalar(0),
                CV_FILLED,
                1);
        putText(finalOutImg, fname, Point(5, 15), FONT_HERSHEY_SIMPLEX, 0.5, Scalar(255, 0, 0), 2);
        putText(finalOutImg, mode, Point(200,15), FONT_HERSHEY_SIMPLEX, 0.5, Scalar(255, 0, 0), 2);
        
        char key;
        imshow("imtophat Output",finalOutImg);
        key = waitKey(2);
        
        // ESC: To stop execution.
        switch(key)
        {
            case 27 : exit(-1);
            break;
        }
        ++frameCount;
    }
    return 0;
}
