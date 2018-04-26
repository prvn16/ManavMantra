/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: kalman03_initialize.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 26-Apr-2018 11:07:25
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "kalman03.h"
#include "kalman03_initialize.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : void
 */
void kalman03_initialize(void)
{
  rt_InitInfAndNaN(8U);
  kalman03_init();
}

/*
 * File trailer for kalman03_initialize.c
 *
 * [EOF]
 */
