/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: ShapeInserter.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "ShapeInserter.h"
#include "MarkerInserter.h"
#include "faceTrackingARMKernel_rtwutil.h"

/* Function Definitions */

/*
 * Arguments    : visioncodegen_ShapeInserter *obj
 *                unsigned char varargin_1[921600]
 *                const int varargin_2_data[]
 *                const int varargin_2_size[1]
 *                const unsigned char varargin_3[3]
 * Return Type  : void
 */
void ShapeInserter_outputImpl(visioncodegen_ShapeInserter *obj, unsigned char
  varargin_1[921600], const int varargin_2_data[], const int varargin_2_size[1],
  const unsigned char varargin_3[3])
{
  vision_ShapeInserter_3 *b_obj;
  int numSubShape;
  int colBoundary;
  int ii;
  int len;
  int x1;
  int b_y1;
  int rect[4];
  int x2;
  int y2;
  int halfLineWidth;
  int idxEdgeStartBdy;
  int y1_M_y2;
  boolean_T isMore;
  int idxPtStartBdy;
  int x1_M_x2;
  signed char idxTmpArray[2];
  float acc1_idx_0;
  signed char idxInitArray[2];
  int parallelTo_XorYaxis1;
  float acc1_idx_2;
  float acc1_idx_1;
  float acc1_idx_3;
  boolean_T firstEdgeIsVertical;
  float acc4_idx_0;
  boolean_T isForeground;
  int jj;
  boolean_T isSwapped;
  int kk;
  int i;
  int line[4];
  int idx;
  int curSeparator;
  int loopEndIdx;
  int b_line;
  int numEdge;
  int c_line;
  float acc2_idx_0;
  float acc2_idx_2;
  float acc2_idx_3;
  int lastSeparator;
  int firstRow;
  int colBdy;
  int lastValidCol;
  signed char b_lastSeparator;
  signed char b_loopEndIdx;
  float acc1_idx_5;
  int row;
  unsigned char subPixCount;
  b_obj = &obj->cSFunObject;

  /* System object Outputs function: vision.ShapeInserter */
  if (obj->cSFunObject.P0_RTP_LINEWIDTH == 1) {
    /* Compute output for unity line width
     */
    numSubShape = varargin_2_size[0] >> 1;

    /* Copy the image from input to output. */
    if (numSubShape << 1 == varargin_2_size[0]) {
      /* Update view port. */
      colBoundary = 0;
      for (ii = 0; ii < numSubShape; ii++) {
        rect[0U] = varargin_2_data[(colBoundary << 1) + 1] - 1;
        rect[1U] = varargin_2_data[colBoundary << 1] - 1;
        if (ii < numSubShape - 1) {
          colBoundary++;
        } else {
          colBoundary = 0;
        }

        if ((rect[0U] != varargin_2_data[(colBoundary << 1) + 1] - 1) || (rect
             [1U] != varargin_2_data[colBoundary << 1] - 1)) {
          isMore = false;
          rect[0U] = (rect[0] << 3) + 4;
          rect[2U] = ((varargin_2_data[(colBoundary << 1) + 1] - 1) << 3) + 4;
          rect[1U] = (rect[1] << 3) + 4;
          rect[3U] = ((varargin_2_data[colBoundary << 1] - 1) << 3) + 4;

          /* Find the visible portion of a line. */
          firstEdgeIsVertical = false;
          isForeground = false;
          isSwapped = false;
          for (i = 0; i < 4; i++) {
            line[i] = rect[i];
          }

          while (!isSwapped) {
            y1_M_y2 = 0;
            curSeparator = 0;

            /* Determine viewport violations. */
            if (line[0U] < 0) {
              y1_M_y2 = 4;
            } else {
              if (line[0U] > 3839) {
                y1_M_y2 = 8;
              }
            }

            if (line[2U] < 0) {
              curSeparator = 4;
            } else {
              if (line[2U] > 3839) {
                curSeparator = 8;
              }
            }

            if (line[1U] < 0) {
              y1_M_y2 |= 1U;
            } else {
              if (line[1U] > 5119) {
                y1_M_y2 |= 2U;
              }
            }

            if (line[3U] < 0) {
              curSeparator |= 1U;
            } else {
              if (line[3U] > 5119) {
                curSeparator |= 2U;
              }
            }

            if (!(((unsigned int)y1_M_y2 | curSeparator) != 0U)) {
              /* Line falls completely within bounds. */
              isSwapped = true;
              isMore = true;
            } else if (((unsigned int)y1_M_y2 & curSeparator) != 0U) {
              /* Line falls completely out of bounds. */
              isSwapped = true;
              isMore = false;
            } else if ((unsigned int)y1_M_y2 != 0U) {
              /* Clip 1st point; if it's in-bounds, clip 2nd point. */
              if (firstEdgeIsVertical) {
                line[0U] = rect[0];
                line[1U] = rect[1];
              }

              x1_M_x2 = line[2] - line[0];
              lastSeparator = line[3] - line[1];
              if ((x1_M_x2 > 1073741824) || (x1_M_x2 < -1073741824) ||
                  ((lastSeparator > 1073741824) || (lastSeparator < -1073741824)))
              {
                /* Possible Inf or Nan. */
                isSwapped = true;
                isMore = false;
                firstEdgeIsVertical = true;
              } else if ((y1_M_y2 & 4U) != 0U) {
                /* Violated RMin. */
                y1_M_y2 = -line[0] * lastSeparator;
                if ((y1_M_y2 > 1073741824) || (y1_M_y2 < -1073741824)) {
                  /* Check for Inf or Nan. */
                  isSwapped = true;
                  isMore = false;
                } else if (((y1_M_y2 >= 0) && (x1_M_x2 >= 0)) || ((y1_M_y2 < 0) &&
                            (x1_M_x2 < 0))) {
                  line[1U] += (div_s32_floor(y1_M_y2 << 1, x1_M_x2) + 1) >> 1;
                } else {
                  line[1U] -= (div_s32_floor(-y1_M_y2 << 1, x1_M_x2) + 1) >> 1;
                }

                line[0U] = 0;
                firstEdgeIsVertical = true;
              } else if ((y1_M_y2 & 8U) != 0U) {
                /* Violated RMax. */
                y1_M_y2 = (3839 - line[0]) * lastSeparator;
                if ((y1_M_y2 > 1073741824) || (y1_M_y2 < -1073741824)) {
                  /* Check for Inf or Nan. */
                  isSwapped = true;
                  isMore = false;
                } else if (((y1_M_y2 >= 0) && (x1_M_x2 >= 0)) || ((y1_M_y2 < 0) &&
                            (x1_M_x2 < 0))) {
                  line[1U] += (div_s32_floor(y1_M_y2 << 1, x1_M_x2) + 1) >> 1;
                } else {
                  line[1U] -= (div_s32_floor(-y1_M_y2 << 1, x1_M_x2) + 1) >> 1;
                }

                line[0U] = 3839;
                firstEdgeIsVertical = true;
              } else if ((y1_M_y2 & 1U) != 0U) {
                /* Violated CMin. */
                y1_M_y2 = -line[1] * x1_M_x2;
                if ((y1_M_y2 > 1073741824) || (y1_M_y2 < -1073741824)) {
                  /* Check for Inf or Nan. */
                  isSwapped = true;
                  isMore = false;
                } else if (((y1_M_y2 >= 0) && (lastSeparator >= 0)) || ((y1_M_y2
                  < 0) && (lastSeparator < 0))) {
                  line[0U] += (div_s32_floor(y1_M_y2 << 1, lastSeparator) + 1) >>
                    1;
                } else {
                  line[0U] -= (div_s32_floor(-y1_M_y2 << 1, lastSeparator) + 1) >>
                    1;
                }

                line[1U] = 0;
                firstEdgeIsVertical = true;
              } else {
                /* Violated CMax. */
                y1_M_y2 = (5119 - line[1]) * x1_M_x2;
                if ((y1_M_y2 > 1073741824) || (y1_M_y2 < -1073741824)) {
                  /* Check for Inf or Nan. */
                  isSwapped = true;
                  isMore = false;
                } else if (((y1_M_y2 >= 0) && (lastSeparator >= 0)) || ((y1_M_y2
                  < 0) && (lastSeparator < 0))) {
                  line[0U] += (div_s32_floor(y1_M_y2 << 1, lastSeparator) + 1) >>
                    1;
                } else {
                  line[0U] -= (div_s32_floor(-y1_M_y2 << 1, lastSeparator) + 1) >>
                    1;
                }

                line[1U] = 5119;
                firstEdgeIsVertical = true;
              }
            } else {
              /* Clip the 2nd point. */
              if (isForeground) {
                line[2U] = rect[2];
                line[3U] = rect[3];
              }

              x1_M_x2 = line[2] - line[0];
              lastSeparator = line[3] - line[1];
              if ((x1_M_x2 > 1073741824) || (x1_M_x2 < -1073741824) ||
                  ((lastSeparator > 1073741824) || (lastSeparator < -1073741824)))
              {
                /* Possible Inf or Nan. */
                isSwapped = true;
                isMore = false;
                isForeground = true;
              } else if ((curSeparator & 4U) != 0U) {
                /* Violated RMin. */
                y1_M_y2 = -line[2] * lastSeparator;
                if ((y1_M_y2 > 1073741824) || (y1_M_y2 < -1073741824)) {
                  /* Check for Inf or Nan. */
                  isSwapped = true;
                  isMore = false;
                } else if (((y1_M_y2 >= 0) && (x1_M_x2 >= 0)) || ((y1_M_y2 < 0) &&
                            (x1_M_x2 < 0))) {
                  line[3U] += (div_s32_floor(y1_M_y2 << 1, x1_M_x2) + 1) >> 1;
                } else {
                  line[3U] -= (div_s32_floor(-y1_M_y2 << 1, x1_M_x2) + 1) >> 1;
                }

                line[2U] = 0;
                isForeground = true;
              } else if ((curSeparator & 8U) != 0U) {
                /* Violated RMax. */
                y1_M_y2 = (3839 - line[2]) * lastSeparator;
                if ((y1_M_y2 > 1073741824) || (y1_M_y2 < -1073741824)) {
                  /* Check for Inf or Nan. */
                  isSwapped = true;
                  isMore = false;
                } else if (((y1_M_y2 >= 0) && (x1_M_x2 >= 0)) || ((y1_M_y2 < 0) &&
                            (x1_M_x2 < 0))) {
                  line[3U] += (div_s32_floor(y1_M_y2 << 1, x1_M_x2) + 1) >> 1;
                } else {
                  line[3U] -= (div_s32_floor(-y1_M_y2 << 1, x1_M_x2) + 1) >> 1;
                }

                line[2U] = 3839;
                isForeground = true;
              } else if ((curSeparator & 1U) != 0U) {
                /* Violated CMin. */
                y1_M_y2 = -line[3] * x1_M_x2;
                if ((y1_M_y2 > 1073741824) || (y1_M_y2 < -1073741824)) {
                  /* Check for Inf or Nan. */
                  isSwapped = true;
                  isMore = false;
                } else if (((y1_M_y2 >= 0) && (lastSeparator >= 0)) || ((y1_M_y2
                  < 0) && (lastSeparator < 0))) {
                  line[2U] += (div_s32_floor(y1_M_y2 << 1, lastSeparator) + 1) >>
                    1;
                } else {
                  line[2U] -= (div_s32_floor(-y1_M_y2 << 1, lastSeparator) + 1) >>
                    1;
                }

                line[3U] = 0;
                isForeground = true;
              } else {
                /* Violated CMax. */
                y1_M_y2 = (5119 - line[3]) * x1_M_x2;
                if ((y1_M_y2 > 1073741824) || (y1_M_y2 < -1073741824)) {
                  /* Check for Inf or Nan. */
                  isSwapped = true;
                  isMore = false;
                } else if (((y1_M_y2 >= 0) && (lastSeparator >= 0)) || ((y1_M_y2
                  < 0) && (lastSeparator < 0))) {
                  line[2U] += (div_s32_floor(y1_M_y2 << 1, lastSeparator) + 1) >>
                    1;
                } else {
                  line[2U] -= (div_s32_floor(-y1_M_y2 << 1, lastSeparator) + 1) >>
                    1;
                }

                line[3U] = 5119;
                isForeground = true;
              }
            }
          }

          if (isMore) {
            /* Initialize the Bresenham algorithm. */
            if (line[2U] >= line[0U]) {
              b_line = line[2] - line[0];
            } else {
              b_line = line[0] - line[2];
            }

            if (line[3U] >= line[1U]) {
              c_line = line[3] - line[1];
            } else {
              c_line = line[1] - line[3];
            }

            if (b_line > c_line) {
              jj = 1;
              kk = 480;
            } else {
              jj = 480;
              kk = 1;
              y1_M_y2 = line[0];
              line[0U] = line[1];
              line[1U] = y1_M_y2;
              y1_M_y2 = line[2];
              line[2U] = line[3];
              line[3U] = y1_M_y2;
            }

            if (line[0U] > line[2U]) {
              y1_M_y2 = line[0];
              line[0U] = line[2];
              line[2U] = y1_M_y2;
              y1_M_y2 = line[1];
              line[1U] = line[3];
              line[3U] = y1_M_y2;
            }

            x1 = line[2] - line[0];
            if (line[1U] <= line[3U]) {
              b_y1 = 1;
              curSeparator = line[3] - line[1];
            } else {
              b_y1 = -1;
              curSeparator = line[1] - line[3];
            }

            lastSeparator = line[0];
            firstRow = line[1];
            parallelTo_XorYaxis1 = -((x1 + 1) >> 1);
            if (jj != 1) {
              len = 3839;
            } else {
              len = 5119;
            }

            x2 = line[0] >> 3;
            loopEndIdx = ((x2 + 1) << 3) - line[0];
            y2 = 640;
            halfLineWidth = 0;
            for (idx = 0; idx < 640; idx++) {
              b_obj->W1_DW_PixCount[idx] = 0U;
            }

            isMore = (line[0] <= line[2]);
            while (isMore) {
              loopEndIdx--;
              y1_M_y2 = firstRow - 4;

              /* Compute the next location using Bresenham algorithm. */
              /* Move to the next sub-pixel location. */
              parallelTo_XorYaxis1 += curSeparator;
              if (parallelTo_XorYaxis1 >= 0) {
                firstRow += b_y1;
                parallelTo_XorYaxis1 -= x1;
              }

              lastSeparator++;
              isMore = (lastSeparator <= line[2]);
              if (isMore) {
                x1_M_x2 = y1_M_y2 + 7;
                if ((y1_M_y2 + 7 > 0) && (y1_M_y2 < len)) {
                  if (y1_M_y2 < 0) {
                    y1_M_y2 = 0;
                  }

                  if (x1_M_x2 > len) {
                    x1_M_x2 = len;
                  }

                  numEdge = y1_M_y2 >> 3;
                  i = x1_M_x2 >> 3;
                  if (y2 > numEdge) {
                    y2 = numEdge;
                  }

                  if (halfLineWidth < i) {
                    halfLineWidth = i;
                  }

                  if (i > numEdge) {
                    b_obj->W1_DW_PixCount[numEdge] = (unsigned char)((unsigned
                      int)b_obj->W1_DW_PixCount[numEdge] + (((numEdge + 1) << 3)
                      - y1_M_y2));
                    b_obj->W1_DW_PixCount[i] = (unsigned char)((unsigned int)
                      b_obj->W1_DW_PixCount[i] + ((x1_M_x2 - (i << 3)) + 1));
                    for (row = numEdge + 1; row < i; row++) {
                      b_obj->W1_DW_PixCount[row] = (unsigned char)
                        (b_obj->W1_DW_PixCount[row] + 8U);
                    }
                  } else {
                    if (i == numEdge) {
                      b_obj->W1_DW_PixCount[numEdge] = (unsigned char)((unsigned
                        int)b_obj->W1_DW_PixCount[numEdge] + ((x1_M_x2 - y1_M_y2)
                        + 1));
                    }
                  }
                }
              }

              if ((loopEndIdx == 0) || (!isMore)) {
                while (y2 <= halfLineWidth) {
                  y1_M_y2 = b_obj->W1_DW_PixCount[y2];
                  x1_M_x2 = 0;
                  numEdge = x2 * jj + y2 * kk;
                  for (loopEndIdx = 0; loopEndIdx < 3; loopEndIdx++) {
                    if (y1_M_y2 == 64) {
                      varargin_1[numEdge] = (unsigned char)((varargin_3[x1_M_x2]
                        - varargin_1[numEdge]) + varargin_1[numEdge]);
                    } else {
                      varargin_1[numEdge] = (unsigned char)((float)
                        ((varargin_3[x1_M_x2] - varargin_1[numEdge]) * y1_M_y2) /
                        64.0F + (float)varargin_1[numEdge]);
                    }

                    numEdge += 307200;
                    x1_M_x2++;
                  }

                  b_obj->W1_DW_PixCount[y2] = 0U;
                  y2++;
                }

                loopEndIdx = 8;
                y2 = 640;
                halfLineWidth = 0;
                x2++;
              }
            }
          }
        }
      }
    }
  } else {
    /* Compute output for non-unity line width
     */
    numSubShape = varargin_2_size[0] >> 1;

    /* Copy the image from input to output. */
    if (numSubShape << 1 == varargin_2_size[0]) {
      /* Update view port. */
      /* ProcessStep-start-1
       */
      if (obj->cSFunObject.P0_RTP_LINEWIDTH > 1) {
        len = numSubShape << 1;
        x1 = varargin_2_data[0] - 1;
        b_y1 = varargin_2_data[1] - 1;
        x2 = varargin_2_data[2] - 1;
        y2 = varargin_2_data[3] - 1;
        halfLineWidth = b_obj->P0_RTP_LINEWIDTH >> 1;

        /* getLineParams-1
         */
        /* getLineParams-main fcn
         */
        y1_M_y2 = varargin_2_data[1] - varargin_2_data[3];
        x1_M_x2 = varargin_2_data[0] - varargin_2_data[2];
        if (x1_M_x2 == 0) {
          acc1_idx_0 = 0.0F;
          parallelTo_XorYaxis1 = 1;
          acc1_idx_2 = (float)((varargin_2_data[0] - halfLineWidth) - 1);
          acc1_idx_3 = (float)((varargin_2_data[0] + halfLineWidth) - 1);
        } else if (y1_M_y2 == 0) {
          parallelTo_XorYaxis1 = 2;
          acc1_idx_0 = 0.0F;
          acc1_idx_2 = (float)((varargin_2_data[1] - halfLineWidth) - 1);
          acc1_idx_3 = (float)((varargin_2_data[1] + halfLineWidth) - 1);
        } else {
          parallelTo_XorYaxis1 = 0;
          acc1_idx_0 = (float)y1_M_y2 / (float)x1_M_x2;
          acc1_idx_1 = (float)(varargin_2_data[1] - 1) - (float)
            (varargin_2_data[0] - 1) * acc1_idx_0;
          acc4_idx_0 = (float)halfLineWidth / ((float)x1_M_x2 / (float)sqrt
            ((float)(y1_M_y2 * y1_M_y2 + x1_M_x2 * x1_M_x2)));
          acc1_idx_2 = acc1_idx_1 + acc4_idx_0;
          acc1_idx_3 = acc1_idx_1 - acc4_idx_0;
        }

        jj = 0;
        kk = (numSubShape << 2) >> 1;
        for (ii = 4; ii < len + 4; ii += 2) {
          if (ii < len) {
            idx = ii;
          } else {
            idx = ii - len;
          }

          /* getLineParams-main fcn
           */
          y1_M_y2 = (y2 - varargin_2_data[idx + 1]) + 1;
          x1_M_x2 = (x2 - varargin_2_data[idx]) + 1;
          if (x1_M_x2 == 0) {
            acc2_idx_0 = 0.0F;
            colBoundary = 1;
            acc2_idx_2 = (float)(x2 - halfLineWidth);
            acc2_idx_3 = (float)(x2 + halfLineWidth);
          } else if (y1_M_y2 == 0) {
            colBoundary = 2;
            acc2_idx_0 = 0.0F;
            acc2_idx_2 = (float)(y2 - halfLineWidth);
            acc2_idx_3 = (float)(y2 + halfLineWidth);
          } else {
            colBoundary = 0;
            acc2_idx_0 = (float)y1_M_y2 / (float)x1_M_x2;
            acc1_idx_1 = (float)y2 - (float)x2 * acc2_idx_0;
            acc4_idx_0 = (float)halfLineWidth / ((float)x1_M_x2 / (float)sqrt
              ((float)(y1_M_y2 * y1_M_y2 + x1_M_x2 * x1_M_x2)));
            acc2_idx_2 = acc1_idx_1 + acc4_idx_0;
            acc2_idx_3 = acc1_idx_1 - acc4_idx_0;
          }

          /* isValidPair- main fcn
           */
          if (parallelTo_XorYaxis1 == 1) {
            acc4_idx_0 = (float)fabs(acc1_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc1_idx_2 + 0.5F);
              } else {
                acc1_idx_1 = acc1_idx_2 * 0.0F;
              }
            } else {
              acc1_idx_1 = acc1_idx_2;
            }

            y1_M_y2 = (int)acc1_idx_1;
            x1_M_x2 = b_y1;
          } else if (parallelTo_XorYaxis1 == 2) {
            y1_M_y2 = x1;
            acc4_idx_0 = (float)fabs(acc1_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc1_idx_2 + 0.5F);
              } else {
                acc1_idx_1 = acc1_idx_2 * 0.0F;
              }
            } else {
              acc1_idx_1 = acc1_idx_2;
            }

            x1_M_x2 = (int)acc1_idx_1;
          } else {
            y1_M_y2 = 0;
            acc4_idx_0 = (float)fabs(acc1_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc1_idx_2 + 0.5F);
              } else {
                acc1_idx_1 = acc1_idx_2 * 0.0F;
              }
            } else {
              acc1_idx_1 = acc1_idx_2;
            }

            x1_M_x2 = (int)acc1_idx_1;
          }

          /* is_RightOfLine_CtrToRef- main fcn
           */
          lastSeparator = (x2 - x1) * (x1_M_x2 - b_y1) - (y1_M_y2 - x1) * (y2 -
            b_y1);
          if (colBoundary == 1) {
            acc4_idx_0 = (float)fabs(acc2_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc2_idx_2 + 0.5F);
              } else {
                acc1_idx_1 = acc2_idx_2 * 0.0F;
              }
            } else {
              acc1_idx_1 = acc2_idx_2;
            }

            curSeparator = (int)acc1_idx_1;
            firstRow = b_y1;
          } else if (colBoundary == 2) {
            curSeparator = x1;
            acc4_idx_0 = (float)fabs(acc2_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc2_idx_2 + 0.5F);
              } else {
                acc1_idx_1 = acc2_idx_2 * 0.0F;
              }
            } else {
              acc1_idx_1 = acc2_idx_2;
            }

            firstRow = (int)acc1_idx_1;
          } else {
            curSeparator = 0;
            acc4_idx_0 = (float)fabs(acc2_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc2_idx_2 + 0.5F);
              } else {
                acc1_idx_1 = acc2_idx_2 * 0.0F;
              }
            } else {
              acc1_idx_1 = acc2_idx_2;
            }

            firstRow = (int)acc1_idx_1;
          }

          /* is_RightOfLine_CtrToRef- main fcn
           */
          loopEndIdx = ((varargin_2_data[idx] - x2) - 1) * (firstRow - y2) -
            (curSeparator - x2) * ((varargin_2_data[idx + 1] - y2) - 1);
          if (lastSeparator < 0) {
            b_lastSeparator = 1;
          } else if (lastSeparator > 0) {
            b_lastSeparator = 0;
          } else {
            b_lastSeparator = (signed char)((x2 - x1) * (x2 - x1) + (y2 - b_y1) *
              (y2 - b_y1) > (y1_M_y2 - x1) * (y1_M_y2 - x1) + (x1_M_x2 - b_y1) *
              (x1_M_x2 - b_y1));
          }

          if (loopEndIdx < 0) {
            b_loopEndIdx = 1;
          } else if (loopEndIdx > 0) {
            b_loopEndIdx = 0;
          } else {
            b_loopEndIdx = (signed char)(((varargin_2_data[idx] - x2) - 1) *
              ((varargin_2_data[idx] - x2) - 1) + ((varargin_2_data[idx + 1] -
              y2) - 1) * ((varargin_2_data[idx + 1] - y2) - 1) > (curSeparator -
              x2) * (curSeparator - x2) + (firstRow - y2) * (firstRow - y2));
          }

          if (b_lastSeparator != b_loopEndIdx) {
            acc1_idx_1 = acc2_idx_2;
            acc2_idx_2 = acc2_idx_3;
            acc2_idx_3 = acc1_idx_1;
          }

          /* findPointOfIntersection- main fcn
           */
          isMore = false;
          if (parallelTo_XorYaxis1 == 1) {
            isMore = true;
          }

          firstEdgeIsVertical = false;
          if (colBoundary == 1) {
            firstEdgeIsVertical = true;
          }

          if (isMore && firstEdgeIsVertical) {
            acc4_idx_0 = (float)fabs(acc1_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_2 = (float)floor(acc1_idx_2 + 0.5F);
              } else {
                acc1_idx_2 *= 0.0F;
              }
            }

            lastSeparator = (int)acc1_idx_2;
            x1_M_x2 = y2;
          } else if (isMore) {
            acc4_idx_0 = (float)fabs(acc1_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_2 = (float)floor(acc1_idx_2 + 0.5F);
              } else {
                acc1_idx_2 *= 0.0F;
              }
            }

            lastSeparator = (int)acc1_idx_2;
            acc1_idx_1 = (float)lastSeparator * acc2_idx_0 + acc2_idx_2;
            acc4_idx_0 = (float)fabs(acc1_idx_1);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc1_idx_1 + 0.5F);
              } else {
                acc1_idx_1 *= 0.0F;
              }
            }

            x1_M_x2 = (int)acc1_idx_1;
          } else if (firstEdgeIsVertical) {
            acc4_idx_0 = (float)fabs(acc2_idx_2);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc2_idx_2 + 0.5F);
              } else {
                acc1_idx_1 = acc2_idx_2 * 0.0F;
              }
            } else {
              acc1_idx_1 = acc2_idx_2;
            }

            lastSeparator = (int)acc1_idx_1;
            acc1_idx_1 = (float)lastSeparator * acc1_idx_0 + acc1_idx_2;
            acc4_idx_0 = (float)fabs(acc1_idx_1);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc1_idx_1 + 0.5F);
              } else {
                acc1_idx_1 *= 0.0F;
              }
            }

            x1_M_x2 = (int)acc1_idx_1;
          } else {
            acc4_idx_0 = acc1_idx_0 - acc2_idx_0;
            if (acc4_idx_0 == 0.0F) {
              lastSeparator = x2;
              acc1_idx_1 = (float)x2 * acc1_idx_0 + acc1_idx_2;
              acc4_idx_0 = (float)fabs(acc1_idx_1);
              if (acc4_idx_0 < 8.388608E+6F) {
                if (acc4_idx_0 >= 0.5F) {
                  acc1_idx_1 = (float)floor(acc1_idx_1 + 0.5F);
                } else {
                  acc1_idx_1 *= 0.0F;
                }
              }

              x1_M_x2 = (int)acc1_idx_1;
            } else {
              acc1_idx_5 = (acc2_idx_2 - acc1_idx_2) / acc4_idx_0;
              acc4_idx_0 = (float)fabs(acc1_idx_5);
              if (acc4_idx_0 < 8.388608E+6F) {
                if (acc4_idx_0 >= 0.5F) {
                  acc1_idx_1 = (float)floor(acc1_idx_5 + 0.5F);
                } else {
                  acc1_idx_1 = acc1_idx_5 * 0.0F;
                }
              } else {
                acc1_idx_1 = acc1_idx_5;
              }

              lastSeparator = (int)acc1_idx_1;
              acc1_idx_1 = acc1_idx_0 * acc1_idx_5 + acc1_idx_2;
              acc4_idx_0 = (float)fabs(acc1_idx_1);
              if (acc4_idx_0 < 8.388608E+6F) {
                if (acc4_idx_0 >= 0.5F) {
                  acc1_idx_1 = (float)floor(acc1_idx_1 + 0.5F);
                } else {
                  acc1_idx_1 *= 0.0F;
                }
              }

              x1_M_x2 = (int)acc1_idx_1;
            }
          }

          /* findPointOfIntersection- main fcn
           */
          isMore = false;
          if (parallelTo_XorYaxis1 == 1) {
            isMore = true;
          }

          firstEdgeIsVertical = false;
          if (colBoundary == 1) {
            firstEdgeIsVertical = true;
          }

          if (isMore && firstEdgeIsVertical) {
            acc4_idx_0 = (float)fabs(acc1_idx_3);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_3 = (float)floor(acc1_idx_3 + 0.5F);
              } else {
                acc1_idx_3 *= 0.0F;
              }
            }

            y1_M_y2 = (int)acc1_idx_3;
            curSeparator = y2;
          } else if (isMore) {
            acc4_idx_0 = (float)fabs(acc1_idx_3);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_3 = (float)floor(acc1_idx_3 + 0.5F);
              } else {
                acc1_idx_3 *= 0.0F;
              }
            }

            y1_M_y2 = (int)acc1_idx_3;
            acc1_idx_1 = (float)y1_M_y2 * acc2_idx_0 + acc2_idx_3;
            acc4_idx_0 = (float)fabs(acc1_idx_1);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc1_idx_1 + 0.5F);
              } else {
                acc1_idx_1 *= 0.0F;
              }
            }

            curSeparator = (int)acc1_idx_1;
          } else if (firstEdgeIsVertical) {
            acc4_idx_0 = (float)fabs(acc2_idx_3);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc2_idx_3 + 0.5F);
              } else {
                acc1_idx_1 = acc2_idx_3 * 0.0F;
              }
            } else {
              acc1_idx_1 = acc2_idx_3;
            }

            y1_M_y2 = (int)acc1_idx_1;
            acc1_idx_1 = (float)y1_M_y2 * acc1_idx_0 + acc1_idx_3;
            acc4_idx_0 = (float)fabs(acc1_idx_1);
            if (acc4_idx_0 < 8.388608E+6F) {
              if (acc4_idx_0 >= 0.5F) {
                acc1_idx_1 = (float)floor(acc1_idx_1 + 0.5F);
              } else {
                acc1_idx_1 *= 0.0F;
              }
            }

            curSeparator = (int)acc1_idx_1;
          } else {
            acc4_idx_0 = acc1_idx_0 - acc2_idx_0;
            if (acc4_idx_0 == 0.0F) {
              y1_M_y2 = x2;
              acc1_idx_1 = (float)x2 * acc1_idx_0 + acc1_idx_3;
              acc4_idx_0 = (float)fabs(acc1_idx_1);
              if (acc4_idx_0 < 8.388608E+6F) {
                if (acc4_idx_0 >= 0.5F) {
                  acc1_idx_1 = (float)floor(acc1_idx_1 + 0.5F);
                } else {
                  acc1_idx_1 *= 0.0F;
                }
              }

              curSeparator = (int)acc1_idx_1;
            } else {
              acc1_idx_5 = (acc2_idx_3 - acc1_idx_3) / acc4_idx_0;
              acc4_idx_0 = (float)fabs(acc1_idx_5);
              if (acc4_idx_0 < 8.388608E+6F) {
                if (acc4_idx_0 >= 0.5F) {
                  acc1_idx_1 = (float)floor(acc1_idx_5 + 0.5F);
                } else {
                  acc1_idx_1 = acc1_idx_5 * 0.0F;
                }
              } else {
                acc1_idx_1 = acc1_idx_5;
              }

              y1_M_y2 = (int)acc1_idx_1;
              acc1_idx_1 = acc1_idx_0 * acc1_idx_5 + acc1_idx_3;
              acc4_idx_0 = (float)fabs(acc1_idx_1);
              if (acc4_idx_0 < 8.388608E+6F) {
                if (acc4_idx_0 >= 0.5F) {
                  acc1_idx_1 = (float)floor(acc1_idx_1 + 0.5F);
                } else {
                  acc1_idx_1 *= 0.0F;
                }
              }

              curSeparator = (int)acc1_idx_1;
            }
          }

          b_obj->W2_DW_Points[jj] = lastSeparator;
          jj += 2;
          b_obj->W2_DW_Points[jj - 1] = x1_M_x2;
          b_obj->W2_DW_Points[kk] = y1_M_y2;
          b_obj->W2_DW_Points[kk + 1] = curSeparator;
          kk += 2;
          x1 = x2;
          b_y1 = y2;
          x2 = varargin_2_data[idx] - 1;
          y2 = varargin_2_data[idx + 1] - 1;
          acc1_idx_0 = acc2_idx_0;
          acc1_idx_2 = acc2_idx_2;
          acc1_idx_3 = acc2_idx_3;
          parallelTo_XorYaxis1 = colBoundary;
        }
      }

      /* ProcessStep-after poly points-1
       */
      /* just before call for cgpolygon
       */
      if (obj->cSFunObject.P0_RTP_LINEWIDTH > 1) {
        /* just before call for cgpolygon-2
         */
        numSubShape <<= 1;
      }

      for (ii = 0; ii < 480; ii++) {
        b_obj->W1_DW_PixCount[ii] = 0U;
      }

      /* Reset scanline states. */
      idxEdgeStartBdy = 0;
      idxPtStartBdy = 0;
      if (0 < numSubShape * 9) {
        idxTmpArray[1U] = (signed char)(numSubShape - 1);
        idxInitArray[0U] = 0;
      }

      isMore = (0 < numSubShape * 9);
      while (isMore) {
        /* Initialize the scanline. */
        /* Convert polygon vertices to boundaries. */
        firstEdgeIsVertical = false;
        y1_M_y2 = 0;
        if (b_obj->P0_RTP_LINEWIDTH > 1) {
          y1_M_y2 = 1;
        }

        if (!(y1_M_y2 != 0)) {
          parallelTo_XorYaxis1 = numSubShape;
          loopEndIdx = 1;
        } else {
          parallelTo_XorYaxis1 = numSubShape >> 1;
          loopEndIdx = 2;
        }

        numEdge = 0;
        len = idxEdgeStartBdy;
        x2 = idxEdgeStartBdy;
        idxTmpArray[0U] = (signed char)(parallelTo_XorYaxis1 - 1);
        idxInitArray[1U] = (signed char)parallelTo_XorYaxis1;
        for (ii = 0; ii < loopEndIdx; ii++) {
          /* start for loop
           */
          y2 = ((idxTmpArray[ii] << 1) + idxPtStartBdy) + 1;
          halfLineWidth = (idxTmpArray[ii] << 1) + idxPtStartBdy;
          curSeparator = idxTmpArray[ii] - 1;
          jj = ((idxTmpArray[ii] - 1) << 1) + idxPtStartBdy;
          kk = parallelTo_XorYaxis1;
          if (b_obj->P0_RTP_LINEWIDTH > 1) {
            /* getLoc-1
             */
            x1 = b_obj->W2_DW_Points[halfLineWidth];
          } else {
            /* getLoc-2
             */
            x1 = varargin_2_data[halfLineWidth];
          }

          if (b_obj->P0_RTP_LINEWIDTH > 1) {
            /* getLoc-1
             */
            lastSeparator = b_obj->W2_DW_Points[jj];
          } else {
            /* getLoc-2
             */
            lastSeparator = varargin_2_data[jj];
          }

          while ((jj >= 0) && (x1 - 1 == lastSeparator - 1)) {
            curSeparator--;
            jj = (curSeparator << 1) + idxPtStartBdy;
            kk--;
            if (b_obj->P0_RTP_LINEWIDTH > 1) {
              /* getLoc-1
               */
              lastSeparator = b_obj->W2_DW_Points[jj];
            } else {
              /* getLoc-2
               */
              lastSeparator = varargin_2_data[jj];
            }
          }

          if (jj < 0) {
            jj = 0;
          }

          if (b_obj->P0_RTP_LINEWIDTH > 1) {
            /* getLoc-1
             */
            x1 = b_obj->W2_DW_Points[halfLineWidth];
          } else {
            /* getLoc-2
             */
            x1 = varargin_2_data[halfLineWidth];
          }

          if (b_obj->P0_RTP_LINEWIDTH > 1) {
            /* getLoc-1
             */
            lastSeparator = b_obj->W2_DW_Points[jj];
          } else {
            /* getLoc-2
             */
            lastSeparator = varargin_2_data[jj];
          }

          isForeground = (lastSeparator - 1 > x1 - 1);
          colBoundary = ((idxInitArray[ii] << 1) + idxPtStartBdy) + 1;
          jj = (idxInitArray[ii] << 1) + idxPtStartBdy;
          isMore = false;
          if (b_obj->P0_RTP_LINEWIDTH > 1) {
            /* getLoc-1
             */
            x1 = b_obj->W2_DW_Points[jj];
          } else {
            /* getLoc-2
             */
            x1 = varargin_2_data[jj];
          }

          if (b_obj->P0_RTP_LINEWIDTH > 1) {
            /* getLoc-1
             */
            lastSeparator = b_obj->W2_DW_Points[halfLineWidth];
          } else {
            /* getLoc-2
             */
            lastSeparator = varargin_2_data[halfLineWidth];
          }

          firstEdgeIsVertical = (lastSeparator - 1 == x1 - 1);
          for (i = 0; i < kk; i++) {
            if (b_obj->P0_RTP_LINEWIDTH > 1) {
              /* getLoc-1
               */
              x1 = b_obj->W2_DW_Points[jj];
            } else {
              /* getLoc-2
               */
              x1 = varargin_2_data[jj];
            }

            if (b_obj->P0_RTP_LINEWIDTH > 1) {
              /* getLoc-1
               */
              lastSeparator = b_obj->W2_DW_Points[halfLineWidth];
            } else {
              /* getLoc-2
               */
              lastSeparator = varargin_2_data[halfLineWidth];
            }

            if (lastSeparator - 1 != x1 - 1) {
              if (b_obj->P0_RTP_LINEWIDTH > 1) {
                /* getLoc-1
                 */
                x1 = b_obj->W2_DW_Points[jj];
              } else {
                /* getLoc-2
                 */
                x1 = varargin_2_data[jj];
              }

              if (b_obj->P0_RTP_LINEWIDTH > 1) {
                /* getLoc-1
                 */
                lastSeparator = b_obj->W2_DW_Points[halfLineWidth];
              } else {
                /* getLoc-2
                 */
                lastSeparator = varargin_2_data[halfLineWidth];
              }

              if (lastSeparator - 1 < x1 - 1) {
                isSwapped = false;
              } else {
                isSwapped = true;
                curSeparator = y2;
                y2 = colBoundary;
                colBoundary = curSeparator;
                curSeparator = halfLineWidth;
                halfLineWidth = jj;
                jj = curSeparator;
              }

              if (b_obj->P0_RTP_LINEWIDTH > 1) {
                /* getLoc-1
                 */
                x1 = b_obj->W2_DW_Points[jj];
              } else {
                /* getLoc-2
                 */
                x1 = varargin_2_data[jj];
              }

              if (b_obj->P0_RTP_LINEWIDTH > 1) {
                /* getLoc-1
                 */
                lastSeparator = b_obj->W2_DW_Points[colBoundary];
              } else {
                /* getLoc-2
                 */
                lastSeparator = varargin_2_data[colBoundary];
              }

              if (b_obj->P0_RTP_LINEWIDTH > 1) {
                /* getLoc-1
                 */
                x1_M_x2 = b_obj->W2_DW_Points[halfLineWidth];
              } else {
                /* getLoc-2
                 */
                x1_M_x2 = varargin_2_data[halfLineWidth];
              }

              if (b_obj->P0_RTP_LINEWIDTH > 1) {
                /* getLoc-1
                 */
                y1_M_y2 = b_obj->W2_DW_Points[y2];
              } else {
                /* getLoc-2
                 */
                y1_M_y2 = varargin_2_data[y2];
              }

              /* Initialize a Bresenham line. */
              b_y1 = ((y1_M_y2 - 1) << 3) + 4;
              firstRow = ((x1_M_x2 - 1) << 3) + 4;
              curSeparator = ((lastSeparator - 1) << 3) + 4;
              y1_M_y2 = ((x1 - 1) << 3) + 4;
              x1_M_x2 = y1_M_y2 - firstRow;
              b_obj->W0_DW_Polygon[x2] = 0;
              b_obj->W0_DW_Polygon[x2 + 1] = b_y1;
              b_obj->W0_DW_Polygon[x2 + 2] = firstRow;
              b_obj->W0_DW_Polygon[x2 + 3] = y1_M_y2;
              b_obj->W0_DW_Polygon[x2 + 6] = 0;
              if (curSeparator >= b_y1) {
                b_obj->W0_DW_Polygon[x2 + 8] = curSeparator - b_y1;
              } else {
                b_obj->W0_DW_Polygon[x2 + 8] = b_y1 - curSeparator;
              }

              while (b_obj->W0_DW_Polygon[x2 + 8] >= 0) {
                b_obj->W0_DW_Polygon[x2 + 6]++;
                b_obj->W0_DW_Polygon[x2 + 8] -= x1_M_x2;
              }

              b_obj->W0_DW_Polygon[x2 + 5] = b_obj->W0_DW_Polygon[x2 + 6] - 1;
              b_obj->W0_DW_Polygon[x2 + 7] = b_obj->W0_DW_Polygon[x2 + 8] +
                x1_M_x2;
              b_obj->W0_DW_Polygon[x2 + 4] = x1_M_x2 - (b_obj->W0_DW_Polygon[x2
                + 7] << 1);
              if (b_y1 > curSeparator) {
                b_obj->W0_DW_Polygon[x2 + 5] = -b_obj->W0_DW_Polygon[x2 + 5];
                b_obj->W0_DW_Polygon[x2 + 6] = -b_obj->W0_DW_Polygon[x2 + 6];
              }

              if ((!isForeground) && (!isSwapped)) {
                /* Use Bresenham algorithm to calculate the polygon boundaries at the next column */
                b_obj->W0_DW_Polygon[x2 + 2]++;
                if ((b_obj->W0_DW_Polygon[x2] << 1) > b_obj->W0_DW_Polygon[x2 +
                    4]) {
                  b_obj->W0_DW_Polygon[x2] += b_obj->W0_DW_Polygon[x2 + 8];
                  b_obj->W0_DW_Polygon[x2 + 1] += b_obj->W0_DW_Polygon[x2 + 6];
                } else {
                  b_obj->W0_DW_Polygon[x2] += b_obj->W0_DW_Polygon[x2 + 7];
                  b_obj->W0_DW_Polygon[x2 + 1] += b_obj->W0_DW_Polygon[x2 + 5];
                }
              } else {
                if (isForeground && isSwapped) {
                  b_obj->W0_DW_Polygon[x2 + 3]--;
                }
              }

              isForeground = isSwapped;
              if (!isMore) {
                /* Merge two Bresenham lines. */
                isMore = false;
                if ((len != x2) && ((b_obj->W0_DW_Polygon[len + 5] ==
                                     b_obj->W0_DW_Polygon[x2 + 5]) &&
                                    (b_obj->W0_DW_Polygon[len + 6] ==
                                     b_obj->W0_DW_Polygon[x2 + 6]) &&
                                    (b_obj->W0_DW_Polygon[len + 7] ==
                                     b_obj->W0_DW_Polygon[x2 + 7]) &&
                                    (b_obj->W0_DW_Polygon[len + 8] ==
                                     b_obj->W0_DW_Polygon[x2 + 8]))) {
                  if (b_obj->W0_DW_Polygon[x2 + 2] == b_obj->W0_DW_Polygon[len +
                      3] + 1) {
                    b_obj->W0_DW_Polygon[len + 3] = b_obj->W0_DW_Polygon[x2 + 3];
                    isMore = true;
                  } else {
                    if (b_obj->W0_DW_Polygon[len + 2] == b_obj->W0_DW_Polygon[x2
                        + 3] + 1) {
                      b_obj->W0_DW_Polygon[len + 1] = b_obj->W0_DW_Polygon[x2 +
                        1];
                      b_obj->W0_DW_Polygon[len + 2] = b_obj->W0_DW_Polygon[x2 +
                        2];
                      isMore = true;
                    }
                  }
                }

                if (!isMore) {
                  len = x2;
                  numEdge++;
                }
              } else {
                len = x2;
                numEdge++;
              }

              x2 = len + 9;
              if (!isSwapped) {
                y2 = colBoundary;
                halfLineWidth = jj;
              }

              colBoundary = y2 + 2;
              jj = halfLineWidth + 2;
              isMore = false;
            } else {
              isMore = true;
              y2 = colBoundary;
              halfLineWidth = jj;
              colBoundary += 2;
              jj += 2;
            }
          }
        }

        if (!firstEdgeIsVertical) {
          /* Merge two Bresenham lines. */
          isMore = false;
          if ((idxEdgeStartBdy != len) && ((b_obj->W0_DW_Polygon[idxEdgeStartBdy
                + 5] == b_obj->W0_DW_Polygon[len + 5]) && (b_obj->
                W0_DW_Polygon[idxEdgeStartBdy + 6] == b_obj->W0_DW_Polygon[len +
                6]) && (b_obj->W0_DW_Polygon[idxEdgeStartBdy + 7] ==
                        b_obj->W0_DW_Polygon[len + 7]) && (b_obj->
                W0_DW_Polygon[idxEdgeStartBdy + 8] == b_obj->W0_DW_Polygon[len +
                8]))) {
            if (b_obj->W0_DW_Polygon[len + 2] == b_obj->
                W0_DW_Polygon[idxEdgeStartBdy + 3] + 1) {
              b_obj->W0_DW_Polygon[idxEdgeStartBdy + 3] = b_obj->
                W0_DW_Polygon[len + 3];
              isMore = true;
            } else {
              if (b_obj->W0_DW_Polygon[idxEdgeStartBdy + 2] ==
                  b_obj->W0_DW_Polygon[len + 3] + 1) {
                b_obj->W0_DW_Polygon[idxEdgeStartBdy + 1] = b_obj->
                  W0_DW_Polygon[len + 1];
                b_obj->W0_DW_Polygon[idxEdgeStartBdy + 2] = b_obj->
                  W0_DW_Polygon[len + 2];
                isMore = true;
              }
            }
          }

          if (isMore) {
            numEdge--;
            x2 -= 9;
          }
        }

        /* Set all other edges to invalid. */
        for (i = numEdge; i < numSubShape; i++) {
          b_obj->W0_DW_Polygon[x2 + 2] = 1;
          b_obj->W0_DW_Polygon[x2 + 3] = 0;
          x2 += 9;
        }

        /* Sort the boundaries of the polygon. */
        isMore = true;
        while (isMore) {
          y1_M_y2 = idxEdgeStartBdy;
          x1_M_x2 = idxEdgeStartBdy + 9;
          isMore = false;
          for (i = 1; i < numEdge; i++) {
            if (b_obj->W0_DW_Polygon[y1_M_y2 + 2] > b_obj->W0_DW_Polygon[x1_M_x2
                + 2]) {
              isMore = true;
              for (b_y1 = 0; b_y1 < 9; b_y1++) {
                loopEndIdx = b_obj->W0_DW_Polygon[y1_M_y2 + b_y1];
                b_obj->W0_DW_Polygon[y1_M_y2 + b_y1] = b_obj->
                  W0_DW_Polygon[x1_M_x2 + b_y1];
                b_obj->W0_DW_Polygon[x1_M_x2 + b_y1] = loopEndIdx;
              }
            }

            y1_M_y2 = x1_M_x2;
            x1_M_x2 += 9;
          }
        }

        /* Find out the last column of the polygon. */
        idx = idxEdgeStartBdy + 3;
        colBdy = b_obj->W0_DW_Polygon[idxEdgeStartBdy + 3];
        for (i = 1; i < numEdge; i++) {
          idx += 9;
          if (colBdy < b_obj->W0_DW_Polygon[idx]) {
            colBdy = b_obj->W0_DW_Polygon[idx];
          }
        }

        lastValidCol = colBdy;
        if (colBdy > 5119) {
          lastValidCol = 5119;
        }

        /* Find out the first column of the polygon. */
        idx = idxEdgeStartBdy + 2;
        colBdy = b_obj->W0_DW_Polygon[idxEdgeStartBdy + 2];
        for (i = 1; i < numEdge; i++) {
          idx += 9;
          if (colBdy > b_obj->W0_DW_Polygon[idx]) {
            colBdy = b_obj->W0_DW_Polygon[idx];
          }
        }

        if (colBdy < 0) {
          colBdy = 0;
        }

        /* Move to the next column and find out boundaries of the polygon at this column. */
        y1_M_y2 = idxEdgeStartBdy;
        x1_M_x2 = idxEdgeStartBdy;
        x2 = idxEdgeStartBdy;
        y2 = 0;
        x1 = 0;
        for (i = 0; i < numEdge; i++) {
          /* Find out the valid boundaries and bring them to the latest column. */
          if (b_obj->W0_DW_Polygon[x1_M_x2 + 3] >= colBdy) {
            if (b_obj->W0_DW_Polygon[x1_M_x2 + 2] <= colBdy) {
              while (b_obj->W0_DW_Polygon[x1_M_x2 + 2] < colBdy) {
                /* Use Bresenham algorithm to calculate the polygon boundaries at the next column */
                b_obj->W0_DW_Polygon[x1_M_x2 + 2]++;
                if ((b_obj->W0_DW_Polygon[x1_M_x2] << 1) > b_obj->
                    W0_DW_Polygon[x1_M_x2 + 4]) {
                  b_obj->W0_DW_Polygon[x1_M_x2] += b_obj->W0_DW_Polygon[x1_M_x2
                    + 8];
                  b_obj->W0_DW_Polygon[x1_M_x2 + 1] += b_obj->
                    W0_DW_Polygon[x1_M_x2 + 6];
                } else {
                  b_obj->W0_DW_Polygon[x1_M_x2] += b_obj->W0_DW_Polygon[x1_M_x2
                    + 7];
                  b_obj->W0_DW_Polygon[x1_M_x2 + 1] += b_obj->
                    W0_DW_Polygon[x1_M_x2 + 5];
                }
              }

              x2 += 9;
              x1++;
            }

            if (x1_M_x2 != y1_M_y2) {
              for (b_y1 = 0; b_y1 < 9; b_y1++) {
                b_obj->W0_DW_Polygon[y1_M_y2 + b_y1] = b_obj->
                  W0_DW_Polygon[x1_M_x2 + b_y1];
              }
            }

            y1_M_y2 += 9;
            y2++;
          }

          x1_M_x2 += 9;
        }

        /* Sort the boundaries of the polygon according to row values. */
        /* Sort the boundaries of the polygon. */
        isMore = true;
        while (isMore) {
          y1_M_y2 = idxEdgeStartBdy;
          x1_M_x2 = idxEdgeStartBdy + 9;
          isMore = false;
          for (i = 1; i < x1; i++) {
            if (b_obj->W0_DW_Polygon[y1_M_y2 + 1] > b_obj->W0_DW_Polygon[x1_M_x2
                + 1]) {
              isMore = true;
              for (b_y1 = 0; b_y1 < 9; b_y1++) {
                loopEndIdx = b_obj->W0_DW_Polygon[y1_M_y2 + b_y1];
                b_obj->W0_DW_Polygon[y1_M_y2 + b_y1] = b_obj->
                  W0_DW_Polygon[x1_M_x2 + b_y1];
                b_obj->W0_DW_Polygon[x1_M_x2 + b_y1] = loopEndIdx;
              }
            }

            y1_M_y2 = x1_M_x2;
            x1_M_x2 += 9;
          }
        }

        x1 = idxEdgeStartBdy;
        halfLineWidth = colBdy + 1;
        jj = 0;
        b_y1 = 0;
        lastSeparator = -1;
        kk = colBdy >> 3;
        colBoundary = ((kk + 1) << 3) - 1;
        ii = 480;
        idx = 0;
        isMore = (0 <= lastValidCol);
        while (isMore) {
          /* Get a string of pixels */
          firstEdgeIsVertical = false;
          isForeground = (b_y1 != 0);
          len = jj;
          if ((jj >= colBdy) && (jj <= lastValidCol)) {
            if (x1 < x2) {
              y1_M_y2 = b_obj->W0_DW_Polygon[x1 + 1];
              x1 += 9;
              curSeparator = y1_M_y2;
              if ((y1_M_y2 == lastSeparator) && (x1 < x2)) {
                y1_M_y2 = b_obj->W0_DW_Polygon[x1 + 1];
                x1_M_x2 = y1_M_y2;
                isMore = (x1 < x2);
                while (isMore && (curSeparator == x1_M_x2)) {
                  firstEdgeIsVertical = true;
                  y1_M_y2 = b_obj->W0_DW_Polygon[x1 + 1];
                  x1 += 9;
                  curSeparator = y1_M_y2;
                  isMore = (x1 < x2);
                  if (isMore) {
                    y1_M_y2 = b_obj->W0_DW_Polygon[x1 + 1];
                    x1_M_x2 = y1_M_y2;
                  }
                }

                if (!isMore) {
                  firstEdgeIsVertical = false;
                }
              }

              if (b_y1 != 0) {
                firstRow = lastSeparator;
                if (curSeparator <= 3839) {
                  parallelTo_XorYaxis1 = curSeparator;
                  lastSeparator = curSeparator;
                } else {
                  parallelTo_XorYaxis1 = 3839;
                  lastSeparator = 3839;
                }
              } else {
                firstRow = lastSeparator + 1;
                if ((curSeparator > 0) && (curSeparator <= 3839)) {
                  parallelTo_XorYaxis1 = curSeparator - 1;
                  lastSeparator = curSeparator;
                } else if (curSeparator <= 0) {
                  parallelTo_XorYaxis1 = -1;
                  lastSeparator = 0;
                } else {
                  parallelTo_XorYaxis1 = 3839;
                  lastSeparator = 3840;
                }
              }

              if (!firstEdgeIsVertical) {
                b_y1 = !(b_y1 != 0);
              }
            } else {
              /* Reset states and move to the next column. */
              isForeground = false;
              firstRow = lastSeparator + 1;
              parallelTo_XorYaxis1 = 3839;

              /* Move to the next column and find out boundaries of the polygon at this column. */
              y1_M_y2 = idxEdgeStartBdy;
              x1_M_x2 = idxEdgeStartBdy;
              x2 = idxEdgeStartBdy;
              numEdge = 0;
              x1 = 0;
              for (i = 0; i < y2; i++) {
                /* Find out the valid boundaries and bring them to the latest column. */
                if (b_obj->W0_DW_Polygon[x1_M_x2 + 3] >= halfLineWidth) {
                  if (b_obj->W0_DW_Polygon[x1_M_x2 + 2] <= halfLineWidth) {
                    while (b_obj->W0_DW_Polygon[x1_M_x2 + 2] < halfLineWidth) {
                      /* Use Bresenham algorithm to calculate the polygon boundaries at the next column */
                      b_obj->W0_DW_Polygon[x1_M_x2 + 2]++;
                      if ((b_obj->W0_DW_Polygon[x1_M_x2] << 1) >
                          b_obj->W0_DW_Polygon[x1_M_x2 + 4]) {
                        b_obj->W0_DW_Polygon[x1_M_x2] += b_obj->
                          W0_DW_Polygon[x1_M_x2 + 8];
                        b_obj->W0_DW_Polygon[x1_M_x2 + 1] +=
                          b_obj->W0_DW_Polygon[x1_M_x2 + 6];
                      } else {
                        b_obj->W0_DW_Polygon[x1_M_x2] += b_obj->
                          W0_DW_Polygon[x1_M_x2 + 7];
                        b_obj->W0_DW_Polygon[x1_M_x2 + 1] +=
                          b_obj->W0_DW_Polygon[x1_M_x2 + 5];
                      }
                    }

                    x2 += 9;
                    x1++;
                  }

                  if (x1_M_x2 != y1_M_y2) {
                    for (b_y1 = 0; b_y1 < 9; b_y1++) {
                      b_obj->W0_DW_Polygon[y1_M_y2 + b_y1] =
                        b_obj->W0_DW_Polygon[x1_M_x2 + b_y1];
                    }
                  }

                  y1_M_y2 += 9;
                  numEdge++;
                }

                x1_M_x2 += 9;
              }

              y2 = numEdge;

              /* Sort the boundaries of the polygon according to row values. */
              /* Sort the boundaries of the polygon. */
              isMore = true;
              while (isMore) {
                y1_M_y2 = idxEdgeStartBdy;
                x1_M_x2 = idxEdgeStartBdy + 9;
                isMore = false;
                for (i = 1; i < x1; i++) {
                  if (b_obj->W0_DW_Polygon[y1_M_y2 + 1] > b_obj->
                      W0_DW_Polygon[x1_M_x2 + 1]) {
                    isMore = true;
                    for (b_y1 = 0; b_y1 < 9; b_y1++) {
                      loopEndIdx = b_obj->W0_DW_Polygon[y1_M_y2 + b_y1];
                      b_obj->W0_DW_Polygon[y1_M_y2 + b_y1] =
                        b_obj->W0_DW_Polygon[x1_M_x2 + b_y1];
                      b_obj->W0_DW_Polygon[x1_M_x2 + b_y1] = loopEndIdx;
                    }
                  }

                  y1_M_y2 = x1_M_x2;
                  x1_M_x2 += 9;
                }
              }

              x1 = idxEdgeStartBdy;
              halfLineWidth++;
              b_y1 = 0;
              lastSeparator = -1;
              jj++;
            }
          } else {
            firstRow = 0;
            parallelTo_XorYaxis1 = 3839;
            jj++;
          }

          if (firstRow < 0) {
            firstRow = 0;
          }

          if (parallelTo_XorYaxis1 < firstRow) {
            parallelTo_XorYaxis1 = firstRow - 1;
          }

          if (isForeground && ((parallelTo_XorYaxis1 > 0) && (firstRow < 3839)))
          {
            if (parallelTo_XorYaxis1 > 3839) {
              parallelTo_XorYaxis1 = 3839;
            }

            numEdge = firstRow >> 3;
            i = parallelTo_XorYaxis1 >> 3;
            if (ii > numEdge) {
              ii = numEdge;
            }

            if (idx < i) {
              idx = i;
            }

            if (i > numEdge) {
              b_obj->W1_DW_PixCount[numEdge] = (unsigned char)((unsigned int)
                b_obj->W1_DW_PixCount[numEdge] + (((numEdge + 1) << 3) -
                firstRow));
              b_obj->W1_DW_PixCount[i] = (unsigned char)((unsigned int)
                b_obj->W1_DW_PixCount[i] + ((parallelTo_XorYaxis1 - (i << 3)) +
                1));
              for (row = numEdge + 1; row < i; row++) {
                b_obj->W1_DW_PixCount[row] = (unsigned char)
                  (b_obj->W1_DW_PixCount[row] + 8U);
              }
            } else {
              if (i == numEdge) {
                b_obj->W1_DW_PixCount[numEdge] = (unsigned char)((unsigned int)
                  b_obj->W1_DW_PixCount[numEdge] + ((parallelTo_XorYaxis1 -
                  firstRow) + 1));
              }
            }
          }

          isMore = (jj <= lastValidCol);
          if (((len == colBoundary) || (!isMore)) && (parallelTo_XorYaxis1 >=
               3839)) {
            x1_M_x2 = 0;
            y1_M_y2 = kk * 480 + ii;
            for (loopEndIdx = 0; loopEndIdx < 3; loopEndIdx++) {
              numEdge = y1_M_y2;
              for (row = ii; row <= idx; row++) {
                subPixCount = b_obj->W1_DW_PixCount[row];
                if (subPixCount == 64) {
                  varargin_1[numEdge] = (unsigned char)((varargin_3[x1_M_x2] -
                    varargin_1[numEdge]) + varargin_1[numEdge]);
                } else {
                  varargin_1[numEdge] = (unsigned char)((float)
                    ((varargin_3[x1_M_x2] - varargin_1[numEdge]) * subPixCount) /
                    64.0F + (float)varargin_1[numEdge]);
                }

                numEdge++;
              }

              y1_M_y2 += 307200;
              x1_M_x2++;
            }

            while (ii <= idx) {
              b_obj->W1_DW_PixCount[ii] = 0U;
              ii++;
            }

            kk++;
            colBoundary += 8;
            ii = 480;
            idx = 0;
          }
        }

        /* Move to the next polygon. */
        idxEdgeStartBdy += numSubShape * 9;
        if (idxPtStartBdy >= div_s32_floor(numSubShape, numSubShape) - 1) {
          idxPtStartBdy = 0;
        } else {
          idxPtStartBdy++;
        }

        isMore = (idxEdgeStartBdy < numSubShape * 9);
      }
    }
  }
}

/*
 * File trailer for ShapeInserter.c
 *
 * [EOF]
 */
