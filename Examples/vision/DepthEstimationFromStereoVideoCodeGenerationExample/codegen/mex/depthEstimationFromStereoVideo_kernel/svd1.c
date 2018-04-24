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
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "svd1.h"
#include "xrotg.h"
#include "error.h"
#include "xrot.h"
#include "sqrt.h"
#include "xswap.h"
#include "xscal.h"
#include "xaxpy.h"
#include "xdotc.h"
#include "xnrm2.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo le_emlrtRSI = { 53, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pathName */
};

static emlrtRSInfo me_emlrtRSI = { 101,/* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\svd.m"/* pathName */
};

static emlrtRSInfo ne_emlrtRSI = { 31, /* lineNo */
  "xgesvd",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgesvd.m"/* pathName */
};

static emlrtRSInfo oe_emlrtRSI = { 424,/* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo se_emlrtRSI = { 376,/* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo we_emlrtRSI = { 265,/* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo xe_emlrtRSI = { 247,/* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo ye_emlrtRSI = { 236,/* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo af_emlrtRSI = { 211,/* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo cf_emlrtRSI = { 180,/* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo ef_emlrtRSI = { 110,/* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo ff_emlrtRSI = { 90, /* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

static emlrtRSInfo hf_emlrtRSI = { 73, /* lineNo */
  "xzsvdc",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzsvdc.m"/* pathName */
};

/* Function Definitions */
void svd(const emlrtStack *sp, const real_T A[9], real_T U[9], real_T s[3],
         real_T V[9])
{
  real_T b_A[9];
  int32_T i;
  real_T b_s[3];
  real_T e[3];
  int32_T q;
  real_T work[3];
  int32_T m;
  int32_T qq;
  boolean_T apply_transform;
  real_T nrm;
  int32_T k;
  int32_T iter;
  real_T snorm;
  real_T rt;
  real_T r;
  boolean_T exitg1;
  int32_T exitg2;
  boolean_T exitg3;
  real_T f;
  real_T scale;
  real_T sqds;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &le_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  b_st.site = &me_emlrtRSI;
  c_st.site = &ne_emlrtRSI;
  memcpy(&b_A[0], &A[0], 9U * sizeof(real_T));
  for (i = 0; i < 3; i++) {
    b_s[i] = 0.0;
    e[i] = 0.0;
    work[i] = 0.0;
  }

  memset(&U[0], 0, 9U * sizeof(real_T));
  memset(&V[0], 0, 9U * sizeof(real_T));
  for (q = 0; q < 2; q++) {
    qq = q + 3 * q;
    apply_transform = false;
    d_st.site = &hf_emlrtRSI;
    nrm = xnrm2(&d_st, 3 - q, b_A, qq + 1);
    if (nrm > 0.0) {
      apply_transform = true;
      if (b_A[qq] < 0.0) {
        b_s[q] = -nrm;
      } else {
        b_s[q] = nrm;
      }

      if (muDoubleScalarAbs(b_s[q]) >= 1.0020841800044864E-292) {
        nrm = 1.0 / b_s[q];
        i = (qq - q) + 3;
        for (k = qq; k < i; k++) {
          b_A[k] *= nrm;
        }
      } else {
        i = (qq - q) + 3;
        for (k = qq; k < i; k++) {
          b_A[k] /= b_s[q];
        }
      }

      b_A[qq]++;
      b_s[q] = -b_s[q];
    } else {
      b_s[q] = 0.0;
    }

    for (k = q + 1; k + 1 < 4; k++) {
      i = q + 3 * k;
      if (apply_transform) {
        d_st.site = &ff_emlrtRSI;
        nrm = xdotc(&d_st, 3 - q, b_A, qq + 1, b_A, i + 1);
        xaxpy(3 - q, -(nrm / b_A[q + 3 * q]), qq + 1, b_A, i + 1);
      }

      e[k] = b_A[i];
    }

    for (k = q; k + 1 < 4; k++) {
      U[k + 3 * q] = b_A[k + 3 * q];
    }

    if (q + 1 <= 1) {
      d_st.site = &ef_emlrtRSI;
      nrm = b_xnrm2(&d_st, e, 2);
      if (nrm == 0.0) {
        e[0] = 0.0;
      } else {
        if (e[1] < 0.0) {
          nrm = -nrm;
        }

        e[0] = nrm;
        if (muDoubleScalarAbs(nrm) >= 1.0020841800044864E-292) {
          nrm = 1.0 / nrm;
          for (k = 1; k < 3; k++) {
            e[k] *= nrm;
          }
        } else {
          for (k = 1; k < 3; k++) {
            e[k] /= nrm;
          }
        }

        e[1]++;
        e[0] = -e[0];
        for (k = 2; k < 4; k++) {
          work[k - 1] = 0.0;
        }

        for (k = 1; k + 1 < 4; k++) {
          b_xaxpy(2, e[k], b_A, 3 * k + 2, work, 2);
        }

        for (k = 1; k + 1 < 4; k++) {
          c_xaxpy(2, -e[k] / e[1], work, 2, b_A, 3 * k + 2);
        }
      }

      for (k = 1; k + 1 < 4; k++) {
        V[k] = e[k];
      }
    }
  }

  m = 1;
  b_s[2] = b_A[8];
  e[1] = b_A[7];
  e[2] = 0.0;
  for (k = 0; k < 3; k++) {
    U[6 + k] = 0.0;
  }

  U[8] = 1.0;
  for (q = 1; q >= 0; q--) {
    qq = q + 3 * q;
    if (b_s[q] != 0.0) {
      for (k = q + 1; k + 1 < 4; k++) {
        i = (q + 3 * k) + 1;
        d_st.site = &cf_emlrtRSI;
        nrm = xdotc(&d_st, 3 - q, U, qq + 1, U, i);
        xaxpy(3 - q, -(nrm / U[qq]), qq + 1, U, i);
      }

      for (k = q; k + 1 < 4; k++) {
        U[k + 3 * q] = -U[k + 3 * q];
      }

      U[qq]++;
      if (1 <= q) {
        U[3] = 0.0;
      }
    } else {
      for (k = 0; k < 3; k++) {
        U[k + 3 * q] = 0.0;
      }

      U[qq] = 1.0;
    }
  }

  for (q = 2; q >= 0; q--) {
    if ((q + 1 <= 1) && (e[0] != 0.0)) {
      for (k = 0; k < 2; k++) {
        i = 2 + 3 * (k + 1);
        d_st.site = &af_emlrtRSI;
        nrm = xdotc(&d_st, 2, V, 2, V, i);
        xaxpy(2, -(nrm / V[1]), 2, V, i);
      }
    }

    for (k = 0; k < 3; k++) {
      V[k + 3 * q] = 0.0;
    }

    V[q + 3 * q] = 1.0;
  }

  for (q = 0; q < 3; q++) {
    nrm = e[q];
    if (b_s[q] != 0.0) {
      rt = muDoubleScalarAbs(b_s[q]);
      r = b_s[q] / rt;
      b_s[q] = rt;
      if (q + 1 < 3) {
        nrm = e[q] / r;
      }

      d_st.site = &ye_emlrtRSI;
      xscal(&d_st, r, U, 1 + 3 * q);
    }

    if ((q + 1 < 3) && (nrm != 0.0)) {
      rt = muDoubleScalarAbs(nrm);
      r = rt / nrm;
      nrm = rt;
      b_s[q + 1] *= r;
      d_st.site = &xe_emlrtRSI;
      xscal(&d_st, r, V, 1 + 3 * (q + 1));
    }

    e[q] = nrm;
  }

  iter = 0;
  snorm = 0.0;
  for (k = 0; k < 3; k++) {
    snorm = muDoubleScalarMax(snorm, muDoubleScalarMax(muDoubleScalarAbs(b_s[k]),
      muDoubleScalarAbs(e[k])));
  }

  exitg1 = false;
  while ((!exitg1) && (m + 2 > 0)) {
    if (iter >= 75) {
      d_st.site = &we_emlrtRSI;
      b_error(&d_st);
    } else {
      k = m;
      do {
        exitg2 = 0;
        q = k + 1;
        if (k + 1 == 0) {
          exitg2 = 1;
        } else {
          nrm = muDoubleScalarAbs(e[k]);
          if ((nrm <= 2.2204460492503131E-16 * (muDoubleScalarAbs(b_s[k]) +
                muDoubleScalarAbs(b_s[k + 1]))) || (nrm <=
               1.0020841800044864E-292) || ((iter > 20) && (nrm <=
                2.2204460492503131E-16 * snorm))) {
            e[k] = 0.0;
            exitg2 = 1;
          } else {
            k--;
          }
        }
      } while (exitg2 == 0);

      if (k + 1 == m + 1) {
        i = 4;
      } else {
        qq = m + 2;
        i = m + 2;
        exitg3 = false;
        while ((!exitg3) && (i >= k + 1)) {
          qq = i;
          if (i == k + 1) {
            exitg3 = true;
          } else {
            nrm = 0.0;
            if (i < m + 2) {
              nrm = muDoubleScalarAbs(e[i - 1]);
            }

            if (i > k + 2) {
              nrm += muDoubleScalarAbs(e[i - 2]);
            }

            r = muDoubleScalarAbs(b_s[i - 1]);
            if ((r <= 2.2204460492503131E-16 * nrm) || (r <=
                 1.0020841800044864E-292)) {
              b_s[i - 1] = 0.0;
              exitg3 = true;
            } else {
              i--;
            }
          }
        }

        if (qq == k + 1) {
          i = 3;
        } else if (qq == m + 2) {
          i = 1;
        } else {
          i = 2;
          q = qq;
        }
      }

      switch (i) {
       case 1:
        f = e[m];
        e[m] = 0.0;
        for (k = m; k + 1 >= q + 1; k--) {
          xrotg(&b_s[k], &f, &nrm, &r);
          if (k + 1 > q + 1) {
            f = -r * e[0];
            e[0] *= nrm;
          }

          xrot(V, 1 + 3 * k, 1 + 3 * (m + 1), nrm, r);
        }
        break;

       case 2:
        f = e[q - 1];
        e[q - 1] = 0.0;
        for (k = q; k < m + 2; k++) {
          xrotg(&b_s[k], &f, &nrm, &r);
          f = -r * e[k];
          e[k] *= nrm;
          xrot(U, 1 + 3 * k, 1 + 3 * (q - 1), nrm, r);
        }
        break;

       case 3:
        scale = muDoubleScalarMax(muDoubleScalarMax(muDoubleScalarMax
          (muDoubleScalarMax(muDoubleScalarAbs(b_s[m + 1]), muDoubleScalarAbs
                             (b_s[m])), muDoubleScalarAbs(e[m])),
          muDoubleScalarAbs(b_s[q])), muDoubleScalarAbs(e[q]));
        f = b_s[m + 1] / scale;
        nrm = b_s[m] / scale;
        r = e[m] / scale;
        sqds = b_s[q] / scale;
        rt = ((nrm + f) * (nrm - f) + r * r) / 2.0;
        nrm = f * r;
        nrm *= nrm;
        if ((rt != 0.0) || (nrm != 0.0)) {
          r = rt * rt + nrm;
          d_st.site = &se_emlrtRSI;
          b_sqrt(&d_st, &r);
          if (rt < 0.0) {
            r = -r;
          }

          r = nrm / (rt + r);
        } else {
          r = 0.0;
        }

        f = (sqds + f) * (sqds - f) + r;
        rt = sqds * (e[q] / scale);
        for (k = q + 1; k <= m + 1; k++) {
          xrotg(&f, &rt, &nrm, &r);
          if (k > q + 1) {
            e[0] = f;
          }

          f = nrm * b_s[k - 1] + r * e[k - 1];
          e[k - 1] = nrm * e[k - 1] - r * b_s[k - 1];
          rt = r * b_s[k];
          b_s[k] *= nrm;
          xrot(V, 1 + 3 * (k - 1), 1 + 3 * k, nrm, r);
          b_s[k - 1] = f;
          xrotg(&b_s[k - 1], &rt, &nrm, &r);
          f = nrm * e[k - 1] + r * b_s[k];
          b_s[k] = -r * e[k - 1] + nrm * b_s[k];
          rt = r * e[k];
          e[k] *= nrm;
          xrot(U, 1 + 3 * (k - 1), 1 + 3 * k, nrm, r);
        }

        e[m] = f;
        iter++;
        break;

       default:
        if (b_s[q] < 0.0) {
          b_s[q] = -b_s[q];
          d_st.site = &oe_emlrtRSI;
          xscal(&d_st, -1.0, V, 1 + 3 * q);
        }

        i = q + 1;
        while ((q + 1 < 3) && (b_s[q] < b_s[i])) {
          rt = b_s[q];
          b_s[q] = b_s[i];
          b_s[i] = rt;
          xswap(V, 1 + 3 * q, 1 + 3 * (q + 1));
          xswap(U, 1 + 3 * q, 1 + 3 * (q + 1));
          q = i;
          i++;
        }

        iter = 0;
        m--;
        break;
      }
    }
  }

  for (k = 0; k < 3; k++) {
    s[k] = b_s[k];
  }
}

/* End of code generation (svd1.c) */
