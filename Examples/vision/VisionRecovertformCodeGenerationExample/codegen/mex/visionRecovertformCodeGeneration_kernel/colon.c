/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * colon.c
 *
 * Code generation for function 'colon'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "colon.h"
#include "eml_int_forloop_overflow_check.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo wj_emlrtRSI = { 149,/* lineNo */
  "colon",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m"/* pathName */
};

/* Function Definitions */
void eml_signed_integer_colon(const emlrtStack *sp, int32_T b, int32_T y_data[],
  int32_T y_size[2])
{
  int32_T n;
  int32_T yk;
  int32_T k;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (b < 1) {
    n = 0;
  } else {
    n = b;
  }

  y_size[0] = 1;
  y_size[1] = n;
  if (n > 0) {
    y_data[0] = 1;
    yk = 1;
    st.site = &wj_emlrtRSI;
    if ((!(2 > n)) && (n > 2147483646)) {
      b_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&b_st);
    }

    for (k = 2; k <= n; k++) {
      yk++;
      y_data[k - 1] = yk;
    }
  }
}

/* End of code generation (colon.c) */
