/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: SystemCore.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceDetectionARMKernel.h"
#include "SystemCore.h"
#include "ShapeInserter.h"

/* Function Definitions */

/*
 * Arguments    : visioncodegen_ShapeInserter *obj
 *                const unsigned char varargin_1[921600]
 *                const int varargin_2_data[]
 *                const int varargin_2_size[2]
 *                const unsigned char varargin_3_data[]
 *                const int varargin_3_size[2]
 *                unsigned char varargout_1[921600]
 * Return Type  : void
 */
void SystemCore_step(visioncodegen_ShapeInserter *obj, const unsigned char
                     varargin_1[921600], const int varargin_2_data[], const int
                     varargin_2_size[2], const unsigned char varargin_3_data[],
                     const int varargin_3_size[2], unsigned char varargout_1
                     [921600])
{
  if (obj->isInitialized != 1) {
    obj->isSetupComplete = false;
    obj->isInitialized = 1;
    obj->isSetupComplete = true;
  }

  memcpy(&varargout_1[0], &varargin_1[0], 921600U * sizeof(unsigned char));
  ShapeInserter_outputImpl(obj, varargout_1, varargin_2_data, varargin_2_size,
    varargin_3_data, varargin_3_size);
}

/*
 * File trailer for SystemCore.c
 *
 * [EOF]
 */
