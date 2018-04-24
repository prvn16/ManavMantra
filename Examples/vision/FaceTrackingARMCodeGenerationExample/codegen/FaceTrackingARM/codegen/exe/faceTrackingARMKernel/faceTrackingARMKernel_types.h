/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: faceTrackingARMKernel_types.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef FACETRACKINGARMKERNEL_TYPES_H
#define FACETRACKINGARMKERNEL_TYPES_H

/* Include Files */
#include "rtwtypes.h"

/* Type Definitions */
#ifndef typedef_cell_wrap_3
#define typedef_cell_wrap_3

typedef struct {
  unsigned int f1[8];
} cell_wrap_3;

#endif                                 /*typedef_cell_wrap_3*/

#ifndef struct_emxArray_real32_T
#define struct_emxArray_real32_T

struct emxArray_real32_T
{
  float *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_real32_T*/

#ifndef typedef_emxArray_real32_T
#define typedef_emxArray_real32_T

typedef struct emxArray_real32_T emxArray_real32_T;

#endif                                 /*typedef_emxArray_real32_T*/

#ifndef struct_sfwI8zOKrNsirWOkLmXxW2D_tag
#define struct_sfwI8zOKrNsirWOkLmXxW2D_tag

struct sfwI8zOKrNsirWOkLmXxW2D_tag
{
  emxArray_real32_T *f1;
};

#endif                                 /*struct_sfwI8zOKrNsirWOkLmXxW2D_tag*/

#ifndef typedef_cell_wrap_62
#define typedef_cell_wrap_62

typedef struct sfwI8zOKrNsirWOkLmXxW2D_tag cell_wrap_62;

#endif                                 /*typedef_cell_wrap_62*/

#ifndef struct_emxArray_boolean_T
#define struct_emxArray_boolean_T

struct emxArray_boolean_T
{
  boolean_T *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_boolean_T*/

#ifndef typedef_emxArray_boolean_T
#define typedef_emxArray_boolean_T

typedef struct emxArray_boolean_T emxArray_boolean_T;

#endif                                 /*typedef_emxArray_boolean_T*/

#ifndef struct_emxArray_int32_T
#define struct_emxArray_int32_T

struct emxArray_int32_T
{
  int *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_int32_T*/

#ifndef typedef_emxArray_int32_T
#define typedef_emxArray_int32_T

typedef struct emxArray_int32_T emxArray_int32_T;

#endif                                 /*typedef_emxArray_int32_T*/

#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T

struct emxArray_real_T
{
  double *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_real_T*/

#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T

typedef struct emxArray_real_T emxArray_real_T;

#endif                                 /*typedef_emxArray_real_T*/

#ifndef struct_emxArray_uint8_T
#define struct_emxArray_uint8_T

struct emxArray_uint8_T
{
  unsigned char *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_uint8_T*/

#ifndef typedef_emxArray_uint8_T
#define typedef_emxArray_uint8_T

typedef struct emxArray_uint8_T emxArray_uint8_T;

#endif                                 /*typedef_emxArray_uint8_T*/

#ifndef typedef_vision_CascadeObjectDetector
#define typedef_vision_CascadeObjectDetector

typedef struct {
  boolean_T matlabCodegenIsDeleted;
  int isInitialized;
  boolean_T isSetupComplete;
  boolean_T TunablePropsChanged;
  cell_wrap_3 inputVarSize[1];
  double ScaleFactor;
  double MergeThreshold;
  void * pCascadeClassifier;
} vision_CascadeObjectDetector;

#endif                                 /*typedef_vision_CascadeObjectDetector*/

#ifndef struct_vision_MarkerInserter_9
#define struct_vision_MarkerInserter_9

struct vision_MarkerInserter_9
{
  int S0_isInitialized;
  int P0_RTP_SIZE;
};

#endif                                 /*struct_vision_MarkerInserter_9*/

#ifndef typedef_vision_MarkerInserter_9
#define typedef_vision_MarkerInserter_9

typedef struct vision_MarkerInserter_9 vision_MarkerInserter_9;

#endif                                 /*typedef_vision_MarkerInserter_9*/

#ifndef typedef_vision_PointTracker
#define typedef_vision_PointTracker

typedef struct {
  boolean_T matlabCodegenIsDeleted;
  int isInitialized;
  boolean_T isSetupComplete;
  cell_wrap_3 inputVarSize[1];
  void * pTracker;
  double FrameSize[2];
  double NumPoints;
  boolean_T IsRGB;
  double FrameClassID;
} vision_PointTracker;

#endif                                 /*typedef_vision_PointTracker*/

#ifndef struct_vision_ShapeInserter_3
#define struct_vision_ShapeInserter_3

struct vision_ShapeInserter_3
{
  int S0_isInitialized;
  int W0_DW_Polygon[72];
  unsigned char W1_DW_PixCount[640];
  int W2_DW_Points[16];
  int P0_RTP_LINEWIDTH;
};

#endif                                 /*struct_vision_ShapeInserter_3*/

#ifndef typedef_vision_ShapeInserter_3
#define typedef_vision_ShapeInserter_3

typedef struct vision_ShapeInserter_3 vision_ShapeInserter_3;

#endif                                 /*typedef_vision_ShapeInserter_3*/

#ifndef struct_s2EJQnOHHYP6arwQ3XTQc2C_tag
#define struct_s2EJQnOHHYP6arwQ3XTQc2C_tag

struct s2EJQnOHHYP6arwQ3XTQc2C_tag
{
  emxArray_real32_T *pLocation;
  emxArray_real32_T *pMetric;
};

#endif                                 /*struct_s2EJQnOHHYP6arwQ3XTQc2C_tag*/

#ifndef typedef_vision_internal_cornerPoints_cg
#define typedef_vision_internal_cornerPoints_cg

typedef struct s2EJQnOHHYP6arwQ3XTQc2C_tag vision_internal_cornerPoints_cg;

#endif                                 /*typedef_vision_internal_cornerPoints_cg*/

#ifndef typedef_visioncodegen_MarkerInserter
#define typedef_visioncodegen_MarkerInserter

typedef struct {
  boolean_T matlabCodegenIsDeleted;
  int isInitialized;
  boolean_T isSetupComplete;
  vision_MarkerInserter_9 cSFunObject;
  double Size;
} visioncodegen_MarkerInserter;

#endif                                 /*typedef_visioncodegen_MarkerInserter*/

#ifndef typedef_visioncodegen_ShapeInserter
#define typedef_visioncodegen_ShapeInserter

typedef struct {
  boolean_T matlabCodegenIsDeleted;
  int isInitialized;
  boolean_T isSetupComplete;
  vision_ShapeInserter_3 cSFunObject;
  double LineWidth;
} visioncodegen_ShapeInserter;

#endif                                 /*typedef_visioncodegen_ShapeInserter*/
#endif

/*
 * File trailer for faceTrackingARMKernel_types.h
 *
 * [EOF]
 */
