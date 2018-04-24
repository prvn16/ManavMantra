/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: PointTracker.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "PointTracker.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const vision_PointTracker *obj
 *                double kltParams_BlockSize[2]
 *                double *kltParams_NumPyramidLevels
 *                double *kltParams_MaxIterations
 *                double *kltParams_Epsilon
 *                double *kltParams_MaxBidirectionalError
 * Return Type  : void
 */
void PointTracker_getKLTParams(const vision_PointTracker *obj, double
  kltParams_BlockSize[2], double *kltParams_NumPyramidLevels, double
  *kltParams_MaxIterations, double *kltParams_Epsilon, double
  *kltParams_MaxBidirectionalError)
{
  int i23;
  double varargin_1[2];
  double topOfPyramid;
  int eint;
  for (i23 = 0; i23 < 2; i23++) {
    kltParams_BlockSize[i23] = 31.0;
    varargin_1[i23] = obj->FrameSize[i23];
  }

  if ((varargin_1[0] > varargin_1[1]) || (rtIsNaN(varargin_1[0]) && (!rtIsNaN
        (varargin_1[1])))) {
    topOfPyramid = varargin_1[1];
  } else {
    topOfPyramid = varargin_1[0];
  }

  if (topOfPyramid == 0.0) {
    topOfPyramid = rtMinusInf;
  } else if (topOfPyramid < 0.0) {
    topOfPyramid = rtNaN;
  } else {
    if ((!rtIsInf(topOfPyramid)) && (!rtIsNaN(topOfPyramid))) {
      topOfPyramid = frexp(topOfPyramid, &eint);
      if (topOfPyramid == 0.5) {
        topOfPyramid = (double)eint - 1.0;
      } else if ((eint == 1) && (topOfPyramid < 0.75)) {
        topOfPyramid = log(2.0 * topOfPyramid) / 0.69314718055994529;
      } else {
        topOfPyramid = log(topOfPyramid) / 0.69314718055994529 + (double)eint;
      }
    }
  }

  topOfPyramid = floor(topOfPyramid - 2.0);
  if (!(topOfPyramid < 3.0)) {
    topOfPyramid = 3.0;
  }

  if (0.0 > topOfPyramid) {
    *kltParams_NumPyramidLevels = 0.0;
  } else {
    *kltParams_NumPyramidLevels = (int)topOfPyramid;
  }

  *kltParams_MaxIterations = 30.0;
  *kltParams_Epsilon = 0.01;
  *kltParams_MaxBidirectionalError = 2.0;
}

/*
 * File trailer for PointTracker.c
 *
 * [EOF]
 */
