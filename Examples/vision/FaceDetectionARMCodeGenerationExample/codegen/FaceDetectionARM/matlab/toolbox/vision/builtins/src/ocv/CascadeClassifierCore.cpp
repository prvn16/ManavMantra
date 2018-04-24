//////////////////////////////////////////////////////////////////////////////
// OpenCV CascadeClassifier wrapper 
//
// Copyright 2013 The MathWorks, Inc.
//  
//////////////////////////////////////////////////////////////////////////////

#ifndef COMPILE_FOR_VISION_BUILTINS

#include "CascadeClassifierCore_api.hpp"
#include "mwobjdetect.hpp" 
#include "opencv2/opencv.hpp"
#include "cgCommon.hpp"
#include <stdio.h>

#define PLATFORM_DIRECTORY_SEPARATOR_BS '\\'   /* only on windows */
#define PLATFORM_DIRECTORY_SEPARATOR_FS '/'    /* win and *ux */

using namespace cv;
using namespace std;

//////////////////////////////////////////////////////////////////////////////
// Invoke OpenCV cvcascadeClassifier
//////////////////////////////////////////////////////////////////////////////

int32_T cascadeClassifier_detectMultiScale(void *ptrClass, void **ptr2ptrDetectedObj, 
    uint8_T *inImg, int32_T nRows, int32_T nCols, 
    double scaleFactor, uint32_T minNeighbors, 
    int32_T *ptrMinSize, int32_T *ptrMaxSize)
{
    cv::Mat img = cv::Mat(nRows, (int)nCols, CV_8UC1, inImg);

    cv::Size minSize      = cv::Size((int)ptrMinSize[1], (int)ptrMinSize[0]);
    cv::Size maxSize      = cv::Size((int)ptrMaxSize[1], (int)ptrMaxSize[0]);

    std::vector<cv::Rect> *ptrDetectedObj = (std::vector<cv::Rect> *)new std::vector<cv::Rect>();
    *ptr2ptrDetectedObj = ptrDetectedObj;
    std::vector<cv::Rect> &refDetectedObj = *ptrDetectedObj;

    //
    int32_T flags(2);

    // call OpenCV Classifiercascade::detectMultiScale      
    cv::MWCascadeClassifier *ptrClass_ = (cv::MWCascadeClassifier *)ptrClass;
    ptrClass_->detectMultiScale(img, refDetectedObj, scaleFactor, 
        minNeighbors, flags, minSize, maxSize);

    return  ((int32_T)(refDetectedObj.size())); 
}

std::string
filenameNoPath( std::string const& pathname )
{
	std::string::size_type lastSeparatorPos;
	std::string::size_type filename_begin;
	std::string::size_type filename_length;

	std::string::size_type lastSeparatorPos_BS = pathname.find_last_of(PLATFORM_DIRECTORY_SEPARATOR_BS);
	std::string::size_type lastSeparatorPos_FS = pathname.find_last_of(PLATFORM_DIRECTORY_SEPARATOR_FS);
	
	if ((lastSeparatorPos_BS == std::string::npos) &&
		(lastSeparatorPos_FS == std::string::npos) ){
		return pathname;
	}	
	
	if (lastSeparatorPos_BS == std::string::npos) { //npos = max int
		lastSeparatorPos = lastSeparatorPos_FS;
	}
	else if (lastSeparatorPos_FS == std::string::npos) {//npos = max int
		lastSeparatorPos = lastSeparatorPos_BS;
	}
	else {
		lastSeparatorPos = std::max(lastSeparatorPos_BS, lastSeparatorPos_FS);
	}

	filename_begin = lastSeparatorPos + 1;

	filename_length = pathname.length();
	if (filename_length != std::string::npos)
		filename_length = filename_length - filename_begin;

	std::string result = pathname.substr(filename_begin, filename_length);

	return result;
}

bool file_exists(const char * filename)
{
	// checking if we can open file with read access.
    if (FILE * file = fopen(filename, "r")) 
    {
        fclose(file);
        return true;
    }
    return false;
}

void cascadeClassifier_load(void *ptrClass, const char * filename)
{
	cv::MWCascadeClassifier *ptrClass_ = (cv::MWCascadeClassifier *)ptrClass;
	// check if file exists; if it does not exist, try to load from it from current directory
	if (file_exists(filename)){
		ptrClass_->load(filename);
	}
	else{
		// This code path is necessary only for packngo.
		// During codegen, it's not easy to detect from Matlab code if codegen is for packngo.
		// In packngo, we copy the xml file with all dependent dlls.
		// for flat packType, xml file and dependent dlls will be copied to 
		//                    directory where exe file lives
		// for hierarchical packType, xml file and dependent dlls will be 
		//                    with the sandbox directory structure
		// so here we try to load the file from current directory
		std::string baseFileName = filenameNoPath(filename);
		if (file_exists((const char *)baseFileName.c_str())){
			// for flat packType
			ptrClass_->load(baseFileName.c_str());
		}
		else{
			// for hierarchical packType
			std::string methodDir = (baseFileName[0] == 'h') ? "haar" : "lbp";
			std::string filenameWithPath = "matlab/toolbox/vision/visionutilities/classifierdata/cascade/" +
				methodDir + "/" + baseFileName;
			if (file_exists((const char *)filenameWithPath.c_str())){
				ptrClass_->load(filenameWithPath.c_str());
			}
		}
	}
}

void cascadeClassifier_deleteObj(void *ptrClass)
{
    delete((cv::MWCascadeClassifier *)ptrClass);    
}

void cascadeClassifier_getClassifierInfo(void *ptrClass, uint32_T *originalWindowSize, 
    uint32_T *featureTypeID)
{
    cv::MWCascadeClassifier *ptrClass_ = (cv::MWCascadeClassifier *)ptrClass;
    originalWindowSize[0] = 0;
    originalWindowSize[1] = 0;

    if (!ptrClass_->empty()) // make sure classifer model is loaded
    {
        originalWindowSize[0] = (uint32_T)(ptrClass_->getOriginalWindowSize().height);
        originalWindowSize[1] = (uint32_T)(ptrClass_->getOriginalWindowSize().width);

        switch (ptrClass_->getFeatureType())
        {
        case cv::MWFeatureEvaluator::HAAR:
            // featureType = "Haar";
            featureTypeID[0] = 1;
            break;
        case cv::MWFeatureEvaluator::LBP:
            // featureType = "Local Binary Patterns (LBP)";
            featureTypeID[0] = 2;
            break;
        case cv::MWFeatureEvaluator::HOG:            
            //featureType = "Histogram of Oriented Gradients (HOG)";            
            featureTypeID[0] = 3;
            break;
        default: 
            featureTypeID[0] = 0; // should not be here 
        }       
    }   
}

void cascadeClassifier_construct(void **ptr2ptrClass)
{
    cv::MWCascadeClassifier *ptrClass_ = (cv::MWCascadeClassifier *)new MWCascadeClassifier();
    *ptr2ptrClass = ptrClass_;
}

void cascadeClassifier_assignOutputDeleteBbox(void *ptrDetectedObj, int32_T *outBBox)
{
    std::vector<cv::Rect> detectedObj = ((std::vector<cv::Rect> *)ptrDetectedObj)[0];

    cvRectToBoundingBox(detectedObj, outBBox);

    delete((std::vector<cv::Rect> *)ptrDetectedObj);
}

void cascadeClassifier_assignOutputDeleteBboxRM(void *ptrDetectedObj, int32_T *outBBox)
{
	std::vector<cv::Rect> detectedObj = ((std::vector<cv::Rect> *)ptrDetectedObj)[0];
	
	cvRectToBoundingBoxRowMajor(detectedObj, outBBox);

	delete((std::vector<cv::Rect> *)ptrDetectedObj);
}

#endif
