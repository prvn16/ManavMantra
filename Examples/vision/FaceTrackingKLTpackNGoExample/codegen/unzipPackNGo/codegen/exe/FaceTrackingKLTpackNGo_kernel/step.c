/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: step.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "step.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void b_Constructor(vision_VideoFileReader_0 **obj);

/* Function Definitions */

/*
 * Arguments    : vision_VideoFileReader_0 **obj
 * Return Type  : void
 */
static void b_Constructor(vision_VideoFileReader_0 **obj)
{
  /* System object Constructor function: vision.VideoFileReader */
  (*obj)->S0_isInitialized = 0;
  (*obj)->P0_PLUGIN_PATH = 0U;
  (*obj)->P1_CONVERTER_PATH = 0U;
  (*obj)->O2_Y2 = false;
}

/*
 * Arguments    : vision_VideoFileReader_0 *obj
 * Return Type  : vision_VideoFileReader_0 *
 */
vision_VideoFileReader_0 *Constructor(vision_VideoFileReader_0 *obj)
{
  vision_VideoFileReader_0 *b_obj;
  b_obj = obj;
  b_Constructor(&b_obj);
  return b_obj;
}

/*
 * Arguments    : vision_VideoFileReader_0 *obj
 * Return Type  : void
 */
void InitializeConditions(vision_VideoFileReader_0 *obj)
{
  /* System object Initialization function: vision.VideoFileReader */
  obj->O1_Y1 = false;
  obj->O2_Y2 = false;
  obj->W3_LoopCount = 0U;
  LibReset(&obj->W0_HostLib[0U]);
}

/*
 * Arguments    : vision_VideoFileReader_0 *obj
 *                float Y0[921600]
 *                boolean_T *Y1
 *                boolean_T *Y2
 * Return Type  : void
 */
void Outputs(vision_VideoFileReader_0 *obj, float Y0[921600], boolean_T *Y1,
             boolean_T *Y2)
{
  char *sErr;
  void *source_R;

  /* System object Outputs function: vision.VideoFileReader */
  sErr = GetErrorBuffer(&obj->W0_HostLib[0U]);
  source_R = (void *)&Y0[0U];
  LibOutputs_FromMMFile(&obj->W0_HostLib[0U], (void *)&obj->O1_Y1,
                        GetNullPointer(), source_R, GetNullPointer(),
                        GetNullPointer());
  if (obj->O1_Y1) {
    obj->W3_LoopCount++;
    obj->O2_Y2 = !(obj->W3_LoopCount < 1U);
  }

  if (*sErr != 0) {
    PrintError(sErr);
  }

  *Y1 = obj->O1_Y1;
  *Y2 = obj->O2_Y2;
}

/*
 * Arguments    : vision_VideoFileReader_0 *obj
 * Return Type  : void
 */
void Start(vision_VideoFileReader_0 *obj)
{
  char *sErr;

  /* System object Start function: vision.VideoFileReader */
  sErr = GetErrorBuffer(&obj->W0_HostLib[0U]);
  CreateHostLibrary("frommmfile.dll", &obj->W0_HostLib[0U]);
  createAudioInfo(&obj->W1_AudioInfo[0U], 0U, 0U, 0.0, 0, 0, 0, 0,
                  GetNullPointer());
  createVideoInfo(&obj->W2_VideoInfo[0U], 1U, 30.0, 30.00003000003, "RGB ", 1, 3,
                  640, 480, 0U, 1, 1, GetNullPointer());
  if (*sErr == 0) {
    LibCreate_FromMMFile(&obj->W0_HostLib[0U], 0, (void *)
                         "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\visiondata\\tilted_face.avi",
                         1, "", "", &obj->W1_AudioInfo[0U], &obj->W2_VideoInfo
                         [0U], 0U, 0U, 1U, 0U, 0U, 1U);
  }

  if (*sErr == 0) {
    LibStart(&obj->W0_HostLib[0U]);
  }

  if (*sErr != 0) {
    DestroyHostLibrary(&obj->W0_HostLib[0U]);
    if (*sErr != 0) {
      PrintError(sErr);
    }
  }
}

/*
 * File trailer for step.c
 *
 * [EOF]
 */
