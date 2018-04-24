/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * xgeqp3.h
 *
 * Code generation for function 'xgeqp3'
 *
 */

#ifndef XGEQP3_H
#define XGEQP3_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "visionRecovertformCodeGeneration_kernel_types.h"

/* Function Declarations */
extern void xgeqp3(const emlrtStack *sp, real32_T A_data[], int32_T A_size[2],
                   real32_T tau_data[], int32_T tau_size[1], int32_T jpvt_data[],
                   int32_T jpvt_size[2]);

#endif

/* End of code generation (xgeqp3.h) */
