/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: FaceTrackingKLTpackNGo_kernel.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "MarkerInserter.h"
#include "insertMarker.h"
#include "SystemCore.h"
#include "insertShape.h"
#include "estimateGeometricTransform.h"
#include "step.h"
#include "PointTracker.h"
#include "detectMinEigenFeatures.h"
#include "bbox2points.h"
#include "CascadeObjectDetector.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "libmwrgb2gray_tbb.h"
#include "pointTrackerCore_api.hpp"
#include "libmwgrayto8.h"
#include "CascadeClassifierCore_api.hpp"

/* Type Definitions */
#ifndef struct_vision_DeployableVideoPlayer_2
#define struct_vision_DeployableVideoPlayer_2

struct vision_DeployableVideoPlayer_2
{
  int S0_isInitialized;
  double W0_ToVideoDevice[137];
  unsigned char W1_ID_Dwork[1025];
  double W2_VideoInfo[11];
};

#endif                                 /*struct_vision_DeployableVideoPlayer_2*/

#ifndef typedef_vision_DeployableVideoPlayer_2
#define typedef_vision_DeployableVideoPlayer_2

typedef struct vision_DeployableVideoPlayer_2 vision_DeployableVideoPlayer_2;

#endif                                 /*typedef_vision_DeployableVideoPlayer_2*/

#ifndef typedef_c_visioncodegen_DeployableVideo
#define typedef_c_visioncodegen_DeployableVideo

typedef struct {
  boolean_T matlabCodegenIsDeleted;
  int isInitialized;
  boolean_T isSetupComplete;
  vision_DeployableVideoPlayer_2 cSFunObject;
} c_visioncodegen_DeployableVideo;

#endif                                 /*typedef_c_visioncodegen_DeployableVideo*/

/* Function Definitions */

/*
 * This is a modified version of the example
 *  <matlab:web(fullfile(docroot,'vision','examples','face-detection-and-tracking-using-the-klt-algorithm.html'));
 *  Face Detection and Tracking Using the KLT Algorithm>. The original
 *  example has been modified so that this function can generate standalone
 *  executable. To learn how to modify the MATLAB code to make it codegen
 *  compatible, you can look at example
 *  <matlab:web(fullfile(docroot,'vision','ug','code-generation-for-feature-matching-and-registration.html')); Introduction to Code Generation with Feature Matching and Registration>
 *  This example shows how to automatically detect and track a face using
 *  feature points. The approach in this example keeps track of the face even
 *  when the person tilts his or her head, or moves toward or away from the
 *  camera.
 *
 *    Copyright 2012 The MathWorks, Inc.
 * Arguments    : void
 * Return Type  : void
 */
void FaceTrackingKLTpackNGo_kernel(void)
{
  c_visioncodegen_DeployableVideo videoPlayer;
  vision_CascadeObjectDetector faceDetector;
  vision_VideoFileReader_0 videoFileReader;
  emxArray_real32_T *bbox;
  emxArray_real_T *r0;
  static float videoFrame[921600];
  boolean_T d;
  boolean_T b0;
  int k;
  int blockW;
  static float b_videoFrame[921600];
  int bbox_size[2];
  emxArray_real32_T *points_pLocation;
  float bbox_data[4];
  emxArray_real32_T *points;
  float bboxPoints[8];
  static float I[307200];
  vision_PointTracker pointTracker;
  void * ptrObj;
  static unsigned char Iu8[921600];
  static unsigned char Iu8_gray[307200];
  double expl_temp[2];
  double params_NumPyramidLevels;
  double b_expl_temp;
  double c_expl_temp;
  double d_expl_temp;
  int blockH;
  cvstPTStruct_T paramStruct;
  emxArray_real32_T *oldPoints;
  int boffset;
  static unsigned char Iu8_grayT[307200];
  emxArray_real32_T *b_points;
  emxArray_boolean_T *isFound;
  emxArray_real32_T *oldInliers;
  emxArray_real32_T *visiblePoints;
  emxArray_int32_T *r1;
  emxArray_int32_T *r2;
  emxArray_real32_T *b_oldPoints;
  emxArray_real32_T *c_points;
  int exitg1;
  int i;
  c_visioncodegen_DeployableVideo *obj;
  char *sErr;
  static float U0[921600];
  float xform_T_data[9];
  int xform_T_size[2];
  float U[12];
  float X_data[12];
  int aoffset;
  float b_bboxPoints[8];
  int iv1[8];
  float c_bboxPoints[8];
  int positionOut_data[8];
  int positionOut_size[1];
  visioncodegen_ShapeInserter_1 *h_ShapeInserter;
  int position_data[998];
  float color_data[1497];
  int color_size[2];
  visioncodegen_MarkerInserter *h_MarkerInserter;
  float points_data[998];
  boolean_T pointValidity_data[499];
  videoPlayer.matlabCodegenIsDeleted = true;
  faceDetector.matlabCodegenIsDeleted = true;

  /*  Detect a Face */
  /*  First, you must detect the face. Use the |vision.CascadeObjectDetector| */
  /*  System Object(TM) to detect the location of a face in a video frame. The */
  /*  cascade object detector uses the Viola-Jones detection algorithm and a */
  /*  trained classification model for detection. By default, the detector is */
  /*  configured to detect faces, but it can be used to detect other types of */
  /*  objects.  */
  /*  Create a cascade detector object. */
  c_CascadeObjectDetector_Cascade(&faceDetector);

  /*  Read a video frame and run the face detector. */
  /*  Use compressed avi on Windows(R) and Linux(R) */
  Constructor(&videoFileReader);
  if (videoFileReader.S0_isInitialized != 1) {
    videoFileReader.S0_isInitialized = 1;
    Start(&videoFileReader);
    InitializeConditions(&videoFileReader);
  }

  emxInit_real32_T(&bbox, 2);
  emxInit_real_T(&r0, 2);
  Outputs(&videoFileReader, videoFrame, &d, &b0);
  SystemCore_step(&faceDetector, videoFrame, r0);
  k = bbox->size[0] * bbox->size[1];
  bbox->size[0] = r0->size[0];
  bbox->size[1] = 4;
  emxEnsureCapacity_real32_T(bbox, k);
  blockW = r0->size[0] * r0->size[1];
  for (k = 0; k < blockW; k++) {
    bbox->data[k] = (float)r0->data[k];
  }

  emxFree_real_T(&r0);

  /*  Draw the returned bounding box around the detected face. */
  memcpy(&b_videoFrame[0], &videoFrame[0], 921600U * sizeof(float));
  insertShape(b_videoFrame, bbox->data, bbox->size, videoFrame);

  /* %%%%%figure; imshow(videoFrame); title('Detected face'); */
  /*  Convert the first box into a list of 4 points */
  /*  This is needed to be able to visualize the rotation of the object. */
  bbox_size[0] = 1;
  bbox_size[1] = 4;
  for (k = 0; k < 4; k++) {
    bbox_data[k] = bbox->data[bbox->size[0] * k];
  }

  emxInit_real32_T(&points_pLocation, 2);
  emxInit_real32_T(&points, 2);
  bbox2points(bbox_data, bbox_size, bboxPoints);

  /*  */
  /*  To track the face over time, this example uses the Kanade-Lucas-Tomasi */
  /*  (KLT) algorithm. While it is possible to use the cascade object detector */
  /*  on every frame, it is computationally expensive. It may also fail to */
  /*  detect the face, when the subject turns or tilts his head. This */
  /*  limitation comes from the type of trained classification model used for */
  /*  detection. The example detects the face only once, and then the KLT */
  /*  algorithm tracks the face across the video frames.  */
  /*  Identify Facial Features To Track */
  /*  The KLT algorithm tracks a set of feature points across the video frames. */
  /*  Once the detection locates the face, the next step in the example */
  /*  identifies feature points that can be reliably tracked.  This example */
  /*  uses the standard, "good features to track" proposed by Shi and Tomasi.  */
  /*  Detect feature points in the face region. */
  rgb2gray_tbb_real32(videoFrame, 307200.0, I, true);
  detectMinEigenFeatures(I, bbox->data, bbox->size, points_pLocation);

  /*  Initialize a Tracker to Track the Points */
  /*  With the feature points identified, you can now use the */
  /*  |vision.PointTracker| System Object(TM) to track them. For each point in */
  /*  the previous frame, the point tracker attempts to find the corresponding */
  /*  point in the current frame. Then the |estimateGeometricTransform| */
  /*  function is used to estimate the translation, rotation, and scale between */
  /*  the old points and the new points. This transformation is applied to the */
  /*  bounding box around the face. */
  /*  Create a point tracker and enable the bidirectional error constraint to */
  /*  make it more robust in the presence of noise and clutter. */
  pointTracker.isInitialized = 0;
  ptrObj = NULL;
  pointTracker_construct(&ptrObj);
  pointTracker.pTracker = ptrObj;
  pointTracker.matlabCodegenIsDeleted = false;

  /*  Initialize the tracker with the initial point locations and the initial */
  /*  video frame. */
  k = points->size[0] * points->size[1];
  points->size[0] = points_pLocation->size[0];
  points->size[1] = 2;
  emxEnsureCapacity_real32_T(points, k);
  blockW = points_pLocation->size[0] * points_pLocation->size[1];
  emxFree_real32_T(&bbox);
  for (k = 0; k < blockW; k++) {
    points->data[k] = points_pLocation->data[k];
  }

  SystemCore_setup(&pointTracker);
  pointTracker.FrameClassID = 1.0;
  grayto8_real32(videoFrame, Iu8, 921600.0);
  pointTracker.IsRGB = true;
  rgb2gray_tbb_uint8(Iu8, 307200.0, Iu8_gray, true);
  for (k = 0; k < 2; k++) {
    pointTracker.FrameSize[k] = 480.0 + 160.0 * (double)k;
  }

  pointTracker.NumPoints = points_pLocation->size[0];
  PointTracker_getKLTParams(&pointTracker, expl_temp, &params_NumPyramidLevels,
    &b_expl_temp, &c_expl_temp, &d_expl_temp);
  blockH = (int32_T)(31.0);
  blockW = (int32_T)(31.0);
  paramStruct.blockSize[0] = blockH;
  paramStruct.blockSize[1] = blockW;
  paramStruct.numPyramidLevels = (int32_T)(params_NumPyramidLevels);
  paramStruct.maxIterations = (double)(30.0);
  paramStruct.epsilon = 0.01;
  paramStruct.maxBidirectionalError = 2.0;
  for (k = 0; k < 480; k++) {
    for (boffset = 0; boffset < 640; boffset++) {
      Iu8_grayT[boffset + 640 * k] = Iu8_gray[k + 480 * boffset];
    }
  }

  emxInit_real32_T(&oldPoints, 2);
  pointTracker_initialize(pointTracker.pTracker, Iu8_grayT, 480, 640,
    &points->data[0], points_pLocation->size[0], &paramStruct);

  /*  Initialize a Video Player to display the results. */
  videoPlayer.isInitialized = 0;

  /* System object Constructor function: vision.DeployableVideoPlayer */
  videoPlayer.matlabCodegenIsDeleted = false;

  /*  Track the Face */
  /*  Track the points from frame to frame, and use */
  /*  |estimateGeometricTransform| function to estimate the motion of the face. */
  /*  Make a copy of the points to be used for computing the geometric */
  /*  transformation between the points in the previous and the current frames. */
  k = oldPoints->size[0] * oldPoints->size[1];
  oldPoints->size[0] = points_pLocation->size[0];
  oldPoints->size[1] = 2;
  emxEnsureCapacity_real32_T(oldPoints, k);
  blockW = points_pLocation->size[0] * points_pLocation->size[1];
  emxFree_real32_T(&points);
  for (k = 0; k < blockW; k++) {
    oldPoints->data[k] = points_pLocation->data[k];
  }

  emxFree_real32_T(&points_pLocation);
  emxInit_real32_T(&b_points, 2);
  emxInit_boolean_T(&isFound, 1);
  emxInit_real32_T(&oldInliers, 2);
  emxInit_real32_T(&visiblePoints, 2);
  emxInit_int32_T(&r1, 1);
  emxInit_int32_T(&r2, 1);
  emxInit_real32_T(&b_oldPoints, 2);
  emxInit_real32_T(&c_points, 2);
  do {
    exitg1 = 0;
    d = videoFileReader.O2_Y2;
    if (!d) {
      /*  get the next frame. */
      if (videoFileReader.S0_isInitialized != 1) {
        videoFileReader.S0_isInitialized = 1;
        Start(&videoFileReader);
        InitializeConditions(&videoFileReader);
      }

      Outputs(&videoFileReader, videoFrame, &d, &b0);

      /*  Track the points. Note that some points may be lost. */
      c_SystemCore_step(&pointTracker, videoFrame, b_points, isFound);
      blockW = isFound->size[0] - 1;
      blockH = 0;
      for (i = 0; i <= blockW; i++) {
        if (isFound->data[i]) {
          blockH++;
        }
      }

      k = r1->size[0];
      r1->size[0] = blockH;
      emxEnsureCapacity_int32_T(r1, k);
      blockH = 0;
      for (i = 0; i <= blockW; i++) {
        if (isFound->data[i]) {
          r1->data[blockH] = i + 1;
          blockH++;
        }
      }

      blockW = isFound->size[0] - 1;
      blockH = 0;
      for (i = 0; i <= blockW; i++) {
        if (isFound->data[i]) {
          blockH++;
        }
      }

      k = r2->size[0];
      r2->size[0] = blockH;
      emxEnsureCapacity_int32_T(r2, k);
      blockH = 0;
      for (i = 0; i <= blockW; i++) {
        if (isFound->data[i]) {
          r2->data[blockH] = i + 1;
          blockH++;
        }
      }

      blockH = r1->size[0];
      if (blockH >= 2) {
        /*  need at least 2 points */
        /*  Estimate the geometric transformation between the old points */
        /*  and the new points and eliminate outliers. */
        blockW = oldPoints->size[1];
        k = b_oldPoints->size[0] * b_oldPoints->size[1];
        b_oldPoints->size[0] = r2->size[0];
        b_oldPoints->size[1] = blockW;
        emxEnsureCapacity_real32_T(b_oldPoints, k);
        for (k = 0; k < blockW; k++) {
          blockH = r2->size[0];
          for (boffset = 0; boffset < blockH; boffset++) {
            b_oldPoints->data[boffset + b_oldPoints->size[0] * k] =
              oldPoints->data[(r2->data[boffset] + oldPoints->size[0] * k) - 1];
          }
        }

        k = c_points->size[0] * c_points->size[1];
        c_points->size[0] = r1->size[0];
        c_points->size[1] = 2;
        emxEnsureCapacity_real32_T(c_points, k);
        for (k = 0; k < 2; k++) {
          blockW = r1->size[0];
          for (boffset = 0; boffset < blockW; boffset++) {
            c_points->data[boffset + c_points->size[0] * k] = b_points->data
              [(r1->data[boffset] + b_points->size[0] * k) - 1];
          }
        }

        estimateGeometricTransform(b_oldPoints, c_points, xform_T_data,
          xform_T_size, oldInliers, visiblePoints);

        /*  Apply the transformation to the bounding box points. */
        for (i = 0; i < 4; i++) {
          U[8 + i] = 1.0F;
        }

        for (blockH = 0; blockH < 2; blockH++) {
          for (i = 0; i < 4; i++) {
            U[i + (blockH << 2)] = bboxPoints[i + (blockH << 2)];
          }
        }

        if (xform_T_size[0] == 1) {
          blockW = xform_T_size[1];
          for (k = 0; k < 4; k++) {
            for (boffset = 0; boffset < blockW; boffset++) {
              X_data[k + (boffset << 2)] = 0.0F;
              for (blockH = 0; blockH < 3; blockH++) {
                X_data[k + (boffset << 2)] += U[k + (blockH << 2)] *
                  xform_T_data[blockH + boffset];
              }
            }
          }
        } else {
          for (blockH = 0; blockH < xform_T_size[1]; blockH++) {
            blockW = blockH << 2;
            boffset = blockH * 3;
            for (i = 0; i < 4; i++) {
              X_data[blockW + i] = 0.0F;
            }

            for (k = 0; k < 3; k++) {
              if (xform_T_data[boffset + k] != 0.0F) {
                aoffset = k << 2;
                for (i = 0; i < 4; i++) {
                  X_data[blockW + i] += xform_T_data[boffset + k] * U[aoffset +
                    i];
                }
              }
            }
          }
        }

        for (k = 0; k < 2; k++) {
          for (boffset = 0; boffset < 4; boffset++) {
            bboxPoints[boffset + (k << 2)] = X_data[boffset + 4 * k];
          }
        }

        /*  Insert a bounding box around the object being tracked. */
        memcpy(&b_videoFrame[0], &videoFrame[0], 921600U * sizeof(float));
        for (k = 0; k < 4; k++) {
          for (boffset = 0; boffset < 2; boffset++) {
            c_bboxPoints[boffset + (k << 1)] = bboxPoints[k + (boffset << 2)];
          }
        }

        for (k = 0; k < 8; k++) {
          b_bboxPoints[k] = c_bboxPoints[k];
        }

        validateAndParseInputs(b_bboxPoints, iv1);
        removeAdjacentSamePts(iv1, positionOut_data, positionOut_size);
        h_ShapeInserter = b_getSystemObjects();
        b_tuneLineWidth(h_ShapeInserter);
        d_SystemCore_step(h_ShapeInserter, b_videoFrame, positionOut_data,
                          positionOut_size, videoFrame);

        /*  Display tracked points. */
        b_validateAndParseInputs(visiblePoints->data, visiblePoints->size,
          position_data, bbox_size, color_data, color_size);
        h_MarkerInserter = c_getSystemObjects();
        tuneMarkersize(h_MarkerInserter);
        if (h_MarkerInserter->isInitialized != 1) {
          h_MarkerInserter->isSetupComplete = false;
          h_MarkerInserter->isInitialized = 1;
          h_MarkerInserter->isSetupComplete = true;
        }

        MarkerInserter_outputImpl(h_MarkerInserter, videoFrame, position_data,
          bbox_size, color_data, color_size);

        /*  Reset the points. */
        k = oldPoints->size[0] * oldPoints->size[1];
        oldPoints->size[0] = visiblePoints->size[0];
        oldPoints->size[1] = visiblePoints->size[1];
        emxEnsureCapacity_real32_T(oldPoints, k);
        blockW = visiblePoints->size[0] * visiblePoints->size[1];
        for (k = 0; k < blockW; k++) {
          oldPoints->data[k] = visiblePoints->data[k];
        }

        blockW = visiblePoints->size[0] * visiblePoints->size[1];
        for (k = 0; k < blockW; k++) {
          points_data[k] = visiblePoints->data[k];
        }

        blockW = visiblePoints->size[0];
        for (k = 0; k < blockW; k++) {
          pointValidity_data[k] = true;
        }

        pointTracker.NumPoints = visiblePoints->size[0];
        pointTracker_setPoints(pointTracker.pTracker, &points_data[0],
          visiblePoints->size[0], &pointValidity_data[0]);
      }

      /*  Display the annotated video frame using the video player. */
      obj = &videoPlayer;
      if (videoPlayer.isInitialized != 1) {
        videoPlayer.isSetupComplete = false;
        videoPlayer.isInitialized = 1;

        /* System object Start function: vision.DeployableVideoPlayer */
        sErr = GetErrorBuffer(&obj->cSFunObject.W0_ToVideoDevice[0U]);
        CreateHostLibrary("tovideodevice.dll",
                          &obj->cSFunObject.W0_ToVideoDevice[0U]);
        if (*sErr == 0) {
          createVideoInfo(&obj->cSFunObject.W2_VideoInfo[0U], 1U, 1.0, 1.0,
                          "RGB ", 1, 3, 640, 480, 0U, 1, 1, NULL);
          LibCreate_Video(&obj->cSFunObject.W0_ToVideoDevice[0U], 0,
                          "SCOMP00000001E6AD93D05", "Deployable Video Player",
                          0U, &obj->cSFunObject.W2_VideoInfo[0U], 1U, 536805376,
                          536805376, 0U, 640, 480, 0, 0U, 1U);
        }

        if (*sErr == 0) {
          LibStart(&obj->cSFunObject.W0_ToVideoDevice[0U]);
        }

        if (*sErr != 0) {
          DestroyHostLibrary(&obj->cSFunObject.W0_ToVideoDevice[0U]);
          if (*sErr != 0) {
            PrintError(sErr);
          }
        }

        videoPlayer.isSetupComplete = true;
      }

      memcpy(&U0[0], &videoFrame[0], 921600U * sizeof(float));

      /* System object Update function: vision.DeployableVideoPlayer */
      sErr = GetErrorBuffer(&obj->cSFunObject.W0_ToVideoDevice[0U]);
      LibUpdate_Video(&obj->cSFunObject.W0_ToVideoDevice[0U], &U0[0U],
                      GetNullPointer(), GetNullPointer(), 640, 480);
      if (*sErr != 0) {
        PrintError(sErr);
      }
    } else {
      exitg1 = 1;
    }
  } while (exitg1 == 0);

  emxFree_real32_T(&c_points);
  emxFree_real32_T(&b_oldPoints);
  emxFree_int32_T(&r2);
  emxFree_int32_T(&r1);
  emxFree_real32_T(&visiblePoints);
  emxFree_real32_T(&oldInliers);
  emxFree_boolean_T(&isFound);
  emxFree_real32_T(&b_points);
  emxFree_real32_T(&oldPoints);

  /*  Clean up. */
  /* System object Destructor function: vision.VideoFileReader */
  if (videoFileReader.S0_isInitialized == 1) {
    videoFileReader.S0_isInitialized = 2;

    /* System object Terminate function: vision.VideoFileReader */
    sErr = GetErrorBuffer(&videoFileReader.W0_HostLib[0U]);
    LibTerminate(&videoFileReader.W0_HostLib[0U]);
    if (*sErr != 0) {
      PrintError(sErr);
    }

    LibDestroy(&videoFileReader.W0_HostLib[0U], 0);
    DestroyHostLibrary(&videoFileReader.W0_HostLib[0U]);
  }

  obj = &videoPlayer;
  if (videoPlayer.isInitialized == 1) {
    videoPlayer.isInitialized = 2;
    if (videoPlayer.isSetupComplete) {
      /* System object Destructor function: vision.DeployableVideoPlayer */
      /* System object Terminate function: vision.DeployableVideoPlayer */
      sErr = GetErrorBuffer(&obj->cSFunObject.W0_ToVideoDevice[0U]);
      LibTerminate(&obj->cSFunObject.W0_ToVideoDevice[0U]);
      if (*sErr != 0) {
        PrintError(sErr);
      }

      LibDestroy(&obj->cSFunObject.W0_ToVideoDevice[0U], 0);
      DestroyHostLibrary(&obj->cSFunObject.W0_ToVideoDevice[0U]);
    }
  }

  if (pointTracker.isInitialized == 1) {
    pointTracker.isInitialized = 2;
    if (pointTracker.isSetupComplete) {
      pointTracker_deleteObj(pointTracker.pTracker);
    }
  }

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

  /* System object Destructor function: vision.VideoFileReader */
  if (videoFileReader.S0_isInitialized == 1) {
    videoFileReader.S0_isInitialized = 2;

    /* System object Terminate function: vision.VideoFileReader */
    sErr = GetErrorBuffer(&videoFileReader.W0_HostLib[0U]);
    LibTerminate(&videoFileReader.W0_HostLib[0U]);
    if (*sErr != 0) {
      PrintError(sErr);
    }

    LibDestroy(&videoFileReader.W0_HostLib[0U], 0);
    DestroyHostLibrary(&videoFileReader.W0_HostLib[0U]);
  }

  if ((!pointTracker.matlabCodegenIsDeleted) && (pointTracker.isInitialized == 1)
      && pointTracker.isSetupComplete) {
    pointTracker_deleteObj(pointTracker.pTracker);
  }

  obj = &videoPlayer;
  if (!videoPlayer.matlabCodegenIsDeleted) {
    videoPlayer.matlabCodegenIsDeleted = true;
    if (videoPlayer.isInitialized == 1) {
      videoPlayer.isInitialized = 2;
      if (videoPlayer.isSetupComplete) {
        /* System object Destructor function: vision.DeployableVideoPlayer */
        /* System object Terminate function: vision.DeployableVideoPlayer */
        sErr = GetErrorBuffer(&obj->cSFunObject.W0_ToVideoDevice[0U]);
        LibTerminate(&obj->cSFunObject.W0_ToVideoDevice[0U]);
        if (*sErr != 0) {
          PrintError(sErr);
        }

        LibDestroy(&obj->cSFunObject.W0_ToVideoDevice[0U], 0);
        DestroyHostLibrary(&obj->cSFunObject.W0_ToVideoDevice[0U]);
      }
    }
  }
}

/*
 * File trailer for FaceTrackingKLTpackNGo_kernel.c
 *
 * [EOF]
 */
