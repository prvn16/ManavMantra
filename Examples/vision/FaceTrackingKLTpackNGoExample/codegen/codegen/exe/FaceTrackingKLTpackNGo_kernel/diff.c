/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: diff.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "diff.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const int x_data[]
 *                int y_data[]
 *                int y_size[2]
 * Return Type  : void
 */
void diff(const int x_data[], int y_data[], int y_size[2])
{
  int ixLead;
  int iyLead;
  int work_data_idx_0;
  int m;
  int tmp1;
  int q0;
  int y1_data[3];
  ixLead = 1;
  iyLead = 0;
  work_data_idx_0 = x_data[0];
  for (m = 0; m < 3; m++) {
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
    y1_data[iyLead] = tmp1;
    iyLead++;
  }

  y_size[0] = 1;
  y_size[1] = 3;
  for (tmp1 = 0; tmp1 < 3; tmp1++) {
    y_data[tmp1] = y1_data[tmp1];
  }
}

/*
 * File trailer for diff.c
 *
 * [EOF]
 */
