/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * depthEstimationFromStereoVideo_kernel.c
 *
 * Code generation for function 'depthEstimationFromStereoVideo_kernel'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "step.h"
#include "DeployableVideoPlayer.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "rdivide.h"
#include "rectifyStereoImages.h"
#include "insertShape.h"
#include "insertText.h"
#include "insertObjectAnnotation.h"
#include "eml_int_forloop_overflow_check.h"
#include "error.h"
#include "scalexpAlloc.h"
#include "indexShapeCheck.h"
#include "sub2ind.h"
#include "round.h"
#include "SystemCore.h"
#include "StereoParametersImpl.h"
#include "disparity.h"
#include "rgb2gray.h"
#include "matlabCodegenHandle.h"
#include "PeopleDetector.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = { 17,    /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo b_emlrtRSI = { 18,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo c_emlrtRSI = { 19,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo d_emlrtRSI = { 22,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo e_emlrtRSI = { 28,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo f_emlrtRSI = { 29,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo g_emlrtRSI = { 32,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo h_emlrtRSI = { 36,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo i_emlrtRSI = { 37,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo j_emlrtRSI = { 40,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo k_emlrtRSI = { 43,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo l_emlrtRSI = { 46,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo m_emlrtRSI = { 52,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo n_emlrtRSI = { 53,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo o_emlrtRSI = { 56,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo p_emlrtRSI = { 60,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo q_emlrtRSI = { 63,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo r_emlrtRSI = { 73,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo s_emlrtRSI = { 78,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo t_emlrtRSI = { 82,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo u_emlrtRSI = { 83,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo v_emlrtRSI = { 84,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo w_emlrtRSI = { 10,  /* lineNo */
  "depthEstimationFromStereoVideo_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pathName */
};

static emlrtRSInfo rd_emlrtRSI = { 1,  /* lineNo */
  "DeployableVideoPlayer",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+visioncodegen\\DeployableVideoPlayer.p"/* pathName */
};

static emlrtRSInfo mh_emlrtRSI = { 71, /* lineNo */
  "sub2ind",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\sub2ind.m"/* pathName */
};

static emlrtRSInfo to_emlrtRSI = { 76, /* lineNo */
  "reconstructScene",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\reconstructScene.m"/* pathName */
};

static emlrtRSInfo qp_emlrtRSI = { 39, /* lineNo */
  "sub2ind",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\sub2ind.m"/* pathName */
};

static emlrtRSInfo tp_emlrtRSI = { 71, /* lineNo */
  "combineVectorElements",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combineVectorElements.m"/* pathName */
};

static emlrtRSInfo up_emlrtRSI = { 80, /* lineNo */
  "blockedSummation",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pathName */
};

static emlrtRSInfo vp_emlrtRSI = { 136,/* lineNo */
  "blockedSummation",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pathName */
};

static emlrtRSInfo wp_emlrtRSI = { 15, /* lineNo */
  "sqrt",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\sqrt.m"/* pathName */
};

static emlrtRTEInfo emlrtRTEI = { 5,   /* lineNo */
  10,                                  /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo d_emlrtRTEI = { 80,/* lineNo */
  13,                                  /* colNo */
  "blockedSummation",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pName */
};

static emlrtRTEInfo e_emlrtRTEI = { 10,/* lineNo */
  1,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo f_emlrtRTEI = { 36,/* lineNo */
  5,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo g_emlrtRTEI = { 37,/* lineNo */
  5,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo h_emlrtRTEI = { 40,/* lineNo */
  5,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo i_emlrtRTEI = { 43,/* lineNo */
  5,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo j_emlrtRTEI = { 46,/* lineNo */
  5,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo k_emlrtRTEI = { 52,/* lineNo */
  9,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo l_emlrtRTEI = { 56,/* lineNo */
  9,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo m_emlrtRTEI = { 60,/* lineNo */
  9,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo n_emlrtRTEI = { 63,/* lineNo */
  9,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtECInfo emlrtECI = { -1,    /* nDims */
  52,                                  /* lineNo */
  28,                                  /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtECInfo b_emlrtECI = { -1,  /* nDims */
  53,                                  /* lineNo */
  19,                                  /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo ge_emlrtRTEI = { 69,/* lineNo */
  9,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo he_emlrtRTEI = { 70,/* lineNo */
  9,                                   /* colNo */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m"                     /* pName */
};

static emlrtRTEInfo ie_emlrtRTEI = { 15,/* lineNo */
  1,                                   /* colNo */
  "reset",                             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\scomp\\reset.m"/* pName */
};

static emlrtRTEInfo je_emlrtRTEI = { 55,/* lineNo */
  5,                                   /* colNo */
  "step",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\scomp\\step.m"/* pName */
};

static emlrtBCInfo emlrtBCI = { -1,    /* iFirst */
  -1,                                  /* iLast */
  48,                                  /* lineNo */
  31,                                  /* colNo */
  "frameLeftRect",                     /* aName */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m",                    /* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo b_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  48,                                  /* lineNo */
  38,                                  /* colNo */
  "frameLeftRect",                     /* aName */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m",                    /* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo c_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  60,                                  /* lineNo */
  26,                                  /* colNo */
  "X",                                 /* aName */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m",                    /* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo d_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  60,                                  /* lineNo */
  44,                                  /* colNo */
  "Y",                                 /* aName */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m",                    /* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo e_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  60,                                  /* lineNo */
  62,                                  /* colNo */
  "Z",                                 /* aName */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m",                    /* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo f_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  72,                                  /* lineNo */
  15,                                  /* colNo */
  "dists",                             /* aName */
  "depthEstimationFromStereoVideo_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\DepthEstimationFromStereoVideoCodeGenerationExample\\depthEstimationFromStereo"
  "Video_kernel.m",                    /* pName */
  0                                    /* checkKind */
};

/* Function Definitions */
void depthEstimationFromStereoVideo_kernel(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const struct0_T *stereoParamStruct)
{
  c_vision_internal_calibration_S stereoParams;
  vision_PeopleDetector peopleDetector;
  c_visioncodegen_DeployableVideo player;
  c_vision_internal_calibration_C lobj_5;
  c_vision_internal_calibration_C lobj_6;
  vision_VideoFileReader_0 readerLeft;
  vision_VideoFileReader_0 readerRight;
  emxArray_uint8_T *frameLeftGray;
  emxArray_uint8_T *frameRightGray;
  emxArray_real32_T *disparityMap;
  emxArray_real32_T *point3D;
  emxArray_real_T *bboxes;
  emxArray_real_T *centroids;
  emxArray_real_T *centroidsIdx;
  emxArray_real32_T *centroids3D;
  emxArray_real32_T *dists;
  emxArray_uint8_T *frameLeftRect;
  emxArray_uint8_T *frameRightRect;
  emxArray_real_T *r0;
  emxArray_real_T *varargin_1;
  emxArray_real_T *varargin_2;
  emxArray_real32_T *z;
  emxArray_real_T *b_bboxes;
  emxArray_real32_T *b_point3D;
  emxArray_real32_T *c_point3D;
  int32_T exitg1;
  boolean_T overflow;
  boolean_T p;
  int32_T nx;
  int32_T xpageoffset;
  int32_T i0;
  int32_T i1;
  int32_T i2;
  c_visioncodegen_DeployableVideo *obj;
  int32_T k;
  int32_T partialTrueCount;
  char_T *sErr;
  int32_T siz[2];
  uint32_T sz[2];
  uint32_T b_varargin_2[2];
  boolean_T exitg2;
  uint32_T unnamed_idx_1;
  boolean_T tmp_data[99];
  int32_T b_tmp_data[99];
  int32_T label_size[2];
  real32_T label_data[99];
  int32_T position_data[396];
  uint8_T color_data[297];
  int32_T color_size[2];
  uint8_T textColor_data[297];
  int32_T textColor_size[2];
  int32_T textLocAndWidth_data[396];
  int32_T textLocAndWidth_size[2];
  int32_T b_textLocAndWidth_size[2];
  int32_T c_textLocAndWidth_size[1];
  int32_T b_textLocAndWidth_data[198];
  int32_T c_textLocAndWidth_data[99];
  int32_T d_textLocAndWidth_size[1];
  int32_T d_textLocAndWidth_data[99];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  c_emxInitStruct_vision_internal(sp, &stereoParams, &e_emlrtRTEI, true);
  emlrtPushHeapReferenceStackR2018a(sp, (void *)&peopleDetector, (void (*)(const
    void *, void *))d_matlabCodegenHandle_matlabCod);
  peopleDetector.matlabCodegenIsDeleted = true;
  emlrtPushHeapReferenceStackR2018a(sp, (void *)&player, (void (*)(const void *,
    void *))c_matlabCodegenHandle_matlabCod);
  player.matlabCodegenIsDeleted = true;

  /*  Kernel for Depth Estimation From Stereo Video */
  /*    Copyright 2013-2014 The MathWorks, Inc. */
  /*  Re-create the Stereo Parameters */
  st.site = &w_emlrtRSI;
  c_StereoParametersImpl_StereoPa(&st, &stereoParams,
    stereoParamStruct->CameraParameters1.RadialDistortion,
    stereoParamStruct->CameraParameters1.TangentialDistortion,
    stereoParamStruct->CameraParameters1.WorldUnits,
    stereoParamStruct->CameraParameters1.NumRadialDistortionCoefficients,
    stereoParamStruct->CameraParameters1.RotationVectors,
    stereoParamStruct->CameraParameters1.TranslationVectors,
    stereoParamStruct->CameraParameters1.IntrinsicMatrix,
    stereoParamStruct->CameraParameters2.RadialDistortion,
    stereoParamStruct->CameraParameters2.TangentialDistortion,
    stereoParamStruct->CameraParameters2.WorldUnits,
    stereoParamStruct->CameraParameters2.NumRadialDistortionCoefficients,
    stereoParamStruct->CameraParameters2.RotationVectors,
    stereoParamStruct->CameraParameters2.TranslationVectors,
    stereoParamStruct->CameraParameters2.IntrinsicMatrix,
    stereoParamStruct->RotationOfCamera2,
    stereoParamStruct->TranslationOfCamera2,
    &stereoParamStruct->RectificationParams, &lobj_5, &lobj_6);

  /*  Create Video File Readers and the Video Player */
  /*  Create System Objects for reading and displaying the video */
  st.site = &emlrtRSI;
  Constructor(&readerLeft);
  st.site = &b_emlrtRSI;
  Constructor(&readerRight);
  st.site = &c_emlrtRSI;
  c_DeployableVideoPlayer_Deploya(&player);

  /*  Create the People Detector */
  st.site = &d_emlrtRSI;
  PeopleDetector_PeopleDetector(&st, &peopleDetector);

  /*  Process the Video */
  emxInit_uint8_T(sp, &frameLeftGray, 2, &f_emlrtRTEI, true);
  emxInit_uint8_T(sp, &frameRightGray, 2, &g_emlrtRTEI, true);
  emxInit_real32_T(sp, &disparityMap, 2, &h_emlrtRTEI, true);
  emxInit_real32_T1(sp, &point3D, 3, &i_emlrtRTEI, true);
  emxInit_real_T(sp, &bboxes, 2, &j_emlrtRTEI, true);
  emxInit_real_T(sp, &centroids, 2, &k_emlrtRTEI, true);
  emxInit_real_T1(sp, &centroidsIdx, 1, &l_emlrtRTEI, true);
  emxInit_real32_T(sp, &centroids3D, 2, &m_emlrtRTEI, true);
  emxInit_real32_T(sp, &dists, 2, &n_emlrtRTEI, true);
  emxInit_uint8_T1(sp, &frameLeftRect, 3, &emlrtRTEI, true);
  emxInit_uint8_T1(sp, &frameRightRect, 3, &emlrtRTEI, true);
  emxInit_real_T1(sp, &r0, 1, &emlrtRTEI, true);
  emxInit_real_T1(sp, &varargin_1, 1, &emlrtRTEI, true);
  emxInit_real_T1(sp, &varargin_2, 1, &emlrtRTEI, true);
  emxInit_real32_T(sp, &z, 2, &emlrtRTEI, true);
  emxInit_real_T1(sp, &b_bboxes, 1, &emlrtRTEI, true);
  emxInit_real32_T(sp, &b_point3D, 2, &emlrtRTEI, true);
  emxInit_real32_T(sp, &c_point3D, 2, &emlrtRTEI, true);
  do {
    exitg1 = 0;
    overflow = readerLeft.O2_Y2;
    if (!overflow) {
      overflow = readerRight.O2_Y2;
      if (!overflow) {
        /*  Read the frames. */
        st.site = &e_emlrtRSI;
        if (readerLeft.S0_isInitialized != 1) {
          if (readerLeft.S0_isInitialized == 2) {
            emlrtErrorWithMessageIdR2018a(&st, &je_emlrtRTEI,
              "MATLAB:system:runtimeMethodCalledWhenReleasedCodegen",
              "MATLAB:system:runtimeMethodCalledWhenReleasedCodegen", 0);
          }

          readerLeft.S0_isInitialized = 1;
          b_st.site = NULL;
          Start(&readerLeft);
          b_st.site = NULL;
          InitializeConditions(&readerLeft);
        }

        b_st.site = NULL;
        Outputs(&readerLeft, SD->f5.frameLeft, &overflow, &p);
        st.site = &f_emlrtRSI;
        if (readerRight.S0_isInitialized != 1) {
          if (readerRight.S0_isInitialized == 2) {
            emlrtErrorWithMessageIdR2018a(&st, &je_emlrtRTEI,
              "MATLAB:system:runtimeMethodCalledWhenReleasedCodegen",
              "MATLAB:system:runtimeMethodCalledWhenReleasedCodegen", 0);
          }

          readerRight.S0_isInitialized = 1;
          b_st.site = NULL;
          b_Start(&readerRight);
          b_st.site = NULL;
          InitializeConditions(&readerRight);
        }

        b_st.site = NULL;
        Outputs(&readerRight, SD->f5.frameRight, &overflow, &p);

        /*  Rectify the frames. */
        st.site = &g_emlrtRSI;
        rectifyStereoImages(SD, &st, SD->f5.frameLeft, SD->f5.frameRight,
                            &stereoParams, frameLeftRect, frameRightRect);

        /*  Convert to grayscale. */
        st.site = &h_emlrtRSI;
        rgb2gray(&st, frameLeftRect, frameLeftGray);
        st.site = &i_emlrtRSI;
        rgb2gray(&st, frameRightRect, frameRightGray);

        /*  Compute disparity.  */
        st.site = &j_emlrtRSI;
        disparity(&st, frameLeftGray, frameRightGray, disparityMap);

        /*  Reconstruct 3-D scene. */
        st.site = &k_emlrtRSI;
        b_st.site = &to_emlrtRSI;
        c_StereoParametersImpl_reconstr(&b_st, &stereoParams, disparityMap,
          point3D);

        /*  Detect people. */
        st.site = &l_emlrtRSI;
        SystemCore_step(&st, &peopleDetector, frameLeftGray, bboxes);
        nx = frameLeftRect->size[0];
        xpageoffset = frameLeftRect->size[1];
        for (i0 = 0; i0 < 3; i0++) {
          for (i1 = 0; i1 < 719; i1++) {
            for (i2 = 0; i2 < 514; i2++) {
              k = 1 + i2;
              if (!(k <= nx)) {
                emlrtDynamicBoundsCheckR2012b(k, 1, nx, &emlrtBCI, sp);
              }

              partialTrueCount = 1 + i1;
              if (!(partialTrueCount <= xpageoffset)) {
                emlrtDynamicBoundsCheckR2012b(partialTrueCount, 1, xpageoffset,
                  &b_emlrtBCI, sp);
              }

              SD->f5.dispFrame[(i2 + 514 * i1) + 369566 * i0] =
                frameLeftRect->data[((k + frameLeftRect->size[0] *
                (partialTrueCount - 1)) + frameLeftRect->size[0] *
                frameLeftRect->size[1] * i0) - 1];
            }
          }
        }

        if (!(bboxes->size[0] == 0)) {
          /*  Find the centroids of detected people. */
          xpageoffset = bboxes->size[0];
          i0 = b_bboxes->size[0];
          b_bboxes->size[0] = xpageoffset;
          emxEnsureCapacity_real_T(sp, b_bboxes, i0, &emlrtRTEI);
          for (i0 = 0; i0 < xpageoffset; i0++) {
            b_bboxes->data[i0] = bboxes->data[i0 + (bboxes->size[0] << 1)];
          }

          rdivide(sp, b_bboxes, 2.0, centroidsIdx);
          i0 = bboxes->size[0];
          i1 = centroidsIdx->size[0];
          if (i0 != i1) {
            emlrtSizeEqCheck1DR2012b(i0, i1, &emlrtECI, sp);
          }

          xpageoffset = bboxes->size[0];
          i0 = b_bboxes->size[0];
          b_bboxes->size[0] = xpageoffset;
          emxEnsureCapacity_real_T(sp, b_bboxes, i0, &emlrtRTEI);
          for (i0 = 0; i0 < xpageoffset; i0++) {
            b_bboxes->data[i0] = bboxes->data[i0 + bboxes->size[0] * 3];
          }

          rdivide(sp, b_bboxes, 2.0, r0);
          i0 = bboxes->size[0];
          i1 = r0->size[0];
          if (i0 != i1) {
            emlrtSizeEqCheck1DR2012b(i0, i1, &b_emlrtECI, sp);
          }

          xpageoffset = bboxes->size[0];
          i0 = varargin_1->size[0];
          varargin_1->size[0] = xpageoffset;
          emxEnsureCapacity_real_T(sp, varargin_1, i0, &emlrtRTEI);
          for (i0 = 0; i0 < xpageoffset; i0++) {
            varargin_1->data[i0] = bboxes->data[i0] + centroidsIdx->data[i0];
          }

          st.site = &m_emlrtRSI;
          b_round(&st, varargin_1);
          xpageoffset = bboxes->size[0];
          i0 = varargin_2->size[0];
          varargin_2->size[0] = xpageoffset;
          emxEnsureCapacity_real_T(sp, varargin_2, i0, &emlrtRTEI);
          for (i0 = 0; i0 < xpageoffset; i0++) {
            varargin_2->data[i0] = bboxes->data[i0 + bboxes->size[0]] + r0->
              data[i0];
          }

          st.site = &n_emlrtRSI;
          b_round(&st, varargin_2);
          st.site = &m_emlrtRSI;
          b_st.site = &rh_emlrtRSI;
          c_st.site = &sh_emlrtRSI;
          overflow = true;
          if (varargin_2->size[0] != varargin_1->size[0]) {
            overflow = false;
          }

          if (!overflow) {
            emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
              "MATLAB:catenate:matrixDimensionMismatch",
              "MATLAB:catenate:matrixDimensionMismatch", 0);
          }

          i0 = centroids->size[0] * centroids->size[1];
          centroids->size[0] = varargin_1->size[0];
          centroids->size[1] = 2;
          emxEnsureCapacity_real_T1(&b_st, centroids, i0, &emlrtRTEI);
          xpageoffset = varargin_1->size[0];
          for (i0 = 0; i0 < xpageoffset; i0++) {
            centroids->data[i0] = varargin_1->data[i0];
          }

          xpageoffset = varargin_2->size[0];
          for (i0 = 0; i0 < xpageoffset; i0++) {
            centroids->data[i0 + centroids->size[0]] = varargin_2->data[i0];
          }

          /*  Find the 3-D world coordinates of the centroids. */
          st.site = &o_emlrtRSI;
          xpageoffset = centroids->size[0];
          i0 = centroidsIdx->size[0];
          centroidsIdx->size[0] = xpageoffset;
          emxEnsureCapacity_real_T(&st, centroidsIdx, i0, &emlrtRTEI);
          for (i0 = 0; i0 < xpageoffset; i0++) {
            centroidsIdx->data[i0] = centroids->data[i0 + centroids->size[0]];
          }

          xpageoffset = centroids->size[0];
          i0 = varargin_2->size[0];
          varargin_2->size[0] = xpageoffset;
          emxEnsureCapacity_real_T(&st, varargin_2, i0, &emlrtRTEI);
          for (i0 = 0; i0 < xpageoffset; i0++) {
            varargin_2->data[i0] = centroids->data[i0];
          }

          b_st.site = &lh_emlrtRSI;
          for (i0 = 0; i0 < 2; i0++) {
            siz[i0] = disparityMap->size[i0];
          }

          if (!allinrange(centroidsIdx, siz[0])) {
            emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
              "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange",
              0);
          }

          i0 = centroids->size[0];
          sz[0] = (uint32_T)i0;
          sz[1] = 1U;
          i0 = centroids->size[0];
          b_varargin_2[0] = (uint32_T)i0;
          b_varargin_2[1] = 1U;
          overflow = false;
          p = true;
          k = 0;
          exitg2 = false;
          while ((!exitg2) && (k < 2)) {
            if (!((int32_T)sz[k] == (int32_T)b_varargin_2[k])) {
              p = false;
              exitg2 = true;
            } else {
              k++;
            }
          }

          if (p) {
            overflow = true;
          }

          if (!overflow) {
            emlrtErrorWithMessageIdR2018a(&b_st, &me_emlrtRTEI,
              "MATLAB:sub2ind:SubscriptVectorSize",
              "MATLAB:sub2ind:SubscriptVectorSize", 0);
          }

          c_st.site = &qp_emlrtRSI;
          d_st.site = &mh_emlrtRSI;
          if (!allinrange(varargin_2, siz[1])) {
            emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
              "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange",
              0);
          }

          i0 = centroidsIdx->size[0];
          emxEnsureCapacity_real_T(&st, centroidsIdx, i0, &emlrtRTEI);
          xpageoffset = centroidsIdx->size[0];
          for (i0 = 0; i0 < xpageoffset; i0++) {
            centroidsIdx->data[i0] = (int32_T)centroidsIdx->data[i0] + siz[0] *
              ((int32_T)varargin_2->data[i0] - 1);
          }

          i0 = point3D->size[0];
          i1 = point3D->size[1];
          siz[0] = i0;
          siz[1] = i1;
          st.site = &p_emlrtRSI;
          indexShapeCheck(&st, siz, centroidsIdx->size[0]);
          i0 = point3D->size[0];
          i1 = point3D->size[1];
          siz[0] = i0;
          siz[1] = i1;
          st.site = &p_emlrtRSI;
          indexShapeCheck(&st, siz, centroidsIdx->size[0]);
          i0 = point3D->size[0];
          i1 = point3D->size[1];
          siz[0] = i0;
          siz[1] = i1;
          st.site = &p_emlrtRSI;
          indexShapeCheck(&st, siz, centroidsIdx->size[0]);
          st.site = &p_emlrtRSI;
          i0 = point3D->size[0];
          i1 = point3D->size[1];
          i0 *= i1;
          xpageoffset = centroidsIdx->size[0];
          for (i1 = 0; i1 < xpageoffset; i1++) {
            i2 = (int32_T)centroidsIdx->data[i1];
            if (!((i2 >= 1) && (i2 <= i0))) {
              emlrtDynamicBoundsCheckR2012b(i2, 1, i0, &c_emlrtBCI, &st);
            }
          }

          i0 = point3D->size[0];
          i1 = point3D->size[1];
          i0 *= i1;
          xpageoffset = centroidsIdx->size[0];
          for (i1 = 0; i1 < xpageoffset; i1++) {
            i2 = (int32_T)centroidsIdx->data[i1];
            if (!((i2 >= 1) && (i2 <= i0))) {
              emlrtDynamicBoundsCheckR2012b(i2, 1, i0, &d_emlrtBCI, &st);
            }
          }

          i0 = point3D->size[0];
          i1 = point3D->size[1];
          i0 *= i1;
          xpageoffset = centroidsIdx->size[0];
          for (i1 = 0; i1 < xpageoffset; i1++) {
            i2 = (int32_T)centroidsIdx->data[i1];
            if (!((i2 >= 1) && (i2 <= i0))) {
              emlrtDynamicBoundsCheckR2012b(i2, 1, i0, &e_emlrtBCI, &st);
            }
          }

          b_st.site = &rh_emlrtRSI;
          c_st.site = &sh_emlrtRSI;
          xpageoffset = point3D->size[0];
          nx = point3D->size[1];
          i0 = disparityMap->size[0] * disparityMap->size[1];
          disparityMap->size[0] = xpageoffset;
          disparityMap->size[1] = nx;
          emxEnsureCapacity_real32_T(&b_st, disparityMap, i0, &emlrtRTEI);
          for (i0 = 0; i0 < nx; i0++) {
            for (i1 = 0; i1 < xpageoffset; i1++) {
              disparityMap->data[i1 + disparityMap->size[0] * i0] =
                point3D->data[i1 + point3D->size[0] * i0];
            }
          }

          xpageoffset = point3D->size[0];
          nx = point3D->size[1];
          i0 = b_point3D->size[0] * b_point3D->size[1];
          b_point3D->size[0] = xpageoffset;
          b_point3D->size[1] = nx;
          emxEnsureCapacity_real32_T(&b_st, b_point3D, i0, &emlrtRTEI);
          for (i0 = 0; i0 < nx; i0++) {
            for (i1 = 0; i1 < xpageoffset; i1++) {
              b_point3D->data[i1 + b_point3D->size[0] * i0] = point3D->data[(i1
                + point3D->size[0] * i0) + point3D->size[0] * point3D->size[1]];
            }
          }

          xpageoffset = point3D->size[0];
          nx = point3D->size[1];
          i0 = c_point3D->size[0] * c_point3D->size[1];
          c_point3D->size[0] = xpageoffset;
          c_point3D->size[1] = nx;
          emxEnsureCapacity_real32_T(&b_st, c_point3D, i0, &emlrtRTEI);
          for (i0 = 0; i0 < nx; i0++) {
            for (i1 = 0; i1 < xpageoffset; i1++) {
              c_point3D->data[i1 + c_point3D->size[0] * i0] = point3D->data[(i1
                + point3D->size[0] * i0) + ((point3D->size[0] * point3D->size[1])
                << 1)];
            }
          }

          i0 = centroids3D->size[0] * centroids3D->size[1];
          centroids3D->size[0] = 3;
          centroids3D->size[1] = centroidsIdx->size[0];
          emxEnsureCapacity_real32_T(&b_st, centroids3D, i0, &emlrtRTEI);
          xpageoffset = centroidsIdx->size[0];
          for (i0 = 0; i0 < xpageoffset; i0++) {
            centroids3D->data[centroids3D->size[0] * i0] = disparityMap->data
              [(int32_T)centroidsIdx->data[i0] - 1];
          }

          xpageoffset = centroidsIdx->size[0];
          for (i0 = 0; i0 < xpageoffset; i0++) {
            centroids3D->data[1 + centroids3D->size[0] * i0] = b_point3D->data
              [(int32_T)centroidsIdx->data[i0] - 1];
          }

          xpageoffset = centroidsIdx->size[0];
          for (i0 = 0; i0 < xpageoffset; i0++) {
            centroids3D->data[2 + centroids3D->size[0] * i0] = c_point3D->data
              [(int32_T)centroidsIdx->data[i0] - 1];
          }

          /*  Find the distances from the camera in meters. */
          st.site = &q_emlrtRSI;
          b_st.site = &bi_emlrtRSI;
          c_st.site = &ci_emlrtRSI;
          d_st.site = &di_emlrtRSI;
          i0 = z->size[0] * z->size[1];
          z->size[0] = 3;
          z->size[1] = centroids3D->size[1];
          emxEnsureCapacity_real32_T(&d_st, z, i0, &b_emlrtRTEI);
          if (!b_dimagree(z, centroids3D)) {
            emlrtErrorWithMessageIdR2018a(&d_st, &ne_emlrtRTEI,
              "MATLAB:dimagree", "MATLAB:dimagree", 0);
          }

          i0 = z->size[0] * z->size[1];
          z->size[0] = 3;
          z->size[1] = centroids3D->size[1];
          emxEnsureCapacity_real32_T(&c_st, z, i0, &c_emlrtRTEI);
          d_st.site = &ei_emlrtRSI;
          unnamed_idx_1 = (uint32_T)centroids3D->size[1];
          nx = 3 * (int32_T)unnamed_idx_1;
          e_st.site = &fi_emlrtRSI;
          if ((!(1 > nx)) && (nx > 2147483646)) {
            f_st.site = &lb_emlrtRSI;
            check_forloop_overflow_error(&f_st);
          }

          for (k = 0; k < nx; k++) {
            z->data[k] = centroids3D->data[k] * centroids3D->data[k];
          }

          st.site = &q_emlrtRSI;
          b_st.site = &hm_emlrtRSI;
          c_st.site = &im_emlrtRSI;
          d_st.site = &tp_emlrtRSI;
          if (z->size[1] == 0) {
            i0 = dists->size[0] * dists->size[1];
            dists->size[0] = 1;
            dists->size[1] = 0;
            emxEnsureCapacity_real32_T(&d_st, dists, i0, &emlrtRTEI);
          } else {
            e_st.site = &up_emlrtRSI;
            i0 = dists->size[0] * dists->size[1];
            dists->size[0] = 1;
            dists->size[1] = z->size[1];
            emxEnsureCapacity_real32_T(&e_st, dists, i0, &d_emlrtRTEI);
            f_st.site = &vp_emlrtRSI;
            overflow = (z->size[1] > 2147483646);
            if (overflow) {
              g_st.site = &lb_emlrtRSI;
              check_forloop_overflow_error(&g_st);
            }

            for (nx = 0; nx < z->size[1]; nx++) {
              xpageoffset = nx * 3;
              dists->data[nx] = z->data[xpageoffset];
              for (k = 0; k < 2; k++) {
                dists->data[nx] += z->data[(xpageoffset + k) + 1];
              }
            }
          }

          st.site = &q_emlrtRSI;
          overflow = false;
          for (k = 0; k < dists->size[1]; k++) {
            if (overflow || (dists->data[k] < 0.0F)) {
              overflow = true;
            } else {
              overflow = false;
            }
          }

          if (overflow) {
            b_st.site = &kf_emlrtRSI;
            error(&b_st);
          }

          b_st.site = &wp_emlrtRSI;
          nx = dists->size[1];
          c_st.site = &hi_emlrtRSI;
          overflow = ((!(1 > dists->size[1])) && (dists->size[1] > 2147483646));
          if (overflow) {
            d_st.site = &lb_emlrtRSI;
            check_forloop_overflow_error(&d_st);
          }

          for (k = 0; k < nx; k++) {
            dists->data[k] = muSingleScalarSqrt(dists->data[k]);
          }

          xpageoffset = dists->size[0] * dists->size[1] - 1;
          i0 = dists->size[0] * dists->size[1];
          dists->size[0] = 1;
          emxEnsureCapacity_real32_T(sp, dists, i0, &emlrtRTEI);
          for (i0 = 0; i0 <= xpageoffset; i0++) {
            dists->data[i0] /= 1000.0F;
          }

          /*  Display the detected people and their distances. */
          /*  Bound the number of the bounding boxes and distances using */
          /*  asserts, because insertObjectAnnotation requires inputs to have  */
          /*  bounded sizes. */
          if (!(bboxes->size[0] < 100)) {
            emlrtErrorWithMessageIdR2018a(sp, &ge_emlrtRTEI,
              "Coder:builtins:AssertionFailed", "Coder:builtins:AssertionFailed",
              0);
          }

          if (!(dists->size[1] < 100)) {
            emlrtErrorWithMessageIdR2018a(sp, &he_emlrtRTEI,
              "Coder:builtins:AssertionFailed", "Coder:builtins:AssertionFailed",
              0);
          }

          nx = dists->size[1];
          xpageoffset = dists->size[0] * dists->size[1];
          for (i0 = 0; i0 < xpageoffset; i0++) {
            tmp_data[i0] = muSingleScalarIsNaN(dists->data[i0]);
          }

          nx--;
          xpageoffset = 0;
          for (k = 0; k <= nx; k++) {
            if (tmp_data[k]) {
              xpageoffset++;
            }
          }

          partialTrueCount = 0;
          for (k = 0; k <= nx; k++) {
            if (tmp_data[k]) {
              b_tmp_data[partialTrueCount] = k + 1;
              partialTrueCount++;
            }
          }

          xpageoffset--;
          nx = dists->size[1];
          for (i0 = 0; i0 <= xpageoffset; i0++) {
            if (!((b_tmp_data[i0] >= 1) && (b_tmp_data[i0] <= nx))) {
              emlrtDynamicBoundsCheckR2012b(b_tmp_data[i0], 1, nx, &f_emlrtBCI,
                sp);
            }

            dists->data[b_tmp_data[i0] - 1] = 0.0F;
          }

          st.site = &r_emlrtRSI;
          memcpy(&SD->f5.RGB[0], &SD->f5.dispFrame[0], 1108698U * sizeof(uint8_T));
          label_size[0] = 1;
          label_size[1] = dists->size[1];
          xpageoffset = dists->size[0] * dists->size[1];
          for (i0 = 0; i0 < xpageoffset; i0++) {
            label_data[i0] = dists->data[i0];
          }

          b_st.site = &xp_emlrtRSI;
          validateAndParseInputs(&b_st, bboxes->data, bboxes->size, label_data,
            label_size, position_data, siz, color_data, color_size,
            textColor_data, textColor_size, &overflow);
          memcpy(&SD->f5.dispFrame[0], &SD->f5.RGB[0], 1108698U * sizeof(uint8_T));
          if (!overflow) {
            b_st.site = &xp_emlrtRSI;
            insertShape(SD, &b_st, SD->f5.RGB, position_data, siz, color_data,
                        color_size, SD->f5.dispFrame);
            b_st.site = &xp_emlrtRSI;
            getTextLocAndWidth(&b_st, position_data, siz, textLocAndWidth_data,
                               textLocAndWidth_size);
            xpageoffset = textLocAndWidth_size[0];
            b_textLocAndWidth_size[0] = textLocAndWidth_size[0];
            b_textLocAndWidth_size[1] = 2;
            for (i0 = 0; i0 < 2; i0++) {
              for (i1 = 0; i1 < xpageoffset; i1++) {
                b_textLocAndWidth_data[i1 + xpageoffset * i0] =
                  textLocAndWidth_data[i1 + textLocAndWidth_size[0] * i0];
              }
            }

            xpageoffset = textLocAndWidth_size[0];
            c_textLocAndWidth_size[0] = textLocAndWidth_size[0];
            for (i0 = 0; i0 < xpageoffset; i0++) {
              c_textLocAndWidth_data[i0] = textLocAndWidth_data[i0 +
                (textLocAndWidth_size[0] << 1)];
            }

            xpageoffset = textLocAndWidth_size[0];
            d_textLocAndWidth_size[0] = textLocAndWidth_size[0];
            for (i0 = 0; i0 < xpageoffset; i0++) {
              d_textLocAndWidth_data[i0] = textLocAndWidth_data[i0 +
                textLocAndWidth_size[0] * 3];
            }

            memcpy(&SD->f5.RGB[0], &SD->f5.dispFrame[0], 1108698U * sizeof
                   (uint8_T));
            b_st.site = &xp_emlrtRSI;
            insertText(&b_st, SD->f5.RGB, b_textLocAndWidth_data,
                       b_textLocAndWidth_size, label_data, label_size,
                       textColor_data, textColor_size, color_data, color_size,
                       c_textLocAndWidth_data, c_textLocAndWidth_size,
                       d_textLocAndWidth_data, d_textLocAndWidth_size,
                       SD->f5.dispFrame);
          }
        }

        /*  Display the frame. */
        st.site = &s_emlrtRSI;
        obj = &player;
        if (player.isInitialized == 2) {
          emlrtErrorWithMessageIdR2018a(&st, &oe_emlrtRTEI,
            "MATLAB:system:methodCalledWhenReleasedCodegen",
            "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
        }

        if (player.isInitialized != 1) {
          b_st.site = &ud_emlrtRSI;
          c_st.site = &ud_emlrtRSI;
          player.isSetupComplete = false;
          if (player.isInitialized != 0) {
            emlrtErrorWithMessageIdR2018a(&c_st, &oe_emlrtRTEI,
              "MATLAB:system:methodCalledWhenLockedReleasedCodegen",
              "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5,
              "setup");
          }

          player.isInitialized = 1;
          d_st.site = &ud_emlrtRSI;
          e_st.site = &rd_emlrtRSI;
          f_st.site = NULL;

          /* System object Start function: vision.DeployableVideoPlayer */
          sErr = GetErrorBuffer(&obj->cSFunObject.W0_ToVideoDevice[0U]);
          CreateHostLibrary("tovideodevice.dll",
                            &obj->cSFunObject.W0_ToVideoDevice[0U]);
          if (*sErr == 0) {
            createVideoInfo(&obj->cSFunObject.W2_VideoInfo[0U], 1U, 1.0, 1.0,
                            "RGB ", 1, 3, 719, 514, 0U, 3, 1, NULL);
            LibCreate_Video(&obj->cSFunObject.W0_ToVideoDevice[0U], 0,
                            "SCOMP00000001E694C2C03", "Deployable Video Player",
                            0U, &obj->cSFunObject.W2_VideoInfo[0U], 1U, 20, -50,
                            0U, 719, 514, 0, 0U, 0U);
          }

          if (*sErr == 0) {
            LibStart(&obj->cSFunObject.W0_ToVideoDevice[0U]);
          }

          if (*sErr != 0) {
            DestroyHostLibrary(&obj->cSFunObject.W0_ToVideoDevice[0U]);
            if (*sErr != 0) {
              PrintError(sErr);
            }
          }

          player.isSetupComplete = true;
        }

        b_st.site = &ud_emlrtRSI;
        c_st.site = &vd_emlrtRSI;
        d_st.site = &rd_emlrtRSI;
        e_st.site = NULL;
        memcpy(&SD->f5.U0[0], &SD->f5.dispFrame[0], 1108698U * sizeof(uint8_T));

        /* System object Update function: vision.DeployableVideoPlayer */
        sErr = GetErrorBuffer(&obj->cSFunObject.W0_ToVideoDevice[0U]);
        LibUpdate_Video(&obj->cSFunObject.W0_ToVideoDevice[0U], &SD->f5.U0[0U],
                        GetNullPointer(), GetNullPointer(), 719, 514);
        if (*sErr != 0) {
          PrintError(sErr);
        }

        if (*emlrtBreakCheckR2012bFlagVar != 0) {
          emlrtBreakCheckR2012b(sp);
        }
      } else {
        exitg1 = 1;
      }
    } else {
      exitg1 = 1;
    }
  } while (exitg1 == 0);

  emxFree_real32_T(sp, &c_point3D);
  emxFree_real32_T(sp, &b_point3D);
  emxFree_real_T(sp, &b_bboxes);
  emxFree_real32_T(sp, &z);
  emxFree_real_T(sp, &varargin_2);
  emxFree_real_T(sp, &varargin_1);
  emxFree_real_T(sp, &r0);
  emxFree_uint8_T(sp, &frameRightRect);
  emxFree_uint8_T(sp, &frameLeftRect);
  emxFree_real32_T(sp, &dists);
  emxFree_real32_T(sp, &centroids3D);
  emxFree_real_T(sp, &centroidsIdx);
  emxFree_real_T(sp, &centroids);
  emxFree_real_T(sp, &bboxes);
  emxFree_real32_T(sp, &point3D);
  emxFree_real32_T(sp, &disparityMap);
  emxFree_uint8_T(sp, &frameRightGray);
  emxFree_uint8_T(sp, &frameLeftGray);

  /*  Clean up. */
  st.site = &t_emlrtRSI;
  if (readerLeft.S0_isInitialized == 2) {
    emlrtErrorWithMessageIdR2018a(&st, &ie_emlrtRTEI,
      "MATLAB:system:runtimeMethodCalledWhenReleasedCodegen",
      "MATLAB:system:runtimeMethodCalledWhenReleasedCodegen", 0);
  }

  b_st.site = NULL;
  if (readerLeft.S0_isInitialized == 1) {
    c_st.site = NULL;
    InitializeConditions(&readerLeft);
  }

  st.site = &u_emlrtRSI;
  if (readerRight.S0_isInitialized == 2) {
    emlrtErrorWithMessageIdR2018a(&st, &ie_emlrtRTEI,
      "MATLAB:system:runtimeMethodCalledWhenReleasedCodegen",
      "MATLAB:system:runtimeMethodCalledWhenReleasedCodegen", 0);
  }

  b_st.site = NULL;
  if (readerRight.S0_isInitialized == 1) {
    c_st.site = NULL;
    InitializeConditions(&readerRight);
  }

  st.site = &v_emlrtRSI;
  obj = &player;
  if (player.isInitialized == 1) {
    player.isInitialized = 2;
    b_st.site = &ud_emlrtRSI;
    if (player.isSetupComplete) {
      c_st.site = &ud_emlrtRSI;
      d_st.site = &rd_emlrtRSI;
      e_st.site = NULL;

      /* System object Destructor function: vision.DeployableVideoPlayer */
      f_st.site = NULL;

      /* System object Terminate function: vision.DeployableVideoPlayer */
      sErr = GetErrorBuffer(&obj->cSFunObject.W0_ToVideoDevice[0U]);
      LibTerminate(&obj->cSFunObject.W0_ToVideoDevice[0U]);
      if (*sErr != 0) {
        PrintError(sErr);
      }

      LibDestroy(&obj->cSFunObject.W0_ToVideoDevice[0U], 0);
      DestroyHostLibrary(&obj->cSFunObject.W0_ToVideoDevice[0U]);
    }
  }

  /*  References */
  /*  [1] G. Bradski and A. Kaehler, "Learning OpenCV : Computer Vision with */
  /*  the OpenCV Library," O'Reilly, Sebastopol, CA, 2008. */
  /*  */
  /*  [2] Dalal, N. and Triggs, B., Histograms of Oriented Gradients for */
  /*  Human Detection. CVPR 2005. */
  st.site = &emlrtRSI;

  /* System object Destructor function: vision.VideoFileReader */
  if (readerLeft.S0_isInitialized == 1) {
    readerLeft.S0_isInitialized = 2;
    b_st.site = NULL;

    /* System object Terminate function: vision.VideoFileReader */
    sErr = GetErrorBuffer(&readerLeft.W0_HostLib[0U]);
    LibTerminate(&readerLeft.W0_HostLib[0U]);
    if (*sErr != 0) {
      PrintError(sErr);
    }

    LibDestroy(&readerLeft.W0_HostLib[0U], 0);
    DestroyHostLibrary(&readerLeft.W0_HostLib[0U]);
  }

  st.site = &b_emlrtRSI;

  /* System object Destructor function: vision.VideoFileReader */
  if (readerRight.S0_isInitialized == 1) {
    readerRight.S0_isInitialized = 2;
    b_st.site = NULL;

    /* System object Terminate function: vision.VideoFileReader */
    sErr = GetErrorBuffer(&readerRight.W0_HostLib[0U]);
    LibTerminate(&readerRight.W0_HostLib[0U]);
    if (*sErr != 0) {
      PrintError(sErr);
    }

    LibDestroy(&readerRight.W0_HostLib[0U], 0);
    DestroyHostLibrary(&readerRight.W0_HostLib[0U]);
  }

  st.site = &c_emlrtRSI;
  c_matlabCodegenHandle_matlabCod(&st, &player);
  st.site = &d_emlrtRSI;
  d_matlabCodegenHandle_matlabCod(&st, &peopleDetector);
  d_emxFreeStruct_vision_internal(sp, &stereoParams);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (depthEstimationFromStereoVideo_kernel.c) */
