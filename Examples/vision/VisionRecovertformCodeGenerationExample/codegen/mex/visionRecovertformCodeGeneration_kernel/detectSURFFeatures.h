/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * detectSURFFeatures.h
 *
 * Code generation for function 'detectSURFFeatures'
 *
 */

#ifndef DETECTSURFFEATURES_H
#define DETECTSURFFEATURES_H

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
extern void detectSURFFeatures(const emlrtStack *sp, const emxArray_uint8_T *I,
  vision_internal_SURFPoints_cg *Pts);

#endif

/* End of code generation (detectSURFFeatures.h) */
