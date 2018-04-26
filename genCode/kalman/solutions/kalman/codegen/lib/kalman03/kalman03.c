/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: kalman03.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 26-Apr-2018 11:07:25
 */

/* Include Files */
#include <math.h>
#include <string.h>
#include "rt_nonfinite.h"
#include "kalman03.h"

/* Variable Definitions */
static double x_est[6];
static double p_est[36];

/* Function Definitions */

/*
 * Initialize state transition matrix
 * Arguments    : const double z_data[]
 *                const int z_size[2]
 *                double y_data[]
 *                int y_size[2]
 * Return Type  : void
 */
void kalman03(const double z_data[], const int z_size[2], double y_data[], int
              y_size[2])
{
  int k;
  signed char Q[36];
  signed char iv0[2];
  int i;
  double x_prd[6];
  int r1;
  double S[4];
  double a[36];
  int r2;
  double b_a[12];
  double a21;
  static const signed char c_a[36] = { 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0,
    1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1 };

  double a22;
  static const signed char d_a[12] = { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 };

  double p_prd[36];
  static const signed char b[36] = { 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1,
    0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1 };

  double B[12];
  static const short R[4] = { 1000, 0, 0, 1000 };

  static const signed char b_b[12] = { 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 };

  double Y[12];
  double z[2];

  /*  */
  /*    --------------------------------------------------------------------- */
  /*  */
  /*    Copyright 2011 The MathWorks, Inc. */
  /*  */
  /*    --------------------------------------------------------------------- */
  /*  */
  /*  Measurement matrix */
  for (k = 0; k < 36; k++) {
    Q[k] = 0;
  }

  for (k = 0; k < 6; k++) {
    Q[k + 6 * k] = 1;
  }

  /*  Initial conditions */
  for (k = 0; k < 2; k++) {
    iv0[k] = (signed char)z_size[k];
  }

  y_size[0] = 2;
  y_size[1] = iv0[1];
  k = iv0[1] << 1;
  if (0 <= k - 1) {
    memset(&y_data[0], 0, (unsigned int)(k * (int)sizeof(double)));
  }

  for (i = 0; i < z_size[1]; i++) {
    /*  Predicted state and covariance */
    for (k = 0; k < 6; k++) {
      x_prd[k] = 0.0;
      for (r1 = 0; r1 < 6; r1++) {
        a[k + 6 * r1] = 0.0;
        for (r2 = 0; r2 < 6; r2++) {
          a[k + 6 * r1] += (double)c_a[k + 6 * r2] * p_est[r2 + 6 * r1];
        }

        x_prd[k] += (double)c_a[k + 6 * r1] * x_est[r1];
      }

      for (r1 = 0; r1 < 6; r1++) {
        a21 = 0.0;
        for (r2 = 0; r2 < 6; r2++) {
          a21 += a[k + 6 * r2] * (double)b[r2 + 6 * r1];
        }

        p_prd[k + 6 * r1] = a21 + (double)Q[k + 6 * r1];
      }
    }

    /*  Estimation */
    for (k = 0; k < 2; k++) {
      for (r1 = 0; r1 < 6; r1++) {
        b_a[k + (r1 << 1)] = 0.0;
        for (r2 = 0; r2 < 6; r2++) {
          b_a[k + (r1 << 1)] += (double)d_a[k + (r2 << 1)] * p_prd[r1 + 6 * r2];
        }
      }

      for (r1 = 0; r1 < 2; r1++) {
        a21 = 0.0;
        for (r2 = 0; r2 < 6; r2++) {
          a21 += b_a[k + (r2 << 1)] * (double)b_b[r2 + 6 * r1];
        }

        S[k + (r1 << 1)] = a21 + (double)R[k + (r1 << 1)];
      }

      for (r1 = 0; r1 < 6; r1++) {
        B[k + (r1 << 1)] = 0.0;
        for (r2 = 0; r2 < 6; r2++) {
          B[k + (r1 << 1)] += (double)d_a[k + (r2 << 1)] * p_prd[r1 + 6 * r2];
        }
      }
    }

    if (fabs(S[1]) > fabs(S[0])) {
      r1 = 1;
      r2 = 0;
    } else {
      r1 = 0;
      r2 = 1;
    }

    a21 = S[r2] / S[r1];
    a22 = S[2 + r2] - a21 * S[2 + r1];
    for (k = 0; k < 6; k++) {
      b_a[1 + (k << 1)] = (B[r2 + (k << 1)] - B[r1 + (k << 1)] * a21) / a22;
      b_a[k << 1] = (B[r1 + (k << 1)] - b_a[1 + (k << 1)] * S[2 + r1]) / S[r1];
    }

    for (k = 0; k < 2; k++) {
      for (r1 = 0; r1 < 6; r1++) {
        Y[r1 + 6 * k] = b_a[k + (r1 << 1)];
      }
    }

    for (k = 0; k < 6; k++) {
      for (r1 = 0; r1 < 2; r1++) {
        B[r1 + (k << 1)] = Y[r1 + (k << 1)];
      }
    }

    /*  Estimated state and covariance */
    for (k = 0; k < 2; k++) {
      a21 = 0.0;
      for (r1 = 0; r1 < 6; r1++) {
        a21 += (double)d_a[k + (r1 << 1)] * x_prd[r1];
      }

      z[k] = z_data[k + z_size[0] * i] - a21;
    }

    for (k = 0; k < 6; k++) {
      a21 = 0.0;
      for (r1 = 0; r1 < 2; r1++) {
        a21 += B[k + 6 * r1] * z[r1];
      }

      x_est[k] = x_prd[k] + a21;
      for (r1 = 0; r1 < 6; r1++) {
        a[k + 6 * r1] = 0.0;
        for (r2 = 0; r2 < 2; r2++) {
          a[k + 6 * r1] += B[k + 6 * r2] * (double)d_a[r2 + (r1 << 1)];
        }
      }

      for (r1 = 0; r1 < 6; r1++) {
        a21 = 0.0;
        for (r2 = 0; r2 < 6; r2++) {
          a21 += a[k + 6 * r2] * p_prd[r2 + 6 * r1];
        }

        p_est[k + 6 * r1] = p_prd[k + 6 * r1] - a21;
      }
    }

    /*  Compute the estimated measurements */
    for (k = 0; k < 2; k++) {
      y_data[k + (i << 1)] = 0.0;
      for (r1 = 0; r1 < 6; r1++) {
        y_data[k + (i << 1)] += (double)d_a[k + (r1 << 1)] * x_est[r1];
      }
    }
  }
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void kalman03_init(void)
{
  int i;
  for (i = 0; i < 6; i++) {
    x_est[i] = 0.0;
  }

  memset(&p_est[0], 0, 36U * sizeof(double));
}

/*
 * File trailer for kalman03.c
 *
 * [EOF]
 */
