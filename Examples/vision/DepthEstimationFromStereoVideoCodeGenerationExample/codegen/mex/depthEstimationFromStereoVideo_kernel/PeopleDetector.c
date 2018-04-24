/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * PeopleDetector.c
 *
 * Code generation for function 'PeopleDetector'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "PeopleDetector.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "HOGDescriptorCore_api.hpp"

/* Variable Definitions */
static emlrtRSInfo de_emlrtRSI = { 207,/* lineNo */
  "PeopleDetector",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\PeopleDetector.m"/* pathName */
};

static emlrtRSInfo ep_emlrtRSI = { 421,/* lineNo */
  "PeopleDetector",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\PeopleDetector.m"/* pathName */
};

static emlrtRSInfo fp_emlrtRSI = { 432,/* lineNo */
  "PeopleDetector",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\PeopleDetector.m"/* pathName */
};

static emlrtRSInfo gp_emlrtRSI = { 172,/* lineNo */
  "HOGDescriptorBuildable",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pathName */
};

static emlrtRSInfo hp_emlrtRSI = { 173,/* lineNo */
  "HOGDescriptorBuildable",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pathName */
};

static emlrtRSInfo ip_emlrtRSI = { 80, /* lineNo */
  "HOGDescriptorBuildable",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pathName */
};

static emlrtRSInfo jp_emlrtRSI = { 81, /* lineNo */
  "HOGDescriptorBuildable",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pathName */
};

static emlrtRSInfo kp_emlrtRSI = { 82, /* lineNo */
  "HOGDescriptorBuildable",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pathName */
};

static emlrtRSInfo lp_emlrtRSI = { 83, /* lineNo */
  "HOGDescriptorBuildable",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pathName */
};

static emlrtRSInfo mp_emlrtRSI = { 84, /* lineNo */
  "HOGDescriptorBuildable",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pathName */
};

static emlrtRSInfo np_emlrtRSI = { 85, /* lineNo */
  "HOGDescriptorBuildable",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pathName */
};

static emlrtRSInfo op_emlrtRSI = { 28, /* lineNo */
  "clipBBox",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m"/* pathName */
};

static emlrtRTEInfo qd_emlrtRTEI = { 385,/* lineNo */
  34,                                  /* colNo */
  "PeopleDetector",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\PeopleDetector.m"/* pName */
};

static emlrtRTEInfo rd_emlrtRTEI = { 421,/* lineNo */
  17,                                  /* colNo */
  "PeopleDetector",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\PeopleDetector.m"/* pName */
};

static emlrtRTEInfo sd_emlrtRTEI = { 432,/* lineNo */
  20,                                  /* colNo */
  "PeopleDetector",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\PeopleDetector.m"/* pName */
};

static emlrtRTEInfo td_emlrtRTEI = { 138,/* lineNo */
  13,                                  /* colNo */
  "HOGDescriptorBuildable",            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pName */
};

static emlrtRTEInfo ud_emlrtRTEI = { 140,/* lineNo */
  13,                                  /* colNo */
  "HOGDescriptorBuildable",            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m"/* pName */
};

static emlrtRTEInfo vd_emlrtRTEI = { 17,/* lineNo */
  1,                                   /* colNo */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m"/* pName */
};

static emlrtRTEInfo wd_emlrtRTEI = { 19,/* lineNo */
  1,                                   /* colNo */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m"/* pName */
};

static emlrtRTEInfo xd_emlrtRTEI = { 20,/* lineNo */
  1,                                   /* colNo */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m"/* pName */
};

static emlrtRTEInfo ve_emlrtRTEI = { 305,/* lineNo */
  17,                                  /* colNo */
  "PeopleDetector",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\PeopleDetector.m"/* pName */
};

static emlrtECInfo s_emlrtECI = { -1,  /* nDims */
  434,                                 /* lineNo */
  13,                                  /* colNo */
  "PeopleDetector",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\PeopleDetector.m"/* pName */
};

static emlrtECInfo t_emlrtECI = { -1,  /* nDims */
  19,                                  /* lineNo */
  6,                                   /* colNo */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m"/* pName */
};

static emlrtECInfo u_emlrtECI = { -1,  /* nDims */
  20,                                  /* lineNo */
  6,                                   /* colNo */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m"/* pName */
};

static emlrtECInfo v_emlrtECI = { -1,  /* nDims */
  28,                                  /* lineNo */
  22,                                  /* colNo */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m"/* pName */
};

static emlrtECInfo w_emlrtECI = { -1,  /* nDims */
  28,                                  /* lineNo */
  30,                                  /* colNo */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m"/* pName */
};

static emlrtDCInfo m_emlrtDCI = { 138, /* lineNo */
  42,                                  /* colNo */
  "HOGDescriptorBuildable",            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m",/* pName */
  4                                    /* checkKind */
};

static emlrtDCInfo n_emlrtDCI = { 140, /* lineNo */
  44,                                  /* colNo */
  "HOGDescriptorBuildable",            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\HOGDescriptorBuildable.m",/* pName */
  4                                    /* checkKind */
};

static emlrtBCInfo qe_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  22,                                  /* lineNo */
  4,                                   /* colNo */
  "",                                  /* aName */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo re_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  23,                                  /* lineNo */
  4,                                   /* colNo */
  "",                                  /* aName */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo se_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  25,                                  /* lineNo */
  4,                                   /* colNo */
  "",                                  /* aName */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo te_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  26,                                  /* lineNo */
  4,                                   /* colNo */
  "",                                  /* aName */
  "clipBBox",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+detector\\clipBBox.m",/* pName */
  0                                    /* checkKind */
};

/* Function Declarations */
static void b_PeopleDetector_PeopleDetector(const emlrtStack *sp,
  vision_PeopleDetector **obj);

/* Function Definitions */
static void b_PeopleDetector_PeopleDetector(const emlrtStack *sp,
  vision_PeopleDetector **obj)
{
  int32_T i61;
  void * ptrObj;
  boolean_T flag;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  (*obj)->ClassificationThreshold = 1.0;
  (*obj)->ScaleFactor = 1.05;
  for (i61 = 0; i61 < 2; i61++) {
    (*obj)->WindowStride[i61] = 8.0;
  }

  (*obj)->isInitialized = 0;
  ptrObj = NULL;
  HOGDescriptor_construct(&ptrObj);
  (*obj)->pHOGDescriptor = ptrObj;
  flag = ((*obj)->isInitialized == 1);
  if (flag) {
    (*obj)->TunablePropsChanged = true;
  }

  for (i61 = 0; i61 < 2; i61++) {
    (*obj)->MinSize[i61] = 166.0 + -83.0 * (real_T)i61;
  }

  for (i61 = 0; i61 < 2; i61++) {
    (*obj)->pTrainingSize[i61] = 128.0 + -64.0 * (real_T)i61;
  }

  ptrObj = (*obj)->pHOGDescriptor;
  HOGDescriptor_setup(ptrObj, 1);
  st.site = &de_emlrtRSI;
  c_PeopleDetector_validateProper(&st, *obj);
  (*obj)->matlabCodegenIsDeleted = false;
}

vision_PeopleDetector *PeopleDetector_PeopleDetector(const emlrtStack *sp,
  vision_PeopleDetector *obj)
{
  vision_PeopleDetector *b_obj;
  b_obj = obj;
  b_PeopleDetector_PeopleDetector(sp, &b_obj);
  return b_obj;
}

void PeopleDetector_stepImpl(const emlrtStack *sp, const vision_PeopleDetector
  *obj, const emxArray_uint8_T *I, emxArray_real_T *bbox)
{
  int32_T i45;
  real_T obj_MinSize[2];
  void * ptrObj;
  real_T ClassificationThreshold_;
  real_T postMergeThreshold_;
  emxArray_uint8_T *b_I;
  real_T WindowStride[2];
  real_T ScaleFactor_;
  int32_T numDetectedObj;
  int32_T MinSize_[2];
  int32_T MaxSize_[2];
  int32_T WindowStride_[2];
  void * ptrDetectedObj;
  void * ptrDetectionScores;
  int32_T numDetectionScores;
  int32_T loop_ub;
  emxArray_int32_T *bbox_;
  emxArray_real_T *scores_;
  emxArray_int32_T *b_y1;
  emxArray_real_T *x2;
  emxArray_real_T *y2;
  emxArray_int32_T *r35;
  emxArray_int32_T *r36;
  boolean_T b3;
  emxArray_real_T *b_bbox;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  for (i45 = 0; i45 < 2; i45++) {
    obj_MinSize[i45] = obj->MinSize[i45];
  }

  st.site = &ep_emlrtRSI;
  ptrObj = obj->pHOGDescriptor;
  ClassificationThreshold_ = obj->ScaleFactor;
  postMergeThreshold_ = obj->ClassificationThreshold;
  for (i45 = 0; i45 < 2; i45++) {
    WindowStride[i45] = obj->WindowStride[i45];
  }

  emxInit_uint8_T(&st, &b_I, 2, &qd_emlrtRTEI, true);
  b_st.site = &ip_emlrtRSI;
  ScaleFactor_ = (double)(ClassificationThreshold_);
  b_st.site = &jp_emlrtRSI;
  ClassificationThreshold_ = (double)(postMergeThreshold_);
  b_st.site = &kp_emlrtRSI;
  postMergeThreshold_ = (double)(0.0);
  b_st.site = &lp_emlrtRSI;
  c_st.site = &gp_emlrtRSI;
  numDetectedObj = (int32_T)(obj_MinSize[0]);
  MinSize_[0] = numDetectedObj;
  c_st.site = &hp_emlrtRSI;
  numDetectedObj = (int32_T)(obj_MinSize[1]);
  MinSize_[1] = numDetectedObj;
  b_st.site = &mp_emlrtRSI;
  c_st.site = &gp_emlrtRSI;
  numDetectedObj = (int32_T)(0.0);
  MaxSize_[0] = numDetectedObj;
  c_st.site = &hp_emlrtRSI;
  numDetectedObj = (int32_T)(0.0);
  MaxSize_[1] = numDetectedObj;
  b_st.site = &np_emlrtRSI;
  c_st.site = &gp_emlrtRSI;
  numDetectedObj = (int32_T)(WindowStride[0]);
  WindowStride_[0] = numDetectedObj;
  c_st.site = &hp_emlrtRSI;
  numDetectedObj = (int32_T)(WindowStride[1]);
  WindowStride_[1] = numDetectedObj;
  ptrDetectedObj = NULL;
  ptrDetectionScores = NULL;
  numDetectedObj = 0;
  numDetectionScores = 0;
  i45 = b_I->size[0] * b_I->size[1];
  b_I->size[0] = I->size[0];
  b_I->size[1] = I->size[1];
  emxEnsureCapacity_uint8_T(&st, b_I, i45, &qd_emlrtRTEI);
  loop_ub = I->size[0] * I->size[1];
  for (i45 = 0; i45 < loop_ub; i45++) {
    b_I->data[i45] = I->data[i45];
  }

  emxInit_int32_T1(&st, &bbox_, 2, &td_emlrtRTEI, true);
  emxInit_real_T1(&st, &scores_, 1, &ud_emlrtRTEI, true);
  HOGDescriptor_detectMultiScale(ptrObj, &ptrDetectedObj, &ptrDetectionScores,
    &b_I->data[0], I->size[0], I->size[1], false, ScaleFactor_,
    ClassificationThreshold_, postMergeThreshold_, MinSize_, MaxSize_,
    WindowStride_, true, &numDetectedObj, &numDetectionScores);
  i45 = bbox_->size[0] * bbox_->size[1];
  if (!(numDetectedObj >= 0)) {
    emlrtNonNegativeCheckR2012b(numDetectedObj, &m_emlrtDCI, &st);
  }

  bbox_->size[0] = numDetectedObj;
  bbox_->size[1] = 4;
  emxEnsureCapacity_int32_T1(&st, bbox_, i45, &rd_emlrtRTEI);
  i45 = scores_->size[0];
  if (!(numDetectionScores >= 0)) {
    emlrtNonNegativeCheckR2012b(numDetectionScores, &n_emlrtDCI, &st);
  }

  scores_->size[0] = numDetectionScores;
  emxEnsureCapacity_real_T(&st, scores_, i45, &rd_emlrtRTEI);
  HOGDescriptor_assignOutputDeleteVectors(ptrDetectedObj, ptrDetectionScores,
    &bbox_->data[0], &scores_->data[0]);
  i45 = bbox->size[0] * bbox->size[1];
  bbox->size[0] = bbox_->size[0];
  bbox->size[1] = 4;
  emxEnsureCapacity_real_T1(&st, bbox, i45, &qd_emlrtRTEI);
  loop_ub = bbox_->size[0] * bbox_->size[1];
  emxFree_uint8_T(&st, &b_I);
  for (i45 = 0; i45 < loop_ub; i45++) {
    bbox->data[i45] = bbox_->data[i45];
  }

  emxFree_int32_T(&st, &bbox_);
  st.site = &fp_emlrtRSI;
  for (i45 = 0; i45 < 2; i45++) {
    obj_MinSize[i45] = I->size[i45];
  }

  loop_ub = bbox->size[0];
  i45 = scores_->size[0];
  scores_->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&st, scores_, i45, &qd_emlrtRTEI);
  for (i45 = 0; i45 < loop_ub; i45++) {
    scores_->data[i45] = bbox->data[i45];
  }

  emxInit_int32_T(&st, &b_y1, 1, &vd_emlrtRTEI, true);
  loop_ub = bbox->size[0];
  i45 = b_y1->size[0];
  b_y1->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&st, b_y1, i45, &qd_emlrtRTEI);
  for (i45 = 0; i45 < loop_ub; i45++) {
    b_y1->data[i45] = (int32_T)bbox->data[i45 + bbox->size[0]];
  }

  emxInit_real_T1(&st, &x2, 1, &wd_emlrtRTEI, true);
  i45 = bbox->size[0];
  numDetectionScores = bbox->size[0];
  if (i45 != numDetectionScores) {
    emlrtSizeEqCheck1DR2012b(i45, numDetectionScores, &t_emlrtECI, &st);
  }

  loop_ub = bbox->size[0];
  i45 = x2->size[0];
  x2->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&st, x2, i45, &qd_emlrtRTEI);
  for (i45 = 0; i45 < loop_ub; i45++) {
    x2->data[i45] = (bbox->data[i45] + bbox->data[i45 + (bbox->size[0] << 1)]) -
      1.0;
  }

  emxInit_real_T1(&st, &y2, 1, &xd_emlrtRTEI, true);
  i45 = bbox->size[0];
  numDetectionScores = bbox->size[0];
  if (i45 != numDetectionScores) {
    emlrtSizeEqCheck1DR2012b(i45, numDetectionScores, &u_emlrtECI, &st);
  }

  loop_ub = bbox->size[0];
  i45 = y2->size[0];
  y2->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&st, y2, i45, &qd_emlrtRTEI);
  for (i45 = 0; i45 < loop_ub; i45++) {
    y2->data[i45] = (bbox->data[i45 + bbox->size[0]] + bbox->data[i45 +
                     bbox->size[0] * 3]) - 1.0;
  }

  numDetectionScores = bbox->size[0];
  for (loop_ub = 0; loop_ub < numDetectionScores; loop_ub++) {
    if (scores_->data[loop_ub] < 1.0) {
      i45 = scores_->size[0];
      if (!((loop_ub + 1 >= 1) && (loop_ub + 1 <= i45))) {
        emlrtDynamicBoundsCheckR2012b(loop_ub + 1, 1, i45, &qe_emlrtBCI, &st);
      }

      scores_->data[loop_ub] = 1.0;
    }
  }

  numDetectionScores = bbox->size[0];
  for (loop_ub = 0; loop_ub < numDetectionScores; loop_ub++) {
    if (b_y1->data[loop_ub] < 1) {
      i45 = b_y1->size[0];
      if (!((loop_ub + 1 >= 1) && (loop_ub + 1 <= i45))) {
        emlrtDynamicBoundsCheckR2012b(loop_ub + 1, 1, i45, &re_emlrtBCI, &st);
      }

      b_y1->data[loop_ub] = 1;
    }
  }

  numDetectionScores = bbox->size[0] - 1;
  numDetectedObj = 0;
  for (loop_ub = 0; loop_ub <= numDetectionScores; loop_ub++) {
    if ((bbox->data[loop_ub] + bbox->data[loop_ub + (bbox->size[0] << 1)]) - 1.0
        > (uint32_T)obj_MinSize[1]) {
      numDetectedObj++;
    }
  }

  emxInit_int32_T(&st, &r35, 1, &qd_emlrtRTEI, true);
  i45 = r35->size[0];
  r35->size[0] = numDetectedObj;
  emxEnsureCapacity_int32_T(&st, r35, i45, &sd_emlrtRTEI);
  numDetectedObj = 0;
  for (loop_ub = 0; loop_ub <= numDetectionScores; loop_ub++) {
    if ((bbox->data[loop_ub] + bbox->data[loop_ub + (bbox->size[0] << 1)]) - 1.0
        > (uint32_T)obj_MinSize[1]) {
      r35->data[numDetectedObj] = loop_ub + 1;
      numDetectedObj++;
    }
  }

  i45 = bbox->size[0];
  loop_ub = r35->size[0];
  for (numDetectionScores = 0; numDetectionScores < loop_ub; numDetectionScores
       ++) {
    numDetectedObj = r35->data[numDetectionScores];
    if (!((numDetectedObj >= 1) && (numDetectedObj <= i45))) {
      emlrtDynamicBoundsCheckR2012b(numDetectedObj, 1, i45, &se_emlrtBCI, &st);
    }

    x2->data[numDetectedObj - 1] = (uint32_T)obj_MinSize[1];
  }

  numDetectionScores = bbox->size[0] - 1;
  numDetectedObj = 0;
  for (loop_ub = 0; loop_ub <= numDetectionScores; loop_ub++) {
    if ((bbox->data[loop_ub + bbox->size[0]] + bbox->data[loop_ub + bbox->size[0]
         * 3]) - 1.0 > (uint32_T)obj_MinSize[0]) {
      numDetectedObj++;
    }
  }

  emxInit_int32_T(&st, &r36, 1, &qd_emlrtRTEI, true);
  i45 = r36->size[0];
  r36->size[0] = numDetectedObj;
  emxEnsureCapacity_int32_T(&st, r36, i45, &sd_emlrtRTEI);
  numDetectedObj = 0;
  for (loop_ub = 0; loop_ub <= numDetectionScores; loop_ub++) {
    if ((bbox->data[loop_ub + bbox->size[0]] + bbox->data[loop_ub + bbox->size[0]
         * 3]) - 1.0 > (uint32_T)obj_MinSize[0]) {
      r36->data[numDetectedObj] = loop_ub + 1;
      numDetectedObj++;
    }
  }

  i45 = bbox->size[0];
  loop_ub = r36->size[0];
  for (numDetectionScores = 0; numDetectionScores < loop_ub; numDetectionScores
       ++) {
    numDetectedObj = r36->data[numDetectionScores];
    if (!((numDetectedObj >= 1) && (numDetectedObj <= i45))) {
      emlrtDynamicBoundsCheckR2012b(numDetectedObj, 1, i45, &te_emlrtBCI, &st);
    }

    y2->data[numDetectedObj - 1] = (uint32_T)obj_MinSize[0];
  }

  emxFree_int32_T(&st, &r36);
  i45 = x2->size[0];
  numDetectionScores = scores_->size[0];
  if (i45 != numDetectionScores) {
    emlrtSizeEqCheck1DR2012b(i45, numDetectionScores, &v_emlrtECI, &st);
  }

  i45 = y2->size[0];
  numDetectionScores = b_y1->size[0];
  if (i45 != numDetectionScores) {
    emlrtSizeEqCheck1DR2012b(i45, numDetectionScores, &w_emlrtECI, &st);
  }

  b_st.site = &op_emlrtRSI;
  i45 = x2->size[0];
  emxEnsureCapacity_real_T(&b_st, x2, i45, &qd_emlrtRTEI);
  loop_ub = x2->size[0];
  for (i45 = 0; i45 < loop_ub; i45++) {
    x2->data[i45] = (x2->data[i45] - scores_->data[i45]) + 1.0;
  }

  i45 = y2->size[0];
  emxEnsureCapacity_real_T(&b_st, y2, i45, &qd_emlrtRTEI);
  loop_ub = y2->size[0];
  for (i45 = 0; i45 < loop_ub; i45++) {
    y2->data[i45] = (y2->data[i45] - (real_T)b_y1->data[i45]) + 1.0;
  }

  c_st.site = &rh_emlrtRSI;
  d_st.site = &sh_emlrtRSI;
  b3 = true;
  if (b_y1->size[0] != scores_->size[0]) {
    b3 = false;
  }

  if (!b3) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if (x2->size[0] != scores_->size[0]) {
    b3 = false;
  }

  if (!b3) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if (y2->size[0] != scores_->size[0]) {
    b3 = false;
  }

  if (!b3) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  i45 = bbox->size[0] * bbox->size[1];
  bbox->size[0] = scores_->size[0];
  bbox->size[1] = 4;
  emxEnsureCapacity_real_T1(&c_st, bbox, i45, &qd_emlrtRTEI);
  loop_ub = scores_->size[0];
  for (i45 = 0; i45 < loop_ub; i45++) {
    bbox->data[i45] = scores_->data[i45];
  }

  emxFree_real_T(&c_st, &scores_);
  loop_ub = b_y1->size[0];
  for (i45 = 0; i45 < loop_ub; i45++) {
    bbox->data[i45 + bbox->size[0]] = b_y1->data[i45];
  }

  emxFree_int32_T(&c_st, &b_y1);
  loop_ub = x2->size[0];
  for (i45 = 0; i45 < loop_ub; i45++) {
    bbox->data[i45 + (bbox->size[0] << 1)] = x2->data[i45];
  }

  emxFree_real_T(&c_st, &x2);
  loop_ub = y2->size[0];
  for (i45 = 0; i45 < loop_ub; i45++) {
    bbox->data[i45 + bbox->size[0] * 3] = y2->data[i45];
  }

  emxFree_real_T(&c_st, &y2);
  loop_ub = bbox->size[0];
  i45 = r35->size[0];
  r35->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(sp, r35, i45, &qd_emlrtRTEI);
  for (i45 = 0; i45 < loop_ub; i45++) {
    r35->data[i45] = i45;
  }

  emxInit_real_T(sp, &b_bbox, 2, &qd_emlrtRTEI, true);
  i45 = bbox->size[0];
  MinSize_[0] = r35->size[0];
  MinSize_[1] = 2;
  MaxSize_[0] = i45;
  MaxSize_[1] = 2;
  emlrtSubAssignSizeCheckR2012b(&MinSize_[0], 2, &MaxSize_[0], 2, &s_emlrtECI,
    sp);
  numDetectedObj = bbox->size[0];
  i45 = b_bbox->size[0] * b_bbox->size[1];
  b_bbox->size[0] = numDetectedObj;
  b_bbox->size[1] = 2;
  emxEnsureCapacity_real_T1(sp, b_bbox, i45, &qd_emlrtRTEI);
  for (i45 = 0; i45 < 2; i45++) {
    for (numDetectionScores = 0; numDetectionScores < numDetectedObj;
         numDetectionScores++) {
      b_bbox->data[numDetectionScores + b_bbox->size[0] * i45] = bbox->
        data[numDetectionScores + bbox->size[0] * i45];
    }
  }

  for (i45 = 0; i45 < 2; i45++) {
    loop_ub = b_bbox->size[0];
    for (numDetectionScores = 0; numDetectionScores < loop_ub;
         numDetectionScores++) {
      bbox->data[r35->data[numDetectionScores] + bbox->size[0] * i45] =
        b_bbox->data[numDetectionScores + b_bbox->size[0] * i45];
    }
  }

  emxFree_real_T(sp, &b_bbox);
  emxFree_int32_T(sp, &r35);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void c_PeopleDetector_validateProper(const emlrtStack *sp, const
  vision_PeopleDetector *obj)
{
  int32_T k;
  boolean_T y;
  boolean_T x[2];
  boolean_T exitg1;
  for (k = 0; k < 2; k++) {
    x[k] = (obj->MinSize[k] < obj->pTrainingSize[k]);
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
    emlrtErrorWithMessageIdR2018a(sp, &ve_emlrtRTEI,
      "vision:ObjectDetector:minSizeLTTrainingSize",
      "vision:ObjectDetector:minSizeLTTrainingSize", 4, 6, obj->pTrainingSize[0],
      6, obj->pTrainingSize[1]);
  }
}

/* End of code generation (PeopleDetector.c) */
