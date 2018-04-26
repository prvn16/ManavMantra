/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: kalman03.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 26-Apr-2018 11:07:25
 */

#ifndef KALMAN03_H
#define KALMAN03_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "kalman03_types.h"

/* Function Declarations */
extern void kalman03(const double z_data[], const int z_size[2], double y_data[],
                     int y_size[2]);
extern void kalman03_init(void);

#endif

/*
 * File trailer for kalman03.h
 *
 * [EOF]
 */
