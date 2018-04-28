/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: callpolymorphic.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 27-Apr-2018 21:18:23
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "callpolymorphic.h"

/* Function Definitions */

/*
 * CALLPOLYMORHIC Summary of this function goes here
 *    Detailed explanation goes here
 * Arguments    : const MakePolymorphic mp
 * Return Type  : int
 */
int callpolymorphic(const MakePolymorphic mp)
{
  int y;
  int i;

  /*  Setup */
  y = 0;

  /*  Algorithm */
  for (i = 0; i < 10; i++) {
    y += mp.u[i];
  }

  /*  Cleanup */
  return y;
}

/*
 * File trailer for callpolymorphic.c
 *
 * [EOF]
 */
