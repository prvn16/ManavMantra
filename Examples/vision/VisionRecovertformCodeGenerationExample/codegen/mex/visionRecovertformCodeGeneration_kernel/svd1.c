/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * svd1.c
 *
 * Code generation for function 'svd1'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "svd1.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "error.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"
#include "lapacke.h"

/* Variable Definitions */
static emlrtRSInfo mh_emlrtRSI = { 53, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pathName */
};

static emlrtRSInfo nh_emlrtRSI = { 78, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pathName */
};

static emlrtRSInfo oh_emlrtRSI = { 83, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pathName */
};

static emlrtRSInfo ph_emlrtRSI = { 105,/* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pathName */
};

static emlrtRSInfo qh_emlrtRSI = { 205,/* lineNo */
  "xgesdd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesdd.m"/* pathName */
};

static emlrtRSInfo rh_emlrtRSI = { 175,/* lineNo */
  "xgesdd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesdd.m"/* pathName */
};

static emlrtRSInfo sh_emlrtRSI = { 64, /* lineNo */
  "xgesdd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesdd.m"/* pathName */
};

static emlrtRSInfo th_emlrtRSI = { 57, /* lineNo */
  "xgesdd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesdd.m"/* pathName */
};

static emlrtRSInfo uh_emlrtRSI = { 54, /* lineNo */
  "xgesdd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesdd.m"/* pathName */
};

static emlrtRSInfo bi_emlrtRSI = { 28, /* lineNo */
  "xgesvd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pathName */
};

static emlrtRSInfo ci_emlrtRSI = { 193,/* lineNo */
  "xgesvd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pathName */
};

static emlrtRSInfo di_emlrtRSI = { 171,/* lineNo */
  "xgesvd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pathName */
};

static emlrtRSInfo ei_emlrtRSI = { 114,/* lineNo */
  "xgesvd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pathName */
};

static emlrtRSInfo fi_emlrtRSI = { 107,/* lineNo */
  "xgesvd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pathName */
};

static emlrtRSInfo gi_emlrtRSI = { 56, /* lineNo */
  "xgesvd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pathName */
};

static emlrtRTEInfo ag_emlrtRTEI = { 78,/* lineNo */
  66,                                  /* colNo */
  "svd",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pName */
};

static emlrtRTEInfo bg_emlrtRTEI = { 78,/* lineNo */
  9,                                   /* colNo */
  "svd",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pName */
};

static emlrtRTEInfo cg_emlrtRTEI = { 28,/* lineNo */
  33,                                  /* colNo */
  "xgesvd",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pName */
};

static emlrtRTEInfo dg_emlrtRTEI = { 53,/* lineNo */
  5,                                   /* colNo */
  "svd",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pName */
};

static emlrtRTEInfo eg_emlrtRTEI = { 28,/* lineNo */
  5,                                   /* colNo */
  "xgesvd",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pName */
};

static emlrtRTEInfo fg_emlrtRTEI = { 1,/* lineNo */
  20,                                  /* colNo */
  "svd",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pName */
};

/* Function Definitions */
void svd(const emlrtStack *sp, const emxArray_real32_T *A, emxArray_real32_T *U,
         real32_T s_data[], int32_T s_size[1], real32_T V[25])
{
  emxArray_real32_T *b_A;
  int32_T m;
  int32_T i18;
  int32_T minnm;
  emxArray_real32_T *Utmp;
  int32_T info;
  real32_T Vt[25];
  ptrdiff_t info_t;
  real32_T superb_data[4];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real32_T(sp, &b_A, 2, &ag_emlrtRTEI, true);
  st.site = &mh_emlrtRSI;
  m = A->size[0];
  b_st.site = &nh_emlrtRSI;
  i18 = b_A->size[0] * b_A->size[1];
  b_A->size[0] = A->size[0];
  b_A->size[1] = 5;
  emxEnsureCapacity_real32_T(&b_st, b_A, i18, &ag_emlrtRTEI);
  minnm = A->size[0] * A->size[1];
  for (i18 = 0; i18 < minnm; i18++) {
    b_A->data[i18] = A->data[i18];
  }

  emxInit_real32_T(&b_st, &Utmp, 2, &fg_emlrtRTEI, true);
  i18 = Utmp->size[0] * Utmp->size[1];
  Utmp->size[0] = A->size[0];
  Utmp->size[1] = A->size[0];
  emxEnsureCapacity_real32_T(&b_st, Utmp, i18, &bg_emlrtRTEI);
  s_size[0] = muIntScalarMin_sint32(5, m);
  c_st.site = &uh_emlrtRSI;
  if (!(A->size[0] == 0)) {
    c_st.site = &th_emlrtRSI;
    d_st.site = &vh_emlrtRSI;
    c_st.site = &sh_emlrtRSI;
    d_st.site = &vh_emlrtRSI;
    c_st.site = &rh_emlrtRSI;
    d_st.site = &wh_emlrtRSI;
    info_t = LAPACKE_sgesdd(102, 'A', (ptrdiff_t)A->size[0], (ptrdiff_t)5,
      &b_A->data[0], (ptrdiff_t)A->size[0], &s_data[0], &Utmp->data[0],
      (ptrdiff_t)A->size[0], &Vt[0], (ptrdiff_t)5);
    info = (int32_T)info_t;
    c_st.site = &qh_emlrtRSI;
    d_st.site = &xh_emlrtRSI;
    if (info < 0) {
      if (info == -1010) {
        d_st.site = &yh_emlrtRSI;
        b_error(&d_st);
      } else {
        d_st.site = &ai_emlrtRSI;
        c_error(&d_st, info);
      }
    }
  } else {
    info = 0;
  }

  if (info > 0) {
    b_st.site = &oh_emlrtRSI;
    c_st.site = &bi_emlrtRSI;
    i18 = b_A->size[0] * b_A->size[1];
    b_A->size[0] = A->size[0];
    b_A->size[1] = 5;
    emxEnsureCapacity_real32_T(&c_st, b_A, i18, &cg_emlrtRTEI);
    minnm = A->size[0] * A->size[1];
    for (i18 = 0; i18 < minnm; i18++) {
      b_A->data[i18] = A->data[i18];
    }

    m = A->size[0];
    d_st.site = &gi_emlrtRSI;
    minnm = muIntScalarMin_sint32(5, m);
    i18 = U->size[0] * U->size[1];
    U->size[0] = A->size[0];
    U->size[1] = minnm;
    emxEnsureCapacity_real32_T(&c_st, U, i18, &eg_emlrtRTEI);
    s_size[0] = minnm;
    if (!(A->size[0] == 0)) {
      d_st.site = &fi_emlrtRSI;
      d_st.site = &ei_emlrtRSI;
      d_st.site = &di_emlrtRSI;
      info_t = LAPACKE_sgesvd(102, 'S', 'A', (ptrdiff_t)A->size[0], (ptrdiff_t)5,
        &b_A->data[0], (ptrdiff_t)A->size[0], &s_data[0], &U->data[0],
        (ptrdiff_t)A->size[0], &Vt[0], (ptrdiff_t)5, &superb_data[0]);
      info = (int32_T)info_t;
    } else {
      info = 0;
    }

    for (i18 = 0; i18 < 5; i18++) {
      for (minnm = 0; minnm < 5; minnm++) {
        V[minnm + 5 * i18] = Vt[i18 + 5 * minnm];
      }
    }

    d_st.site = &ci_emlrtRSI;
    if (info < 0) {
      if (info == -1010) {
        e_st.site = &yh_emlrtRSI;
        b_error(&e_st);
      } else {
        e_st.site = &ai_emlrtRSI;
        d_error(&e_st, info);
      }
    }
  } else {
    for (i18 = 0; i18 < 5; i18++) {
      for (minnm = 0; minnm < 5; minnm++) {
        V[minnm + 5 * i18] = Vt[i18 + 5 * minnm];
      }
    }

    minnm = A->size[0];
    i18 = U->size[0] * U->size[1];
    U->size[0] = minnm;
    U->size[1] = muIntScalarMin_sint32(m, 5);
    emxEnsureCapacity_real32_T(&st, U, i18, &dg_emlrtRTEI);
    i18 = U->size[0] * U->size[1];
    for (minnm = 0; minnm < i18; minnm++) {
      U->data[minnm] = Utmp->data[minnm];
    }
  }

  emxFree_real32_T(&st, &b_A);
  emxFree_real32_T(&st, &Utmp);
  if (info > 0) {
    b_st.site = &ph_emlrtRSI;
    e_error(&b_st);
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (svd1.c) */
