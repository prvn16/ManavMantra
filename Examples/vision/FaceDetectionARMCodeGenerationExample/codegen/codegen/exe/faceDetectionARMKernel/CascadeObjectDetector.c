/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: CascadeObjectDetector.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceDetectionARMKernel.h"
#include "CascadeObjectDetector.h"
#include "CascadeClassifierCore_api.hpp"

/* Function Definitions */

/*
 * Arguments    : const vision_CascadeObjectDetector *obj
 * Return Type  : void
 */
void c_CascadeObjectDetector_validat(const vision_CascadeObjectDetector *obj)
{
  void * ptrObj;
  int k;
  unsigned int unusedU0;
  unsigned int originalWindowSize[2];
  boolean_T y;
  boolean_T x[2];
  boolean_T exitg1;
  ptrObj = obj->pCascadeClassifier;
  for (k = 0; k < 2; k++) {
    originalWindowSize[k] = 0U;
  }

  unusedU0 = 0U;
  cascadeClassifier_getClassifierInfo(ptrObj, originalWindowSize, &unusedU0);
  for (k = 0; k < 2; k++) {
    x[k] = (obj->MinSize[k] < originalWindowSize[k]);
  }

  y = false;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (x[k]) {
      y = true;
      exitg1 = true;
    } else {
      k++;
    }
  }

  if (y) {
    ptrObj = obj->pCascadeClassifier;
    for (k = 0; k < 2; k++) {
      originalWindowSize[k] = 0U;
    }

    unusedU0 = 0U;
    cascadeClassifier_getClassifierInfo(ptrObj, originalWindowSize, &unusedU0);
    ptrObj = obj->pCascadeClassifier;
    for (k = 0; k < 2; k++) {
      originalWindowSize[k] = 0U;
    }

    unusedU0 = 0U;
    cascadeClassifier_getClassifierInfo(ptrObj, originalWindowSize, &unusedU0);
  }
}

/*
 * File trailer for CascadeObjectDetector.c
 *
 * [EOF]
 */
