/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: CascadeObjectDetector.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "CascadeObjectDetector.h"
#include "CascadeClassifierCore_api.hpp"

/* Function Declarations */
static void d_CascadeObjectDetector_Cascade(vision_CascadeObjectDetector **obj);

/* Function Definitions */

/*
 * Arguments    : vision_CascadeObjectDetector **obj
 * Return Type  : void
 */
static void d_CascadeObjectDetector_Cascade(vision_CascadeObjectDetector **obj)
{
  void * ptrObj;
  char ClassificationModel[123];
  static const char b_ClassificationModel[123] = { 'C', ':', '\\', 'P', 'r', 'o',
    'g', 'r', 'a', 'm', ' ', 'F', 'i', 'l', 'e', 's', '\\', 'M', 'A', 'T', 'L',
    'A', 'B', '\\', 'R', '2', '0', '1', '8', 'a', '\\', 't', 'o', 'o', 'l', 'b',
    'o', 'x', '\\', 'v', 'i', 's', 'i', 'o', 'n', '\\', 'v', 'i', 's', 'i', 'o',
    'n', 'u', 't', 'i', 'l', 'i', 't', 'i', 'e', 's', '\\', 'c', 'l', 'a', 's',
    's', 'i', 'f', 'i', 'e', 'r', 'd', 'a', 't', 'a', '\\', 'c', 'a', 's', 'c',
    'a', 'd', 'e', '\\', 'h', 'a', 'a', 'r', '\\', 'h', 'a', 'a', 'r', 'c', 'a',
    's', 'c', 'a', 'd', 'e', '_', 'f', 'r', 'o', 'n', 't', 'a', 'l', 'f', 'a',
    'c', 'e', '_', 'a', 'l', 't', '2', '.', 'x', 'm', 'l', '\x00' };

  (*obj)->ScaleFactor = 1.1;
  (*obj)->MergeThreshold = 4.0;
  (*obj)->isInitialized = 0;
  ptrObj = NULL;
  cascadeClassifier_construct(&ptrObj);
  (*obj)->pCascadeClassifier = ptrObj;
  ptrObj = (*obj)->pCascadeClassifier;
  memcpy(&ClassificationModel[0], &b_ClassificationModel[0], 123U * sizeof(char));
  cascadeClassifier_load(ptrObj, ClassificationModel);
  (*obj)->matlabCodegenIsDeleted = false;
}

/*
 * Arguments    : vision_CascadeObjectDetector *obj
 * Return Type  : vision_CascadeObjectDetector *
 */
vision_CascadeObjectDetector *c_CascadeObjectDetector_Cascade
  (vision_CascadeObjectDetector *obj)
{
  vision_CascadeObjectDetector *b_obj;
  b_obj = obj;
  d_CascadeObjectDetector_Cascade(&b_obj);
  return b_obj;
}

/*
 * File trailer for CascadeObjectDetector.c
 *
 * [EOF]
 */
