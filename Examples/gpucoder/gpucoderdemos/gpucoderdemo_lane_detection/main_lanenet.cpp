/* Copyright 2016 The MathWorks, Inc. */

#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "opencv2/opencv.hpp"
#include <list>
#include <cmath>
#include "detect_lane.h"

using namespace cv;
void readData(float *input, Mat& orig, Mat & im)
{
	Size size(227,227);
	resize(orig,im,size,0,0,INTER_LINEAR);
	for(int j=0;j<227*227;j++)
	{
		//BGR to RGB
		input[2*227*227+j]=(float)(im.data[j*3+0]);
		input[1*227*227+j]=(float)(im.data[j*3+1]);
		input[0*227*227+j]=(float)(im.data[j*3+2]);
	}
}

void addLane(float pts[28][2], Mat & im, int numPts)
{
    std::vector<Point2f> iArray;
    for(int k=0; k<numPts; k++) 
    {
        iArray.push_back(Point2f(pts[k][0],pts[k][1]));    
    }	
    Mat curve(iArray, true);
    curve.convertTo(curve, CV_32S); //adapt type for polylines
    polylines(im, curve, false, CV_RGB(255,255,0), 2, CV_AA);
}


void writeData(float *outputBuffer, Mat & im, int N, double means[6], double stds[6])
{
    // get lane coordinates
    boolean_T laneFound = 0;	
    float ltPts[56];
    float rtPts[56];	
    detect_lane(outputBuffer, means, stds, &laneFound, ltPts, rtPts);    
	
	if (!laneFound)
	{
		return;
	}
	
	float ltPtsM[28][2];
	float rtPtsM[28][2];
	for(int k=0; k<28; k++)
	{
		ltPtsM[k][0] = ltPts[k];
		ltPtsM[k][1] = ltPts[k+28];
		rtPtsM[k][0] = rtPts[k];
		rtPtsM[k][1] = rtPts[k+28];   
	}		  

	addLane(ltPtsM, im, 28);
	addLane(rtPtsM, im, 28);
}

void readMeanAndStds(const char* filename, double means[6], double stds[6])
{
    FILE* pFile = fopen(filename, "rb");
    if (pFile==NULL)
    {
        fputs ("File error",stderr);
        return;
    }

    // obtain file size
    fseek (pFile , 0 , SEEK_END);
    long lSize = ftell(pFile);
    rewind(pFile);
    
    double* buffer = (double*)malloc(lSize);
    
    size_t result = fread(buffer,sizeof(double),lSize,pFile);
    if (result*sizeof(double) != lSize) {    
        fputs ("Reading error",stderr);
        return;
    }
    
    for (int k = 0 ; k < 6; k++)
    {
        means[k] = buffer[k];
        stds[k] = buffer[k+6];
    }
    free(buffer);        
}


// Main function
int main(int argc, char* argv[])
{    
	
    float *inputBuffer = (float*)calloc(sizeof(float),227*227*3);
    float *outputBuffer = (float*)calloc(sizeof(float),6);

    if ((inputBuffer == NULL) || (outputBuffer == NULL)) {
        printf("ERROR: Input/Output buffers could not be allocated!\n");
        exit(-1);
    }
    
    // get ground truth mean and std
    double means[6];
    double stds[6];	
    readMeanAndStds("mean.bin", means, stds);	
	
	if (argc < 2)
    {
        printf("Pass in input video file name as argument\n");
        return -1;
    }
    
    VideoCapture cap(argv[1]);
    if (!cap.isOpened()) {
        printf("Could not open the video capture device.\n");
        return -1;
    }

    cudaEvent_t start, stop;
    float fps = 0;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);    
    Mat orig, im;    
    namedWindow("Lane detection demo",CV_WINDOW_NORMAL);
    while(true)
    {
        cudaEventRecord(start);
        cap >> orig;
        if (orig.empty()) break;                
        readData(inputBuffer, orig, im);		

        writeData(inputBuffer, orig, 6, means, stds);
        
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        
        char strbuf[50];
        float milliseconds = -1.0; 
        cudaEventElapsedTime(&milliseconds, start, stop);
        fps = fps*.9+1000.0/milliseconds*.1;
        sprintf (strbuf, "%.2f FPS", fps);
        putText(orig, strbuf, cvPoint(200,30), CV_FONT_HERSHEY_DUPLEX, 1, CV_RGB(0,0,0), 2);
        imshow("Lane detection demo", orig); 		
        if( waitKey(50)%256 == 27 ) break; // stop capturing by pressing ESC	*/       
    }
    destroyWindow("Lane detection demo");
	
    free(inputBuffer);
    free(outputBuffer);
        
    return 0;
}
