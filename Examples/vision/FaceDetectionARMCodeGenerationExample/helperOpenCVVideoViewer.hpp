/* Copyright 2012 The MathWorks, Inc. */

#ifndef HELPER_OPENCV_VIDEO_VIEWER
#define HELPER_OPENCV_VIDEO_VIEWER

#include "vision_defines.h"

EXTERN_C LIBMWCVSTRT_API boolean_T opencvIsEscKeyPressed(void);
EXTERN_C LIBMWCVSTRT_API void opencvInitVideoViewer(const char*winName);
EXTERN_C LIBMWCVSTRT_API void opencvDisplayRGB(uint8_T *rgbU8, int frameHeight, int frameWidth, const char *winName);

#endif
