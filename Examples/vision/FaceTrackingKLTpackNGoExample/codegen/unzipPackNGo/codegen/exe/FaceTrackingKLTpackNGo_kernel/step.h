/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: step.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

#ifndef STEP_H
#define STEP_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "FaceTrackingKLTpackNGo_kernel_types.h"

/* Function Declarations */
extern vision_VideoFileReader_0 *Constructor(vision_VideoFileReader_0 *obj);
extern void InitializeConditions(vision_VideoFileReader_0 *obj);
extern void Outputs(vision_VideoFileReader_0 *obj, float Y0[921600], boolean_T
                    *Y1, boolean_T *Y2);
extern void Start(vision_VideoFileReader_0 *obj);

#endif

/*
 * File trailer for step.h
 *
 * [EOF]
 */
