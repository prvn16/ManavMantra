/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: faceDetectionARMKernel.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

/* Include Files */
#include <math.h>
#include <string.h>
#include "rt_nonfinite.h"
#include "faceDetectionARMKernel.h"
#include "SystemCore.h"
#include "insertShape.h"
#include "faceDetectionARMKernel_emxutil.h"
#include "CascadeObjectDetector.h"
#include "CascadeClassifierCore_api.hpp"

/* Variable Definitions */
static vision_CascadeObjectDetector faceDetector;
static boolean_T faceDetector_not_empty;

/* Function Declarations */
static double rt_roundd_snf(double u);

/* Function Definitions */

/*
 * Arguments    : double u
 * Return Type  : double
 */
static double rt_roundd_snf(double u)
{
  double y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

/*
 * Arguments    : const unsigned char inRGB[921600]
 *                unsigned char outRGB[921600]
 * Return Type  : void
 */
void faceDetectionARMKernel(const unsigned char inRGB[921600], unsigned char
  outRGB[921600])
{
  vision_CascadeObjectDetector *obj;
  int num_bboxes;
  emxArray_int32_T *varargout_1;
  unsigned char b_inRGB[3];
  void * ptrObj;
  double d0;
  int ibmat;
  boolean_T flag;
  static const double b[3] = { 0.29893602129377539, 0.58704307445112125,
    0.11402090425510336 };

  unsigned char u0;
  boolean_T exitg1;
  cell_wrap_3 varSizes[1];
  static const unsigned char inSize[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  static unsigned char inGray[307200];
  static const unsigned char uv0[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  double obj_MinSize[2];
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

  double obj_MaxSize[2];
  double ScaleFactor;
  unsigned int MergeThreshold;
  void * ptrDetectedObj;
  emxArray_int32_T *bboxes_;
  unsigned char b_inGray[34240];
  int MinSize_[2];
  int MaxSize_[2];
  int loop_ub;
  int positionOut_size[2];
  float f0;
  int color_size[2];
  int positionOut_data[36];
  visioncodegen_ShapeInserter *h_ShapeInserter;
  int itilerow;
  unsigned char color_data[27];
  static const unsigned char uv1[3] = { MAX_uint8_T, MAX_uint8_T, 0U };

  /*  Kernel function for 'Face Detection on ARM Target using Code Generation' example */
  /*  Instantiate system object */
  if (!faceDetector_not_empty) {
    obj = &faceDetector;
    faceDetector.ScaleFactor = 1.1;
    faceDetector.MergeThreshold = 4.0;
    faceDetector.isInitialized = 0;
    ptrObj = NULL;
    cascadeClassifier_construct(&ptrObj);
    obj->pCascadeClassifier = ptrObj;
    flag = (obj->isInitialized == 1);
    if (flag) {
      obj->TunablePropsChanged = true;
    }

    for (ibmat = 0; ibmat < 2; ibmat++) {
      obj->MinSize[ibmat] = 20.0;
    }

    flag = (obj->isInitialized == 1);
    if (flag) {
      obj->TunablePropsChanged = true;
    }

    for (ibmat = 0; ibmat < 2; ibmat++) {
      obj->MaxSize[ibmat] = 80.0 + 26.0 * (double)ibmat;
    }

    ptrObj = obj->pCascadeClassifier;
    memcpy(&ClassificationModel[0], &b_ClassificationModel[0], 123U * sizeof
           (char));
    cascadeClassifier_load(ptrObj, ClassificationModel);
    c_CascadeObjectDetector_validat(obj);
    obj->matlabCodegenIsDeleted = false;
    faceDetector_not_empty = true;
  }

  for (num_bboxes = 0; num_bboxes < 307200; num_bboxes++) {
    b_inRGB[0] = inRGB[num_bboxes];
    b_inRGB[1] = inRGB[num_bboxes + 307200];
    b_inRGB[2] = inRGB[num_bboxes + 614400];
    d0 = 0.0;
    for (ibmat = 0; ibmat < 3; ibmat++) {
      d0 += (double)b_inRGB[ibmat] * b[ibmat];
    }

    d0 = rt_roundd_snf(d0);
    if (d0 < 256.0) {
      u0 = (unsigned char)d0;
    } else {
      u0 = MAX_uint8_T;
    }

    inGray[num_bboxes] = u0;
  }

  emxInit_int32_T(&varargout_1, 2);

  /*  Create uninitialized memory in generated code */
  /*  Resize input image  */
  /*  Detect faces and create boundiong boxes around detected faces */
  obj = &faceDetector;
  if (faceDetector.isInitialized != 1) {
    faceDetector.isSetupComplete = false;
    faceDetector.isInitialized = 1;
    for (ibmat = 0; ibmat < 8; ibmat++) {
      varSizes[0].f1[ibmat] = inSize[ibmat];
    }

    faceDetector.inputVarSize[0] = varSizes[0];
    c_CascadeObjectDetector_validat(&faceDetector);
    obj->isSetupComplete = true;
    obj->TunablePropsChanged = false;
  }

  if (obj->TunablePropsChanged) {
    c_CascadeObjectDetector_validat(obj);
    obj->TunablePropsChanged = false;
  }

  num_bboxes = 0;
  exitg1 = false;
  while ((!exitg1) && (num_bboxes < 8)) {
    if (obj->inputVarSize[0].f1[num_bboxes] != uv0[num_bboxes]) {
      for (ibmat = 0; ibmat < 8; ibmat++) {
        obj->inputVarSize[0].f1[ibmat] = inSize[ibmat];
      }

      exitg1 = true;
    } else {
      num_bboxes++;
    }
  }

  for (ibmat = 0; ibmat < 2; ibmat++) {
    obj_MinSize[ibmat] = obj->MinSize[ibmat];
  }

  for (ibmat = 0; ibmat < 2; ibmat++) {
    obj_MaxSize[ibmat] = obj->MaxSize[ibmat];
  }

  ptrObj = obj->pCascadeClassifier;
  ScaleFactor = obj->ScaleFactor;
  d0 = rt_roundd_snf(obj->MergeThreshold);
  if (d0 < 4.294967296E+9) {
    if (d0 >= 0.0) {
      MergeThreshold = (unsigned int)d0;
    } else {
      MergeThreshold = 0U;
    }
  } else if (d0 >= 4.294967296E+9) {
    MergeThreshold = MAX_uint32_T;
  } else {
    MergeThreshold = 0U;
  }

  for (ibmat = 0; ibmat < 2; ibmat++) {
    d0 = rt_roundd_snf(obj_MinSize[ibmat]);
    if (d0 < 2.147483648E+9) {
      if (d0 >= -2.147483648E+9) {
        num_bboxes = (int)d0;
      } else {
        num_bboxes = MIN_int32_T;
      }
    } else if (d0 >= 2.147483648E+9) {
      num_bboxes = MAX_int32_T;
    } else {
      num_bboxes = 0;
    }

    MinSize_[ibmat] = num_bboxes;
    d0 = rt_roundd_snf(obj_MaxSize[ibmat]);
    if (d0 < 2.147483648E+9) {
      if (d0 >= -2.147483648E+9) {
        num_bboxes = (int)d0;
      } else {
        num_bboxes = MIN_int32_T;
      }
    } else if (d0 >= 2.147483648E+9) {
      num_bboxes = MAX_int32_T;
    } else {
      num_bboxes = 0;
    }

    MaxSize_[ibmat] = num_bboxes;
  }

  ptrDetectedObj = NULL;
  for (ibmat = 0; ibmat < 160; ibmat++) {
    for (num_bboxes = 0; num_bboxes < 214; num_bboxes++) {
      b_inGray[num_bboxes + 214 * ibmat] = inGray[3 * ibmat + 480 * (3 *
        num_bboxes)];
    }
  }

  emxInit_int32_T(&bboxes_, 2);
  num_bboxes = cascadeClassifier_detectMultiScale(ptrObj, &ptrDetectedObj,
    b_inGray, 160, 214, ScaleFactor, MergeThreshold, MinSize_, MaxSize_);
  ibmat = bboxes_->size[0] * bboxes_->size[1];
  bboxes_->size[0] = num_bboxes;
  bboxes_->size[1] = 4;
  emxEnsureCapacity_int32_T(bboxes_, ibmat);
  cascadeClassifier_assignOutputDeleteBbox(ptrDetectedObj, &bboxes_->data[0]);
  ibmat = varargout_1->size[0] * varargout_1->size[1];
  varargout_1->size[0] = bboxes_->size[0];
  varargout_1->size[1] = bboxes_->size[1];
  emxEnsureCapacity_int32_T(varargout_1, ibmat);
  loop_ub = bboxes_->size[0] * bboxes_->size[1];
  for (ibmat = 0; ibmat < loop_ub; ibmat++) {
    varargout_1->data[ibmat] = bboxes_->data[ibmat];
  }

  emxFree_int32_T(&bboxes_);

  /*  Limit the number of faces to be detected in an image.  insertShape */
  /*  requires that bbox signal must be bounded */
  /*  Insert rectangle shape for bounding box */
  positionOut_size[0] = varargout_1->size[0];
  positionOut_size[1] = 4;
  loop_ub = varargout_1->size[0] * varargout_1->size[1];
  for (ibmat = 0; ibmat < loop_ub; ibmat++) {
    f0 = (float)varargout_1->data[ibmat] * 3.0F;
    if (f0 < 2.14748365E+9F) {
      if (f0 >= -2.14748365E+9F) {
        num_bboxes = (int)f0;
      } else {
        num_bboxes = MIN_int32_T;
      }
    } else {
      num_bboxes = MAX_int32_T;
    }

    positionOut_data[ibmat] = num_bboxes;
  }

  emxFree_int32_T(&varargout_1);
  color_size[0] = (signed char)positionOut_size[0];
  color_size[1] = 3;
  num_bboxes = positionOut_size[0];
  for (loop_ub = 0; loop_ub < 3; loop_ub++) {
    ibmat = loop_ub * num_bboxes;
    for (itilerow = 1; itilerow <= num_bboxes; itilerow++) {
      color_data[(ibmat + itilerow) - 1] = uv1[loop_ub];
    }
  }

  h_ShapeInserter = getSystemObjects();
  tuneLineWidth(h_ShapeInserter);
  SystemCore_step(h_ShapeInserter, inRGB, positionOut_data, positionOut_size,
                  color_data, color_size, outRGB);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void faceDetectionARMKernel_free(void)
{
  void * ptrObj;
  if (!faceDetector.matlabCodegenIsDeleted) {
    faceDetector.matlabCodegenIsDeleted = true;
    if (faceDetector.isInitialized == 1) {
      faceDetector.isInitialized = 2;
      if (faceDetector.isSetupComplete) {
        ptrObj = faceDetector.pCascadeClassifier;
        cascadeClassifier_deleteObj(ptrObj);
      }
    }
  }
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void faceDetectionARMKernel_init(void)
{
  faceDetector_not_empty = false;
  faceDetector.matlabCodegenIsDeleted = true;
}

/*
 * File trailer for faceDetectionARMKernel.c
 *
 * [EOF]
 */
