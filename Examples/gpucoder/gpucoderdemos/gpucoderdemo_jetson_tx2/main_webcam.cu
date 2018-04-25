/* Copyright 2016 The MathWorks, Inc. */

#include <stdio.h>
#include <cuda.h>
#include "opencv2/opencv.hpp"
#include "alexnet_predict.h"

using namespace cv;

void readData(float *input, const Mat& orig, Mat & im)
{
    /* DATA INPUT CODE
     *   The code inserted here should write to the pre-allocated
     *   buffer 'inputBuffer'. This is the data that will be consumed
     *   by one iteration of the neural network.
     */	
    Size size(227,227);
    resize(orig,im,size);
    for(int j=0;j<227*227;j++)
    {
        //BGR to RGB
        input[2*227*227+j]=(float)(im.data[j*3+0]);
        input[1*227*227+j]=(float)(im.data[j*3+1]);
        input[0*227*227+j]=(float)(im.data[j*3+2]);
    }	
}

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) || defined(_WIN64)

int cmpfunc(void* r, const void * a, const void * b)
{
	float x =  ((float*)r)[*(int*)b] - ((float*)r)[*(int*)a] ;
	return ( x > 0 ? ceil(x) : floor(x) );
}
#else

int cmpfunc(const void * a, const void * b, void * r)
{
	float x =  ((float*)r)[*(int*)b] - ((float*)r)[*(int*)a] ;
	return ( x > 0 ? ceil(x) : floor(x) );
}

#endif


void top( float* r, int* top5 )
{
    int n = 1000;
    int t[1000];
    for(int i=0; i<1000; i++)
        t[i]=i;
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) || defined(_WIN64)
	qsort_s(t, 1000, sizeof(int), cmpfunc, r);
#else
	qsort_r(t, 1000, sizeof(int), cmpfunc, r);
#endif
    top5[0]=t[0];
    top5[1]=t[1];
    top5[2]=t[2];
    top5[3]=t[3];
    top5[4]=t[4];
    return;
}

void writeData(float *output,  char synsetWords[1000][100], Mat & frame, float fps)
{
	int top5[5];
	top(output, top5);
	
	copyMakeBorder(frame, frame, 0, 0, 400, 0, BORDER_CONSTANT, CV_RGB(0,0,0));
	char strbuf[50];
	sprintf (strbuf, "%.2f FPS", fps);
	putText(frame, strbuf, cvPoint(30,30), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(220,220,220), 1);
	sprintf(strbuf, "%4.1f%% %s", output[top5[0]]*100, synsetWords[top5[0]]);
	putText(frame, strbuf, cvPoint(30,80), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(220,220,220), 1);
	sprintf(strbuf, "%4.1f%% %s", output[top5[1]]*100, synsetWords[top5[1]]);
	putText(frame, strbuf, cvPoint(30,130), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(220,220,220), 1);
	sprintf(strbuf, "%4.1f%% %s", output[top5[2]]*100, synsetWords[top5[2]]);
	putText(frame, strbuf, cvPoint(30,180), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(220,220,220), 1);
	sprintf(strbuf, "%4.1f%% %s", output[top5[3]]*100, synsetWords[top5[3]]);
	putText(frame, strbuf, cvPoint(30,230), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(220,220,220), 1);
	sprintf(strbuf, "%4.1f%% %s", output[top5[4]]*100, synsetWords[top5[4]]);
	putText(frame, strbuf, cvPoint(30,280), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(220,220,220), 1);
	
	imshow("Alexnet Demo", frame);
}

int prepareSynset(char synsets[1000][100])
{
    FILE* fp1 = fopen("synsetWords.txt", "r");
	if (fp1 == 0) return -1;
    for(int i=0; i<1000; i++)
    {
        fgets(synsets[i], 100, fp1);
        strtok(synsets[i], "\n");
    }
    fclose(fp1);
	return 0;
}

// Main function
int main(int argc, char* argv[])
{
    int n = 1;	
    if (argc > 1) {
        n = atoi(argv[1]);
    }

    float *inputBuffer = (float*)calloc(sizeof(float),227*227*3);
    float *outputBuffer = (float*)calloc(sizeof(float),1000);
    if ((inputBuffer == NULL) || (outputBuffer == NULL)) {
        printf("ERROR: Input/Output buffers could not be allocated!\n");
        exit(-1);
    }	

    char synsetWords[1000][100];
	if (prepareSynset(synsetWords) == -1)
	{
		printf("ERROR: Unable to find synsetWords.txt\n");
		return -1;
	}       
    
    VideoCapture cap(n); //use device number for camera. 
    if (!cap.isOpened()) {
        printf("Could not open the video capture device.\n");
        return -1;
    }
    namedWindow("Alexnet Demo",CV_WINDOW_NORMAL);
	resizeWindow("Alexnet Demo", 1000,1000);
		
    float fps=0;	
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);		
	    	
    for (;;)
    {  
        Mat orig;
		
        cap >> orig; 

		if (orig.empty()) break;
	
        Mat im;
        readData(inputBuffer, orig, im);        
        
        cudaEventRecord(start);
        alexnet_predict(inputBuffer, outputBuffer);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float milliseconds = -1.0;
        cudaEventElapsedTime(&milliseconds, start, stop);
        fps = fps*.9+1000.0/milliseconds*.1;
		
        writeData(outputBuffer, synsetWords, orig, fps);
		if(waitKey(1)%256 == 27 ) break; // stop when ESC key is pressed
    }
    destroyWindow("Alexnet Demo");

    free(inputBuffer);
    free(outputBuffer);
        
    return 0;
}

