/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * insertShape.c
 *
 * Code generation for function 'insertShape'
 *
 */

/* Include files */
#include <string.h>
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "insertShape.h"
#include "matlabCodegenHandle.h"
#include "SystemCore.h"
#include "repmat.h"
#include "validatesize.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo bq_emlrtRSI = { 99, /* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo cq_emlrtRSI = { 114,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo dq_emlrtRSI = { 123,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo eq_emlrtRSI = { 125,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo fq_emlrtRSI = { 248,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo gq_emlrtRSI = { 250,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo hq_emlrtRSI = { 256,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo iq_emlrtRSI = { 310,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo jq_emlrtRSI = { 363,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo kq_emlrtRSI = { 561,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo lq_emlrtRSI = { 392,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo mq_emlrtRSI = { 408,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo pq_emlrtRSI = { 729,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo qq_emlrtRSI = { 774,/* lineNo */
  "insertShape",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pathName */
};

static emlrtRSInfo rq_emlrtRSI = { 61, /* lineNo */
  "createShapeInserter_cg",            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+textngraphics\\createShapeInserter_cg.m"/* pathName */
};

static emlrtRTEInfo eg_emlrtRTEI = { 876,/* lineNo */
  1,                                   /* colNo */
  "insertShape",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertShape.m"/* pName */
};

/* Function Declarations */
static void b_validateAndParseInputs(const emlrtStack *sp, const int32_T
  position_size[2], uint8_T varargin_4_data[], int32_T varargin_4_size[2]);
static visioncodegen_ShapeInserter *getSystemObjects(const emlrtStack *sp);
static void tuneLineWidth(visioncodegen_ShapeInserter *h_ShapeInserter);

/* Function Definitions */
static void b_validateAndParseInputs(const emlrtStack *sp, const int32_T
  position_size[2], uint8_T varargin_4_data[], int32_T varargin_4_size[2])
{
  boolean_T errCond;
  real_T position[2];
  int32_T loop_ub;
  uint8_T b_varargin_4_data[3];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &fq_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  b_st.site = &iq_emlrtRSI;
  c_st.site = &jq_emlrtRSI;
  d_st.site = &kq_emlrtRSI;
  e_st.site = &ic_emlrtRSI;
  if (!size_check(varargin_4_size)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &dg_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:insertShape:incorrectSize", 3, 4, 5, "Color");
  }

  st.site = &gq_emlrtRSI;
  b_st.site = &lq_emlrtRSI;
  if ((varargin_4_size[0] != 1) && (position_size[0] != varargin_4_size[0])) {
    errCond = true;
  } else {
    errCond = false;
  }

  c_st.site = &mq_emlrtRSI;
  if (errCond) {
    emlrtErrorWithMessageIdR2018a(&c_st, &eg_emlrtRTEI,
      "vision:insertShape:invalidNumPosMatrixNumColor",
      "vision:insertShape:invalidNumPosMatrixNumColor", 0);
  }

  st.site = &hq_emlrtRSI;
  if (varargin_4_size[0] == 1) {
    position[0] = position_size[0];
    position[1] = 1.0;
    loop_ub = varargin_4_size[0] * varargin_4_size[1];
    if (0 <= loop_ub - 1) {
      memcpy(&b_varargin_4_data[0], &varargin_4_data[0], (uint32_T)(loop_ub *
              (int32_T)sizeof(uint8_T)));
    }

    b_st.site = &nq_emlrtRSI;
    b_repmat(&b_st, b_varargin_4_data, position, varargin_4_data,
             varargin_4_size);
  }
}

static visioncodegen_ShapeInserter *getSystemObjects(const emlrtStack *sp)
{
  visioncodegen_ShapeInserter *obj;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &pq_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &qq_emlrtRSI;
  if (!h3111_not_empty) {
    obj = &h3111;
    h3111.isInitialized = 0;
    h3111.c_NoTuningBeforeLockingCodeGenE = true;

    /* System object Constructor function: vision.ShapeInserter */
    obj->cSFunObject.P0_RTP_LINEWIDTH = 1;
    h3111.LineWidth = 1.0;
    h3111.c_NoTuningBeforeLockingCodeGenE = false;
    h3111.matlabCodegenIsDeleted = false;
    h3111_not_empty = true;
    c_st.site = &rq_emlrtRSI;
    obj = &h3111;
    h3111.isSetupComplete = false;
    if (h3111.isInitialized != 0) {
      emlrtErrorWithMessageIdR2018a(&c_st, &oe_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen",
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    obj->isInitialized = 1;
    obj->c_NoTuningBeforeLockingCodeGenE = true;
    obj->isSetupComplete = true;
  }

  return &h3111;
}

static void tuneLineWidth(visioncodegen_ShapeInserter *h_ShapeInserter)
{
  if (1.0 != h_ShapeInserter->LineWidth) {
    h_ShapeInserter->cSFunObject.P0_RTP_LINEWIDTH = 1;
    h_ShapeInserter->LineWidth = 1.0;
  }
}

void insertShape(e_depthEstimationFromStereoVide *SD, const emlrtStack *sp,
                 const uint8_T I[1108698], const int32_T position_data[], const
                 int32_T position_size[2], const uint8_T varargin_4_data[],
                 const int32_T varargin_4_size[2], uint8_T RGB[1108698])
{
  int32_T positionOut_size[2];
  int32_T loop_ub;
  int32_T positionOut_data[396];
  int32_T color_size[2];
  uint8_T color_data[297];
  visioncodegen_ShapeInserter *h_ShapeInserter;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  memcpy(&SD->u1.f0.tmpRGB[0], &I[0], 1108698U * sizeof(uint8_T));
  positionOut_size[0] = position_size[0];
  positionOut_size[1] = 4;
  loop_ub = position_size[0] * position_size[1];
  if (0 <= loop_ub - 1) {
    memcpy(&positionOut_data[0], &position_data[0], (uint32_T)(loop_ub *
            (int32_T)sizeof(int32_T)));
  }

  color_size[0] = varargin_4_size[0];
  color_size[1] = 3;
  loop_ub = varargin_4_size[0] * varargin_4_size[1];
  if (0 <= loop_ub - 1) {
    memcpy(&color_data[0], &varargin_4_data[0], (uint32_T)(loop_ub * (int32_T)
            sizeof(uint8_T)));
  }

  st.site = &bq_emlrtRSI;
  b_validateAndParseInputs(&st, positionOut_size, color_data, color_size);
  st.site = &cq_emlrtRSI;
  h_ShapeInserter = getSystemObjects(&st);
  st.site = &dq_emlrtRSI;
  tuneLineWidth(h_ShapeInserter);
  st.site = &eq_emlrtRSI;
  b_SystemCore_step(&st, h_ShapeInserter, SD->u1.f0.tmpRGB, positionOut_data,
                    positionOut_size, color_data, color_size, RGB);
}

/* End of code generation (insertShape.c) */
