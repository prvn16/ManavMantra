/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: bwmorph.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "bwmorph.h"
#include "isequal.h"
#include "bwlookup.h"

/* Function Definitions */

/*
 * Arguments    : boolean_T bwin_data[]
 *                int bwin_size[2]
 * Return Type  : void
 */
void bwmorph(boolean_T bwin_data[], int bwin_size[2])
{
  int last_aout_size[2];
  int loop_ub;
  boolean_T last_aout_data[34615];
  boolean_T m_data[34615];
  int m_size[2];
  int i42;
  int b_loop_ub;
  int i43;
  do {
    last_aout_size[0] = bwin_size[0];
    last_aout_size[1] = bwin_size[1];
    loop_ub = bwin_size[0] * bwin_size[1];
    if (0 <= loop_ub - 1) {
      memcpy(&last_aout_data[0], &bwin_data[0], (unsigned int)(loop_ub * (int)
              sizeof(boolean_T)));
    }

    bwlookup(bwin_data, bwin_size, m_data, m_size);
    loop_ub = bwin_size[0] * bwin_size[1] - 1;
    m_size[0] = bwin_size[0];
    for (i42 = 0; i42 <= loop_ub; i42++) {
      m_data[i42] = (bwin_data[i42] && (!m_data[i42]));
    }

    loop_ub = (bwin_size[1] - 1) >> 1;
    for (i42 = 0; i42 <= loop_ub; i42++) {
      b_loop_ub = (m_size[0] - 1) >> 1;
      for (i43 = 0; i43 <= b_loop_ub; i43++) {
        bwin_data[(i43 << 1) + bwin_size[0] * (i42 << 1)] = m_data[(i43 << 1) +
          m_size[0] * (i42 << 1)];
      }
    }

    bwlookup(bwin_data, bwin_size, m_data, m_size);
    loop_ub = bwin_size[0] * bwin_size[1] - 1;
    m_size[0] = bwin_size[0];
    for (i42 = 0; i42 <= loop_ub; i42++) {
      m_data[i42] = (bwin_data[i42] && (!m_data[i42]));
    }

    loop_ub = (bwin_size[1] - 2) >> 1;
    for (i42 = 0; i42 <= loop_ub; i42++) {
      b_loop_ub = (m_size[0] - 2) >> 1;
      for (i43 = 0; i43 <= b_loop_ub; i43++) {
        bwin_data[((i43 << 1) + bwin_size[0] * (1 + (i42 << 1))) + 1] = m_data
          [((i43 << 1) + m_size[0] * (1 + (i42 << 1))) + 1];
      }
    }

    bwlookup(bwin_data, bwin_size, m_data, m_size);
    loop_ub = bwin_size[0] * bwin_size[1] - 1;
    m_size[0] = bwin_size[0];
    for (i42 = 0; i42 <= loop_ub; i42++) {
      m_data[i42] = (bwin_data[i42] && (!m_data[i42]));
    }

    loop_ub = (bwin_size[1] - 2) >> 1;
    for (i42 = 0; i42 <= loop_ub; i42++) {
      b_loop_ub = (m_size[0] - 1) >> 1;
      for (i43 = 0; i43 <= b_loop_ub; i43++) {
        bwin_data[(i43 << 1) + bwin_size[0] * (1 + (i42 << 1))] = m_data[(i43 <<
          1) + m_size[0] * (1 + (i42 << 1))];
      }
    }

    bwlookup(bwin_data, bwin_size, m_data, m_size);
    loop_ub = bwin_size[0] * bwin_size[1] - 1;
    m_size[0] = bwin_size[0];
    for (i42 = 0; i42 <= loop_ub; i42++) {
      m_data[i42] = (bwin_data[i42] && (!m_data[i42]));
    }

    loop_ub = (bwin_size[1] - 1) >> 1;
    for (i42 = 0; i42 <= loop_ub; i42++) {
      b_loop_ub = (m_size[0] - 2) >> 1;
      for (i43 = 0; i43 <= b_loop_ub; i43++) {
        bwin_data[((i43 << 1) + bwin_size[0] * (i42 << 1)) + 1] = m_data[((i43 <<
          1) + m_size[0] * (i42 << 1)) + 1];
      }
    }
  } while (!isequal(last_aout_data, last_aout_size, bwin_data, bwin_size));

  /*  the output is not changing anymore */
}

/*
 * File trailer for bwmorph.c
 *
 * [EOF]
 */
