/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: eml_rand_mt19937ar_stateful.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "eml_rand_mt19937ar_stateful.h"
#include "faceTrackingARMKernel_data.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : void
 */
void c_eml_rand_mt19937ar_stateful_i(void)
{
  unsigned int r;
  int mti;
  memset(&state[0], 0, 625U * sizeof(unsigned int));
  r = 5489U;
  state[0] = 5489U;
  for (mti = 0; mti < 623; mti++) {
    r = ((r ^ r >> 30U) * 1812433253U + mti) + 1U;
    state[mti + 1] = r;
  }

  state[624] = 624U;
}

/*
 * File trailer for eml_rand_mt19937ar_stateful.c
 *
 * [EOF]
 */
