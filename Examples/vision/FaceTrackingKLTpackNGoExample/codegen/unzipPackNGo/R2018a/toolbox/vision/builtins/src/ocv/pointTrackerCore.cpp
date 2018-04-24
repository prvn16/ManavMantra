//////////////////////////////////////////////////////////////////////////////
// OpenCV PointTracker wrapper 
//
// Copyright 2010 The MathWorks, Inc.
//  
//////////////////////////////////////////////////////////////////////////////

#include "pointTrackerCore_api.hpp"

#include "PointTrackerParams.hpp"
#include "PointBuffers.hpp"
#include "ImageBuffers.hpp"
#include "PointTrackerOcv.hpp"

#include "opencv2/opencv.hpp"
#include "cgCommon.hpp"

using namespace cv;
using namespace std;
using namespace pointTracker;

///////////////////////////////////////////////////////////////////////////////
void getPoints(void *ptrClass, float *pointData)
{
    pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;

    mwSize pointDims[2];
    int numPoints = ptrClass_->getNumPoints();
    pointDims[0] = numPoints;
    pointDims[1] = 2;

    const std::vector<PointBuffers::Point> &cvPoints = 
        ptrClass_->getPoints();

    for(int i = 0; i < numPoints; ++i)
    {
        // convert to 1-based MATLAB coordinates
        pointData[i] = cvPoints[i].x + 1;
        pointData[i+numPoints] = cvPoints[i].y + 1;
    }
}

void getPointsRM(void *ptrClass, float *pointData)
{
	pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;

	mwSize pointDims[2];
	int numPoints = ptrClass_->getNumPoints();
	pointDims[0] = numPoints;
	pointDims[1] = 2;

	const std::vector<PointBuffers::Point> &cvPoints =
		ptrClass_->getPoints();

	int k = 0; 
	for (int i = 0; i < numPoints; ++i)
	{
		// convert to 1-based MATLAB coordinates
		pointData[k++] = cvPoints[i].x + 1;
		pointData[k++] = cvPoints[i].y + 1;
	}
}

///////////////////////////////////////////////////////////////////////////////
void getValidity(void *ptrClass, boolean_T *logicalData)
{
    pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
    int numPoints = ptrClass_->getNumPoints();

    const std::vector<uchar> &status = ptrClass_->getStatus();
    for(mwSize i = 0; i < (mwSize)numPoints; ++i)
    {
        logicalData[i] = (status[i] != 0);
    }
}

///////////////////////////////////////////////////////////////////////////////
void getScores(void *ptrClass, double *errorsData)
{
    pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
    const std::vector<float> &cvErrors = ptrClass_->getErr();
    std::copy(cvErrors.begin(), cvErrors.end(), errorsData);
}

cv::TermCriteria getTerminationCriteria(const double maxIterations, const double epsilon)
{
    return
        cv::TermCriteria(cv::TermCriteria::COUNT + cv::TermCriteria::EPS, 
        (int)maxIterations, epsilon);
}

///////////////////////////////////////////////////////////////////////////////
double getMaxBidirectionalErrorSq(const double maxBidirectionalError)
{
    double maxBidirectionalErrorSq = -1.0;
    if(maxBidirectionalError >= 0.0)
    {
        maxBidirectionalErrorSq = 
            maxBidirectionalError * maxBidirectionalError;
    }
    return maxBidirectionalErrorSq;
}

//////////////////////////////////////////////////////////////////////////////
// Invoke OpenCV Functions
//////////////////////////////////////////////////////////////////////////////
const pointTracker::PointTrackerParams PointTrackerParams_build(const cvstPTStruct_T *params)
{
    cv::Size blockSize = cv::Size(params->blockSize[0], params->blockSize[1]);
    cv::TermCriteria terminationCriteria = getTerminationCriteria(params->maxIterations, params->epsilon);

    double maxBidirectionalErrorSq = getMaxBidirectionalErrorSq(params->maxBidirectionalError);

    return pointTracker::PointTrackerParams(blockSize, params->numPyramidLevels, terminationCriteria,
        maxBidirectionalErrorSq);
}

void pointTracker_construct(void **ptr2ptrClass)
{
    pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)new PointTrackerOcv();
    *ptr2ptrClass = ptrClass_;
}

void pointTracker_initialize(void *ptrClass, 
    uint8_T *inImg, const int nRows, const int nCols,
    const float *pointData, const int numPoints,
    cvstPTStruct_T *paramsIn)
{
    pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
    pointTracker::PointTrackerParams params = PointTrackerParams_build(paramsIn);

    cv::Mat img = cv::Mat(nRows, (int)nCols, CV_8UC1, inImg);
    // transpose matrix
    // https://code.ros.org/trac/opencv/ticket/1090
    // cv::transpose(img, img);

    ptrClass_->initialize(params, img, numPoints, pointData);
}

void pointTracker_initializeRM(void *ptrClass,
	uint8_T *inImg, const int nRows, const int nCols,
	const float *pointData, const int numPoints,
	cvstPTStruct_T *paramsIn)
{
	pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
	pointTracker::PointTrackerParams params = PointTrackerParams_build(paramsIn);

	cv::Mat img = cv::Mat(nRows, (int)nCols, CV_8UC1, inImg);
	// transpose matrix
	// https://code.ros.org/trac/opencv/ticket/1090
	// cv::transpose(img, img);

	ptrClass_->initializeRM(params, img, numPoints, pointData);
}

void pointTracker_setPoints(void *ptrClass, const float *pointData, int numPoints,
    boolean_T *validityData)
{
    pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
    ptrClass_->setPoints(numPoints, pointData, validityData);
}


void pointTracker_setPointsRM(void *ptrClass, const float *pointData, int numPoints,
	boolean_T *validityData)
{
	pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
	ptrClass_->setPointsRM(numPoints, pointData, validityData);
}

///////////////////////////////////////////////////////////////////////////////
void pointTracker_step(void *ptrClass, uint8_T *inImg, 
    int32_T nRows, int32_T nCols,
    float *outPoints, boolean_T *outValidity, double *outScores)
{
    pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
    cv::Mat frame = cv::Mat(nRows, (int)nCols, CV_8UC1, inImg);

    ptrClass_->step(frame);

    getPoints(ptrClass, outPoints);
    getValidity(ptrClass, outValidity);
    getScores(ptrClass, outScores);
}

void pointTracker_stepRM(void *ptrClass, uint8_T *inImg,
	int32_T nRows, int32_T nCols,
	float *outPoints, boolean_T *outValidity, double *outScores)
{
	pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
	cv::Mat frame = cv::Mat(nRows, (int)nCols, CV_8UC1, inImg);

	ptrClass_->step(frame);

	getPointsRM(ptrClass, outPoints);
	getValidity(ptrClass, outValidity);
	getScores(ptrClass, outScores);
}

///////////////////////////////////////////////////////////////////////////////
void pointTracker_getPreviousFrame(void *ptrClass, uint8_T *outFrame)
{
    pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
    cArrayFromMat<uint8_T>(outFrame, ptrClass_->getPreviousFrame());

}

void pointTracker_getPreviousFrameRM(void *ptrClass, uint8_T *outFrame)
{
	pointTracker::PointTrackerOcv *ptrClass_ = (pointTracker::PointTrackerOcv *)ptrClass;
	cArrayFromMat_RowMaj<uint8_T>(outFrame, ptrClass_->getPreviousFrame());

}

///////////////////////////////////////////////////////////////////////////////
void pointTracker_getPointsAndValidity(void *ptrClass, float *outPoints, boolean_T *outValidity)
{
    getPoints(ptrClass, outPoints);
    getValidity(ptrClass, outValidity);
}

void pointTracker_getPointsAndValidityRM(void *ptrClass, float *outPoints, boolean_T *outValidity)
{
	getPointsRM(ptrClass, outPoints);
	getValidity(ptrClass, outValidity);
}

///////////////////////////////////////////////////////////////////////////////
void pointTracker_deleteObj(void *ptrClass)
{
    delete((pointTracker::PointTrackerOcv *)ptrClass);    
}