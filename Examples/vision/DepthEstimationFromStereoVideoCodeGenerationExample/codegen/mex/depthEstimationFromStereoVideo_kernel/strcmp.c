/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * strcmp.c
 *
 * Code generation for function 'strcmp'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "strcmp.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
boolean_T b_strcmp(const emxArray_char_T *a)
{
  boolean_T b_bool;
  int32_T kstr;
  int32_T exitg1;
  static const char_T cv11[6] = { 'd', 'o', 'u', 'b', 'l', 'e' };

  b_bool = false;
  if (a->size[1] == 6) {
    kstr = 0;
    do {
      exitg1 = 0;
      if (kstr + 1 < 7) {
        if (a->data[kstr] != cv11[kstr]) {
          exitg1 = 1;
        } else {
          kstr++;
        }
      } else {
        b_bool = true;
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }

  return b_bool;
}

/* End of code generation (strcmp.c) */
