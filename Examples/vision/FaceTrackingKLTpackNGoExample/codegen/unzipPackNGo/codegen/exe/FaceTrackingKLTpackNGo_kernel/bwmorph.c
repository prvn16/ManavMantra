/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: bwmorph.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "bwmorph.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "isequal.h"
#include "bwlookup.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : emxArray_boolean_T *bwin
 * Return Type  : void
 */
void bwmorph(emxArray_boolean_T *bwin)
{
  emxArray_boolean_T *last_aout;
  emxArray_boolean_T *m;
  int i35;
  int loop_ub;
  int i36;
  int b_loop_ub;
  int i37;
  emxInit_boolean_T1(&last_aout, 2);
  emxInit_boolean_T1(&m, 2);
  do {
    i35 = last_aout->size[0] * last_aout->size[1];
    last_aout->size[0] = bwin->size[0];
    last_aout->size[1] = bwin->size[1];
    emxEnsureCapacity_boolean_T(last_aout, i35);
    loop_ub = bwin->size[0] * bwin->size[1];
    for (i35 = 0; i35 < loop_ub; i35++) {
      last_aout->data[i35] = bwin->data[i35];
    }

    bwlookup(bwin, m);
    loop_ub = bwin->size[0] * bwin->size[1] - 1;
    i35 = m->size[0] * m->size[1];
    m->size[0] = bwin->size[0];
    m->size[1] = bwin->size[1];
    emxEnsureCapacity_boolean_T(m, i35);
    for (i35 = 0; i35 <= loop_ub; i35++) {
      m->data[i35] = (bwin->data[i35] && (!m->data[i35]));
    }

    i35 = m->size[0] - 1;
    i36 = m->size[1] - 1;
    loop_ub = i36 >> 1;
    for (i36 = 0; i36 <= loop_ub; i36++) {
      b_loop_ub = i35 >> 1;
      for (i37 = 0; i37 <= b_loop_ub; i37++) {
        bwin->data[(i37 << 1) + bwin->size[0] * (i36 << 1)] = m->data[(i37 << 1)
          + m->size[0] * (i36 << 1)];
      }
    }

    bwlookup(bwin, m);
    loop_ub = bwin->size[0] * bwin->size[1] - 1;
    i35 = m->size[0] * m->size[1];
    m->size[0] = bwin->size[0];
    m->size[1] = bwin->size[1];
    emxEnsureCapacity_boolean_T(m, i35);
    for (i35 = 0; i35 <= loop_ub; i35++) {
      m->data[i35] = (bwin->data[i35] && (!m->data[i35]));
    }

    i35 = m->size[0] - 2;
    i36 = m->size[1] - 2;
    loop_ub = i36 >> 1;
    for (i36 = 0; i36 <= loop_ub; i36++) {
      b_loop_ub = i35 >> 1;
      for (i37 = 0; i37 <= b_loop_ub; i37++) {
        bwin->data[((i37 << 1) + bwin->size[0] * (1 + (i36 << 1))) + 1] =
          m->data[((i37 << 1) + m->size[0] * (1 + (i36 << 1))) + 1];
      }
    }

    bwlookup(bwin, m);
    loop_ub = bwin->size[0] * bwin->size[1] - 1;
    i35 = m->size[0] * m->size[1];
    m->size[0] = bwin->size[0];
    m->size[1] = bwin->size[1];
    emxEnsureCapacity_boolean_T(m, i35);
    for (i35 = 0; i35 <= loop_ub; i35++) {
      m->data[i35] = (bwin->data[i35] && (!m->data[i35]));
    }

    i35 = m->size[0] - 1;
    i36 = m->size[1] - 2;
    loop_ub = i36 >> 1;
    for (i36 = 0; i36 <= loop_ub; i36++) {
      b_loop_ub = i35 >> 1;
      for (i37 = 0; i37 <= b_loop_ub; i37++) {
        bwin->data[(i37 << 1) + bwin->size[0] * (1 + (i36 << 1))] = m->data[(i37
          << 1) + m->size[0] * (1 + (i36 << 1))];
      }
    }

    bwlookup(bwin, m);
    loop_ub = bwin->size[0] * bwin->size[1] - 1;
    i35 = m->size[0] * m->size[1];
    m->size[0] = bwin->size[0];
    m->size[1] = bwin->size[1];
    emxEnsureCapacity_boolean_T(m, i35);
    for (i35 = 0; i35 <= loop_ub; i35++) {
      m->data[i35] = (bwin->data[i35] && (!m->data[i35]));
    }

    i35 = m->size[0] - 2;
    i36 = m->size[1] - 1;
    loop_ub = i36 >> 1;
    for (i36 = 0; i36 <= loop_ub; i36++) {
      b_loop_ub = i35 >> 1;
      for (i37 = 0; i37 <= b_loop_ub; i37++) {
        bwin->data[((i37 << 1) + bwin->size[0] * (i36 << 1)) + 1] = m->data
          [((i37 << 1) + m->size[0] * (i36 << 1)) + 1];
      }
    }
  } while (!isequal(last_aout, bwin));

  emxFree_boolean_T(&m);
  emxFree_boolean_T(&last_aout);

  /*  the output is not changing anymore */
}

/*
 * File trailer for bwmorph.c
 *
 * [EOF]
 */
