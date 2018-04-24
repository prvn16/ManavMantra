/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * visionRecovertformCodeGeneration_kernel_types.h
 *
 * Code generation for function 'visionRecovertformCodeGeneration_kernel'
 *
 */

#ifndef VISIONRECOVERTFORMCODEGENERATION_KERNEL_TYPES_H
#define VISIONRECOVERTFORMCODEGENERATION_KERNEL_TYPES_H

/* Include files */
#include "rtwtypes.h"

/* Type Definitions */
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

#ifndef struct_sfwI8zOKrNsirWOkLmXxW2D_tag
#define struct_sfwI8zOKrNsirWOkLmXxW2D_tag

struct sfwI8zOKrNsirWOkLmXxW2D_tag
{
  emxArray_real32_T *f1;
};

#endif                                 /*struct_sfwI8zOKrNsirWOkLmXxW2D_tag*/

#ifndef typedef_cell_wrap_26
#define typedef_cell_wrap_26

typedef struct sfwI8zOKrNsirWOkLmXxW2D_tag cell_wrap_26;

#endif                                 /*typedef_cell_wrap_26*/

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

#ifndef struct_emxArray_int8_T
#define struct_emxArray_int8_T

struct emxArray_int8_T
{
  int8_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_int8_T*/

#ifndef typedef_emxArray_int8_T
#define typedef_emxArray_int8_T

typedef struct emxArray_int8_T emxArray_int8_T;

#endif                                 /*typedef_emxArray_int8_T*/

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

#ifndef struct_emxArray_uint32_T
#define struct_emxArray_uint32_T

struct emxArray_uint32_T
{
  uint32_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_uint32_T*/

#ifndef typedef_emxArray_uint32_T
#define typedef_emxArray_uint32_T

typedef struct emxArray_uint32_T emxArray_uint32_T;

#endif                                 /*typedef_emxArray_uint32_T*/

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

#include <stdlib.h>
#ifndef struct_sLwtwpsYQ0YURdtS4ntXANH_tag
#define struct_sLwtwpsYQ0YURdtS4ntXANH_tag

struct sLwtwpsYQ0YURdtS4ntXANH_tag
{
  emxArray_real32_T *pLocation;
  emxArray_real32_T *pMetric;
  emxArray_real32_T *pScale;
  emxArray_int8_T *pSignOfLaplacian;
  emxArray_real32_T *pOrientation;
};

#endif                                 /*struct_sLwtwpsYQ0YURdtS4ntXANH_tag*/

#ifndef typedef_vision_internal_SURFPoints_cg
#define typedef_vision_internal_SURFPoints_cg

typedef struct sLwtwpsYQ0YURdtS4ntXANH_tag vision_internal_SURFPoints_cg;

#endif                                 /*typedef_vision_internal_SURFPoints_cg*/
#endif

/* End of code generation (visionRecovertformCodeGeneration_kernel_types.h) */
