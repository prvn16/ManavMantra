/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * PeopleDetector.h
 *
 * Code generation for function 'PeopleDetector'
 *
 */

#ifndef PEOPLEDETECTOR_H
#define PEOPLEDETECTOR_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "depthEstimationFromStereoVideo_kernel_types.h"

/* Function Declarations */
extern vision_PeopleDetector *PeopleDetector_PeopleDetector(const emlrtStack *sp,
  vision_PeopleDetector *obj);
extern void PeopleDetector_stepImpl(const emlrtStack *sp, const
  vision_PeopleDetector *obj, const emxArray_uint8_T *I, emxArray_real_T *bbox);
extern void c_PeopleDetector_validateProper(const emlrtStack *sp, const
  vision_PeopleDetector *obj);

#endif

/* End of code generation (PeopleDetector.h) */
