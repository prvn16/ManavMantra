/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: MarkerInserter.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "MarkerInserter.h"
#include "FaceTrackingKLTpackNGo_kernel_rtwutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const visioncodegen_MarkerInserter *obj
 *                float varargin_1[921600]
 *                const int varargin_2_data[]
 *                const int varargin_2_size[2]
 *                const float varargin_3_data[]
 *                const int varargin_3_size[2]
 * Return Type  : void
 */
void MarkerInserter_outputImpl(const visioncodegen_MarkerInserter *obj, float
  varargin_1[921600], const int varargin_2_data[], const int varargin_2_size[2],
  const float varargin_3_data[], const int varargin_3_size[2])
{
  boolean_T isSizeValid;
  int numShape;
  int numFillColor;
  int idxFillColor;
  int size;
  int idxROI;
  int row;
  int col;
  int line[4];
  boolean_T visited1;
  boolean_T visited2;
  boolean_T done;
  int i;
  int b_line[4];
  int in;
  int b_idxFillColor;
  int idxPix;

  /* System object Outputs function: vision.MarkerInserter */
  isSizeValid = true;
  numShape = 0;
  if (varargin_2_size[1] > 1) {
    numShape = varargin_2_size[0];
  } else {
    if (varargin_2_size[1] == 1) {
      numShape = 1;
      isSizeValid = !((varargin_2_size[0] & 1) != 0);
    }
  }

  numFillColor = varargin_3_size[0];
  isSizeValid = (isSizeValid && ((numShape == 1) || (varargin_3_size[0] == 1) ||
    (numShape == varargin_3_size[0])));

  /* Copy the image from input to output. */
  if (isSizeValid) {
    /* Update view port. */
    idxFillColor = 0;

    /* Draw all pluses. */
    size = obj->cSFunObject.P0_RTP_SIZE + 1;
    for (idxROI = 0; idxROI < numShape; idxROI++) {
      row = varargin_2_data[idxROI + numShape] - 1;
      col = varargin_2_data[idxROI] - 1;
      line[0U] = varargin_2_data[idxROI + numShape] - 1;
      line[1U] = varargin_2_data[idxROI] - size;
      line[2U] = varargin_2_data[idxROI + numShape] - 1;
      line[3U] = (varargin_2_data[idxROI] + size) - 2;
      isSizeValid = false;

      /* Find the visible portion of a line. */
      visited1 = false;
      visited2 = false;
      done = false;
      for (i = 0; i < 4; i++) {
        b_line[i] = line[i];
      }

      while (!done) {
        i = 0;
        in = 0;

        /* Determine viewport violations. */
        if (b_line[0U] < 0) {
          i = 4;
        } else {
          if (b_line[0U] > 479) {
            i = 8;
          }
        }

        if (b_line[2U] < 0) {
          in = 4;
        } else {
          if (b_line[2U] > 479) {
            in = 8;
          }
        }

        if (b_line[1U] < 0) {
          i |= 1U;
        } else {
          if (b_line[1U] > 639) {
            i |= 2U;
          }
        }

        if (b_line[3U] < 0) {
          in |= 1U;
        } else {
          if (b_line[3U] > 639) {
            in |= 2U;
          }
        }

        if (!(((unsigned int)i | in) != 0U)) {
          /* Line falls completely within bounds. */
          done = true;
          isSizeValid = true;
        } else if (((unsigned int)i & in) != 0U) {
          /* Line falls completely out of bounds. */
          done = true;
          isSizeValid = false;
        } else if ((unsigned int)i != 0U) {
          /* Clip 1st point; if it's in-bounds, clip 2nd point. */
          if (visited1) {
            b_line[0U] = row;
            b_line[1U] = line[1];
          }

          b_idxFillColor = b_line[2] - b_line[0];
          idxPix = b_line[3] - b_line[1];
          if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824) ||
              ((idxPix > 1073741824) || (idxPix < -1073741824))) {
            /* Possible Inf or Nan. */
            done = true;
            isSizeValid = false;
            visited1 = true;
          } else if ((i & 4U) != 0U) {
            /* Violated RMin. */
            i = -b_line[0] * idxPix;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (b_idxFillColor >= 0)) || ((i < 0) &&
                        (b_idxFillColor < 0))) {
              b_line[1U] += (div_s32_floor(i << 1, b_idxFillColor) + 1) >> 1;
            } else {
              b_line[1U] -= (div_s32_floor(-i << 1, b_idxFillColor) + 1) >> 1;
            }

            b_line[0U] = 0;
            visited1 = true;
          } else if ((i & 8U) != 0U) {
            /* Violated RMax. */
            i = (479 - b_line[0]) * idxPix;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (b_idxFillColor >= 0)) || ((i < 0) &&
                        (b_idxFillColor < 0))) {
              b_line[1U] += (div_s32_floor(i << 1, b_idxFillColor) + 1) >> 1;
            } else {
              b_line[1U] -= (div_s32_floor(-i << 1, b_idxFillColor) + 1) >> 1;
            }

            b_line[0U] = 479;
            visited1 = true;
          } else if ((i & 1U) != 0U) {
            /* Violated CMin. */
            i = -b_line[1] * b_idxFillColor;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (idxPix >= 0)) || ((i < 0) && (idxPix < 0)))
            {
              b_line[0U] += (div_s32_floor(i << 1, idxPix) + 1) >> 1;
            } else {
              b_line[0U] -= (div_s32_floor(-i << 1, idxPix) + 1) >> 1;
            }

            b_line[1U] = 0;
            visited1 = true;
          } else {
            /* Violated CMax. */
            i = (639 - b_line[1]) * b_idxFillColor;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (idxPix >= 0)) || ((i < 0) && (idxPix < 0)))
            {
              b_line[0U] += (div_s32_floor(i << 1, idxPix) + 1) >> 1;
            } else {
              b_line[0U] -= (div_s32_floor(-i << 1, idxPix) + 1) >> 1;
            }

            b_line[1U] = 639;
            visited1 = true;
          }
        } else {
          /* Clip the 2nd point. */
          if (visited2) {
            b_line[2U] = row;
            b_line[3U] = line[3];
          }

          b_idxFillColor = b_line[2] - b_line[0];
          idxPix = b_line[3] - b_line[1];
          if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824) ||
              ((idxPix > 1073741824) || (idxPix < -1073741824))) {
            /* Possible Inf or Nan. */
            done = true;
            isSizeValid = false;
            visited2 = true;
          } else if ((in & 4U) != 0U) {
            /* Violated RMin. */
            i = -b_line[2] * idxPix;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (b_idxFillColor >= 0)) || ((i < 0) &&
                        (b_idxFillColor < 0))) {
              b_line[3U] += (div_s32_floor(i << 1, b_idxFillColor) + 1) >> 1;
            } else {
              b_line[3U] -= (div_s32_floor(-i << 1, b_idxFillColor) + 1) >> 1;
            }

            b_line[2U] = 0;
            visited2 = true;
          } else if ((in & 8U) != 0U) {
            /* Violated RMax. */
            i = (479 - b_line[2]) * idxPix;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (b_idxFillColor >= 0)) || ((i < 0) &&
                        (b_idxFillColor < 0))) {
              b_line[3U] += (div_s32_floor(i << 1, b_idxFillColor) + 1) >> 1;
            } else {
              b_line[3U] -= (div_s32_floor(-i << 1, b_idxFillColor) + 1) >> 1;
            }

            b_line[2U] = 479;
            visited2 = true;
          } else if ((in & 1U) != 0U) {
            /* Violated CMin. */
            i = -b_line[3] * b_idxFillColor;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (idxPix >= 0)) || ((i < 0) && (idxPix < 0)))
            {
              b_line[2U] += (div_s32_floor(i << 1, idxPix) + 1) >> 1;
            } else {
              b_line[2U] -= (div_s32_floor(-i << 1, idxPix) + 1) >> 1;
            }

            b_line[3U] = 0;
            visited2 = true;
          } else {
            /* Violated CMax. */
            i = (639 - b_line[3]) * b_idxFillColor;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (idxPix >= 0)) || ((i < 0) && (idxPix < 0)))
            {
              b_line[2U] += (div_s32_floor(i << 1, idxPix) + 1) >> 1;
            } else {
              b_line[2U] -= (div_s32_floor(-i << 1, idxPix) + 1) >> 1;
            }

            b_line[3U] = 639;
            visited2 = true;
          }
        }
      }

      if (isSizeValid) {
        i = b_line[1] * 480 + b_line[0];
        for (in = b_line[1]; in <= b_line[3U]; in++) {
          b_idxFillColor = idxFillColor;
          idxPix = i;
          for (row = 0; row < 3; row++) {
            varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
            idxPix += 307200;
            b_idxFillColor += numFillColor;
          }

          i += 480;
        }
      }

      line[0U] = varargin_2_data[idxROI + numShape] - size;
      line[1U] = varargin_2_data[idxROI] - 1;
      line[2U] = (varargin_2_data[idxROI + numShape] + size) - 2;
      line[3U] = varargin_2_data[idxROI] - 1;
      isSizeValid = false;

      /* Find the visible portion of a line. */
      visited1 = false;
      visited2 = false;
      done = false;
      for (i = 0; i < 4; i++) {
        b_line[i] = line[i];
      }

      while (!done) {
        i = 0;
        in = 0;

        /* Determine viewport violations. */
        if (b_line[0U] < 0) {
          i = 4;
        } else {
          if (b_line[0U] > 479) {
            i = 8;
          }
        }

        if (b_line[2U] < 0) {
          in = 4;
        } else {
          if (b_line[2U] > 479) {
            in = 8;
          }
        }

        if (b_line[1U] < 0) {
          i |= 1U;
        } else {
          if (b_line[1U] > 639) {
            i |= 2U;
          }
        }

        if (b_line[3U] < 0) {
          in |= 1U;
        } else {
          if (b_line[3U] > 639) {
            in |= 2U;
          }
        }

        if (!(((unsigned int)i | in) != 0U)) {
          /* Line falls completely within bounds. */
          done = true;
          isSizeValid = true;
        } else if (((unsigned int)i & in) != 0U) {
          /* Line falls completely out of bounds. */
          done = true;
          isSizeValid = false;
        } else if ((unsigned int)i != 0U) {
          /* Clip 1st point; if it's in-bounds, clip 2nd point. */
          if (visited1) {
            b_line[0U] = line[0];
            b_line[1U] = col;
          }

          b_idxFillColor = b_line[2] - b_line[0];
          idxPix = b_line[3] - b_line[1];
          if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824) ||
              ((idxPix > 1073741824) || (idxPix < -1073741824))) {
            /* Possible Inf or Nan. */
            done = true;
            isSizeValid = false;
            visited1 = true;
          } else if ((i & 4U) != 0U) {
            /* Violated RMin. */
            i = -b_line[0] * idxPix;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (b_idxFillColor >= 0)) || ((i < 0) &&
                        (b_idxFillColor < 0))) {
              b_line[1U] += (div_s32_floor(i << 1, b_idxFillColor) + 1) >> 1;
            } else {
              b_line[1U] -= (div_s32_floor(-i << 1, b_idxFillColor) + 1) >> 1;
            }

            b_line[0U] = 0;
            visited1 = true;
          } else if ((i & 8U) != 0U) {
            /* Violated RMax. */
            i = (479 - b_line[0]) * idxPix;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (b_idxFillColor >= 0)) || ((i < 0) &&
                        (b_idxFillColor < 0))) {
              b_line[1U] += (div_s32_floor(i << 1, b_idxFillColor) + 1) >> 1;
            } else {
              b_line[1U] -= (div_s32_floor(-i << 1, b_idxFillColor) + 1) >> 1;
            }

            b_line[0U] = 479;
            visited1 = true;
          } else if ((i & 1U) != 0U) {
            /* Violated CMin. */
            i = -b_line[1] * b_idxFillColor;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (idxPix >= 0)) || ((i < 0) && (idxPix < 0)))
            {
              b_line[0U] += (div_s32_floor(i << 1, idxPix) + 1) >> 1;
            } else {
              b_line[0U] -= (div_s32_floor(-i << 1, idxPix) + 1) >> 1;
            }

            b_line[1U] = 0;
            visited1 = true;
          } else {
            /* Violated CMax. */
            i = (639 - b_line[1]) * b_idxFillColor;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (idxPix >= 0)) || ((i < 0) && (idxPix < 0)))
            {
              b_line[0U] += (div_s32_floor(i << 1, idxPix) + 1) >> 1;
            } else {
              b_line[0U] -= (div_s32_floor(-i << 1, idxPix) + 1) >> 1;
            }

            b_line[1U] = 639;
            visited1 = true;
          }
        } else {
          /* Clip the 2nd point. */
          if (visited2) {
            b_line[2U] = line[2];
            b_line[3U] = col;
          }

          b_idxFillColor = b_line[2] - b_line[0];
          idxPix = b_line[3] - b_line[1];
          if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824) ||
              ((idxPix > 1073741824) || (idxPix < -1073741824))) {
            /* Possible Inf or Nan. */
            done = true;
            isSizeValid = false;
            visited2 = true;
          } else if ((in & 4U) != 0U) {
            /* Violated RMin. */
            i = -b_line[2] * idxPix;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (b_idxFillColor >= 0)) || ((i < 0) &&
                        (b_idxFillColor < 0))) {
              b_line[3U] += (div_s32_floor(i << 1, b_idxFillColor) + 1) >> 1;
            } else {
              b_line[3U] -= (div_s32_floor(-i << 1, b_idxFillColor) + 1) >> 1;
            }

            b_line[2U] = 0;
            visited2 = true;
          } else if ((in & 8U) != 0U) {
            /* Violated RMax. */
            i = (479 - b_line[2]) * idxPix;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (b_idxFillColor >= 0)) || ((i < 0) &&
                        (b_idxFillColor < 0))) {
              b_line[3U] += (div_s32_floor(i << 1, b_idxFillColor) + 1) >> 1;
            } else {
              b_line[3U] -= (div_s32_floor(-i << 1, b_idxFillColor) + 1) >> 1;
            }

            b_line[2U] = 479;
            visited2 = true;
          } else if ((in & 1U) != 0U) {
            /* Violated CMin. */
            i = -b_line[3] * b_idxFillColor;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (idxPix >= 0)) || ((i < 0) && (idxPix < 0)))
            {
              b_line[2U] += (div_s32_floor(i << 1, idxPix) + 1) >> 1;
            } else {
              b_line[2U] -= (div_s32_floor(-i << 1, idxPix) + 1) >> 1;
            }

            b_line[3U] = 0;
            visited2 = true;
          } else {
            /* Violated CMax. */
            i = (639 - b_line[3]) * b_idxFillColor;
            if ((i > 1073741824) || (i < -1073741824)) {
              /* Check for Inf or Nan. */
              done = true;
              isSizeValid = false;
            } else if (((i >= 0) && (idxPix >= 0)) || ((i < 0) && (idxPix < 0)))
            {
              b_line[2U] += (div_s32_floor(i << 1, idxPix) + 1) >> 1;
            } else {
              b_line[2U] -= (div_s32_floor(-i << 1, idxPix) + 1) >> 1;
            }

            b_line[3U] = 639;
            visited2 = true;
          }
        }
      }

      if (isSizeValid) {
        i = b_line[1] * 480 + b_line[0];
        for (in = b_line[0]; in <= b_line[2U]; in++) {
          b_idxFillColor = idxFillColor;
          idxPix = i;
          for (row = 0; row < 3; row++) {
            varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
            idxPix += 307200;
            b_idxFillColor += numFillColor;
          }

          i++;
        }
      }

      if (idxFillColor < 3 * (numFillColor - 1)) {
        idxFillColor++;
      } else {
        idxFillColor = 0;
      }
    }
  }
}

/*
 * File trailer for MarkerInserter.c
 *
 * [EOF]
 */
