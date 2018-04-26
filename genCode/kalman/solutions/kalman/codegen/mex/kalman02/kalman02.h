/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * kalman02.h
 *
 * Code generation for function 'kalman02'
 *
 */

#ifndef KALMAN02_H
#define KALMAN02_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "kalman02_types.h"

/* Function Declarations */
extern void kalman02(const emlrtStack *sp, const real_T z[2], real_T y[2]);
extern void kalman02_init(void);

#endif

/* End of code generation (kalman02.h) */
