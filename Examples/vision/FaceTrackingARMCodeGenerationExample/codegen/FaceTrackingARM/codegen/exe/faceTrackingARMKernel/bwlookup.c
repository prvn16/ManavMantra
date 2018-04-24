/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: bwlookup.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "bwlookup.h"

/* Function Definitions */

/*
 * Arguments    : const boolean_T bwin_data[]
 *                const int bwin_size[2]
 *                boolean_T B_data[]
 *                int B_size[2]
 * Return Type  : void
 */
void bwlookup(const boolean_T bwin_data[], const int bwin_size[2], boolean_T
              B_data[], int B_size[2])
{
  int rowInd;
  unsigned char inDims[2];
  static const boolean_T lut[512] = { false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    true, true, true, true, false, true, true, true, true, true, true, false,
    false, true, true, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, true, false, true,
    true, true, false, true, true, false, false, true, true, false, false, true,
    true, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, true, false, false, false, false,
    false, false, false, true, true, true, true, false, false, true, true, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, true, false, false, true, true, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false,
    true, true, true, true, false, false, true, true, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, true, false, true, true, true, false, true, true, true, true, false,
    false, true, true, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, true,
    false, false, false, false, false, false, false, true, true, true, true,
    false, false, true, true, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, true, false,
    true, true, true, false, true, true, true, true, false, false, true, true,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, true, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, true, false, true, true, true,
    false, true, true, false, false, true, true, false, false, true, true, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, true, true, false, false, true, true, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, true, false, false, false, false, false, false, false, true,
    true, true, true, false, false, true, true, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, true, false, true, true, true, false, true, true, true, true, false,
    false, true, true, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, true,
    false, false, false, false, false, false, false, true, true, true, true,
    false, false, true, true, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, true, false,
    true, true, true, false, true, true, true, true, false, false, true, true,
    false, false };

  int colInd;
  for (rowInd = 0; rowInd < 2; rowInd++) {
    inDims[rowInd] = (unsigned char)bwin_size[rowInd];
  }

  B_size[0] = inDims[0];
  B_size[1] = inDims[1];
  for (rowInd = 0; rowInd < 2; rowInd++) {
    inDims[rowInd] = (unsigned char)bwin_size[rowInd];
  }

  /*  Process a 3x3 neighborhood centered around the pixel being processed. */
  /*  process the first column first row element */
  B_data[0] = lut[(((bwin_data[0] << 4) + (bwin_data[1] << 5)) +
                   (bwin_data[bwin_size[0]] << 7)) + (bwin_data[1 + bwin_size[0]]
    << 8)];

  /*  process the first column interior elements */
  for (rowInd = 0; rowInd <= inDims[0] - 3; rowInd++) {
    B_data[rowInd + 1] = lut[(((((bwin_data[rowInd] << 3) + (bwin_data[rowInd +
      1] << 4)) + (bwin_data[rowInd + 2] << 5)) + (bwin_data[rowInd + bwin_size
      [0]] << 6)) + (bwin_data[(rowInd + bwin_size[0]) + 1] << 7)) + (bwin_data
      [(rowInd + bwin_size[0]) + 2] << 8)];
  }

  /*  process the first column last row element */
  B_data[inDims[0] - 1] = lut[(((bwin_data[inDims[0] - 2] << 3) +
    (bwin_data[inDims[0] - 1] << 4)) + (bwin_data[(inDims[0] + bwin_size[0]) - 2]
    << 6)) + (bwin_data[(inDims[0] + bwin_size[0]) - 1] << 7)];
  for (colInd = 0; colInd <= inDims[1] - 3; colInd++) {
    /*  process second column to last but one column------------------------- */
    /*  process second to last but one row for this column */
    for (rowInd = 0; rowInd <= inDims[0] - 3; rowInd++) {
      B_data[(rowInd + B_size[0] * (colInd + 1)) + 1] = lut
        [(((((((bwin_data[rowInd + bwin_size[0] * colInd] + (bwin_data[(rowInd +
                  bwin_size[0] * colInd) + 1] << 1)) + (bwin_data[(rowInd +
                 bwin_size[0] * colInd) + 2] << 2)) + (bwin_data[rowInd +
               bwin_size[0] * (colInd + 1)] << 3)) + (bwin_data[(rowInd +
               bwin_size[0] * (colInd + 1)) + 1] << 4)) + (bwin_data[(rowInd +
              bwin_size[0] * (colInd + 1)) + 2] << 5)) + (bwin_data[rowInd +
            bwin_size[0] * (colInd + 2)] << 6)) + (bwin_data[(rowInd +
            bwin_size[0] * (colInd + 2)) + 1] << 7)) + (bwin_data[(rowInd +
        bwin_size[0] * (colInd + 2)) + 2] << 8)];
    }
  }

  for (colInd = 1; colInd - 1 <= inDims[1] - 3; colInd++) {
    /*  process first row element */
    B_data[B_size[0] * colInd] = lut[(((((bwin_data[bwin_size[0] * (colInd - 1)]
      << 1) + (bwin_data[1 + bwin_size[0] * (colInd - 1)] << 2)) +
      (bwin_data[bwin_size[0] * colInd] << 4)) + (bwin_data[1 + bwin_size[0] *
      colInd] << 5)) + (bwin_data[bwin_size[0] * (colInd + 1)] << 7)) +
      (bwin_data[1 + bwin_size[0] * (colInd + 1)] << 8)];

    /*  process the last row element */
    B_data[(inDims[0] + B_size[0] * colInd) - 1] = lut[((((bwin_data[(inDims[0]
      + bwin_size[0] * (colInd - 1)) - 2] + (bwin_data[(inDims[0] + bwin_size[0]
      * (colInd - 1)) - 1] << 1)) + (bwin_data[(inDims[0] + bwin_size[0] *
      colInd) - 2] << 3)) + (bwin_data[(inDims[0] + bwin_size[0] * colInd) - 1] <<
      4)) + (bwin_data[(inDims[0] + bwin_size[0] * (colInd + 1)) - 2] << 6)) +
      (bwin_data[(inDims[0] + bwin_size[0] * (colInd + 1)) - 1] << 7)];
  }

  /*  end process second column to last but one column--------------------- */
  /*  process last column first row element */
  colInd = inDims[1] - 1;
  B_data[B_size[0] * (inDims[1] - 1)] = lut[(((bwin_data[bwin_size[0] * (inDims
    [1] - 2)] << 1) + (bwin_data[1 + bwin_size[0] * (inDims[1] - 2)] << 2)) +
    (bwin_data[bwin_size[0] * (inDims[1] - 1)] << 4)) + (bwin_data[1 +
    bwin_size[0] * (inDims[1] - 1)] << 5)];

  /*  process last column second to last but one element */
  for (rowInd = 0; rowInd <= inDims[0] - 3; rowInd++) {
    B_data[(rowInd + B_size[0] * colInd) + 1] = lut[((((bwin_data[rowInd +
      bwin_size[0] * (colInd - 1)] + (bwin_data[(rowInd + bwin_size[0] * (colInd
      - 1)) + 1] << 1)) + (bwin_data[(rowInd + bwin_size[0] * (colInd - 1)) + 2]
      << 2)) + (bwin_data[rowInd + bwin_size[0] * colInd] << 3)) + (bwin_data
      [(rowInd + bwin_size[0] * colInd) + 1] << 4)) + (bwin_data[(rowInd +
      bwin_size[0] * colInd) + 2] << 5)];
  }

  /*  process the last column last row element */
  B_data[(inDims[0] + B_size[0] * (inDims[1] - 1)) - 1] = lut[((bwin_data
    [(inDims[0] + bwin_size[0] * (inDims[1] - 2)) - 2] + (bwin_data[(inDims[0] +
    bwin_size[0] * (inDims[1] - 2)) - 1] << 1)) + (bwin_data[(inDims[0] +
    bwin_size[0] * (inDims[1] - 1)) - 2] << 3)) + (bwin_data[(inDims[0] +
    bwin_size[0] * (inDims[1] - 1)) - 1] << 4)];
}

/*
 * File trailer for bwlookup.c
 *
 * [EOF]
 */
