/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: kalman02_initialize.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 26-Apr-2018 11:06:36
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "kalman02.h"
#include "kalman02_initialize.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : void
 */
void kalman02_initialize(void)
{
  rt_InitInfAndNaN(8U);
  kalman02_init();
}

/*
 * File trailer for kalman02_initialize.c
 *
 * [EOF]
 */
