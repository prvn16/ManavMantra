/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * depthEstimationFromStereoVideo_kernel_types.h
 *
 * Code generation for function 'depthEstimationFromStereoVideo_kernel'
 *
 */

#ifndef DEPTHESTIMATIONFROMSTEREOVIDEO_KERNEL_TYPES_H
#define DEPTHESTIMATIONFROMSTEREOVIDEO_KERNEL_TYPES_H

/* Include files */
#include "rtwtypes.h"

/* Type Definitions */
#ifndef struct_emxArray_boolean_T
#define struct_emxArray_boolean_T

struct emxArray_boolean_T
{
  boolean_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_boolean_T*/

#ifndef typedef_emxArray_boolean_T
#define typedef_emxArray_boolean_T

typedef struct emxArray_boolean_T emxArray_boolean_T;

#endif                                 /*typedef_emxArray_boolean_T*/

#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T

struct emxArray_real_T
{
  real_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_real_T*/

#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T

typedef struct emxArray_real_T emxArray_real_T;

#endif                                 /*typedef_emxArray_real_T*/

#ifndef typedef_c_struct_T
#define typedef_c_struct_T

typedef struct {
  real_T Area;
  real_T Centroid[2];
  real_T BoundingBox[4];
  real_T MajorAxisLength;
  real_T MinorAxisLength;
  real_T Eccentricity;
  real_T Orientation;
  emxArray_boolean_T *Image;
  emxArray_boolean_T *FilledImage;
  real_T FilledArea;
  real_T EulerNumber;
  real_T Extrema[16];
  real_T EquivDiameter;
  real_T Extent;
  emxArray_real_T *PixelIdxList;
  emxArray_real_T *PixelList;
  real_T Perimeter;
  emxArray_real_T *PixelValues;
  real_T WeightedCentroid[2];
  real_T MeanIntensity;
  real_T MinIntensity;
  real_T MaxIntensity;
  emxArray_real_T *SubarrayIdx;
  real_T SubarrayIdxLengths[2];
} c_struct_T;

#endif                                 /*typedef_c_struct_T*/

#ifndef typedef_b_emxArray_struct_T
#define typedef_b_emxArray_struct_T

typedef struct {
  c_struct_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
} b_emxArray_struct_T;

#endif                                 /*typedef_b_emxArray_struct_T*/

#ifndef typedef_b_struct_T
#define typedef_b_struct_T

typedef struct {
  real_T Centroid[2];
  real_T BoundingBox[4];
} b_struct_T;

#endif                                 /*typedef_b_struct_T*/

#ifndef typedef_c_vision_internal_calibration_C
#define typedef_c_vision_internal_calibration_C

typedef struct {
  real_T RadialDistortion[2];
  real_T TangentialDistortion[2];
  char_T WorldUnits[2];
  real_T NumRadialDistortionCoefficients;
  real_T TranslationVectors[36];
  real_T RotationVectors[36];
  real_T IntrinsicMatrixInternal[9];
} c_vision_internal_calibration_C;

#endif                                 /*typedef_c_vision_internal_calibration_C*/

#ifndef struct_emxArray_char_T
#define struct_emxArray_char_T

struct emxArray_char_T
{
  char_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_char_T*/

#ifndef typedef_emxArray_char_T
#define typedef_emxArray_char_T

typedef struct emxArray_char_T emxArray_char_T;

#endif                                 /*typedef_emxArray_char_T*/

#ifndef struct_emxArray_real32_T
#define struct_emxArray_real32_T

struct emxArray_real32_T
{
  real32_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_real32_T*/

#ifndef typedef_emxArray_real32_T
#define typedef_emxArray_real32_T

typedef struct emxArray_real32_T emxArray_real32_T;

#endif                                 /*typedef_emxArray_real32_T*/

#ifndef typedef_c_vision_internal_calibration_I
#define typedef_c_vision_internal_calibration_I

typedef struct {
  emxArray_real32_T *XmapSingle;
  emxArray_real32_T *YmapSingle;
  emxArray_real_T *SizeOfImage;
  emxArray_char_T *ClassOfImage;
  emxArray_char_T *OutputView;
  real_T XBounds[2];
  real_T YBounds[2];
} c_vision_internal_calibration_I;

#endif                                 /*typedef_c_vision_internal_calibration_I*/

#ifndef typedef_projective2d
#define typedef_projective2d

typedef struct {
  real_T T[9];
} projective2d;

#endif                                 /*typedef_projective2d*/

#ifndef typedef_c_vision_internal_calibration_R
#define typedef_c_vision_internal_calibration_R

typedef struct {
  projective2d H1;
  projective2d H2;
  real_T Q[16];
  real_T XBounds[2];
  real_T YBounds[2];
  boolean_T Initialized;
  real_T OriginalImageSize[2];
  emxArray_char_T *OutputView;
} c_vision_internal_calibration_R;

#endif                                 /*typedef_c_vision_internal_calibration_R*/

#ifndef typedef_c_vision_internal_calibration_S
#define typedef_c_vision_internal_calibration_S

typedef struct {
  c_vision_internal_calibration_C *CameraParameters1;
  c_vision_internal_calibration_C *CameraParameters2;
  real_T RotationOfCamera2[9];
  real_T TranslationOfCamera2[3];
  c_vision_internal_calibration_I RectifyMap1;
  c_vision_internal_calibration_I RectifyMap2;
  c_vision_internal_calibration_R RectificationParams;
} c_vision_internal_calibration_S;

#endif                                 /*typedef_c_vision_internal_calibration_S*/

#ifndef struct_vision_DeployableVideoPlayer_2
#define struct_vision_DeployableVideoPlayer_2

struct vision_DeployableVideoPlayer_2
{
  int32_T S0_isInitialized;
  real_T W0_ToVideoDevice[137];
  uint8_T W1_ID_Dwork[1025];
  real_T W2_VideoInfo[11];
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
  int32_T isInitialized;
  boolean_T isSetupComplete;
  vision_DeployableVideoPlayer_2 cSFunObject;
} c_visioncodegen_DeployableVideo;

#endif                                 /*typedef_c_visioncodegen_DeployableVideo*/

#ifndef typedef_cell_wrap_3
#define typedef_cell_wrap_3

typedef struct {
  uint32_T f1[8];
} cell_wrap_3;

#endif                                 /*typedef_cell_wrap_3*/

#ifndef typedef_cvstDSGBMStruct_T
#define typedef_cvstDSGBMStruct_T

typedef struct {
  int32_T preFilterCap;
  int32_T SADWindowSize;
  int32_T minDisparity;
  int32_T numberOfDisparities;
  int32_T uniquenessRatio;
  int32_T disp12MaxDiff;
  int32_T speckleWindowSize;
  int32_T speckleRange;
  int32_T P1;
  int32_T P2;
  int32_T fullDP;
} cvstDSGBMStruct_T;

#endif                                 /*typedef_cvstDSGBMStruct_T*/

#ifndef typedef_e_depthEstimationFromStereoVide
#define typedef_e_depthEstimationFromStereoVide

typedef struct {
  union
  {
    struct {
      uint8_T tmpRGB[1108698];
    } f0;

    struct {
      uint8_T inputImage[307200];
    } f1;

    struct {
      real_T centeredPoints[614400];
      real_T r4[614400];
      real_T a[614400];
      real_T distortedNormalizedPoints[614400];
      real_T xNorm[307200];
      real_T r2[307200];
      real_T yNorm[307200];
      real_T dv0[307200];
      real_T b_r4[307200];
      real_T xyProduct[307200];
    } f2;
  } u1;

  union
  {
    struct {
      real_T allPts[2457600];
      real_T X[614400];
      real_T ptsOut[614400];
      real_T b_X[307200];
      real_T Y[307200];
      real_T b_ptsOut[307200];
      real_T dv8[307200];
      boolean_T bv2[1228800];
      boolean_T bv3[1228800];
      uint8_T mask[307200];
    } f3;

    struct {
      real_T allPts[2457600];
      real_T X[614400];
      real_T ptsOut[614400];
      real_T b_X[307200];
      real_T Y[307200];
      real_T b_ptsOut[307200];
      real_T dv3[307200];
      boolean_T bv0[1228800];
      boolean_T bv1[1228800];
      uint8_T mask[307200];
    } f4;
  } u2;

  struct {
    uint8_T dispFrame[1108698];
    uint8_T U0[1108698];
    uint8_T RGB[1108698];
    uint8_T frameLeft[921600];
    uint8_T frameRight[921600];
  } f5;
} e_depthEstimationFromStereoVide;

#endif                                 /*typedef_e_depthEstimationFromStereoVide*/

#ifndef struct_emxArray_int32_T
#define struct_emxArray_int32_T

struct emxArray_int32_T
{
  int32_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_int32_T*/

#ifndef typedef_emxArray_int32_T
#define typedef_emxArray_int32_T

typedef struct emxArray_int32_T emxArray_int32_T;

#endif                                 /*typedef_emxArray_int32_T*/

#ifndef typedef_emxArray_struct_T
#define typedef_emxArray_struct_T

typedef struct {
  b_struct_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
} emxArray_struct_T;

#endif                                 /*typedef_emxArray_struct_T*/

#ifndef struct_emxArray_uint8_T
#define struct_emxArray_uint8_T

struct emxArray_uint8_T
{
  uint8_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_uint8_T*/

#ifndef typedef_emxArray_uint8_T
#define typedef_emxArray_uint8_T

typedef struct emxArray_uint8_T emxArray_uint8_T;

#endif                                 /*typedef_emxArray_uint8_T*/

#ifndef typedef_struct2_T
#define typedef_struct2_T

typedef struct {
  char_T Name[30];
  char_T Version[3];
  char_T Release[8];
  char_T Date[11];
} struct2_T;

#endif                                 /*typedef_struct2_T*/

#ifndef typedef_struct1_T
#define typedef_struct1_T

typedef struct {
  real_T RadialDistortion[2];
  real_T TangentialDistortion[2];
  real_T WorldPoints[96];
  char_T WorldUnits[2];
  boolean_T EstimateSkew;
  real_T NumRadialDistortionCoefficients;
  boolean_T EstimateTangentialDistortion;
  real_T RotationVectors[36];
  real_T TranslationVectors[36];
  real_T ReprojectionErrors[1152];
  real_T IntrinsicMatrix[9];
  struct2_T Version;
} struct1_T;

#endif                                 /*typedef_struct1_T*/

#ifndef typedef_struct3_T
#define typedef_struct3_T

typedef struct {
  boolean_T Initialized;
  real_T H1[9];
  real_T H2[9];
  real_T Q[16];
  real_T XBounds[2];
  real_T YBounds[2];
  real_T OriginalImageSize[2];
  char_T OutputView[5];
} struct3_T;

#endif                                 /*typedef_struct3_T*/

#ifndef typedef_struct0_T
#define typedef_struct0_T

typedef struct {
  struct1_T CameraParameters1;
  struct1_T CameraParameters2;
  real_T RotationOfCamera2[9];
  real_T TranslationOfCamera2[3];
  struct2_T Version;
  struct3_T RectificationParams;
} struct0_T;

#endif                                 /*typedef_struct0_T*/

#ifndef typedef_vision_PeopleDetector
#define typedef_vision_PeopleDetector

typedef struct {
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  boolean_T TunablePropsChanged;
  cell_wrap_3 inputVarSize[1];
  real_T ClassificationThreshold;
  real_T MinSize[2];
  real_T ScaleFactor;
  real_T WindowStride[2];
  void * pHOGDescriptor;
  real_T pTrainingSize[2];
} vision_PeopleDetector;

#endif                                 /*typedef_vision_PeopleDetector*/

#ifndef struct_vision_ShapeInserter_3
#define struct_vision_ShapeInserter_3

struct vision_ShapeInserter_3
{
  int32_T S0_isInitialized;
  int32_T P0_RTP_LINEWIDTH;
};

#endif                                 /*struct_vision_ShapeInserter_3*/

#ifndef typedef_vision_ShapeInserter_3
#define typedef_vision_ShapeInserter_3

typedef struct vision_ShapeInserter_3 vision_ShapeInserter_3;

#endif                                 /*typedef_vision_ShapeInserter_3*/

#ifndef struct_vision_VideoFileReader_0
#define struct_vision_VideoFileReader_0

struct vision_VideoFileReader_0
{
  int32_T S0_isInitialized;
  real_T W0_HostLib[137];
  real_T W1_AudioInfo[5];
  real_T W2_VideoInfo[11];
  uint32_T W3_LoopCount;
  uint8_T P0_PLUGIN_PATH;
  uint8_T P1_CONVERTER_PATH;
  boolean_T O1_Y1;
  boolean_T O2_Y2;
};

#endif                                 /*struct_vision_VideoFileReader_0*/

#ifndef typedef_vision_VideoFileReader_0
#define typedef_vision_VideoFileReader_0

typedef struct vision_VideoFileReader_0 vision_VideoFileReader_0;

#endif                                 /*typedef_vision_VideoFileReader_0*/

#ifndef typedef_visioncodegen_ShapeInserter
#define typedef_visioncodegen_ShapeInserter

typedef struct {
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  vision_ShapeInserter_3 cSFunObject;
  real_T LineWidth;
  boolean_T c_NoTuningBeforeLockingCodeGenE;
} visioncodegen_ShapeInserter;

#endif                                 /*typedef_visioncodegen_ShapeInserter*/
#endif

/* End of code generation (depthEstimationFromStereoVideo_kernel_types.h) */
