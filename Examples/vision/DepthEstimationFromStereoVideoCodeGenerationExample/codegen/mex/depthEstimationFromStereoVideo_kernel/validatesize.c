/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * validatesize.c
 *
 * Code generation for function 'validatesize'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "validatesize.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
boolean_T size_check(const int32_T a_size[2])
{
  boolean_T p;
  static real_T dv9[2] = { 0.0, 3.0 };

  int32_T k;
  boolean_T exitg1;
  dv9[0U] = rtNaN;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (muDoubleScalarIsNaN(dv9[k]) || (dv9[k] == a_size[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  return p;
}

/* End of code generation (validatesize.c) */
