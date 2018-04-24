/* Copyright 2012 The MathWorks, Inc. */

#ifndef _POINTTRACKER_
#define _POINTTRACKER_

#include "vision_defines.h"

#ifndef typedef_cvstPTStruct_T
#define typedef_cvstPTStruct_T

 typedef struct {
   int32_T blockSize[2];
   int numPyramidLevels;
   double maxIterations;
   double epsilon;
   double maxBidirectionalError;
} cvstPTStruct_T;

#endif /*typedef_cvstPTStruct_T: used by matlab coder*/

EXTERN_C LIBMWCVSTRT_API void pointTracker_construct(void **ptr2ptrClass);
EXTERN_C LIBMWCVSTRT_API void pointTracker_initialize(void *ptrClass, 
	uint8_T *inImg, const int nRows, const int nCols,
	const float *pointData, const int numPoints,
	cvstPTStruct_T *params);
EXTERN_C LIBMWCVSTRT_API void pointTracker_initializeRM(void *ptrClass,
	uint8_T *inImg, const int nRows, const int nCols,
	const float *pointData, const int numPoints,
	cvstPTStruct_T *params);
EXTERN_C LIBMWCVSTRT_API void pointTracker_setPoints(void *ptrClass, const float *pointData, int numPoints, boolean_T *validityData);
EXTERN_C LIBMWCVSTRT_API void pointTracker_setPointsRM(void *ptrClass, const float *pointData, int numPoints, boolean_T *validityData);
EXTERN_C LIBMWCVSTRT_API void pointTracker_step(void *ptrClass, uint8_T *inImg, 
	int32_T nRows, int32_T nCols,
	float *outPoints, boolean_T *outValidity, double *outScores);
EXTERN_C LIBMWCVSTRT_API void pointTracker_stepRM(void *ptrClass, uint8_T *inImg,
	int32_T nRows, int32_T nCols,
	float *outPoints, boolean_T *outValidity, double *outScores);
EXTERN_C LIBMWCVSTRT_API void pointTracker_getPreviousFrame(void *ptrClass, uint8_T *outFrame);
EXTERN_C LIBMWCVSTRT_API void pointTracker_getPreviousFrameRM(void *ptrClass, uint8_T *outFrame);

EXTERN_C LIBMWCVSTRT_API void pointTracker_getPointsAndValidity(void *ptrClass, float *outPoints, boolean_T *outValidity);
EXTERN_C LIBMWCVSTRT_API void pointTracker_getPointsAndValidityRM(void *ptrClass, float *outPoints, boolean_T *outValidity);

EXTERN_C LIBMWCVSTRT_API void pointTracker_deleteObj(void *ptrClass);

#endif
