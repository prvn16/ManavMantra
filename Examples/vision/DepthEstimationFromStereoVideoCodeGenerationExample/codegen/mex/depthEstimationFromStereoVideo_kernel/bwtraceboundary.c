/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * bwtraceboundary.c
 *
 * Code generation for function 'bwtraceboundary'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "bwtraceboundary.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "matlabCodegenHandle.h"
#include "mod1.h"
#include "mod.h"
#include "padarray.h"
#include "all.h"
#include "depthEstimationFromStereoVideo_kernel_mexutil.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo rj_emlrtRSI = { 8,  /* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

static emlrtRSInfo sj_emlrtRSI = { 10, /* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

static emlrtRSInfo tj_emlrtRSI = { 347,/* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

static emlrtRSInfo uj_emlrtRSI = { 359,/* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

static emlrtRSInfo vj_emlrtRSI = { 29, /* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

static emlrtRSInfo wj_emlrtRSI = { 105,/* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

static emlrtRSInfo xj_emlrtRSI = { 111,/* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

static emlrtRSInfo yj_emlrtRSI = { 112,/* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

static emlrtMCInfo e_emlrtMCI = { 231, /* lineNo */
  1,                                   /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pName */
};

static emlrtRTEInfo yb_emlrtRTEI = { 1,/* lineNo */
  14,                                  /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pName */
};

static emlrtRTEInfo ac_emlrtRTEI = { 112,/* lineNo */
  9,                                   /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pName */
};

static emlrtRTEInfo bc_emlrtRTEI = { 29,/* lineNo */
  1,                                   /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pName */
};

static emlrtRTEInfo cc_emlrtRTEI = { 244,/* lineNo */
  1,                                   /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pName */
};

static emlrtRTEInfo lf_emlrtRTEI = { 26,/* lineNo */
  1,                                   /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pName */
};

static emlrtRTEInfo mf_emlrtRTEI = { 119,/* lineNo */
  1,                                   /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pName */
};

static emlrtDCInfo e_emlrtDCI = { 197, /* lineNo */
  33,                                  /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  1                                    /* checkKind */
};

static emlrtRTEInfo nf_emlrtRTEI = { 316,/* lineNo */
  11,                                  /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pName */
};

static emlrtBCInfo u_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  317,                                 /* lineNo */
  34,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo v_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  318,                                 /* lineNo */
  47,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo w_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  129,                                 /* lineNo */
  15,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo x_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  138,                                 /* lineNo */
  24,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo y_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  198,                                 /* lineNo */
  24,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ab_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  249,                                 /* lineNo */
  12,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo f_emlrtDCI = { 315, /* lineNo */
  33,                                  /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  1                                    /* checkKind */
};

static emlrtBCInfo bb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  317,                                 /* lineNo */
  14,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo cb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  318,                                 /* lineNo */
  14,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo db_emlrtBCI = { 1,  /* iFirst */
  8,                                   /* iLast */
  262,                                 /* lineNo */
  44,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo g_emlrtDCI = { 262, /* lineNo */
  44,                                  /* colNo */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  1                                    /* checkKind */
};

static emlrtBCInfo eb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  264,                                 /* lineNo */
  23,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo fb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  266,                                 /* lineNo */
  28,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo gb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  271,                                 /* lineNo */
  32,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo hb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  294,                                 /* lineNo */
  27,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ib_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  295,                                 /* lineNo */
  28,                                  /* colNo */
  "",                                  /* aName */
  "bwtraceboundary",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRSInfo rs_emlrtRSI = { 231,/* lineNo */
  "bwtraceboundary",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwtraceboundary.m"/* pathName */
};

/* Function Definitions */
void bwtraceboundary(const emlrtStack *sp, const emxArray_uint8_T *varargin_1,
                     const real_T varargin_2[2], emxArray_real_T *B)
{
  emxArray_boolean_T *BW;
  int32_T i25;
  int32_T loop_ub;
  boolean_T tf;
  boolean_T exitg1;
  int32_T numRows;
  real_T maxNumPoints;
  emxArray_uint8_T *bwPadImage;
  emxArray_boolean_T *r21;
  real_T idx;
  real_T fOffsets[8];
  real_T fVOffsets[8];
  int32_T i26;
  real_T fNextSearchDir;
  real_T currentCircIdx;
  real_T checkDir;
  emxArray_real_T *boundary;
  const mxArray *y;
  emxArray_real_T *fScratch;
  const mxArray *m3;
  static const int32_T iv13[2] = { 1, 42 };

  static const char_T u[42] = { 'U', 'n', 'a', 'b', 'l', 'e', ' ', 't', 'o', ' ',
    'd', 'e', 't', 'e', 'r', 'm', 'i', 'n', 'e', ' ', 'v', 'a', 'l', 'i', 'd',
    ' ', 's', 'e', 'a', 'r', 'c', 'h', ' ', 'd', 'i', 'r', 'e', 'c', 't', 'i',
    'o', 'n' };

  int32_T initDepartureDir;
  emxArray_real_T *b_fScratch;
  boolean_T foundNextPixel;
  boolean_T guard1 = false;
  static const int8_T iv14[8] = { 8, 8, 2, 2, 4, 4, 6, 6 };

  real_T neighbor;
  static const int8_T iv15[8] = { 2, 3, 4, 5, 6, 7, 8, 1 };

  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &rj_emlrtRSI;
  b_st.site = &tj_emlrtRSI;
  c_st.site = &ic_emlrtRSI;
  if ((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0)) {
    emlrtErrorWithMessageIdR2018a(&c_st, &kf_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonempty",
      "MATLAB:bwtraceboundary:expectedNonempty", 3, 4, 19, "input number 1, BW,");
  }

  emxInit_boolean_T1(&c_st, &BW, 2, &yb_emlrtRTEI, true);
  i25 = BW->size[0] * BW->size[1];
  BW->size[0] = varargin_1->size[0];
  BW->size[1] = varargin_1->size[1];
  emxEnsureCapacity_boolean_T1(&st, BW, i25, &yb_emlrtRTEI);
  loop_ub = varargin_1->size[0] * varargin_1->size[1];
  for (i25 = 0; i25 < loop_ub; i25++) {
    BW->data[i25] = (varargin_1->data[i25] != 0);
  }

  b_st.site = &uj_emlrtRSI;
  c_st.site = &ic_emlrtRSI;
  if (!all(varargin_2)) {
    emlrtErrorWithMessageIdR2018a(&c_st, &se_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedInteger",
      "MATLAB:bwtraceboundary:expectedInteger", 3, 4, 18, "input number 2, P,");
  }

  c_st.site = &ic_emlrtRSI;
  tf = true;
  loop_ub = 0;
  exitg1 = false;
  while ((!exitg1) && (loop_ub < 2)) {
    if (!(varargin_2[loop_ub] <= 0.0)) {
      loop_ub++;
    } else {
      tf = false;
      exitg1 = true;
    }
  }

  if (!tf) {
    emlrtErrorWithMessageIdR2018a(&c_st, &te_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedPositive",
      "MATLAB:bwtraceboundary:expectedPositive", 3, 4, 18, "input number 2, P,");
  }

  st.site = &sj_emlrtRSI;
  numRows = BW->size[0];
  maxNumPoints = 2.0 * (real_T)BW->size[0] * (real_T)BW->size[1] + 2.0;
  if ((varargin_2[0] > BW->size[0]) || (varargin_2[1] > BW->size[1])) {
    emlrtErrorWithMessageIdR2018a(&st, &lf_emlrtRTEI,
      "images:bwtraceboundary:codegenStartingOutsideBW",
      "images:bwtraceboundary:codegenStartingOutsideBW", 0);
  }

  emxInit_uint8_T(&st, &bwPadImage, 2, &bc_emlrtRTEI, true);
  emxInit_boolean_T1(&st, &r21, 2, &yb_emlrtRTEI, true);
  b_st.site = &vj_emlrtRSI;
  padarray(&b_st, BW, r21);
  i25 = bwPadImage->size[0] * bwPadImage->size[1];
  bwPadImage->size[0] = r21->size[0];
  bwPadImage->size[1] = r21->size[1];
  emxEnsureCapacity_uint8_T(&st, bwPadImage, i25, &yb_emlrtRTEI);
  loop_ub = r21->size[0] * r21->size[1];
  for (i25 = 0; i25 < loop_ub; i25++) {
    bwPadImage->data[i25] = r21->data[i25];
  }

  emxFree_boolean_T(&st, &r21);
  idx = (varargin_2[1] * ((real_T)BW->size[0] + 2.0) + varargin_2[0]) + 1.0;
  fOffsets[0] = -1.0;
  fOffsets[1] = ((real_T)BW->size[0] + 2.0) - 1.0;
  fOffsets[2] = (real_T)BW->size[0] + 2.0;
  fOffsets[3] = ((real_T)BW->size[0] + 2.0) + 1.0;
  fOffsets[4] = 1.0;
  fOffsets[5] = -((real_T)BW->size[0] + 2.0) + 1.0;
  fOffsets[6] = -((real_T)BW->size[0] + 2.0);
  fOffsets[7] = -((real_T)BW->size[0] + 2.0) - 1.0;
  fVOffsets[0] = -1.0;
  fVOffsets[1] = (real_T)BW->size[0] + 2.0;
  fVOffsets[2] = 1.0;
  fVOffsets[3] = -((real_T)BW->size[0] + 2.0);
  b_st.site = &wj_emlrtRSI;
  tf = false;
  i25 = bwPadImage->size[0] * bwPadImage->size[1];
  i26 = (int32_T)idx;
  if (!((i26 >= 1) && (i26 <= i25))) {
    emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &w_emlrtBCI, &b_st);
  }

  if ((int8_T)bwPadImage->data[i26 - 1] != 0) {
    loop_ub = 0;
    exitg1 = false;
    while ((!exitg1) && (loop_ub <= 3)) {
      i25 = bwPadImage->size[0] * bwPadImage->size[1];
      i26 = (int32_T)(idx + fVOffsets[loop_ub]);
      if (!((i26 >= 1) && (i26 <= i25))) {
        emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &x_emlrtBCI, &b_st);
      }

      if (!((int8_T)bwPadImage->data[i26 - 1] != 0)) {
        tf = true;
        exitg1 = true;
      } else {
        loop_ub++;
      }
    }
  }

  if (tf) {
    b_st.site = &xj_emlrtRSI;
    tf = false;
    fNextSearchDir = 0.0;
    loop_ub = 0;
    exitg1 = false;
    while ((!exitg1) && (loop_ub <= 7)) {
      currentCircIdx = b_mod(6.0 + (real_T)loop_ub);
      checkDir = currentCircIdx + -1.0;
      if (currentCircIdx + -1.0 < 0.0) {
        checkDir = 7.0;
      }

      checkDir = b_mod(checkDir);
      if (checkDir + 1.0 != (int32_T)muDoubleScalarFloor(checkDir + 1.0)) {
        emlrtIntegerCheckR2012b(checkDir + 1.0, &e_emlrtDCI, &b_st);
      }

      i25 = bwPadImage->size[0] * bwPadImage->size[1];
      i26 = (int32_T)(idx + fOffsets[(int32_T)(checkDir + 1.0) - 1]);
      if (!((i26 >= 1) && (i26 <= i25))) {
        emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &y_emlrtBCI, &b_st);
      }

      if ((int8_T)bwPadImage->data[i26 - 1] == 0) {
        tf = true;
        fNextSearchDir = currentCircIdx + 1.0;
        exitg1 = true;
      } else {
        loop_ub++;
      }
    }

    if (!tf) {
      y = NULL;
      m3 = emlrtCreateCharArray(2, iv13);
      emlrtInitCharArrayR2013a(&b_st, 42, m3, &u[0]);
      emlrtAssign(&y, m3);
      c_st.site = &rs_emlrtRSI;
      f_error(&c_st, y, &e_emlrtMCI);
    }

    emxInit_real_T(&b_st, &boundary, 2, &yb_emlrtRTEI, true);
    emxInit_real_T1(&b_st, &fScratch, 1, &cc_emlrtRTEI, true);
    b_st.site = &yj_emlrtRSI;
    currentCircIdx = 1.0;
    i25 = fScratch->size[0];
    fScratch->size[0] = 1;
    emxEnsureCapacity_real_T(&b_st, fScratch, i25, &yb_emlrtRTEI);
    fScratch->data[0] = idx;
    i25 = bwPadImage->size[0] * bwPadImage->size[1];
    i26 = (int32_T)idx;
    if (!((i26 >= 1) && (i26 <= i25))) {
      emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &ab_emlrtBCI, &b_st);
    }

    bwPadImage->data[i26 - 1] = 2U;
    tf = false;
    initDepartureDir = -1;
    emxInit_real_T1(&b_st, &b_fScratch, 1, &yb_emlrtRTEI, true);
    while (!tf) {
      checkDir = fNextSearchDir;
      foundNextPixel = false;
      loop_ub = 0;
      guard1 = false;
      exitg1 = false;
      while ((!exitg1) && (loop_ub < 8)) {
        if (checkDir != (int32_T)muDoubleScalarFloor(checkDir)) {
          emlrtIntegerCheckR2012b(checkDir, &g_emlrtDCI, &b_st);
        }

        i25 = (int32_T)checkDir;
        if (!((i25 >= 1) && (i25 <= 8))) {
          emlrtDynamicBoundsCheckR2012b(i25, 1, 8, &db_emlrtBCI, &b_st);
        }

        neighbor = idx + fOffsets[i25 - 1];
        i25 = bwPadImage->size[0] * bwPadImage->size[1];
        i26 = (int32_T)neighbor;
        if (!((i26 >= 1) && (i26 <= i25))) {
          emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &eb_emlrtBCI, &b_st);
        }

        if ((int8_T)bwPadImage->data[i26 - 1] != 0) {
          i25 = bwPadImage->size[0] * bwPadImage->size[1];
          i26 = (int32_T)idx;
          if (!((i26 >= 1) && (i26 <= i25))) {
            emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &fb_emlrtBCI, &b_st);
          }

          if (((int8_T)bwPadImage->data[i26 - 1] == 2) && (initDepartureDir ==
               -1)) {
            initDepartureDir = (int32_T)checkDir;
            guard1 = true;
          } else {
            i25 = bwPadImage->size[0] * bwPadImage->size[1];
            i26 = (int32_T)idx;
            if (!((i26 >= 1) && (i26 <= i25))) {
              emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &gb_emlrtBCI, &b_st);
            }

            if (((int8_T)bwPadImage->data[i26 - 1] == 2) && (initDepartureDir ==
                 (int32_T)checkDir)) {
              tf = true;
              foundNextPixel = true;
            } else {
              guard1 = true;
            }
          }

          exitg1 = true;
        } else {
          checkDir = iv15[(int32_T)checkDir - 1];
          loop_ub++;
          guard1 = false;
        }
      }

      if (guard1) {
        fNextSearchDir = iv14[(int32_T)checkDir - 1];
        foundNextPixel = true;
        currentCircIdx++;
        loop_ub = fScratch->size[0];
        i25 = fScratch->size[0];
        fScratch->size[0] = loop_ub + 1;
        emxEnsureCapacity_real_T(&b_st, fScratch, i25, &yb_emlrtRTEI);
        fScratch->data[loop_ub] = neighbor;
        if (currentCircIdx == maxNumPoints) {
          tf = true;
        } else {
          i25 = bwPadImage->size[0] * bwPadImage->size[1];
          i26 = (int32_T)neighbor;
          if (!((i26 >= 1) && (i26 <= i25))) {
            emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &hb_emlrtBCI, &b_st);
          }

          if ((int8_T)bwPadImage->data[i26 - 1] != 2) {
            i25 = bwPadImage->size[0] * bwPadImage->size[1];
            i26 = (int32_T)neighbor;
            if (!((i26 >= 1) && (i26 <= i25))) {
              emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &ib_emlrtBCI, &b_st);
            }

            bwPadImage->data[i26 - 1] = 3U;
          }

          idx = neighbor;
        }
      }

      if (!foundNextPixel) {
        currentCircIdx = 2.0;
        i25 = b_fScratch->size[0];
        b_fScratch->size[0] = fScratch->size[0] + fScratch->size[0];
        emxEnsureCapacity_real_T(&b_st, b_fScratch, i25, &yb_emlrtRTEI);
        loop_ub = fScratch->size[0];
        for (i25 = 0; i25 < loop_ub; i25++) {
          b_fScratch->data[i25] = fScratch->data[i25];
        }

        loop_ub = fScratch->size[0];
        for (i25 = 0; i25 < loop_ub; i25++) {
          b_fScratch->data[i25 + fScratch->size[0]] = fScratch->data[i25];
        }

        i25 = fScratch->size[0];
        fScratch->size[0] = b_fScratch->size[0];
        emxEnsureCapacity_real_T(&b_st, fScratch, i25, &yb_emlrtRTEI);
        loop_ub = b_fScratch->size[0];
        for (i25 = 0; i25 < loop_ub; i25++) {
          fScratch->data[i25] = b_fScratch->data[i25];
        }

        tf = true;
      }
    }

    emxFree_real_T(&b_st, &b_fScratch);
    i25 = boundary->size[0] * boundary->size[1];
    if (currentCircIdx != (int32_T)currentCircIdx) {
      emlrtIntegerCheckR2012b(currentCircIdx, &f_emlrtDCI, &b_st);
    }

    boundary->size[0] = (int32_T)currentCircIdx;
    boundary->size[1] = 2;
    emxEnsureCapacity_real_T1(&b_st, boundary, i25, &ac_emlrtRTEI);
    emlrtForLoopVectorCheckR2012b(1.0, 1.0, currentCircIdx, mxDOUBLE_CLASS,
      (int32_T)currentCircIdx, &nf_emlrtRTEI, &b_st);
    for (loop_ub = 0; loop_ub < (int32_T)currentCircIdx; loop_ub++) {
      i25 = fScratch->size[0];
      i26 = loop_ub + 1;
      if (!((i26 >= 1) && (i26 <= i25))) {
        emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &u_emlrtBCI, &b_st);
      }

      i25 = boundary->size[0] << 1;
      if (!((loop_ub + 1 >= 1) && (loop_ub + 1 <= i25))) {
        emlrtDynamicBoundsCheckR2012b(loop_ub + 1, 1, i25, &bb_emlrtBCI, &b_st);
      }

      boundary->data[loop_ub] = c_mod(fScratch->data[loop_ub] - 1.0, (real_T)
        numRows + 2.0);
      i25 = fScratch->size[0];
      i26 = loop_ub + 1;
      if (!((i26 >= 1) && (i26 <= i25))) {
        emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &v_emlrtBCI, &b_st);
      }

      i25 = boundary->size[0] << 1;
      i26 = (int32_T)(currentCircIdx + (1.0 + (real_T)loop_ub));
      if (!((i26 >= 1) && (i26 <= i25))) {
        emlrtDynamicBoundsCheckR2012b(i26, 1, i25, &cb_emlrtBCI, &b_st);
      }

      boundary->data[i26 - 1] = muDoubleScalarFloor((fScratch->data[loop_ub] -
        1.0) / ((real_T)numRows + 2.0));
    }

    emxFree_real_T(&b_st, &fScratch);
    i25 = B->size[0] * B->size[1];
    B->size[0] = boundary->size[0];
    B->size[1] = 2;
    emxEnsureCapacity_real_T1(&st, B, i25, &yb_emlrtRTEI);
    loop_ub = boundary->size[0] * boundary->size[1];
    for (i25 = 0; i25 < loop_ub; i25++) {
      B->data[i25] = boundary->data[i25];
    }

    emxFree_real_T(&st, &boundary);
  } else {
    i25 = B->size[0] * B->size[1];
    B->size[0] = 0;
    B->size[1] = 0;
    emxEnsureCapacity_real_T1(&st, B, i25, &yb_emlrtRTEI);
  }

  emxFree_uint8_T(&st, &bwPadImage);
  if (B->size[0] > 2.0 * (real_T)BW->size[0] * (real_T)BW->size[1] + 1.0) {
    emlrtErrorWithMessageIdR2018a(&st, &mf_emlrtRTEI,
      "images:bwtraceboundary:failedTrace", "images:bwtraceboundary:failedTrace",
      0);
  }

  emxFree_boolean_T(&st, &BW);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (bwtraceboundary.c) */
