/* Copyright 2012 The MathWorks, Inc. */

#ifndef _CASCADECLASSIFIER_
#define _CASCADECLASSIFIER_

#include "vision_defines.h"

EXTERN_C LIBMWCVSTRT_API int32_T cascadeClassifier_detectMultiScale(void *ptrClass, void **ptr2ptrDetectedObj, 
	uint8_T *inImg, int32_T nRows, int32_T nCols, 
	double scaleFactor, uint32_T minNeighbors, 
    int32_T *ptrMinSize, int32_T *ptrMaxSize);

EXTERN_C LIBMWCVSTRT_API void cascadeClassifier_load(void *ptrClass, const char * filename);
EXTERN_C LIBMWCVSTRT_API void cascadeClassifier_getClassifierInfo(void *ptrClass, 
	uint32_T *originalWindowSize, uint32_T *featureTypeID);
EXTERN_C LIBMWCVSTRT_API void cascadeClassifier_construct(void **ptr2ptrClass);
EXTERN_C LIBMWCVSTRT_API void cascadeClassifier_assignOutputDeleteBbox(void *ptrDetectedObj, int32_T *outBBox);
EXTERN_C LIBMWCVSTRT_API void cascadeClassifier_assignOutputDeleteBboxRM(void *ptrDetectedObj, int32_T *outBBox);
EXTERN_C LIBMWCVSTRT_API void cascadeClassifier_deleteObj(void *ptrClass);

#endif
