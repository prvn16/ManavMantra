/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: eml_rand_shr3cong_stateful.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 26-Apr-2018 10:39:55
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "coderand.h"
#include "eml_rand_shr3cong_stateful.h"
#include "coderand_data.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : void
 */
void eml_rand_shr3cong_stateful_init(void)
{
  int i0;
  for (i0 = 0; i0 < 2; i0++) {
    b_state[i0] = 362436069U + 158852560U * i0;
  }
}

/*
 * File trailer for eml_rand_shr3cong_stateful.c
 *
 * [EOF]
 */
