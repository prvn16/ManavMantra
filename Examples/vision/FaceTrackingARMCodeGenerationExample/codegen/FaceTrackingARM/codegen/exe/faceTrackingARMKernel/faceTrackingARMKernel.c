/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: faceTrackingARMKernel.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "MarkerInserter.h"
#include "insertMarker.h"
#include "SystemCore.h"
#include "insertShape.h"
#include "bbox2points.h"
#include "PointTracker.h"
#include "cornerPoints_cg.h"
#include "excludePointsOutsideROI.h"
#include "harrisMinEigen.h"
#include "findPeaks.h"
#include "cropImage.h"
#include "expandROI.h"
#include "estimateGeometricTransform.h"
#include "rgb2gray.h"
#include "CascadeObjectDetector.h"
#include "faceTrackingARMKernel_rtwutil.h"
#include "pointTrackerCore_api.hpp"
#include "CascadeClassifierCore_api.hpp"

/* Type Definitions */
#ifndef struct_emxArray_real_T_4x2
#define struct_emxArray_real_T_4x2

struct emxArray_real_T_4x2
{
  double data[8];
  int size[2];
};

#endif                                 /*struct_emxArray_real_T_4x2*/

#ifndef typedef_emxArray_real_T_4x2
#define typedef_emxArray_real_T_4x2

typedef struct emxArray_real_T_4x2 emxArray_real_T_4x2;

#endif                                 /*typedef_emxArray_real_T_4x2*/

/* Variable Definitions */
static vision_CascadeObjectDetector faceDetector;
static boolean_T faceDetector_not_empty;
static vision_PointTracker pointTracker;
static boolean_T pointTracker_not_empty;
static double numPts;
static emxArray_real32_T *oldPoints;
static boolean_T oldPoints_not_empty;
static emxArray_real_T_4x2 bboxPoints;
static boolean_T bboxPoints_not_empty;

/* Function Definitions */

/*
 * Arguments    : const unsigned char videoFrame[921600]
 *                unsigned char videoFrameOut[921600]
 * Return Type  : void
 */
void faceTrackingARMKernel(const unsigned char videoFrame[921600], unsigned char
  videoFrameOut[921600])
{
  int i0;
  static unsigned char videoFrameGrayFULL[307200];
  emxArray_int32_T *position;
  emxArray_uint8_T *color;
  emxArray_real32_T *points;
  unsigned char Iu8_grayT[34240];
  int end;
  vision_PointTracker *obj;
  emxArray_real_T *bbox;
  int numPoints;
  boolean_T exitg1;
  cell_wrap_3 varSizes[1];
  static const unsigned char inSize[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  emxArray_boolean_T *pointValidity;
  static const unsigned char uv0[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  emxArray_real_T *scores;
  double bbox_data[4];
  float expl_temp;
  double num_points;
  boolean_T b_expl_temp;
  int params_ROI_data[4];
  int xform_T_size[2];
  emxArray_real32_T *pointsTmp;
  int expandedROI_data[4];
  int expandedROI_size[2];
  void * ptrObj;
  emxArray_real32_T *points_pLocation;
  emxArray_real32_T *Ic;
  emxArray_real32_T *metricMatrix;
  static float b_videoFrameGrayFULL[34240];
  emxArray_real32_T *locations;
  emxArray_real32_T *metricValues;
  emxArray_real32_T *b_locations;
  emxArray_real32_T *b_metricValues;
  vision_internal_cornerPoints_cg c_expl_temp;
  emxArray_boolean_T *badPoints;
  int i;
  emxArray_real_T *b_obj;
  emxArray_int32_T *r0;
  boolean_T pointValidity_data[34615];
  emxArray_int32_T *r1;
  int bbox_size[2];
  emxArray_real32_T *b_pointsTmp;
  double x_data[8];
  emxArray_real32_T *visiblePoints;
  float xform_T_data[9];
  int U_size_idx_0;
  static unsigned char tmpRGB[921600];
  double U_data[12];
  int x_size[2];
  double b_x_data[8];
  int positionOut_data[8];
  int b_positionOut_data[8];
  int positionOut_size[1];
  visioncodegen_ShapeInserter *h_ShapeInserter;
  float X_data[12];
  visioncodegen_MarkerInserter *h_MarkerInserter;
  int visiblePoints_size[2];
  emxArray_real32_T visiblePoints_data;
  float b_visiblePoints_data[998];

  /*  Kernel function for 'Face Tracking on ARM Target using Code Generation' example */
  /*  Initialize persistent variables */
  /*  Create the face detector object. */
  if (!faceDetector_not_empty) {
    c_CascadeObjectDetector_Cascade(&faceDetector);
    faceDetector_not_empty = true;
  }

  if (!oldPoints_not_empty) {
    i0 = oldPoints->size[0] * oldPoints->size[1];
    oldPoints->size[0] = 1;
    oldPoints->size[1] = 2;
    emxEnsureCapacity_real32_T(oldPoints, i0);
    for (i0 = 0; i0 < 2; i0++) {
      oldPoints->data[i0] = 0.0F;
    }

    oldPoints_not_empty = true;
  }

  if (!bboxPoints_not_empty) {
    bboxPoints.size[0] = 1;
    bboxPoints.size[1] = 2;
    for (i0 = 0; i0 < 2; i0++) {
      bboxPoints.data[i0] = 0.0;
    }

    bboxPoints_not_empty = true;
  }

  /*  Get the next frame. */
  rgb2gray(videoFrame, videoFrameGrayFULL);

  /*  Resize frame */
  /*  Create the point tracker object. */
  if (!pointTracker_not_empty) {
    PointTracker_PointTracker(&pointTracker);
    pointTracker_not_empty = true;

    /*  Initialize tracker with dummy points */
    for (i0 = 0; i0 < 214; i0++) {
      for (end = 0; end < 160; end++) {
        Iu8_grayT[end + 160 * i0] = videoFrameGrayFULL[3 * end + 480 * (3 * i0)];
      }
    }

    PointTracker_initialize(&pointTracker, Iu8_grayT);
  }

  /*  Detection and Tracking */
  emxInit_int32_T1(&position, 2);
  emxInit_uint8_T(&color, 2);
  emxInit_real32_T(&points, 2);
  if (numPts < 10.0) {
    /*  Detection mode. */
    for (i0 = 0; i0 < 214; i0++) {
      for (end = 0; end < 160; end++) {
        Iu8_grayT[end + 160 * i0] = videoFrameGrayFULL[3 * end + 480 * (3 * i0)];
      }
    }

    emxInit_real_T(&bbox, 2);
    SystemCore_step(&faceDetector, Iu8_grayT, bbox);
    if (!(bbox->size[0] == 0)) {
      /*  Find corner points inside the detected region. */
      for (i0 = 0; i0 < 4; i0++) {
        bbox_data[i0] = bbox->data[bbox->size[0] * i0];
      }

      parseInputs(bbox_data, &expl_temp, &num_points, &b_expl_temp,
                  params_ROI_data, xform_T_size);
      expandROI(params_ROI_data, xform_T_size, expandedROI_data,
                expandedROI_size);
      for (i0 = 0; i0 < 214; i0++) {
        for (end = 0; end < 160; end++) {
          b_videoFrameGrayFULL[end + 160 * i0] = (float)videoFrameGrayFULL[3 *
            end + 480 * (3 * i0)] / 255.0F;
        }
      }

      emxInit_real32_T(&points_pLocation, 2);
      emxInit_real32_T(&Ic, 2);
      emxInit_real32_T(&metricMatrix, 2);
      emxInit_real32_T(&locations, 2);
      emxInit_real32_T1(&metricValues, 1);
      emxInit_real32_T(&b_locations, 2);
      emxInit_real32_T1(&b_metricValues, 1);
      c_emxInitStruct_vision_internal(&c_expl_temp);
      cropImage(b_videoFrameGrayFULL, expandedROI_data, Ic);
      cornerMetric(Ic, metricMatrix);
      findPeaks(metricMatrix, locations);
      subPixelLocation(metricMatrix, locations);
      computeMetric(metricMatrix, locations, metricValues);
      excludePointsOutsideROI(params_ROI_data, expandedROI_data, locations,
        metricValues, b_locations, b_metricValues);
      cornerPoints_cg_cornerPoints_cg(b_locations, b_metricValues, &c_expl_temp);
      i0 = points_pLocation->size[0] * points_pLocation->size[1];
      points_pLocation->size[0] = c_expl_temp.pLocation->size[0];
      points_pLocation->size[1] = 2;
      emxEnsureCapacity_real32_T(points_pLocation, i0);
      i = c_expl_temp.pLocation->size[0] * c_expl_temp.pLocation->size[1];
      emxFree_real32_T(&b_metricValues);
      emxFree_real32_T(&b_locations);
      emxFree_real32_T(&metricValues);
      emxFree_real32_T(&metricMatrix);
      emxFree_real32_T(&Ic);
      for (i0 = 0; i0 < i; i0++) {
        points_pLocation->data[i0] = c_expl_temp.pLocation->data[i0];
      }

      c_emxFreeStruct_vision_internal(&c_expl_temp);

      /*  Re-initialize the point tracker. */
      numPts = points_pLocation->size[0];
      b_expl_temp = (pointTracker.isInitialized == 1);
      if (!b_expl_temp) {
        for (i0 = 0; i0 < 214; i0++) {
          for (end = 0; end < 160; end++) {
            Iu8_grayT[end + 160 * i0] = videoFrameGrayFULL[3 * end + 480 * (3 *
              i0)];
          }
        }

        b_PointTracker_initialize(&pointTracker, points_pLocation, Iu8_grayT);
      }

      for (i0 = 0; i0 < 214; i0++) {
        for (end = 0; end < 160; end++) {
          Iu8_grayT[end + 160 * i0] = videoFrameGrayFULL[3 * end + 480 * (3 * i0)];
        }
      }

      b_SystemCore_step(&pointTracker, Iu8_grayT);
      i0 = points->size[0] * points->size[1];
      points->size[0] = points_pLocation->size[0];
      points->size[1] = 2;
      emxEnsureCapacity_real32_T(points, i0);
      i = points_pLocation->size[0] * points_pLocation->size[1];
      for (i0 = 0; i0 < i; i0++) {
        points->data[i0] = points_pLocation->data[i0];
      }

      i = points_pLocation->size[0];
      for (i0 = 0; i0 < i; i0++) {
        pointValidity_data[i0] = true;
      }

      pointTracker.NumPoints = points_pLocation->size[0];
      ptrObj = pointTracker.pTracker;
      pointTracker_setPoints(ptrObj, &points->data[0], points_pLocation->size[0],
        &pointValidity_data[0]);

      /*  Save a copy of the points. */
      i0 = oldPoints->size[0] * oldPoints->size[1];
      oldPoints->size[0] = points_pLocation->size[0];
      oldPoints->size[1] = 2;
      emxEnsureCapacity_real32_T(oldPoints, i0);
      i = points_pLocation->size[0] * points_pLocation->size[1];
      for (i0 = 0; i0 < i; i0++) {
        oldPoints->data[i0] = points_pLocation->data[i0];
      }

      oldPoints_not_empty = !(oldPoints->size[0] == 0);

      /*  Convert the rectangle represented as [x, y, w, h] into an */
      /*  M-by-2 matrix of [x,y] coordinates of the four corners. This */
      /*  is needed to be able to transform the bounding box to display */
      /*  the orientation of the face. */
      bbox_size[0] = 1;
      bbox_size[1] = 4;
      for (i0 = 0; i0 < 4; i0++) {
        bbox_data[i0] = bbox->data[bbox->size[0] * i0];
      }

      bbox2points(bbox_data, bbox_size, x_data);
      bboxPoints.size[0] = 4;
      bboxPoints.size[1] = 2;
      memcpy(&bboxPoints.data[0], &x_data[0], sizeof(double) << 3);
      bboxPoints_not_empty = true;

      /*  Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4] */
      /*  format required by insertShape. */
      i = bboxPoints.size[0];
      for (i0 = 0; i0 < i; i0++) {
        for (end = 0; end < 2; end++) {
          x_data[end + (i0 << 1)] = bboxPoints.data[i0 + bboxPoints.size[0] *
            end];
        }
      }

      i = bboxPoints.size[0];
      for (i0 = 0; i0 < i; i0++) {
        for (end = 0; end < 2; end++) {
          b_x_data[end + (i0 << 1)] = x_data[end + (i0 << 1)];
        }
      }

      /*  Display a bounding box around the detected face. */
      memcpy(&tmpRGB[0], &videoFrame[0], 921600U * sizeof(unsigned char));
      x_size[0] = 1;
      x_size[1] = bboxPoints.size[0] << 1;
      i = bboxPoints.size[0] << 1;
      for (i0 = 0; i0 < i; i0++) {
        x_data[i0] = b_x_data[i0] * 3.0;
      }

      validateAndParseInputs(x_data, x_size, positionOut_data, xform_T_size);
      removeAdjacentSamePts(positionOut_data, xform_T_size, b_positionOut_data,
                            positionOut_size);
      h_ShapeInserter = getSystemObjects();
      tuneLineWidth(h_ShapeInserter);
      c_SystemCore_step(h_ShapeInserter, tmpRGB, b_positionOut_data,
                        positionOut_size, videoFrameOut);

      /*  Display detected corners. */
      i0 = locations->size[0] * locations->size[1];
      locations->size[0] = points_pLocation->size[0];
      locations->size[1] = 2;
      emxEnsureCapacity_real32_T(locations, i0);
      i = points_pLocation->size[0] * points_pLocation->size[1];
      for (i0 = 0; i0 < i; i0++) {
        locations->data[i0] = points_pLocation->data[i0] * 3.0F;
      }

      emxFree_real32_T(&points_pLocation);
      b_validateAndParseInputs(locations, position, color);
      h_MarkerInserter = b_getSystemObjects();
      tuneMarkersize(h_MarkerInserter);
      emxFree_real32_T(&locations);
      if (h_MarkerInserter->isInitialized != 1) {
        h_MarkerInserter->isSetupComplete = false;
        h_MarkerInserter->isInitialized = 1;
        h_MarkerInserter->isSetupComplete = true;
      }

      MarkerInserter_outputImpl(h_MarkerInserter, videoFrameOut, position, color);
    } else {
      memcpy(&videoFrameOut[0], &videoFrame[0], 921600U * sizeof(unsigned char));
    }

    emxFree_real_T(&bbox);
  } else {
    /*  Tracking mode. */
    obj = &pointTracker;
    if (pointTracker.isInitialized != 1) {
      pointTracker.isSetupComplete = false;
      pointTracker.isInitialized = 1;
      for (i0 = 0; i0 < 8; i0++) {
        varSizes[0].f1[i0] = inSize[i0];
      }

      pointTracker.inputVarSize[0] = varSizes[0];
      pointTracker.isSetupComplete = true;
    }

    numPoints = 0;
    exitg1 = false;
    while ((!exitg1) && (numPoints < 8)) {
      if (pointTracker.inputVarSize[0].f1[numPoints] != uv0[numPoints]) {
        for (i0 = 0; i0 < 8; i0++) {
          pointTracker.inputVarSize[0].f1[i0] = inSize[i0];
        }

        exitg1 = true;
      } else {
        numPoints++;
      }
    }

    emxInit_boolean_T(&pointValidity, 1);
    emxInit_real_T1(&scores, 1);
    emxInit_real32_T(&pointsTmp, 2);
    ptrObj = pointTracker.pTracker;
    num_points = pointTracker.NumPoints;
    num_points = rt_roundd_snf(num_points);
    if (num_points < 2.147483648E+9) {
      if (num_points >= -2.147483648E+9) {
        numPoints = (int)num_points;
      } else {
        numPoints = MIN_int32_T;
      }
    } else if (num_points >= 2.147483648E+9) {
      numPoints = MAX_int32_T;
    } else {
      numPoints = 0;
    }

    i0 = pointsTmp->size[0] * pointsTmp->size[1];
    pointsTmp->size[0] = numPoints;
    pointsTmp->size[1] = 2;
    emxEnsureCapacity_real32_T(pointsTmp, i0);
    i0 = pointValidity->size[0];
    pointValidity->size[0] = numPoints;
    emxEnsureCapacity_boolean_T(pointValidity, i0);
    i0 = scores->size[0];
    scores->size[0] = numPoints;
    emxEnsureCapacity_real_T(scores, i0);
    for (i0 = 0; i0 < 160; i0++) {
      for (end = 0; end < 214; end++) {
        Iu8_grayT[end + 214 * i0] = videoFrameGrayFULL[3 * i0 + 480 * (3 * end)];
      }
    }

    emxInit_boolean_T(&badPoints, 1);
    pointTracker_step(ptrObj, Iu8_grayT, 160, 214, &pointsTmp->data[0],
                      &pointValidity->data[0], &scores->data[0]);
    PointTracker_pointsOutsideImage(obj, pointsTmp, badPoints);
    end = badPoints->size[0];
    for (i = 0; i < end; i++) {
      if (badPoints->data[i]) {
        pointValidity->data[i] = false;
      }
    }

    emxFree_boolean_T(&badPoints);
    emxInit_real_T1(&b_obj, 1);
    PointTracker_normalizeScores(scores, pointValidity, b_obj);
    end = pointValidity->size[0] - 1;
    numPoints = 0;
    emxFree_real_T(&b_obj);
    emxFree_real_T(&scores);
    for (i = 0; i <= end; i++) {
      if (pointValidity->data[i]) {
        numPoints++;
      }
    }

    emxInit_int32_T(&r0, 1);
    i0 = r0->size[0];
    r0->size[0] = numPoints;
    emxEnsureCapacity_int32_T(r0, i0);
    numPoints = 0;
    for (i = 0; i <= end; i++) {
      if (pointValidity->data[i]) {
        r0->data[numPoints] = i + 1;
        numPoints++;
      }
    }

    numPoints = r0->size[0];
    numPts = numPoints;
    if (numPts >= 10.0) {
      /*  Estimate the geometric transformation between the old points */
      /*  and the new points. */
      end = pointValidity->size[0] - 1;
      numPoints = 0;
      for (i = 0; i <= end; i++) {
        if (pointValidity->data[i]) {
          numPoints++;
        }
      }

      emxInit_int32_T(&r1, 1);
      i0 = r1->size[0];
      r1->size[0] = numPoints;
      emxEnsureCapacity_int32_T(r1, i0);
      numPoints = 0;
      for (i = 0; i <= end; i++) {
        if (pointValidity->data[i]) {
          r1->data[numPoints] = i + 1;
          numPoints++;
        }
      }

      emxInit_real32_T(&points_pLocation, 2);
      i = oldPoints->size[1];
      i0 = points_pLocation->size[0] * points_pLocation->size[1];
      points_pLocation->size[0] = r1->size[0];
      points_pLocation->size[1] = i;
      emxEnsureCapacity_real32_T(points_pLocation, i0);
      for (i0 = 0; i0 < i; i0++) {
        numPoints = r1->size[0];
        for (end = 0; end < numPoints; end++) {
          points_pLocation->data[end + points_pLocation->size[0] * i0] =
            oldPoints->data[(r1->data[end] + oldPoints->size[0] * i0) - 1];
        }
      }

      emxFree_int32_T(&r1);
      emxInit_real32_T(&b_pointsTmp, 2);
      i0 = b_pointsTmp->size[0] * b_pointsTmp->size[1];
      b_pointsTmp->size[0] = r0->size[0];
      b_pointsTmp->size[1] = 2;
      emxEnsureCapacity_real32_T(b_pointsTmp, i0);
      for (i0 = 0; i0 < 2; i0++) {
        i = r0->size[0];
        for (end = 0; end < i; end++) {
          b_pointsTmp->data[end + b_pointsTmp->size[0] * i0] = pointsTmp->data
            [(r0->data[end] + pointsTmp->size[0] * i0) - 1];
        }
      }

      emxInit_real32_T(&visiblePoints, 2);
      estimateGeometricTransform(points_pLocation, b_pointsTmp, xform_T_data,
        xform_T_size, pointsTmp, visiblePoints);

      /*  Apply the transformation to the bounding box. */
      U_size_idx_0 = (signed char)bboxPoints.size[0];
      i = 0;
      emxFree_real32_T(&b_pointsTmp);
      emxFree_real32_T(&points_pLocation);
      while (i <= U_size_idx_0 - 1) {
        U_data[i + (U_size_idx_0 << 1)] = 1.0;
        i++;
      }

      for (numPoints = 0; numPoints < 2; numPoints++) {
        for (i = bboxPoints.size[0]; i < U_size_idx_0; i++) {
          U_data[i + U_size_idx_0 * numPoints] = 1.0;
        }
      }

      for (numPoints = 0; numPoints < 2; numPoints++) {
        for (i = 0; i < bboxPoints.size[0]; i++) {
          U_data[i + U_size_idx_0 * numPoints] = bboxPoints.data[i +
            bboxPoints.size[0] * numPoints];
        }
      }

      for (i0 = 0; i0 < U_size_idx_0; i0++) {
        i = xform_T_size[1];
        for (end = 0; end < i; end++) {
          X_data[i0 + U_size_idx_0 * end] = 0.0F;
          for (numPoints = 0; numPoints < 3; numPoints++) {
            X_data[i0 + U_size_idx_0 * end] += (float)U_data[i0 + U_size_idx_0 *
              numPoints] * xform_T_data[numPoints + xform_T_size[0] * end];
          }
        }
      }

      bboxPoints.size[0] = U_size_idx_0;
      bboxPoints.size[1] = 2;
      for (i0 = 0; i0 < 2; i0++) {
        for (end = 0; end < U_size_idx_0; end++) {
          bboxPoints.data[end + bboxPoints.size[0] * i0] = X_data[end +
            U_size_idx_0 * i0];
        }
      }

      bboxPoints_not_empty = true;

      /*  Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4] */
      /*  format required by insertShape. */
      i = bboxPoints.size[0];
      for (i0 = 0; i0 < i; i0++) {
        for (end = 0; end < 2; end++) {
          b_x_data[end + (i0 << 1)] = bboxPoints.data[i0 + bboxPoints.size[0] *
            end];
        }
      }

      /*  Display a bounding box around the face being tracked. */
      memcpy(&tmpRGB[0], &videoFrame[0], 921600U * sizeof(unsigned char));
      x_size[0] = 1;
      x_size[1] = bboxPoints.size[0] << 1;
      i = bboxPoints.size[0] << 1;
      for (i0 = 0; i0 < i; i0++) {
        x_data[i0] = b_x_data[i0] * 3.0;
      }

      validateAndParseInputs(x_data, x_size, positionOut_data, xform_T_size);
      removeAdjacentSamePts(positionOut_data, xform_T_size, b_positionOut_data,
                            positionOut_size);
      h_ShapeInserter = getSystemObjects();
      tuneLineWidth(h_ShapeInserter);
      c_SystemCore_step(h_ShapeInserter, tmpRGB, b_positionOut_data,
                        positionOut_size, videoFrameOut);

      /*  Display tracked points. */
      visiblePoints_size[0] = visiblePoints->size[0];
      visiblePoints_size[1] = visiblePoints->size[1];
      i = visiblePoints->size[0] * visiblePoints->size[1];
      for (i0 = 0; i0 < i; i0++) {
        b_visiblePoints_data[i0] = visiblePoints->data[i0] * 3.0F;
      }

      visiblePoints_data.data = (float *)&b_visiblePoints_data;
      visiblePoints_data.size = (int *)&visiblePoints_size;
      visiblePoints_data.allocatedSize = 998;
      visiblePoints_data.numDimensions = 2;
      visiblePoints_data.canFreeData = false;
      b_validateAndParseInputs(&visiblePoints_data, position, color);
      h_MarkerInserter = b_getSystemObjects();
      tuneMarkersize(h_MarkerInserter);
      if (h_MarkerInserter->isInitialized != 1) {
        h_MarkerInserter->isSetupComplete = false;
        h_MarkerInserter->isInitialized = 1;
        h_MarkerInserter->isSetupComplete = true;
      }

      MarkerInserter_outputImpl(h_MarkerInserter, videoFrameOut, position, color);

      /*  Reset the points. */
      i0 = oldPoints->size[0] * oldPoints->size[1];
      oldPoints->size[0] = visiblePoints->size[0];
      oldPoints->size[1] = visiblePoints->size[1];
      emxEnsureCapacity_real32_T(oldPoints, i0);
      i = visiblePoints->size[0] * visiblePoints->size[1];
      for (i0 = 0; i0 < i; i0++) {
        oldPoints->data[i0] = visiblePoints->data[i0];
      }

      emxFree_real32_T(&visiblePoints);
      oldPoints_not_empty = !((oldPoints->size[0] == 0) || (oldPoints->size[1] ==
        0));
      i0 = points->size[0] * points->size[1];
      points->size[0] = oldPoints->size[0];
      points->size[1] = oldPoints->size[1];
      emxEnsureCapacity_real32_T(points, i0);
      i = oldPoints->size[0] * oldPoints->size[1];
      for (i0 = 0; i0 < i; i0++) {
        points->data[i0] = oldPoints->data[i0];
      }

      i = oldPoints->size[0];
      for (i0 = 0; i0 < i; i0++) {
        pointValidity_data[i0] = true;
      }

      pointTracker.NumPoints = oldPoints->size[0];
      ptrObj = pointTracker.pTracker;
      pointTracker_setPoints(ptrObj, &points->data[0], points->size[0],
        &pointValidity_data[0]);
    } else {
      memcpy(&videoFrameOut[0], &videoFrame[0], 921600U * sizeof(unsigned char));
    }

    emxFree_real32_T(&pointsTmp);
    emxFree_boolean_T(&pointValidity);
    emxFree_int32_T(&r0);
  }

  emxFree_real32_T(&points);
  emxFree_uint8_T(&color);
  emxFree_int32_T(&position);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void faceTrackingARMKernel_free(void)
{
  void * ptrObj;
  if (!faceDetector.matlabCodegenIsDeleted) {
    faceDetector.matlabCodegenIsDeleted = true;
    if (faceDetector.isInitialized == 1) {
      faceDetector.isInitialized = 2;
      if (faceDetector.isSetupComplete) {
        ptrObj = faceDetector.pCascadeClassifier;
        cascadeClassifier_deleteObj(ptrObj);
      }
    }
  }

  if (!pointTracker.matlabCodegenIsDeleted) {
    pointTracker.matlabCodegenIsDeleted = true;
    if (pointTracker.isInitialized == 1) {
      pointTracker.isInitialized = 2;
      if (pointTracker.isSetupComplete) {
        ptrObj = pointTracker.pTracker;
        pointTracker_deleteObj(ptrObj);
      }
    }
  }

  emxFree_real32_T(&oldPoints);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void faceTrackingARMKernel_init(void)
{
  bboxPoints.size[1] = 0;
  emxInit_real32_T(&oldPoints, 2);
  bboxPoints_not_empty = false;
  oldPoints_not_empty = false;
  pointTracker_not_empty = false;
  faceDetector_not_empty = false;
  pointTracker.matlabCodegenIsDeleted = true;
  faceDetector.matlabCodegenIsDeleted = true;
  numPts = 0.0;
}

/*
 * File trailer for faceTrackingARMKernel.c
 *
 * [EOF]
 */
