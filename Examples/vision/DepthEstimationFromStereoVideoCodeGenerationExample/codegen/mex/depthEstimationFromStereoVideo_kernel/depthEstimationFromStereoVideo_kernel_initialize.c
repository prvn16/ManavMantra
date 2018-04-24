/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * depthEstimationFromStereoVideo_kernel_initialize.c
 *
 * Code generation for function 'depthEstimationFromStereoVideo_kernel_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "depthEstimationFromStereoVideo_kernel_initialize.h"
#include "createShapeInserter_cg.h"
#include "matlabCodegenHandle.h"
#include "_coder_depthEstimationFromStereoVideo_kernel_mex.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void c_depthEstimationFromStereoVide(void);

/* Function Definitions */
static void c_depthEstimationFromStereoVide(void)
{
  const mxArray *m0;
  static const int32_T iv1[2] = { 0, 0 };

  static const int32_T iv2[2] = { 0, 0 };

  emlrtAssignP(&b_eml_mx, NULL);
  emlrtAssignP(&eml_mx, NULL);
  m0 = emlrtCreateNumericArray(2, iv1, mxDOUBLE_CLASS, mxREAL);
  emlrtAssignP(&b_eml_mx, m0);
  m0 = emlrtCreateCharArray(2, iv2);
  emlrtAssignP(&eml_mx, m0);
  createShapeInserter_cg_init();
}

void depthEstimationFromStereoVideo_kernel_initialize(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtLicenseCheckR2012b(&st, "Video_and_Image_Blockset", 2);
  emlrtLicenseCheckR2012b(&st, "Image_Toolbox", 2);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    c_depthEstimationFromStereoVide();
  }
}

/* End of code generation (depthEstimationFromStereoVideo_kernel_initialize.c) */
