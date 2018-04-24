/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: imregionalmax.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <float.h>
#include <math.h>
#include "rt_nonfinite.h"
#include <string.h>
#include "faceTrackingARMKernel.h"
#include "imregionalmax.h"
#include "isequal.h"

/* Function Declarations */
static double rt_remd_snf(double u0, double u1);

/* Function Definitions */

/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_remd_snf(double u0, double u1)
{
  double y;
  double b_u1;
  double q;
  if (!((!rtIsNaN(u0)) && (!rtIsInf(u0)) && ((!rtIsNaN(u1)) && (!rtIsInf(u1)))))
  {
    y = rtNaN;
  } else {
    if (u1 < 0.0) {
      b_u1 = ceil(u1);
    } else {
      b_u1 = floor(u1);
    }

    if ((u1 != 0.0) && (u1 != b_u1)) {
      q = fabs(u0 / u1);
      if (fabs(q - floor(q + 0.5)) <= DBL_EPSILON * q) {
        y = 0.0 * u0;
      } else {
        y = fmod(u0, u1);
      }
    } else {
      y = fmod(u0, u1);
    }
  }

  return y;
}

/*
 * Arguments    : const emxArray_real32_T *varargin_1
 *                boolean_T BW_data[]
 *                int BW_size[2]
 * Return Type  : void
 */
void imregionalmax(const emxArray_real32_T *varargin_1, boolean_T BW_data[], int
                   BW_size[2])
{
  int i26;
  unsigned char uv4[2];
  unsigned char np_ImageSize[2];
  int i;
  boolean_T continuePropagation;
  int bwpre_size[2];
  boolean_T bwpre_data[34615];
  boolean_T imParams_bw_data[34615];
  int loffsets[9];
  int np_ImageNeighborLinearOffsets[9];
  unsigned char pixelsPerImPage[2];
  short imSize[2];
  int pind;
  signed char subs[2];
  int r;
  signed char b_subs[2];
  int pixelSub[2];
  int imnhSubs[18];
  int np_NeighborSubscriptOffsets[18];
  int k;
  int loop_ub;
  int secondInd;
  int firstInd;
  int u1;
  int minval;
  boolean_T out__data[161];
  float pixel;
  int imnhInds_[9];
  boolean_T exitg1;
  int c;
  int b_pixelSub[2];
  boolean_T isInside[9];
  int maxval;
  int c_pixelSub[2];
  int imnhInds_data[9];
  float imnh_data[9];
  int d_pixelSub[2];
  int b_imnhInds_data[9];
  int c_imnhInds_data[9];
  int e_pixelSub[2];
  int d_imnhInds_data[9];
  for (i26 = 0; i26 < 2; i26++) {
    np_ImageSize[i26] = (unsigned char)varargin_1->size[i26];
    uv4[i26] = (unsigned char)varargin_1->size[i26];
  }

  BW_size[0] = uv4[0];
  BW_size[1] = uv4[1];
  i = uv4[0] * uv4[1];
  for (i26 = 0; i26 < i; i26++) {
    BW_data[i26] = true;
  }

  continuePropagation = true;
  while (continuePropagation) {
    bwpre_size[0] = BW_size[0];
    bwpre_size[1] = BW_size[1];
    i = BW_size[0] * BW_size[1];
    if (0 <= i - 1) {
      memcpy(&bwpre_data[0], &BW_data[0], (unsigned int)(i * (int)sizeof
              (boolean_T)));
    }

    i = BW_size[0] * BW_size[1];
    if (0 <= i - 1) {
      memcpy(&imParams_bw_data[0], &BW_data[0], (unsigned int)(i * (int)sizeof
              (boolean_T)));
    }

    for (i = 0; i < 9; i++) {
      loffsets[i] = np_ImageNeighborLinearOffsets[i];
    }

    /*  Process pixels with full neighborhood */
    /*  Process pixels with partial neighborhood */
    /*  Process pixels with full neighborhood */
    /*  Process pixels with partial neighborhood */
    pixelsPerImPage[0] = 1U;
    pixelsPerImPage[1] = np_ImageSize[0];
    for (i26 = 0; i26 < 2; i26++) {
      imSize[i26] = (short)(np_ImageSize[i26] - 1);
    }

    i = 0;
    for (pind = 0; pind < 9; pind++) {
      r = (int)rt_remd_snf((1.0 + (double)pind) - 1.0, 3.0) + 1;
      b_subs[1] = (signed char)((int)(((double)(pind - r) + 1.0) / 3.0) + 1);
      b_subs[0] = (signed char)r;
      subs[0] = (signed char)r;
      subs[1] = (signed char)(b_subs[1] - 1);
      for (i26 = 0; i26 < 2; i26++) {
        np_NeighborSubscriptOffsets[i + 9 * i26] = b_subs[i26];
        pixelSub[i26] = subs[i26] * pixelsPerImPage[i26];
      }

      loffsets[i] = pixelSub[0] + pixelSub[1];
      i++;
    }

    subs[0] = 2;
    subs[1] = 1;
    for (i26 = 0; i26 < 2; i26++) {
      pixelSub[i26] = subs[i26] * pixelsPerImPage[i26];
    }

    for (i26 = 0; i26 < 9; i26++) {
      loffsets[i26] = (loffsets[i26] - (unsigned char)pixelSub[1]) - 2;
    }

    memcpy(&imnhSubs[0], &np_NeighborSubscriptOffsets[0], 18U * sizeof(int));
    for (i = 0; i < 2; i++) {
      for (k = 0; k < 9; k++) {
        np_NeighborSubscriptOffsets[k + 9 * i] = imnhSubs[k + 9 * i] - 2;
      }
    }

    for (i = 0; i < 9; i++) {
      np_ImageNeighborLinearOffsets[i] = loffsets[i];
    }

    if (2 <= imSize[1]) {
      loop_ub = BW_size[0];
    }

    for (secondInd = 1; secondInd < imSize[1]; secondInd++) {
      for (firstInd = 1; firstInd < imSize[0]; firstInd++) {
        pind = secondInd * np_ImageSize[0] + firstInd;
        for (i = 0; i < 9; i++) {
          imnhInds_[i] = (loffsets[i] + pind) + 1;
        }

        pixel = varargin_1->data[pind];
        continuePropagation = imParams_bw_data[pind];
        if (imParams_bw_data[pind]) {
          /*  Pixel has not already been set as non-max */
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i <= 8)) {
            if (varargin_1->data[imnhInds_[i] - 1] > pixel) {
              /*  Set pixel to zero if any neighbor is greater */
              continuePropagation = false;
              exitg1 = true;
            } else if ((varargin_1->data[imnhInds_[i] - 1] == pixel) &&
                       (!imParams_bw_data[imnhInds_[i] - 1])) {
              /*  Set pixel to zero if any equal neighbor is already set to zero */
              continuePropagation = false;
              exitg1 = true;
            } else {
              i++;
            }
          }
        }

        out__data[firstInd] = continuePropagation;
      }

      for (i26 = 0; i26 < loop_ub; i26++) {
        BW_data[i26 + BW_size[0] * secondInd] = out__data[i26];
      }
    }

    i = np_ImageSize[0];
    u1 = np_ImageSize[0];
    if (i < u1) {
      u1 = i;
    }

    if (1 > np_ImageSize[1]) {
      minval = np_ImageSize[1];
    } else {
      minval = 1;
    }

    for (secondInd = 0; secondInd < minval; secondInd++) {
      for (firstInd = 0; firstInd < u1; firstInd++) {
        pind = secondInd * np_ImageSize[0] + firstInd;
        for (i = 0; i < 9; i++) {
          imnhInds_[i] = (loffsets[i] + pind) + 1;
        }

        if (np_ImageSize[0] == 0) {
          r = 0;
        } else {
          i26 = np_ImageSize[0];
          r = pind - np_ImageSize[0] * (pind / i26);
        }

        c = pind - r;
        if (np_ImageSize[0] == 0) {
          if (c == 0) {
            i = 0;
          } else if (c < 0) {
            i = MIN_int32_T;
          } else {
            i = MAX_int32_T;
          }
        } else if (np_ImageSize[0] == 1) {
          i = c;
        } else {
          if (c >= 0) {
            k = c;
          } else {
            k = -c;
          }

          i26 = np_ImageSize[0];
          i = k / i26;
          k -= i * np_ImageSize[0];
          if ((k > 0) && (k >= (np_ImageSize[0] >> 1) + (np_ImageSize[0] & 1)))
          {
            i++;
          }

          if (c < 0) {
            i = -i;
          }
        }

        b_pixelSub[1] = i + 1;
        b_pixelSub[0] = r + 1;
        for (i = 0; i < 2; i++) {
          pixelSub[i] = b_pixelSub[i];
          for (k = 0; k < 9; k++) {
            imnhSubs[k + 9 * i] = np_NeighborSubscriptOffsets[k + 9 * i] +
              pixelSub[i];
          }
        }

        for (i = 0; i < 9; i++) {
          isInside[i] = true;
        }

        c = 0;
        for (k = 0; k < 9; k++) {
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i < 2)) {
            if ((imnhSubs[k + 9 * i] < 1) || (imnhSubs[k + 9 * i] >
                 np_ImageSize[i])) {
              isInside[k] = false;
              exitg1 = true;
            } else {
              i++;
            }
          }

          if (isInside[k]) {
            c++;
          }
        }

        k = 0;
        for (i = 0; i < 9; i++) {
          if (isInside[i]) {
            imnhInds_data[k] = imnhInds_[i];
            k++;
          }
        }

        for (i26 = 0; i26 < c; i26++) {
          imnh_data[i26] = varargin_1->data[imnhInds_data[i26] - 1];
        }

        pixel = varargin_1->data[pind];
        continuePropagation = imParams_bw_data[pind];
        if (imParams_bw_data[pind]) {
          /*  Pixel has not already been set as non-max */
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i <= c - 1)) {
            if (imnh_data[i] > pixel) {
              /*  Set pixel to zero if any neighbor is greater */
              continuePropagation = false;
              exitg1 = true;
            } else if ((imnh_data[i] == pixel) &&
                       (!imParams_bw_data[imnhInds_data[i] - 1])) {
              /*  Set pixel to zero if any equal neighbor is already set to zero */
              continuePropagation = false;
              exitg1 = true;
            } else {
              i++;
            }
          }
        }

        BW_data[pind] = continuePropagation;
      }
    }

    i = np_ImageSize[0];
    u1 = np_ImageSize[0];
    if (i < u1) {
      u1 = i;
    }

    i = np_ImageSize[1];
    minval = np_ImageSize[1];
    if (i < minval) {
      minval = i;
    }

    if (imSize[1] + 1 < 1) {
      secondInd = 1;
    } else {
      secondInd = imSize[1] + 1;
    }

    while (secondInd <= minval) {
      for (firstInd = 0; firstInd < u1; firstInd++) {
        pind = (secondInd - 1) * np_ImageSize[0] + firstInd;
        for (i = 0; i < 9; i++) {
          imnhInds_[i] = (loffsets[i] + pind) + 1;
        }

        if (np_ImageSize[0] == 0) {
          r = 0;
        } else {
          i26 = np_ImageSize[0];
          r = pind - np_ImageSize[0] * (pind / i26);
        }

        c = pind - r;
        if (np_ImageSize[0] == 0) {
          if (c == 0) {
            i = 0;
          } else if (c < 0) {
            i = MIN_int32_T;
          } else {
            i = MAX_int32_T;
          }
        } else if (np_ImageSize[0] == 1) {
          i = c;
        } else {
          if (c >= 0) {
            k = c;
          } else {
            k = -c;
          }

          i26 = np_ImageSize[0];
          i = k / i26;
          k -= i * np_ImageSize[0];
          if ((k > 0) && (k >= (np_ImageSize[0] >> 1) + (np_ImageSize[0] & 1)))
          {
            i++;
          }

          if (c < 0) {
            i = -i;
          }
        }

        c_pixelSub[1] = i + 1;
        c_pixelSub[0] = r + 1;
        for (i = 0; i < 2; i++) {
          pixelSub[i] = c_pixelSub[i];
          for (k = 0; k < 9; k++) {
            imnhSubs[k + 9 * i] = np_NeighborSubscriptOffsets[k + 9 * i] +
              pixelSub[i];
          }
        }

        for (i = 0; i < 9; i++) {
          isInside[i] = true;
        }

        c = 0;
        for (k = 0; k < 9; k++) {
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i < 2)) {
            if ((imnhSubs[k + 9 * i] < 1) || (imnhSubs[k + 9 * i] >
                 np_ImageSize[i])) {
              isInside[k] = false;
              exitg1 = true;
            } else {
              i++;
            }
          }

          if (isInside[k]) {
            c++;
          }
        }

        k = 0;
        for (i = 0; i < 9; i++) {
          if (isInside[i]) {
            b_imnhInds_data[k] = imnhInds_[i];
            k++;
          }
        }

        for (i26 = 0; i26 < c; i26++) {
          imnh_data[i26] = varargin_1->data[b_imnhInds_data[i26] - 1];
        }

        pixel = varargin_1->data[pind];
        continuePropagation = imParams_bw_data[pind];
        if (imParams_bw_data[pind]) {
          /*  Pixel has not already been set as non-max */
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i <= c - 1)) {
            if (imnh_data[i] > pixel) {
              /*  Set pixel to zero if any neighbor is greater */
              continuePropagation = false;
              exitg1 = true;
            } else if ((imnh_data[i] == pixel) &&
                       (!imParams_bw_data[b_imnhInds_data[i] - 1])) {
              /*  Set pixel to zero if any equal neighbor is already set to zero */
              continuePropagation = false;
              exitg1 = true;
            } else {
              i++;
            }
          }
        }

        BW_data[pind] = continuePropagation;
      }

      secondInd++;
    }

    if (1 > np_ImageSize[0]) {
      minval = np_ImageSize[0];
    } else {
      minval = 1;
    }

    i = np_ImageSize[1];
    u1 = np_ImageSize[1];
    if (i < u1) {
      u1 = i;
    }

    for (secondInd = 1; secondInd <= u1; secondInd++) {
      for (firstInd = 0; firstInd < minval; firstInd++) {
        pind = (secondInd - 1) * np_ImageSize[0] + firstInd;
        for (i = 0; i < 9; i++) {
          imnhInds_[i] = (loffsets[i] + pind) + 1;
        }

        if (np_ImageSize[0] == 0) {
          r = 0;
        } else {
          i26 = np_ImageSize[0];
          r = pind - np_ImageSize[0] * (pind / i26);
        }

        c = pind - r;
        if (np_ImageSize[0] == 0) {
          if (c == 0) {
            i = 0;
          } else if (c < 0) {
            i = MIN_int32_T;
          } else {
            i = MAX_int32_T;
          }
        } else if (np_ImageSize[0] == 1) {
          i = c;
        } else {
          if (c >= 0) {
            k = c;
          } else {
            k = -c;
          }

          i26 = np_ImageSize[0];
          i = k / i26;
          k -= i * np_ImageSize[0];
          if ((k > 0) && (k >= (np_ImageSize[0] >> 1) + (np_ImageSize[0] & 1)))
          {
            i++;
          }

          if (c < 0) {
            i = -i;
          }
        }

        d_pixelSub[1] = i + 1;
        d_pixelSub[0] = r + 1;
        for (i = 0; i < 2; i++) {
          pixelSub[i] = d_pixelSub[i];
          for (k = 0; k < 9; k++) {
            imnhSubs[k + 9 * i] = np_NeighborSubscriptOffsets[k + 9 * i] +
              pixelSub[i];
          }
        }

        for (i = 0; i < 9; i++) {
          isInside[i] = true;
        }

        c = 0;
        for (k = 0; k < 9; k++) {
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i < 2)) {
            if ((imnhSubs[k + 9 * i] < 1) || (imnhSubs[k + 9 * i] >
                 np_ImageSize[i])) {
              isInside[k] = false;
              exitg1 = true;
            } else {
              i++;
            }
          }

          if (isInside[k]) {
            c++;
          }
        }

        k = 0;
        for (i = 0; i < 9; i++) {
          if (isInside[i]) {
            c_imnhInds_data[k] = imnhInds_[i];
            k++;
          }
        }

        for (i26 = 0; i26 < c; i26++) {
          imnh_data[i26] = varargin_1->data[c_imnhInds_data[i26] - 1];
        }

        pixel = varargin_1->data[pind];
        continuePropagation = imParams_bw_data[pind];
        if (imParams_bw_data[pind]) {
          /*  Pixel has not already been set as non-max */
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i <= c - 1)) {
            if (imnh_data[i] > pixel) {
              /*  Set pixel to zero if any neighbor is greater */
              continuePropagation = false;
              exitg1 = true;
            } else if ((imnh_data[i] == pixel) &&
                       (!imParams_bw_data[c_imnhInds_data[i] - 1])) {
              /*  Set pixel to zero if any equal neighbor is already set to zero */
              continuePropagation = false;
              exitg1 = true;
            } else {
              i++;
            }
          }
        }

        BW_data[pind] = continuePropagation;
      }
    }

    if (imSize[0] + 1 < 1) {
      maxval = 1;
    } else {
      maxval = imSize[0] + 1;
    }

    i = np_ImageSize[0];
    u1 = np_ImageSize[0];
    if (i < u1) {
      u1 = i;
    }

    i = np_ImageSize[1];
    minval = np_ImageSize[1];
    if (i < minval) {
      minval = i;
    }

    for (secondInd = 1; secondInd <= minval; secondInd++) {
      for (firstInd = maxval; firstInd <= u1; firstInd++) {
        pind = ((secondInd - 1) * np_ImageSize[0] + firstInd) - 1;
        for (i = 0; i < 9; i++) {
          imnhInds_[i] = (loffsets[i] + pind) + 1;
        }

        if (np_ImageSize[0] == 0) {
          r = 0;
        } else {
          i26 = np_ImageSize[0];
          r = pind - np_ImageSize[0] * (pind / i26);
        }

        c = pind - r;
        if (np_ImageSize[0] == 0) {
          if (c == 0) {
            i = 0;
          } else if (c < 0) {
            i = MIN_int32_T;
          } else {
            i = MAX_int32_T;
          }
        } else if (np_ImageSize[0] == 1) {
          i = c;
        } else {
          if (c >= 0) {
            k = c;
          } else {
            k = -c;
          }

          i26 = np_ImageSize[0];
          i = k / i26;
          k -= i * np_ImageSize[0];
          if ((k > 0) && (k >= (np_ImageSize[0] >> 1) + (np_ImageSize[0] & 1)))
          {
            i++;
          }

          if (c < 0) {
            i = -i;
          }
        }

        e_pixelSub[1] = i + 1;
        e_pixelSub[0] = r + 1;
        for (i = 0; i < 2; i++) {
          pixelSub[i] = e_pixelSub[i];
          for (k = 0; k < 9; k++) {
            imnhSubs[k + 9 * i] = np_NeighborSubscriptOffsets[k + 9 * i] +
              pixelSub[i];
          }
        }

        for (i = 0; i < 9; i++) {
          isInside[i] = true;
        }

        c = 0;
        for (k = 0; k < 9; k++) {
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i < 2)) {
            if ((imnhSubs[k + 9 * i] < 1) || (imnhSubs[k + 9 * i] >
                 np_ImageSize[i])) {
              isInside[k] = false;
              exitg1 = true;
            } else {
              i++;
            }
          }

          if (isInside[k]) {
            c++;
          }
        }

        k = 0;
        for (i = 0; i < 9; i++) {
          if (isInside[i]) {
            d_imnhInds_data[k] = imnhInds_[i];
            k++;
          }
        }

        for (i26 = 0; i26 < c; i26++) {
          imnh_data[i26] = varargin_1->data[d_imnhInds_data[i26] - 1];
        }

        pixel = varargin_1->data[pind];
        continuePropagation = imParams_bw_data[pind];
        if (imParams_bw_data[pind]) {
          /*  Pixel has not already been set as non-max */
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i <= c - 1)) {
            if (imnh_data[i] > pixel) {
              /*  Set pixel to zero if any neighbor is greater */
              continuePropagation = false;
              exitg1 = true;
            } else if ((imnh_data[i] == pixel) &&
                       (!imParams_bw_data[d_imnhInds_data[i] - 1])) {
              /*  Set pixel to zero if any equal neighbor is already set to zero */
              continuePropagation = false;
              exitg1 = true;
            } else {
              i++;
            }
          }
        }

        BW_data[pind] = continuePropagation;
      }
    }

    continuePropagation = !isequal(bwpre_data, bwpre_size, BW_data, BW_size);
  }
}

/*
 * File trailer for imregionalmax.c
 *
 * [EOF]
 */
