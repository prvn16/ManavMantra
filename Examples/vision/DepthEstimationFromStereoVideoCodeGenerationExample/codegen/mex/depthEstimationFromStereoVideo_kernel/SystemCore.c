/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * SystemCore.c
 *
 * Code generation for function 'SystemCore'
 *
 */

/* Include files */
#include <string.h>
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "SystemCore.h"
#include "ShapeInserter.h"
#include "matlabCodegenHandle.h"
#include "PeopleDetector.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
void SystemCore_step(const emlrtStack *sp, vision_PeopleDetector *obj, const
                     emxArray_uint8_T *varargin_1, emxArray_real_T *varargout_1)
{
  int32_T k;
  uint32_T inSize[8];
  cell_wrap_3 varSizes[1];
  boolean_T exitg1;
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
  if (obj->isInitialized == 2) {
    emlrtErrorWithMessageIdR2018a(sp, &oe_emlrtRTEI,
      "MATLAB:system:methodCalledWhenReleasedCodegen",
      "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
  }

  if (obj->isInitialized != 1) {
    st.site = &ud_emlrtRSI;
    b_st.site = &ud_emlrtRSI;
    obj->isSetupComplete = false;
    if (obj->isInitialized != 0) {
      emlrtErrorWithMessageIdR2018a(&b_st, &oe_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen",
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    obj->isInitialized = 1;
    c_st.site = &ud_emlrtRSI;
    for (k = 0; k < 2; k++) {
      varSizes[0].f1[k] = (uint32_T)varargin_1->size[k];
    }

    for (k = 0; k < 6; k++) {
      varSizes[0].f1[k + 2] = 1U;
    }

    obj->inputVarSize[0] = varSizes[0];
    c_st.site = &ud_emlrtRSI;
    d_st.site = &ud_emlrtRSI;
    c_PeopleDetector_validateProper(&d_st, obj);
    obj->isSetupComplete = true;
    obj->TunablePropsChanged = false;
  }

  st.site = &ud_emlrtRSI;
  if (obj->TunablePropsChanged) {
    b_st.site = &ud_emlrtRSI;
    c_PeopleDetector_validateProper(&b_st, obj);
    obj->TunablePropsChanged = false;
  }

  st.site = &ud_emlrtRSI;
  for (k = 0; k < 2; k++) {
    inSize[k] = (uint32_T)varargin_1->size[k];
  }

  for (k = 0; k < 6; k++) {
    inSize[k + 2] = 1U;
  }

  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 8)) {
    if (obj->inputVarSize[0].f1[k] != inSize[k]) {
      for (k = 0; k < 8; k++) {
        obj->inputVarSize[0].f1[k] = inSize[k];
      }

      exitg1 = true;
    } else {
      k++;
    }
  }

  st.site = &ud_emlrtRSI;
  PeopleDetector_stepImpl(&st, obj, varargin_1, varargout_1);
}

void b_SystemCore_step(const emlrtStack *sp, visioncodegen_ShapeInserter *obj,
  const uint8_T varargin_1[1108698], const int32_T varargin_2_data[], const
  int32_T varargin_2_size[2], const uint8_T varargin_3_data[], const int32_T
  varargin_3_size[2], uint8_T varargout_1[1108698])
{
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (obj->isInitialized == 2) {
    emlrtErrorWithMessageIdR2018a(sp, &oe_emlrtRTEI,
      "MATLAB:system:methodCalledWhenReleasedCodegen",
      "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
  }

  if (obj->isInitialized != 1) {
    st.site = &ud_emlrtRSI;
    b_st.site = &ud_emlrtRSI;
    obj->isSetupComplete = false;
    if (obj->isInitialized != 0) {
      emlrtErrorWithMessageIdR2018a(&b_st, &oe_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen",
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    obj->isInitialized = 1;
    obj->c_NoTuningBeforeLockingCodeGenE = true;
    obj->isSetupComplete = true;
  }

  st.site = &ud_emlrtRSI;
  memcpy(&varargout_1[0], &varargin_1[0], 1108698U * sizeof(uint8_T));
  b_st.site = &vd_emlrtRSI;
  ShapeInserter_outputImpl(&b_st, obj, varargout_1, varargin_2_data,
    varargin_2_size, varargin_3_data, varargin_3_size);
}

/* End of code generation (SystemCore.c) */
