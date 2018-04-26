/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * kalman02.c
 *
 * Code generation for function 'kalman02'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include <string.h>
#include "rt_nonfinite.h"
#include "kalman02.h"
#include "warning.h"

/* Variable Definitions */
static real_T x_est[6];
static real_T p_est[36];
static emlrtRSInfo emlrtRSI = { 37,    /* lineNo */
  "kalman02",                          /* fcnName */
  "C:\\Users\\Krishna Bhatia\\MATLAB\\Projects\\ManavMantra\\genCode\\kalman\\solutions\\kalman\\kalman02.m"/* pathName */
};

static emlrtRSInfo b_emlrtRSI = { 1,   /* lineNo */
  "mldivide",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\mldivide.p"/* pathName */
};

static emlrtRSInfo c_emlrtRSI = { 54,  /* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo d_emlrtRSI = { 171, /* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo e_emlrtRSI = { 76,  /* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

/* Function Definitions */
void kalman02(const emlrtStack *sp, const real_T z[2], real_T y[2])
{
  int32_T r2;
  int8_T Q[36];
  int32_T k;
  real_T x_prd[6];
  int32_T i0;
  real_T a21;
  real_T a[36];
  int32_T r1;
  real_T b_a[12];
  real_T p_prd[36];
  static const int8_T b[36] = { 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0,
    1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1 };

  static const int8_T c_a[36] = { 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0,
    0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1 };

  real_T S[4];
  static const int8_T d_a[12] = { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 };

  real_T B[12];
  static const int16_T R[4] = { 1000, 0, 0, 1000 };

  static const int8_T b_b[12] = { 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 };

  real_T a22;
  real_T Y[12];
  real_T b_z[2];
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

  /*  */
  /*    --------------------------------------------------------------------- */
  /*  */
  /*    Copyright 2011 The MathWorks, Inc. */
  /*  */
  /*    --------------------------------------------------------------------- */
  /*  */
  /*  Initialize state transition matrix */
  /*  Measurement matrix */
  for (r2 = 0; r2 < 36; r2++) {
    Q[r2] = 0;
  }

  /*  Initial conditions */
  /*  Predicted state and covariance */
  for (k = 0; k < 6; k++) {
    Q[k + 6 * k] = 1;
    x_prd[k] = 0.0;
    for (r2 = 0; r2 < 6; r2++) {
      a[k + 6 * r2] = 0.0;
      for (i0 = 0; i0 < 6; i0++) {
        a[k + 6 * r2] += (real_T)c_a[k + 6 * i0] * p_est[i0 + 6 * r2];
      }

      x_prd[k] += (real_T)c_a[k + 6 * r2] * x_est[r2];
    }
  }

  for (r2 = 0; r2 < 6; r2++) {
    for (i0 = 0; i0 < 6; i0++) {
      a21 = 0.0;
      for (r1 = 0; r1 < 6; r1++) {
        a21 += a[r2 + 6 * r1] * (real_T)b[r1 + 6 * i0];
      }

      p_prd[r2 + 6 * i0] = a21 + (real_T)Q[r2 + 6 * i0];
    }
  }

  /*  Estimation */
  for (r2 = 0; r2 < 2; r2++) {
    for (i0 = 0; i0 < 6; i0++) {
      b_a[r2 + (i0 << 1)] = 0.0;
      for (r1 = 0; r1 < 6; r1++) {
        b_a[r2 + (i0 << 1)] += (real_T)d_a[r2 + (r1 << 1)] * p_prd[i0 + 6 * r1];
      }
    }

    for (i0 = 0; i0 < 2; i0++) {
      a21 = 0.0;
      for (r1 = 0; r1 < 6; r1++) {
        a21 += b_a[r2 + (r1 << 1)] * (real_T)b_b[r1 + 6 * i0];
      }

      S[r2 + (i0 << 1)] = a21 + (real_T)R[r2 + (i0 << 1)];
    }

    for (i0 = 0; i0 < 6; i0++) {
      B[r2 + (i0 << 1)] = 0.0;
      for (r1 = 0; r1 < 6; r1++) {
        B[r2 + (i0 << 1)] += (real_T)d_a[r2 + (r1 << 1)] * p_prd[i0 + 6 * r1];
      }
    }
  }

  st.site = &emlrtRSI;
  b_st.site = &b_emlrtRSI;
  c_st.site = &c_emlrtRSI;
  if (muDoubleScalarAbs(S[1]) > muDoubleScalarAbs(S[0])) {
    r1 = 1;
    r2 = 0;
  } else {
    r1 = 0;
    r2 = 1;
  }

  a21 = S[r2] / S[r1];
  a22 = S[2 + r2] - a21 * S[2 + r1];
  if ((a22 == 0.0) || (S[r1] == 0.0)) {
    d_st.site = &d_emlrtRSI;
    e_st.site = &e_emlrtRSI;
    warning(&e_st);
  }

  for (k = 0; k < 6; k++) {
    b_a[1 + (k << 1)] = (B[r2 + (k << 1)] - B[r1 + (k << 1)] * a21) / a22;
    b_a[k << 1] = (B[r1 + (k << 1)] - b_a[1 + (k << 1)] * S[2 + r1]) / S[r1];
  }

  for (r2 = 0; r2 < 2; r2++) {
    for (i0 = 0; i0 < 6; i0++) {
      Y[i0 + 6 * r2] = b_a[r2 + (i0 << 1)];
    }
  }

  for (r2 = 0; r2 < 6; r2++) {
    for (i0 = 0; i0 < 2; i0++) {
      B[i0 + (r2 << 1)] = Y[i0 + (r2 << 1)];
    }
  }

  /*  Estimated state and covariance */
  for (r2 = 0; r2 < 2; r2++) {
    a21 = 0.0;
    for (i0 = 0; i0 < 6; i0++) {
      a21 += (real_T)d_a[r2 + (i0 << 1)] * x_prd[i0];
    }

    b_z[r2] = z[r2] - a21;
  }

  for (r2 = 0; r2 < 6; r2++) {
    a21 = 0.0;
    for (i0 = 0; i0 < 2; i0++) {
      a21 += B[r2 + 6 * i0] * b_z[i0];
    }

    x_est[r2] = x_prd[r2] + a21;
    for (i0 = 0; i0 < 6; i0++) {
      a[r2 + 6 * i0] = 0.0;
      for (r1 = 0; r1 < 2; r1++) {
        a[r2 + 6 * i0] += B[r2 + 6 * r1] * (real_T)d_a[r1 + (i0 << 1)];
      }
    }

    for (i0 = 0; i0 < 6; i0++) {
      a21 = 0.0;
      for (r1 = 0; r1 < 6; r1++) {
        a21 += a[r2 + 6 * r1] * p_prd[r1 + 6 * i0];
      }

      p_est[r2 + 6 * i0] = p_prd[r2 + 6 * i0] - a21;
    }
  }

  /*  Compute the estimated measurements */
  for (r2 = 0; r2 < 2; r2++) {
    y[r2] = 0.0;
    for (i0 = 0; i0 < 6; i0++) {
      y[r2] += (real_T)d_a[r2 + (i0 << 1)] * x_est[i0];
    }
  }
}

void kalman02_init(void)
{
  int32_T i;
  for (i = 0; i < 6; i++) {
    x_est[i] = 0.0;
  }

  memset(&p_est[0], 0, 36U * sizeof(real_T));
}

/* End of code generation (kalman02.c) */
