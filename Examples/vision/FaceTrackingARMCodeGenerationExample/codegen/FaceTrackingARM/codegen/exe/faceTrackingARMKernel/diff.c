/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: diff.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "diff.h"

/* Function Definitions */

/*
 * Arguments    : const int x_data[]
 *                const int x_size[2]
 *                int y_data[]
 *                int y_size[2]
 * Return Type  : void
 */
void diff(const int x_data[], const int x_size[2], int y_data[], int y_size[2])
{
  int tmp1;
  int ixLead;
  int iyLead;
  int work_data_idx_0;
  int m;
  int q0;
  tmp1 = x_size[1] - 1;
  if (!(tmp1 < 1)) {
    tmp1 = 1;
  }

  if (tmp1 < 1) {
    y_size[0] = 1;
    y_size[1] = 0;
  } else {
    y_size[0] = 1;
    y_size[1] = (signed char)(x_size[1] - 1);
    if (!((signed char)(x_size[1] - 1) == 0)) {
      ixLead = 1;
      iyLead = 0;
      work_data_idx_0 = x_data[0];
      for (m = 2; m <= x_size[1]; m++) {
        tmp1 = work_data_idx_0;
        work_data_idx_0 = x_data[ixLead];
        q0 = x_data[ixLead];
        if ((q0 >= 0) && (tmp1 < q0 - MAX_int32_T)) {
          tmp1 = MAX_int32_T;
        } else if ((q0 < 0) && (tmp1 > q0 - MIN_int32_T)) {
          tmp1 = MIN_int32_T;
        } else {
          tmp1 = q0 - tmp1;
        }

        ixLead++;
        y_data[iyLead] = tmp1;
        iyLead++;
      }
    }
  }
}

/*
 * File trailer for diff.c
 *
 * [EOF]
 */
