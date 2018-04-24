/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * insertObjectAnnotation.c
 *
 * Code generation for function 'insertObjectAnnotation'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "insertObjectAnnotation.h"
#include "matlabCodegenHandle.h"
#include "bwtraceboundary.h"
#include "assertValidSizeArg.h"
#include "all.h"
#include "depthEstimationFromStereoVideo_kernel_mexutil.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRTEInfo ee_emlrtRTEI = { 1,/* lineNo */
  1,                                   /* colNo */
  "insertObjectAnnotation",            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertObjectAnnotation.p"/* pName */
};

static emlrtECInfo x_emlrtECI = { -1,  /* nDims */
  1,                                   /* lineNo */
  1,                                   /* colNo */
  "insertObjectAnnotation",            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertObjectAnnotation.p"/* pName */
};

/* Function Definitions */
void getTextLocAndWidth(const emlrtStack *sp, const int32_T position_data[],
  const int32_T position_size[2], int32_T textLocAndWidth_data[], int32_T
  textLocAndWidth_size[2])
{
  int32_T loop_ub;
  int32_T i46;
  int32_T b_loop_ub;
  int32_T q0;
  int32_T iv29[1];
  int8_T tmp_data[99];
  int32_T iv30[1];
  int32_T b_textLocAndWidth_data[99];
  loop_ub = position_size[0];
  textLocAndWidth_size[0] = position_size[0];
  textLocAndWidth_size[1] = 4;
  for (i46 = 0; i46 < 4; i46++) {
    for (q0 = 0; q0 < loop_ub; q0++) {
      textLocAndWidth_data[q0 + loop_ub * i46] = position_data[q0 +
        position_size[0] * i46];
    }
  }

  b_loop_ub = (int8_T)position_size[0] - 1;
  for (i46 = 0; i46 <= b_loop_ub; i46++) {
    tmp_data[i46] = (int8_T)i46;
  }

  iv29[0] = (int8_T)position_size[0];
  iv30[0] = position_size[0];
  emlrtSubAssignSizeCheckR2012b(&iv29[0], 1, &iv30[0], 1, &x_emlrtECI, sp);
  b_loop_ub = position_size[0];
  for (i46 = 0; i46 < b_loop_ub; i46++) {
    q0 = textLocAndWidth_data[i46 + loop_ub];
    if (q0 < -2147483647) {
      q0 = MIN_int32_T;
    } else {
      q0--;
    }

    b_textLocAndWidth_data[i46] = q0;
  }

  b_loop_ub = position_size[0];
  for (i46 = 0; i46 < b_loop_ub; i46++) {
    textLocAndWidth_data[tmp_data[i46] + loop_ub] = b_textLocAndWidth_data[i46];
  }

  b_loop_ub = (int8_T)position_size[0] - 1;
  for (i46 = 0; i46 <= b_loop_ub; i46++) {
    tmp_data[i46] = (int8_T)i46;
  }

  iv29[0] = (int8_T)position_size[0];
  iv30[0] = position_size[0];
  emlrtSubAssignSizeCheckR2012b(&iv29[0], 1, &iv30[0], 1, &x_emlrtECI, sp);
  q0 = position_size[0];
  if (0 <= q0 - 1) {
    memcpy(&b_textLocAndWidth_data[0], &textLocAndWidth_data[0], (uint32_T)(q0 *
            (int32_T)sizeof(int32_T)));
  }

  b_loop_ub = position_size[0];
  for (i46 = 0; i46 < b_loop_ub; i46++) {
    textLocAndWidth_data[tmp_data[i46]] = b_textLocAndWidth_data[i46];
  }

  b_loop_ub = (int8_T)position_size[0] - 1;
  for (i46 = 0; i46 <= b_loop_ub; i46++) {
    tmp_data[i46] = (int8_T)i46;
  }

  iv29[0] = (int8_T)position_size[0];
  iv30[0] = position_size[0];
  emlrtSubAssignSizeCheckR2012b(&iv29[0], 1, &iv30[0], 1, &x_emlrtECI, sp);
  q0 = position_size[0];
  for (i46 = 0; i46 < q0; i46++) {
    b_textLocAndWidth_data[i46] = textLocAndWidth_data[i46 + (loop_ub << 1)];
  }

  b_loop_ub = position_size[0];
  for (i46 = 0; i46 < b_loop_ub; i46++) {
    textLocAndWidth_data[tmp_data[i46] + (loop_ub << 1)] =
      b_textLocAndWidth_data[i46];
  }
}

void validateAndParseInputs(const emlrtStack *sp, const real_T position_data[],
  const int32_T position_size[2], const real32_T label_data[], const int32_T
  label_size[2], int32_T b_position_data[], int32_T b_position_size[2], uint8_T
  color_data[], int32_T color_size[2], uint8_T textColor_data[], int32_T
  textColor_size[2], boolean_T *isEmpty)
{
  boolean_T p;
  int32_T ibmat;
  int32_T ntilerows;
  boolean_T exitg1;
  real_T d2;
  int32_T jcol;
  real_T varargin_1[2];
  const mxArray *y;
  const mxArray *m14;
  static const int32_T iv33[2] = { 1, 15 };

  int32_T itilerow;
  static const uint8_T uv1[3] = { MAX_uint8_T, MAX_uint8_T, 0U };

  static const int32_T iv34[2] = { 1, 15 };

  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &xp_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &ic_emlrtRSI;
  p = true;
  ibmat = position_size[0] << 2;
  ntilerows = 0;
  exitg1 = false;
  while ((!exitg1) && (ntilerows <= ibmat - 1)) {
    if ((!muDoubleScalarIsInf(position_data[ntilerows])) &&
        (!muDoubleScalarIsNaN(position_data[ntilerows]))) {
      ntilerows++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:insertObjectAnnotation:expectedFinite", 3, 4, 25,
      "input number 3, POSITION,");
  }

  b_position_size[0] = position_size[0];
  b_position_size[1] = 4;
  ntilerows = position_size[0] * position_size[1];
  for (ibmat = 0; ibmat < ntilerows; ibmat++) {
    d2 = muDoubleScalarRound(position_data[ibmat]);
    if (d2 < 2.147483648E+9) {
      if (d2 >= -2.147483648E+9) {
        jcol = (int32_T)d2;
      } else {
        jcol = MIN_int32_T;
      }
    } else if (d2 >= 2.147483648E+9) {
      jcol = MAX_int32_T;
    } else {
      jcol = 0;
    }

    b_position_data[ibmat] = jcol;
  }

  *isEmpty = (position_size[0] == 0);
  st.site = &xp_emlrtRSI;
  b_st.site = &xp_emlrtRSI;
  c_st.site = &ic_emlrtRSI;
  p = true;
  ntilerows = 0;
  exitg1 = false;
  while ((!exitg1) && (ntilerows <= label_size[1] - 1)) {
    if (!muSingleScalarIsNaN(label_data[ntilerows])) {
      ntilerows++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&c_st, &xe_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:insertObjectAnnotation:expectedNonNaN", 3, 4, 5, "LABEL");
  }

  c_st.site = &ic_emlrtRSI;
  p = b_all(label_data, label_size);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:insertObjectAnnotation:expectedFinite", 3, 4, 5, "LABEL");
  }

  c_st.site = &ic_emlrtRSI;
  if (label_size[1] == 0) {
    emlrtErrorWithMessageIdR2018a(&c_st, &kf_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonempty",
      "MATLAB:insertObjectAnnotation:expectedNonempty", 3, 4, 5, "LABEL");
  }

  st.site = &xp_emlrtRSI;
  if ((label_size[1] != 1) && (label_size[1] != position_size[0])) {
    p = true;
  } else {
    p = false;
  }

  b_st.site = &xp_emlrtRSI;
  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ee_emlrtRTEI,
      "vision:insertObjectAnnotation:invalidNumLabels",
      "vision:insertObjectAnnotation:invalidNumLabels", 0);
  }

  st.site = &xp_emlrtRSI;
  b_st.site = &xp_emlrtRSI;
  varargin_1[0] = position_size[0];
  varargin_1[1] = 1.0;
  c_st.site = &ck_emlrtRSI;
  assertValidSizeArg(&c_st, varargin_1);
  if ((int8_T)position_size[0] != position_size[0]) {
    y = NULL;
    m14 = emlrtCreateCharArray(2, iv33);
    emlrtInitCharArrayR2013a(&b_st, 15, m14, &cv1[0]);
    emlrtAssign(&y, m14);
    c_st.site = &qs_emlrtRSI;
    f_error(&c_st, y, &d_emlrtMCI);
  }

  color_size[0] = (int8_T)position_size[0];
  color_size[1] = 3;
  ntilerows = position_size[0];
  c_st.site = &aq_emlrtRSI;
  for (jcol = 0; jcol < 3; jcol++) {
    ibmat = jcol * ntilerows;
    c_st.site = &yp_emlrtRSI;
    for (itilerow = 1; itilerow <= ntilerows; itilerow++) {
      color_data[(ibmat + itilerow) - 1] = uv1[jcol];
    }
  }

  st.site = &xp_emlrtRSI;
  b_st.site = &xp_emlrtRSI;
  varargin_1[0] = position_size[0];
  varargin_1[1] = 1.0;
  c_st.site = &ck_emlrtRSI;
  assertValidSizeArg(&c_st, varargin_1);
  if ((int8_T)position_size[0] != position_size[0]) {
    y = NULL;
    m14 = emlrtCreateCharArray(2, iv34);
    emlrtInitCharArrayR2013a(&b_st, 15, m14, &cv1[0]);
    emlrtAssign(&y, m14);
    c_st.site = &qs_emlrtRSI;
    f_error(&c_st, y, &d_emlrtMCI);
  }

  textColor_size[0] = (int8_T)position_size[0];
  textColor_size[1] = 3;
  ntilerows = position_size[0];
  c_st.site = &aq_emlrtRSI;
  for (jcol = 0; jcol < 3; jcol++) {
    ibmat = jcol * ntilerows;
    c_st.site = &yp_emlrtRSI;
    for (itilerow = 1; itilerow <= ntilerows; itilerow++) {
      textColor_data[(ibmat + itilerow) - 1] = 0U;
    }
  }
}

/* End of code generation (insertObjectAnnotation.c) */
