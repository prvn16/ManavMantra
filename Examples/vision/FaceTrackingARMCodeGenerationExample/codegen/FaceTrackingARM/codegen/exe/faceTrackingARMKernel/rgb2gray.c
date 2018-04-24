/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: rgb2gray.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "rgb2gray.h"
#include "insertShape.h"
#include "faceTrackingARMKernel_rtwutil.h"

/* Function Definitions */

/*
 * Arguments    : const unsigned char X[921600]
 *                unsigned char I[307200]
 * Return Type  : void
 */
void rgb2gray(const unsigned char X[921600], unsigned char I[307200])
{
  int i;
  unsigned char b_X[3];
  double d0;
  int i1;
  static const double b[3] = { 0.29893602129377539, 0.58704307445112125,
    0.11402090425510336 };

  unsigned char u0;
  for (i = 0; i < 307200; i++) {
    b_X[0] = X[i];
    b_X[1] = X[i + 307200];
    b_X[2] = X[i + 614400];
    d0 = 0.0;
    for (i1 = 0; i1 < 3; i1++) {
      d0 += (double)b_X[i1] * b[i1];
    }

    d0 = rt_roundd_snf(d0);
    if (d0 < 256.0) {
      u0 = (unsigned char)d0;
    } else {
      u0 = MAX_uint8_T;
    }

    I[i] = u0;
  }
}

/*
 * File trailer for rgb2gray.c
 *
 * [EOF]
 */
