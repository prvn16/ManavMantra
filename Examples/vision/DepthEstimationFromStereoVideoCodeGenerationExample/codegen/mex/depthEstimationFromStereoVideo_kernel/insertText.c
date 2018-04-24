/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * insertText.c
 *
 * Code generation for function 'insertText'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "insertText.h"
#include "matlabCodegenHandle.h"
#include "error.h"
#include "sum.h"
#include "bwtraceboundary.h"
#include "assertValidSizeArg.h"
#include "repmat.h"
#include "validatesize.h"
#include "all.h"
#include "depthEstimationFromStereoVideo_kernel_mexutil.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include <stdio.h>

/* Variable Definitions */
static emlrtRSInfo uq_emlrtRSI = { 126,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo wq_emlrtRSI = { 191,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo xq_emlrtRSI = { 195,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo yq_emlrtRSI = { 218,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo ar_emlrtRSI = { 225,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo br_emlrtRSI = { 239,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo cr_emlrtRSI = { 243,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo dr_emlrtRSI = { 244,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo er_emlrtRSI = { 245,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo fr_emlrtRSI = { 246,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo gr_emlrtRSI = { 247,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo hr_emlrtRSI = { 362,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo ir_emlrtRSI = { 329,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo jr_emlrtRSI = { 330,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo kr_emlrtRSI = { 581,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo lr_emlrtRSI = { 451,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo mr_emlrtRSI = { 455,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo nr_emlrtRSI = { 459,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo or_emlrtRSI = { 476,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo qr_emlrtRSI = { 1129,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo sr_emlrtRSI = { 881,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo tr_emlrtRSI = { 894,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo ur_emlrtRSI = { 896,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo vr_emlrtRSI = { 904,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo wr_emlrtRSI = { 908,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo xr_emlrtRSI = { 918,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo yr_emlrtRSI = { 919,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo as_emlrtRSI = { 931,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo bs_emlrtRSI = { 932,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo cs_emlrtRSI = { 41, /* lineNo */
  "find",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\find.m"/* pathName */
};

static emlrtRSInfo ds_emlrtRSI = { 153,/* lineNo */
  "find",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\find.m"/* pathName */
};

static emlrtRSInfo hs_emlrtRSI = { 1257,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtRSInfo is_emlrtRSI = { 1269,/* lineNo */
  "insertText",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pathName */
};

static emlrtBCInfo ue_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  155,                                 /* lineNo */
  28,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ve_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  192,                                 /* lineNo */
  26,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo we_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  193,                                 /* lineNo */
  26,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo xe_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  196,                                 /* lineNo */
  27,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ye_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  194,                                 /* lineNo */
  28,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo af_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  194,                                 /* lineNo */
  45,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo bf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  900,                                 /* lineNo */
  29,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo cf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  900,                                 /* lineNo */
  32,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo df_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  912,                                 /* lineNo */
  32,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ef_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  913,                                 /* lineNo */
  30,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ff_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  914,                                 /* lineNo */
  30,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo gf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  914,                                 /* lineNo */
  39,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo hf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  926,                                 /* lineNo */
  43,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo if_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  926,                                 /* lineNo */
  28,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo jf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  926,                                 /* lineNo */
  51,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRTEInfo xf_emlrtRTEI = { 387,/* lineNo */
  1,                                   /* colNo */
  "find",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\find.m"/* pName */
};

static emlrtRTEInfo gg_emlrtRTEI = { 1311,/* lineNo */
  1,                                   /* colNo */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m"/* pName */
};

static emlrtBCInfo yf_emlrtBCI = { 1,  /* iFirst */
  9304,                                /* iLast */
  1255,                                /* lineNo */
  59,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ag_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1197,                                /* lineNo */
  34,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo bg_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1191,                                /* lineNo */
  22,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo cg_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1408,                                /* lineNo */
  35,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo dg_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1408,                                /* lineNo */
  45,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo eg_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1408,                                /* lineNo */
  54,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo fg_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1408,                                /* lineNo */
  64,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo gg_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1416,                                /* lineNo */
  40,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo hg_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1416,                                /* lineNo */
  43,                                  /* colNo */
  "",                                  /* aName */
  "insertText",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\insertText.m",/* pName */
  0                                    /* checkKind */
};

static const int8_T iv0[261] = { 9, 0, 0, 4, 4, 4, 8, 8, 8, 8, 3, 4, 4, 6, 10, 4,
  7, 4, 6, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 4, 4, 10, 10, 10, 5, 10, 8, 7, 8, 9, 7,
  6, 9, 9, 3, 4, 8, 6, 10, 9, 9, 7, 9, 8, 6, 8, 8, 8, 10, 8, 7, 7, 4, 6, 4, 8, 6,
  7, 7, 8, 6, 8, 7, 4, 7, 7, 3, 4, 7, 3, 11, 7, 7, 8, 8, 5, 6, 4, 7, 6, 9, 7, 6,
  7, 4, 4, 4, 8, 8, 8, 8, 7, 9, 9, 8, 7, 7, 7, 7, 7, 7, 6, 7, 7, 7, 7, 3, 3, 3,
  3, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 5, 8, 8, 8, 0, 8, 7, 8, 10, 0, 7, 7, 0, 11,
  9, 0, 10, 0, 0, 8, 8, 0, 0, 0, 0, 0, 6, 6, 0, 10, 7, 5, 4, 10, 0, 0, 0, 0, 6,
  6, 0, 4, 8, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 6, 0, 0, 8, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 8, 7, 8, 7, 7, 3, 3, 3, 3, 9, 9, 0, 9, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0,
  7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 9, 7, 7, 6, 7, 8, 0, 10, 5, 5, 5, 10, 10, 10,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 6, 4 };

static const uint16_T uv0[256] = { 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
  0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
  0U, 3U, 4U, 5U, 6U, 7U, 8U, 9U, 10U, 11U, 12U, 13U, 14U, 15U, 16U, 17U, 18U,
  19U, 20U, 21U, 22U, 23U, 24U, 25U, 26U, 27U, 28U, 29U, 30U, 31U, 32U, 33U, 34U,
  35U, 36U, 37U, 38U, 39U, 40U, 41U, 42U, 43U, 44U, 45U, 46U, 47U, 48U, 49U, 50U,
  51U, 52U, 53U, 54U, 55U, 56U, 57U, 58U, 59U, 60U, 61U, 62U, 63U, 64U, 65U, 66U,
  67U, 68U, 69U, 70U, 71U, 72U, 73U, 74U, 75U, 76U, 77U, 78U, 79U, 80U, 81U, 82U,
  83U, 84U, 85U, 86U, 87U, 88U, 89U, 90U, 91U, 92U, 93U, 94U, 95U, 96U, 97U, 0U,
  0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
  0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 172U, 163U, 132U, 133U, 189U,
  150U, 232U, 134U, 142U, 139U, 157U, 169U, 164U, 258U, 138U, 259U, 131U, 147U,
  242U, 243U, 141U, 151U, 136U, 260U, 222U, 241U, 158U, 170U, 245U, 244U, 246U,
  162U, 173U, 201U, 199U, 174U, 98U, 99U, 144U, 100U, 203U, 101U, 200U, 202U,
  207U, 204U, 205U, 206U, 233U, 102U, 211U, 208U, 209U, 175U, 103U, 240U, 145U,
  214U, 212U, 213U, 104U, 235U, 237U, 137U, 106U, 105U, 107U, 109U, 108U, 110U,
  160U, 111U, 113U, 112U, 114U, 115U, 117U, 116U, 118U, 119U, 234U, 120U, 122U,
  121U, 123U, 125U, 124U, 184U, 161U, 127U, 126U, 128U, 129U, 236U, 238U, 186U };

/* Function Declarations */
static void c_validateAndParseInputs(const emlrtStack *sp, const int32_T
  position_size[2], const real32_T text_data[], const int32_T text_size[2],
  uint8_T varargin_6_data[], int32_T varargin_6_size[2], uint8_T
  varargin_8_data[], int32_T varargin_8_size[2], const int32_T varargin_14_data[],
  const int32_T varargin_14_size[1], const int32_T varargin_16_data[], const
  int32_T varargin_16_size[1], boolean_T *isScalarText, int32_T shapeWidth_data[],
  int32_T shapeWidth_size[2], int32_T shapeHeight_data[], int32_T
  shapeHeight_size[2], boolean_T *isEmpty);
static void doGlyph_uint8(const emlrtStack *sp, uint8_T imgIn[1108698], const
  uint8_T thisGlyphBitmap_data[], const int32_T thisGlyphBitmap_size[2], int32_T
  imgIdx_startR_im, int32_T imgIdx_startC_im, int32_T imgIdx_endR_im, int32_T
  imgIdx_endC_im, int32_T glIdx_startR_gl, int32_T glIdx_startC_gl, int32_T
  glIdx_endR_gl, int32_T glIdx_endC_gl);
static void getShapeDimMatrix(const emlrtStack *sp, const int32_T shapeDim_data[],
  const int32_T shapeDim_size[1], real_T numPos, int32_T shapeDimOut_data[],
  int32_T shapeDimOut_size[2]);
static void getTextboxWidthHeight(const emlrtStack *sp, const uint16_T
  ucTextU16_data[], const int32_T ucTextU16_size[2], int32_T shapeWidth, int32_T
  *tbWidth, int32_T *tbHeight);
static void insertGlyphs(const emlrtStack *sp, uint8_T imgIn[1108698], const
  uint16_T ucTextU16_data[], const int32_T ucTextU16_size[2], int32_T
  textLocationXY_x, int32_T textLocationXY_y);
static void insertTextBox(const emlrtStack *sp, uint8_T RGB[1108698], const
  int32_T position[2], const uint16_T ucTextU16_data[], const int32_T
  ucTextU16_size[2], const uint8_T boxColor_data[], int32_T shapeWidth, int32_T
  shapeHeight, int32_T *textLocationXY_x, int32_T *textLocationXY_y);

/* Function Definitions */
static void c_validateAndParseInputs(const emlrtStack *sp, const int32_T
  position_size[2], const real32_T text_data[], const int32_T text_size[2],
  uint8_T varargin_6_data[], int32_T varargin_6_size[2], uint8_T
  varargin_8_data[], int32_T varargin_8_size[2], const int32_T varargin_14_data[],
  const int32_T varargin_14_size[1], const int32_T varargin_16_data[], const
  int32_T varargin_16_size[1], boolean_T *isScalarText, int32_T shapeWidth_data[],
  int32_T shapeWidth_size[2], int32_T shapeHeight_data[], int32_T
  shapeHeight_size[2], boolean_T *isEmpty)
{
  static real_T dv11[2] = { 0.0, 2.0 };

  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  real_T position[2];
  uint8_T b_varargin_6_data[3];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  dv11[0U] = rtNaN;
  st.site = &yq_emlrtRSI;
  b_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (muDoubleScalarIsNaN(dv11[k]) || (dv11[k] == position_size[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &dg_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:insertText:incorrectSize", 3, 4, 25, "Input number 2, POSITION,");
  }

  st.site = &ar_emlrtRSI;
  b_st.site = &hr_emlrtRSI;
  c_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= text_size[1] - 1)) {
    if (!muSingleScalarIsNaN(text_data[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&c_st, &xe_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:insertText:expectedNonNaN", 3, 4, 4, "TEXT");
  }

  c_st.site = &ic_emlrtRSI;
  p = b_all(text_data, text_size);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:insertText:expectedFinite", 3, 4, 4, "TEXT");
  }

  c_st.site = &ic_emlrtRSI;
  if (text_size[1] == 0) {
    emlrtErrorWithMessageIdR2018a(&c_st, &kf_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonempty",
      "MATLAB:insertText:expectedNonempty", 3, 4, 4, "TEXT");
  }

  *isEmpty = (position_size[0] == 0);
  st.site = &br_emlrtRSI;
  b_st.site = &ir_emlrtRSI;
  c_st.site = &kr_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  if (!size_check(varargin_6_size)) {
    emlrtErrorWithMessageIdR2018a(&d_st, &dg_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:insertText:incorrectSize", 3, 4, 9, "TextColor");
  }

  b_st.site = &jr_emlrtRSI;
  c_st.site = &kr_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  if (!size_check(varargin_8_size)) {
    emlrtErrorWithMessageIdR2018a(&d_st, &dg_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:insertText:incorrectSize", 3, 4, 8, "BoxColor");
  }

  st.site = &cr_emlrtRSI;
  if ((text_size[1] != 1) && (text_size[1] != position_size[0])) {
    p = true;
  } else {
    p = false;
  }

  b_st.site = &lr_emlrtRSI;
  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &gg_emlrtRTEI,
      "vision:insertText:invalidNumTexts", "vision:insertText:invalidNumTexts",
      0);
  }

  if ((varargin_8_size[0] != 1) && (position_size[0] != varargin_8_size[0])) {
    p = true;
  } else {
    p = false;
  }

  b_st.site = &mr_emlrtRSI;
  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &gg_emlrtRTEI,
      "vision:insertText:invalidNumPosNumBoxColor",
      "vision:insertText:invalidNumPosNumBoxColor", 0);
  }

  if ((varargin_6_size[0] != 1) && (position_size[0] != varargin_6_size[0])) {
    p = true;
  } else {
    p = false;
  }

  b_st.site = &nr_emlrtRSI;
  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &gg_emlrtRTEI,
      "vision:insertText:invalidNumPosNumTextColor",
      "vision:insertText:invalidNumPosNumTextColor", 0);
  }

  st.site = &dr_emlrtRSI;
  if (varargin_6_size[0] == 1) {
    position[0] = position_size[0];
    position[1] = 1.0;
    k = varargin_6_size[0] * varargin_6_size[1];
    if (0 <= k - 1) {
      memcpy(&b_varargin_6_data[0], &varargin_6_data[0], (uint32_T)(k * (int32_T)
              sizeof(uint8_T)));
    }

    b_st.site = &nq_emlrtRSI;
    b_repmat(&b_st, b_varargin_6_data, position, varargin_6_data,
             varargin_6_size);
  }

  st.site = &er_emlrtRSI;
  if (varargin_8_size[0] == 1) {
    position[0] = position_size[0];
    position[1] = 1.0;
    k = varargin_8_size[0] * varargin_8_size[1];
    if (0 <= k - 1) {
      memcpy(&b_varargin_6_data[0], &varargin_8_data[0], (uint32_T)(k * (int32_T)
              sizeof(uint8_T)));
    }

    b_st.site = &nq_emlrtRSI;
    b_repmat(&b_st, b_varargin_6_data, position, varargin_8_data,
             varargin_8_size);
  }

  st.site = &fr_emlrtRSI;
  getShapeDimMatrix(&st, varargin_14_data, varargin_14_size, position_size[0],
                    shapeWidth_data, shapeWidth_size);
  st.site = &gr_emlrtRSI;
  getShapeDimMatrix(&st, varargin_16_data, varargin_16_size, position_size[0],
                    shapeHeight_data, shapeHeight_size);
  *isScalarText = (text_size[1] == 1);
}

static void doGlyph_uint8(const emlrtStack *sp, uint8_T imgIn[1108698], const
  uint8_T thisGlyphBitmap_data[], const int32_T thisGlyphBitmap_size[2], int32_T
  imgIdx_startR_im, int32_T imgIdx_startC_im, int32_T imgIdx_endR_im, int32_T
  imgIdx_endC_im, int32_T glIdx_startR_gl, int32_T glIdx_startC_gl, int32_T
  glIdx_endR_gl, int32_T glIdx_endC_gl)
{
  int32_T i67;
  int32_T i68;
  int32_T i69;
  int32_T i70;
  int32_T idx;
  real_T cg;
  int32_T c;
  int32_T rg;
  int32_T r;
  int32_T i71;
  int32_T i72;
  uint16_T tmp1;
  uint16_T tmp3;
  if (glIdx_startR_gl > glIdx_endR_gl) {
    i67 = 1;
    i68 = 1;
  } else {
    if (!((glIdx_startR_gl >= 1) && (glIdx_startR_gl <= thisGlyphBitmap_size[0])))
    {
      emlrtDynamicBoundsCheckR2012b(glIdx_startR_gl, 1, thisGlyphBitmap_size[0],
        &cg_emlrtBCI, sp);
    }

    i67 = glIdx_startR_gl;
    if (!((glIdx_endR_gl >= 1) && (glIdx_endR_gl <= thisGlyphBitmap_size[0]))) {
      emlrtDynamicBoundsCheckR2012b(glIdx_endR_gl, 1, thisGlyphBitmap_size[0],
        &dg_emlrtBCI, sp);
    }

    i68 = glIdx_endR_gl + 1;
  }

  if (glIdx_startC_gl > glIdx_endC_gl) {
    i69 = -1;
    i70 = 1;
  } else {
    if (!((glIdx_startC_gl >= 1) && (glIdx_startC_gl <= thisGlyphBitmap_size[1])))
    {
      emlrtDynamicBoundsCheckR2012b(glIdx_startC_gl, 1, thisGlyphBitmap_size[1],
        &eg_emlrtBCI, sp);
    }

    i69 = glIdx_startC_gl - 2;
    if (!((glIdx_endC_gl >= 1) && (glIdx_endC_gl <= thisGlyphBitmap_size[1]))) {
      emlrtDynamicBoundsCheckR2012b(glIdx_endC_gl, 1, thisGlyphBitmap_size[1],
        &fg_emlrtBCI, sp);
    }

    i70 = glIdx_endC_gl + 1;
  }

  for (idx = 0; idx < 3; idx++) {
    cg = 1.0;
    for (c = imgIdx_startC_im - 1; c < imgIdx_endC_im; c++) {
      rg = -1;
      for (r = imgIdx_startR_im - 1; r < imgIdx_endR_im; r++) {
        i71 = i68 - i67;
        i72 = rg + 2;
        if (!((i72 >= 1) && (i72 <= i71))) {
          emlrtDynamicBoundsCheckR2012b(i72, 1, i71, &gg_emlrtBCI, sp);
        }

        i71 = (i70 - i69) - 2;
        i72 = (int32_T)cg;
        if (!((i72 >= 1) && (i72 <= i71))) {
          emlrtDynamicBoundsCheckR2012b(i72, 1, i71, &hg_emlrtBCI, sp);
        }

        if (thisGlyphBitmap_data[(i67 + rg) + thisGlyphBitmap_size[0] * (i69 +
             (int32_T)cg)] == 255) {
          imgIn[(r + 514 * c) + 369566 * idx] = 0U;
        } else {
          if (thisGlyphBitmap_data[(i67 + rg) + thisGlyphBitmap_size[0] * (i69 +
               (int32_T)cg)] != 0) {
            tmp1 = (uint16_T)(imgIn[(r + 514 * c) + 369566 * idx] * (255 -
              thisGlyphBitmap_data[(i67 + rg) + thisGlyphBitmap_size[0] * (i69 +
              (int32_T)cg)]));
            tmp3 = (uint16_T)(tmp1 / 255U);
            tmp1 = (uint16_T)((uint32_T)tmp1 - tmp3 * 255);
            if ((tmp1 > 0) && (tmp1 >= 128)) {
              tmp3++;
            }

            if (tmp3 > 255) {
              tmp3 = 255U;
            }

            imgIn[(r + 514 * c) + 369566 * idx] = (uint8_T)tmp3;
          }
        }

        rg++;
      }

      cg++;
    }
  }
}

static void getShapeDimMatrix(const emlrtStack *sp, const int32_T shapeDim_data[],
  const int32_T shapeDim_size[1], real_T numPos, int32_T shapeDimOut_data[],
  int32_T shapeDimOut_size[2])
{
  real_T varargin_1[2];
  int32_T loop_ub;
  const mxArray *y;
  const mxArray *m10;
  static const int32_T iv31[2] = { 1, 15 };

  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (shapeDim_size[0] == 1) {
    st.site = &or_emlrtRSI;
    varargin_1[0] = numPos;
    varargin_1[1] = 1.0;
    b_st.site = &ck_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    if ((int8_T)(int32_T)numPos != (int32_T)numPos) {
      y = NULL;
      m10 = emlrtCreateCharArray(2, iv31);
      emlrtInitCharArrayR2013a(&st, 15, m10, &cv1[0]);
      emlrtAssign(&y, m10);
      b_st.site = &qs_emlrtRSI;
      f_error(&b_st, y, &d_emlrtMCI);
    }

    shapeDimOut_size[0] = (int8_T)(int32_T)numPos;
    shapeDimOut_size[1] = 1;
    b_st.site = &aq_emlrtRSI;
    b_st.site = &yp_emlrtRSI;
    for (loop_ub = 1; loop_ub <= (int32_T)numPos; loop_ub++) {
      b_st.site = &do_emlrtRSI;
      shapeDimOut_data[loop_ub - 1] = shapeDim_data[0];
    }
  } else {
    shapeDimOut_size[0] = shapeDim_size[0];
    shapeDimOut_size[1] = 1;
    loop_ub = shapeDim_size[0];
    if (0 <= loop_ub - 1) {
      memcpy(&shapeDimOut_data[0], &shapeDim_data[0], (uint32_T)(loop_ub *
              (int32_T)sizeof(int32_T)));
    }
  }
}

static void getTextboxWidthHeight(const emlrtStack *sp, const uint16_T
  ucTextU16_data[], const int32_T ucTextU16_size[2], int32_T shapeWidth, int32_T
  *tbWidth, int32_T *tbHeight)
{
  int32_T nx;
  int32_T idx;
  boolean_T x_data[29];
  int32_T ii_size_idx_1;
  int32_T ii;
  boolean_T exitg1;
  int32_T ii_data[29];
  int32_T idxNewlineChar_data[29];
  int32_T tmp_size[2];
  uint32_T u0;
  uint16_T thisCharcodes_1b_data[29];
  real_T d1;
  int16_T tmp_data[29];
  real_T lenFirstSegment;
  int16_T b_tmp_data[28];
  int32_T b_tmp_size[2];
  real_T numMissingGlyph;
  boolean_T c_tmp_data[28];
  int32_T y;
  int32_T i;
  int32_T thisCharcodes_1b_size_idx_1;
  int32_T c_tmp_size[2];
  real_T lenEndSegment;
  int32_T d_tmp_size[2];
  int32_T e_tmp_size[2];
  int32_T f_tmp_size[2];
  int32_T varargin_1[3];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &sr_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  nx = ucTextU16_size[0] * ucTextU16_size[1];
  for (idx = 0; idx < nx; idx++) {
    x_data[idx] = (ucTextU16_data[idx] == 10);
  }

  b_st.site = &cs_emlrtRSI;
  nx = ucTextU16_size[1];
  c_st.site = &ds_emlrtRSI;
  idx = 0;
  ii_size_idx_1 = ucTextU16_size[1];
  ii = 1;
  exitg1 = false;
  while ((!exitg1) && (ii <= nx)) {
    if (x_data[ii - 1]) {
      idx++;
      ii_data[idx - 1] = ii;
      if (idx >= nx) {
        exitg1 = true;
      } else {
        ii++;
      }
    } else {
      ii++;
    }
  }

  if (!(idx <= ucTextU16_size[1])) {
    emlrtErrorWithMessageIdR2018a(&c_st, &xf_emlrtRTEI,
      "Coder:builtins:AssertionFailed", "Coder:builtins:AssertionFailed", 0);
  }

  if (ucTextU16_size[1] == 1) {
    if (idx == 0) {
      ii_size_idx_1 = 0;
    }
  } else if (1 > idx) {
    ii_size_idx_1 = 0;
  } else {
    ii_size_idx_1 = idx;
  }

  if (0 <= ii_size_idx_1 - 1) {
    memcpy(&idxNewlineChar_data[0], &ii_data[0], (uint32_T)(ii_size_idx_1 *
            (int32_T)sizeof(int32_T)));
  }

  *tbHeight = 14 + 14 * ii_size_idx_1;
  if (ii_size_idx_1 == 0) {
    nx = ucTextU16_size[0] * ucTextU16_size[1];
    for (idx = 0; idx < nx; idx++) {
      u0 = ucTextU16_data[idx] + 1U;
      if (u0 > 65535U) {
        u0 = 65535U;
      }

      thisCharcodes_1b_data[idx] = (uint16_T)u0;
    }

    tmp_size[0] = 1;
    tmp_size[1] = ucTextU16_size[1];
    nx = ucTextU16_size[1];
    for (idx = 0; idx < nx; idx++) {
      tmp_data[idx] = iv0[uv0[thisCharcodes_1b_data[idx] - 1]];
    }

    st.site = &tr_emlrtRSI;
    d1 = muDoubleScalarRound(b_sum(&st, tmp_data, tmp_size));
    if (d1 < 2.147483648E+9) {
      if (d1 >= -2.147483648E+9) {
        *tbWidth = (int32_T)d1;
      } else {
        *tbWidth = MIN_int32_T;
      }
    } else if (d1 >= 2.147483648E+9) {
      *tbWidth = MAX_int32_T;
    } else {
      *tbWidth = 0;
    }

    b_tmp_size[0] = 1;
    b_tmp_size[1] = ucTextU16_size[1];
    nx = ucTextU16_size[1];
    for (idx = 0; idx < nx; idx++) {
      x_data[idx] = (uv0[thisCharcodes_1b_data[idx] - 1] == 0);
    }

    st.site = &ur_emlrtRSI;
    numMissingGlyph = c_sum(&st, x_data, b_tmp_size);
    d1 = muDoubleScalarRound(numMissingGlyph * 4.0);
    if (d1 < 2.147483648E+9) {
      if (d1 >= -2.147483648E+9) {
        nx = (int32_T)d1;
      } else {
        nx = MIN_int32_T;
      }
    } else if (d1 >= 2.147483648E+9) {
      nx = MAX_int32_T;
    } else {
      nx = 0;
    }

    if ((*tbWidth < 0) && (nx < MIN_int32_T - *tbWidth)) {
      *tbWidth = MIN_int32_T;
    } else if ((*tbWidth > 0) && (nx > MAX_int32_T - *tbWidth)) {
      *tbWidth = MAX_int32_T;
    } else {
      *tbWidth += nx;
    }
  } else {
    if (1.0 > (real_T)idxNewlineChar_data[0] - 1.0) {
      nx = 0;
    } else {
      if (!(1 <= ucTextU16_size[1])) {
        emlrtDynamicBoundsCheckR2012b(1, 1, ucTextU16_size[1], &bf_emlrtBCI, sp);
      }

      nx = (int32_T)((real_T)idxNewlineChar_data[0] - 1.0);
      if (!((nx >= 1) && (nx <= ucTextU16_size[1]))) {
        emlrtDynamicBoundsCheckR2012b(nx, 1, ucTextU16_size[1], &cf_emlrtBCI, sp);
      }
    }

    for (idx = 0; idx < nx; idx++) {
      u0 = ucTextU16_data[idx] + 1U;
      if (u0 > 65535U) {
        u0 = 65535U;
      }

      thisCharcodes_1b_data[idx] = (uint16_T)u0;
    }

    tmp_size[0] = 1;
    tmp_size[1] = nx;
    for (idx = 0; idx < nx; idx++) {
      b_tmp_data[idx] = iv0[uv0[thisCharcodes_1b_data[idx] - 1]];
    }

    st.site = &vr_emlrtRSI;
    lenFirstSegment = b_sum(&st, b_tmp_data, tmp_size);
    b_tmp_size[0] = 1;
    b_tmp_size[1] = nx;
    for (idx = 0; idx < nx; idx++) {
      c_tmp_data[idx] = (uv0[thisCharcodes_1b_data[idx] - 1] == 0);
    }

    st.site = &wr_emlrtRSI;
    numMissingGlyph = c_sum(&st, c_tmp_data, b_tmp_size);
    d1 = muDoubleScalarRound(numMissingGlyph * 4.0);
    if (d1 < 2.147483648E+9) {
      if (d1 >= -2.147483648E+9) {
        y = (int32_T)d1;
      } else {
        y = MIN_int32_T;
      }
    } else if (d1 >= 2.147483648E+9) {
      y = MAX_int32_T;
    } else {
      y = 0;
    }

    *tbWidth = 0;
    for (i = 0; i <= ii_size_idx_1 - 3; i++) {
      idx = (int32_T)(2.0 + (real_T)i);
      if (!((idx >= 1) && (idx <= ii_size_idx_1))) {
        emlrtDynamicBoundsCheckR2012b(idx, 1, ii_size_idx_1, &df_emlrtBCI, sp);
      }

      idx = (int32_T)((2.0 + (real_T)i) + 1.0);
      if (!((idx >= 1) && (idx <= ii_size_idx_1))) {
        emlrtDynamicBoundsCheckR2012b(idx, 1, ii_size_idx_1, &ef_emlrtBCI, sp);
      }

      if ((real_T)idxNewlineChar_data[i + 1] + 1.0 > (real_T)
          idxNewlineChar_data[i + 2] - 1.0) {
        idx = 0;
        ii = 0;
      } else {
        idx = idxNewlineChar_data[i + 1] + 1;
        if (!((idx >= 1) && (idx <= ucTextU16_size[1]))) {
          emlrtDynamicBoundsCheckR2012b(idx, 1, ucTextU16_size[1], &ff_emlrtBCI,
            sp);
        }

        idx--;
        ii = (int32_T)((real_T)idxNewlineChar_data[i + 2] - 1.0);
        if (!((ii >= 1) && (ii <= ucTextU16_size[1]))) {
          emlrtDynamicBoundsCheckR2012b(ii, 1, ucTextU16_size[1], &gf_emlrtBCI,
            sp);
        }
      }

      thisCharcodes_1b_size_idx_1 = ii - idx;
      nx = ii - idx;
      for (ii = 0; ii < nx; ii++) {
        u0 = ucTextU16_data[idx + ii] + 1U;
        if (u0 > 65535U) {
          u0 = 65535U;
        }

        thisCharcodes_1b_data[ii] = (uint16_T)u0;
      }

      d_tmp_size[0] = 1;
      d_tmp_size[1] = thisCharcodes_1b_size_idx_1;
      for (idx = 0; idx < thisCharcodes_1b_size_idx_1; idx++) {
        b_tmp_data[idx] = iv0[uv0[thisCharcodes_1b_data[idx] - 1]];
      }

      st.site = &xr_emlrtRSI;
      lenEndSegment = b_sum(&st, b_tmp_data, d_tmp_size);
      f_tmp_size[0] = 1;
      f_tmp_size[1] = thisCharcodes_1b_size_idx_1;
      for (idx = 0; idx < thisCharcodes_1b_size_idx_1; idx++) {
        c_tmp_data[idx] = (uv0[thisCharcodes_1b_data[idx] - 1] == 0);
      }

      st.site = &yr_emlrtRSI;
      numMissingGlyph = c_sum(&st, c_tmp_data, f_tmp_size);
      d1 = muDoubleScalarRound(numMissingGlyph * 4.0);
      if (d1 < 2.147483648E+9) {
        if (d1 >= -2.147483648E+9) {
          idx = (int32_T)d1;
        } else {
          idx = MIN_int32_T;
        }
      } else if (d1 >= 2.147483648E+9) {
        idx = MAX_int32_T;
      } else {
        idx = 0;
      }

      d1 = muDoubleScalarRound(lenEndSegment + (real_T)idx);
      if (d1 < 2.147483648E+9) {
        if (d1 >= -2.147483648E+9) {
          nx = (int32_T)d1;
        } else {
          nx = MIN_int32_T;
        }
      } else if (d1 >= 2.147483648E+9) {
        nx = MAX_int32_T;
      } else {
        nx = 0;
      }

      if (nx > *tbWidth) {
        *tbWidth = nx;
      }
    }

    if (!(ii_size_idx_1 >= 1)) {
      emlrtDynamicBoundsCheckR2012b(ii_size_idx_1, 1, ii_size_idx_1,
        &hf_emlrtBCI, sp);
    }

    if ((real_T)idxNewlineChar_data[ii_size_idx_1 - 1] + 1.0 > ucTextU16_size[1])
    {
      idx = 0;
      ii = 0;
    } else {
      idx = idxNewlineChar_data[ii_size_idx_1 - 1] + 1;
      if (!((idx >= 1) && (idx <= ucTextU16_size[1]))) {
        emlrtDynamicBoundsCheckR2012b(idx, 1, ucTextU16_size[1], &if_emlrtBCI,
          sp);
      }

      idx--;
      if (!(ucTextU16_size[1] >= 1)) {
        emlrtDynamicBoundsCheckR2012b(ucTextU16_size[1], 1, ucTextU16_size[1],
          &jf_emlrtBCI, sp);
      }

      ii = ucTextU16_size[1];
    }

    thisCharcodes_1b_size_idx_1 = ii - idx;
    nx = ii - idx;
    for (ii = 0; ii < nx; ii++) {
      u0 = ucTextU16_data[idx + ii] + 1U;
      if (u0 > 65535U) {
        u0 = 65535U;
      }

      thisCharcodes_1b_data[ii] = (uint16_T)u0;
    }

    c_tmp_size[0] = 1;
    c_tmp_size[1] = thisCharcodes_1b_size_idx_1;
    for (idx = 0; idx < thisCharcodes_1b_size_idx_1; idx++) {
      tmp_data[idx] = iv0[uv0[thisCharcodes_1b_data[idx] - 1]];
    }

    st.site = &as_emlrtRSI;
    lenEndSegment = b_sum(&st, tmp_data, c_tmp_size);
    e_tmp_size[0] = 1;
    e_tmp_size[1] = thisCharcodes_1b_size_idx_1;
    for (idx = 0; idx < thisCharcodes_1b_size_idx_1; idx++) {
      x_data[idx] = (uv0[thisCharcodes_1b_data[idx] - 1] == 0);
    }

    st.site = &bs_emlrtRSI;
    numMissingGlyph = c_sum(&st, x_data, e_tmp_size);
    d1 = muDoubleScalarRound(lenFirstSegment + (real_T)y);
    if (d1 < 2.147483648E+9) {
      if (d1 >= -2.147483648E+9) {
        idx = (int32_T)d1;
      } else {
        idx = MIN_int32_T;
      }
    } else if (d1 >= 2.147483648E+9) {
      idx = MAX_int32_T;
    } else {
      idx = 0;
    }

    varargin_1[0] = idx;
    varargin_1[1] = *tbWidth;
    d1 = muDoubleScalarRound(numMissingGlyph * 4.0);
    if (d1 < 2.147483648E+9) {
      if (d1 >= -2.147483648E+9) {
        idx = (int32_T)d1;
      } else {
        idx = MIN_int32_T;
      }
    } else if (d1 >= 2.147483648E+9) {
      idx = MAX_int32_T;
    } else {
      idx = 0;
    }

    d1 = muDoubleScalarRound(lenEndSegment + (real_T)idx);
    if (d1 < 2.147483648E+9) {
      if (d1 >= -2.147483648E+9) {
        idx = (int32_T)d1;
      } else {
        idx = MIN_int32_T;
      }
    } else if (d1 >= 2.147483648E+9) {
      idx = MAX_int32_T;
    } else {
      idx = 0;
    }

    varargin_1[2] = idx;
    *tbWidth = varargin_1[0];
    for (nx = 0; nx < 2; nx++) {
      if (*tbWidth < varargin_1[nx + 1]) {
        *tbWidth = varargin_1[nx + 1];
      }
    }
  }

  *tbWidth = muIntScalarMax_sint32(*tbWidth, shapeWidth);
}

static void insertGlyphs(const emlrtStack *sp, uint8_T imgIn[1108698], const
  uint16_T ucTextU16_data[], const int32_T ucTextU16_size[2], int32_T
  textLocationXY_x, int32_T textLocationXY_y)
{
  int32_T penX;
  int32_T penY;
  int32_T loop_ub;
  int32_T i65;
  int32_T i;
  boolean_T isNewLineChar_data[29];
  uint32_T u1;
  int32_T bitmapEndIdx_1b;
  static const int8_T iv35[261] = { 1, 0, 0, 0, 1, 0, 0, 1, -1, 1, 1, 1, 0, 0, 1,
    0, 1, 1, 0, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 2, 2, 2, 0, 1, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, -1, 0, 1, 1, 0, 1, -1,
    1, 2, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0,
    -1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    -1, -1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 2, 1, 1, 0, 0, 2,
    2, 0, -1, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 2, 0, 0,
    0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, -1, 0, -1, 1, 1, 0, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, -1, 1, 1, 0, 1, 1,
    1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1 };

  int32_T xx;
  static const int8_T iv36[261] = { 8, 0, 0, 0, 9, 9, 9, 10, 9, 9, 9, 9, 9, 9, 7,
    1, 4, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 7, 7, 7, 5, 7, 9, 9, 9, 9, 9, 9, 9,
    9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 0,
    10, 7, 9, 7, 9, 7, 9, 7, 9, 9, 9, 9, 9, 7, 7, 7, 7, 7, 7, 7, 8, 7, 7, 7, 7,
    7, 7, 9, 9, 9, 5, 11, 12, 9, 12, 12, 11, 11, 10, 10, 10, 9, 10, 11, 7, 10,
    10, 10, 9, 10, 10, 10, 9, 10, 10, 10, 10, 9, 10, 10, 10, 10, 9, 0, 9, 9, 9,
    9, 0, 9, 9, 9, 9, 0, 10, 9, 0, 9, 9, 0, 7, 0, 0, 9, 7, 0, 0, 0, 0, 0, 9, 9,
    0, 7, 7, 7, 7, 5, 0, 0, 0, 0, 6, 6, 0, 0, 12, 12, 12, 0, 0, 0, 0, 0, 0, 0, 0,
    7, 0, 9, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 12, 12, 11, 12, 12, 12, 11,
    12, 12, 12, 0, 12, 12, 12, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 9, 9, 10, 12, 10, 9, 9, 0, 7, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 4, 10, 4 };

  int32_T yy;
  static const int8_T iv37[261] = { 8, 0, 0, 0, 9, 3, 9, 11, 9, 9, 3, 11, 11, 4,
    7, 3, 1, 1, 11, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 7, 9, 7, 3, 7, 9, 9, 9, 9, 9,
    9, 9, 9, 9, 9, 9, 11, 9, 9, 9, 9, 9, 9, 11, 9, 9, 9, 9, 9, 9, 9, 9, 9, 11,
    11, 11, 6, 1, 2, 7, 9, 7, 9, 7, 9, 9, 9, 9, 11, 9, 9, 7, 7, 7, 9, 9, 7, 7, 8,
    7, 7, 7, 7, 9, 7, 11, 11, 11, 2, 11, 12, 12, 12, 12, 11, 11, 10, 10, 10, 9,
    10, 11, 10, 10, 10, 10, 9, 10, 10, 10, 9, 10, 10, 10, 10, 9, 10, 10, 10, 10,
    9, 0, 3, 9, 9, 11, 0, 11, 9, 5, 9, 0, 2, 1, 0, 9, 9, 0, 7, 0, 0, 9, 9, 0, 0,
    0, 0, 0, 4, 4, 0, 7, 7, 9, 9, 3, 0, 0, 0, 0, 5, 5, 0, 0, 12, 12, 12, 0, 0, 0,
    0, 0, 0, 0, 0, 7, 0, 11, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 12, 12, 11,
    12, 12, 12, 11, 12, 12, 12, 0, 12, 12, 12, 12, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 11, 9, 10, 12, 12, 9, 11, 0, 7, 6, 6, 6, 9, 9, 9, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 };

  int32_T endR_im;
  static const int8_T iv38[261] = { 7, 0, 0, 0, 1, 3, 8, 5, 10, 6, 1, 3, 3, 5, 7,
    2, 5, 1, 6, 6, 5, 5, 5, 6, 5, 6, 6, 6, 6, 1, 2, 6, 6, 6, 5, 9, 9, 5, 6, 7, 6,
    4, 7, 7, 1, 3, 8, 5, 7, 7, 7, 5, 8, 7, 5, 7, 6, 8, 9, 9, 7, 5, 2, 6, 2, 9, 4,
    3, 6, 6, 4, 6, 5, 4, 5, 5, 1, 3, 7, 1, 9, 5, 5, 6, 6, 4, 4, 3, 5, 7, 9, 7, 9,
    5, 3, 1, 3, 6, 9, 9, 6, 6, 7, 7, 6, 6, 6, 6, 6, 6, 6, 4, 5, 5, 5, 5, 3, 3, 5,
    3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 3, 5, 6, 6, 0, 5, 5, 5, 9, 0, 3, 3, 0,
    12, 9, 0, 5, 0, 0, 7, 5, 0, 0, 0, 0, 0, 4, 4, 0, 8, 5, 5, 1, 6, 0, 0, 0, 0,
    5, 5, 0, 0, 9, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 9, 0, 0, 7, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 9, 6, 9, 6, 6, 3, 5, 3, 3, 7, 7, 0, 7, 6, 6, 6, 0, 0, 0, 0, 0, 0,
    0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 8, 5, 7, 9, 5, 6, 0, 7, 3, 3, 3, 9, 10,
    9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 1 };

  int32_T endC_im;
  int32_T startR_gl;
  int32_T startC_gl;
  int32_T endR_gl;
  int32_T endC_gl;
  uint32_T u2;
  uint32_T u3;
  static const int16_T iv39[261] = { 0, 0, 0, 56, 56, 65, 74, 146, 201, 291, 345,
    348, 381, 414, 434, 483, 489, 494, 495, 561, 615, 660, 705, 750, 804, 849,
    903, 957, 1011, 1065, 1072, 1090, 1132, 1150, 1192, 1237, 1318, 1399, 1444,
    1498, 1561, 1615, 1651, 1714, 1777, 1786, 1819, 1891, 1936, 1999, 2062, 2125,
    2170, 2258, 2321, 2366, 2429, 2483, 2555, 2636, 2717, 2780, 2825, 2847, 2913,
    2935, 2989, 2993, 2999, 3041, 3095, 3123, 3177, 3212, 3248, 3293, 3338, 3347,
    3380, 3443, 3452, 3515, 3550, 3585, 3639, 3693, 3721, 3749, 3773, 3808, 3857,
    3920, 3969, 4050, 4085, 4118, 4129, 4162, 5630, 5729, 5945, 6089, 6536, 6956,
    7379, 7679, 7619, 7739, 7859, 7799, 7913, 8035, 8125, 8075, 8175, 8225, 8300,
    8270, 8330, 8380, 8457, 8557, 8507, 8607, 8707, 8657, 8886, 8836, 8936, 8986,
    0, 4649, 4183, 4228, 4405, 0, 4780, 7574, 4619, 4474, 0, 4729, 4471, 0, 5837,
    7082, 0, 4658, 0, 0, 4331, 4735, 0, 0, 0, 0, 0, 4555, 4860, 0, 7979, 8801,
    5153, 4174, 4596, 0, 0, 0, 0, 4571, 4876, 0, 4174, 5198, 5522, 6872, 0, 0, 0,
    0, 0, 0, 0, 0, 8752, 0, 9205, 0, 0, 4282, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5414,
    6161, 5306, 6233, 6017, 6335, 6371, 6431, 6299, 6704, 6788, 0, 6620, 7235,
    7307, 7163, 0, 0, 0, 0, 0, 0, 0, 4836, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4394, 6464,
    8407, 7445, 9031, 7529, 9139, 0, 7033, 4842, 4693, 4711, 4991, 4901, 5072, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4614, 4644, 4835 };

  int32_T thisGlyphBitmap_size_idx_1;
  int32_T i66;
  uint8_T thisGlyphBitmap_data[9304];
  static const uint8_T uv2[9304] = { 60U, 96U, 96U, 96U, 96U, 96U, 60U, 96U, 0U,
    0U, 0U, 0U, 0U, 96U, 96U, 0U, 0U, 0U, 0U, 0U, 96U, 96U, 0U, 0U, 0U, 0U, 0U,
    96U, 96U, 0U, 0U, 0U, 0U, 0U, 96U, 96U, 0U, 0U, 0U, 0U, 0U, 96U, 96U, 0U, 0U,
    0U, 0U, 0U, 96U, 108U, 96U, 96U, 96U, 96U, 96U, 108U, MAX_uint8_T,
    MAX_uint8_T, 249U, 236U, 223U, 211U, 198U, 0U, MAX_uint8_T, 245U, 0U, 245U,
    224U, 0U, 224U, 202U, 0U, 202U, 0U, 0U, 28U, 223U, 0U, 25U, 226U, 0U, 0U, 0U,
    84U, 165U, 0U, 82U, 169U, 0U, 0U, 0U, 140U, 108U, 0U, 139U, 112U, 0U, 0U,
    242U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 222U,
    0U, 7U, 239U, 5U, 5U, 239U, 7U, 0U, 222U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 242U, 0U, 0U, 113U, 139U, 0U, 109U,
    140U, 0U, 0U, 0U, 170U, 81U, 0U, 166U, 84U, 0U, 0U, 0U, 227U, 24U, 0U, 223U,
    28U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 65U, 221U, MAX_uint8_T, 222U, 91U,
    222U, 97U, MAX_uint8_T, 43U, 175U, 242U, 19U, MAX_uint8_T, 0U, 0U, 141U,
    153U, MAX_uint8_T, 0U, 0U, 2U, 130U, MAX_uint8_T, 163U, 13U, 0U, 0U,
    MAX_uint8_T, 119U, 183U, 0U, 0U, MAX_uint8_T, 16U, 246U, 166U, 34U,
    MAX_uint8_T, 116U, 195U, 91U, 222U, MAX_uint8_T, 204U, 38U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 88U, 233U, 232U, 86U, 0U, 0U, 62U, 183U, 4U, 0U,
    233U, 54U, 55U, 233U, 0U, 31U, 197U, 17U, 0U, 0U, 233U, 52U, 49U, 232U, 11U,
    192U, 39U, 0U, 0U, 0U, 89U, 233U, 232U, 89U, 167U, 70U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, 126U, 109U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 80U, 151U, 88U, 233U, 232U,
    86U, 0U, 0U, 0U, 45U, 178U, 5U, 233U, 54U, 55U, 233U, 0U, 0U, 19U, 186U, 18U,
    0U, 233U, 52U, 49U, 232U, 0U, 4U, 175U, 41U, 0U, 0U, 89U, 234U, 232U, 88U,
    0U, 0U, 77U, 225U, 236U, 94U, 0U, 0U, 234U, 58U, 58U, 238U, 0U, 0U, 227U,
    25U, 52U, 201U, 0U, 0U, 170U, 149U, 171U, 30U, 0U, 94U, 178U, 233U, 20U, 2U,
    247U, 210U, 25U, 114U, 143U, 20U, 215U, 243U, 6U, 4U, 210U, 129U, 144U, 182U,
    92U, 12U, 106U, MAX_uint8_T, 38U, 30U, 190U, 245U, 209U, 197U, 155U, 238U,
    204U, 169U, 0U, 4U, 143U, 0U, 149U, 97U, 59U, 180U, 0U, 165U, 73U, 0U, 224U,
    20U, 0U, 248U, 5U, 0U, 224U, 20U, 0U, 165U, 72U, 0U, 59U, 178U, 0U, 0U, 149U,
    96U, 0U, 5U, 144U, 144U, 5U, 0U, 99U, 149U, 0U, 1U, 184U, 60U, 0U, 77U, 165U,
    0U, 22U, 224U, 0U, 6U, 248U, 0U, 22U, 224U, 0U, 76U, 165U, 0U, 182U, 60U,
    99U, 149U, 0U, 145U, 5U, 0U, 0U, 0U, 225U, 0U, 0U, 200U, 167U, 131U, 167U,
    200U, 0U, 83U, 120U, 120U, 0U, 0U, 158U, 9U, 164U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 66U, 225U, 197U, 45U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 1U, 228U, 25U, 0U, 0U, 0U,
    54U, 197U, 0U, 0U, 0U, 0U, 133U, 116U, 0U, 0U, 0U, 0U, 211U, 34U, 0U, 0U, 0U,
    34U, 208U, 0U, 0U, 0U, 0U, 112U, 127U, 0U, 0U, 0U, 0U, 191U, 46U, 0U, 0U, 0U,
    17U, 216U, 0U, 0U, 0U, 0U, 92U, 139U, 0U, 0U, 0U, 0U, 170U, 57U, 0U, 0U, 0U,
    6U, 217U, 1U, 0U, 0U, 0U, 0U, 71U, 207U, 207U, 70U, 0U, 56U, 200U, 33U, 33U,
    199U, 55U, 175U, 73U, 0U, 0U, 72U, 175U, 227U, 20U, 0U, 0U, 21U, 226U, 249U,
    5U, 0U, 0U, 5U, 248U, 227U, 20U, 0U, 0U, 22U, 226U, 175U, 71U, 0U, 0U, 75U,
    179U, 57U, 198U, 31U, 35U, 208U, 70U, 0U, 72U, 209U, 235U, 114U, 0U, 42U,
    127U, 213U, 0U, 0U, 162U, 110U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 246U, 188U, 35U, 0U, 0U, 9U, 119U, 196U, 0U, 0U,
    0U, 10U, 245U, 0U, 0U, 0U, 73U, 192U, 0U, 0U, 31U, 199U, 35U, 0U, 41U, 184U,
    30U, 0U, 29U, 185U, 16U, 0U, 0U, 187U, 51U, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    245U, 202U, 62U, 0U, 0U, 6U, 53U, 214U, 0U, 0U, 0U, 13U, 233U, 0U, 3U, 32U,
    153U, 98U, 0U, MAX_uint8_T, MAX_uint8_T, 99U, 0U, 0U, 3U, 30U, 145U, 106U,
    0U, 0U, 0U, 15U, 240U, 0U, 0U, 5U, 84U, 193U, MAX_uint8_T, MAX_uint8_T, 239U,
    178U, 32U, 0U, 0U, 0U, 99U, MAX_uint8_T, 0U, 0U, 0U, 50U, 200U, MAX_uint8_T,
    0U, 0U, 17U, 201U, 30U, MAX_uint8_T, 0U, 1U, 175U, 61U, 0U, MAX_uint8_T, 0U,
    125U, 101U, 0U, 0U, MAX_uint8_T, 0U, 253U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 239U, 200U, 83U, 0U, 0U, 17U,
    65U, 200U, 84U, 0U, 0U, 0U, 33U, 205U, 0U, 0U, 0U, 21U, 215U, 0U, 0U, 25U,
    167U, 91U, MAX_uint8_T, 250U, 196U, 87U, 0U, 0U, 58U, 194U, 247U,
    MAX_uint8_T, MAX_uint8_T, 45U, 214U, 64U, 8U, 0U, 0U, 167U, 77U, 0U, 0U, 0U,
    0U, 230U, 109U, 224U, 218U, 85U, 0U, 250U, 163U, 26U, 20U, 166U, 96U, 214U,
    14U, 0U, 0U, 24U, 221U, 154U, 31U, 0U, 0U, 19U, 194U, 49U, 169U, 26U, 17U,
    154U, 65U, 0U, 84U, 213U, 225U, 82U, 0U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 98U,
    172U, 0U, 0U, 0U, 14U, 214U, 23U, 0U, 0U, 0U, 139U, 98U, 0U, 0U, 0U, 37U,
    201U, 2U, 0U, 0U, 0U, 177U, 69U, 0U, 0U, 0U, 57U, 208U, 0U, 0U, 0U, 0U, 163U,
    104U, 0U, 0U, 0U, 0U, 229U, 33U, 0U, 0U, 0U, 33U, 173U, 236U, 244U, 196U,
    57U, 205U, 103U, 12U, 14U, 109U, 229U, 235U, 47U, 0U, 0U, 40U, 207U, 82U,
    226U, 65U, 51U, 180U, 38U, 25U, 205U, 157U, 178U, 153U, 11U, 179U, 79U, 0U,
    0U, 55U, 170U, 245U, 4U, 0U, 0U, 5U, 243U, 199U, 68U, 5U, 7U, 85U, 187U, 33U,
    179U, 240U, 237U, 168U, 24U, 0U, 80U, 211U, 203U, 77U, 0U, 82U, 154U, 17U,
    34U, 191U, 72U, 205U, 18U, 0U, 0U, 42U, 192U, 210U, 24U, 0U, 0U, 15U, 234U,
    69U, 163U, 20U, 24U, 160U, 249U, 0U, 80U, 216U, 225U, 111U, 222U, 0U, 0U, 0U,
    0U, 92U, 150U, 0U, 0U, 12U, 80U, 213U, 27U, MAX_uint8_T, MAX_uint8_T, 242U,
    177U, 38U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 68U, 230U, 221U,
    76U, 0U, 0U, 0U, 0U, 37U, 180U, 0U, 0U, 13U, 138U, 208U, 70U, 1U, 95U, 214U,
    111U, 4U, 0U, 146U, 241U, 44U, 0U, 0U, 0U, 1U, 96U, 217U, 116U, 5U, 0U, 0U,
    0U, 13U, 139U, 211U, 74U, 0U, 0U, 0U, 0U, 38U, 181U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 181U, 38U, 0U, 0U, 0U, 0U, 71U, 209U, 138U, 14U, 0U, 0U, 0U, 5U,
    112U, 215U, 95U, 2U, 0U, 0U, 0U, 45U, 242U, 146U, 0U, 7U, 118U, 218U, 96U,
    2U, 75U, 212U, 139U, 14U, 0U, 0U, 182U, 39U, 0U, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 245U, 194U, 48U, 0U, 0U, 8U, 99U, 216U, 0U, 0U, 0U, 31U, 226U,
    0U, 0U, 11U, 184U, 58U, 0U, 17U, 171U, 49U, 0U, 0U, 169U, 46U, 0U, 0U, 0U,
    248U, 1U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    34U, 158U, 230U, 248U, 204U, 76U, 0U, 0U, 71U, 228U, 105U, 20U, 16U, 90U,
    235U, 80U, 32U, 228U, 44U, 85U, 220U, MAX_uint8_T, 219U, 83U, 209U, 154U,
    112U, 62U, 179U, 21U, 125U, 145U, 13U, 246U, 228U, 26U, 188U, 38U, 14U, 224U,
    72U, 40U, 198U, 250U, 13U, 240U, 36U, 170U, 224U, 33U, 173U, 62U, 212U, 86U,
    108U, 227U, 65U, 212U, 191U, 48U, 0U, 82U, 238U, 100U, 23U, 0U, 0U, 0U, 0U,
    0U, 0U, 63U, 192U, 240U, MAX_uint8_T, 230U, 0U, 0U, 0U, 0U, 0U, 0U, 10U,
    215U, 11U, 0U, 0U, 0U, 0U, 0U, 0U, 111U, 237U, 113U, 0U, 0U, 0U, 0U, 0U, 5U,
    219U, 53U, 221U, 6U, 0U, 0U, 0U, 0U, 99U, 153U, 0U, 154U, 100U, 0U, 0U, 0U,
    2U, 214U, 34U, 0U, 35U, 215U, 2U, 0U, 0U, 86U, 165U, 0U, 0U, 0U, 165U, 87U,
    0U, 0U, 207U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 207U, 0U, 74U, 179U, 0U, 0U, 0U, 0U, 0U, 183U, 73U, 195U, 57U,
    0U, 0U, 0U, 0U, 0U, 61U, 195U, MAX_uint8_T, MAX_uint8_T, 248U, 205U, 64U,
    MAX_uint8_T, 1U, 23U, 126U, 225U, MAX_uint8_T, 0U, 0U, 14U, 240U,
    MAX_uint8_T, 1U, 20U, 122U, 138U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    210U, 12U, MAX_uint8_T, 1U, 11U, 86U, 164U, MAX_uint8_T, 0U, 0U, 8U, 244U,
    MAX_uint8_T, 0U, 12U, 112U, 219U, MAX_uint8_T, MAX_uint8_T, 250U, 209U, 62U,
    0U, 78U, 208U, 250U, MAX_uint8_T, MAX_uint8_T, 53U, 234U, 78U, 9U, 0U, 0U,
    174U, 104U, 0U, 0U, 0U, 0U, 224U, 29U, 0U, 0U, 0U, 0U, 248U, 7U, 0U, 0U, 0U,
    0U, 225U, 30U, 0U, 0U, 0U, 0U, 176U, 111U, 0U, 0U, 0U, 0U, 57U, 240U, 87U,
    12U, 0U, 0U, 0U, 85U, 213U, 252U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 243U, 196U, 67U, 0U, MAX_uint8_T, 0U, 5U, 26U,
    109U, 242U, 51U, MAX_uint8_T, 0U, 0U, 0U, 0U, 123U, 176U, MAX_uint8_T, 0U,
    0U, 0U, 0U, 32U, 229U, MAX_uint8_T, 0U, 0U, 0U, 0U, 9U, 249U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 38U, 226U, MAX_uint8_T, 0U, 0U, 0U, 0U, 130U, 158U,
    MAX_uint8_T, 0U, 0U, 20U, 104U, 230U, 33U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 240U, 176U, 41U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 44U, 176U, 238U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 41U,
    236U, 115U, 27U, 0U, 0U, 0U, 168U, 126U, 0U, 0U, 0U, 0U, 0U, 233U, 35U, 0U,
    0U, 0U, 0U, 0U, 252U, 6U, 0U, 0U, 0U, 0U, 0U, 234U, 15U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 172U, 70U, 0U, 0U, 0U, 0U, MAX_uint8_T, 47U, 208U, 82U, 22U, 7U,
    37U, MAX_uint8_T, 0U, 50U, 180U, 240U, 249U, 224U, 170U, MAX_uint8_T, 0U, 0U,
    0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U,
    0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U,
    0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 6U, 242U,
    0U, 71U, 196U, MAX_uint8_T, 219U, 56U, MAX_uint8_T, 0U, 0U, 0U, 82U, 170U,
    7U, 0U, MAX_uint8_T, 0U, 0U, 99U, 163U, 4U, 0U, 0U, MAX_uint8_T, 0U, 118U,
    155U, 2U, 0U, 0U, 0U, MAX_uint8_T, 137U, 148U, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 108U, 195U, 12U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 100U, 191U,
    11U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 91U, 187U, 9U, 0U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 84U, 182U, 8U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 76U, 177U, 8U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 109U, 0U, 0U, 0U, 109U, MAX_uint8_T, MAX_uint8_T, 192U, 0U, 0U,
    0U, 183U, MAX_uint8_T, MAX_uint8_T, 171U, 36U, 0U, 19U, 173U, MAX_uint8_T,
    MAX_uint8_T, 79U, 128U, 0U, 97U, 91U, MAX_uint8_T, MAX_uint8_T, 5U, 200U, 0U,
    170U, 13U, MAX_uint8_T, MAX_uint8_T, 0U, 151U, 66U, 166U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 59U, 220U, 89U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 212U,
    12U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 93U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 180U, 19U, 0U,
    0U, 0U, MAX_uint8_T, MAX_uint8_T, 49U, 157U, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 143U, 68U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 13U, 192U,
    9U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 83U, 136U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, 175U, 46U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    32U, 192U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 119U, MAX_uint8_T, 0U,
    76U, 212U, 249U, 212U, 77U, 0U, 47U, 231U, 73U, 14U, 74U, 233U, 48U, 169U,
    101U, 0U, 0U, 0U, 104U, 170U, 223U, 27U, 0U, 0U, 0U, 28U, 222U, 248U, 6U, 0U,
    0U, 0U, 7U, 247U, 223U, 28U, 0U, 0U, 0U, 30U, 222U, 170U, 103U, 0U, 0U, 0U,
    105U, 169U, 49U, 233U, 72U, 14U, 74U, 233U, 48U, 0U, 80U, 215U, 249U, 212U,
    77U, 0U, MAX_uint8_T, MAX_uint8_T, 247U, 210U, 71U, MAX_uint8_T, 0U, 5U, 65U,
    224U, MAX_uint8_T, 0U, 0U, 5U, 237U, MAX_uint8_T, 0U, 0U, 40U, 158U,
    MAX_uint8_T, 252U, 219U, 134U, 11U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    76U, 212U, 249U, 212U, 75U, 0U, 0U, 47U, 231U, 73U, 14U, 74U, 232U, 46U, 0U,
    169U, 101U, 0U, 0U, 0U, 104U, 168U, 0U, 223U, 27U, 0U, 0U, 0U, 29U, 222U, 0U,
    248U, 6U, 0U, 0U, 0U, 7U, 248U, 0U, 223U, 28U, 0U, 0U, 0U, 29U, 232U, 0U,
    168U, 103U, 0U, 0U, 0U, 105U, 174U, 0U, 47U, 232U, 72U, 14U, 74U, 233U, 54U,
    0U, 0U, 79U, 216U, 250U, 253U, 99U, 0U, 0U, 0U, 0U, 0U, 0U, 63U, 206U, 88U,
    11U, 0U, 0U, 0U, 0U, 0U, 20U, 147U, 158U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 242U, 194U, 52U, 0U, MAX_uint8_T, 0U, 6U, 32U, 133U, 217U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 20U, 234U, 0U, MAX_uint8_T, 0U, 1U, 32U, 157U, 91U,
    0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 222U, 44U, 0U, 0U, MAX_uint8_T,
    0U, 0U, 141U, 76U, 0U, 0U, MAX_uint8_T, 0U, 0U, 6U, 188U, 33U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 37U, 193U, 8U, MAX_uint8_T, 0U, 0U, 0U, 0U, 93U,
    157U, 38U, 187U, 245U, MAX_uint8_T, MAX_uint8_T, 204U, 97U, 6U, 0U, 0U, 240U,
    35U, 0U, 0U, 0U, 79U, 206U, 79U, 0U, 0U, 0U, 22U, 207U, 177U, 16U, 0U, 0U,
    14U, 111U, 181U, 0U, 0U, 0U, 2U, 243U, 0U, 0U, 6U, 102U, 191U, MAX_uint8_T,
    MAX_uint8_T, 241U, 179U, 30U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U,
    0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    0U, 0U, 0U, 0U, MAX_uint8_T, 252U, 1U, 0U, 0U, 0U, 253U, 227U, 13U, 0U, 0U,
    11U, 228U, 153U, 107U, 11U, 7U, 93U, 161U, 18U, 163U, 234U, 239U, 174U, 23U,
    212U, 39U, 0U, 0U, 0U, 19U, 228U, 5U, 125U, 125U, 0U, 0U, 0U, 104U, 142U, 0U,
    38U, 212U, 0U, 0U, 0U, 194U, 45U, 0U, 0U, 207U, 43U, 0U, 30U, 203U, 0U, 0U,
    0U, 120U, 130U, 0U, 120U, 107U, 0U, 0U, 0U, 34U, 215U, 0U, 203U, 17U, 0U, 0U,
    0U, 0U, 202U, 92U, 169U, 0U, 0U, 0U, 0U, 0U, 115U, 240U, 72U, 0U, 0U, 0U, 0U,
    0U, 29U, 227U, 3U, 0U, 0U, 0U, 228U, 23U, 0U, 42U, MAX_uint8_T, 60U, 0U, 23U,
    228U, 175U, 77U, 0U, 93U, MAX_uint8_T, 109U, 0U, 78U, 173U, 121U, 131U, 0U,
    144U, 204U, 158U, 0U, 133U, 119U, 67U, 185U, 0U, 196U, 104U, 207U, 0U, 188U,
    64U, 14U, 236U, 3U, 237U, 14U, 246U, 8U, 238U, 12U, 0U, 214U, 79U, 203U, 0U,
    212U, 91U, 211U, 0U, 0U, 160U, 185U, 151U, 0U, 163U, 195U, 156U, 0U, 0U,
    106U, 254U, 100U, 0U, 114U, MAX_uint8_T, 101U, 0U, 0U, 51U, MAX_uint8_T, 49U,
    0U, 65U, MAX_uint8_T, 47U, 0U, 11U, 205U, 39U, 0U, 0U, 0U, 34U, 203U, 11U,
    0U, 49U, 201U, 7U, 0U, 4U, 195U, 52U, 0U, 0U, 0U, 113U, 146U, 0U, 134U, 122U,
    0U, 0U, 0U, 0U, 1U, 182U, 136U, 192U, 2U, 0U, 0U, 0U, 0U, 0U, 54U,
    MAX_uint8_T, 53U, 0U, 0U, 0U, 0U, 0U, 2U, 192U, 137U, 181U, 1U, 0U, 0U, 0U,
    0U, 123U, 134U, 0U, 147U, 112U, 0U, 0U, 0U, 53U, 197U, 5U, 0U, 7U, 201U, 48U,
    0U, 11U, 205U, 36U, 0U, 0U, 0U, 40U, 205U, 11U, 170U, 86U, 0U, 0U, 0U, 81U,
    167U, 20U, 212U, 22U, 0U, 10U, 198U, 17U, 0U, 81U, 173U, 0U, 133U, 70U, 0U,
    0U, 0U, 165U, 128U, 142U, 0U, 0U, 0U, 0U, 17U, MAX_uint8_T, 10U, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    69U, 182U, 0U, 0U, 3U, 207U, 40U, 0U, 0U, 107U, 144U, 0U, 0U, 17U, 217U, 17U,
    0U, 0U, 145U, 106U, 0U, 0U, 41U, 207U, 3U, 0U, 0U, 182U, 69U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T,
    0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, MAX_uint8_T, MAX_uint8_T, 26U, 228U, 2U, 0U, 0U, 0U, 0U,
    199U, 54U, 0U, 0U, 0U, 0U, 117U, 132U, 0U, 0U, 0U, 0U, 36U, 211U, 0U, 0U, 0U,
    0U, 0U, 210U, 34U, 0U, 0U, 0U, 0U, 129U, 112U, 0U, 0U, 0U, 0U, 47U, 190U, 0U,
    0U, 0U, 0U, 1U, 217U, 18U, 0U, 0U, 0U, 0U, 140U, 91U, 0U, 0U, 0U, 0U, 59U,
    170U, 0U, 0U, 0U, 0U, 3U, 218U, 7U, MAX_uint8_T, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 3U, 153U, 3U, 0U, 0U, 0U,
    0U, 0U, 0U, 112U, 227U, 112U, 0U, 0U, 0U, 0U, 0U, 28U, 212U, 23U, 213U, 28U,
    0U, 0U, 0U, 0U, 175U, 77U, 0U, 78U, 175U, 0U, 0U, 0U, 80U, 174U, 0U, 0U, 0U,
    175U, 80U, 0U, 12U, 214U, 28U, 0U, 0U, 0U, 28U, 214U, 12U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 41U, 193U, 8U, 0U, 87U, 156U, 72U,
    196U, 245U, 222U, 85U, 0U, 183U, 58U, 10U, 80U, 232U, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 28U, 159U, 227U, 248U, MAX_uint8_T, 0U, 202U, 126U, 24U, 1U,
    MAX_uint8_T, 0U, 238U, 60U, 13U, 85U, MAX_uint8_T, 32U, 93U, 233U, 226U,
    116U, 138U, 220U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 75U, 218U, 242U, 170U, 16U, MAX_uint8_T, 157U, 36U, 11U,
    91U, 152U, MAX_uint8_T, 0U, 0U, 0U, 0U, 208U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    243U, MAX_uint8_T, 53U, 0U, 0U, 0U, 206U, MAX_uint8_T, 224U, 46U, 2U, 67U,
    177U, 240U, 86U, 210U, 240U, 179U, 32U, 16U, 173U, 245U, MAX_uint8_T, 151U,
    118U, 7U, 0U, 227U, 15U, 0U, 0U, 248U, 2U, 0U, 0U, 222U, 17U, 0U, 0U, 138U,
    128U, 8U, 0U, 12U, 175U, 250U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 3U, 144U, 238U, 209U, 86U, MAX_uint8_T,
    112U, 138U, 0U, 27U, 130U, MAX_uint8_T, 212U, 30U, 0U, 0U, 0U, MAX_uint8_T,
    246U, 6U, 0U, 0U, 0U, MAX_uint8_T, 230U, 19U, 0U, 0U, 0U, MAX_uint8_T, 154U,
    110U, 0U, 34U, 156U, MAX_uint8_T, 17U, 172U, 238U, 219U, 75U, MAX_uint8_T,
    7U, 156U, 238U, 194U, 24U, 132U, 124U, 4U, 116U, 157U, 222U, 35U, 0U, 13U,
    227U, 246U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 251U, 215U, 25U, 0U, 0U,
    0U, 112U, 118U, 0U, 0U, 0U, 2U, 125U, 203U, 254U, MAX_uint8_T, 0U, 90U, 225U,
    MAX_uint8_T, 0U, 248U, 24U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    15U, 187U, 239U, 124U, MAX_uint8_T, 138U, 94U, 13U, 103U, MAX_uint8_T, 221U,
    11U, 0U, 0U, MAX_uint8_T, 248U, 0U, 0U, 0U, MAX_uint8_T, 231U, 2U, 0U, 0U,
    MAX_uint8_T, 169U, 95U, 13U, 127U, 249U, 32U, 205U, 213U, 69U, 231U, 0U, 0U,
    0U, 86U, 169U, 240U, MAX_uint8_T, 233U, 173U, 24U, MAX_uint8_T, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 66U, 217U, 239U, 96U,
    MAX_uint8_T, 182U, 36U, 56U, 232U, MAX_uint8_T, 15U, 0U, 2U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 2U, 252U, 0U, 49U,
    221U, MAX_uint8_T, 238U, 90U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 81U, 182U, 8U, 0U,
    MAX_uint8_T, 0U, 97U, 196U, 12U, 0U, 0U, MAX_uint8_T, 114U, 206U, 16U, 0U,
    0U, 0U, MAX_uint8_T, 127U, 199U, 13U, 0U, 0U, 0U, MAX_uint8_T, 0U, 111U,
    193U, 11U, 0U, 0U, MAX_uint8_T, 0U, 0U, 95U, 187U, 9U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 81U, 179U, 8U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    84U, 223U, 237U, 78U, 38U, 208U, 222U, 77U, MAX_uint8_T, 220U, 48U, 54U,
    224U, 174U, 48U, 53U, 233U, MAX_uint8_T, 48U, 0U, 0U, MAX_uint8_T, 48U, 0U,
    0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 66U, 217U,
    239U, 96U, MAX_uint8_T, 182U, 36U, 56U, 232U, MAX_uint8_T, 15U, 0U, 2U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, 17U, 179U, 229U, 179U, 17U, 150U, 131U, 1U, 131U, 149U, 226U,
    26U, 0U, 27U, 226U, 249U, 5U, 0U, 5U, 248U, 226U, 26U, 0U, 28U, 225U, 148U,
    130U, 1U, 133U, 149U, 16U, 179U, 229U, 178U, 17U, MAX_uint8_T, 75U, 218U,
    229U, 166U, 16U, MAX_uint8_T, 157U, 36U, 1U, 89U, 152U, MAX_uint8_T, 0U, 0U,
    0U, 18U, 229U, MAX_uint8_T, 0U, 0U, 0U, 3U, 251U, MAX_uint8_T, 29U, 0U, 0U,
    22U, 233U, MAX_uint8_T, 180U, 39U, 0U, 106U, 170U, MAX_uint8_T, 56U, 221U,
    216U, 169U, 25U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, 3U, 144U, 238U, 216U, 95U, MAX_uint8_T, 112U, 138U, 0U, 27U, 130U,
    MAX_uint8_T, 212U, 30U, 0U, 0U, 0U, MAX_uint8_T, 246U, 6U, 0U, 0U, 0U,
    MAX_uint8_T, 230U, 19U, 0U, 0U, 0U, MAX_uint8_T, 154U, 110U, 0U, 34U, 156U,
    MAX_uint8_T, 17U, 172U, 238U, 219U, 75U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 63U, 208U, 252U,
    MAX_uint8_T, 177U, 41U, 1U, MAX_uint8_T, 9U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    82U, 221U, 253U, MAX_uint8_T, 235U, 48U, 0U, 0U, 216U, 136U, 13U, 0U, 42U,
    198U, 234U, 73U, 0U, 0U, 96U, 231U, 0U, 0U, 56U, 227U, MAX_uint8_T,
    MAX_uint8_T, 221U, 70U, 0U, 244U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 238U, 40U, 0U, 83U, 244U, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 1U, 0U, 15U,
    MAX_uint8_T, 227U, 56U, 34U, 181U, MAX_uint8_T, 49U, 205U, 218U, 65U,
    MAX_uint8_T, 198U, 53U, 0U, 0U, 0U, 61U, 198U, 83U, 168U, 0U, 0U, 0U, 175U,
    84U, 2U, 217U, 31U, 0U, 35U, 220U, 3U, 0U, 108U, 142U, 0U, 146U, 111U, 0U,
    0U, 11U, 224U, 31U, 227U, 12U, 0U, 0U, 0U, 133U, 215U, 139U, 0U, 0U, 0U, 0U,
    24U, 244U, 29U, 0U, 0U, 216U, 34U, 0U, 31U, MAX_uint8_T, 41U, 0U, 34U, 218U,
    138U, 110U, 0U, 108U, MAX_uint8_T, 116U, 0U, 111U, 144U, 59U, 187U, 0U, 186U,
    163U, 191U, 0U, 188U, 70U, 2U, 227U, 27U, 237U, 19U, 241U, 29U, 238U, 7U, 0U,
    157U, 169U, 169U, 0U, 176U, 171U, 177U, 0U, 0U, 78U, MAX_uint8_T, 85U, 0U,
    94U, MAX_uint8_T, 103U, 0U, 0U, 9U, 236U, 11U, 0U, 17U, 250U, 29U, 0U, 12U,
    211U, 27U, 0U, 16U, 213U, 14U, 0U, 72U, 177U, 0U, 143U, 101U, 0U, 0U, 0U,
    163U, 125U, 204U, 2U, 0U, 0U, 0U, 57U, MAX_uint8_T, 79U, 0U, 0U, 0U, 0U,
    187U, 147U, 164U, 0U, 0U, 0U, 87U, 165U, 0U, 178U, 72U, 0U, 13U, 214U, 24U,
    0U, 28U, 211U, 12U, 18U, 225U, 7U, 0U, 0U, 0U, 12U, 223U, 16U, 0U, 154U, 95U,
    0U, 0U, 0U, 116U, 137U, 0U, 0U, 44U, 203U, 0U, 0U, 7U, 222U, 24U, 0U, 0U, 0U,
    189U, 57U, 0U, 104U, 151U, 0U, 0U, 0U, 0U, 79U, 166U, 3U, 218U, 33U, 0U, 0U,
    0U, 0U, 2U, 216U, 117U, 164U, 0U, 0U, 0U, 0U, 0U, 0U, 114U, 252U, 44U, 0U,
    0U, 0U, 0U, 0U, 0U, 81U, 177U, 0U, 0U, 0U, 0U, 0U, 0U, 2U, 210U, 56U, 0U, 0U,
    0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    0U, 0U, 99U, 152U, 0U, 0U, 55U, 190U, 6U, 0U, 24U, 202U, 24U, 0U, 6U, 190U,
    55U, 0U, 0U, 153U, 98U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 0U, 90U, 228U, 0U, 240U, 43U, 0U, MAX_uint8_T, 0U,
    0U, 253U, 0U, 45U, 208U, 0U, MAX_uint8_T, 96U, 0U, 44U, 207U, 0U, 0U, 253U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 240U, 43U, 0U, 93U, 229U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 229U, 91U, 0U, 40U, 241U,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, 209U, 45U, 0U, 97U,
    MAX_uint8_T, 0U, 209U, 45U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 40U,
    241U, 0U, 230U, 93U, 0U, 71U, 226U, 191U, 84U, 37U, 219U, 234U, 39U, 86U,
    191U, 230U, 62U, MAX_uint8_T, 0U, 198U, 211U, 223U, 236U, 249U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, 23U, 198U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 161U, 118U, MAX_uint8_T, 0U, 0U, 231U, 20U,
    MAX_uint8_T, 0U, 0U, 249U, 3U, MAX_uint8_T, 0U, 0U, 228U, 26U, MAX_uint8_T,
    0U, 0U, 154U, 140U, MAX_uint8_T, 0U, 0U, 21U, 199U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 26U, 168U, 233U, MAX_uint8_T,
    MAX_uint8_T, 0U, 183U, 103U, 8U, 0U, 0U, 0U, 245U, 3U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 7U, 241U, 0U, 0U, 0U,
    0U, 106U, 167U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 160U, 32U, 0U, 0U, 0U, 32U, 160U, 32U,
    192U, 190U, 245U, 190U, 192U, 32U, 0U, 191U, 118U, 12U, 120U, 191U, 0U, 0U,
    246U, 11U, 0U, 12U, 245U, 0U, 0U, 191U, 118U, 11U, 118U, 191U, 0U, 32U, 192U,
    190U, 246U, 190U, 192U, 32U, 160U, 32U, 0U, 0U, 0U, 32U, 160U, 159U, 91U, 0U,
    0U, 0U, 92U, 159U, 10U, 201U, 40U, 0U, 41U, 201U, 10U, 0U, 42U, 200U, 19U,
    201U, 42U, 0U, 0U, 0U, 96U, 233U, 96U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 29U, 162U, 230U, 253U, MAX_uint8_T,
    MAX_uint8_T, 206U, 106U, 19U, 0U, 0U, 0U, 227U, 100U, 6U, 0U, 0U, 0U, 71U,
    250U, 231U, 135U, 27U, 0U, 197U, 73U, 26U, 127U, 228U, 98U, 238U, 49U, 0U,
    0U, 35U, 240U, 85U, 230U, 128U, 22U, 100U, 179U, 0U, 21U, 130U, 229U, 250U,
    46U, 0U, 0U, 0U, 8U, 115U, 217U, 0U, 0U, 0U, 12U, 92U, 219U, MAX_uint8_T,
    MAX_uint8_T, 254U, 235U, 176U, 42U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 35U,
    160U, 229U, 251U, 229U, 159U, 33U, 0U, 45U, 187U, 60U, 14U, 3U, 14U, 60U,
    186U, 43U, 174U, 60U, 41U, 197U, 250U, MAX_uint8_T, 0U, 60U, 173U, 235U, 13U,
    198U, 122U, 8U, 0U, 0U, 14U, 233U, 251U, 2U, 245U, 11U, 0U, 0U, 0U, 5U, 251U,
    234U, 13U, 197U, 119U, 9U, 0U, 0U, 35U, 233U, 173U, 59U, 39U, 196U, 250U,
    MAX_uint8_T, 0U, 122U, 173U, 45U, 185U, 57U, 12U, 3U, 18U, 80U, 219U, 45U,
    0U, 36U, 162U, 232U, 248U, 218U, 152U, 29U, 0U, MAX_uint8_T, 242U, 95U, 0U,
    0U, 29U, MAX_uint8_T, 0U, 164U, 248U, MAX_uint8_T, 18U, 205U, 205U, 195U,
    227U, 0U, 32U, 155U, 32U, 155U, 32U, 188U, 58U, 188U, 26U, 192U, 61U, 192U,
    61U, 0U, 32U, 187U, 57U, 187U, 25U, 0U, 32U, 155U, 32U, 155U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 30U, 188U, 243U, 188U,
    30U, 189U, 123U, 13U, 125U, 188U, 244U, 12U, 224U, 13U, 243U, 190U, 121U,
    MAX_uint8_T, 128U, 189U, 32U, 190U, 244U, 189U, 31U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 135U, 243U, 135U, 244U,
    76U, 243U, 134U, 244U, 134U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 227U, 45U, 0U, 47U, 224U, 0U, 56U, 182U, 9U, 197U,
    37U, 159U, 89U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 241U,
    98U, 2U, 67U, 221U, MAX_uint8_T, 246U, 68U, 5U, 80U, 223U, 0U, 48U, 223U,
    MAX_uint8_T, 236U, 71U, 8U, 206U, 125U, 156U, 119U, 0U, MAX_uint8_T, 0U, 0U,
    0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U,
    0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 1U, 0U,
    13U, MAX_uint8_T, MAX_uint8_T, 68U, 25U, 172U, MAX_uint8_T, MAX_uint8_T,
    228U, 231U, 77U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 0U, 83U, 218U, 251U, MAX_uint8_T, MAX_uint8_T, 237U, MAX_uint8_T,
    MAX_uint8_T, 0U, MAX_uint8_T, 220U, MAX_uint8_T, MAX_uint8_T, 0U,
    MAX_uint8_T, 68U, 222U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, MAX_uint8_T, MAX_uint8_T, 177U, 81U, 41U, 232U, 252U, 87U, 64U, 192U, 0U,
    192U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 88U, 233U, 232U, 86U,
    233U, 48U, 48U, 232U, 233U, 46U, 49U, 233U, 91U, 234U, 232U, 88U, 156U, 32U,
    156U, 32U, 0U, 27U, 189U, 59U, 189U, 32U, 0U, 62U, 192U, 62U, 192U, 27U,
    189U, 59U, 189U, 32U, 156U, 32U, 156U, 32U, 0U, 0U, 64U, 192U, 0U, 0U, 0U,
    37U, 203U, 11U, 0U, 0U, 192U, MAX_uint8_T, 0U, 0U, 5U, 197U, 48U, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, 139U, 112U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    70U, 180U, 1U, 67U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 22U, 207U, 21U, 0U,
    193U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 180U, 70U, 0U, 64U, 193U,
    MAX_uint8_T, 0U, 0U, 0U, 113U, 139U, 0U, 0U, 190U, 67U, MAX_uint8_T, 0U, 0U,
    49U, 197U, 5U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    11U, 203U, 37U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 64U, 192U, 0U, 0U,
    0U, 37U, 203U, 11U, 0U, 192U, MAX_uint8_T, 0U, 0U, 5U, 197U, 48U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 139U, 112U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 70U, 180U,
    MAX_uint8_T, 243U, 90U, 0U, 0U, MAX_uint8_T, 22U, 207U, 21U, 0U, 47U, 236U,
    0U, 0U, MAX_uint8_T, 180U, 70U, 0U, 0U, 60U, 182U, 0U, 0U, 113U, 139U, 0U,
    0U, 8U, 196U, 34U, 0U, 49U, 197U, 5U, 0U, 0U, 155U, 89U, 0U, 11U, 203U, 37U,
    0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 241U, 98U,
    0U, 0U, 0U, 37U, 203U, 11U, 2U, 67U, 221U, 0U, 0U, 5U, 197U, 48U, 0U,
    MAX_uint8_T, 246U, 68U, 0U, 0U, 139U, 112U, 0U, 0U, 5U, 80U, 223U, 0U, 70U,
    180U, 68U, MAX_uint8_T, 0U, 0U, 48U, 223U, 22U, 207U, 21U, 193U, MAX_uint8_T,
    0U, MAX_uint8_T, 236U, 72U, 180U, 70U, 64U, 193U, MAX_uint8_T, 0U, 0U, 0U,
    113U, 139U, 0U, 190U, 67U, MAX_uint8_T, 0U, 0U, 49U, 197U, 5U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 11U, 203U, 37U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 1U, 248U, 0U, 0U, 0U, 48U, 168U, 0U, 0U, 49U, 171U, 17U, 0U, 58U, 184U,
    12U, 0U, 0U, 227U, 31U, 0U, 0U, 0U, 218U, 95U, 7U, 0U, 0U, 52U, 196U, 245U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 41U, 193U, 8U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 87U, 156U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    10U, 215U, 11U, 0U, 0U, 0U, 0U, 0U, 0U, 111U, 237U, 113U, 0U, 0U, 0U, 0U, 0U,
    5U, 219U, 53U, 221U, 6U, 0U, 0U, 0U, 0U, 99U, 153U, 0U, 154U, 100U, 0U, 0U,
    0U, 2U, 214U, 34U, 0U, 35U, 215U, 2U, 0U, 0U, 86U, 165U, 0U, 0U, 0U, 165U,
    87U, 0U, 0U, 207U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 207U, 0U, 74U, 179U, 0U, 0U, 0U, 0U, 0U, 183U, 73U, 195U, 57U,
    0U, 0U, 0U, 0U, 0U, 61U, 195U, 0U, 0U, 0U, 0U, 8U, 206U, 125U, 0U, 0U, 0U,
    0U, 0U, 0U, 156U, 119U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, 10U, 215U, 11U, 0U, 0U, 0U, 0U, 0U, 0U, 111U, 237U, 113U, 0U, 0U, 0U,
    0U, 0U, 5U, 219U, 53U, 221U, 6U, 0U, 0U, 0U, 0U, 99U, 153U, 0U, 154U, 100U,
    0U, 0U, 0U, 2U, 214U, 34U, 0U, 35U, 215U, 2U, 0U, 0U, 86U, 165U, 0U, 0U, 0U,
    165U, 87U, 0U, 0U, 207U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 207U, 0U, 74U, 179U, 0U, 0U, 0U, 0U, 0U, 183U, 73U, 195U, 57U,
    0U, 0U, 0U, 0U, 0U, 61U, 195U, 0U, 0U, 0U, 107U, 243U, 107U, 0U, 0U, 0U, 0U,
    0U, 14U, 220U, 48U, 220U, 14U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, 0U, 10U, 215U, 11U, 0U, 0U, 0U, 0U, 0U, 0U, 111U, 237U, 113U, 0U, 0U,
    0U, 0U, 0U, 5U, 219U, 53U, 221U, 6U, 0U, 0U, 0U, 0U, 99U, 153U, 0U, 154U,
    100U, 0U, 0U, 0U, 2U, 214U, 34U, 0U, 35U, 215U, 2U, 0U, 0U, 86U, 165U, 0U,
    0U, 0U, 165U, 87U, 0U, 0U, 207U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 207U, 0U, 74U, 179U, 0U, 0U, 0U, 0U, 0U, 183U, 73U,
    195U, 57U, 0U, 0U, 0U, 0U, 0U, 61U, 195U, 0U, 0U, 161U, 203U, 47U, 242U, 0U,
    0U, 0U, 0U, 0U, 243U, 47U, 202U, 159U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, 0U, 0U, 0U, 0U, 10U, 215U, 11U, 0U, 0U, 0U, 0U, 0U, 0U, 111U, 237U,
    113U, 0U, 0U, 0U, 0U, 0U, 5U, 219U, 53U, 221U, 6U, 0U, 0U, 0U, 0U, 99U, 153U,
    0U, 154U, 100U, 0U, 0U, 0U, 2U, 214U, 34U, 0U, 35U, 215U, 2U, 0U, 0U, 86U,
    165U, 0U, 0U, 0U, 165U, 87U, 0U, 0U, 207U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 207U, 0U, 74U, 179U, 0U, 0U, 0U, 0U,
    0U, 183U, 73U, 195U, 57U, 0U, 0U, 0U, 0U, 0U, 61U, 195U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, 0U, 10U, 215U, 11U, 0U, 0U, 0U, 0U, 0U, 0U, 111U, 237U, 113U, 0U, 0U,
    0U, 0U, 0U, 5U, 219U, 53U, 221U, 6U, 0U, 0U, 0U, 0U, 99U, 153U, 0U, 154U,
    100U, 0U, 0U, 0U, 2U, 214U, 34U, 0U, 35U, 215U, 2U, 0U, 0U, 86U, 165U, 0U,
    0U, 0U, 165U, 87U, 0U, 0U, 207U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 207U, 0U, 74U, 179U, 0U, 0U, 0U, 0U, 0U, 183U, 73U,
    195U, 57U, 0U, 0U, 0U, 0U, 0U, 61U, 195U, 0U, 0U, 0U, 135U, 243U, 135U, 0U,
    0U, 0U, 0U, 0U, 0U, 244U, 76U, 243U, 0U, 0U, 0U, 0U, 0U, 0U, 137U, 244U,
    137U, 0U, 0U, 0U, 0U, 0U, 0U, 10U, 215U, 11U, 0U, 0U, 0U, 0U, 0U, 0U, 111U,
    237U, 113U, 0U, 0U, 0U, 0U, 0U, 5U, 219U, 53U, 221U, 6U, 0U, 0U, 0U, 0U, 99U,
    153U, 0U, 154U, 100U, 0U, 0U, 0U, 2U, 214U, 34U, 0U, 35U, 215U, 2U, 0U, 0U,
    86U, 165U, 0U, 0U, 0U, 165U, 87U, 0U, 0U, 207U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 207U, 0U, 74U, 179U, 0U, 0U, 0U, 0U,
    0U, 183U, 73U, 195U, 57U, 0U, 0U, 0U, 0U, 0U, 61U, 195U, 0U, 0U, 0U, 0U, 0U,
    0U, 91U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    0U, 0U, 0U, 0U, 26U, 207U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    180U, 63U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 101U, 139U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 31U, 197U, 7U, 0U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 1U, 183U, 47U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 110U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 37U, 186U, 2U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 2U, 185U, 34U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 78U,
    208U, 250U, MAX_uint8_T, MAX_uint8_T, 53U, 234U, 78U, 9U, 0U, 0U, 174U, 104U,
    0U, 0U, 0U, 0U, 224U, 29U, 0U, 0U, 0U, 0U, 248U, 7U, 0U, 0U, 0U, 0U, 225U,
    30U, 0U, 0U, 0U, 0U, 176U, 111U, 0U, 0U, 0U, 0U, 57U, 240U, 87U, 12U, 0U, 0U,
    0U, 85U, 213U, 252U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 177U, 81U, 0U, 0U,
    0U, 0U, 41U, 232U, 0U, 0U, 0U, 0U, 252U, 87U, 0U, 0U, 41U, 193U, 8U, 0U, 0U,
    0U, 0U, 87U, 156U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 8U, 206U, 125U, 0U, 0U, 0U,
    156U, 119U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 107U, 243U, 107U, 0U, 0U, 14U,
    220U, 48U, 220U, 14U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 41U, 193U, 8U, 0U, 87U, 156U, 0U, 0U,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 8U, 206U, 125U, 156U, 119U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 107U, 243U, 107U, 0U,
    14U, 220U, 48U, 220U, 14U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, 243U, 196U, 67U, 0U, 0U, MAX_uint8_T, 0U, 5U, 26U, 109U, 242U,
    51U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 123U, 176U, 0U, MAX_uint8_T, 0U, 0U,
    0U, 0U, 32U, 229U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U,
    0U, 9U, 249U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 38U, 226U, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 130U, 158U, 0U, MAX_uint8_T, 0U, 0U, 20U, 103U, 230U, 33U,
    0U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 240U, 176U, 41U, 0U, 0U, 0U, 161U,
    203U, 47U, 242U, 0U, 0U, 0U, 243U, 47U, 202U, 159U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 93U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 180U,
    19U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 49U, 157U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 143U, 68U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    0U, 13U, 192U, 9U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 83U, 136U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 175U, 46U, MAX_uint8_T, MAX_uint8_T,
    0U, 0U, 0U, 32U, 192U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, 119U,
    MAX_uint8_T, 0U, 41U, 193U, 8U, 0U, 0U, 0U, 0U, 0U, 87U, 156U, 0U, 0U, 0U,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 76U, 212U, 249U, 212U, 77U, 0U, 47U, 231U,
    73U, 14U, 74U, 233U, 48U, 169U, 101U, 0U, 0U, 0U, 104U, 170U, 223U, 27U, 0U,
    0U, 0U, 28U, 222U, 248U, 6U, 0U, 0U, 0U, 7U, 247U, 223U, 28U, 0U, 0U, 0U,
    30U, 222U, 170U, 103U, 0U, 0U, 0U, 105U, 169U, 49U, 233U, 72U, 14U, 74U,
    233U, 48U, 0U, 80U, 215U, 249U, 212U, 77U, 0U, 0U, 0U, 0U, 8U, 206U, 125U,
    0U, 0U, 0U, 0U, 156U, 119U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 76U,
    212U, 249U, 212U, 77U, 0U, 47U, 231U, 73U, 14U, 74U, 233U, 48U, 169U, 101U,
    0U, 0U, 0U, 104U, 170U, 223U, 27U, 0U, 0U, 0U, 28U, 222U, 248U, 6U, 0U, 0U,
    0U, 7U, 247U, 223U, 28U, 0U, 0U, 0U, 30U, 222U, 170U, 103U, 0U, 0U, 0U, 105U,
    169U, 49U, 233U, 72U, 14U, 74U, 233U, 48U, 0U, 80U, 215U, 249U, 212U, 77U,
    0U, 0U, 0U, 107U, 243U, 107U, 0U, 0U, 0U, 14U, 220U, 48U, 220U, 14U, 0U, 0U,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 76U, 212U, 249U, 212U, 77U, 0U, 47U, 231U, 73U,
    14U, 74U, 233U, 48U, 169U, 101U, 0U, 0U, 0U, 104U, 170U, 223U, 27U, 0U, 0U,
    0U, 28U, 222U, 248U, 6U, 0U, 0U, 0U, 7U, 247U, 223U, 28U, 0U, 0U, 0U, 30U,
    222U, 170U, 103U, 0U, 0U, 0U, 105U, 169U, 49U, 233U, 72U, 14U, 74U, 233U,
    48U, 0U, 80U, 215U, 249U, 212U, 77U, 0U, 0U, 0U, 161U, 203U, 47U, 242U, 0U,
    0U, 0U, 243U, 47U, 202U, 159U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 76U, 212U,
    249U, 212U, 77U, 0U, 47U, 231U, 73U, 14U, 74U, 233U, 48U, 169U, 101U, 0U, 0U,
    0U, 104U, 170U, 223U, 27U, 0U, 0U, 0U, 28U, 222U, 248U, 6U, 0U, 0U, 0U, 7U,
    247U, 223U, 28U, 0U, 0U, 0U, 30U, 222U, 170U, 103U, 0U, 0U, 0U, 105U, 169U,
    49U, 233U, 72U, 14U, 74U, 233U, 48U, 0U, 80U, 215U, 249U, 212U, 77U, 0U, 0U,
    0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    76U, 212U, 249U, 212U, 77U, 0U, 47U, 231U, 73U, 14U, 74U, 233U, 48U, 169U,
    101U, 0U, 0U, 0U, 104U, 170U, 223U, 27U, 0U, 0U, 0U, 28U, 222U, 248U, 6U, 0U,
    0U, 0U, 7U, 247U, 223U, 28U, 0U, 0U, 0U, 30U, 222U, 170U, 103U, 0U, 0U, 0U,
    105U, 169U, 49U, 233U, 72U, 14U, 74U, 233U, 48U, 0U, 80U, 215U, 249U, 212U,
    77U, 0U, 160U, 32U, 0U, 0U, 0U, 32U, 160U, 32U, 193U, 32U, 0U, 33U, 192U,
    32U, 0U, 33U, 194U, 67U, 193U, 32U, 0U, 0U, 0U, 68U, MAX_uint8_T, 64U, 0U,
    0U, 0U, 33U, 194U, 67U, 193U, 32U, 0U, 32U, 193U, 33U, 0U, 33U, 193U, 32U,
    160U, 32U, 0U, 0U, 0U, 32U, 160U, 0U, 0U, 76U, 213U, 246U, 202U, 100U, 203U,
    11U, 0U, 47U, 231U, 73U, 13U, 74U, 253U, 88U, 0U, 0U, 169U, 101U, 0U, 0U,
    138U, 192U, 172U, 0U, 0U, 223U, 27U, 0U, 69U, 180U, 26U, 226U, 0U, 0U, 248U,
    5U, 20U, 206U, 21U, 6U, 248U, 0U, 0U, 227U, 26U, 177U, 69U, 0U, 29U, 222U,
    0U, 0U, 173U, 192U, 138U, 0U, 0U, 105U, 169U, 0U, 0U, 88U, 253U, 74U, 12U,
    74U, 233U, 48U, 0U, 11U, 203U, 101U, 204U, 247U, 214U, 78U, 0U, 0U, 0U, 41U,
    193U, 8U, 0U, 0U, 0U, 0U, 87U, 156U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U,
    0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 252U, 1U, 0U,
    0U, 0U, 253U, 227U, 13U, 0U, 0U, 11U, 228U, 153U, 107U, 11U, 7U, 93U, 161U,
    18U, 163U, 234U, 239U, 174U, 23U, 0U, 0U, 8U, 206U, 125U, 0U, 0U, 0U, 156U,
    119U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U,
    0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    0U, 0U, 0U, 0U, MAX_uint8_T, 252U, 1U, 0U, 0U, 0U, 253U, 227U, 13U, 0U, 0U,
    11U, 228U, 153U, 107U, 11U, 7U, 93U, 161U, 18U, 163U, 234U, 239U, 174U, 23U,
    0U, 0U, 107U, 243U, 107U, 0U, 0U, 14U, 220U, 48U, 220U, 14U, 0U, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U,
    0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 252U, 1U,
    0U, 0U, 0U, 253U, 227U, 13U, 0U, 0U, 11U, 228U, 153U, 107U, 11U, 7U, 93U,
    161U, 18U, 163U, 234U, 239U, 174U, 23U, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U,
    0U, 0U, MAX_uint8_T, 252U, 1U, 0U, 0U, 0U, 253U, 227U, 13U, 0U, 0U, 11U,
    228U, 153U, 107U, 11U, 7U, 93U, 161U, 18U, 163U, 234U, 239U, 174U, 23U, 0U,
    0U, 0U, 8U, 206U, 125U, 0U, 0U, 0U, 0U, 156U, 119U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, 0U, 170U, 86U, 0U, 0U, 0U, 81U, 167U, 20U, 212U, 22U, 0U, 10U, 198U,
    17U, 0U, 81U, 173U, 0U, 133U, 70U, 0U, 0U, 0U, 165U, 128U, 142U, 0U, 0U, 0U,
    0U, 17U, MAX_uint8_T, 10U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U,
    0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 246U, 207U, 69U, MAX_uint8_T, 0U, 14U,
    106U, 224U, MAX_uint8_T, 0U, 0U, 7U, 237U, MAX_uint8_T, 0U, 12U, 97U, 158U,
    MAX_uint8_T, 252U, 224U, 140U, 11U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 95U, 234U, 227U, 64U, 0U, 224U, 58U, 40U, 229U, 0U, 252U, 0U,
    58U, 201U, 0U, MAX_uint8_T, 0U, 193U, 84U, 0U, MAX_uint8_T, 0U, 230U, 26U,
    0U, MAX_uint8_T, 0U, 63U, 170U, 33U, MAX_uint8_T, 0U, 0U, 33U, 209U,
    MAX_uint8_T, 0U, 0U, 50U, 220U, MAX_uint8_T, 0U, MAX_uint8_T, 239U, 73U, 0U,
    41U, 193U, 8U, 0U, 0U, 0U, 0U, 87U, 156U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    72U, 196U, 245U, 222U, 85U, 0U, 183U, 58U, 10U, 80U, 232U, 0U, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 28U, 159U, 227U, 248U, MAX_uint8_T, 0U, 202U, 126U, 24U,
    1U, MAX_uint8_T, 0U, 238U, 60U, 13U, 85U, MAX_uint8_T, 32U, 93U, 233U, 226U,
    116U, 138U, 220U, 0U, 8U, 206U, 125U, 0U, 0U, 0U, 156U, 119U, 0U, 0U, 0U, 0U,
    0U, 0U, 0U, 0U, 0U, 72U, 196U, 245U, 222U, 85U, 0U, 183U, 58U, 10U, 80U,
    232U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 28U, 159U, 227U, 248U,
    MAX_uint8_T, 0U, 202U, 126U, 24U, 1U, MAX_uint8_T, 0U, 238U, 60U, 13U, 85U,
    MAX_uint8_T, 32U, 93U, 233U, 226U, 116U, 138U, 220U, 0U, 107U, 243U, 107U,
    0U, 0U, 14U, 220U, 48U, 220U, 14U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 72U, 196U,
    245U, 222U, 85U, 0U, 183U, 58U, 10U, 80U, 232U, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 28U, 159U, 227U, 248U, MAX_uint8_T, 0U, 202U, 126U, 24U, 1U,
    MAX_uint8_T, 0U, 238U, 60U, 13U, 85U, MAX_uint8_T, 32U, 93U, 233U, 226U,
    116U, 138U, 220U, 0U, 161U, 203U, 47U, 242U, 0U, 0U, 243U, 47U, 202U, 159U,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 72U, 196U, 245U, 222U, 85U, 0U, 183U, 58U, 10U,
    80U, 232U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 28U, 159U, 227U, 248U,
    MAX_uint8_T, 0U, 202U, 126U, 24U, 1U, MAX_uint8_T, 0U, 238U, 60U, 13U, 85U,
    MAX_uint8_T, 32U, 93U, 233U, 226U, 116U, 138U, 220U, 0U, MAX_uint8_T, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 72U, 196U, 245U, 222U, 85U, 0U,
    183U, 58U, 10U, 80U, 232U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 28U, 159U,
    227U, 248U, MAX_uint8_T, 0U, 202U, 126U, 24U, 1U, MAX_uint8_T, 0U, 238U, 60U,
    13U, 85U, MAX_uint8_T, 32U, 93U, 233U, 226U, 116U, 138U, 220U, 0U, 0U, 135U,
    243U, 135U, 0U, 0U, 0U, 244U, 76U, 243U, 0U, 0U, 0U, 137U, 244U, 137U, 0U,
    0U, 0U, 0U, 0U, 0U, 0U, 72U, 196U, 245U, 222U, 85U, 0U, 183U, 58U, 10U, 80U,
    232U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 28U, 159U, 227U, 248U,
    MAX_uint8_T, 0U, 202U, 126U, 24U, 1U, MAX_uint8_T, 0U, 238U, 60U, 13U, 85U,
    MAX_uint8_T, 32U, 93U, 233U, 226U, 116U, 138U, 220U, 90U, 219U, 230U, 107U,
    177U, 241U, 183U, 17U, 158U, 28U, 62U, MAX_uint8_T, 108U, 10U, 118U, 144U,
    0U, 0U, 0U, MAX_uint8_T, 13U, 0U, 13U, 219U, 53U, 198U, 245U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 244U, 216U, 97U, 4U, MAX_uint8_T, 14U,
    0U, 0U, 0U, 237U, 48U, 73U, 234U, 119U, 14U, 0U, 0U, 89U, 238U, 152U, 20U,
    169U, 244U, MAX_uint8_T, MAX_uint8_T, 16U, 173U, 245U, MAX_uint8_T, 151U,
    118U, 7U, 0U, 227U, 15U, 0U, 0U, 248U, 2U, 0U, 0U, 222U, 17U, 0U, 0U, 138U,
    128U, 8U, 0U, 12U, 175U, 250U, MAX_uint8_T, 0U, 0U, 177U, 81U, 0U, 0U, 41U,
    232U, 0U, 0U, 252U, 87U, 0U, 41U, 193U, 8U, 0U, 0U, 0U, 87U, 156U, 0U, 0U,
    0U, 0U, 0U, 0U, 7U, 156U, 238U, 194U, 24U, 132U, 124U, 4U, 116U, 157U, 222U,
    35U, 0U, 13U, 227U, 246U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 251U, 215U,
    25U, 0U, 0U, 0U, 112U, 118U, 0U, 0U, 0U, 2U, 125U, 203U, 254U, MAX_uint8_T,
    0U, 0U, 8U, 206U, 125U, 0U, 0U, 156U, 119U, 0U, 0U, 0U, 0U, 0U, 0U, 7U, 156U,
    238U, 194U, 24U, 132U, 124U, 4U, 116U, 157U, 222U, 35U, 0U, 13U, 227U, 246U,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 251U, 215U, 25U, 0U, 0U, 0U, 112U,
    118U, 0U, 0U, 0U, 2U, 125U, 203U, 254U, MAX_uint8_T, 0U, 107U, 243U, 107U,
    0U, 14U, 220U, 48U, 220U, 14U, 0U, 0U, 0U, 0U, 0U, 7U, 156U, 238U, 194U, 24U,
    132U, 124U, 4U, 116U, 157U, 222U, 35U, 0U, 13U, 227U, 246U, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, 251U, 215U, 25U, 0U, 0U, 0U, 112U, 118U, 0U, 0U,
    0U, 2U, 125U, 203U, 254U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U,
    0U, 0U, 0U, 0U, 0U, 7U, 156U, 238U, 194U, 24U, 132U, 124U, 4U, 116U, 157U,
    222U, 35U, 0U, 13U, 227U, 246U, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 251U,
    215U, 25U, 0U, 0U, 0U, 112U, 118U, 0U, 0U, 0U, 2U, 125U, 203U, 254U,
    MAX_uint8_T, 41U, 193U, 8U, 0U, 87U, 156U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 8U, 206U, 125U, 156U,
    119U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 107U, 243U, 107U, 0U, 14U, 220U, 48U, 220U, 14U, 0U,
    0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T,
    0U, 0U, MAX_uint8_T, 0U, 0U, MAX_uint8_T, 0U, 0U, 2U, 34U, 159U, 0U, 244U,
    225U, MAX_uint8_T, 98U, 0U, 0U, 159U, 102U, 233U, 11U, 15U, 178U, 241U, 253U,
    99U, 147U, 83U, 5U, 73U, 177U, 226U, 10U, 0U, 8U, 230U, 248U, 2U, 0U, 2U,
    248U, 223U, 11U, 0U, 13U, 223U, 142U, 84U, 4U, 89U, 141U, 13U, 174U, 241U,
    174U, 13U, 0U, 161U, 203U, 47U, 242U, 0U, 243U, 47U, 202U, 159U, 0U, 0U, 0U,
    0U, 0U, MAX_uint8_T, 66U, 217U, 239U, 96U, MAX_uint8_T, 182U, 36U, 56U, 232U,
    MAX_uint8_T, 15U, 0U, 2U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, 41U, 193U, 8U, 0U, 0U, 0U, 87U, 156U,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 17U, 179U, 229U, 179U, 17U, 150U, 131U, 1U, 131U,
    149U, 226U, 26U, 0U, 27U, 226U, 249U, 5U, 0U, 5U, 248U, 226U, 26U, 0U, 28U,
    225U, 148U, 130U, 1U, 133U, 149U, 16U, 179U, 229U, 178U, 17U, 0U, 0U, 8U,
    206U, 125U, 0U, 0U, 156U, 119U, 0U, 0U, 0U, 0U, 0U, 0U, 17U, 179U, 229U,
    179U, 17U, 150U, 131U, 1U, 131U, 149U, 226U, 26U, 0U, 27U, 226U, 249U, 5U,
    0U, 5U, 248U, 226U, 26U, 0U, 28U, 225U, 148U, 130U, 1U, 133U, 149U, 16U,
    179U, 229U, 178U, 17U, 0U, 107U, 243U, 107U, 0U, 14U, 220U, 48U, 220U, 14U,
    0U, 0U, 0U, 0U, 0U, 17U, 179U, 229U, 179U, 17U, 150U, 131U, 1U, 131U, 149U,
    226U, 26U, 0U, 27U, 226U, 249U, 5U, 0U, 5U, 248U, 226U, 26U, 0U, 28U, 225U,
    148U, 130U, 1U, 133U, 149U, 16U, 179U, 229U, 178U, 17U, 0U, 161U, 203U, 47U,
    242U, 0U, 243U, 47U, 202U, 159U, 0U, 0U, 0U, 0U, 0U, 17U, 179U, 229U, 179U,
    17U, 150U, 131U, 1U, 131U, 149U, 226U, 26U, 0U, 27U, 226U, 249U, 5U, 0U, 5U,
    248U, 226U, 26U, 0U, 28U, 225U, 148U, 130U, 1U, 133U, 149U, 16U, 179U, 229U,
    178U, 17U, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 17U,
    179U, 229U, 179U, 17U, 150U, 131U, 1U, 131U, 149U, 226U, 26U, 0U, 27U, 226U,
    249U, 5U, 0U, 5U, 248U, 226U, 26U, 0U, 28U, 225U, 148U, 130U, 1U, 133U, 149U,
    16U, 179U, 229U, 178U, 17U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T,
    MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U,
    0U, 21U, 191U, 242U, 180U, 179U, 156U, 128U, 14U, 160U, 150U, 228U, 23U, 33U,
    145U, 226U, 249U, 10U, 140U, 10U, 248U, 229U, 144U, 33U, 24U, 228U, 155U,
    159U, 14U, 129U, 156U, 182U, 179U, 242U, 192U, 23U, 41U, 193U, 8U, 0U, 0U,
    0U, 87U, 156U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 1U, 0U, 15U,
    MAX_uint8_T, 227U, 56U, 34U, 181U, MAX_uint8_T, 49U, 205U, 218U, 65U,
    MAX_uint8_T, 0U, 0U, 8U, 206U, 125U, 0U, 0U, 156U, 119U, 0U, 0U, 0U, 0U, 0U,
    0U, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 1U, 0U, 15U, MAX_uint8_T, 227U, 56U, 34U, 181U,
    MAX_uint8_T, 49U, 205U, 218U, 65U, MAX_uint8_T, 0U, 107U, 243U, 107U, 0U,
    14U, 220U, 48U, 220U, 14U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U,
    MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 1U, 0U, 15U,
    MAX_uint8_T, 227U, 56U, 34U, 181U, MAX_uint8_T, 49U, 205U, 218U, 65U,
    MAX_uint8_T, 0U, MAX_uint8_T, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T, MAX_uint8_T, 0U, 0U, 0U, MAX_uint8_T,
    MAX_uint8_T, 1U, 0U, 15U, MAX_uint8_T, 227U, 56U, 34U, 181U, MAX_uint8_T,
    49U, 205U, 218U, 65U, MAX_uint8_T, 0U, 0U, 0U, 0U, 8U, 206U, 125U, 0U, 0U,
    0U, 0U, 0U, 0U, 156U, 119U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    18U, 225U, 7U, 0U, 0U, 0U, 12U, 223U, 16U, 0U, 154U, 95U, 0U, 0U, 0U, 116U,
    137U, 0U, 0U, 44U, 203U, 0U, 0U, 7U, 222U, 24U, 0U, 0U, 0U, 189U, 57U, 0U,
    104U, 151U, 0U, 0U, 0U, 0U, 79U, 166U, 3U, 218U, 33U, 0U, 0U, 0U, 0U, 2U,
    216U, 117U, 164U, 0U, 0U, 0U, 0U, 0U, 0U, 114U, 252U, 44U, 0U, 0U, 0U, 0U,
    0U, 0U, 81U, 177U, 0U, 0U, 0U, 0U, 0U, 0U, 2U, 210U, 56U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 40U, 205U, 241U, 170U, 16U, MAX_uint8_T, 169U, 53U, 6U, 85U,
    152U, MAX_uint8_T, 31U, 0U, 0U, 10U, 229U, MAX_uint8_T, 0U, 0U, 0U, 6U, 251U,
    MAX_uint8_T, 29U, 0U, 0U, 34U, 233U, MAX_uint8_T, 180U, 39U, 0U, 113U, 170U,
    MAX_uint8_T, 56U, 221U, 185U, 159U, 25U, MAX_uint8_T, 0U, 0U, 0U, 0U, 0U,
    MAX_uint8_T, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, MAX_uint8_T, 0U, MAX_uint8_T,
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 18U, 225U, 7U, 0U, 0U, 0U,
    12U, 223U, 16U, 0U, 154U, 95U, 0U, 0U, 0U, 116U, 137U, 0U, 0U, 44U, 203U, 0U,
    0U, 7U, 222U, 24U, 0U, 0U, 0U, 189U, 57U, 0U, 104U, 151U, 0U, 0U, 0U, 0U,
    79U, 166U, 3U, 218U, 33U, 0U, 0U, 0U, 0U, 2U, 216U, 117U, 164U, 0U, 0U, 0U,
    0U, 0U, 0U, 114U, 252U, 44U, 0U, 0U, 0U, 0U, 0U, 0U, 81U, 177U, 0U, 0U, 0U,
    0U, 0U, 0U, 2U, 210U, 56U, 0U, 0U, 0U, 0U };

  int8_T varargin_1[2];
  real_T n;
  int8_T num[2];
  int32_T thisGlyphBitmap_size[2];
  uint8_T b_thisGlyphBitmap_data[144];
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  penX = textLocationXY_x;
  if (textLocationXY_y > 2147483636) {
    penY = MAX_int32_T;
  } else {
    penY = textLocationXY_y + 11;
  }

  loop_ub = ucTextU16_size[0] * ucTextU16_size[1];
  for (i65 = 0; i65 < loop_ub; i65++) {
    isNewLineChar_data[i65] = (ucTextU16_data[i65] == 10);
  }

  for (i = 0; i < ucTextU16_size[1]; i++) {
    i65 = 1 + i;
    if (!((i65 >= 1) && (i65 <= ucTextU16_size[1]))) {
      emlrtDynamicBoundsCheckR2012b(i65, 1, ucTextU16_size[1], &bg_emlrtBCI, sp);
    }

    if (isNewLineChar_data[i65 - 1]) {
      if (penY > 2147483633) {
        penY = MAX_int32_T;
      } else {
        penY += 14;
      }

      penX = textLocationXY_x;
    } else {
      i65 = i + 1;
      if (!((i65 >= 1) && (i65 <= ucTextU16_size[1]))) {
        emlrtDynamicBoundsCheckR2012b(i65, 1, ucTextU16_size[1], &ag_emlrtBCI,
          sp);
      }

      u1 = ucTextU16_data[i] + 1U;
      if (u1 > 65535U) {
        u1 = 65535U;
      }

      if (!(uv0[(int32_T)u1 - 1] != 0)) {
        if (penX > 2147483643) {
          penX = MAX_int32_T;
        } else {
          penX += 4;
        }
      } else {
        u1 = ucTextU16_data[i] + 1U;
        if (u1 > 65535U) {
          u1 = 65535U;
        }

        bitmapEndIdx_1b = iv35[uv0[(int32_T)u1 - 1]];
        if ((penX < 0) && (bitmapEndIdx_1b < MIN_int32_T - penX)) {
          xx = MIN_int32_T;
        } else if ((penX > 0) && (bitmapEndIdx_1b > MAX_int32_T - penX)) {
          xx = MAX_int32_T;
        } else {
          xx = penX + bitmapEndIdx_1b;
        }

        u1 = ucTextU16_data[i] + 1U;
        if (u1 > 65535U) {
          u1 = 65535U;
        }

        bitmapEndIdx_1b = iv36[uv0[(int32_T)u1 - 1]];
        if ((penY >= 0) && (bitmapEndIdx_1b < penY - MAX_int32_T)) {
          yy = MAX_int32_T;
        } else if ((penY < 0) && (bitmapEndIdx_1b > penY - MIN_int32_T)) {
          yy = MIN_int32_T;
        } else {
          yy = penY - bitmapEndIdx_1b;
        }

        u1 = ucTextU16_data[i] + 1U;
        if (u1 > 65535U) {
          u1 = 65535U;
        }

        bitmapEndIdx_1b = iv37[uv0[(int32_T)u1 - 1]];
        if (yy > MAX_int32_T - bitmapEndIdx_1b) {
          bitmapEndIdx_1b = MAX_int32_T;
        } else {
          bitmapEndIdx_1b += yy;
        }

        if (bitmapEndIdx_1b < -2147483647) {
          endR_im = MIN_int32_T;
        } else {
          endR_im = bitmapEndIdx_1b - 1;
        }

        u1 = ucTextU16_data[i] + 1U;
        if (u1 > 65535U) {
          u1 = 65535U;
        }

        bitmapEndIdx_1b = iv38[uv0[(int32_T)u1 - 1]];
        if (xx > MAX_int32_T - bitmapEndIdx_1b) {
          bitmapEndIdx_1b = MAX_int32_T;
        } else {
          bitmapEndIdx_1b += xx;
        }

        if (bitmapEndIdx_1b < -2147483647) {
          endC_im = MIN_int32_T;
        } else {
          endC_im = bitmapEndIdx_1b - 1;
        }

        if ((yy > 514) || (endR_im < 1) || (xx > 719) || (endC_im < 1)) {
        } else {
          startR_gl = 1;
          startC_gl = 1;
          u1 = ucTextU16_data[i] + 1U;
          if (u1 > 65535U) {
            u1 = 65535U;
          }

          endR_gl = iv37[uv0[(int32_T)u1 - 1]];
          u1 = ucTextU16_data[i] + 1U;
          if (u1 > 65535U) {
            u1 = 65535U;
          }

          endC_gl = iv38[uv0[(int32_T)u1 - 1]];
          if (yy < 1) {
            if (yy <= MIN_int32_T) {
              bitmapEndIdx_1b = MAX_int32_T;
            } else {
              bitmapEndIdx_1b = -yy;
            }

            if (bitmapEndIdx_1b > 2147483645) {
              startR_gl = MAX_int32_T;
            } else {
              startR_gl = bitmapEndIdx_1b + 2;
            }

            yy = 1;
          }

          if (endR_im > 514) {
            u1 = ucTextU16_data[i] + 1U;
            if (u1 > 65535U) {
              u1 = 65535U;
            }

            endR_gl = (iv37[uv0[(int32_T)u1 - 1]] - endR_im) + 514;
            endR_im = 514;
          }

          if (xx < 1) {
            if (xx <= MIN_int32_T) {
              bitmapEndIdx_1b = MAX_int32_T;
            } else {
              bitmapEndIdx_1b = -xx;
            }

            if (bitmapEndIdx_1b > 2147483645) {
              startC_gl = MAX_int32_T;
            } else {
              startC_gl = bitmapEndIdx_1b + 2;
            }

            xx = 1;
          }

          if (endC_im > 719) {
            u1 = ucTextU16_data[i] + 1U;
            if (u1 > 65535U) {
              u1 = 65535U;
            }

            endC_gl = (iv38[uv0[(int32_T)u1 - 1]] - endC_im) + 719;
            endC_im = 719;
          }

          u1 = ucTextU16_data[i] + 1U;
          if (u1 > 65535U) {
            u1 = 65535U;
          }

          u2 = ucTextU16_data[i] + 1U;
          if (u2 > 65535U) {
            u2 = 65535U;
          }

          u3 = ucTextU16_data[i] + 1U;
          if (u3 > 65535U) {
            u3 = 65535U;
          }

          bitmapEndIdx_1b = (int32_T)(((iv39[uv0[(int32_T)u1 - 1]] + 1U) +
            iv38[uv0[(int32_T)u2 - 1]] * iv37[uv0[(int32_T)u3 - 1]]) - 1U);
          u1 = ucTextU16_data[i] + 1U;
          if (u1 > 65535U) {
            u1 = 65535U;
          }

          if (iv39[uv0[(int32_T)u1 - 1]] + 1U > (uint32_T)bitmapEndIdx_1b) {
            i65 = 0;
            bitmapEndIdx_1b = 0;
          } else {
            u1 = ucTextU16_data[i] + 1U;
            if (u1 > 65535U) {
              u1 = 65535U;
            }

            i65 = iv39[uv0[(int32_T)u1 - 1]];
            if (!((bitmapEndIdx_1b >= 1) && (bitmapEndIdx_1b <= 9304))) {
              emlrtDynamicBoundsCheckR2012b(bitmapEndIdx_1b, 1, 9304,
                &yf_emlrtBCI, sp);
            }
          }

          thisGlyphBitmap_size_idx_1 = bitmapEndIdx_1b - i65;
          loop_ub = bitmapEndIdx_1b - i65;
          for (i66 = 0; i66 < loop_ub; i66++) {
            thisGlyphBitmap_data[i66] = uv2[i65 + i66];
          }

          st.site = &hs_emlrtRSI;
          u1 = ucTextU16_data[i] + 1U;
          if (u1 > 65535U) {
            u1 = 65535U;
          }

          varargin_1[0] = iv38[uv0[(int32_T)u1 - 1]];
          u1 = ucTextU16_data[i] + 1U;
          if (u1 > 65535U) {
            u1 = 65535U;
          }

          varargin_1[1] = iv37[uv0[(int32_T)u1 - 1]];
          b_st.site = &ui_emlrtRSI;
          n = 1.0;
          for (bitmapEndIdx_1b = 0; bitmapEndIdx_1b < 2; bitmapEndIdx_1b++) {
            if (varargin_1[bitmapEndIdx_1b] <= 0) {
              n = 0.0;
            } else {
              n *= (real_T)varargin_1[bitmapEndIdx_1b];
            }
          }

          if (!(n <= 2.147483647E+9)) {
            emlrtErrorWithMessageIdR2018a(&b_st, &hf_emlrtRTEI,
              "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
          }

          for (i65 = 0; i65 < 2; i65++) {
            num[i65] = varargin_1[i65];
          }

          bitmapEndIdx_1b = 1;
          if (thisGlyphBitmap_size_idx_1 > 1) {
            bitmapEndIdx_1b = thisGlyphBitmap_size_idx_1;
          }

          bitmapEndIdx_1b = muIntScalarMax_sint32(thisGlyphBitmap_size_idx_1,
            bitmapEndIdx_1b);
          if (num[0] > bitmapEndIdx_1b) {
            b_st.site = &vi_emlrtRSI;
            d_error(&b_st);
          }

          if (num[1] > bitmapEndIdx_1b) {
            b_st.site = &vi_emlrtRSI;
            d_error(&b_st);
          }

          if (num[0] * num[1] != thisGlyphBitmap_size_idx_1) {
            emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
              "Coder:MATLAB:getReshapeDims_notSameNumel",
              "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
          }

          thisGlyphBitmap_size[0] = num[1];
          thisGlyphBitmap_size[1] = num[0];
          loop_ub = num[0];
          for (i65 = 0; i65 < loop_ub; i65++) {
            bitmapEndIdx_1b = num[1];
            for (i66 = 0; i66 < bitmapEndIdx_1b; i66++) {
              b_thisGlyphBitmap_data[i66 + thisGlyphBitmap_size[0] * i65] =
                thisGlyphBitmap_data[i65 + num[0] * i66];
            }
          }

          st.site = &is_emlrtRSI;
          doGlyph_uint8(&st, imgIn, b_thisGlyphBitmap_data, thisGlyphBitmap_size,
                        yy, xx, endR_im, endC_im, startR_gl, startC_gl, endR_gl,
                        endC_gl);
        }

        u1 = ucTextU16_data[i] + 1U;
        if (u1 > 65535U) {
          u1 = 65535U;
        }

        bitmapEndIdx_1b = iv0[uv0[(int32_T)u1 - 1]];
        if ((penX < 0) && (bitmapEndIdx_1b < MIN_int32_T - penX)) {
          penX = MIN_int32_T;
        } else if ((penX > 0) && (bitmapEndIdx_1b > MAX_int32_T - penX)) {
          penX = MAX_int32_T;
        } else {
          penX += bitmapEndIdx_1b;
        }
      }
    }
  }
}

static void insertTextBox(const emlrtStack *sp, uint8_T RGB[1108698], const
  int32_T position[2], const uint16_T ucTextU16_data[], const int32_T
  ucTextU16_size[2], const uint8_T boxColor_data[], int32_T shapeWidth, int32_T
  shapeHeight, int32_T *textLocationXY_x, int32_T *textLocationXY_y)
{
  int32_T tbWidth;
  int32_T tbHeight;
  int32_T q0;
  int32_T qY;
  int32_T b_qY;
  int32_T tbTopLeftX;
  int32_T startR;
  boolean_T guard1 = false;
  int32_T endR;
  int32_T adjBorder;
  int32_T startC;
  real_T d3;
  uint8_T tmp11;
  uint8_T tmp22;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &qr_emlrtRSI;
  getTextboxWidthHeight(&st, ucTextU16_data, ucTextU16_size, shapeWidth,
                        &tbWidth, &tbHeight);
  if (tbWidth > shapeWidth) {
    if (tbWidth > 2147483639) {
      tbWidth = MAX_int32_T;
    } else {
      tbWidth += 8;
    }
  }

  if (tbHeight > 2147483639) {
    tbHeight = MAX_int32_T;
  } else {
    tbHeight += 8;
  }

  q0 = position[1];
  if ((q0 >= 0) && (tbHeight < q0 - MAX_int32_T)) {
    qY = MAX_int32_T;
  } else if ((q0 < 0) && (tbHeight > q0 - MIN_int32_T)) {
    qY = MIN_int32_T;
  } else {
    qY = q0 - tbHeight;
  }

  if (qY > 2147483646) {
    b_qY = MAX_int32_T;
  } else {
    b_qY = qY + 1;
  }

  tbTopLeftX = position[0];
  if ((shapeWidth > 0) && (shapeHeight > 0)) {
    if ((b_qY < 0) && (tbHeight < MIN_int32_T - b_qY)) {
      qY = MIN_int32_T;
    } else if ((b_qY > 0) && (tbHeight > MAX_int32_T - b_qY)) {
      qY = MAX_int32_T;
    } else {
      qY = b_qY + tbHeight;
    }

    guard1 = false;
    if (position[0] <= 719) {
      q0 = position[0];
      if ((q0 < 0) && (shapeWidth < MIN_int32_T - q0)) {
        adjBorder = MIN_int32_T;
      } else if ((q0 > 0) && (shapeWidth > MAX_int32_T - q0)) {
        adjBorder = MAX_int32_T;
      } else {
        adjBorder = q0 + shapeWidth;
      }

      if ((adjBorder - 1 >= 1) && (qY <= 514)) {
        if ((qY < 0) && (shapeHeight < MIN_int32_T - qY)) {
          qY = MIN_int32_T;
        } else if ((qY > 0) && (shapeHeight > MAX_int32_T - qY)) {
          qY = MAX_int32_T;
        } else {
          qY += shapeHeight;
        }

        if (qY - 1 >= 1) {
          if (b_qY < 1) {
            if ((b_qY < 0) && (tbHeight < MIN_int32_T - b_qY)) {
              qY = MIN_int32_T;
            } else {
              qY = b_qY + tbHeight;
            }

            if ((qY < 0) && (shapeHeight < MIN_int32_T - qY)) {
              qY = MIN_int32_T;
            } else if ((qY > 0) && (shapeHeight > MAX_int32_T - qY)) {
              qY = MAX_int32_T;
            } else {
              qY += shapeHeight;
            }

            if (qY >= 1) {
              q0 = position[1];
              if ((q0 < 0) && (shapeHeight < MIN_int32_T - q0)) {
                qY = MIN_int32_T;
              } else if ((q0 > 0) && (shapeHeight > MAX_int32_T - q0)) {
                qY = MAX_int32_T;
              } else {
                qY = q0 + shapeHeight;
              }

              if (qY > 2147483646) {
                b_qY = MAX_int32_T;
              } else {
                b_qY = qY + 1;
              }
            }
          }

          q0 = position[0];
          if ((q0 < 0) && (tbWidth < MIN_int32_T - q0)) {
            qY = MIN_int32_T;
          } else if ((q0 > 0) && (tbWidth > MAX_int32_T - q0)) {
            qY = MAX_int32_T;
          } else {
            qY = q0 + tbWidth;
          }

          d3 = (real_T)qY - 719.0;
          if (d3 >= -2.147483648E+9) {
            adjBorder = (int32_T)d3;
          } else {
            adjBorder = MIN_int32_T;
          }

          if ((adjBorder > 0) && (position[0] <= 719)) {
            q0 = position[0];
            if ((q0 >= 0) && (adjBorder < q0 - MAX_int32_T)) {
              qY = MAX_int32_T;
            } else if ((q0 < 0) && (adjBorder > q0 - MIN_int32_T)) {
              qY = MIN_int32_T;
            } else {
              qY = q0 - adjBorder;
            }

            tbTopLeftX = qY + 1;
          }

          if (tbTopLeftX < 1) {
            q0 = position[0];
            if ((q0 < 0) && (shapeWidth < MIN_int32_T - q0)) {
              qY = MIN_int32_T;
            } else if ((q0 > 0) && (shapeWidth > MAX_int32_T - q0)) {
              qY = MAX_int32_T;
            } else {
              qY = q0 + shapeWidth;
            }

            if (qY >= 1) {
              tbTopLeftX = 1;
            }
          }
        } else {
          guard1 = true;
        }
      } else {
        guard1 = true;
      }
    } else {
      guard1 = true;
    }

    if (guard1) {
      b_qY = -32767;
      tbTopLeftX = -32767;
    }
  }

  startR = b_qY - 1;
  if ((b_qY < 0) && (tbHeight < MIN_int32_T - b_qY)) {
    qY = MIN_int32_T;
  } else if ((b_qY > 0) && (tbHeight > MAX_int32_T - b_qY)) {
    qY = MAX_int32_T;
  } else {
    qY = b_qY + tbHeight;
  }

  if (qY < -2147483647) {
    endR = MIN_int32_T;
  } else {
    endR = qY - 1;
  }

  startC = tbTopLeftX - 1;
  if ((tbTopLeftX < 0) && (tbWidth < MIN_int32_T - tbTopLeftX)) {
    qY = MIN_int32_T;
  } else if ((tbTopLeftX > 0) && (tbWidth > MAX_int32_T - tbTopLeftX)) {
    qY = MAX_int32_T;
  } else {
    qY = tbTopLeftX + tbWidth;
  }

  if (qY < -2147483647) {
    adjBorder = MIN_int32_T;
  } else {
    adjBorder = qY - 1;
  }

  if ((b_qY > 514) || (endR < 1) || (tbTopLeftX > 719) || (adjBorder < 1)) {
  } else {
    if (b_qY < 1) {
      startR = 0;
    }

    if (endR > 514) {
      endR = 514;
    }

    if (tbTopLeftX < 1) {
      startC = 0;
    }

    if (adjBorder > 719) {
      adjBorder = 719;
    }

    for (q0 = 0; q0 < 3; q0++) {
      for (tbHeight = startC; tbHeight < adjBorder; tbHeight++) {
        for (qY = startR; qY < endR; qY++) {
          tmp11 = (uint8_T)(0.6 * (real_T)boxColor_data[q0] + 0.5);
          tmp22 = (uint8_T)(0.4 * (real_T)RGB[(qY + 514 * tbHeight) + 369566 *
                            q0] + 0.5);
          tbWidth = (int32_T)((uint32_T)tmp11 + tmp22);
          if ((uint32_T)tbWidth > 255U) {
            tbWidth = 255;
          }

          RGB[(qY + 514 * tbHeight) + 369566 * q0] = (uint8_T)tbWidth;
        }
      }
    }
  }

  if (tbTopLeftX > 2147483643) {
    *textLocationXY_x = MAX_int32_T;
  } else {
    *textLocationXY_x = tbTopLeftX + 4;
  }

  if (b_qY > 2147483643) {
    *textLocationXY_y = MAX_int32_T;
  } else {
    *textLocationXY_y = b_qY + 4;
  }
}

void insertText(const emlrtStack *sp, const uint8_T I[1108698], const int32_T
                position_data[], const int32_T position_size[2], const real32_T
                text_data[], const int32_T text_size[2], const uint8_T
                varargin_6_data[], const int32_T varargin_6_size[2], const
                uint8_T varargin_8_data[], const int32_T varargin_8_size[2],
                const int32_T varargin_14_data[], const int32_T
                varargin_14_size[1], const int32_T varargin_16_data[], const
                int32_T varargin_16_size[1], uint8_T RGB[1108698])
{
  int32_T b_position_size[2];
  int32_T endIdx;
  int32_T b_position_data[198];
  int32_T b_text_size[2];
  real32_T b_text_data[99];
  int32_T textColor_size[2];
  uint8_T textColor_data[297];
  int32_T boxColor_size[2];
  uint8_T boxColor_data[297];
  boolean_T isScalarText;
  int32_T shapeWidth_data[9801];
  int32_T shapeWidth_size[2];
  int32_T shapeHeight_data[9801];
  int32_T shapeHeight_size[2];
  boolean_T isEmpty;
  int32_T textIdx;
  int32_T ii;
  int32_T i;
  char_T str1[30];
  char_T cv14[6];
  static const char_T cv15[6] = { '%', '0', '.', '5', 'g', '\x00' };

  boolean_T exitg1;
  int32_T thisTextU16_size[2];
  uint16_T thisTextU16_data[29];
  int32_T position[2];
  uint8_T b_boxColor_data[3];
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  memcpy(&RGB[0], &I[0], 1108698U * sizeof(uint8_T));
  b_position_size[0] = position_size[0];
  b_position_size[1] = 2;
  endIdx = position_size[0] * position_size[1];
  if (0 <= endIdx - 1) {
    memcpy(&b_position_data[0], &position_data[0], (uint32_T)(endIdx * (int32_T)
            sizeof(int32_T)));
  }

  b_text_size[0] = 1;
  b_text_size[1] = text_size[1];
  endIdx = text_size[0] * text_size[1];
  if (0 <= endIdx - 1) {
    memcpy(&b_text_data[0], &text_data[0], (uint32_T)(endIdx * (int32_T)sizeof
            (real32_T)));
  }

  textColor_size[0] = varargin_6_size[0];
  textColor_size[1] = 3;
  endIdx = varargin_6_size[0] * varargin_6_size[1];
  if (0 <= endIdx - 1) {
    memcpy(&textColor_data[0], &varargin_6_data[0], (uint32_T)(endIdx * (int32_T)
            sizeof(uint8_T)));
  }

  boxColor_size[0] = varargin_8_size[0];
  boxColor_size[1] = 3;
  endIdx = varargin_8_size[0] * varargin_8_size[1];
  if (0 <= endIdx - 1) {
    memcpy(&boxColor_data[0], &varargin_8_data[0], (uint32_T)(endIdx * (int32_T)
            sizeof(uint8_T)));
  }

  st.site = &uq_emlrtRSI;
  c_validateAndParseInputs(&st, b_position_size, b_text_data, b_text_size,
    textColor_data, textColor_size, boxColor_data, boxColor_size,
    varargin_14_data, varargin_14_size, varargin_16_data, varargin_16_size,
    &isScalarText, shapeWidth_data, shapeWidth_size, shapeHeight_data,
    shapeHeight_size, &isEmpty);
  if (!isEmpty) {
    textIdx = 1;
    for (ii = 1; ii - 1 < b_position_size[0]; ii++) {
      if (!isScalarText) {
        textIdx = ii;
      }

      if (!((textIdx >= 1) && (textIdx <= b_text_size[1]))) {
        emlrtDynamicBoundsCheckR2012b(textIdx, 1, b_text_size[1], &ue_emlrtBCI,
          sp);
      }

      for (i = 0; i < 30; i++) {
        str1[i] = '\x00';
      }

      for (i = 0; i < 6; i++) {
        cv14[i] = cv15[i];
      }

      sprintf(str1, cv14, (real_T)b_text_data[textIdx - 1]);
      endIdx = 0;
      i = 0;
      exitg1 = false;
      while ((!exitg1) && (i < 30)) {
        if ((uint8_T)str1[i] == 0) {
          endIdx = i;
          exitg1 = true;
        } else {
          i++;
        }
      }

      if (1 > endIdx) {
        endIdx = 0;
      }

      thisTextU16_size[0] = 1;
      thisTextU16_size[1] = endIdx;
      for (i = 0; i < endIdx; i++) {
        thisTextU16_data[i] = (uint8_T)str1[i];
      }

      if (!(endIdx == 0)) {
        if (!((ii >= 1) && (ii <= b_position_size[0]))) {
          emlrtDynamicBoundsCheckR2012b(ii, 1, b_position_size[0], &ve_emlrtBCI,
            sp);
        }

        for (i = 0; i < 2; i++) {
          position[i] = b_position_data[(ii + b_position_size[0] * i) - 1];
        }

        if (!((ii >= 1) && (ii <= boxColor_size[0]))) {
          emlrtDynamicBoundsCheckR2012b(ii, 1, boxColor_size[0], &we_emlrtBCI,
            sp);
        }

        for (i = 0; i < 3; i++) {
          b_boxColor_data[i] = boxColor_data[(ii + boxColor_size[0] * i) - 1];
        }

        if (!((ii >= 1) && (ii <= shapeWidth_size[0]))) {
          emlrtDynamicBoundsCheckR2012b(ii, 1, shapeWidth_size[0], &ye_emlrtBCI,
            sp);
        }

        if (!((ii >= 1) && (ii <= shapeHeight_size[0]))) {
          emlrtDynamicBoundsCheckR2012b(ii, 1, shapeHeight_size[0], &af_emlrtBCI,
            sp);
        }

        st.site = &wq_emlrtRSI;
        insertTextBox(&st, RGB, position, thisTextU16_data, thisTextU16_size,
                      b_boxColor_data, shapeWidth_data[ii - 1],
                      shapeHeight_data[ii - 1], &endIdx, &i);
        if (!((ii >= 1) && (ii <= textColor_size[0]))) {
          emlrtDynamicBoundsCheckR2012b(ii, 1, textColor_size[0], &xe_emlrtBCI,
            sp);
        }

        st.site = &xq_emlrtRSI;
        insertGlyphs(&st, RGB, thisTextU16_data, thisTextU16_size, endIdx, i);
      }
    }
  }
}

/* End of code generation (insertText.c) */
