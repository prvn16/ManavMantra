/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * ShapeInserter.c
 *
 * Code generation for function 'ShapeInserter'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "ShapeInserter.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo sq_emlrtRSI = { 1,  /* lineNo */
  "ShapeInserter",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+visioncodegen\\ShapeInserter.p"/* pathName */
};

static emlrtRTEInfo fg_emlrtRTEI = { 51,/* lineNo */
  20,                                  /* colNo */
  "output",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\scomp\\output.m"/* pName */
};

/* Function Declarations */
static int32_T div_s32_floor(const emlrtStack *sp, int32_T numerator, int32_T
  denominator);

/* Function Definitions */
static int32_T div_s32_floor(const emlrtStack *sp, int32_T numerator, int32_T
  denominator)
{
  int32_T quotient;
  uint32_T absNumerator;
  uint32_T absDenominator;
  boolean_T quotientNeedsNegation;
  uint32_T tempAbsQuotient;
  if (denominator == 0) {
    if (numerator >= 0) {
      quotient = MAX_int32_T;
    } else {
      quotient = MIN_int32_T;
    }

    emlrtDivisionByZeroErrorR2012b(NULL, sp);
  } else {
    if (numerator < 0) {
      absNumerator = ~(uint32_T)numerator + 1U;
    } else {
      absNumerator = (uint32_T)numerator;
    }

    if (denominator < 0) {
      absDenominator = ~(uint32_T)denominator + 1U;
    } else {
      absDenominator = (uint32_T)denominator;
    }

    quotientNeedsNegation = ((numerator < 0) != (denominator < 0));
    tempAbsQuotient = absNumerator / absDenominator;
    if (quotientNeedsNegation) {
      absNumerator %= absDenominator;
      if (absNumerator > 0U) {
        tempAbsQuotient++;
      }

      quotient = -(int32_T)tempAbsQuotient;
    } else {
      quotient = (int32_T)tempAbsQuotient;
    }
  }

  return quotient;
}

void ShapeInserter_outputImpl(const emlrtStack *sp, visioncodegen_ShapeInserter *
  obj, uint8_T varargin_1[1108698], const int32_T varargin_2_data[], const
  int32_T varargin_2_size[2], const uint8_T varargin_3_data[], const int32_T
  varargin_3_size[2])
{
  vision_ShapeInserter_3 *b_obj;
  int32_T numShape;
  int32_T numFillColor;
  int32_T idxFillColor;
  int32_T idxROI;
  int32_T firstRow;
  int32_T firstCol;
  int32_T lastRow;
  int32_T lastCol;
  int32_T halfLineWidth;
  int32_T ii;
  int32_T line[4];
  boolean_T isInBound;
  boolean_T visited1;
  boolean_T visited2;
  boolean_T done;
  int32_T b_line[4];
  int32_T in;
  int32_T b_idxFillColor;
  int32_T idxPix;
  int32_T idxColor;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &sq_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_obj = &obj->cSFunObject;
  b_st.site = NULL;

  /* System object Outputs function: vision.ShapeInserter */
  numShape = varargin_2_size[0];
  numFillColor = varargin_3_size[0];
  if (!((varargin_2_size[0] == 1) || (varargin_3_size[0] == 1) ||
        (varargin_2_size[0] == varargin_3_size[0]))) {
    emlrtErrorWithMessageIdR2018a(&b_st, &fg_emlrtRTEI,
      "vision:system:vipDrawNotVecOrMat", "vision:system:vipDrawNotVecOrMat", 16,
      4, 1, "I", 12, 3, 12, varargin_2_size[0], 4, 11, "Color input", 12, 3, 12,
      varargin_2_size[0], 12, 3);
  }

  /* Copy the image from input to output. */
  if ((varargin_2_size[0] > 0) && (varargin_3_size[0] > 0)) {
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
              if (b_line[0U] > 513) {
                halfLineWidth = 8;
              }
            }

            if (b_line[2U] < 0) {
              in = 4;
            } else {
              if (b_line[2U] > 513) {
                in = 8;
              }
            }

            if (b_line[1U] < 0) {
              halfLineWidth |= 1U;
            } else {
              if (b_line[1U] > 718) {
                halfLineWidth |= 2U;
              }
            }

            if (b_line[3U] < 0) {
              in |= 1U;
            } else {
              if (b_line[3U] > 718) {
                in |= 2U;
              }
            }

            if (!(((uint32_T)halfLineWidth | in) != 0U)) {
              /* Line falls completely within bounds. */
              done = true;
              isInBound = true;
            } else if (((uint32_T)halfLineWidth & in) != 0U) {
              /* Line falls completely out of bounds. */
              done = true;
              isInBound = false;
            } else if ((uint32_T)halfLineWidth != 0U) {
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 0;
                visited1 = true;
              } else if ((halfLineWidth & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (513 - b_line[0]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 513;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[1U] = 0;
                visited1 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (718 - b_line[1]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[1U] = 718;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 0;
                visited2 = true;
              } else if ((in & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (513 - b_line[2]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 513;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[3U] = 0;
                visited2 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (718 - b_line[3]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[3U] = 718;
                visited2 = true;
              }
            }
          }

          if (isInBound) {
            halfLineWidth = b_line[1] * 514 + b_line[0];
            for (in = b_line[1]; in <= b_line[3U]; in++) {
              b_idxFillColor = idxFillColor;
              idxPix = halfLineWidth;
              for (idxColor = 0; idxColor < 3; idxColor++) {
                varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
                idxPix += 369566;
                b_idxFillColor += numFillColor;
              }

              halfLineWidth += 514;
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
              if (b_line[0U] > 513) {
                halfLineWidth = 8;
              }
            }

            if (b_line[2U] < 0) {
              in = 4;
            } else {
              if (b_line[2U] > 513) {
                in = 8;
              }
            }

            if (b_line[1U] < 0) {
              halfLineWidth |= 1U;
            } else {
              if (b_line[1U] > 718) {
                halfLineWidth |= 2U;
              }
            }

            if (b_line[3U] < 0) {
              in |= 1U;
            } else {
              if (b_line[3U] > 718) {
                in |= 2U;
              }
            }

            if (!(((uint32_T)halfLineWidth | in) != 0U)) {
              /* Line falls completely within bounds. */
              done = true;
              isInBound = true;
            } else if (((uint32_T)halfLineWidth & in) != 0U) {
              /* Line falls completely out of bounds. */
              done = true;
              isInBound = false;
            } else if ((uint32_T)halfLineWidth != 0U) {
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 0;
                visited1 = true;
              } else if ((halfLineWidth & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (513 - b_line[0]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 513;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[1U] = 0;
                visited1 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (718 - b_line[1]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[1U] = 718;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 0;
                visited2 = true;
              } else if ((in & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (513 - b_line[2]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 513;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[3U] = 0;
                visited2 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (718 - b_line[3]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[3U] = 718;
                visited2 = true;
              }
            }
          }

          if (isInBound) {
            halfLineWidth = b_line[1] * 514 + b_line[0];
            for (in = b_line[0]; in <= b_line[2U]; in++) {
              b_idxFillColor = idxFillColor;
              idxPix = halfLineWidth;
              for (idxColor = 0; idxColor < 3; idxColor++) {
                varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
                idxPix += 369566;
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
              if (b_line[0U] > 513) {
                halfLineWidth = 8;
              }
            }

            if (b_line[2U] < 0) {
              in = 4;
            } else {
              if (b_line[2U] > 513) {
                in = 8;
              }
            }

            if (b_line[1U] < 0) {
              halfLineWidth |= 1U;
            } else {
              if (b_line[1U] > 718) {
                halfLineWidth |= 2U;
              }
            }

            if (b_line[3U] < 0) {
              in |= 1U;
            } else {
              if (b_line[3U] > 718) {
                in |= 2U;
              }
            }

            if (!(((uint32_T)halfLineWidth | in) != 0U)) {
              /* Line falls completely within bounds. */
              done = true;
              isInBound = true;
            } else if (((uint32_T)halfLineWidth & in) != 0U) {
              /* Line falls completely out of bounds. */
              done = true;
              isInBound = false;
            } else if ((uint32_T)halfLineWidth != 0U) {
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 0;
                visited1 = true;
              } else if ((halfLineWidth & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (513 - b_line[0]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 513;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[1U] = 0;
                visited1 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (718 - b_line[1]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[1U] = 718;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 0;
                visited2 = true;
              } else if ((in & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (513 - b_line[2]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 513;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[3U] = 0;
                visited2 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (718 - b_line[3]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[3U] = 718;
                visited2 = true;
              }
            }
          }

          if (isInBound) {
            halfLineWidth = b_line[1] * 514 + b_line[0];
            for (in = b_line[1]; in <= b_line[3U]; in++) {
              b_idxFillColor = idxFillColor;
              idxPix = halfLineWidth;
              for (idxColor = 0; idxColor < 3; idxColor++) {
                varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
                idxPix += 369566;
                b_idxFillColor += numFillColor;
              }

              halfLineWidth += 514;
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
              if (b_line[0U] > 513) {
                halfLineWidth = 8;
              }
            }

            if (b_line[2U] < 0) {
              in = 4;
            } else {
              if (b_line[2U] > 513) {
                in = 8;
              }
            }

            if (b_line[1U] < 0) {
              halfLineWidth |= 1U;
            } else {
              if (b_line[1U] > 718) {
                halfLineWidth |= 2U;
              }
            }

            if (b_line[3U] < 0) {
              in |= 1U;
            } else {
              if (b_line[3U] > 718) {
                in |= 2U;
              }
            }

            if (!(((uint32_T)halfLineWidth | in) != 0U)) {
              /* Line falls completely within bounds. */
              done = true;
              isInBound = true;
            } else if (((uint32_T)halfLineWidth & in) != 0U) {
              /* Line falls completely out of bounds. */
              done = true;
              isInBound = false;
            } else if ((uint32_T)halfLineWidth != 0U) {
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 0;
                visited1 = true;
              } else if ((halfLineWidth & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (513 - b_line[0]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[1U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[0U] = 513;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[1U] = 0;
                visited1 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (718 - b_line[1]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[0U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[1U] = 718;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 0;
                visited2 = true;
              } else if ((in & 8U) != 0U) {
                /* Violated RMax. */
                halfLineWidth = (513 - b_line[2]) * idxPix;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (b_idxFillColor >= 0)) ||
                           ((halfLineWidth < 0) && (b_idxFillColor < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] += (div_s32_floor(&c_st, halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[3U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    b_idxFillColor) + 1) >> 1;
                }

                b_line[2U] = 513;
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
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[3U] = 0;
                visited2 = true;
              } else {
                /* Violated CMax. */
                halfLineWidth = (718 - b_line[3]) * b_idxFillColor;
                if ((halfLineWidth > 1073741824) || (halfLineWidth < -1073741824))
                {
                  /* Check for Inf or Nan. */
                  done = true;
                  isInBound = false;
                } else if (((halfLineWidth >= 0) && (idxPix >= 0)) ||
                           ((halfLineWidth < 0) && (idxPix < 0))) {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] += (div_s32_floor(&c_st, halfLineWidth << 1, idxPix)
                                 + 1) >> 1;
                } else {
                  c_st.site = &sq_emlrtRSI;
                  b_line[2U] -= (div_s32_floor(&c_st, -halfLineWidth << 1,
                    idxPix) + 1) >> 1;
                }

                b_line[3U] = 718;
                visited2 = true;
              }
            }
          }

          if (isInBound) {
            halfLineWidth = b_line[1] * 514 + b_line[0];
            for (in = b_line[0]; in <= b_line[2U]; in++) {
              b_idxFillColor = idxFillColor;
              idxPix = halfLineWidth;
              for (idxColor = 0; idxColor < 3; idxColor++) {
                varargin_1[idxPix] = varargin_3_data[b_idxFillColor];
                idxPix += 369566;
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

/* End of code generation (ShapeInserter.c) */
