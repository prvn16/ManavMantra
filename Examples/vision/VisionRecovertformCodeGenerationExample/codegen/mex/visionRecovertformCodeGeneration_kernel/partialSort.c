/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * partialSort.c
 *
 * Code generation for function 'partialSort'
 *
 */

/* Include files */
#include <math.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "partialSort.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "sub2ind.h"
#include "eml_int_forloop_overflow_check.h"
#include "sort1.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo od_emlrtRSI = { 23, /* lineNo */
  "partialSort",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pathName */
};

static emlrtRSInfo pd_emlrtRSI = { 27, /* lineNo */
  "partialSort",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pathName */
};

static emlrtRSInfo qd_emlrtRSI = { 28, /* lineNo */
  "partialSort",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pathName */
};

static emlrtRSInfo rd_emlrtRSI = { 39, /* lineNo */
  "partialSort",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pathName */
};

static emlrtRSInfo sd_emlrtRSI = { 27, /* lineNo */
  "log2",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\log2.m"/* pathName */
};

static emlrtRSInfo td_emlrtRSI = { 48, /* lineNo */
  "applyScalarFunction",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\applyScalarFunction.m"/* pathName */
};

static emlrtRSInfo ud_emlrtRSI = { 18, /* lineNo */
  "log2",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+scalar\\log2.m"/* pathName */
};

static emlrtRSInfo vd_emlrtRSI = { 55, /* lineNo */
  "log2",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+scalar\\log2.m"/* pathName */
};

static emlrtRSInfo wd_emlrtRSI = { 15, /* lineNo */
  "min",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\min.m"/* pathName */
};

static emlrtRSInfo xd_emlrtRSI = { 16, /* lineNo */
  "minOrMax",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pathName */
};

static emlrtRSInfo yd_emlrtRSI = { 47, /* lineNo */
  "minOrMax",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pathName */
};

static emlrtRSInfo ae_emlrtRSI = { 126,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo be_emlrtRSI = { 257,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo ce_emlrtRSI = { 329,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo de_emlrtRSI = { 432,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo ee_emlrtRSI = { 431,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo fe_emlrtRSI = { 428,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo ge_emlrtRSI = { 16, /* lineNo */
  "sub2ind",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\sub2ind.m"/* pathName */
};

static emlrtRSInfo he_emlrtRSI = { 39, /* lineNo */
  "sub2ind",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\sub2ind.m"/* pathName */
};

static emlrtRSInfo ie_emlrtRSI = { 71, /* lineNo */
  "sub2ind",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\sub2ind.m"/* pathName */
};

static emlrtRSInfo je_emlrtRSI = { 23, /* lineNo */
  "sort",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\sort.m"/* pathName */
};

static emlrtRTEInfo od_emlrtRTEI = { 15,/* lineNo */
  1,                                   /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo pd_emlrtRTEI = { 16,/* lineNo */
  1,                                   /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo qd_emlrtRTEI = { 19,/* lineNo */
  5,                                   /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo rd_emlrtRTEI = { 23,/* lineNo */
  6,                                   /* colNo */
  "sort",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\sort.m"/* pName */
};

static emlrtRTEInfo sd_emlrtRTEI = { 44,/* lineNo */
  1,                                   /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo td_emlrtRTEI = { 24,/* lineNo */
  5,                                   /* colNo */
  "sort",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\sort.m"/* pName */
};

static emlrtRTEInfo ud_emlrtRTEI = { 329,/* lineNo */
  9,                                   /* colNo */
  "unaryMinOrMax",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pName */
};

static emlrtRTEInfo vd_emlrtRTEI = { 422,/* lineNo */
  5,                                   /* colNo */
  "unaryMinOrMax",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pName */
};

static emlrtRTEInfo wd_emlrtRTEI = { 40,/* lineNo */
  5,                                   /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo xd_emlrtRTEI = { 41,/* lineNo */
  5,                                   /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo yd_emlrtRTEI = { 17,/* lineNo */
  5,                                   /* colNo */
  "minOrMax",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pName */
};

static emlrtRTEInfo ae_emlrtRTEI = { 27,/* lineNo */
  24,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo be_emlrtRTEI = { 27,/* lineNo */
  39,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo ce_emlrtRTEI = { 28,/* lineNo */
  37,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo de_emlrtRTEI = { 28,/* lineNo */
  51,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo ee_emlrtRTEI = { 29,/* lineNo */
  15,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo fe_emlrtRTEI = { 5,/* lineNo */
  30,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo ge_emlrtRTEI = { 5,/* lineNo */
  19,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtRTEInfo pi_emlrtRTEI = { 41,/* lineNo */
  19,                                  /* colNo */
  "sub2ind",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\sub2ind.m"/* pName */
};

static emlrtRTEInfo qi_emlrtRTEI = { 31,/* lineNo */
  23,                                  /* colNo */
  "sub2ind",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\sub2ind.m"/* pName */
};

static emlrtECInfo f_emlrtECI = { -1,  /* nDims */
  27,                                  /* lineNo */
  14,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtBCInfo bb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  27,                                  /* lineNo */
  21,                                  /* colNo */
  "",                                  /* aName */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo cb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  41,                                  /* lineNo */
  25,                                  /* colNo */
  "",                                  /* aName */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo db_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  41,                                  /* lineNo */
  23,                                  /* colNo */
  "",                                  /* aName */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo eb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  40,                                  /* lineNo */
  27,                                  /* colNo */
  "",                                  /* aName */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo fb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  40,                                  /* lineNo */
  25,                                  /* colNo */
  "",                                  /* aName */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo gb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  28,                                  /* lineNo */
  59,                                  /* colNo */
  "",                                  /* aName */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m",/* pName */
  0                                    /* checkKind */
};

static emlrtECInfo g_emlrtECI = { -1,  /* nDims */
  27,                                  /* lineNo */
  28,                                  /* colNo */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m"/* pName */
};

static emlrtBCInfo hb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  27,                                  /* lineNo */
  36,                                  /* colNo */
  "",                                  /* aName */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ib_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  29,                                  /* lineNo */
  15,                                  /* colNo */
  "",                                  /* aName */
  "partialSort",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\partialSort.m",/* pName */
  0                                    /* checkKind */
};

/* Function Definitions */
void partialSort(const emlrtStack *sp, emxArray_real32_T *x, emxArray_real32_T
                 *values, emxArray_uint32_T *indices)
{
  int32_T n;
  int32_T i10;
  int32_T loop_ub;
  emxArray_int32_T *b_indices;
  real_T f;
  int32_T eint;
  emxArray_real32_T *xSorted;
  int32_T i;
  emxArray_int32_T *r11;
  emxArray_int32_T *indx;
  emxArray_real32_T *ex;
  emxArray_int32_T *idx;
  emxArray_real_T *varargin_1;
  emxArray_real_T *varargin_2;
  emxArray_int32_T *c_indices;
  emxArray_int32_T *inds;
  emxArray_int32_T *iidx;
  int32_T m;
  uint32_T x_idx_0;
  int32_T j;
  boolean_T overflow;
  int32_T siz[2];
  uint32_T b_varargin_1[2];
  uint32_T b_varargin_2[2];
  boolean_T p;
  boolean_T exitg1;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
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
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  i_st.prev = &h_st;
  i_st.tls = h_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  n = 2;
  if (2 > x->size[1]) {
    n = x->size[1];
  }

  i10 = values->size[0] * values->size[1];
  values->size[0] = n;
  values->size[1] = x->size[0];
  emxEnsureCapacity_real32_T(sp, values, i10, &od_emlrtRTEI);
  loop_ub = n * x->size[0];
  for (i10 = 0; i10 < loop_ub; i10++) {
    values->data[i10] = 0.0F;
  }

  emxInit_int32_T1(sp, &b_indices, 2, &ge_emlrtRTEI, true);
  i10 = b_indices->size[0] * b_indices->size[1];
  b_indices->size[0] = n;
  b_indices->size[1] = x->size[0];
  emxEnsureCapacity_int32_T1(sp, b_indices, i10, &pd_emlrtRTEI);
  loop_ub = n * x->size[0];
  for (i10 = 0; i10 < loop_ub; i10++) {
    b_indices->data[i10] = 0;
  }

  if ((x->size[0] == 0) || (x->size[1] == 0)) {
    i10 = indices->size[0] * indices->size[1];
    indices->size[0] = n;
    indices->size[1] = x->size[0];
    emxEnsureCapacity_uint32_T(sp, indices, i10, &qd_emlrtRTEI);
    loop_ub = n * x->size[0];
    for (i10 = 0; i10 < loop_ub; i10++) {
      indices->data[i10] = 0U;
    }
  } else {
    st.site = &od_emlrtRSI;
    b_st.site = &sd_emlrtRSI;
    c_st.site = &td_emlrtRSI;
    d_st.site = &ud_emlrtRSI;
    e_st.site = &vd_emlrtRSI;
    f = frexp(x->size[1], &eint);
    if (f == 0.5) {
      f = (real_T)eint - 1.0;
    } else if ((eint == 1) && (f < 0.75)) {
      f = muDoubleScalarLog(2.0 * f) / 0.69314718055994529;
    } else {
      f = muDoubleScalarLog(f) / 0.69314718055994529 + (real_T)eint;
    }

    if (n < f) {
      i = 0;
      emxInit_int32_T1(sp, &r11, 2, &fe_emlrtRTEI, true);
      emxInit_int32_T(sp, &indx, 1, &fe_emlrtRTEI, true);
      emxInit_real32_T1(sp, &ex, 1, &fe_emlrtRTEI, true);
      emxInit_int32_T(sp, &idx, 1, &fe_emlrtRTEI, true);
      emxInit_real_T(sp, &varargin_1, 2, &ce_emlrtRTEI, true);
      emxInit_real_T(sp, &varargin_2, 2, &de_emlrtRTEI, true);
      emxInit_int32_T1(sp, &c_indices, 2, &de_emlrtRTEI, true);
      while (i <= n - 1) {
        st.site = &pd_emlrtRSI;
        b_st.site = &wd_emlrtRSI;
        c_st.site = &xd_emlrtRSI;
        d_st.site = &yd_emlrtRSI;
        e_st.site = &ae_emlrtRSI;
        f_st.site = &be_emlrtRSI;
        g_st.site = &ce_emlrtRSI;
        m = x->size[0];
        x_idx_0 = (uint32_T)x->size[0];
        i10 = ex->size[0];
        ex->size[0] = (int32_T)x_idx_0;
        emxEnsureCapacity_real32_T1(&g_st, ex, i10, &ud_emlrtRTEI);
        i10 = idx->size[0];
        idx->size[0] = x->size[0];
        emxEnsureCapacity_int32_T(&g_st, idx, i10, &vd_emlrtRTEI);
        loop_ub = x->size[0];
        for (i10 = 0; i10 < loop_ub; i10++) {
          idx->data[i10] = 1;
        }

        h_st.site = &fe_emlrtRSI;
        overflow = (x->size[0] > 2147483646);
        if (overflow) {
          i_st.site = &mb_emlrtRSI;
          check_forloop_overflow_error(&i_st);
        }

        for (eint = 0; eint < m; eint++) {
          ex->data[eint] = x->data[eint];
        }

        h_st.site = &ee_emlrtRSI;
        overflow = ((!(2 > x->size[1])) && (x->size[1] > 2147483646));
        if (overflow) {
          i_st.site = &mb_emlrtRSI;
          check_forloop_overflow_error(&i_st);
        }

        for (j = 1; j < x->size[1]; j++) {
          h_st.site = &de_emlrtRSI;
          for (eint = 0; eint < m; eint++) {
            overflow = ((!muSingleScalarIsNaN(x->data[eint + x->size[0] * j])) &&
                        (muSingleScalarIsNaN(ex->data[eint]) || (ex->data[eint] >
              x->data[eint + x->size[0] * j])));
            if (overflow) {
              ex->data[eint] = x->data[eint + x->size[0] * j];
              idx->data[eint] = j + 1;
            }
          }
        }

        i10 = indx->size[0];
        indx->size[0] = idx->size[0];
        emxEnsureCapacity_int32_T(&b_st, indx, i10, &yd_emlrtRTEI);
        loop_ub = idx->size[0];
        for (i10 = 0; i10 < loop_ub; i10++) {
          indx->data[i10] = idx->data[i10];
        }

        i10 = values->size[0];
        j = i + 1;
        if (!((j >= 1) && (j <= i10))) {
          emlrtDynamicBoundsCheckR2012b(j, 1, i10, &bb_emlrtBCI, sp);
        }

        loop_ub = values->size[1];
        i10 = idx->size[0];
        idx->size[0] = loop_ub;
        emxEnsureCapacity_int32_T(sp, idx, i10, &ae_emlrtRTEI);
        for (i10 = 0; i10 < loop_ub; i10++) {
          idx->data[i10] = i10;
        }

        siz[0] = 1;
        siz[1] = idx->size[0];
        emlrtSubAssignSizeCheckR2012b(&siz[0], 2, &(*(int32_T (*)[1])ex->size)[0],
          1, &f_emlrtECI, sp);
        eint = idx->size[0];
        for (i10 = 0; i10 < eint; i10++) {
          values->data[i + values->size[0] * idx->data[i10]] = ex->data[i10];
        }

        i10 = b_indices->size[0];
        j = i + 1;
        if (!((j >= 1) && (j <= i10))) {
          emlrtDynamicBoundsCheckR2012b(j, 1, i10, &hb_emlrtBCI, sp);
        }

        loop_ub = b_indices->size[1];
        i10 = idx->size[0];
        idx->size[0] = loop_ub;
        emxEnsureCapacity_int32_T(sp, idx, i10, &be_emlrtRTEI);
        for (i10 = 0; i10 < loop_ub; i10++) {
          idx->data[i10] = i10;
        }

        siz[0] = 1;
        siz[1] = idx->size[0];
        emlrtSubAssignSizeCheckR2012b(&siz[0], 2, &(*(int32_T (*)[1])indx->size)
          [0], 1, &g_emlrtECI, sp);
        eint = idx->size[0];
        for (i10 = 0; i10 < eint; i10++) {
          b_indices->data[i + b_indices->size[0] * idx->data[i10]] = indx->
            data[i10];
        }

        i10 = x->size[0];
        j = varargin_1->size[0] * varargin_1->size[1];
        varargin_1->size[0] = 1;
        varargin_1->size[1] = (int32_T)((real_T)i10 - 1.0) + 1;
        emxEnsureCapacity_real_T(sp, varargin_1, j, &ce_emlrtRTEI);
        loop_ub = (int32_T)((real_T)i10 - 1.0);
        for (i10 = 0; i10 <= loop_ub; i10++) {
          varargin_1->data[varargin_1->size[0] * i10] = 1.0 + (real_T)i10;
        }

        loop_ub = b_indices->size[1];
        i10 = b_indices->size[0];
        j = 1 + i;
        if (!((j >= 1) && (j <= i10))) {
          emlrtDynamicBoundsCheckR2012b(j, 1, i10, &gb_emlrtBCI, sp);
        }

        i10 = varargin_2->size[0] * varargin_2->size[1];
        varargin_2->size[0] = 1;
        varargin_2->size[1] = loop_ub;
        emxEnsureCapacity_real_T(sp, varargin_2, i10, &de_emlrtRTEI);
        for (i10 = 0; i10 < loop_ub; i10++) {
          varargin_2->data[varargin_2->size[0] * i10] = b_indices->data[(j +
            b_indices->size[0] * i10) - 1];
        }

        st.site = &qd_emlrtRSI;
        b_st.site = &ge_emlrtRSI;
        for (i10 = 0; i10 < 2; i10++) {
          siz[i10] = x->size[i10];
        }

        if (!allinrange(varargin_1, siz[0])) {
          emlrtErrorWithMessageIdR2018a(&b_st, &pi_emlrtRTEI,
            "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange",
            0);
        }

        for (i10 = 0; i10 < 2; i10++) {
          b_varargin_1[i10] = (uint32_T)varargin_1->size[i10];
        }

        loop_ub = b_indices->size[1];
        i10 = c_indices->size[0] * c_indices->size[1];
        c_indices->size[0] = 1;
        c_indices->size[1] = loop_ub;
        emxEnsureCapacity_int32_T1(&b_st, c_indices, i10, &de_emlrtRTEI);
        for (i10 = 0; i10 < loop_ub; i10++) {
          c_indices->data[c_indices->size[0] * i10] = b_indices->data[i +
            b_indices->size[0] * i10];
        }

        for (i10 = 0; i10 < 2; i10++) {
          b_varargin_2[i10] = (uint32_T)c_indices->size[i10];
        }

        overflow = false;
        p = true;
        eint = 0;
        exitg1 = false;
        while ((!exitg1) && (eint < 2)) {
          if (!((int32_T)b_varargin_1[eint] == (int32_T)b_varargin_2[eint])) {
            p = false;
            exitg1 = true;
          } else {
            eint++;
          }
        }

        if (p) {
          overflow = true;
        }

        if (!overflow) {
          emlrtErrorWithMessageIdR2018a(&b_st, &qi_emlrtRTEI,
            "MATLAB:sub2ind:SubscriptVectorSize",
            "MATLAB:sub2ind:SubscriptVectorSize", 0);
        }

        c_st.site = &he_emlrtRSI;
        d_st.site = &ie_emlrtRSI;
        if (!allinrange(varargin_2, siz[1])) {
          emlrtErrorWithMessageIdR2018a(&b_st, &pi_emlrtRTEI,
            "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange",
            0);
        }

        i10 = r11->size[0] * r11->size[1];
        r11->size[0] = 1;
        r11->size[1] = varargin_1->size[1];
        emxEnsureCapacity_int32_T1(sp, r11, i10, &ee_emlrtRTEI);
        eint = x->size[0] * x->size[1];
        loop_ub = varargin_1->size[0] * varargin_1->size[1];
        for (i10 = 0; i10 < loop_ub; i10++) {
          j = (int32_T)varargin_1->data[i10] + siz[0] * ((int32_T)
            varargin_2->data[i10] - 1);
          if (!((j >= 1) && (j <= eint))) {
            emlrtDynamicBoundsCheckR2012b(j, 1, eint, &ib_emlrtBCI, sp);
          }

          r11->data[i10] = j;
        }

        loop_ub = r11->size[0] * r11->size[1] - 1;
        for (i10 = 0; i10 <= loop_ub; i10++) {
          x->data[r11->data[i10] - 1] = ((real32_T)rtInf);
        }

        i++;
      }

      emxFree_int32_T(sp, &c_indices);
      emxFree_real_T(sp, &varargin_2);
      emxFree_real_T(sp, &varargin_1);
      emxFree_int32_T(sp, &idx);
      emxFree_real32_T(sp, &ex);
      emxFree_int32_T(sp, &indx);
      emxFree_int32_T(sp, &r11);
    } else {
      emxInit_real32_T(sp, &xSorted, 2, &fe_emlrtRTEI, true);
      st.site = &rd_emlrtRSI;
      i10 = xSorted->size[0] * xSorted->size[1];
      xSorted->size[0] = x->size[0];
      xSorted->size[1] = x->size[1];
      emxEnsureCapacity_real32_T(&st, xSorted, i10, &rd_emlrtRTEI);
      loop_ub = x->size[0] * x->size[1];
      for (i10 = 0; i10 < loop_ub; i10++) {
        xSorted->data[i10] = x->data[i10];
      }

      emxInit_int32_T1(&st, &inds, 2, &fe_emlrtRTEI, true);
      emxInit_int32_T1(&st, &iidx, 2, &fe_emlrtRTEI, true);
      b_st.site = &je_emlrtRSI;
      sort(&b_st, xSorted, iidx);
      i10 = inds->size[0] * inds->size[1];
      inds->size[0] = iidx->size[0];
      inds->size[1] = iidx->size[1];
      emxEnsureCapacity_int32_T1(&st, inds, i10, &td_emlrtRTEI);
      loop_ub = iidx->size[0] * iidx->size[1];
      for (i10 = 0; i10 < loop_ub; i10++) {
        inds->data[i10] = iidx->data[i10];
      }

      emxFree_int32_T(&st, &iidx);
      if (1 > n) {
        loop_ub = 0;
      } else {
        i10 = xSorted->size[1];
        if (!(1 <= i10)) {
          emlrtDynamicBoundsCheckR2012b(1, 1, i10, &fb_emlrtBCI, sp);
        }

        i10 = xSorted->size[1];
        if (!(n <= i10)) {
          emlrtDynamicBoundsCheckR2012b(n, 1, i10, &eb_emlrtBCI, sp);
        }

        loop_ub = n;
      }

      eint = xSorted->size[0];
      i10 = values->size[0] * values->size[1];
      values->size[0] = loop_ub;
      values->size[1] = eint;
      emxEnsureCapacity_real32_T(sp, values, i10, &wd_emlrtRTEI);
      for (i10 = 0; i10 < eint; i10++) {
        for (j = 0; j < loop_ub; j++) {
          values->data[j + values->size[0] * i10] = xSorted->data[i10 +
            xSorted->size[0] * j];
        }
      }

      emxFree_real32_T(sp, &xSorted);
      if (1 > n) {
        n = 0;
      } else {
        i10 = inds->size[1];
        if (!(1 <= i10)) {
          emlrtDynamicBoundsCheckR2012b(1, 1, i10, &db_emlrtBCI, sp);
        }

        i10 = inds->size[1];
        if (!(n <= i10)) {
          emlrtDynamicBoundsCheckR2012b(n, 1, i10, &cb_emlrtBCI, sp);
        }
      }

      loop_ub = inds->size[0];
      i10 = b_indices->size[0] * b_indices->size[1];
      b_indices->size[0] = n;
      b_indices->size[1] = loop_ub;
      emxEnsureCapacity_int32_T1(sp, b_indices, i10, &xd_emlrtRTEI);
      for (i10 = 0; i10 < loop_ub; i10++) {
        for (j = 0; j < n; j++) {
          b_indices->data[j + b_indices->size[0] * i10] = inds->data[i10 +
            inds->size[0] * j];
        }
      }

      emxFree_int32_T(sp, &inds);
    }

    i10 = indices->size[0] * indices->size[1];
    indices->size[0] = b_indices->size[0];
    indices->size[1] = b_indices->size[1];
    emxEnsureCapacity_uint32_T(sp, indices, i10, &sd_emlrtRTEI);
    loop_ub = b_indices->size[0] * b_indices->size[1];
    for (i10 = 0; i10 < loop_ub; i10++) {
      j = b_indices->data[i10];
      if (j < 0) {
        j = 0;
      }

      indices->data[i10] = (uint32_T)j;
    }
  }

  emxFree_int32_T(sp, &b_indices);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (partialSort.c) */
