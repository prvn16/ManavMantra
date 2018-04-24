/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * rodriguesVectorToMatrix.c
 *
 * Code generation for function 'rodriguesVectorToMatrix'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "rodriguesVectorToMatrix.h"
#include "norm.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
void rodriguesVectorToMatrix(const real_T rotationVector[3], real_T
  rotationMatrix[9])
{
  real_T theta;
  int32_T i;
  real_T alpha;
  real_T u[3];
  int32_T i5;
  real_T beta[9];
  int8_T I[9];
  real_T b_u[9];
  theta = norm(rotationVector);
  if (theta < 1.0E-6) {
    memset(&rotationMatrix[0], 0, 9U * sizeof(real_T));
    for (i = 0; i < 3; i++) {
      rotationMatrix[i + 3 * i] = 1.0;
    }
  } else {
    for (i = 0; i < 3; i++) {
      u[i] = rotationVector[i] / theta;
    }

    alpha = muDoubleScalarCos(theta);
    theta = muDoubleScalarSin(theta);
    for (i5 = 0; i5 < 9; i5++) {
      I[i5] = 0;
    }

    beta[0] = theta * 0.0;
    beta[3] = theta * -u[2];
    beta[6] = theta * u[1];
    beta[1] = theta * u[2];
    beta[4] = theta * 0.0;
    beta[7] = theta * -u[0];
    beta[2] = theta * -u[1];
    beta[5] = theta * u[0];
    beta[8] = theta * 0.0;
    for (i = 0; i < 3; i++) {
      I[i + 3 * i] = 1;
      for (i5 = 0; i5 < 3; i5++) {
        b_u[i + 3 * i5] = u[i] * u[i5];
      }
    }

    for (i5 = 0; i5 < 3; i5++) {
      for (i = 0; i < 3; i++) {
        rotationMatrix[i + 3 * i5] = ((real_T)I[i + 3 * i5] * alpha + beta[i + 3
          * i5]) + (1.0 - alpha) * b_u[i + 3 * i5];
      }
    }
  }
}

/* End of code generation (rodriguesVectorToMatrix.c) */
