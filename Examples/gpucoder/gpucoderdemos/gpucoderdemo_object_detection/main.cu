/* Copyright 2016-2017 The MathWorks, Inc. */

#include "cnn_exec.hpp"

#include <stdio.h>
#include <cuda.h>
#include "opencv2/opencv.hpp"
#include <opencv2/objdetect/objdetect.hpp>
#include <list>
#include <map>
#include <vector>
#include <cmath>

#define THRESH 0.15

using namespace cv;

typedef struct {
    float x;
    float y;
    float w;
    float h;    
} boxtype;

typedef struct {
    int classid; // class id
    boxtype box; // bounding box coordinates
    float prob;  // class probability
} outputType;

outputType result;

const char *voc_names[] = {"aeroplane", "bicycle", "bird", "boat", "bottle", "bus", "car", "cat", "chair", "cow", 
                           "diningtable", "dog", "horse", "motorbike", "person", "pottedplant", "sheep", "sofa", "train", "tvmonitor"};
  
// initialize output windows for each frame						   
std::map<int, std::vector<Rect> > getAllClassWindows(std::map<int, std::vector<Rect> > & newW)
{
    static std::vector<std::map<int, std::vector<Rect> > > gClassWindows;    
	// reuse windows from last 3 frames to minimize jitter in the output
    if (gClassWindows.size() > 3)
    {
        int numToErase = gClassWindows.size() - 3;
        gClassWindows.erase(gClassWindows.begin(), gClassWindows.begin()+numToErase);
    }
    gClassWindows.push_back(newW);
    
    std::map<int, std::vector<Rect> > newMap;
    for( std::vector<std::map<int, std::vector<Rect> > >::iterator it = gClassWindows.begin();
         it != gClassWindows.end(); ++it)
    {
        newMap.insert(it->begin(), it->end());    
    }
       
    return newMap;
}

void addWindow(Rect & r1, std::vector<Rect> & windows)
{
    for(int i = 0; i < windows.size(); i++)
    {
        Rect window = windows[i];
        Rect common = r1 | window;
        if (common == window)
        { 
            //  r1 is contained in window
            return;
        }
        else if (common == r1)
        {
            // r1 contains window
            windows[i] = r1;
            return;
        }
    }
    // no overlap found , append r1
    windows.push_back(r1);
}

std::vector<Rect> groupWindows(std::vector<Rect> & windows)
{
    std::vector<Rect> grouped = windows;
    groupRectangles(grouped, 1, .4);

    std::vector<Rect> newWindows = grouped;
    for(int i = 0; i < windows.size(); i++)
    {
        bool windowFound = false;
        for(int j = 0; j < grouped.size(); j++)
        {
            if ((windows[i] & grouped[j]).area() > 0)
            {
                // window captured;          
                windowFound = true;
                break;
            }
        }
        if (!windowFound)
        {           
            newWindows.push_back(windows[i]);
        }
    }
    return newWindows;
}

void drawIm(Mat & im, std::list<outputType> & results, float fps)
{
    // group bounding box by class id
    std::map<int, std::vector<Rect> > classWindows;
    for(std::list<outputType>::iterator it = results.begin(); it != results.end(); ++it)
    {
        if (it->prob >  THRESH)
        {
            boxtype box = it->box;
            cv::Rect rect(box.x, box.y, box.w, box.h);
            std::map<int, std::vector<Rect> >::iterator existing = classWindows.find(it->classid);
            if (existing == classWindows.end())
            {
                classWindows[it->classid].push_back(rect);
            }
            else
            {
                std::vector<Rect> & windows = existing->second;
                addWindow(rect, windows);            
            }
        }
    }

    classWindows = getAllClassWindows(classWindows);
    
    for (std::map<int, std::vector<Rect> >::iterator it = classWindows.begin();
         it != classWindows.end(); ++it)
    {
        int classid = it->first;
        std::vector<Rect> windows = it->second;
        std::vector<Rect> grouped  = groupWindows(it->second);
        for (int i = 0; i < grouped.size(); i++)
        {
            Rect rect = grouped[i];
            float width = rect.width;
            float height = rect.height;
            Point2f start = rect.tl();
            float wratio = (float)im.size().width/448.0;
            float hratio = (float)im.size().height/448.0;
            
            float newwidth = width*wratio;
            float newheight = height*hratio;
            float newstartx = start.x*wratio;
            float newstarty = start.y*hratio;
            Rect newrect = Rect(newstartx,
                                newstarty,
                                newwidth,
                                newheight);
            rectangle(im, newrect, CV_RGB(255,255,0), 2, CV_AA);
            Point2f orig =  newrect.tl();

            int baseline=0;
            float thickness = 1;            
            Size tsize = getTextSize( voc_names[classid], CV_FONT_HERSHEY_DUPLEX, .5, 1,&baseline);
            //baseline += thickness;
      
            Point2f textOrg(orig.x+1,orig.y+4);
            rectangle(im, textOrg + Point2f(0,baseline), textOrg + Point2f(tsize.width, -tsize.height),
                      CV_RGB(255,255,0), CV_FILLED, CV_AA);       
            
            putText(im, voc_names[classid], textOrg,
                    CV_FONT_HERSHEY_DUPLEX, .5,CV_RGB(0,0,0),1,CV_AA);

        }
    }

    char strbuf[50];
    sprintf (strbuf, "%.2f FPS", fps);
    putText(im, strbuf, cvPoint(200,30), CV_FONT_HERSHEY_DUPLEX, 1.0, CV_RGB(0,0,0), 2);   
}

// in YOLO, the prediction vector is side * side * (B * 5 + C) tensor
//  where side * side = number of grid cells  = 7 * 7
//  Each grid cell predicts :
//  1. B = 2 bounding box
//     Each bounding box prediction consists of x,y, w, h,confidence
//  2. Conditional class probabilities i.e. probability of class ,
//     conditioned on the grid cell containing an object. 

//  Prediction vector is formatted as :
//  1. side*side entries of numClass probabilities i.e. probability of each class
//     conditioned on the grid cell containing an object.
//  2. side*side entries of numBox confidences
//  3. side*side entries of numBoxes * bounding box prediction vector (x, y, w, h)

// classes = 20, num = 2, sqrt = 1, side = 7,  h, w=448, thresh = .2, only_objectness = 0
void get_detection_boxes(float* predictions, int classes, int num, double side, int w,
                         int h, std::list<outputType> & results)
{
  int i,j,n;
  float bx, by, bw, bh;
  
  for (i = 0; i < side*side; ++i){
    int row = i / side;
    int col = i % (int)side;
    for(n = 0; n < num; ++n){
      int index = i*num + n;
      int p_index = side*side*classes + i*num + n;
      float scale = predictions[p_index];
      int box_index = side*side*(classes + num) + (i*num + n)*4;
      bx = (predictions[box_index + 0] + col) / side;
      by = (predictions[box_index + 1] + row) / side;
      bw = pow(predictions[box_index + 2], 2);
      bh = pow(predictions[box_index + 3], 2);    
      int class_index = i*classes;
      for(j = 0; j < classes; ++j){
          float prob = scale*predictions[class_index+j];
          if (prob > THRESH)
          {
              boxtype box;
              box.x = (bx - bw/2)*w;
              box.y = (by - bh/2)*h;
              box.w = bw*w;
              box.h = bh*h;
                  
              outputType result;
              result.classid = j;
              result.box = box;
              result.prob = prob;

              results.push_back(result);
          }
      }
    }
  }
}

void readData(float *input, Mat& orig, Mat & im)
{
    Size size(448,448);
    resize(orig,im,size);
    for(int j=0;j<448*448;j++)
    {
        //BGR to RGB
        input[2*448*448+j]=(float)(im.data[j*3+0])/255.0;
        input[1*448*448+j]=(float)(im.data[j*3+1])/255.0;
        input[0*448*448+j]=(float)(im.data[j*3+2])/255.0;
    }	
}

void writeData(float *outputBuffer, Mat & im, float fps)
{
    /* DATA OUTPUT CODE
     *   The code inserted here should read from the pre-allocated
     *   buffer 'outputBuffer'. This is the data that will be produced
     *   by one iteration of the neural network.
     */	
    // convert predictions to box, prob and class id    
    int classes = 20;
    int num = 2;
    int side = 7;
    int h = 448;
    int w = 448;
    std::list<outputType> results;
    get_detection_boxes(outputBuffer, classes, num, side, w,h, results);

    drawIm(im, results, fps);
}

// Main function
int main(int argc, char* argv[])
{    
			
    float *inputBuffer = (float*)calloc(sizeof(float),448*448*3);
    float *outputBuffer = (float*)calloc(sizeof(float),1470);

    if ((inputBuffer == NULL) || (outputBuffer == NULL)) {
        printf("ERROR: Input/Output buffers could not be allocated!\n");
        exit(-1);
    }
    
    CnnMain* net = new CnnMain;

    net->batchSize = 1;
    net->setup();

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

    namedWindow("Yolo Demo",CV_WINDOW_NORMAL);
    cvMoveWindow("Yolo Demo", 0, 0);
    resizeWindow("Yolo Demo", 1352,1013);    
	   
    float fps = 0;
	
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);        
    
    for(;;)
    {      
        
        Mat orig;
        cap >> orig;
        if (orig.empty()) break;
	   
        Mat im;
        readData(inputBuffer, orig, im);
			
        cudaEventRecord(start);
        cudaMemcpy(net->inputData, 
                   inputBuffer, 
                   sizeof(float)*448*448*3, 
                   cudaMemcpyHostToDevice);
        net->predict();

        cudaMemcpy(outputBuffer,
                   net->layers[55]->getData(),
                   sizeof(float)*1470,
                   cudaMemcpyDeviceToHost);
		
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
		
        float milliseconds = -1.0; 
        cudaEventElapsedTime(&milliseconds, start, stop);
        fps = fps*.9+1000.0/milliseconds*.1;	

        Mat resized;
        resize(orig, resized, Size(1352,1013));
   
		writeData(outputBuffer, resized, fps);
        imshow("Yolo Demo", resized);
        if( waitKey(50)%256 == 27 ) break; // stop capturing by pressing ESC
    }
    destroyWindow("Yolo Demo");
    
    delete net;
    
    free(inputBuffer);
    free(outputBuffer);
        
    return 0;
}
