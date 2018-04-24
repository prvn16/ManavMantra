/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sort1.c
 *
 * Code generation for function 'sort1'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "sort1.h"
#include "matlabCodegenHandle.h"
#include "sortIdx.h"
#include "eml_int_forloop_overflow_check.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo uk_emlrtRSI = { 72, /* lineNo */
  "sort",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m"/* pathName */
};

static emlrtRSInfo vk_emlrtRSI = { 105,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

static emlrtRSInfo wk_emlrtRSI = { 308,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

static emlrtRSInfo xk_emlrtRSI = { 333,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

static emlrtRSInfo yk_emlrtRSI = { 420,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

static emlrtRSInfo al_emlrtRSI = { 427,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

static emlrtRSInfo bl_emlrtRSI = { 499,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

static emlrtRSInfo cl_emlrtRSI = { 506,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

static emlrtRSInfo dl_emlrtRSI = { 507,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

static emlrtRSInfo el_emlrtRSI = { 514,/* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

/* Function Definitions */
void b_sort(const emlrtStack *sp, real_T x[8])
{
  int32_T i;
  int32_T idx[8];
  real_T xwork[8];
  real_T x4[4];
  int32_T nNaNs;
  int8_T idx4[4];
  int32_T ib;
  int32_T k;
  int8_T perm[4];
  int32_T i2;
  int32_T i3;
  int32_T i4;
  int32_T iwork[8];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &uk_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  for (i = 0; i < 8; i++) {
    idx[i] = 0;
  }

  b_st.site = &vk_emlrtRSI;
  c_st.site = &wk_emlrtRSI;
  for (i = 0; i < 4; i++) {
    x4[i] = 0.0;
    idx4[i] = 0;
  }

  memset(&xwork[0], 0, sizeof(real_T) << 3);
  nNaNs = 0;
  ib = 0;
  for (k = 0; k < 8; k++) {
    if (muDoubleScalarIsNaN(x[k])) {
      idx[7 - nNaNs] = k + 1;
      xwork[7 - nNaNs] = x[k];
      nNaNs++;
    } else {
      ib++;
      idx4[ib - 1] = (int8_T)(k + 1);
      x4[ib - 1] = x[k];
      if (ib == 4) {
        i = k - nNaNs;
        if (x4[0] <= x4[1]) {
          ib = 1;
          i2 = 2;
        } else {
          ib = 2;
          i2 = 1;
        }

        if (x4[2] <= x4[3]) {
          i3 = 3;
          i4 = 4;
        } else {
          i3 = 4;
          i4 = 3;
        }

        if (x4[ib - 1] <= x4[i3 - 1]) {
          if (x4[i2 - 1] <= x4[i3 - 1]) {
            perm[0] = (int8_T)ib;
            perm[1] = (int8_T)i2;
            perm[2] = (int8_T)i3;
            perm[3] = (int8_T)i4;
          } else if (x4[i2 - 1] <= x4[i4 - 1]) {
            perm[0] = (int8_T)ib;
            perm[1] = (int8_T)i3;
            perm[2] = (int8_T)i2;
            perm[3] = (int8_T)i4;
          } else {
            perm[0] = (int8_T)ib;
            perm[1] = (int8_T)i3;
            perm[2] = (int8_T)i4;
            perm[3] = (int8_T)i2;
          }
        } else if (x4[ib - 1] <= x4[i4 - 1]) {
          if (x4[i2 - 1] <= x4[i4 - 1]) {
            perm[0] = (int8_T)i3;
            perm[1] = (int8_T)ib;
            perm[2] = (int8_T)i2;
            perm[3] = (int8_T)i4;
          } else {
            perm[0] = (int8_T)i3;
            perm[1] = (int8_T)ib;
            perm[2] = (int8_T)i4;
            perm[3] = (int8_T)i2;
          }
        } else {
          perm[0] = (int8_T)i3;
          perm[1] = (int8_T)i4;
          perm[2] = (int8_T)ib;
          perm[3] = (int8_T)i2;
        }

        idx[i - 3] = idx4[perm[0] - 1];
        idx[i - 2] = idx4[perm[1] - 1];
        idx[i - 1] = idx4[perm[2] - 1];
        idx[i] = idx4[perm[3] - 1];
        x[i - 3] = x4[perm[0] - 1];
        x[i - 2] = x4[perm[1] - 1];
        x[i - 1] = x4[perm[2] - 1];
        x[i] = x4[perm[3] - 1];
        ib = 0;
      }
    }
  }

  if (ib > 0) {
    for (i = 0; i < 4; i++) {
      perm[i] = 0;
    }

    if (ib == 1) {
      perm[0] = 1;
    } else if (ib == 2) {
      if (x4[0] <= x4[1]) {
        perm[0] = 1;
        perm[1] = 2;
      } else {
        perm[0] = 2;
        perm[1] = 1;
      }
    } else if (x4[0] <= x4[1]) {
      if (x4[1] <= x4[2]) {
        perm[0] = 1;
        perm[1] = 2;
        perm[2] = 3;
      } else if (x4[0] <= x4[2]) {
        perm[0] = 1;
        perm[1] = 3;
        perm[2] = 2;
      } else {
        perm[0] = 3;
        perm[1] = 1;
        perm[2] = 2;
      }
    } else if (x4[0] <= x4[2]) {
      perm[0] = 2;
      perm[1] = 1;
      perm[2] = 3;
    } else if (x4[1] <= x4[2]) {
      perm[0] = 2;
      perm[1] = 3;
      perm[2] = 1;
    } else {
      perm[0] = 3;
      perm[1] = 2;
      perm[2] = 1;
    }

    d_st.site = &yk_emlrtRSI;
    if (ib > 2147483646) {
      e_st.site = &lb_emlrtRSI;
      check_forloop_overflow_error(&e_st);
    }

    for (k = 8; k - 7 <= ib; k++) {
      idx[(k - nNaNs) - ib] = idx4[perm[k - 8] - 1];
      x[(k - nNaNs) - ib] = x4[perm[k - 8] - 1];
    }
  }

  i = nNaNs >> 1;
  d_st.site = &al_emlrtRSI;
  for (k = 1; k <= i; k++) {
    ib = idx[(k - nNaNs) + 7];
    idx[(k - nNaNs) + 7] = idx[8 - k];
    idx[8 - k] = ib;
    x[(k - nNaNs) + 7] = xwork[8 - k];
    x[8 - k] = xwork[(k - nNaNs) + 7];
  }

  if ((nNaNs & 1) != 0) {
    x[(i - nNaNs) + 8] = xwork[(i - nNaNs) + 8];
  }

  if (8 - nNaNs > 1) {
    c_st.site = &xk_emlrtRSI;
    for (i = 0; i < 8; i++) {
      iwork[i] = 0;
    }

    i3 = (8 - nNaNs) >> 2;
    i2 = 4;
    while (i3 > 1) {
      if ((i3 & 1) != 0) {
        i3--;
        i = i2 * i3;
        ib = 8 - (nNaNs + i);
        if (ib > i2) {
          d_st.site = &bl_emlrtRSI;
          merge(&d_st, idx, x, i, i2, ib - i2, iwork, xwork);
        }
      }

      i = i2 << 1;
      i3 >>= 1;
      d_st.site = &cl_emlrtRSI;
      for (k = 1; k <= i3; k++) {
        d_st.site = &dl_emlrtRSI;
        merge(&d_st, idx, x, (k - 1) * i, i2, i2, iwork, xwork);
      }

      i2 = i;
    }

    if (8 - nNaNs > i2) {
      d_st.site = &el_emlrtRSI;
      merge(&d_st, idx, x, 0, i2, 8 - (nNaNs + i2), iwork, xwork);
    }
  }
}

void sort(real_T x[2])
{
  real_T tmp;
  if ((x[0] <= x[1]) || muDoubleScalarIsNaN(x[1])) {
  } else {
    tmp = x[0];
    x[0] = x[1];
    x[1] = tmp;
  }
}

/* End of code generation (sort1.c) */
