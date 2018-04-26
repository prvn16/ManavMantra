/*
 * cgen_fi.c
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "cgen_fi".
 *
 * Model version              : 1.3
 * Simulink Coder version : 8.14 (R2018a) 06-Feb-2018
 * C source code generated on : Thu Apr 26 13:32:58 2018
 *
 * Target selection: grt.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "cgen_fi.h"
#include "cgen_fi_private.h"

/* Block signals (default storage) */
B_cgen_fi_T cgen_fi_B;

/* Block states (default storage) */
DW_cgen_fi_T cgen_fi_DW;

/* Real-time model */
RT_MODEL_cgen_fi_T cgen_fi_M_;
RT_MODEL_cgen_fi_T *const cgen_fi_M = &cgen_fi_M_;

/* Model step function */
void cgen_fi_step(void)
{
  /* local block i/o variables */
  int16_T rtb_zf[13];
  int32_T k;
  int32_T c;
  int16_T tmp[13];
  int32_T b_k;
  int16_T tmp_0;

  /* ToWorkspace: '<Root>/Noisy x' incorporates:
   *  Constant: '<Root>/Constant1'
   */
  rt_UpdateLogVar((LogVar *)(LogVar*) (cgen_fi_DW.Noisyx_PWORK.LoggedData),
                  &cgen_fi_P.Constant1_Value[0], 0);

  /* MATLAB Function: '<Root>/FIR' incorporates:
   *  Constant: '<Root>/Constant'
   *  Constant: '<Root>/Constant1'
   *  Constant: '<Root>/Constant2'
   */
  for (c = 0; c < 13; c++) {
    rtb_zf[c] = cgen_fi_P.zi[c];
  }

  for (k = 0; k < 4001; k++) {
    tmp_0 = (int16_T)(cgen_fi_P.Constant1_Value[k] >> 8);
    tmp[0] = (int16_T)((tmp_0 & 2048U) != 0U ? (int32_T)(int16_T)(tmp_0 | -2048)
                       : (int32_T)(int16_T)(tmp_0 & 2047));
    for (c = 0; c < 12; c++) {
      tmp_0 = (int16_T)(rtb_zf[c] << 8);
      tmp_0 = (int16_T)(((tmp_0 & 2048U) != 0U ? (int32_T)(int16_T)(tmp_0 |
        -2048) : (int32_T)(int16_T)(tmp_0 & 2047)) >> 8);
      tmp[c + 1] = (int16_T)((tmp_0 & 2048U) != 0U ? (int32_T)(int16_T)(tmp_0 |
        -2048) : (int32_T)(int16_T)(tmp_0 & 2047));
    }

    c = 0;
    for (b_k = 0; b_k < 13; b_k++) {
      rtb_zf[b_k] = tmp[b_k];
      c += cgen_fi_P.b[b_k] * rtb_zf[b_k];
    }

    tmp_0 = (int16_T)(c >> 4);
    cgen_fi_B.yout[k] = (int16_T)((tmp_0 & 2048U) != 0U ? (int32_T)(int16_T)
      (tmp_0 | -2048) : (int32_T)(int16_T)(tmp_0 & 2047));
  }

  /* End of MATLAB Function: '<Root>/FIR' */

  /* ToWorkspace: '<Root>/To Workspace' */
  rt_UpdateLogVar((LogVar *)(LogVar*) (cgen_fi_DW.ToWorkspace_PWORK.LoggedData),
                  &cgen_fi_B.yout[0], 0);

  /* ToWorkspace: '<Root>/To Workspace1' */
  rt_UpdateLogVar((LogVar *)(LogVar*) (cgen_fi_DW.ToWorkspace1_PWORK.LoggedData),
                  &rtb_zf[0], 0);

  /* Matfile logging */
  rt_UpdateTXYLogVars(cgen_fi_M->rtwLogInfo, (&cgen_fi_M->Timing.taskTime0));

  /* signal main to stop simulation */
  {                                    /* Sample time: [1.0s, 0.0s] */
    if ((rtmGetTFinal(cgen_fi_M)!=-1) &&
        !((rtmGetTFinal(cgen_fi_M)-cgen_fi_M->Timing.taskTime0) >
          cgen_fi_M->Timing.taskTime0 * (DBL_EPSILON))) {
      rtmSetErrorStatus(cgen_fi_M, "Simulation finished");
    }
  }

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  if (!(++cgen_fi_M->Timing.clockTick0)) {
    ++cgen_fi_M->Timing.clockTickH0;
  }

  cgen_fi_M->Timing.taskTime0 = cgen_fi_M->Timing.clockTick0 *
    cgen_fi_M->Timing.stepSize0 + cgen_fi_M->Timing.clockTickH0 *
    cgen_fi_M->Timing.stepSize0 * 4294967296.0;
}

/* Model initialize function */
void cgen_fi_initialize(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)cgen_fi_M, 0,
                sizeof(RT_MODEL_cgen_fi_T));
  rtmSetTFinal(cgen_fi_M, 0.0);
  cgen_fi_M->Timing.stepSize0 = 1.0;

  /* Setup for data logging */
  {
    static RTWLogInfo rt_DataLoggingInfo;
    rt_DataLoggingInfo.loggingInterval = NULL;
    cgen_fi_M->rtwLogInfo = &rt_DataLoggingInfo;
  }

  /* Setup for data logging */
  {
    rtliSetLogXSignalInfo(cgen_fi_M->rtwLogInfo, (NULL));
    rtliSetLogXSignalPtrs(cgen_fi_M->rtwLogInfo, (NULL));
    rtliSetLogT(cgen_fi_M->rtwLogInfo, "tout");
    rtliSetLogX(cgen_fi_M->rtwLogInfo, "");
    rtliSetLogXFinal(cgen_fi_M->rtwLogInfo, "");
    rtliSetLogVarNameModifier(cgen_fi_M->rtwLogInfo, "rt_");
    rtliSetLogFormat(cgen_fi_M->rtwLogInfo, 4);
    rtliSetLogMaxRows(cgen_fi_M->rtwLogInfo, 0);
    rtliSetLogDecimation(cgen_fi_M->rtwLogInfo, 1);
    rtliSetLogY(cgen_fi_M->rtwLogInfo, "");
    rtliSetLogYSignalInfo(cgen_fi_M->rtwLogInfo, (NULL));
    rtliSetLogYSignalPtrs(cgen_fi_M->rtwLogInfo, (NULL));
  }

  /* states (dwork) */
  (void) memset((void *)&cgen_fi_DW, 0,
                sizeof(DW_cgen_fi_T));

  /* Matfile logging */
  rt_StartDataLoggingWithStartTime(cgen_fi_M->rtwLogInfo, 0.0, rtmGetTFinal
    (cgen_fi_M), cgen_fi_M->Timing.stepSize0, (&rtmGetErrorStatus(cgen_fi_M)));

  /* Start for ToWorkspace: '<Root>/Noisy x' incorporates:
   *  Constant: '<Root>/Constant1'
   */
  {
    int_T dimensions[2] = { 4001, 1 };

    static RTWLogDataTypeConvert rt_ToWksDataTypeConvert[] = {
      { 1, SS_DOUBLE, SS_INT16, 32, 1, 1, 1.0, -8, 0.0 }
    };

    cgen_fi_DW.Noisyx_PWORK.LoggedData = rt_CreateLogVarWithConvert(
      cgen_fi_M->rtwLogInfo,
      0.0,
      rtmGetTFinal(cgen_fi_M),
      cgen_fi_M->Timing.stepSize0,
      (&rtmGetErrorStatus(cgen_fi_M)),
      "noisyx",
      SS_DOUBLE,
      rt_ToWksDataTypeConvert,
      0,
      0,
      0,
      4001,
      2,
      dimensions,
      NO_LOGVALDIMS,
      (NULL),
      (NULL),
      0,
      1,
      1.0,
      1);
    if (cgen_fi_DW.Noisyx_PWORK.LoggedData == (NULL))
      return;
  }

  /* Start for ToWorkspace: '<Root>/To Workspace' */
  {
    int_T dimensions[1] = { 4001 };

    static RTWLogDataTypeConvert rt_ToWksDataTypeConvert[] = {
      { 1, SS_DOUBLE, SS_INT16, 32, 1, 1, 1.0, -8, 0.0 }
    };

    cgen_fi_DW.ToWorkspace_PWORK.LoggedData = rt_CreateLogVarWithConvert(
      cgen_fi_M->rtwLogInfo,
      0.0,
      rtmGetTFinal(cgen_fi_M),
      cgen_fi_M->Timing.stepSize0,
      (&rtmGetErrorStatus(cgen_fi_M)),
      "yout",
      SS_DOUBLE,
      rt_ToWksDataTypeConvert,
      0,
      0,
      0,
      4001,
      1,
      dimensions,
      NO_LOGVALDIMS,
      (NULL),
      (NULL),
      0,
      1,
      1.0,
      1);
    if (cgen_fi_DW.ToWorkspace_PWORK.LoggedData == (NULL))
      return;
  }

  /* Start for ToWorkspace: '<Root>/To Workspace1' */
  {
    int_T dimensions[1] = { 13 };

    static RTWLogDataTypeConvert rt_ToWksDataTypeConvert[] = {
      { 1, SS_DOUBLE, SS_INT16, 32, 1, 1, 1.0, 0, 0.0 }
    };

    cgen_fi_DW.ToWorkspace1_PWORK.LoggedData = rt_CreateLogVarWithConvert(
      cgen_fi_M->rtwLogInfo,
      0.0,
      rtmGetTFinal(cgen_fi_M),
      cgen_fi_M->Timing.stepSize0,
      (&rtmGetErrorStatus(cgen_fi_M)),
      "zf",
      SS_DOUBLE,
      rt_ToWksDataTypeConvert,
      0,
      0,
      0,
      13,
      1,
      dimensions,
      NO_LOGVALDIMS,
      (NULL),
      (NULL),
      0,
      1,
      1.0,
      1);
    if (cgen_fi_DW.ToWorkspace1_PWORK.LoggedData == (NULL))
      return;
  }
}

/* Model terminate function */
void cgen_fi_terminate(void)
{
  /* (no terminate code required) */
}
