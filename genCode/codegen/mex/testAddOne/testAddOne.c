/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * testAddOne.c
 *
 * Code generation for function 'testAddOne'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "testAddOne.h"

/* Function Definitions */
real_T testAddOne(const emlrtStack *sp, real_T x)
{
  (void)sp;

  /*  ADDONE Compute an output value that increments the input by one */
  /*  stepImpl method is called by the step method */
  return x + 1.0;
}

/* End of code generation (testAddOne.c) */
