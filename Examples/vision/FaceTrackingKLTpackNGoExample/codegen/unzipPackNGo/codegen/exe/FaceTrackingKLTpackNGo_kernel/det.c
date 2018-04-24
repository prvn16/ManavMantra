/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: det.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <math.h>
#include <string.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "det.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const float x_data[]
 *                const int x_size[2]
 * Return Type  : float
 */
float det(const float x_data[], const int x_size[2])
{
  float y;
  int m;
  int n;
  int x_size_idx_0;
  int yk;
  float b_x_data[9];
  int u1;
  int ipiv_data[3];
  int jA;
  int b_u1;
  int j;
  int mmj;
  int c;
  boolean_T isodd;
  int ix;
  float smax;
  int i32;
  int jy;
  int b_j;
  float s;
  int ijA;
  if ((x_size[0] == 0) || (x_size[1] == 0)) {
    y = 1.0F;
  } else {
    m = x_size[0];
    n = x_size[1];
    x_size_idx_0 = x_size[0];
    yk = x_size[0] * x_size[1];
    if (0 <= yk - 1) {
      memcpy(&b_x_data[0], &x_data[0], (unsigned int)(yk * (int)sizeof(float)));
    }

    yk = x_size[0];
    u1 = x_size[1];
    if (yk < u1) {
      u1 = yk;
    }

    ipiv_data[0] = 1;
    yk = 1;
    for (jA = 2; jA <= u1; jA++) {
      yk++;
      ipiv_data[jA - 1] = yk;
    }

    yk = x_size[0] - 1;
    b_u1 = x_size[1];
    if (yk < b_u1) {
      b_u1 = yk;
    }

    for (j = 0; j < b_u1; j++) {
      mmj = m - j;
      c = j * (m + 1);
      if (mmj < 1) {
        yk = -1;
      } else {
        yk = 0;
        if (mmj > 1) {
          ix = c;
          smax = (float)fabs(b_x_data[c]);
          for (jA = 2; jA <= mmj; jA++) {
            ix++;
            s = (float)fabs(b_x_data[ix]);
            if (s > smax) {
              yk = jA - 1;
              smax = s;
            }
          }
        }
      }

      if (b_x_data[c + yk] != 0.0F) {
        if (yk != 0) {
          ipiv_data[j] = (j + yk) + 1;
          ix = j;
          yk += j;
          for (jA = 1; jA <= n; jA++) {
            smax = b_x_data[ix];
            b_x_data[ix] = b_x_data[yk];
            b_x_data[yk] = smax;
            ix += m;
            yk += m;
          }
        }

        i32 = c + mmj;
        for (yk = c + 1; yk < i32; yk++) {
          b_x_data[yk] /= b_x_data[c];
        }
      }

      yk = n - j;
      jA = (c + m) + 1;
      jy = c + m;
      for (b_j = 1; b_j < yk; b_j++) {
        smax = b_x_data[jy];
        if (b_x_data[jy] != 0.0F) {
          ix = c + 1;
          i32 = mmj + jA;
          for (ijA = jA; ijA < i32 - 1; ijA++) {
            b_x_data[ijA] += b_x_data[ix] * -smax;
            ix++;
          }
        }

        jy += m;
        jA += m;
      }
    }

    y = b_x_data[0];
    for (jA = 1; jA - 1 <= x_size_idx_0 - 2; jA++) {
      y *= b_x_data[jA + x_size_idx_0 * jA];
    }

    isodd = false;
    for (jA = 0; jA <= u1 - 2; jA++) {
      if (ipiv_data[jA] > 1 + jA) {
        isodd = !isodd;
      }
    }

    if (isodd) {
      y = -y;
    }
  }

  return y;
}

/*
 * File trailer for det.c
 *
 * [EOF]
 */
