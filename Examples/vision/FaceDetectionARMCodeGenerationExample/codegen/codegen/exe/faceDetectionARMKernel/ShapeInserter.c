/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: ShapeInserter.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceDetectionARMKernel.h"
#include "ShapeInserter.h"

/* Function Declarations */
static int div_s32_floor(int numerator, int denominator);

/* Function Definitions */

/*
 * Arguments    : int numerator
 *                int denominator
 * Return Type  : int
 */
static int div_s32_floor(int numerator, int denominator)
{
  int quotient;
  unsigned int absNumerator;
  unsigned int absDenominator;
  boolean_T quotientNeedsNegation;
  unsigned int tempAbsQuotient;
  if (denominator == 0) {
    if (numerator >= 0) {
      quotient = MAX_int32_T;
    } else {
      quotient = MIN_int32_T;
    }
  } else {
    if (numerator < 0) {
      absNumerator = ~(unsigned int)numerator + 1U;
    } else {
      absNumerator = (unsigned int)numerator;
    }

    if (denominator < 0) {
      absDenominator = ~(unsigned int)denominator + 1U;
    } else {
      absDenominator = (unsigned int)denominator;
    }

    quotientNeedsNegation = ((numerator < 0) != (denominator < 0));
    tempAbsQuotient = absNumerator / absDenominator;
    if (quotientNeedsNegation) {
      absNumerator %= absDenominator;
      if (absNumerator > 0U) {
        tempAbsQuotient++;
      }

      quotient = -(int)tempAbsQuotient;
    } else {
      quotient = (int)tempAbsQuotient;
    }
  }

  return quotient;
}

/*
 * Arguments    : visioncodegen_ShapeInserter *obj
 *                unsigned char varargin_1[921600]
 *                const int varargin_2_data[]
 *                const int varargin_2_size[2]
 *                const unsigned char varargin_3_data[]
 *                const int varargin_3_size[2]
 * Return Type  : void
 */
void ShapeInserter_outputImpl(visioncodegen_ShapeInserter *obj, unsigned char
  varargin_1[921600], const int varargin_2_data[], const int varargin_2_size[2],
  const unsigned char varargin_3_data[], const int varargin_3_size[2])
{
  vision_ShapeInserter_0 *b_obj;
  int numShape;
  int numFillColor;
  int idxFillColor;
  int idxROI;
  int firstRow;
  int firstCol;
  int lastRow;
  int lastCol;
  int halfLineWidth;
  int ii;
  int line[4];
  boolean_T isInBound;
  boolean_T visited1;
  boolean_T visited2;
  boolean_T done;
  int b_line[4];
  int in;
  int b_idxFillColor;
  int idxPix;
  int idxColor;
  b_obj = &obj->cSFunObject;

  /* System object Outputs function: vision.ShapeInserter */
  numShape = varargin_2_size[0];
  numFillColor = varargin_3_size[0];

  /* Copy the image from input to output. */
  if (((varargin_2_size[0] == 1) || (varargin_3_size[0] == 1) ||
       (varargin_2_size[0] == varargin_3_size[0])) && (varargin_2_size[0] > 0) &&
      (varargin_3_size[0] > 0)) {
    /* Update view port. */
    /* Draw all rectangles. */
    idxFillColor = 0;
    for (idxROI = 0; idxROI < numShape; idxROI++) {
      firstRow = varargin_2_data[idxROI + numShape] - 1;
      firstCol = varargin_2_data[idxROI] - 1;
      lastRow = (varargin_2_data[idxROI + numShape] + varargin_2_data[idxROI + 3
                 * numShape]) - 2;
      lastCol = (varargin_2_data[idxROI] + varargin_2_data[idxROI + (numShape <<
                  1)]) - 2;
      if (b_obj->P0_RTP_LINEWIDTH > 1) {
        halfLineWidth = b_obj->P0_RTP_LINEWIDTH >> 1;
        firstRow = (varargin_2_data[idxROI + numShape] - halfLineWidth) - 1;
        lastRow += halfLineWidth;
        firstCol = (varargin_2_data[idxROI] - halfLineWidth) - 1;
        lastCol += halfLineWidth;
      }

      if ((firstRow <= lastRow) && (firstCol <= lastCol)) {
        for (ii = 0; ii < b_obj->P0_RTP_LINEWIDTH; ii++) {
          line[0U] = firstRow + ii;
          line[1U] = firstCol;
          line[2U] = firstRow + ii;
          line[3U] = lastCol;
          isInBound = false;

          /* Find the visible portion of a line. */
          visited1 = false;
          visited2 = false;
          done = false;
          for (halfLineWidth = 0; halfLineWidth < 4; halfLineWidth++) {
            b_line[halfLineWidth] = line[halfLineWidth];
          }

          while (!done) {
            halfLineWidth = 0;
            in = 0;

            /* Determine viewport violations. */
            if (b_line[0U] < 0) {
              halfLineWidth = 4;
            } else {
              if (b_line[0U] > 479) {
                halfLineWidth = 8;
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
              halfLineWidth |= 1U;
            } else {
              if (b_line[1U] > 639) {
                halfLineWidth |= 2U;
              }
            }

            if (b_line[3U] < 0) {
              in |= 1U;
            } else {
              if (b_line[3U] > 639) {
                in |= 2U;
              }
            }

            if (!(((unsigned int)halfLineWidth | in) != 0U)) {
              /* Line falls completely within bounds. */
              done = true;
              isInBound = true;
            } else if (((unsigned int)halfLineWidth & in) != 0U) {
              /* Line falls completely out of bounds. */
              done = true;
              isInBound = false;
            } else if ((unsigned int)halfLineWidth != 0U) {
              /* Clip 1st point; if it's in-bounds, clip 2nd point. */
              if (visited1) {
                b_line[0U] = line[0];
                b_line[1U] = firstCol;
              }

              b_idxFillColor = b_line[2] - b_line[0];
              idxPix = b_line[3] - b_line[1];
              if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824)
                  || ((idxPix > 1073741824) || (idxPix < -1073741824))) {
                /* Possible Inf or Nan. */
                done = true;
                isInBound = false;
                visited1 = true;
              } else if ((halfLineWidth & 4U) != 0U) {
                /* Violated RMin. */
                halfLineWidth = -b_line[0] * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[1U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[1U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 0;
                visited1 = true;
              } else if ((halfLineWidth & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (479 - b_line[0]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[1U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[1U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 479;
                visited1 = true;
              } else if ((halfLineWidth & 1U) != 0U) {
                /* Violated CMin. */
                halfLineWidth = -b_line[1] * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[0U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[0U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[1U] = 0;
                visited1 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (639 - b_line[1]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[0U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[0U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[1U] = 639;
                visited1 = true;
              }
            } else {
              /* Clip the 2nd point. */
              if (visited2) {
                b_line[2U] = line[2];
                b_line[3U] = lastCol;
              }

              b_idxFillColor = b_line[2] - b_line[0];
              idxPix = b_line[3] - b_line[1];
              if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824)
                  || ((idxPix > 1073741824) || (idxPix < -1073741824))) {
                /* Possible Inf or Nan. */
                done = true;
                isInBound = false;
                visited2 = true;
              } else if ((in & 4U) != 0U) {
                /* Violated RMin. */
                halfLineWidth = -b_line[2] * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[3U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[3U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 0;
                visited2 = true;
              } else if ((in & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (479 - b_line[2]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[3U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[3U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 479;
                visited2 = true;
              } else if ((in & 1U) != 0U) {
                /* Violated CMin. */
                halfLineWidth = -b_line[3] * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[2U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[2U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[3U] = 0;
                visited2 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (639 - b_line[3]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[2U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[2U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[3U] = 639;
                visited2 = true;
              }
            }
          }

          if (isInBound) {
            halfLineWidth = b_line[1] * 480 + b_line[0];
            for (in = b_line[1]; in <= b_line[3U]; in++) {
              b_idxFillColor = idxFillColor;
              idxPix = halfLineWidth;
              for (idxColor = 0; idxColor < 3; idxColor++) {
                varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
                idxPix += 307200;
                b_idxFillColor += numFillColor;
              }

              halfLineWidth += 480;
            }
          }

          line[0U] = firstRow;
          line[1U] = firstCol + ii;
          line[2U] = lastRow;
          line[3U] = firstCol + ii;
          isInBound = false;

          /* Find the visible portion of a line. */
          visited1 = false;
          visited2 = false;
          done = false;
          for (halfLineWidth = 0; halfLineWidth < 4; halfLineWidth++) {
            b_line[halfLineWidth] = line[halfLineWidth];
          }

          while (!done) {
            halfLineWidth = 0;
            in = 0;

            /* Determine viewport violations. */
            if (b_line[0U] < 0) {
              halfLineWidth = 4;
            } else {
              if (b_line[0U] > 479) {
                halfLineWidth = 8;
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
              halfLineWidth |= 1U;
            } else {
              if (b_line[1U] > 639) {
                halfLineWidth |= 2U;
              }
            }

            if (b_line[3U] < 0) {
              in |= 1U;
            } else {
              if (b_line[3U] > 639) {
                in |= 2U;
              }
            }

            if (!(((unsigned int)halfLineWidth | in) != 0U)) {
              /* Line falls completely within bounds. */
              done = true;
              isInBound = true;
            } else if (((unsigned int)halfLineWidth & in) != 0U) {
              /* Line falls completely out of bounds. */
              done = true;
              isInBound = false;
            } else if ((unsigned int)halfLineWidth != 0U) {
              /* Clip 1st point; if it's in-bounds, clip 2nd point. */
              if (visited1) {
                b_line[0U] = firstRow;
                b_line[1U] = line[1];
              }

              b_idxFillColor = b_line[2] - b_line[0];
              idxPix = b_line[3] - b_line[1];
              if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824)
                  || ((idxPix > 1073741824) || (idxPix < -1073741824))) {
                /* Possible Inf or Nan. */
                done = true;
                isInBound = false;
                visited1 = true;
              } else if ((halfLineWidth & 4U) != 0U) {
                /* Violated RMin. */
                halfLineWidth = -b_line[0] * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[1U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[1U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 0;
                visited1 = true;
              } else if ((halfLineWidth & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (479 - b_line[0]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[1U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[1U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 479;
                visited1 = true;
              } else if ((halfLineWidth & 1U) != 0U) {
                /* Violated CMin. */
                halfLineWidth = -b_line[1] * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[0U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[0U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[1U] = 0;
                visited1 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (639 - b_line[1]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[0U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[0U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[1U] = 639;
                visited1 = true;
              }
            } else {
              /* Clip the 2nd point. */
              if (visited2) {
                b_line[2U] = lastRow;
                b_line[3U] = line[3];
              }

              b_idxFillColor = b_line[2] - b_line[0];
              idxPix = b_line[3] - b_line[1];
              if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824)
                  || ((idxPix > 1073741824) || (idxPix < -1073741824))) {
                /* Possible Inf or Nan. */
                done = true;
                isInBound = false;
                visited2 = true;
              } else if ((in & 4U) != 0U) {
                /* Violated RMin. */
                halfLineWidth = -b_line[2] * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[3U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[3U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 0;
                visited2 = true;
              } else if ((in & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (479 - b_line[2]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[3U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[3U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 479;
                visited2 = true;
              } else if ((in & 1U) != 0U) {
                /* Violated CMin. */
                halfLineWidth = -b_line[3] * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[2U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[2U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[3U] = 0;
                visited2 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (639 - b_line[3]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[2U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[2U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[3U] = 639;
                visited2 = true;
              }
            }
          }

          if (isInBound) {
            halfLineWidth = b_line[1] * 480 + b_line[0];
            for (in = b_line[0]; in <= b_line[2U]; in++) {
              b_idxFillColor = idxFillColor;
              idxPix = halfLineWidth;
              for (idxColor = 0; idxColor < 3; idxColor++) {
                varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
                idxPix += 307200;
                b_idxFillColor += numFillColor;
              }

              halfLineWidth++;
            }
          }

          line[0U] = lastRow - ii;
          line[1U] = firstCol;
          line[2U] = lastRow - ii;
          line[3U] = lastCol;
          isInBound = false;

          /* Find the visible portion of a line. */
          visited1 = false;
          visited2 = false;
          done = false;
          for (halfLineWidth = 0; halfLineWidth < 4; halfLineWidth++) {
            b_line[halfLineWidth] = line[halfLineWidth];
          }

          while (!done) {
            halfLineWidth = 0;
            in = 0;

            /* Determine viewport violations. */
            if (b_line[0U] < 0) {
              halfLineWidth = 4;
            } else {
              if (b_line[0U] > 479) {
                halfLineWidth = 8;
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
              halfLineWidth |= 1U;
            } else {
              if (b_line[1U] > 639) {
                halfLineWidth |= 2U;
              }
            }

            if (b_line[3U] < 0) {
              in |= 1U;
            } else {
              if (b_line[3U] > 639) {
                in |= 2U;
              }
            }

            if (!(((unsigned int)halfLineWidth | in) != 0U)) {
              /* Line falls completely within bounds. */
              done = true;
              isInBound = true;
            } else if (((unsigned int)halfLineWidth & in) != 0U) {
              /* Line falls completely out of bounds. */
              done = true;
              isInBound = false;
            } else if ((unsigned int)halfLineWidth != 0U) {
              /* Clip 1st point; if it's in-bounds, clip 2nd point. */
              if (visited1) {
                b_line[0U] = line[0];
                b_line[1U] = firstCol;
              }

              b_idxFillColor = b_line[2] - b_line[0];
              idxPix = b_line[3] - b_line[1];
              if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824)
                  || ((idxPix > 1073741824) || (idxPix < -1073741824))) {
                /* Possible Inf or Nan. */
                done = true;
                isInBound = false;
                visited1 = true;
              } else if ((halfLineWidth & 4U) != 0U) {
                /* Violated RMin. */
                halfLineWidth = -b_line[0] * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[1U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[1U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 0;
                visited1 = true;
              } else if ((halfLineWidth & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (479 - b_line[0]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[1U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[1U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 479;
                visited1 = true;
              } else if ((halfLineWidth & 1U) != 0U) {
                /* Violated CMin. */
                halfLineWidth = -b_line[1] * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[0U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[0U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[1U] = 0;
                visited1 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (639 - b_line[1]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[0U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[0U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[1U] = 639;
                visited1 = true;
              }
            } else {
              /* Clip the 2nd point. */
              if (visited2) {
                b_line[2U] = line[2];
                b_line[3U] = lastCol;
              }

              b_idxFillColor = b_line[2] - b_line[0];
              idxPix = b_line[3] - b_line[1];
              if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824)
                  || ((idxPix > 1073741824) || (idxPix < -1073741824))) {
                /* Possible Inf or Nan. */
                done = true;
                isInBound = false;
                visited2 = true;
              } else if ((in & 4U) != 0U) {
                /* Violated RMin. */
                halfLineWidth = -b_line[2] * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[3U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[3U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 0;
                visited2 = true;
              } else if ((in & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (479 - b_line[2]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[3U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[3U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 479;
                visited2 = true;
              } else if ((in & 1U) != 0U) {
                /* Violated CMin. */
                halfLineWidth = -b_line[3] * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[2U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[2U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[3U] = 0;
                visited2 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (639 - b_line[3]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[2U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[2U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[3U] = 639;
                visited2 = true;
              }
            }
          }

          if (isInBound) {
            halfLineWidth = b_line[1] * 480 + b_line[0];
            for (in = b_line[1]; in <= b_line[3U]; in++) {
              b_idxFillColor = idxFillColor;
              idxPix = halfLineWidth;
              for (idxColor = 0; idxColor < 3; idxColor++) {
                varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
                idxPix += 307200;
                b_idxFillColor += numFillColor;
              }

              halfLineWidth += 480;
            }
          }

          line[0U] = firstRow;
          line[1U] = lastCol - ii;
          line[2U] = lastRow;
          line[3U] = lastCol - ii;
          isInBound = false;

          /* Find the visible portion of a line. */
          visited1 = false;
          visited2 = false;
          done = false;
          for (halfLineWidth = 0; halfLineWidth < 4; halfLineWidth++) {
            b_line[halfLineWidth] = line[halfLineWidth];
          }

          while (!done) {
            halfLineWidth = 0;
            in = 0;

            /* Determine viewport violations. */
            if (b_line[0U] < 0) {
              halfLineWidth = 4;
            } else {
              if (b_line[0U] > 479) {
                halfLineWidth = 8;
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
              halfLineWidth |= 1U;
            } else {
              if (b_line[1U] > 639) {
                halfLineWidth |= 2U;
              }
            }

            if (b_line[3U] < 0) {
              in |= 1U;
            } else {
              if (b_line[3U] > 639) {
                in |= 2U;
              }
            }

            if (!(((unsigned int)halfLineWidth | in) != 0U)) {
              /* Line falls completely within bounds. */
              done = true;
              isInBound = true;
            } else if (((unsigned int)halfLineWidth & in) != 0U) {
              /* Line falls completely out of bounds. */
              done = true;
              isInBound = false;
            } else if ((unsigned int)halfLineWidth != 0U) {
              /* Clip 1st point; if it's in-bounds, clip 2nd point. */
              if (visited1) {
                b_line[0U] = firstRow;
                b_line[1U] = line[1];
              }

              b_idxFillColor = b_line[2] - b_line[0];
              idxPix = b_line[3] - b_line[1];
              if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824)
                  || ((idxPix > 1073741824) || (idxPix < -1073741824))) {
                /* Possible Inf or Nan. */
                done = true;
                isInBound = false;
                visited1 = true;
              } else if ((halfLineWidth & 4U) != 0U) {
                /* Violated RMin. */
                halfLineWidth = -b_line[0] * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[1U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[1U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 0;
                visited1 = true;
              } else if ((halfLineWidth & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (479 - b_line[0]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[1U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[1U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 479;
                visited1 = true;
              } else if ((halfLineWidth & 1U) != 0U) {
                /* Violated CMin. */
                halfLineWidth = -b_line[1] * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[0U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[0U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[1U] = 0;
                visited1 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (639 - b_line[1]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[0U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[0U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[1U] = 639;
                visited1 = true;
              }
            } else {
              /* Clip the 2nd point. */
              if (visited2) {
                b_line[2U] = lastRow;
                b_line[3U] = line[3];
              }

              b_idxFillColor = b_line[2] - b_line[0];
              idxPix = b_line[3] - b_line[1];
              if ((b_idxFillColor > 1073741824) || (b_idxFillColor < -1073741824)
                  || ((idxPix > 1073741824) || (idxPix < -1073741824))) {
                /* Possible Inf or Nan. */
                done = true;
                isInBound = false;
                visited2 = true;
              } else if ((in & 4U) != 0U) {
                /* Violated RMin. */
                halfLineWidth = -b_line[2] * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[3U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[3U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 0;
                visited2 = true;
              } else if ((in & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (479 - b_line[2]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  b_line[3U] += (div_s32_floor(halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  b_line[3U] -= (div_s32_floor(-halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 479;
                visited2 = true;
              } else if ((in & 1U) != 0U) {
                /* Violated CMin. */
                halfLineWidth = -b_line[3] * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[2U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[2U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[3U] = 0;
                visited2 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (639 - b_line[3]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  b_line[2U] += (div_s32_floor(halfLineWidth << 1, idxPix) + 1) >>
                    1;
                } else {
                  b_line[2U] -= (div_s32_floor(-halfLineWidth << 1, idxPix) + 1)
                    >> 1;
                }

                b_line[3U] = 639;
                visited2 = true;
              }
            }
          }

          if (isInBound) {
            halfLineWidth = b_line[1] * 480 + b_line[0];
            for (in = b_line[0]; in <= b_line[2U]; in++) {
              b_idxFillColor = idxFillColor;
              idxPix = halfLineWidth;
              for (idxColor = 0; idxColor < 3; idxColor++) {
                varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
                idxPix += 307200;
                b_idxFillColor += numFillColor;
              }

              halfLineWidth++;
            }
          }
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
 * File trailer for ShapeInserter.c
 *
 * [EOF]
 */
