/* Copyright 2012 The MathWorks, Inc. */

#ifndef HELPER_OPENCV_WEBCAM
#define HELPER_OPENCV_WEBCAM

#include "vision_defines.h"

EXTERN_C LIBMWCVSTRT_API void* opencvInitCam(const int frameW, const int frameH);
EXTERN_C LIBMWCVSTRT_API void opencvCaptureRGBFrameAndCopy(void *captureV, uint8_T *rgbU8);

#endif
