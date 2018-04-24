/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * padarray.c
 *
 * Code generation for function 'padarray'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "padarray.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "repmat.h"
#include "eml_int_forloop_overflow_check.h"
#include "matlabCodegenHandle.h"
#include "bwtraceboundary.h"
#include "assertValidSizeArg.h"
#include "depthEstimationFromStereoVideo_kernel_mexutil.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo ak_emlrtRSI = { 66, /* lineNo */
  "padarray",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m"/* pathName */
};

static emlrtRSInfo bk_emlrtRSI = { 72, /* lineNo */
  "padarray",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m"/* pathName */
};

static emlrtRSInfo dk_emlrtRSI = { 405,/* lineNo */
  "padarray",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m"/* pathName */
};

static emlrtRSInfo ek_emlrtRSI = { 420,/* lineNo */
  "padarray",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m"/* pathName */
};

static emlrtRSInfo un_emlrtRSI = { 434,/* lineNo */
  "padarray",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m"/* pathName */
};

static emlrtRTEInfo dc_emlrtRTEI = { 72,/* lineNo */
  13,                                  /* colNo */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m"/* pName */
};

static emlrtRTEInfo dd_emlrtRTEI = { 1,/* lineNo */
  14,                                  /* colNo */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m"/* pName */
};

static emlrtDCInfo h_emlrtDCI = { 251, /* lineNo */
  35,                                  /* colNo */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  1                                    /* checkKind */
};

static emlrtBCInfo jb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  444,                                 /* lineNo */
  102,                                 /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo kb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  444,                                 /* lineNo */
  104,                                 /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo lb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  444,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo mb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  444,                                 /* lineNo */
  58,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo nb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  421,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ob_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  421,                                 /* lineNo */
  21,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo pb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  414,                                 /* lineNo */
  21,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo qb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  407,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo rb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  407,                                 /* lineNo */
  21,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo sb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  400,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo je_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  435,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ke_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  450,                                 /* lineNo */
  28,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo le_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  450,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo me_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  429,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "padarray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\padarray.m",/* pName */
  0                                    /* checkKind */
};

/* Function Definitions */
void b_padarray(const emlrtStack *sp, const emxArray_real_T *varargin_1,
                emxArray_real_T *b)
{
  int32_T i38;
  real_T b_varargin_1[2];
  int32_T i;
  const mxArray *y;
  const mxArray *m6;
  static const int32_T iv22[2] = { 1, 15 };

  int32_T j;
  int32_T b_b;
  boolean_T overflow;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  if (varargin_1->size[0] == 0) {
    st.site = &ak_emlrtRSI;
    b_varargin_1[0] = (int8_T)varargin_1->size[0];
    b_varargin_1[1] = 3.0;
    b_st.site = &ck_emlrtRSI;
    assertValidSizeArg(&b_st, b_varargin_1);
    if (!(b_varargin_1[0] == b_varargin_1[0])) {
      y = NULL;
      m6 = emlrtCreateCharArray(2, iv22);
      emlrtInitCharArrayR2013a(&st, 15, m6, &cv1[0]);
      emlrtAssign(&y, m6);
      b_st.site = &qs_emlrtRSI;
      f_error(&b_st, y, &d_emlrtMCI);
    }

    i38 = b->size[0] * b->size[1];
    b->size[0] = (int32_T)b_varargin_1[0];
    b->size[1] = 3;
    emxEnsureCapacity_real_T1(&st, b, i38, &dd_emlrtRTEI);
    j = (int32_T)b_varargin_1[0] * 3;
    for (i38 = 0; i38 < j; i38++) {
      b->data[i38] = 1.0;
    }
  } else {
    st.site = &bk_emlrtRSI;
    i38 = b->size[0] * b->size[1];
    b->size[0] = varargin_1->size[0];
    b->size[1] = 3;
    emxEnsureCapacity_real_T1(&st, b, i38, &dc_emlrtRTEI);
    i38 = b->size[0];
    for (i = 0; i < i38; i++) {
      j = b->size[0];
      if (!((i + 1 >= 1) && (i + 1 <= j))) {
        emlrtDynamicBoundsCheckR2012b(i + 1, 1, j, &me_emlrtBCI, &st);
      }

      b->data[i + (b->size[0] << 1)] = 1.0;
    }

    for (j = 0; j < 2; j++) {
      b_b = b->size[0];
      b_st.site = &un_emlrtRSI;
      overflow = ((!(varargin_1->size[0] + 1 > b->size[0])) && (b->size[0] >
        2147483646));
      if (overflow) {
        c_st.site = &lb_emlrtRSI;
        check_forloop_overflow_error(&c_st);
      }

      for (i = varargin_1->size[0] + 1; i <= b_b; i++) {
        i38 = b->size[0];
        if (!((i >= 1) && (i <= i38))) {
          emlrtDynamicBoundsCheckR2012b(i, 1, i38, &je_emlrtBCI, &st);
        }

        b->data[(i + b->size[0] * j) - 1] = 1.0;
      }
    }

    for (j = 0; j < 2; j++) {
      for (i = 1; i - 1 < varargin_1->size[0]; i++) {
        i38 = varargin_1->size[0];
        if (!((i >= 1) && (i <= i38))) {
          emlrtDynamicBoundsCheckR2012b(i, 1, i38, &ke_emlrtBCI, &st);
        }

        i38 = b->size[0];
        if (!((i >= 1) && (i <= i38))) {
          emlrtDynamicBoundsCheckR2012b(i, 1, i38, &le_emlrtBCI, &st);
        }

        b->data[(i + b->size[0] * j) - 1] = varargin_1->data[(i +
          varargin_1->size[0] * j) - 1];
      }
    }
  }
}

void padarray(const emlrtStack *sp, const emxArray_boolean_T *varargin_1,
              emxArray_boolean_T *b)
{
  int32_T i27;
  real_T sizeB[2];
  uint32_T b_sizeB[2];
  real_T d0;
  int32_T i;
  int32_T b_b;
  int32_T i28;
  boolean_T overflow;
  int32_T j;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  if ((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0)) {
    for (i27 = 0; i27 < 2; i27++) {
      b_sizeB[i27] = varargin_1->size[i27] + 2U;
    }

    sizeB[0] = b_sizeB[0];
    sizeB[1] = b_sizeB[1];
    st.site = &ak_emlrtRSI;
    repmat(&st, sizeB, b);
  } else {
    st.site = &bk_emlrtRSI;
    for (i27 = 0; i27 < 2; i27++) {
      d0 = (real_T)varargin_1->size[i27] + 2.0;
      if (d0 != (int32_T)d0) {
        emlrtIntegerCheckR2012b(d0, &h_emlrtDCI, &st);
      }

      b_sizeB[i27] = (uint32_T)d0;
    }

    i27 = b->size[0] * b->size[1];
    b->size[0] = (int32_T)b_sizeB[0];
    b->size[1] = (int32_T)b_sizeB[1];
    emxEnsureCapacity_boolean_T1(&st, b, i27, &dc_emlrtRTEI);
    i27 = b->size[0];
    for (i = 0; i < i27; i++) {
      i28 = b->size[0];
      if (!((i + 1 >= 1) && (i + 1 <= i28))) {
        emlrtDynamicBoundsCheckR2012b(i + 1, 1, i28, &sb_emlrtBCI, &st);
      }

      b->data[i] = false;
    }

    b_b = b->size[1];
    b_st.site = &dk_emlrtRSI;
    overflow = ((!(varargin_1->size[1] + 2 > b->size[1])) && (b->size[1] >
      2147483646));
    if (overflow) {
      c_st.site = &lb_emlrtRSI;
      check_forloop_overflow_error(&c_st);
    }

    for (j = varargin_1->size[1] + 2; j <= b_b; j++) {
      i27 = b->size[0];
      for (i = 0; i < i27; i++) {
        i28 = b->size[0];
        if (!((i + 1 >= 1) && (i + 1 <= i28))) {
          emlrtDynamicBoundsCheckR2012b(i + 1, 1, i28, &qb_emlrtBCI, &st);
        }

        i28 = b->size[1];
        if (!((j >= 1) && (j <= i28))) {
          emlrtDynamicBoundsCheckR2012b(j, 1, i28, &rb_emlrtBCI, &st);
        }

        b->data[i + b->size[0] * (j - 1)] = false;
      }
    }

    for (j = 0; j < varargin_1->size[1]; j++) {
      i27 = b->size[1];
      if (!((j + 2 >= 1) && (j + 2 <= i27))) {
        emlrtDynamicBoundsCheckR2012b(j + 2, 1, i27, &pb_emlrtBCI, &st);
      }

      b->data[b->size[0] * (j + 1)] = false;
    }

    for (j = 0; j < varargin_1->size[1]; j++) {
      b_b = b->size[0];
      b_st.site = &ek_emlrtRSI;
      overflow = ((!(varargin_1->size[0] + 2 > b->size[0])) && (b->size[0] >
        2147483646));
      if (overflow) {
        c_st.site = &lb_emlrtRSI;
        check_forloop_overflow_error(&c_st);
      }

      for (i = varargin_1->size[0] + 2; i <= b_b; i++) {
        i27 = b->size[0];
        if (!((i >= 1) && (i <= i27))) {
          emlrtDynamicBoundsCheckR2012b(i, 1, i27, &nb_emlrtBCI, &st);
        }

        i27 = b->size[1];
        if (!((j + 2 >= 1) && (j + 2 <= i27))) {
          emlrtDynamicBoundsCheckR2012b(j + 2, 1, i27, &ob_emlrtBCI, &st);
        }

        b->data[(i + b->size[0] * (j + 1)) - 1] = false;
      }
    }

    for (j = 0; j < varargin_1->size[1]; j++) {
      for (i = 0; i < varargin_1->size[0]; i++) {
        i27 = varargin_1->size[0];
        if (!((i + 1 >= 1) && (i + 1 <= i27))) {
          emlrtDynamicBoundsCheckR2012b(i + 1, 1, i27, &jb_emlrtBCI, &st);
        }

        i27 = varargin_1->size[1];
        if (!((j + 1 >= 1) && (j + 1 <= i27))) {
          emlrtDynamicBoundsCheckR2012b(j + 1, 1, i27, &kb_emlrtBCI, &st);
        }

        i27 = b->size[0];
        if (!((i + 2 >= 1) && (i + 2 <= i27))) {
          emlrtDynamicBoundsCheckR2012b(i + 2, 1, i27, &lb_emlrtBCI, &st);
        }

        i27 = b->size[1];
        if (!((j + 2 >= 1) && (j + 2 <= i27))) {
          emlrtDynamicBoundsCheckR2012b(j + 2, 1, i27, &mb_emlrtBCI, &st);
        }

        b->data[(i + b->size[0] * (j + 1)) + 1] = varargin_1->data[i +
          varargin_1->size[0] * j];
      }
    }
  }
}

/* End of code generation (padarray.c) */
