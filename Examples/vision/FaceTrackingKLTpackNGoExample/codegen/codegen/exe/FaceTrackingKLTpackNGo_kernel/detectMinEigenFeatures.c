/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: detectMinEigenFeatures.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "detectMinEigenFeatures.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "cornerPoints_cg.h"
#include "excludePointsOutsideROI.h"
#include "harrisMinEigen.h"
#include "findPeaks.h"
#include "cropImage.h"
#include "expandROI.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const float I[307200]
 *                const float varargin_2_data[]
 *                const int varargin_2_size[2]
 *                emxArray_real32_T *pts_pLocation
 * Return Type  : void
 */
void detectMinEigenFeatures(const float I[307200], const float varargin_2_data[],
  const int varargin_2_size[2], emxArray_real32_T *pts_pLocation)
{
  emxArray_real32_T *Ic;
  emxArray_real32_T *metricMatrix;
  emxArray_real32_T *locations;
  emxArray_real32_T *metricValues;
  emxArray_real32_T *b_locations;
  emxArray_real32_T *b_metricValues;
  vision_internal_cornerPoints_cg expl_temp;
  float b_expl_temp;
  double c_expl_temp;
  boolean_T d_expl_temp;
  int params_ROI_data[36];
  int params_ROI_size[2];
  int expandedROI_data[36];
  int expandedROI_size[2];
  int i1;
  int loop_ub;
  emxInit_real32_T(&Ic, 2);
  emxInit_real32_T(&metricMatrix, 2);
  emxInit_real32_T(&locations, 2);
  emxInit_real32_T1(&metricValues, 1);
  emxInit_real32_T(&b_locations, 2);
  emxInit_real32_T1(&b_metricValues, 1);
  c_emxInitStruct_vision_internal(&expl_temp);
  parseInputs(varargin_2_data, varargin_2_size, &b_expl_temp, &c_expl_temp,
              &d_expl_temp, params_ROI_data, params_ROI_size);
  expandROI(params_ROI_data, params_ROI_size, expandedROI_data, expandedROI_size);
  cropImage(I, expandedROI_data, expandedROI_size, Ic);
  cornerMetric(Ic, metricMatrix);
  findPeaks(metricMatrix, locations);
  subPixelLocation(metricMatrix, locations);
  computeMetric(metricMatrix, locations, metricValues);
  excludePointsOutsideROI(params_ROI_data, params_ROI_size, expandedROI_data,
    locations, metricValues, b_locations, b_metricValues);
  cornerPoints_cg_cornerPoints_cg(b_locations, b_metricValues, &expl_temp);
  i1 = pts_pLocation->size[0] * pts_pLocation->size[1];
  pts_pLocation->size[0] = expl_temp.pLocation->size[0];
  pts_pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(pts_pLocation, i1);
  loop_ub = expl_temp.pLocation->size[0] * expl_temp.pLocation->size[1];
  emxFree_real32_T(&b_metricValues);
  emxFree_real32_T(&b_locations);
  emxFree_real32_T(&metricValues);
  emxFree_real32_T(&locations);
  emxFree_real32_T(&metricMatrix);
  emxFree_real32_T(&Ic);
  for (i1 = 0; i1 < loop_ub; i1++) {
    pts_pLocation->data[i1] = expl_temp.pLocation->data[i1];
  }

  c_emxFreeStruct_vision_internal(&expl_temp);
}

/*
 * File trailer for detectMinEigenFeatures.c
 *
 * [EOF]
 */
