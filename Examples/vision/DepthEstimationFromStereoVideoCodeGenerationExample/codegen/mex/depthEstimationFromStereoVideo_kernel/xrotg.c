/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * xrotg.c
 *
 * Code generation for function 'xrotg'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "xrotg.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "blas.h"

/* Function Definitions */
void xrotg(real_T *a, real_T *b, real_T *c, real_T *s)
{
  *c = 0.0;
  *s = 0.0;
  drotg(a, b, c, s);
}

/* End of code generation (xrotg.c) */
