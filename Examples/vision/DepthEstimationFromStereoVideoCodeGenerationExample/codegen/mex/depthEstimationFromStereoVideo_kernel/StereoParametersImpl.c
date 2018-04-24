/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * StereoParametersImpl.c
 *
 * Code generation for function 'StereoParametersImpl'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include <string.h>
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "StereoParametersImpl.h"
#include "CameraParametersImpl.h"
#include "sort1.h"
#include "matlabCodegenHandle.h"
#include "det.h"
#include "mrdivide.h"
#include "rodriguesVectorToMatrix.h"
#include "error.h"
#include "norm.h"
#include "svd1.h"
#include "rdivide.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "eml_int_forloop_overflow_check.h"
#include "assertValidSizeArg.h"
#include "bsxfun.h"
#include "meshgrid.h"
#include "isequal.h"
#include "all.h"
#include "ImageTransformer.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "blas.h"

/* Variable Definitions */
static emlrtRSInfo x_emlrtRSI = { 74,  /* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo y_emlrtRSI = { 75,  /* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo ab_emlrtRSI = { 76, /* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo bb_emlrtRSI = { 77, /* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo cb_emlrtRSI = { 81, /* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo fb_emlrtRSI = { 62, /* lineNo */
  "RectificationParameters",           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\RectificationParameters.m"/* pathName */
};

static emlrtRSInfo sb_emlrtRSI = { 331,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo tb_emlrtRSI = { 333,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo ub_emlrtRSI = { 334,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo vb_emlrtRSI = { 340,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo wb_emlrtRSI = { 350,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo xb_emlrtRSI = { 342,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo yb_emlrtRSI = { 343,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo ac_emlrtRSI = { 465,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo bc_emlrtRSI = { 475,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo cc_emlrtRSI = { 482,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo dc_emlrtRSI = { 489,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo ec_emlrtRSI = { 496,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo fc_emlrtRSI = { 503,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo gc_emlrtRSI = { 510,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo hc_emlrtRSI = { 518,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo jc_emlrtRSI = { 67, /* lineNo */
  "validatestring",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\lang\\validatestring.m"/* pathName */
};

static emlrtRSInfo kc_emlrtRSI = { 98, /* lineNo */
  "validatestring",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\lang\\validatestring.m"/* pathName */
};

static emlrtRSInfo lc_emlrtRSI = { 140,/* lineNo */
  "validatestring",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\lang\\validatestring.m"/* pathName */
};

static emlrtRSInfo mc_emlrtRSI = { 61, /* lineNo */
  "strcmp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\strcmp.m"/* pathName */
};

static emlrtRSInfo nc_emlrtRSI = { 136,/* lineNo */
  "strcmp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\strcmp.m"/* pathName */
};

static emlrtRSInfo oc_emlrtRSI = { 205,/* lineNo */
  "strcmp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\strcmp.m"/* pathName */
};

static emlrtRSInfo pc_emlrtRSI = { 206,/* lineNo */
  "strcmp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\strcmp.m"/* pathName */
};

static emlrtRSInfo qc_emlrtRSI = { 207,/* lineNo */
  "strcmp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\strcmp.m"/* pathName */
};

static emlrtRSInfo rc_emlrtRSI = { 17, /* lineNo */
  "lower",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\strfun\\lower.m"/* pathName */
};

static emlrtRSInfo sc_emlrtRSI = { 10, /* lineNo */
  "eml_string_transform",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\strfun\\eml_string_transform.m"/* pathName */
};

static emlrtRSInfo od_emlrtRSI = { 440,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo pd_emlrtRSI = { 444,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo qd_emlrtRSI = { 450,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo fe_emlrtRSI = { 359,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo ge_emlrtRSI = { 32, /* lineNo */
  "rodriguesMatrixToVector",           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\rodriguesMatrixToVector.m"/* pathName */
};

static emlrtRSInfo he_emlrtRSI = { 41, /* lineNo */
  "rodriguesMatrixToVector",           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\rodriguesMatrixToVector.m"/* pathName */
};

static emlrtRSInfo ie_emlrtRSI = { 98, /* lineNo */
  "rodriguesMatrixToVector",           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\rodriguesMatrixToVector.m"/* pathName */
};

static emlrtRSInfo je_emlrtRSI = { 25, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m"/* pathName */
};

static emlrtRSInfo ke_emlrtRSI = { 33, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m"/* pathName */
};

static emlrtRSInfo vf_emlrtRSI = { 13, /* lineNo */
  "acos",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\acos.m"/* pathName */
};

static emlrtRSInfo wf_emlrtRSI = { 119,/* lineNo */
  "rodriguesMatrixToVector",           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\rodriguesMatrixToVector.m"/* pathName */
};

static emlrtRSInfo xf_emlrtRSI = { 604,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo rg_emlrtRSI = { 399,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo sg_emlrtRSI = { 405,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo tg_emlrtRSI = { 418,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo rk_emlrtRSI = { 559,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo sk_emlrtRSI = { 560,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo tk_emlrtRSI = { 28, /* lineNo */
  "sort",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\sort.m"/* pathName */
};

static emlrtRSInfo uo_emlrtRSI = { 305,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo vo_emlrtRSI = { 308,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo wo_emlrtRSI = { 310,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo xo_emlrtRSI = { 311,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo yo_emlrtRSI = { 314,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo ap_emlrtRSI = { 315,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo bp_emlrtRSI = { 316,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo cp_emlrtRSI = { 323,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo dp_emlrtRSI = { 64, /* lineNo */
  "cat",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\cat.m"/* pathName */
};

static emlrtRTEInfo hd_emlrtRTEI = { 281,/* lineNo */
  29,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo id_emlrtRTEI = { 323,/* lineNo */
  28,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo jd_emlrtRTEI = { 308,/* lineNo */
  17,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo kd_emlrtRTEI = { 310,/* lineNo */
  17,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo ld_emlrtRTEI = { 311,/* lineNo */
  17,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo md_emlrtRTEI = { 314,/* lineNo */
  17,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo nd_emlrtRTEI = { 315,/* lineNo */
  17,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo od_emlrtRTEI = { 316,/* lineNo */
  17,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo yd_emlrtRTEI = { 74,/* lineNo */
  25,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo qe_emlrtRTEI = { 15,/* lineNo */
  9,                                   /* colNo */
  "assertSupportedString",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\assertSupportedString.m"/* pName */
};

static emlrtRTEInfo re_emlrtRTEI = { 107,/* lineNo */
  9,                                   /* colNo */
  "validatestring",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\lang\\validatestring.m"/* pName */
};

static emlrtBCInfo g_emlrtBCI = { 1,   /* iFirst */
  3,                                   /* iLast */
  119,                                 /* lineNo */
  48,                                  /* colNo */
  "",                                  /* aName */
  "rodriguesMatrixToVector",           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\rodriguesMatrixToVector.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo h_emlrtBCI = { 1,   /* iFirst */
  3,                                   /* iLast */
  119,                                 /* lineNo */
  51,                                  /* colNo */
  "",                                  /* aName */
  "rodriguesMatrixToVector",           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\rodriguesMatrixToVector.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo i_emlrtBCI = { 1,   /* iFirst */
  3,                                   /* iLast */
  119,                                 /* lineNo */
  71,                                  /* colNo */
  "",                                  /* aName */
  "rodriguesMatrixToVector",           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\rodriguesMatrixToVector.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo j_emlrtBCI = { 1,   /* iFirst */
  3,                                   /* iLast */
  119,                                 /* lineNo */
  74,                                  /* colNo */
  "",                                  /* aName */
  "rodriguesMatrixToVector",           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\rodriguesMatrixToVector.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRTEInfo sf_emlrtRTEI = { 54,/* lineNo */
  27,                                  /* colNo */
  "cat",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\cat.m"/* pName */
};

static emlrtRTEInfo tf_emlrtRTEI = { 288,/* lineNo */
  13,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtRTEInfo uf_emlrtRTEI = { 285,/* lineNo */
  17,                                  /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static emlrtBCInfo ne_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  319,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo oe_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  320,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo pe_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  321,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRTEInfo ag_emlrtRTEI = { 440,/* lineNo */
  1,                                   /* colNo */
  "StereoParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pName */
};

static const char_T cv0[128] = { '\x00', '\x01', '\x02', '\x03', '\x04', '\x05',
  '\x06', '\x07', '\x08', '	', '\x0a', '\x0b', '\x0c', '\x0d', '\x0e', '\x0f',
  '\x10', '\x11', '\x12', '\x13', '\x14', '\x15', '\x16', '\x17', '\x18', '\x19',
  '\x1a', '\x1b', '\x1c', '\x1d', '\x1e', '\x1f', ' ', '!', '\"', '#', '$', '%',
  '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/', '0', '1', '2', '3', '4',
  '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'a', 'b', 'c', 'd',
  'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
  'u', 'v', 'w', 'x', 'y', 'z', '[', '\\', ']', '^', '_', '`', 'a', 'b', 'c',
  'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
  't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~', '\x7f' };

/* Function Declarations */
static void computeOutputBoundsFull(const real_T outBounds1[8], const real_T
  outBounds2[8], real_T xBounds[2], real_T yBounds[2], boolean_T *isValid);
static void d_StereoParametersImpl_StereoPa(const emlrtStack *sp,
  c_vision_internal_calibration_S **this, const real_T
  c_varargin_1_CameraParameters1_[2], const real_T
  d_varargin_1_CameraParameters1_[2], const char_T
  e_varargin_1_CameraParameters1_[2], real_T f_varargin_1_CameraParameters1_,
  const real_T g_varargin_1_CameraParameters1_[36], const real_T
  h_varargin_1_CameraParameters1_[36], const real_T
  i_varargin_1_CameraParameters1_[9], const real_T
  c_varargin_1_CameraParameters2_[2], const real_T
  d_varargin_1_CameraParameters2_[2], const char_T
  e_varargin_1_CameraParameters2_[2], real_T f_varargin_1_CameraParameters2_,
  const real_T g_varargin_1_CameraParameters2_[36], const real_T
  h_varargin_1_CameraParameters2_[36], const real_T
  i_varargin_1_CameraParameters2_[9], const real_T varargin_1_RotationOfCamera2
  [9], const real_T varargin_1_TranslationOfCamera2[3], const struct3_T
  *varargin_1_RectificationParams, c_vision_internal_calibration_C *iobj_0,
  c_vision_internal_calibration_C *iobj_1);
static void validateParamStruct(const emlrtStack *sp, boolean_T
  c_paramStruct_RectificationPara, const real_T d_paramStruct_RectificationPara
  [9], const real_T e_paramStruct_RectificationPara[9], const real_T
  f_paramStruct_RectificationPara[16], const real_T
  g_paramStruct_RectificationPara[2], const real_T
  h_paramStruct_RectificationPara[2], const real_T
  i_paramStruct_RectificationPara[2], const char_T
  j_paramStruct_RectificationPara[5]);

/* Function Definitions */
static void computeOutputBoundsFull(const real_T outBounds1[8], const real_T
  outBounds2[8], real_T xBounds[2], real_T yBounds[2], boolean_T *isValid)
{
  int32_T j;
  real_T minXY[2];
  real_T maxXY[2];
  int32_T i;
  real_T b_minXY;
  real_T varargin_1[4];
  real_T b_outBounds1[4];
  real_T b_maxXY;
  real_T b_outBounds2[4];
  for (j = 0; j < 2; j++) {
    minXY[j] = outBounds1[j << 2];
    maxXY[j] = outBounds1[j << 2];
    for (i = 0; i < 3; i++) {
      b_maxXY = maxXY[j];
      b_minXY = minXY[j];
      if ((!muDoubleScalarIsNaN(outBounds1[(i + (j << 2)) + 1])) &&
          (muDoubleScalarIsNaN(minXY[j]) || (minXY[j] > outBounds1[(i + (j << 2))
            + 1]))) {
        b_minXY = outBounds1[(i + (j << 2)) + 1];
      }

      if ((!muDoubleScalarIsNaN(outBounds1[(i + (j << 2)) + 1])) &&
          (muDoubleScalarIsNaN(maxXY[j]) || (maxXY[j] < outBounds1[(i + (j << 2))
            + 1]))) {
        b_maxXY = outBounds1[(i + (j << 2)) + 1];
      }

      minXY[j] = b_minXY;
      maxXY[j] = b_maxXY;
    }

    b_outBounds1[j << 1] = minXY[j];
    b_outBounds1[1 + (j << 1)] = maxXY[j];
  }

  for (j = 0; j < 2; j++) {
    minXY[j] = outBounds2[j << 2];
    maxXY[j] = outBounds2[j << 2];
    for (i = 0; i < 3; i++) {
      b_maxXY = maxXY[j];
      b_minXY = minXY[j];
      if ((!muDoubleScalarIsNaN(outBounds2[(i + (j << 2)) + 1])) &&
          (muDoubleScalarIsNaN(minXY[j]) || (minXY[j] > outBounds2[(i + (j << 2))
            + 1]))) {
        b_minXY = outBounds2[(i + (j << 2)) + 1];
      }

      if ((!muDoubleScalarIsNaN(outBounds2[(i + (j << 2)) + 1])) &&
          (muDoubleScalarIsNaN(maxXY[j]) || (maxXY[j] < outBounds2[(i + (j << 2))
            + 1]))) {
        b_maxXY = outBounds2[(i + (j << 2)) + 1];
      }

      minXY[j] = b_minXY;
      maxXY[j] = b_maxXY;
    }

    b_outBounds2[j << 1] = minXY[j];
    b_outBounds2[1 + (j << 1)] = maxXY[j];
    varargin_1[j << 1] = b_outBounds1[j << 1];
    varargin_1[1 + (j << 1)] = b_outBounds2[j << 1];
  }

  for (j = 0; j < 2; j++) {
    b_minXY = varargin_1[j << 1];
    if ((!muDoubleScalarIsNaN(varargin_1[1 + (j << 1)])) && (muDoubleScalarIsNaN
         (varargin_1[j << 1]) || (varargin_1[j << 1] > varargin_1[1 + (j << 1)])))
    {
      b_minXY = varargin_1[1 + (j << 1)];
    }

    b_minXY = muDoubleScalarRound(b_minXY);
    varargin_1[j << 1] = b_outBounds1[1 + (j << 1)];
    varargin_1[1 + (j << 1)] = b_outBounds2[1 + (j << 1)];
    b_maxXY = varargin_1[j << 1];
    if ((!muDoubleScalarIsNaN(varargin_1[1 + (j << 1)])) && (muDoubleScalarIsNaN
         (varargin_1[j << 1]) || (varargin_1[j << 1] < varargin_1[1 + (j << 1)])))
    {
      b_maxXY = varargin_1[1 + (j << 1)];
    }

    b_maxXY = muDoubleScalarRound(b_maxXY);
    minXY[j] = b_minXY;
    maxXY[j] = b_maxXY;
  }

  xBounds[0] = minXY[0];
  xBounds[1] = maxXY[0];
  yBounds[0] = minXY[1];
  yBounds[1] = maxXY[1];
  if ((minXY[0] >= maxXY[0]) || (minXY[1] >= maxXY[1])) {
    *isValid = false;
  } else {
    *isValid = true;
  }
}

static void d_StereoParametersImpl_StereoPa(const emlrtStack *sp,
  c_vision_internal_calibration_S **this, const real_T
  c_varargin_1_CameraParameters1_[2], const real_T
  d_varargin_1_CameraParameters1_[2], const char_T
  e_varargin_1_CameraParameters1_[2], real_T f_varargin_1_CameraParameters1_,
  const real_T g_varargin_1_CameraParameters1_[36], const real_T
  h_varargin_1_CameraParameters1_[36], const real_T
  i_varargin_1_CameraParameters1_[9], const real_T
  c_varargin_1_CameraParameters2_[2], const real_T
  d_varargin_1_CameraParameters2_[2], const char_T
  e_varargin_1_CameraParameters2_[2], real_T f_varargin_1_CameraParameters2_,
  const real_T g_varargin_1_CameraParameters2_[36], const real_T
  h_varargin_1_CameraParameters2_[36], const real_T
  i_varargin_1_CameraParameters2_[9], const real_T varargin_1_RotationOfCamera2
  [9], const real_T varargin_1_TranslationOfCamera2[3], const struct3_T
  *varargin_1_RectificationParams, c_vision_internal_calibration_C *iobj_0,
  c_vision_internal_calibration_C *iobj_1)
{
  int32_T k;
  static const int8_T iv32[16] = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0,
    1 };

  static const char_T cv16[4] = { 'f', 'u', 'l', 'l' };

  static const char_T cv17[5] = { 'v', 'a', 'l', 'i', 'd' };

  real_T self_T[9];
  static const int8_T T[9] = { 1, 0, 0, 0, 1, 0, 0, 0, 1 };

  c_vision_internal_calibration_C *r37;
  c_vision_internal_calibration_C *camParams1;
  boolean_T p;
  char_T a[2];
  boolean_T exitg1;
  char_T b[2];
  int32_T exitg2;
  real_T varargin_1;
  boolean_T b_p;
  real_T h2_T[9];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &x_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  b_st.site = &db_emlrtRSI;
  c_st.site = &eb_emlrtRSI;
  st.site = &y_emlrtRSI;
  for (k = 0; k < 16; k++) {
    (*this)->RectificationParams.Q[k] = iv32[k];
  }

  for (k = 0; k < 2; k++) {
    (*this)->RectificationParams.XBounds[k] = 0.0;
  }

  for (k = 0; k < 2; k++) {
    (*this)->RectificationParams.YBounds[k] = 0.0;
  }

  (*this)->RectificationParams.Initialized = false;
  for (k = 0; k < 2; k++) {
    (*this)->RectificationParams.OriginalImageSize[k] = 0.0;
  }

  b_st.site = &fb_emlrtRSI;
  k = (*this)->RectificationParams.OutputView->size[0] * (*this)
    ->RectificationParams.OutputView->size[1];
  (*this)->RectificationParams.OutputView->size[0] = 1;
  (*this)->RectificationParams.OutputView->size[1] = 4;
  emxEnsureCapacity_char_T(&st, (*this)->RectificationParams.OutputView, k,
    &yd_emlrtRTEI);
  for (k = 0; k < 4; k++) {
    (*this)->RectificationParams.OutputView->data[k] = cv16[k];
  }

  k = (*this)->RectificationParams.OutputView->size[0] * (*this)
    ->RectificationParams.OutputView->size[1];
  (*this)->RectificationParams.OutputView->size[0] = 1;
  (*this)->RectificationParams.OutputView->size[1] = 5;
  emxEnsureCapacity_char_T(&st, (*this)->RectificationParams.OutputView, k,
    &yd_emlrtRTEI);
  for (k = 0; k < 5; k++) {
    (*this)->RectificationParams.OutputView->data[k] = cv17[k];
  }

  for (k = 0; k < 9; k++) {
    self_T[k] = T[k];
  }

  for (k = 0; k < 9; k++) {
    (*this)->RectificationParams.H1.T[k] = self_T[k];
  }

  for (k = 0; k < 9; k++) {
    self_T[k] = T[k];
  }

  for (k = 0; k < 9; k++) {
    (*this)->RectificationParams.H2.T[k] = self_T[k];
  }

  st.site = &ab_emlrtRSI;
  c_ImageTransformer_ImageTransfo(&st, &(*this)->RectifyMap1);
  st.site = &bb_emlrtRSI;
  c_ImageTransformer_ImageTransfo(&st, &(*this)->RectifyMap2);
  st.site = &cb_emlrtRSI;
  b_st.site = &sb_emlrtRSI;
  validateParamStruct(&b_st, varargin_1_RectificationParams->Initialized,
                      varargin_1_RectificationParams->H1,
                      varargin_1_RectificationParams->H2,
                      varargin_1_RectificationParams->Q,
                      varargin_1_RectificationParams->XBounds,
                      varargin_1_RectificationParams->YBounds,
                      varargin_1_RectificationParams->OriginalImageSize,
                      varargin_1_RectificationParams->OutputView);
  r37 = iobj_0;
  b_st.site = &tb_emlrtRSI;
  c_CameraParametersImpl_CameraPa(&b_st, &r37, c_varargin_1_CameraParameters1_,
    d_varargin_1_CameraParameters1_, e_varargin_1_CameraParameters1_,
    f_varargin_1_CameraParameters1_, g_varargin_1_CameraParameters1_,
    h_varargin_1_CameraParameters1_, i_varargin_1_CameraParameters1_);
  camParams1 = r37;
  r37 = iobj_1;
  b_st.site = &ub_emlrtRSI;
  c_CameraParametersImpl_CameraPa(&b_st, &r37, c_varargin_1_CameraParameters2_,
    d_varargin_1_CameraParameters2_, e_varargin_1_CameraParameters2_,
    f_varargin_1_CameraParameters2_, g_varargin_1_CameraParameters2_,
    h_varargin_1_CameraParameters2_, i_varargin_1_CameraParameters2_);
  if (varargin_1_RectificationParams->Initialized) {
    b_st.site = &xb_emlrtRSI;
    c_st.site = &jd_emlrtRSI;
    d_st.site = &kd_emlrtRSI;
    e_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if ((!muDoubleScalarIsInf(varargin_1_RectificationParams->H1[k])) &&
          (!muDoubleScalarIsNaN(varargin_1_RectificationParams->H1[k]))) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&e_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:projective2d.set.T:expectedFinite", 3, 4, 1, "T");
    }

    e_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if (!muDoubleScalarIsNaN(varargin_1_RectificationParams->H1[k])) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&e_st, &xe_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedNonNaN",
        "MATLAB:projective2d.set.T:expectedNonNaN", 3, 4, 1, "T");
    }

    d_st.site = &ld_emlrtRSI;
    varargin_1 = det(&d_st, varargin_1_RectificationParams->H1);
    p = false;
    b_p = true;
    if (!(varargin_1 == 0.0)) {
      b_p = false;
    }

    if (b_p) {
      p = true;
    }

    if (p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &we_emlrtRTEI,
        "images:geotrans:singularTransformationMatrix",
        "images:geotrans:singularTransformationMatrix", 0);
    }

    memcpy(&self_T[0], &varargin_1_RectificationParams->H1[0], 9U * sizeof
           (real_T));
    b_st.site = &yb_emlrtRSI;
    c_st.site = &jd_emlrtRSI;
    d_st.site = &kd_emlrtRSI;
    e_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if ((!muDoubleScalarIsInf(varargin_1_RectificationParams->H2[k])) &&
          (!muDoubleScalarIsNaN(varargin_1_RectificationParams->H2[k]))) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&e_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:projective2d.set.T:expectedFinite", 3, 4, 1, "T");
    }

    e_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if (!muDoubleScalarIsNaN(varargin_1_RectificationParams->H2[k])) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&e_st, &xe_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedNonNaN",
        "MATLAB:projective2d.set.T:expectedNonNaN", 3, 4, 1, "T");
    }

    d_st.site = &ld_emlrtRSI;
    varargin_1 = det(&d_st, varargin_1_RectificationParams->H2);
    p = false;
    b_p = true;
    if (!(varargin_1 == 0.0)) {
      b_p = false;
    }

    if (b_p) {
      p = true;
    }

    if (p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &we_emlrtRTEI,
        "images:geotrans:singularTransformationMatrix",
        "images:geotrans:singularTransformationMatrix", 0);
    }

    memcpy(&h2_T[0], &varargin_1_RectificationParams->H2[0], 9U * sizeof(real_T));
    b_st.site = &vb_emlrtRSI;
    (*this)->RectificationParams.Initialized = true;
    for (k = 0; k < 2; k++) {
      (*this)->RectificationParams.OriginalImageSize[k] =
        varargin_1_RectificationParams->OriginalImageSize[k];
    }

    for (k = 0; k < 9; k++) {
      (*this)->RectificationParams.H1.T[k] = self_T[k];
    }

    for (k = 0; k < 9; k++) {
      (*this)->RectificationParams.H2.T[k] = h2_T[k];
    }

    for (k = 0; k < 16; k++) {
      (*this)->RectificationParams.Q[k] = varargin_1_RectificationParams->Q[k];
    }

    k = (*this)->RectificationParams.OutputView->size[0] * (*this)
      ->RectificationParams.OutputView->size[1];
    (*this)->RectificationParams.OutputView->size[0] = 1;
    (*this)->RectificationParams.OutputView->size[1] = 5;
    emxEnsureCapacity_char_T(&b_st, (*this)->RectificationParams.OutputView, k,
      &yd_emlrtRTEI);
    for (k = 0; k < 5; k++) {
      (*this)->RectificationParams.OutputView->data[k] =
        varargin_1_RectificationParams->OutputView[k];
    }

    for (k = 0; k < 2; k++) {
      (*this)->RectificationParams.XBounds[k] =
        varargin_1_RectificationParams->XBounds[k];
    }

    for (k = 0; k < 2; k++) {
      (*this)->RectificationParams.YBounds[k] =
        varargin_1_RectificationParams->YBounds[k];
    }
  }

  b_st.site = &wb_emlrtRSI;
  c_st.site = &od_emlrtRSI;
  for (k = 0; k < 2; k++) {
    a[k] = camParams1->WorldUnits[k];
  }

  for (k = 0; k < 2; k++) {
    b[k] = r37->WorldUnits[k];
  }

  d_st.site = &mc_emlrtRSI;
  e_st.site = &nc_emlrtRSI;
  p = false;
  k = 0;
  do {
    exitg2 = 0;
    if (k + 1 < 3) {
      f_st.site = &oc_emlrtRSI;
      if (!((uint8_T)a[k] <= 127)) {
        emlrtErrorWithMessageIdR2018a(&f_st, &qe_emlrtRTEI,
          "Coder:toolbox:unsupportedString", "Coder:toolbox:unsupportedString",
          2, 12, 127);
      }

      f_st.site = &pc_emlrtRSI;
      if (!((uint8_T)b[k] <= 127)) {
        emlrtErrorWithMessageIdR2018a(&f_st, &qe_emlrtRTEI,
          "Coder:toolbox:unsupportedString", "Coder:toolbox:unsupportedString",
          2, 12, 127);
      }

      f_st.site = &qc_emlrtRSI;
      g_st.site = &rc_emlrtRSI;
      h_st.site = &sc_emlrtRSI;
      if (!((uint8_T)a[k] <= 127)) {
        emlrtErrorWithMessageIdR2018a(&h_st, &qe_emlrtRTEI,
          "Coder:toolbox:unsupportedString", "Coder:toolbox:unsupportedString",
          2, 12, 127);
      }

      f_st.site = &qc_emlrtRSI;
      g_st.site = &rc_emlrtRSI;
      h_st.site = &sc_emlrtRSI;
      if (!((uint8_T)b[k] <= 127)) {
        emlrtErrorWithMessageIdR2018a(&h_st, &qe_emlrtRTEI,
          "Coder:toolbox:unsupportedString", "Coder:toolbox:unsupportedString",
          2, 12, 127);
      }

      if (cv0[(uint8_T)a[k] & 127] != cv0[(uint8_T)b[k] & 127]) {
        exitg2 = 1;
      } else {
        k++;
      }
    } else {
      p = true;
      exitg2 = 1;
    }
  } while (exitg2 == 0);

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ag_emlrtRTEI,
      "vision:calibrate:sameWorldUnits", "vision:calibrate:sameWorldUnits", 0);
  }

  c_st.site = &pd_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 9)) {
    if ((!muDoubleScalarIsInf(varargin_1_RotationOfCamera2[k])) &&
        (!muDoubleScalarIsNaN(varargin_1_RotationOfCamera2[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:stereoParameters:expectedFinite", 3, 4, 17, "rotationOfCamera2");
  }

  c_st.site = &qd_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 3)) {
    if ((!muDoubleScalarIsInf(varargin_1_TranslationOfCamera2[k])) &&
        (!muDoubleScalarIsNaN(varargin_1_TranslationOfCamera2[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:stereoParameters:expectedFinite", 3, 4, 20, "translationOfCamera2");
  }

  (*this)->CameraParameters1 = camParams1;
  (*this)->CameraParameters2 = r37;
  for (k = 0; k < 9; k++) {
    (*this)->RotationOfCamera2[k] = varargin_1_RotationOfCamera2[k];
  }

  for (k = 0; k < 3; k++) {
    (*this)->TranslationOfCamera2[k] = varargin_1_TranslationOfCamera2[k];
  }
}

static void validateParamStruct(const emlrtStack *sp, boolean_T
  c_paramStruct_RectificationPara, const real_T d_paramStruct_RectificationPara
  [9], const real_T e_paramStruct_RectificationPara[9], const real_T
  f_paramStruct_RectificationPara[16], const real_T
  g_paramStruct_RectificationPara[2], const real_T
  h_paramStruct_RectificationPara[2], const real_T
  i_paramStruct_RectificationPara[2], const char_T
  j_paramStruct_RectificationPara[5])
{
  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  int32_T exitg2;
  int32_T partial_match_size_idx_1;
  char_T cv2[10];
  static const char_T cv3[3] = { ',', ' ', '\'' };

  static const char_T cv4[2] = { '\'', ',' };

  static const char_T cv5[5] = { 'v', 'a', 'l', 'i', 'd' };

  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
  emlrtStack j_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  i_st.prev = &h_st;
  i_st.tls = h_st.tls;
  j_st.prev = &i_st;
  j_st.tls = i_st.tls;
  if (c_paramStruct_RectificationPara) {
    st.site = &ac_emlrtRSI;
    b_st.site = &bc_emlrtRSI;
    c_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if ((!muDoubleScalarIsInf(d_paramStruct_RectificationPara[k])) &&
          (!muDoubleScalarIsNaN(d_paramStruct_RectificationPara[k]))) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:stereoParameters:expectedFinite", 3, 4, 34,
        "paramStruct.RectificationParams.H1");
    }

    b_st.site = &cc_emlrtRSI;
    c_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if ((!muDoubleScalarIsInf(e_paramStruct_RectificationPara[k])) &&
          (!muDoubleScalarIsNaN(e_paramStruct_RectificationPara[k]))) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:stereoParameters:expectedFinite", 3, 4, 34,
        "paramStruct.RectificationParams.H2");
    }

    b_st.site = &dc_emlrtRSI;
    c_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 16)) {
      if ((!muDoubleScalarIsInf(f_paramStruct_RectificationPara[k])) &&
          (!muDoubleScalarIsNaN(f_paramStruct_RectificationPara[k]))) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:stereoParameters:expectedFinite", 3, 4, 33,
        "paramStruct.RectificationParams.Q");
    }

    b_st.site = &ec_emlrtRSI;
    c_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 2)) {
      if ((!muDoubleScalarIsInf(g_paramStruct_RectificationPara[k])) &&
          (!muDoubleScalarIsNaN(g_paramStruct_RectificationPara[k]))) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:stereoParameters:expectedFinite", 3, 4, 39,
        "paramStruct.RectificationParams.XBounds");
    }

    b_st.site = &fc_emlrtRSI;
    c_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 2)) {
      if ((!muDoubleScalarIsInf(h_paramStruct_RectificationPara[k])) &&
          (!muDoubleScalarIsNaN(h_paramStruct_RectificationPara[k]))) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:stereoParameters:expectedFinite", 3, 4, 39,
        "paramStruct.RectificationParams.YBounds");
    }

    b_st.site = &gc_emlrtRSI;
    c_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 2)) {
      if ((!muDoubleScalarIsInf(i_paramStruct_RectificationPara[k])) &&
          (!muDoubleScalarIsNaN(i_paramStruct_RectificationPara[k]))) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:stereoParameters:expectedFinite", 3, 4, 49,
        "paramStruct.RectificationParams.OriginalImageSize");
    }

    c_st.site = &ic_emlrtRSI;
    p = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 2)) {
      if (!(i_paramStruct_RectificationPara[k] <= 0.0)) {
        k++;
      } else {
        p = false;
        exitg1 = true;
      }
    }

    if (!p) {
      emlrtErrorWithMessageIdR2018a(&c_st, &te_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedPositive",
        "MATLAB:stereoParameters:expectedPositive", 3, 4, 49,
        "paramStruct.RectificationParams.OriginalImageSize");
    }

    c_st.site = &ic_emlrtRSI;
    if (!all(i_paramStruct_RectificationPara)) {
      emlrtErrorWithMessageIdR2018a(&c_st, &se_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedInteger",
        "MATLAB:stereoParameters:expectedInteger", 3, 4, 49,
        "paramStruct.RectificationParams.OriginalImageSize");
    }

    b_st.site = &hc_emlrtRSI;
    c_st.site = &jc_emlrtRSI;
    d_st.site = &kc_emlrtRSI;
    e_st.site = &lc_emlrtRSI;
    f_st.site = &mc_emlrtRSI;
    g_st.site = &nc_emlrtRSI;
    p = false;
    k = 0;
    do {
      exitg2 = 0;
      if (k + 1 < 6) {
        h_st.site = &oc_emlrtRSI;
        if (!((uint8_T)j_paramStruct_RectificationPara[k] <= 127)) {
          emlrtErrorWithMessageIdR2018a(&h_st, &qe_emlrtRTEI,
            "Coder:toolbox:unsupportedString", "Coder:toolbox:unsupportedString",
            2, 12, 127);
        }

        h_st.site = &pc_emlrtRSI;
        h_st.site = &qc_emlrtRSI;
        i_st.site = &rc_emlrtRSI;
        j_st.site = &sc_emlrtRSI;
        if (!((uint8_T)j_paramStruct_RectificationPara[k] <= 127)) {
          emlrtErrorWithMessageIdR2018a(&j_st, &qe_emlrtRTEI,
            "Coder:toolbox:unsupportedString", "Coder:toolbox:unsupportedString",
            2, 12, 127);
        }

        h_st.site = &qc_emlrtRSI;
        i_st.site = &rc_emlrtRSI;
        if (cv0[(uint8_T)j_paramStruct_RectificationPara[k] & 127] != cv0
            [(int32_T)cv5[k]]) {
          exitg2 = 1;
        } else {
          k++;
        }
      } else {
        p = true;
        exitg2 = 1;
      }
    } while (exitg2 == 0);

    if (p) {
      k = 1;
      partial_match_size_idx_1 = 5;
    } else {
      k = 0;
      partial_match_size_idx_1 = 0;
    }

    if ((k == 0) || (partial_match_size_idx_1 == 0)) {
      for (k = 0; k < 3; k++) {
        cv2[k] = cv3[k];
      }

      for (k = 0; k < 5; k++) {
        cv2[k + 3] = j_paramStruct_RectificationPara[k];
      }

      for (k = 0; k < 2; k++) {
        cv2[k + 8] = cv4[k];
      }

      emlrtErrorWithMessageIdR2018a(&c_st, &re_emlrtRTEI,
        "Coder:toolbox:ValidatestringUnrecognizedStringChoice",
        "MATLAB:stereoParameters:unrecognizedStringChoice", 9, 4, 42,
        "paramStruct.RectificationParams.OutputView", 4, 15,
        "\'full\', \'valid\'", 4, 10, cv2);
    }
  }
}

c_vision_internal_calibration_S *c_StereoParametersImpl_StereoPa(const
  emlrtStack *sp, c_vision_internal_calibration_S *this, const real_T
  c_varargin_1_CameraParameters1_[2], const real_T
  d_varargin_1_CameraParameters1_[2], const char_T
  e_varargin_1_CameraParameters1_[2], real_T f_varargin_1_CameraParameters1_,
  const real_T g_varargin_1_CameraParameters1_[36], const real_T
  h_varargin_1_CameraParameters1_[36], const real_T
  i_varargin_1_CameraParameters1_[9], const real_T
  c_varargin_1_CameraParameters2_[2], const real_T
  d_varargin_1_CameraParameters2_[2], const char_T
  e_varargin_1_CameraParameters2_[2], real_T f_varargin_1_CameraParameters2_,
  const real_T g_varargin_1_CameraParameters2_[36], const real_T
  h_varargin_1_CameraParameters2_[36], const real_T
  i_varargin_1_CameraParameters2_[9], const real_T varargin_1_RotationOfCamera2
  [9], const real_T varargin_1_TranslationOfCamera2[3], const struct3_T
  *varargin_1_RectificationParams, c_vision_internal_calibration_C *iobj_0,
  c_vision_internal_calibration_C *iobj_1)
{
  c_vision_internal_calibration_S *b_this;
  b_this = this;
  d_StereoParametersImpl_StereoPa(sp, &b_this, c_varargin_1_CameraParameters1_,
    d_varargin_1_CameraParameters1_, e_varargin_1_CameraParameters1_,
    f_varargin_1_CameraParameters1_, g_varargin_1_CameraParameters1_,
    h_varargin_1_CameraParameters1_, i_varargin_1_CameraParameters1_,
    c_varargin_1_CameraParameters2_, d_varargin_1_CameraParameters2_,
    e_varargin_1_CameraParameters2_, f_varargin_1_CameraParameters2_,
    g_varargin_1_CameraParameters2_, h_varargin_1_CameraParameters2_,
    i_varargin_1_CameraParameters2_, varargin_1_RotationOfCamera2,
    varargin_1_TranslationOfCamera2, varargin_1_RectificationParams, iobj_0,
    iobj_1);
  return b_this;
}

void c_StereoParametersImpl_computeH(const emlrtStack *sp, const
  c_vision_internal_calibration_S *this, real_T Rl[9], real_T Rr[9])
{
  int32_T k;
  int32_T r;
  boolean_T p;
  real_T rotationMatrix[9];
  real_T V[9];
  real_T V1[9];
  real_T b_r[3];
  real_T t;
  real_T tr;
  int32_T i;
  real_T theta;
  int32_T idx;
  boolean_T exitg1;
  real_T c_r[3];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &fe_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  for (k = 0; k < 3; k++) {
    for (r = 0; r < 3; r++) {
      rotationMatrix[r + 3 * k] = this->RotationOfCamera2[k + 3 * r];
    }
  }

  b_st.site = &ge_emlrtRSI;
  p = true;
  for (k = 0; k < 9; k++) {
    if (p && ((!muDoubleScalarIsInf(rotationMatrix[k])) && (!muDoubleScalarIsNaN
          (rotationMatrix[k])))) {
      p = true;
    } else {
      p = false;
    }
  }

  if (p) {
    c_st.site = &je_emlrtRSI;
    svd(&c_st, rotationMatrix, V1, b_r, V);
  } else {
    memset(&V[0], 0, 9U * sizeof(real_T));
    c_st.site = &ke_emlrtRSI;
    svd(&c_st, V, rotationMatrix, b_r, V1);
    for (k = 0; k < 9; k++) {
      V1[k] = rtNaN;
      V[k] = rtNaN;
    }
  }

  for (k = 0; k < 3; k++) {
    for (r = 0; r < 3; r++) {
      rotationMatrix[k + 3 * r] = 0.0;
      for (i = 0; i < 3; i++) {
        rotationMatrix[k + 3 * r] += V1[k + 3 * i] * V[r + 3 * i];
      }
    }
  }

  t = 0.0;
  for (k = 0; k < 3; k++) {
    t += rotationMatrix[k + 3 * k];
  }

  tr = (t - 1.0) / 2.0;
  b_st.site = &he_emlrtRSI;
  if ((tr < -1.0) || (tr > 1.0)) {
    c_st.site = &vf_emlrtRSI;
    c_error(&c_st);
  }

  theta = muDoubleScalarAcos(tr);
  b_r[0] = rotationMatrix[5] - rotationMatrix[7];
  b_r[1] = rotationMatrix[6] - rotationMatrix[2];
  b_r[2] = rotationMatrix[1] - rotationMatrix[3];
  if (muDoubleScalarSin(theta) >= 0.0001) {
    tr = 1.0 / (2.0 * muDoubleScalarSin(theta));
    for (k = 0; k < 3; k++) {
      b_r[k] = theta * (b_r[k] * tr);
    }
  } else if (t - 1.0 > 0.0) {
    tr = (t - 3.0) / 12.0;
    for (k = 0; k < 3; k++) {
      b_r[k] *= 0.5 - tr;
    }
  } else {
    b_st.site = &ie_emlrtRSI;
    for (k = 0; k < 3; k++) {
      b_r[k] = rotationMatrix[k + 3 * k];
    }

    if (!muDoubleScalarIsNaN(b_r[0])) {
      idx = 1;
    } else {
      idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k < 4)) {
        if (!muDoubleScalarIsNaN(b_r[k - 1])) {
          idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }

    if (idx != 0) {
      tr = b_r[idx - 1];
      k = idx - 1;
      while (idx + 1 < 4) {
        if (tr < b_r[idx]) {
          tr = b_r[idx];
          k = idx;
        }

        idx++;
      }

      idx = k;
    }

    k = (int32_T)muDoubleScalarRem(idx + 1, 3.0);
    r = (int32_T)muDoubleScalarRem((real_T)(idx + 1) + 1.0, 3.0);
    c_st.site = &wf_emlrtRSI;
    if (!((k + 1 >= 1) && (k + 1 <= 3))) {
      emlrtDynamicBoundsCheckR2012b(k + 1, 1, 3, &g_emlrtBCI, &c_st);
      emlrtDynamicBoundsCheckR2012b(k + 1, 1, 3, &h_emlrtBCI, &c_st);
    }

    if (!((r + 1 >= 1) && (r + 1 <= 3))) {
      emlrtDynamicBoundsCheckR2012b(r + 1, 1, 3, &i_emlrtBCI, &c_st);
      emlrtDynamicBoundsCheckR2012b(r + 1, 1, 3, &j_emlrtBCI, &c_st);
    }

    tr = ((rotationMatrix[idx + 3 * idx] - rotationMatrix[k + 3 * k]) -
          rotationMatrix[r + 3 * r]) + 1.0;
    if (tr < 0.0) {
      d_st.site = &kf_emlrtRSI;
      error(&d_st);
    }

    tr = muDoubleScalarSqrt(tr);
    for (i = 0; i < 3; i++) {
      b_r[i] = 0.0;
    }

    b_r[idx] = tr / 2.0;
    b_r[k] = (rotationMatrix[k + 3 * idx] + rotationMatrix[idx + 3 * k]) / (2.0 *
      tr);
    b_r[r] = (rotationMatrix[r + 3 * idx] + rotationMatrix[idx + 3 * r]) / (2.0 *
      tr);
    tr = norm(b_r);
    for (k = 0; k < 3; k++) {
      b_r[k] = theta * b_r[k] / tr;
    }
  }

  for (i = 0; i < 3; i++) {
    c_r[i] = b_r[i] / -2.0;
  }

  rodriguesVectorToMatrix(c_r, Rr);
  for (k = 0; k < 3; k++) {
    for (r = 0; r < 3; r++) {
      Rl[r + 3 * k] = Rr[k + 3 * r];
    }
  }
}

void c_StereoParametersImpl_computeN(const c_vision_internal_calibration_S *this,
  real_T K_new[9])
{
  c_vision_internal_calibration_C *b_this;
  int32_T i6;
  int32_T i7;
  real_T intrinsicMatrix[9];
  real_T Kl[9];
  real_T Kr[9];
  real_T f_new;
  b_this = this->CameraParameters1;
  for (i6 = 0; i6 < 3; i6++) {
    for (i7 = 0; i7 < 3; i7++) {
      intrinsicMatrix[i7 + 3 * i6] = b_this->IntrinsicMatrixInternal[i6 + 3 * i7];
    }
  }

  for (i6 = 0; i6 < 3; i6++) {
    for (i7 = 0; i7 < 3; i7++) {
      Kl[i7 + 3 * i6] = intrinsicMatrix[i6 + 3 * i7];
    }
  }

  b_this = this->CameraParameters2;
  for (i6 = 0; i6 < 3; i6++) {
    for (i7 = 0; i7 < 3; i7++) {
      intrinsicMatrix[i7 + 3 * i6] = b_this->IntrinsicMatrixInternal[i6 + 3 * i7];
    }
  }

  for (i6 = 0; i6 < 3; i6++) {
    for (i7 = 0; i7 < 3; i7++) {
      Kr[i7 + 3 * i6] = intrinsicMatrix[i6 + 3 * i7];
    }
  }

  memcpy(&K_new[0], &Kl[0], 9U * sizeof(real_T));
  if ((Kr[0] > Kl[0]) || (muDoubleScalarIsNaN(Kr[0]) && (!muDoubleScalarIsNaN
        (Kl[0])))) {
    f_new = Kl[0];
  } else {
    f_new = Kr[0];
  }

  K_new[0] = f_new;
  K_new[4] = f_new;
  K_new[7] = (Kr[7] + Kl[7]) / 2.0;
  K_new[3] = 0.0;
}

void c_StereoParametersImpl_computeO(e_depthEstimationFromStereoVide *SD, const
  emlrtStack *sp, const c_vision_internal_calibration_S *this, const real_T
  Hleft_T[9], const real_T Hright_T[9], real_T xBounds[2], real_T yBounds[2],
  boolean_T *success)
{
  real_T xBoundsUndistort1[2];
  real_T yBoundsUndistort1[2];
  real_T undistortBounds1[8];
  real_T undistortBounds2[8];
  int32_T ibtile;
  int32_T j;
  real_T U[12];
  real_T X[12];
  int32_T k;
  real_T outBounds1[8];
  real_T b_X[12];
  real_T ySort[8];
  real_T outPts[16];
  boolean_T exitg1;
  real_T xmin1;
  real_T xmax1;
  real_T xmin2;
  real_T xmax2;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &rg_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  c_CameraParametersImpl_computeU(SD, &st, this->CameraParameters1,
    xBoundsUndistort1, yBoundsUndistort1);
  undistortBounds1[0] = xBoundsUndistort1[0];
  undistortBounds1[4] = yBoundsUndistort1[0];
  undistortBounds1[1] = xBoundsUndistort1[1];
  undistortBounds1[5] = yBoundsUndistort1[0];
  undistortBounds1[2] = xBoundsUndistort1[1];
  undistortBounds1[6] = yBoundsUndistort1[1];
  undistortBounds1[3] = xBoundsUndistort1[0];
  undistortBounds1[7] = yBoundsUndistort1[1];
  st.site = &sg_emlrtRSI;
  c_CameraParametersImpl_computeU(SD, &st, this->CameraParameters2,
    xBoundsUndistort1, yBoundsUndistort1);
  undistortBounds2[0] = xBoundsUndistort1[0];
  undistortBounds2[4] = yBoundsUndistort1[0];
  undistortBounds2[1] = xBoundsUndistort1[1];
  undistortBounds2[5] = yBoundsUndistort1[0];
  undistortBounds2[2] = xBoundsUndistort1[1];
  undistortBounds2[6] = yBoundsUndistort1[1];
  undistortBounds2[3] = xBoundsUndistort1[0];
  undistortBounds2[7] = yBoundsUndistort1[1];
  for (ibtile = 0; ibtile < 4; ibtile++) {
    U[8 + ibtile] = 1.0;
  }

  for (j = 0; j < 2; j++) {
    for (ibtile = 0; ibtile < 4; ibtile++) {
      U[ibtile + (j << 2)] = undistortBounds1[ibtile + (j << 2)];
    }
  }

  for (j = 0; j < 4; j++) {
    for (ibtile = 0; ibtile < 3; ibtile++) {
      X[j + (ibtile << 2)] = 0.0;
      for (k = 0; k < 3; k++) {
        X[j + (ibtile << 2)] += U[j + (k << 2)] * Hleft_T[k + 3 * ibtile];
      }
    }
  }

  for (j = 0; j < 2; j++) {
    ibtile = j << 2;
    for (k = 0; k < 4; k++) {
      undistortBounds1[ibtile + k] = X[8 + k];
    }
  }

  for (j = 0; j < 2; j++) {
    for (ibtile = 0; ibtile < 4; ibtile++) {
      X[ibtile + (j << 2)] /= undistortBounds1[ibtile + (j << 2)];
      outBounds1[ibtile + (j << 2)] = X[ibtile + (j << 2)];
    }
  }

  for (ibtile = 0; ibtile < 4; ibtile++) {
    U[8 + ibtile] = 1.0;
  }

  for (j = 0; j < 2; j++) {
    for (ibtile = 0; ibtile < 4; ibtile++) {
      U[ibtile + (j << 2)] = undistortBounds2[ibtile + (j << 2)];
    }
  }

  for (j = 0; j < 4; j++) {
    for (ibtile = 0; ibtile < 3; ibtile++) {
      b_X[j + (ibtile << 2)] = 0.0;
      for (k = 0; k < 3; k++) {
        b_X[j + (ibtile << 2)] += U[j + (k << 2)] * Hright_T[k + 3 * ibtile];
      }
    }
  }

  for (j = 0; j < 2; j++) {
    ibtile = j << 2;
    for (k = 0; k < 4; k++) {
      undistortBounds1[ibtile + k] = b_X[8 + k];
    }
  }

  for (j = 0; j < 2; j++) {
    for (ibtile = 0; ibtile < 4; ibtile++) {
      b_X[ibtile + (j << 2)] /= undistortBounds1[ibtile + (j << 2)];
      undistortBounds1[ibtile + (j << 2)] = b_X[ibtile + (j << 2)];
    }
  }

  st.site = &tg_emlrtRSI;
  for (j = 0; j < 2; j++) {
    for (ibtile = 0; ibtile < 4; ibtile++) {
      outPts[ibtile + (j << 3)] = X[ibtile + (j << 2)];
      outPts[(ibtile + (j << 3)) + 4] = b_X[ibtile + (j << 2)];
    }
  }

  b_st.site = &rk_emlrtRSI;
  memcpy(&ySort[0], &outPts[0], sizeof(real_T) << 3);
  for (j = 0; j < 2; j++) {
    for (ibtile = 0; ibtile < 4; ibtile++) {
      undistortBounds2[ibtile + (j << 2)] = ySort[ibtile + (j << 2)];
    }
  }

  c_st.site = &tk_emlrtRSI;
  b_sort(&c_st, undistortBounds2);
  b_st.site = &sk_emlrtRSI;
  memcpy(&ySort[0], &outPts[8], sizeof(real_T) << 3);
  c_st.site = &tk_emlrtRSI;
  b_sort(&c_st, ySort);
  for (j = 0; j < 2; j++) {
    xBounds[j] = 0.0;
    yBounds[j] = 0.0;
  }

  for (k = 0; k < 8; k++) {
    outBounds1[k] = muDoubleScalarRound(outBounds1[k]);
    undistortBounds1[k] = muDoubleScalarRound(undistortBounds1[k]);
  }

  if (!muDoubleScalarIsNaN(outBounds1[0])) {
    ibtile = 1;
  } else {
    ibtile = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k < 5)) {
      if (!muDoubleScalarIsNaN(outBounds1[k - 1])) {
        ibtile = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  if (ibtile == 0) {
    xmin1 = outBounds1[0];
  } else {
    xmin1 = outBounds1[ibtile - 1];
    while (ibtile + 1 < 5) {
      if (xmin1 > outBounds1[ibtile]) {
        xmin1 = outBounds1[ibtile];
      }

      ibtile++;
    }
  }

  if (!muDoubleScalarIsNaN(outBounds1[0])) {
    ibtile = 1;
  } else {
    ibtile = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k < 5)) {
      if (!muDoubleScalarIsNaN(outBounds1[k - 1])) {
        ibtile = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  if (ibtile == 0) {
    xmax1 = outBounds1[0];
  } else {
    xmax1 = outBounds1[ibtile - 1];
    while (ibtile + 1 < 5) {
      if (xmax1 < outBounds1[ibtile]) {
        xmax1 = outBounds1[ibtile];
      }

      ibtile++;
    }
  }

  if (!muDoubleScalarIsNaN(undistortBounds1[0])) {
    ibtile = 1;
  } else {
    ibtile = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k < 5)) {
      if (!muDoubleScalarIsNaN(undistortBounds1[k - 1])) {
        ibtile = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  if (ibtile == 0) {
    xmin2 = undistortBounds1[0];
  } else {
    xmin2 = undistortBounds1[ibtile - 1];
    while (ibtile + 1 < 5) {
      if (xmin2 > undistortBounds1[ibtile]) {
        xmin2 = undistortBounds1[ibtile];
      }

      ibtile++;
    }
  }

  if (!muDoubleScalarIsNaN(undistortBounds1[0])) {
    ibtile = 1;
  } else {
    ibtile = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k < 5)) {
      if (!muDoubleScalarIsNaN(undistortBounds1[k - 1])) {
        ibtile = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  if (ibtile == 0) {
    xmax2 = undistortBounds1[0];
  } else {
    xmax2 = undistortBounds1[ibtile - 1];
    while (ibtile + 1 < 5) {
      if (xmax2 < undistortBounds1[ibtile]) {
        xmax2 = undistortBounds1[ibtile];
      }

      ibtile++;
    }
  }

  if ((xmin1 >= xmax2) || (xmax1 <= xmin2)) {
    *success = false;
  } else {
    xBounds[0] = muDoubleScalarRound(undistortBounds2[3]);
    xBounds[1] = muDoubleScalarRound(undistortBounds2[4]);
    yBounds[0] = muDoubleScalarRound(ySort[3]);
    yBounds[1] = muDoubleScalarRound(ySort[4]);
    *success = !(xBounds[1] - xBounds[0] < 0.4 * muDoubleScalarMin(xmax1 - xmin1,
      xmax2 - xmin2));
  }
}

void c_StereoParametersImpl_computeR(e_depthEstimationFromStereoVide *SD, const
  emlrtStack *sp, const c_vision_internal_calibration_S *this, real_T Hleft_T[9],
  real_T Hright_T[9], real_T Q[16], real_T xBounds[2], real_T yBounds[2],
  boolean_T *success)
{
  real_T Rl[9];
  real_T Rr[9];
  int32_T k;
  real_T b[3];
  real_T t[3];
  real_T RrowAlign[9];
  c_vision_internal_calibration_C *b_this;
  int32_T j;
  real_T intrinsicMatrix[9];
  real_T K_new[9];
  real_T b_intrinsicMatrix[9];
  real_T c_intrinsicMatrix[9];
  real_T b_RrowAlign[9];
  int32_T ibtile;
  real_T A[9];
  boolean_T p;
  boolean_T exitg1;
  real_T varargin_1;
  boolean_T b_p;
  real_T xBoundsUndistort1[2];
  real_T yBoundsUndistort1[2];
  real_T undistortBounds1[8];
  real_T undistortBounds2[8];
  real_T U[12];
  real_T X[12];
  real_T b_X[12];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &mg_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  c_StereoParametersImpl_computeH(&st, this, Rl, Rr);
  for (k = 0; k < 3; k++) {
    b[k] = this->TranslationOfCamera2[k];
  }

  for (k = 0; k < 3; k++) {
    t[k] = 0.0;
    for (j = 0; j < 3; j++) {
      t[k] += Rr[k + 3 * j] * b[j];
    }
  }

  st.site = &ng_emlrtRSI;
  computeRowAlignmentRotation(&st, t, RrowAlign);
  b_this = this->CameraParameters1;
  for (k = 0; k < 3; k++) {
    for (j = 0; j < 3; j++) {
      intrinsicMatrix[j + 3 * k] = b_this->IntrinsicMatrixInternal[k + 3 * j];
    }
  }

  b_this = this->CameraParameters2;
  for (k = 0; k < 3; k++) {
    for (j = 0; j < 3; j++) {
      b_intrinsicMatrix[j + 3 * k] = b_this->IntrinsicMatrixInternal[k + 3 * j];
    }
  }

  c_StereoParametersImpl_computeN(this, K_new);
  st.site = &og_emlrtRSI;
  for (k = 0; k < 3; k++) {
    for (j = 0; j < 3; j++) {
      b_RrowAlign[k + 3 * j] = 0.0;
      for (ibtile = 0; ibtile < 3; ibtile++) {
        b_RrowAlign[k + 3 * j] += RrowAlign[k + 3 * ibtile] * Rl[ibtile + 3 * j];
      }
    }
  }

  for (k = 0; k < 3; k++) {
    for (j = 0; j < 3; j++) {
      Rl[k + 3 * j] = 0.0;
      for (ibtile = 0; ibtile < 3; ibtile++) {
        Rl[k + 3 * j] += K_new[k + 3 * ibtile] * b_RrowAlign[ibtile + 3 * j];
      }

      c_intrinsicMatrix[j + 3 * k] = intrinsicMatrix[k + 3 * j];
    }
  }

  b_st.site = &og_emlrtRSI;
  mrdivide(&b_st, Rl, c_intrinsicMatrix, intrinsicMatrix);
  for (k = 0; k < 3; k++) {
    for (j = 0; j < 3; j++) {
      A[j + 3 * k] = intrinsicMatrix[k + 3 * j];
    }
  }

  b_st.site = &jd_emlrtRSI;
  c_st.site = &kd_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 9)) {
    if ((!muDoubleScalarIsInf(A[k])) && (!muDoubleScalarIsNaN(A[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:projective2d.set.T:expectedFinite", 3, 4, 1, "T");
  }

  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 9)) {
    if (!muDoubleScalarIsNaN(A[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &xe_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:projective2d.set.T:expectedNonNaN", 3, 4, 1, "T");
  }

  c_st.site = &ld_emlrtRSI;
  varargin_1 = det(&c_st, A);
  p = false;
  b_p = true;
  if (!(varargin_1 == 0.0)) {
    b_p = false;
  }

  if (b_p) {
    p = true;
  }

  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &we_emlrtRTEI,
      "images:geotrans:singularTransformationMatrix",
      "images:geotrans:singularTransformationMatrix", 0);
  }

  memcpy(&Hleft_T[0], &A[0], 9U * sizeof(real_T));
  st.site = &pg_emlrtRSI;
  for (k = 0; k < 3; k++) {
    for (j = 0; j < 3; j++) {
      b_RrowAlign[k + 3 * j] = 0.0;
      for (ibtile = 0; ibtile < 3; ibtile++) {
        b_RrowAlign[k + 3 * j] += RrowAlign[k + 3 * ibtile] * Rr[ibtile + 3 * j];
      }
    }
  }

  for (k = 0; k < 3; k++) {
    for (j = 0; j < 3; j++) {
      Rl[k + 3 * j] = 0.0;
      for (ibtile = 0; ibtile < 3; ibtile++) {
        Rl[k + 3 * j] += K_new[k + 3 * ibtile] * b_RrowAlign[ibtile + 3 * j];
      }

      c_intrinsicMatrix[j + 3 * k] = b_intrinsicMatrix[k + 3 * j];
    }
  }

  b_st.site = &pg_emlrtRSI;
  mrdivide(&b_st, Rl, c_intrinsicMatrix, intrinsicMatrix);
  for (k = 0; k < 3; k++) {
    for (j = 0; j < 3; j++) {
      Rl[j + 3 * k] = intrinsicMatrix[k + 3 * j];
    }
  }

  b_st.site = &jd_emlrtRSI;
  c_st.site = &kd_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 9)) {
    if ((!muDoubleScalarIsInf(Rl[k])) && (!muDoubleScalarIsNaN(Rl[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:projective2d.set.T:expectedFinite", 3, 4, 1, "T");
  }

  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 9)) {
    if (!muDoubleScalarIsNaN(Rl[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &xe_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:projective2d.set.T:expectedNonNaN", 3, 4, 1, "T");
  }

  c_st.site = &ld_emlrtRSI;
  varargin_1 = det(&c_st, Rl);
  p = false;
  b_p = true;
  if (!(varargin_1 == 0.0)) {
    b_p = false;
  }

  if (b_p) {
    p = true;
  }

  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &we_emlrtRTEI,
      "images:geotrans:singularTransformationMatrix",
      "images:geotrans:singularTransformationMatrix", 0);
  }

  memcpy(&Hright_T[0], &Rl[0], 9U * sizeof(real_T));
  for (k = 0; k < 3; k++) {
    b[k] = 0.0;
    for (j = 0; j < 3; j++) {
      b[k] += RrowAlign[k + 3 * j] * t[j];
    }
  }

  for (k = 0; k < 3; k++) {
    t[k] = b[k];
  }

  st.site = &qg_emlrtRSI;
  b_st.site = &rg_emlrtRSI;
  d_CameraParametersImpl_computeU(SD, &b_st, this->CameraParameters1,
    xBoundsUndistort1, yBoundsUndistort1);
  undistortBounds1[0] = xBoundsUndistort1[0];
  undistortBounds1[4] = yBoundsUndistort1[0];
  undistortBounds1[1] = xBoundsUndistort1[1];
  undistortBounds1[5] = yBoundsUndistort1[0];
  undistortBounds1[2] = xBoundsUndistort1[1];
  undistortBounds1[6] = yBoundsUndistort1[1];
  undistortBounds1[3] = xBoundsUndistort1[0];
  undistortBounds1[7] = yBoundsUndistort1[1];
  b_st.site = &sg_emlrtRSI;
  d_CameraParametersImpl_computeU(SD, &b_st, this->CameraParameters2,
    xBoundsUndistort1, yBoundsUndistort1);
  undistortBounds2[0] = xBoundsUndistort1[0];
  undistortBounds2[4] = yBoundsUndistort1[0];
  undistortBounds2[1] = xBoundsUndistort1[1];
  undistortBounds2[5] = yBoundsUndistort1[0];
  undistortBounds2[2] = xBoundsUndistort1[1];
  undistortBounds2[6] = yBoundsUndistort1[1];
  undistortBounds2[3] = xBoundsUndistort1[0];
  undistortBounds2[7] = yBoundsUndistort1[1];
  for (k = 0; k < 4; k++) {
    U[8 + k] = 1.0;
  }

  for (j = 0; j < 2; j++) {
    for (k = 0; k < 4; k++) {
      U[k + (j << 2)] = undistortBounds1[k + (j << 2)];
    }
  }

  for (k = 0; k < 4; k++) {
    for (j = 0; j < 3; j++) {
      X[k + (j << 2)] = 0.0;
      for (ibtile = 0; ibtile < 3; ibtile++) {
        X[k + (j << 2)] += U[k + (ibtile << 2)] * A[ibtile + 3 * j];
      }
    }
  }

  for (j = 0; j < 2; j++) {
    ibtile = j << 2;
    for (k = 0; k < 4; k++) {
      undistortBounds1[ibtile + k] = X[8 + k];
    }
  }

  for (k = 0; k < 2; k++) {
    for (j = 0; j < 4; j++) {
      X[j + (k << 2)] /= undistortBounds1[j + (k << 2)];
    }
  }

  for (k = 0; k < 4; k++) {
    U[8 + k] = 1.0;
  }

  for (j = 0; j < 2; j++) {
    for (k = 0; k < 4; k++) {
      U[k + (j << 2)] = undistortBounds2[k + (j << 2)];
    }
  }

  for (k = 0; k < 4; k++) {
    for (j = 0; j < 3; j++) {
      b_X[k + (j << 2)] = 0.0;
      for (ibtile = 0; ibtile < 3; ibtile++) {
        b_X[k + (j << 2)] += U[k + (ibtile << 2)] * Rl[ibtile + 3 * j];
      }
    }
  }

  for (j = 0; j < 2; j++) {
    ibtile = j << 2;
    for (k = 0; k < 4; k++) {
      undistortBounds1[ibtile + k] = b_X[8 + k];
    }
  }

  for (k = 0; k < 2; k++) {
    for (j = 0; j < 4; j++) {
      b_X[j + (k << 2)] /= undistortBounds1[j + (k << 2)];
    }
  }

  computeOutputBoundsFull(*(real_T (*)[8])&X[0], *(real_T (*)[8])&b_X[0],
    xBounds, yBounds, success);
  Q[0] = 1.0;
  Q[1] = 0.0;
  Q[2] = 0.0;
  Q[3] = -(K_new[6] - xBounds[0]);
  Q[4] = 0.0;
  Q[5] = 1.0;
  Q[6] = 0.0;
  Q[7] = -(K_new[7] - yBounds[0]);
  Q[8] = 0.0;
  Q[9] = 0.0;
  Q[10] = 0.0;
  Q[11] = K_new[4];
  Q[12] = 0.0;
  Q[13] = 0.0;
  Q[14] = -1.0 / t[0];
  Q[15] = 0.0;
}

void c_StereoParametersImpl_reconstr(const emlrtStack *sp, const
  c_vision_internal_calibration_S *this, const emxArray_real32_T *disparityMap,
  emxArray_real32_T *points3D)
{
  real_T imageSize[2];
  int32_T i42;
  real_T b_disparityMap[2];
  real_T imageSize_idx_1;
  emxArray_real_T *y;
  real32_T Q[16];
  int32_T numPoints;
  int32_T disparityMap_idx_0;
  int32_T iy;
  emxArray_real_T *b_y;
  emxArray_real32_T *c_y;
  emxArray_real32_T *d_y;
  emxArray_real32_T *X;
  emxArray_real32_T *Y;
  boolean_T b2;
  emxArray_real32_T *points2dHomog;
  int32_T maxdimlen;
  emxArray_real32_T *points3dHomog;
  char_T TRANSA;
  char_T TRANSB;
  real32_T alpha1;
  emxArray_real32_T *b_points3dHomog;
  real32_T beta1;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  emxArray_real32_T *r31;
  emxArray_real32_T *c_points3dHomog;
  emxArray_real32_T *points3d;
  int32_T num[2];
  int32_T b_num[2];
  int32_T c_num[2];
  emxArray_real32_T *Z;
  emxArray_int32_T *r32;
  emxArray_int32_T *r33;
  emxArray_int32_T *r34;
  uint32_T ysize_idx_0;
  uint32_T ysize_idx_1;
  boolean_T exitg1;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  if (!this->RectificationParams.Initialized) {
    emlrtErrorWithMessageIdR2018a(sp, &uf_emlrtRTEI,
      "vision:calibrate:callRectifyFirst", "vision:calibrate:callRectifyFirst",
      3, 4, 12, "stereoParams");
  }

  imageSize[0] = (this->RectificationParams.YBounds[1] -
                  this->RectificationParams.YBounds[0]) + 1.0;
  imageSize[1] = (this->RectificationParams.XBounds[1] -
                  this->RectificationParams.XBounds[0]) + 1.0;
  for (i42 = 0; i42 < 2; i42++) {
    b_disparityMap[i42] = disparityMap->size[i42];
  }

  if (!isequal(b_disparityMap, imageSize)) {
    imageSize[0] = (this->RectificationParams.YBounds[1] -
                    this->RectificationParams.YBounds[0]) + 1.0;
    imageSize_idx_1 = (this->RectificationParams.XBounds[1] -
                       this->RectificationParams.XBounds[0]) + 1.0;
    emlrtErrorWithMessageIdR2018a(sp, &tf_emlrtRTEI,
      "vision:calibrate:disparitySizeMismatch",
      "vision:calibrate:disparitySizeMismatch", 10, 4, 12, "disparityMap", 6,
      imageSize[0], 6, imageSize_idx_1, 4, 12, "disparityMap");
  }

  for (i42 = 0; i42 < 16; i42++) {
    Q[i42] = (real32_T)this->RectificationParams.Q[i42];
  }

  emxInit_real_T(sp, &y, 2, &hd_emlrtRTEI, true);
  numPoints = disparityMap->size[0] * disparityMap->size[1];
  if (disparityMap->size[1] < 1) {
    i42 = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = 0;
    emxEnsureCapacity_real_T1(sp, y, i42, &hd_emlrtRTEI);
  } else {
    i42 = disparityMap->size[1];
    disparityMap_idx_0 = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = (int32_T)((real_T)i42 - 1.0) + 1;
    emxEnsureCapacity_real_T1(sp, y, disparityMap_idx_0, &hd_emlrtRTEI);
    iy = (int32_T)((real_T)i42 - 1.0);
    for (i42 = 0; i42 <= iy; i42++) {
      y->data[y->size[0] * i42] = 1.0 + (real_T)i42;
    }
  }

  emxInit_real_T(sp, &b_y, 2, &hd_emlrtRTEI, true);
  if (disparityMap->size[0] < 1) {
    i42 = b_y->size[0] * b_y->size[1];
    b_y->size[0] = 1;
    b_y->size[1] = 0;
    emxEnsureCapacity_real_T1(sp, b_y, i42, &hd_emlrtRTEI);
  } else {
    i42 = disparityMap->size[0];
    disparityMap_idx_0 = b_y->size[0] * b_y->size[1];
    b_y->size[0] = 1;
    b_y->size[1] = (int32_T)((real_T)i42 - 1.0) + 1;
    emxEnsureCapacity_real_T1(sp, b_y, disparityMap_idx_0, &hd_emlrtRTEI);
    iy = (int32_T)((real_T)i42 - 1.0);
    for (i42 = 0; i42 <= iy; i42++) {
      b_y->data[b_y->size[0] * i42] = 1.0 + (real_T)i42;
    }
  }

  emxInit_real32_T(sp, &c_y, 2, &hd_emlrtRTEI, true);
  i42 = c_y->size[0] * c_y->size[1];
  c_y->size[0] = 1;
  c_y->size[1] = y->size[1];
  emxEnsureCapacity_real32_T(sp, c_y, i42, &hd_emlrtRTEI);
  iy = y->size[0] * y->size[1];
  for (i42 = 0; i42 < iy; i42++) {
    c_y->data[i42] = (real32_T)y->data[i42];
  }

  emxFree_real_T(sp, &y);
  emxInit_real32_T(sp, &d_y, 2, &hd_emlrtRTEI, true);
  i42 = d_y->size[0] * d_y->size[1];
  d_y->size[0] = 1;
  d_y->size[1] = b_y->size[1];
  emxEnsureCapacity_real32_T(sp, d_y, i42, &hd_emlrtRTEI);
  iy = b_y->size[0] * b_y->size[1];
  for (i42 = 0; i42 < iy; i42++) {
    d_y->data[i42] = (real32_T)b_y->data[i42];
  }

  emxFree_real_T(sp, &b_y);
  emxInit_real32_T(sp, &X, 2, &md_emlrtRTEI, true);
  emxInit_real32_T(sp, &Y, 2, &nd_emlrtRTEI, true);
  st.site = &uo_emlrtRSI;
  c_meshgrid(&st, c_y, d_y, X, Y);
  st.site = &vo_emlrtRSI;
  b_st.site = &rh_emlrtRSI;
  c_st.site = &sh_emlrtRSI;
  b2 = true;
  emxFree_real32_T(&c_st, &d_y);
  emxFree_real32_T(&c_st, &c_y);
  if (Y->size[0] * Y->size[1] != X->size[0] * X->size[1]) {
    b2 = false;
  }

  if (!b2) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if (disparityMap->size[0] * disparityMap->size[1] != X->size[0] * X->size[1])
  {
    b2 = false;
  }

  if (!b2) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if (numPoints != X->size[0] * X->size[1]) {
    b2 = false;
  }

  if (!b2) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  emxInit_real32_T(&c_st, &points2dHomog, 2, &jd_emlrtRTEI, true);
  maxdimlen = X->size[0] * X->size[1];
  iy = Y->size[0] * Y->size[1];
  disparityMap_idx_0 = disparityMap->size[0] * disparityMap->size[1];
  i42 = points2dHomog->size[0] * points2dHomog->size[1];
  points2dHomog->size[0] = maxdimlen;
  points2dHomog->size[1] = 4;
  emxEnsureCapacity_real32_T(&b_st, points2dHomog, i42, &hd_emlrtRTEI);
  for (i42 = 0; i42 < maxdimlen; i42++) {
    points2dHomog->data[i42] = X->data[i42];
  }

  for (i42 = 0; i42 < iy; i42++) {
    points2dHomog->data[i42 + points2dHomog->size[0]] = Y->data[i42];
  }

  for (i42 = 0; i42 < disparityMap_idx_0; i42++) {
    points2dHomog->data[i42 + (points2dHomog->size[0] << 1)] =
      disparityMap->data[i42];
  }

  for (i42 = 0; i42 < numPoints; i42++) {
    points2dHomog->data[i42 + points2dHomog->size[0] * 3] = 1.0F;
  }

  st.site = &wo_emlrtRSI;
  b_st.site = &ao_emlrtRSI;
  emxInit_real32_T(&b_st, &points3dHomog, 2, &kd_emlrtRTEI, true);
  if (points2dHomog->size[0] == 0) {
    i42 = points3dHomog->size[0] * points3dHomog->size[1];
    points3dHomog->size[0] = 0;
    points3dHomog->size[1] = 4;
    emxEnsureCapacity_real32_T(&b_st, points3dHomog, i42, &hd_emlrtRTEI);
  } else {
    c_st.site = &co_emlrtRSI;
    c_st.site = &bo_emlrtRSI;
    TRANSA = 'N';
    TRANSB = 'N';
    alpha1 = 1.0F;
    beta1 = 0.0F;
    m_t = (ptrdiff_t)points2dHomog->size[0];
    n_t = (ptrdiff_t)4;
    k_t = (ptrdiff_t)4;
    lda_t = (ptrdiff_t)points2dHomog->size[0];
    ldb_t = (ptrdiff_t)4;
    ldc_t = (ptrdiff_t)points2dHomog->size[0];
    i42 = points3dHomog->size[0] * points3dHomog->size[1];
    points3dHomog->size[0] = points2dHomog->size[0];
    points3dHomog->size[1] = 4;
    emxEnsureCapacity_real32_T(&c_st, points3dHomog, i42, &xc_emlrtRTEI);
    sgemm(&TRANSA, &TRANSB, &m_t, &n_t, &k_t, &alpha1, &points2dHomog->data[0],
          &lda_t, &Q[0], &ldb_t, &beta1, &points3dHomog->data[0], &ldc_t);
  }

  emxFree_real32_T(&b_st, &points2dHomog);
  emxInit_real32_T2(&b_st, &b_points3dHomog, 1, &hd_emlrtRTEI, true);
  iy = points3dHomog->size[0];
  i42 = b_points3dHomog->size[0];
  b_points3dHomog->size[0] = iy;
  emxEnsureCapacity_real32_T1(sp, b_points3dHomog, i42, &hd_emlrtRTEI);
  for (i42 = 0; i42 < iy; i42++) {
    b_points3dHomog->data[i42] = points3dHomog->data[i42 + points3dHomog->size[0]
      * 3];
  }

  emxInit_real32_T2(sp, &r31, 1, &hd_emlrtRTEI, true);
  emxInit_real32_T(sp, &c_points3dHomog, 2, &hd_emlrtRTEI, true);
  b_rdivide(sp, b_points3dHomog, r31);
  iy = points3dHomog->size[0];
  i42 = c_points3dHomog->size[0] * c_points3dHomog->size[1];
  c_points3dHomog->size[0] = iy;
  c_points3dHomog->size[1] = 3;
  emxEnsureCapacity_real32_T(sp, c_points3dHomog, i42, &hd_emlrtRTEI);
  for (i42 = 0; i42 < 3; i42++) {
    for (disparityMap_idx_0 = 0; disparityMap_idx_0 < iy; disparityMap_idx_0++)
    {
      c_points3dHomog->data[disparityMap_idx_0 + c_points3dHomog->size[0] * i42]
        = points3dHomog->data[disparityMap_idx_0 + points3dHomog->size[0] * i42];
    }
  }

  emxFree_real32_T(sp, &points3dHomog);
  emxInit_real32_T(sp, &points3d, 2, &ld_emlrtRTEI, true);
  st.site = &xo_emlrtRSI;
  b_bsxfun(&st, c_points3dHomog, r31, points3d);
  st.site = &yo_emlrtRSI;
  emxFree_real32_T(&st, &c_points3dHomog);
  emxFree_real32_T(&st, &r31);
  for (i42 = 0; i42 < 2; i42++) {
    imageSize[i42] = disparityMap->size[i42];
  }

  i42 = points3d->size[0];
  b_st.site = &ui_emlrtRSI;
  assertValidSizeArg(&b_st, imageSize);
  for (disparityMap_idx_0 = 0; disparityMap_idx_0 < 2; disparityMap_idx_0++) {
    num[disparityMap_idx_0] = (int32_T)imageSize[disparityMap_idx_0];
  }

  maxdimlen = points3d->size[0];
  disparityMap_idx_0 = points3d->size[0];
  if (1 > disparityMap_idx_0) {
    maxdimlen = 1;
  }

  maxdimlen = muIntScalarMax_sint32(i42, maxdimlen);
  if (num[0] > maxdimlen) {
    b_st.site = &vi_emlrtRSI;
    d_error(&b_st);
  }

  if (num[1] > maxdimlen) {
    b_st.site = &vi_emlrtRSI;
    d_error(&b_st);
  }

  i42 = points3d->size[0];
  if (num[0] * num[1] != i42) {
    emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
      "Coder:MATLAB:getReshapeDims_notSameNumel",
      "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
  }

  iy = points3d->size[0];
  i42 = b_points3dHomog->size[0];
  b_points3dHomog->size[0] = iy;
  emxEnsureCapacity_real32_T1(&st, b_points3dHomog, i42, &hd_emlrtRTEI);
  for (i42 = 0; i42 < iy; i42++) {
    b_points3dHomog->data[i42] = points3d->data[i42];
  }

  maxdimlen = num[0];
  i42 = X->size[0] * X->size[1];
  X->size[0] = num[0];
  X->size[1] = num[1];
  emxEnsureCapacity_real32_T(&st, X, i42, &hd_emlrtRTEI);
  iy = num[1];
  for (i42 = 0; i42 < iy; i42++) {
    for (disparityMap_idx_0 = 0; disparityMap_idx_0 < maxdimlen;
         disparityMap_idx_0++) {
      X->data[disparityMap_idx_0 + X->size[0] * i42] = b_points3dHomog->
        data[disparityMap_idx_0 + maxdimlen * i42];
    }
  }

  st.site = &ap_emlrtRSI;
  for (i42 = 0; i42 < 2; i42++) {
    imageSize[i42] = disparityMap->size[i42];
  }

  i42 = points3d->size[0];
  b_st.site = &ui_emlrtRSI;
  assertValidSizeArg(&b_st, imageSize);
  for (disparityMap_idx_0 = 0; disparityMap_idx_0 < 2; disparityMap_idx_0++) {
    b_num[disparityMap_idx_0] = (int32_T)imageSize[disparityMap_idx_0];
  }

  maxdimlen = points3d->size[0];
  disparityMap_idx_0 = points3d->size[0];
  if (1 > disparityMap_idx_0) {
    maxdimlen = 1;
  }

  maxdimlen = muIntScalarMax_sint32(i42, maxdimlen);
  if (b_num[0] > maxdimlen) {
    b_st.site = &vi_emlrtRSI;
    d_error(&b_st);
  }

  if (b_num[1] > maxdimlen) {
    b_st.site = &vi_emlrtRSI;
    d_error(&b_st);
  }

  i42 = points3d->size[0];
  if (b_num[0] * b_num[1] != i42) {
    emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
      "Coder:MATLAB:getReshapeDims_notSameNumel",
      "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
  }

  iy = points3d->size[0];
  i42 = b_points3dHomog->size[0];
  b_points3dHomog->size[0] = iy;
  emxEnsureCapacity_real32_T1(&st, b_points3dHomog, i42, &hd_emlrtRTEI);
  for (i42 = 0; i42 < iy; i42++) {
    b_points3dHomog->data[i42] = points3d->data[i42 + points3d->size[0]];
  }

  maxdimlen = b_num[0];
  i42 = Y->size[0] * Y->size[1];
  Y->size[0] = b_num[0];
  Y->size[1] = b_num[1];
  emxEnsureCapacity_real32_T(&st, Y, i42, &hd_emlrtRTEI);
  iy = b_num[1];
  for (i42 = 0; i42 < iy; i42++) {
    for (disparityMap_idx_0 = 0; disparityMap_idx_0 < maxdimlen;
         disparityMap_idx_0++) {
      Y->data[disparityMap_idx_0 + Y->size[0] * i42] = b_points3dHomog->
        data[disparityMap_idx_0 + maxdimlen * i42];
    }
  }

  st.site = &bp_emlrtRSI;
  for (i42 = 0; i42 < 2; i42++) {
    imageSize[i42] = disparityMap->size[i42];
  }

  i42 = points3d->size[0];
  b_st.site = &ui_emlrtRSI;
  assertValidSizeArg(&b_st, imageSize);
  for (disparityMap_idx_0 = 0; disparityMap_idx_0 < 2; disparityMap_idx_0++) {
    c_num[disparityMap_idx_0] = (int32_T)imageSize[disparityMap_idx_0];
  }

  maxdimlen = points3d->size[0];
  disparityMap_idx_0 = points3d->size[0];
  if (1 > disparityMap_idx_0) {
    maxdimlen = 1;
  }

  maxdimlen = muIntScalarMax_sint32(i42, maxdimlen);
  if (c_num[0] > maxdimlen) {
    b_st.site = &vi_emlrtRSI;
    d_error(&b_st);
  }

  if (c_num[1] > maxdimlen) {
    b_st.site = &vi_emlrtRSI;
    d_error(&b_st);
  }

  i42 = points3d->size[0];
  if (c_num[0] * c_num[1] != i42) {
    emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
      "Coder:MATLAB:getReshapeDims_notSameNumel",
      "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
  }

  iy = points3d->size[0];
  i42 = b_points3dHomog->size[0];
  b_points3dHomog->size[0] = iy;
  emxEnsureCapacity_real32_T1(&st, b_points3dHomog, i42, &hd_emlrtRTEI);
  for (i42 = 0; i42 < iy; i42++) {
    b_points3dHomog->data[i42] = points3d->data[i42 + (points3d->size[0] << 1)];
  }

  emxFree_real32_T(&st, &points3d);
  emxInit_real32_T(&st, &Z, 2, &od_emlrtRTEI, true);
  maxdimlen = c_num[0];
  i42 = Z->size[0] * Z->size[1];
  Z->size[0] = c_num[0];
  Z->size[1] = c_num[1];
  emxEnsureCapacity_real32_T(&st, Z, i42, &hd_emlrtRTEI);
  iy = c_num[1];
  for (i42 = 0; i42 < iy; i42++) {
    for (disparityMap_idx_0 = 0; disparityMap_idx_0 < maxdimlen;
         disparityMap_idx_0++) {
      Z->data[disparityMap_idx_0 + Z->size[0] * i42] = b_points3dHomog->
        data[disparityMap_idx_0 + maxdimlen * i42];
    }
  }

  emxFree_real32_T(&st, &b_points3dHomog);
  disparityMap_idx_0 = disparityMap->size[0] * disparityMap->size[1] - 1;
  maxdimlen = 0;
  for (iy = 0; iy <= disparityMap_idx_0; iy++) {
    if (disparityMap->data[iy] == -3.402823466E+38F) {
      maxdimlen++;
    }
  }

  emxInit_int32_T(sp, &r32, 1, &hd_emlrtRTEI, true);
  i42 = r32->size[0];
  r32->size[0] = maxdimlen;
  emxEnsureCapacity_int32_T(sp, r32, i42, &hd_emlrtRTEI);
  maxdimlen = 0;
  for (iy = 0; iy <= disparityMap_idx_0; iy++) {
    if (disparityMap->data[iy] == -3.402823466E+38F) {
      r32->data[maxdimlen] = iy + 1;
      maxdimlen++;
    }
  }

  maxdimlen = num[0] * num[1];
  iy = r32->size[0];
  for (i42 = 0; i42 < iy; i42++) {
    disparityMap_idx_0 = r32->data[i42];
    if (!((disparityMap_idx_0 >= 1) && (disparityMap_idx_0 <= maxdimlen))) {
      emlrtDynamicBoundsCheckR2012b(disparityMap_idx_0, 1, maxdimlen,
        &ne_emlrtBCI, sp);
    }

    X->data[disparityMap_idx_0 - 1] = ((real32_T)rtNaN);
  }

  emxFree_int32_T(sp, &r32);
  disparityMap_idx_0 = disparityMap->size[0] * disparityMap->size[1] - 1;
  maxdimlen = 0;
  for (iy = 0; iy <= disparityMap_idx_0; iy++) {
    if (disparityMap->data[iy] == -3.402823466E+38F) {
      maxdimlen++;
    }
  }

  emxInit_int32_T(sp, &r33, 1, &hd_emlrtRTEI, true);
  i42 = r33->size[0];
  r33->size[0] = maxdimlen;
  emxEnsureCapacity_int32_T(sp, r33, i42, &hd_emlrtRTEI);
  maxdimlen = 0;
  for (iy = 0; iy <= disparityMap_idx_0; iy++) {
    if (disparityMap->data[iy] == -3.402823466E+38F) {
      r33->data[maxdimlen] = iy + 1;
      maxdimlen++;
    }
  }

  maxdimlen = b_num[0] * b_num[1];
  iy = r33->size[0];
  for (i42 = 0; i42 < iy; i42++) {
    disparityMap_idx_0 = r33->data[i42];
    if (!((disparityMap_idx_0 >= 1) && (disparityMap_idx_0 <= maxdimlen))) {
      emlrtDynamicBoundsCheckR2012b(disparityMap_idx_0, 1, maxdimlen,
        &oe_emlrtBCI, sp);
    }

    Y->data[disparityMap_idx_0 - 1] = ((real32_T)rtNaN);
  }

  emxFree_int32_T(sp, &r33);
  disparityMap_idx_0 = disparityMap->size[0] * disparityMap->size[1] - 1;
  maxdimlen = 0;
  for (iy = 0; iy <= disparityMap_idx_0; iy++) {
    if (disparityMap->data[iy] == -3.402823466E+38F) {
      maxdimlen++;
    }
  }

  emxInit_int32_T(sp, &r34, 1, &hd_emlrtRTEI, true);
  i42 = r34->size[0];
  r34->size[0] = maxdimlen;
  emxEnsureCapacity_int32_T(sp, r34, i42, &hd_emlrtRTEI);
  maxdimlen = 0;
  for (iy = 0; iy <= disparityMap_idx_0; iy++) {
    if (disparityMap->data[iy] == -3.402823466E+38F) {
      r34->data[maxdimlen] = iy + 1;
      maxdimlen++;
    }
  }

  maxdimlen = c_num[0] * c_num[1];
  iy = r34->size[0];
  for (i42 = 0; i42 < iy; i42++) {
    disparityMap_idx_0 = r34->data[i42];
    if (!((disparityMap_idx_0 >= 1) && (disparityMap_idx_0 <= maxdimlen))) {
      emlrtDynamicBoundsCheckR2012b(disparityMap_idx_0, 1, maxdimlen,
        &pe_emlrtBCI, sp);
    }

    Z->data[disparityMap_idx_0 - 1] = ((real32_T)rtNaN);
  }

  emxFree_int32_T(sp, &r34);
  st.site = &cp_emlrtRSI;
  ysize_idx_0 = (uint32_T)X->size[0];
  ysize_idx_1 = (uint32_T)X->size[1];
  i42 = points3D->size[0] * points3D->size[1] * points3D->size[2];
  points3D->size[0] = (int32_T)ysize_idx_0;
  points3D->size[1] = (int32_T)ysize_idx_1;
  points3D->size[2] = 3;
  emxEnsureCapacity_real32_T2(&st, points3D, i42, &id_emlrtRTEI);
  maxdimlen = 0;
  exitg1 = false;
  while ((!exitg1) && (maxdimlen < 2)) {
    if (points3D->size[maxdimlen] != X->size[maxdimlen]) {
      emlrtErrorWithMessageIdR2018a(&st, &sf_emlrtRTEI,
        "Coder:MATLAB:catenate_dimensionMismatch",
        "Coder:MATLAB:catenate_dimensionMismatch", 0);
      exitg1 = true;
    } else {
      maxdimlen++;
    }
  }

  maxdimlen = 0;
  exitg1 = false;
  while ((!exitg1) && (maxdimlen < 2)) {
    if (points3D->size[maxdimlen] != Y->size[maxdimlen]) {
      emlrtErrorWithMessageIdR2018a(&st, &sf_emlrtRTEI,
        "Coder:MATLAB:catenate_dimensionMismatch",
        "Coder:MATLAB:catenate_dimensionMismatch", 0);
      exitg1 = true;
    } else {
      maxdimlen++;
    }
  }

  maxdimlen = 0;
  exitg1 = false;
  while ((!exitg1) && (maxdimlen < 2)) {
    if (points3D->size[maxdimlen] != Z->size[maxdimlen]) {
      emlrtErrorWithMessageIdR2018a(&st, &sf_emlrtRTEI,
        "Coder:MATLAB:catenate_dimensionMismatch",
        "Coder:MATLAB:catenate_dimensionMismatch", 0);
      exitg1 = true;
    } else {
      maxdimlen++;
    }
  }

  iy = -1;
  disparityMap_idx_0 = X->size[0] * X->size[1];
  b_st.site = &dp_emlrtRSI;
  if ((!(1 > disparityMap_idx_0)) && (disparityMap_idx_0 > 2147483646)) {
    c_st.site = &lb_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }

  for (maxdimlen = 1; maxdimlen <= disparityMap_idx_0; maxdimlen++) {
    iy++;
    points3D->data[iy] = X->data[maxdimlen - 1];
  }

  emxFree_real32_T(&st, &X);
  disparityMap_idx_0 = Y->size[0] * Y->size[1];
  b_st.site = &dp_emlrtRSI;
  if ((!(1 > disparityMap_idx_0)) && (disparityMap_idx_0 > 2147483646)) {
    c_st.site = &lb_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }

  for (maxdimlen = 1; maxdimlen <= disparityMap_idx_0; maxdimlen++) {
    iy++;
    points3D->data[iy] = Y->data[maxdimlen - 1];
  }

  emxFree_real32_T(&st, &Y);
  disparityMap_idx_0 = Z->size[0] * Z->size[1];
  b_st.site = &dp_emlrtRSI;
  if ((!(1 > disparityMap_idx_0)) && (disparityMap_idx_0 > 2147483646)) {
    c_st.site = &lb_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }

  for (maxdimlen = 1; maxdimlen <= disparityMap_idx_0; maxdimlen++) {
    iy++;
    points3D->data[iy] = Z->data[maxdimlen - 1];
  }

  emxFree_real32_T(&st, &Z);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void computeRowAlignmentRotation(const emlrtStack *sp, const real_T t[3], real_T
  RrowAlign[9])
{
  real_T angle;
  int32_T k;
  real_T xUnitVector[3];
  static const int8_T a[3] = { 1, 0, 0 };

  real_T rotationAxis[3];
  static const int8_T iv5[3] = { -1, 0, 0 };

  real_T y;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  angle = 0.0;
  for (k = 0; k < 3; k++) {
    xUnitVector[k] = a[k];
    angle += (real_T)a[k] * t[k];
  }

  if (angle < 0.0) {
    for (k = 0; k < 3; k++) {
      xUnitVector[k] = iv5[k];
    }
  }

  rotationAxis[0] = t[1] * xUnitVector[2] - t[2] * xUnitVector[1];
  rotationAxis[1] = t[2] * xUnitVector[0] - t[0] * xUnitVector[2];
  rotationAxis[2] = t[0] * xUnitVector[1] - t[1] * xUnitVector[0];
  if (norm(rotationAxis) == 0.0) {
    memset(&RrowAlign[0], 0, 9U * sizeof(real_T));
    for (k = 0; k < 3; k++) {
      RrowAlign[k + 3 * k] = 1.0;
    }
  } else {
    y = norm(rotationAxis);
    angle = 0.0;
    for (k = 0; k < 3; k++) {
      angle += t[k] * xUnitVector[k];
      rotationAxis[k] /= y;
    }

    angle = muDoubleScalarAbs(angle) / (norm(t) * norm(xUnitVector));
    st.site = &xf_emlrtRSI;
    if ((angle < -1.0) || (angle > 1.0)) {
      b_st.site = &vf_emlrtRSI;
      c_error(&b_st);
    }

    angle = muDoubleScalarAcos(angle);
    for (k = 0; k < 3; k++) {
      rotationAxis[k] *= angle;
    }

    rodriguesVectorToMatrix(rotationAxis, RrowAlign);
  }
}

/* End of code generation (StereoParametersImpl.c) */
