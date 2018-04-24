/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * mrdivide.c
 *
 * Code generation for function 'mrdivide'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "mrdivide.h"
#include "imwarp.h"
#include "warning.h"
#include "xgetrf.h"
#include "xgeqp3.h"
#include "visionRecovertformCodeGeneration_kernel_mexutil.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo uk_emlrtRSI = { 59, /* lineNo */
  "xtrsm",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xtrsm.m"/* pathName */
};

static emlrtRSInfo ol_emlrtRSI = { 42, /* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo pl_emlrtRSI = { 103,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo ql_emlrtRSI = { 101,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo rl_emlrtRSI = { 113,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo tl_emlrtRSI = { 40, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo ul_emlrtRSI = { 33, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo vl_emlrtRSI = { 29, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo gm_emlrtRSI = { 121,/* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo hm_emlrtRSI = { 122,/* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo im_emlrtRSI = { 73, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo jm_emlrtRSI = { 80, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo km_emlrtRSI = { 90, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo lm_emlrtRSI = { 34, /* lineNo */
  "xunormqr",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xunormqr.m"/* pathName */
};

static emlrtRTEInfo xg_emlrtRTEI = { 1,/* lineNo */
  1,                                   /* colNo */
  "mrdivide",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\mrdivide.p"/* pName */
};

/* Function Definitions */
void mrdivide(const emlrtStack *sp, const real_T A[9], const real32_T B_data[],
              const int32_T B_size[2], real32_T y_data[], int32_T y_size[2])
{
  int32_T rankR;
  int32_T Y_size[2];
  int32_T kBcol;
  int32_T jBcol;
  real_T B[9];
  int32_T A_size[2];
  int32_T jAcol;
  real32_T Y_data[9];
  int32_T jpvt_data[3];
  int32_T jpvt_size[2];
  real32_T b_B_data[9];
  real32_T A_data[9];
  real32_T tau_data[3];
  int32_T tau_size[1];
  real32_T tol;
  int32_T j;
  const mxArray *y;
  const mxArray *m4;
  static const int32_T iv21[2] = { 1, 6 };

  int32_T k;
  static const char_T rfmt[6] = { '%', '1', '4', '.', '6', 'e' };

  char_T cv3[14];
  int32_T i;
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
  if (B_size[1] != 3) {
    emlrtErrorWithMessageIdR2018a(sp, &xg_emlrtRTEI, "Coder:MATLAB:dimagree",
      "Coder:MATLAB:dimagree", 0);
  }

  if (B_size[0] == 0) {
    y_size[0] = 3;
    y_size[1] = 0;
  } else if (B_size[0] == 3) {
    st.site = &ii_emlrtRSI;
    b_st.site = &ol_emlrtRSI;
    Y_size[0] = 3;
    Y_size[1] = B_size[1];
    kBcol = 3 * B_size[1];
    if (0 <= kBcol - 1) {
      memcpy(&Y_data[0], &B_data[0], (uint32_T)(kBcol * (int32_T)sizeof(real32_T)));
    }

    c_st.site = &ql_emlrtRSI;
    b_xgetrf(&c_st, Y_data, Y_size, jpvt_data, jpvt_size, &rankR);
    if (rankR > 0) {
      c_st.site = &pl_emlrtRSI;
      d_st.site = &li_emlrtRSI;
      warning(&d_st);
    }

    for (rankR = 0; rankR < 9; rankR++) {
      b_B_data[rankR] = (real32_T)A[rankR];
    }

    c_st.site = &rl_emlrtRSI;
    d_st.site = &uk_emlrtRSI;
    for (j = 0; j < 3; j++) {
      jBcol = 3 * j;
      jAcol = 3 * j;
      for (k = 1; k <= j; k++) {
        kBcol = 3 * (k - 1);
        if (Y_data[(k + jAcol) - 1] != 0.0F) {
          for (i = 0; i < 3; i++) {
            b_B_data[i + jBcol] -= Y_data[(k + jAcol) - 1] * b_B_data[i + kBcol];
          }
        }
      }

      tol = 1.0F / Y_data[j + jAcol];
      for (i = 0; i < 3; i++) {
        b_B_data[i + jBcol] *= tol;
      }
    }

    for (j = 2; j >= 0; j--) {
      jBcol = 3 * j;
      jAcol = 3 * j - 1;
      for (k = j + 2; k < 4; k++) {
        kBcol = 3 * (k - 1);
        if (Y_data[k + jAcol] != 0.0F) {
          for (i = 0; i < 3; i++) {
            b_B_data[i + jBcol] -= Y_data[k + jAcol] * b_B_data[i + kBcol];
          }
        }
      }
    }

    for (rankR = 1; rankR >= 0; rankR--) {
      if (jpvt_data[rankR] != rankR + 1) {
        jBcol = jpvt_data[rankR] - 1;
        for (jAcol = 0; jAcol < 3; jAcol++) {
          tol = b_B_data[jAcol + 3 * rankR];
          b_B_data[jAcol + 3 * rankR] = b_B_data[jAcol + 3 * jBcol];
          b_B_data[jAcol + 3 * jBcol] = tol;
        }
      }
    }

    y_size[0] = 3;
    y_size[1] = 3;
    for (rankR = 0; rankR < 9; rankR++) {
      y_data[rankR] = b_B_data[rankR];
    }
  } else {
    st.site = &ii_emlrtRSI;
    for (rankR = 0; rankR < 3; rankR++) {
      for (jBcol = 0; jBcol < 3; jBcol++) {
        B[jBcol + 3 * rankR] = A[rankR + 3 * jBcol];
      }
    }

    kBcol = B_size[0];
    for (rankR = 0; rankR < kBcol; rankR++) {
      jAcol = B_size[1];
      for (jBcol = 0; jBcol < jAcol; jBcol++) {
        b_B_data[jBcol + B_size[1] * rankR] = B_data[rankR + B_size[0] * jBcol];
      }
    }

    A_size[0] = 3;
    A_size[1] = B_size[0];
    kBcol = B_size[0];
    for (rankR = 0; rankR < kBcol; rankR++) {
      for (jBcol = 0; jBcol < 3; jBcol++) {
        A_data[jBcol + 3 * rankR] = b_B_data[jBcol + 3 * rankR];
      }
    }

    b_st.site = &vl_emlrtRSI;
    xgeqp3(&b_st, A_data, A_size, tau_data, tau_size, jpvt_data, jpvt_size);
    b_st.site = &ul_emlrtRSI;
    rankR = 0;
    tol = 0.0F;
    if (A_size[1] > 0) {
      tol = 3.0F * muSingleScalarAbs(A_data[0]) * 1.1920929E-7F;
      while ((rankR < A_size[1]) && (!(muSingleScalarAbs(A_data[rankR + A_size[0]
                * rankR]) <= tol))) {
        rankR++;
      }
    }

    if (rankR < A_size[1]) {
      c_st.site = &hm_emlrtRSI;
      y = NULL;
      m4 = emlrtCreateCharArray(2, iv21);
      emlrtInitCharArrayR2013a(&c_st, 6, m4, &rfmt[0]);
      emlrtAssign(&y, m4);
      d_st.site = &um_emlrtRSI;
      emlrt_marshallIn(&d_st, b_sprintf(&d_st, y, d_emlrt_marshallOut(tol),
        &e_emlrtMCI), "sprintf", cv3);
      c_st.site = &gm_emlrtRSI;
      c_warning(&c_st, rankR, cv3);
    }

    b_st.site = &tl_emlrtRSI;
    Y_size[0] = (int8_T)A_size[1];
    kBcol = (int8_T)A_size[1] * 3;
    if (0 <= kBcol - 1) {
      memset(&Y_data[0], 0, (uint32_T)(kBcol * (int32_T)sizeof(real32_T)));
    }

    c_st.site = &im_emlrtRSI;
    d_st.site = &lm_emlrtRSI;
    for (j = 0; j < A_size[1]; j++) {
      if (tau_data[j] != 0.0F) {
        for (k = 0; k < 3; k++) {
          tol = (real32_T)B[j + 3 * k];
          for (i = j + 1; i < 3; i++) {
            tol += A_data[i + A_size[0] * j] * (real32_T)B[i + 3 * k];
          }

          tol *= tau_data[j];
          if (tol != 0.0F) {
            B[j + 3 * k] = (real32_T)B[j + 3 * k] - tol;
            for (i = j + 1; i < 3; i++) {
              B[i + 3 * k] = (real32_T)B[i + 3 * k] - A_data[i + A_size[0] * j] *
                tol;
            }
          }
        }
      }
    }

    for (k = 0; k < 3; k++) {
      c_st.site = &jm_emlrtRSI;
      for (i = 0; i < rankR; i++) {
        Y_data[(jpvt_data[i] + Y_size[0] * k) - 1] = (real32_T)B[i + 3 * k];
      }

      for (j = rankR - 1; j + 1 > 0; j--) {
        Y_data[(jpvt_data[j] + Y_size[0] * k) - 1] /= A_data[j + A_size[0] * j];
        c_st.site = &km_emlrtRSI;
        for (i = 0; i < j; i++) {
          Y_data[(jpvt_data[i] + Y_size[0] * k) - 1] -= Y_data[(jpvt_data[j] +
            Y_size[0] * k) - 1] * A_data[i + A_size[0] * j];
        }
      }
    }

    y_size[0] = 3;
    y_size[1] = (int8_T)A_size[1];
    kBcol = (int8_T)A_size[1];
    for (rankR = 0; rankR < kBcol; rankR++) {
      for (jBcol = 0; jBcol < 3; jBcol++) {
        y_data[jBcol + 3 * rankR] = Y_data[rankR + Y_size[0] * jBcol];
      }
    }
  }
}

/* End of code generation (mrdivide.c) */
