/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * xgeqp3.c
 *
 * Code generation for function 'xgeqp3'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "xgeqp3.h"
#include "colon.h"
#include "error.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"
#include "lapacke.h"

/* Variable Definitions */
static emlrtRSInfo wl_emlrtRSI = { 14, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo xl_emlrtRSI = { 37, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo yl_emlrtRSI = { 38, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo am_emlrtRSI = { 41, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo bm_emlrtRSI = { 45, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo cm_emlrtRSI = { 64, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo dm_emlrtRSI = { 67, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo em_emlrtRSI = { 76, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo fm_emlrtRSI = { 79, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

/* Function Definitions */
void xgeqp3(const emlrtStack *sp, real32_T A_data[], int32_T A_size[2], real32_T
            tau_data[], int32_T tau_size[1], int32_T jpvt_data[], int32_T
            jpvt_size[2])
{
  int32_T n;
  int32_T jpvt_t_size_idx_0;
  int32_T loop_ub;
  int32_T i29;
  ptrdiff_t jpvt_t_data[3];
  ptrdiff_t m_t;
  ptrdiff_t info_t;
  int32_T info;
  boolean_T p;
  boolean_T b_p;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &wl_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  n = A_size[1];
  b_st.site = &xl_emlrtRSI;
  c_st.site = &vh_emlrtRSI;
  b_st.site = &yl_emlrtRSI;
  if (A_size[1] == 0) {
    tau_size[0] = 0;
    b_st.site = &am_emlrtRSI;
    c_st.site = &tj_emlrtRSI;
    d_st.site = &uj_emlrtRSI;
    e_st.site = &vj_emlrtRSI;
    eml_signed_integer_colon(&e_st, A_size[1], jpvt_data, jpvt_size);
  } else {
    tau_size[0] = A_size[1];
    b_st.site = &bm_emlrtRSI;
    c_st.site = &vh_emlrtRSI;
    jpvt_t_size_idx_0 = A_size[1];
    loop_ub = A_size[1];
    for (i29 = 0; i29 < loop_ub; i29++) {
      jpvt_t_data[i29] = (ptrdiff_t)0;
    }

    b_st.site = &cm_emlrtRSI;
    c_st.site = &vh_emlrtRSI;
    m_t = (ptrdiff_t)3;
    b_st.site = &dm_emlrtRSI;
    c_st.site = &wh_emlrtRSI;
    info_t = LAPACKE_sgeqp3(102, m_t, (ptrdiff_t)A_size[1], &A_data[0], m_t,
      &jpvt_t_data[0], &tau_data[0]);
    info = (int32_T)info_t;
    b_st.site = &em_emlrtRSI;
    c_st.site = &xh_emlrtRSI;
    if (info != 0) {
      p = true;
      b_p = false;
      if (info == -4) {
        b_p = true;
      }

      if (!b_p) {
        if (info == -1010) {
          c_st.site = &yh_emlrtRSI;
          b_error(&c_st);
        } else {
          c_st.site = &ai_emlrtRSI;
          h_error(&c_st, info);
        }
      }
    } else {
      p = false;
    }

    if (p) {
      A_size[0] = 3;
      loop_ub = A_size[1];
      for (i29 = 0; i29 < loop_ub; i29++) {
        for (info = 0; info < 3; info++) {
          A_data[info + A_size[0] * i29] = ((real32_T)rtNaN);
        }
      }

      loop_ub = tau_size[0];
      for (i29 = 0; i29 < loop_ub; i29++) {
        tau_data[i29] = ((real32_T)rtNaN);
      }

      b_st.site = &fm_emlrtRSI;
      c_st.site = &tj_emlrtRSI;
      d_st.site = &uj_emlrtRSI;
      e_st.site = &vj_emlrtRSI;
      eml_signed_integer_colon(&e_st, n, jpvt_data, jpvt_size);
    } else {
      jpvt_size[0] = 1;
      jpvt_size[1] = jpvt_t_size_idx_0;
      for (i29 = 0; i29 < jpvt_t_size_idx_0; i29++) {
        jpvt_data[i29] = (int32_T)jpvt_t_data[i29];
      }
    }
  }
}

/* End of code generation (xgeqp3.c) */
