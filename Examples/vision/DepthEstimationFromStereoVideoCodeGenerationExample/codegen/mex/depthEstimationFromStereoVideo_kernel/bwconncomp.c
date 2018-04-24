/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * bwconncomp.c
 *
 * Code generation for function 'bwconncomp'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "bwconncomp.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "eml_int_forloop_overflow_check.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo tl_emlrtRSI = { 9,  /* lineNo */
  "bwconncomp",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pathName */
};

static emlrtRSInfo ul_emlrtRSI = { 30, /* lineNo */
  "bwconncomp",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pathName */
};

static emlrtRSInfo vl_emlrtRSI = { 43, /* lineNo */
  "bwconncomp",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pathName */
};

static emlrtRSInfo wl_emlrtRSI = { 55, /* lineNo */
  "bwconncomp",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pathName */
};

static emlrtRSInfo xl_emlrtRSI = { 56, /* lineNo */
  "bwconncomp",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pathName */
};

static emlrtRSInfo yl_emlrtRSI = { 57, /* lineNo */
  "bwconncomp",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pathName */
};

static emlrtRSInfo am_emlrtRSI = { 65, /* lineNo */
  "bwconncomp",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pathName */
};

static emlrtRSInfo bm_emlrtRSI = { 33, /* lineNo */
  "intermediateLabelRuns",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m"/* pathName */
};

static emlrtRSInfo cm_emlrtRSI = { 51, /* lineNo */
  "intermediateLabelRuns",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m"/* pathName */
};

static emlrtRSInfo dm_emlrtRSI = { 114,/* lineNo */
  "intermediateLabelRuns",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m"/* pathName */
};

static emlrtRSInfo em_emlrtRSI = { 149,/* lineNo */
  "intermediateLabelRuns",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m"/* pathName */
};

static emlrtRSInfo fm_emlrtRSI = { 150,/* lineNo */
  "intermediateLabelRuns",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m"/* pathName */
};

static emlrtRSInfo gm_emlrtRSI = { 153,/* lineNo */
  "intermediateLabelRuns",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m"/* pathName */
};

static emlrtRSInfo nm_emlrtRSI = { 32, /* lineNo */
  "useConstantDim",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\useConstantDim.m"/* pathName */
};

static emlrtRSInfo om_emlrtRSI = { 93, /* lineNo */
  "cumop",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\cumop.m"/* pathName */
};

static emlrtRTEInfo oc_emlrtRTEI = { 1,/* lineNo */
  15,                                  /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pName */
};

static emlrtRTEInfo pc_emlrtRTEI = { 9,/* lineNo */
  1,                                   /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pName */
};

static emlrtRTEInfo qc_emlrtRTEI = { 25,/* lineNo */
  1,                                   /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pName */
};

static emlrtRTEInfo rc_emlrtRTEI = { 41,/* lineNo */
  1,                                   /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pName */
};

static emlrtRTEInfo sc_emlrtRTEI = { 55,/* lineNo */
  1,                                   /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pName */
};

static emlrtRTEInfo tc_emlrtRTEI = { 56,/* lineNo */
  1,                                   /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m"/* pName */
};

static emlrtBCInfo dc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  66,                                  /* lineNo */
  63,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ec_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  65,                                  /* lineNo */
  41,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo fc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  65,                                  /* lineNo */
  31,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo gc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  59,                                  /* lineNo */
  82,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo i_emlrtDCI = { 55,  /* lineNo */
  37,                                  /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo j_emlrtDCI = { 55,  /* lineNo */
  37,                                  /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  4                                    /* checkKind */
};

static emlrtBCInfo hc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  45,                                  /* lineNo */
  52,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo k_emlrtDCI = { 48,  /* lineNo */
  33,                                  /* colNo */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  4                                    /* checkKind */
};

static emlrtBCInfo ic_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  75,                                  /* lineNo */
  18,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo jc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  81,                                  /* lineNo */
  22,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo kc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  86,                                  /* lineNo */
  34,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo lc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  80,                                  /* lineNo */
  34,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo mc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  130,                                 /* lineNo */
  25,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo nc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  134,                                 /* lineNo */
  25,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo oc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  95,                                  /* lineNo */
  25,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo pc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  95,                                  /* lineNo */
  41,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo qc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  95,                                  /* lineNo */
  66,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo rc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  95,                                  /* lineNo */
  80,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo sc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  99,                                  /* lineNo */
  37,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo tc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  108,                                 /* lineNo */
  41,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo uc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  108,                                 /* lineNo */
  63,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo vc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  181,                                 /* lineNo */
  23,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo wc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  170,                                 /* lineNo */
  12,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo xc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  171,                                 /* lineNo */
  12,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo yc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  167,                                 /* lineNo */
  12,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ad_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  168,                                 /* lineNo */
  12,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo bd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  182,                                 /* lineNo */
  27,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo cd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  182,                                 /* lineNo */
  34,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo dd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  182,                                 /* lineNo */
  12,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ed_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  183,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo fd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  103,                                 /* lineNo */
  58,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo gd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  103,                                 /* lineNo */
  37,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo hd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  228,                                 /* lineNo */
  34,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo id_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  228,                                 /* lineNo */
  38,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo jd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  232,                                 /* lineNo */
  31,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo kd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  232,                                 /* lineNo */
  35,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ld_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  233,                                 /* lineNo */
  15,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo md_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  234,                                 /* lineNo */
  16,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo nd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  235,                                 /* lineNo */
  38,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo od_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  235,                                 /* lineNo */
  42,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo pd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  238,                                 /* lineNo */
  16,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo l_emlrtDCI = { 41,  /* lineNo */
  23,                                  /* colNo */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  1                                    /* checkKind */
};

static emlrtBCInfo qd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  62,                                  /* lineNo */
  52,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo rd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  66,                                  /* lineNo */
  22,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo sd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  67,                                  /* lineNo */
  26,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo td_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  67,                                  /* lineNo */
  35,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ud_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  48,                                  /* lineNo */
  46,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo vd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  48,                                  /* lineNo */
  62,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo wd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  48,                                  /* lineNo */
  76,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo xd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  48,                                  /* lineNo */
  23,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo yd_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  32,                                  /* lineNo */
  25,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ae_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  34,                                  /* lineNo */
  26,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo be_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  38,                                  /* lineNo */
  44,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ce_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  38,                                  /* lineNo */
  60,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo de_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  38,                                  /* lineNo */
  22,                                  /* colNo */
  "",                                  /* aName */
  "bwconncomp",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\bwconncomp.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ee_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  198,                                 /* lineNo */
  18,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo fe_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  204,                                 /* lineNo */
  21,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ge_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  204,                                 /* lineNo */
  23,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo he_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  204,                                 /* lineNo */
  41,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ie_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  204,                                 /* lineNo */
  45,                                  /* colNo */
  "",                                  /* aName */
  "intermediateLabelRuns",             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\intermediateLabelRuns.m",/* pName */
  0                                    /* checkKind */
};

/* Function Definitions */
void bwconncomp(const emlrtStack *sp, const emxArray_boolean_T *varargin_1,
                real_T *CC_Connectivity, real_T CC_ImageSize[2], real_T
                *CC_NumObjects, emxArray_real_T *CC_RegionIndices,
                emxArray_int32_T *CC_RegionLengths)
{
  int32_T numRuns;
  int32_T lastRunOnPreviousColumn;
  emxArray_int32_T *regionLengths;
  emxArray_int32_T *startRow;
  int32_T i36;
  emxArray_int32_T *endRow;
  emxArray_int32_T *startCol;
  int32_T k;
  int32_T i37;
  int32_T firstRunOnPreviousColumn;
  int32_T runCounter;
  emxArray_int32_T *labelsRenumbered;
  int32_T nextLabel;
  real_T numComponents;
  boolean_T exitg1;
  int32_T firstRunOnThisColumn;
  int32_T p;
  real_T y;
  emxArray_real_T *pixelIdxList;
  boolean_T overflow;
  emxArray_int32_T *x;
  int32_T root_k;
  emxArray_int32_T *idxCount;
  int32_T exitg2;
  int32_T root_p;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &tl_emlrtRSI;
  b_st.site = &bm_emlrtRSI;
  numRuns = 0;
  if ((varargin_1->size[0] != 0) && (varargin_1->size[1] != 0)) {
    for (lastRunOnPreviousColumn = 1; lastRunOnPreviousColumn - 1 <
         varargin_1->size[1]; lastRunOnPreviousColumn++) {
      i36 = varargin_1->size[1];
      if (!((lastRunOnPreviousColumn >= 1) && (lastRunOnPreviousColumn <= i36)))
      {
        emlrtDynamicBoundsCheckR2012b(lastRunOnPreviousColumn, 1, i36,
          &ee_emlrtBCI, &b_st);
      }

      if (varargin_1->data[varargin_1->size[0] * (lastRunOnPreviousColumn - 1)])
      {
        numRuns++;
      }

      for (k = 0; k <= varargin_1->size[0] - 2; k++) {
        i36 = varargin_1->size[0];
        i37 = 2 + k;
        if (!((i37 >= 1) && (i37 <= i36))) {
          emlrtDynamicBoundsCheckR2012b(i37, 1, i36, &fe_emlrtBCI, &b_st);
        }

        i36 = varargin_1->size[1];
        if (!((lastRunOnPreviousColumn >= 1) && (lastRunOnPreviousColumn <= i36)))
        {
          emlrtDynamicBoundsCheckR2012b(lastRunOnPreviousColumn, 1, i36,
            &ge_emlrtBCI, &b_st);
        }

        if (varargin_1->data[(i37 + varargin_1->size[0] *
                              (lastRunOnPreviousColumn - 1)) - 1]) {
          i36 = varargin_1->size[0];
          if (!((k + 1 >= 1) && (k + 1 <= i36))) {
            emlrtDynamicBoundsCheckR2012b(k + 1, 1, i36, &he_emlrtBCI, &b_st);
          }

          i36 = varargin_1->size[1];
          if (!((lastRunOnPreviousColumn >= 1) && (lastRunOnPreviousColumn <=
                i36))) {
            emlrtDynamicBoundsCheckR2012b(lastRunOnPreviousColumn, 1, i36,
              &ie_emlrtBCI, &b_st);
          }

          if (!varargin_1->data[k + varargin_1->size[0] *
              (lastRunOnPreviousColumn - 1)]) {
            numRuns++;
          }
        }
      }
    }
  }

  emxInit_int32_T(&st, &regionLengths, 1, &rc_emlrtRTEI, true);
  emxInit_int32_T(&st, &startRow, 1, &oc_emlrtRTEI, true);
  emxInit_int32_T(&st, &endRow, 1, &oc_emlrtRTEI, true);
  emxInit_int32_T(&st, &startCol, 1, &oc_emlrtRTEI, true);
  if (numRuns == 0) {
    i36 = startRow->size[0];
    startRow->size[0] = 0;
    emxEnsureCapacity_int32_T(&st, startRow, i36, &oc_emlrtRTEI);
    i36 = endRow->size[0];
    endRow->size[0] = 0;
    emxEnsureCapacity_int32_T(&st, endRow, i36, &oc_emlrtRTEI);
    i36 = startCol->size[0];
    startCol->size[0] = 0;
    emxEnsureCapacity_int32_T(&st, startCol, i36, &oc_emlrtRTEI);
    i36 = regionLengths->size[0];
    regionLengths->size[0] = 0;
    emxEnsureCapacity_int32_T(&st, regionLengths, i36, &oc_emlrtRTEI);
  } else {
    i36 = startRow->size[0];
    if (!(numRuns >= 0)) {
      emlrtNonNegativeCheckR2012b(numRuns, &k_emlrtDCI, &st);
    }

    startRow->size[0] = numRuns;
    emxEnsureCapacity_int32_T(&st, startRow, i36, &pc_emlrtRTEI);
    i36 = endRow->size[0];
    endRow->size[0] = numRuns;
    emxEnsureCapacity_int32_T(&st, endRow, i36, &pc_emlrtRTEI);
    i36 = startCol->size[0];
    startCol->size[0] = numRuns;
    emxEnsureCapacity_int32_T(&st, startCol, i36, &pc_emlrtRTEI);
    b_st.site = &cm_emlrtRSI;
    firstRunOnPreviousColumn = varargin_1->size[0];
    runCounter = 1;
    for (lastRunOnPreviousColumn = 1; lastRunOnPreviousColumn - 1 <
         varargin_1->size[1]; lastRunOnPreviousColumn++) {
      nextLabel = 1;
      while (nextLabel <= firstRunOnPreviousColumn) {
        exitg1 = false;
        while ((!exitg1) && (nextLabel <= firstRunOnPreviousColumn)) {
          i36 = varargin_1->size[0];
          if (!((nextLabel >= 1) && (nextLabel <= i36))) {
            emlrtDynamicBoundsCheckR2012b(nextLabel, 1, i36, &hd_emlrtBCI, &b_st);
          }

          i36 = varargin_1->size[1];
          if (!((lastRunOnPreviousColumn >= 1) && (lastRunOnPreviousColumn <=
                i36))) {
            emlrtDynamicBoundsCheckR2012b(lastRunOnPreviousColumn, 1, i36,
              &id_emlrtBCI, &b_st);
          }

          if (!varargin_1->data[(nextLabel + varargin_1->size[0] *
                                 (lastRunOnPreviousColumn - 1)) - 1]) {
            nextLabel++;
          } else {
            exitg1 = true;
          }
        }

        if (nextLabel <= firstRunOnPreviousColumn) {
          i36 = varargin_1->size[0];
          if (!((nextLabel >= 1) && (nextLabel <= i36))) {
            emlrtDynamicBoundsCheckR2012b(nextLabel, 1, i36, &jd_emlrtBCI, &b_st);
          }

          i36 = varargin_1->size[1];
          if (!((lastRunOnPreviousColumn >= 1) && (lastRunOnPreviousColumn <=
                i36))) {
            emlrtDynamicBoundsCheckR2012b(lastRunOnPreviousColumn, 1, i36,
              &kd_emlrtBCI, &b_st);
          }

          if (varargin_1->data[(nextLabel + varargin_1->size[0] *
                                (lastRunOnPreviousColumn - 1)) - 1]) {
            i36 = startCol->size[0];
            if (!((runCounter >= 1) && (runCounter <= i36))) {
              emlrtDynamicBoundsCheckR2012b(runCounter, 1, i36, &ld_emlrtBCI,
                &b_st);
            }

            startCol->data[runCounter - 1] = lastRunOnPreviousColumn;
            i36 = startRow->size[0];
            if (!((runCounter >= 1) && (runCounter <= i36))) {
              emlrtDynamicBoundsCheckR2012b(runCounter, 1, i36, &md_emlrtBCI,
                &b_st);
            }

            startRow->data[runCounter - 1] = nextLabel;
            exitg1 = false;
            while ((!exitg1) && (nextLabel <= firstRunOnPreviousColumn)) {
              i36 = varargin_1->size[0];
              if (!((nextLabel >= 1) && (nextLabel <= i36))) {
                emlrtDynamicBoundsCheckR2012b(nextLabel, 1, i36, &nd_emlrtBCI,
                  &b_st);
              }

              i36 = varargin_1->size[1];
              if (!((lastRunOnPreviousColumn >= 1) && (lastRunOnPreviousColumn <=
                    i36))) {
                emlrtDynamicBoundsCheckR2012b(lastRunOnPreviousColumn, 1, i36,
                  &od_emlrtBCI, &b_st);
              }

              if (varargin_1->data[(nextLabel + varargin_1->size[0] *
                                    (lastRunOnPreviousColumn - 1)) - 1]) {
                nextLabel++;
              } else {
                exitg1 = true;
              }
            }

            i36 = endRow->size[0];
            if (!((runCounter >= 1) && (runCounter <= i36))) {
              emlrtDynamicBoundsCheckR2012b(runCounter, 1, i36, &pd_emlrtBCI,
                &b_st);
            }

            endRow->data[runCounter - 1] = nextLabel - 1;
            runCounter++;
          }
        }
      }
    }

    i36 = regionLengths->size[0];
    regionLengths->size[0] = numRuns;
    emxEnsureCapacity_int32_T(&st, regionLengths, i36, &oc_emlrtRTEI);
    for (i36 = 0; i36 < numRuns; i36++) {
      regionLengths->data[i36] = 0;
    }

    k = 1;
    runCounter = 1;
    nextLabel = 1;
    firstRunOnPreviousColumn = -1;
    lastRunOnPreviousColumn = -1;
    firstRunOnThisColumn = 1;
    while (k <= numRuns) {
      i36 = startCol->size[0];
      if (!((k >= 1) && (k <= i36))) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i36, &ic_emlrtBCI, &st);
      }

      if (startCol->data[k - 1] == runCounter + 1) {
        firstRunOnPreviousColumn = firstRunOnThisColumn;
        firstRunOnThisColumn = k;
        lastRunOnPreviousColumn = k - 1;
        i36 = startCol->size[0];
        if (!((k >= 1) && (k <= i36))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i36, &lc_emlrtBCI, &st);
        }

        runCounter = startCol->data[k - 1];
      } else {
        i36 = startCol->size[0];
        if (!((k >= 1) && (k <= i36))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i36, &jc_emlrtBCI, &st);
        }

        if (startCol->data[k - 1] > runCounter + 1) {
          firstRunOnPreviousColumn = -1;
          lastRunOnPreviousColumn = -1;
          firstRunOnThisColumn = k;
          i36 = startCol->size[0];
          if (!((k >= 1) && (k <= i36))) {
            emlrtDynamicBoundsCheckR2012b(k, 1, i36, &kc_emlrtBCI, &st);
          }

          runCounter = startCol->data[k - 1];
        }
      }

      if (firstRunOnPreviousColumn >= 0) {
        for (p = firstRunOnPreviousColumn; p <= lastRunOnPreviousColumn; p++) {
          i36 = endRow->size[0];
          if (!((k >= 1) && (k <= i36))) {
            emlrtDynamicBoundsCheckR2012b(k, 1, i36, &oc_emlrtBCI, &st);
          }

          i36 = startRow->size[0];
          if (!((p >= 1) && (p <= i36))) {
            emlrtDynamicBoundsCheckR2012b(p, 1, i36, &pc_emlrtBCI, &st);
          }

          if (endRow->data[k - 1] >= startRow->data[p - 1] - 1) {
            i36 = startRow->size[0];
            if (!((k >= 1) && (k <= i36))) {
              emlrtDynamicBoundsCheckR2012b(k, 1, i36, &qc_emlrtBCI, &st);
            }

            i36 = endRow->size[0];
            if (!((p >= 1) && (p <= i36))) {
              emlrtDynamicBoundsCheckR2012b(p, 1, i36, &rc_emlrtBCI, &st);
            }

            if (startRow->data[k - 1] <= endRow->data[p - 1] + 1) {
              i36 = regionLengths->size[0];
              if (!((k >= 1) && (k <= i36))) {
                emlrtDynamicBoundsCheckR2012b(k, 1, i36, &sc_emlrtBCI, &st);
              }

              if (regionLengths->data[k - 1] == 0) {
                i36 = regionLengths->size[0];
                if (!((p >= 1) && (p <= i36))) {
                  emlrtDynamicBoundsCheckR2012b(p, 1, i36, &fd_emlrtBCI, &st);
                }

                i36 = regionLengths->size[0];
                if (!((k >= 1) && (k <= i36))) {
                  emlrtDynamicBoundsCheckR2012b(k, 1, i36, &gd_emlrtBCI, &st);
                }

                regionLengths->data[k - 1] = regionLengths->data[p - 1];
                nextLabel++;
              } else {
                i36 = regionLengths->size[0];
                if (!((k >= 1) && (k <= i36))) {
                  emlrtDynamicBoundsCheckR2012b(k, 1, i36, &tc_emlrtBCI, &st);
                }

                i36 = regionLengths->size[0];
                if (!((p >= 1) && (p <= i36))) {
                  emlrtDynamicBoundsCheckR2012b(p, 1, i36, &uc_emlrtBCI, &st);
                }

                if (regionLengths->data[k - 1] != regionLengths->data[p - 1]) {
                  b_st.site = &dm_emlrtRSI;
                  c_st.site = &em_emlrtRSI;
                  root_k = k;
                  do {
                    exitg2 = 0;
                    i36 = regionLengths->size[0];
                    if (!((root_k >= 1) && (root_k <= i36))) {
                      emlrtDynamicBoundsCheckR2012b(root_k, 1, i36, &vc_emlrtBCI,
                        &c_st);
                    }

                    if (root_k != regionLengths->data[root_k - 1]) {
                      i36 = regionLengths->size[0];
                      i37 = regionLengths->size[0];
                      if (!((root_k >= 1) && (root_k <= i37))) {
                        emlrtDynamicBoundsCheckR2012b(root_k, 1, i37,
                          &cd_emlrtBCI, &c_st);
                      }

                      i37 = regionLengths->data[root_k - 1];
                      if (!((i37 >= 1) && (i37 <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(i37, 1, i36, &bd_emlrtBCI,
                          &c_st);
                      }

                      i36 = regionLengths->size[0];
                      if (!((root_k >= 1) && (root_k <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(root_k, 1, i36,
                          &dd_emlrtBCI, &c_st);
                      }

                      regionLengths->data[root_k - 1] = regionLengths->data[i37
                        - 1];
                      i36 = regionLengths->size[0];
                      if (!((root_k >= 1) && (root_k <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(root_k, 1, i36,
                          &ed_emlrtBCI, &c_st);
                      }

                      root_k = regionLengths->data[root_k - 1];
                    } else {
                      exitg2 = 1;
                    }
                  } while (exitg2 == 0);

                  c_st.site = &fm_emlrtRSI;
                  root_p = p;
                  do {
                    exitg2 = 0;
                    i36 = regionLengths->size[0];
                    if (!((root_p >= 1) && (root_p <= i36))) {
                      emlrtDynamicBoundsCheckR2012b(root_p, 1, i36, &vc_emlrtBCI,
                        &c_st);
                    }

                    if (root_p != regionLengths->data[root_p - 1]) {
                      i36 = regionLengths->size[0];
                      i37 = regionLengths->size[0];
                      if (!((root_p >= 1) && (root_p <= i37))) {
                        emlrtDynamicBoundsCheckR2012b(root_p, 1, i37,
                          &cd_emlrtBCI, &c_st);
                      }

                      i37 = regionLengths->data[root_p - 1];
                      if (!((i37 >= 1) && (i37 <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(i37, 1, i36, &bd_emlrtBCI,
                          &c_st);
                      }

                      i36 = regionLengths->size[0];
                      if (!((root_p >= 1) && (root_p <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(root_p, 1, i36,
                          &dd_emlrtBCI, &c_st);
                      }

                      regionLengths->data[root_p - 1] = regionLengths->data[i37
                        - 1];
                      i36 = regionLengths->size[0];
                      if (!((root_p >= 1) && (root_p <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(root_p, 1, i36,
                          &ed_emlrtBCI, &c_st);
                      }

                      root_p = regionLengths->data[root_p - 1];
                    } else {
                      exitg2 = 1;
                    }
                  } while (exitg2 == 0);

                  if (root_k != root_p) {
                    c_st.site = &gm_emlrtRSI;
                    if (root_p < root_k) {
                      i36 = regionLengths->size[0];
                      if (!((root_k >= 1) && (root_k <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(root_k, 1, i36,
                          &yc_emlrtBCI, &c_st);
                      }

                      regionLengths->data[root_k - 1] = root_p;
                      i36 = regionLengths->size[0];
                      if (!((k >= 1) && (k <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(k, 1, i36, &ad_emlrtBCI,
                          &c_st);
                      }

                      regionLengths->data[k - 1] = root_p;
                    } else {
                      i36 = regionLengths->size[0];
                      if (!((root_p >= 1) && (root_p <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(root_p, 1, i36,
                          &wc_emlrtBCI, &c_st);
                      }

                      regionLengths->data[root_p - 1] = root_k;
                      i36 = regionLengths->size[0];
                      if (!((p >= 1) && (p <= i36))) {
                        emlrtDynamicBoundsCheckR2012b(p, 1, i36, &xc_emlrtBCI,
                          &c_st);
                      }

                      regionLengths->data[p - 1] = root_k;
                    }
                  }
                }
              }
            }
          }
        }
      }

      i36 = regionLengths->size[0];
      if (!((k >= 1) && (k <= i36))) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i36, &mc_emlrtBCI, &st);
      }

      if (regionLengths->data[k - 1] == 0) {
        i36 = regionLengths->size[0];
        if (!((k >= 1) && (k <= i36))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i36, &nc_emlrtBCI, &st);
        }

        regionLengths->data[k - 1] = nextLabel;
        nextLabel++;
      }

      k++;
    }
  }

  if (numRuns == 0) {
    for (i36 = 0; i36 < 2; i36++) {
      CC_ImageSize[i36] = varargin_1->size[i36];
    }

    numComponents = 0.0;
    i36 = CC_RegionIndices->size[0];
    CC_RegionIndices->size[0] = 0;
    emxEnsureCapacity_real_T(sp, CC_RegionIndices, i36, &oc_emlrtRTEI);
    i36 = CC_RegionLengths->size[0];
    CC_RegionLengths->size[0] = 1;
    emxEnsureCapacity_int32_T(sp, CC_RegionLengths, i36, &oc_emlrtRTEI);
    CC_RegionLengths->data[0] = 0;
  } else {
    emxInit_int32_T(sp, &labelsRenumbered, 1, &qc_emlrtRTEI, true);
    i36 = labelsRenumbered->size[0];
    labelsRenumbered->size[0] = regionLengths->size[0];
    emxEnsureCapacity_int32_T(sp, labelsRenumbered, i36, &oc_emlrtRTEI);
    numComponents = 0.0;
    st.site = &ul_emlrtRSI;
    for (k = 1; k <= numRuns; k++) {
      i36 = regionLengths->size[0];
      if (!(k <= i36)) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i36, &yd_emlrtBCI, sp);
      }

      if (regionLengths->data[k - 1] == k) {
        numComponents++;
        i36 = labelsRenumbered->size[0];
        if (!(k <= i36)) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i36, &ae_emlrtBCI, sp);
        }

        labelsRenumbered->data[k - 1] = (int32_T)numComponents;
      }

      i36 = labelsRenumbered->size[0];
      i37 = regionLengths->size[0];
      if (!(k <= i37)) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i37, &ce_emlrtBCI, sp);
      }

      i37 = regionLengths->data[k - 1];
      if (!((i37 >= 1) && (i37 <= i36))) {
        emlrtDynamicBoundsCheckR2012b(i37, 1, i36, &be_emlrtBCI, sp);
      }

      i36 = labelsRenumbered->size[0];
      if (!(k <= i36)) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i36, &de_emlrtBCI, sp);
      }

      labelsRenumbered->data[k - 1] = labelsRenumbered->data[i37 - 1];
    }

    i36 = regionLengths->size[0];
    if (numComponents != (int32_T)numComponents) {
      emlrtIntegerCheckR2012b(numComponents, &l_emlrtDCI, sp);
    }

    regionLengths->size[0] = (int32_T)numComponents;
    emxEnsureCapacity_int32_T(sp, regionLengths, i36, &oc_emlrtRTEI);
    if (numComponents != (int32_T)numComponents) {
      emlrtIntegerCheckR2012b(numComponents, &l_emlrtDCI, sp);
    }

    firstRunOnPreviousColumn = (int32_T)numComponents;
    for (i36 = 0; i36 < firstRunOnPreviousColumn; i36++) {
      regionLengths->data[i36] = 0;
    }

    st.site = &vl_emlrtRSI;
    for (k = 1; k <= numRuns; k++) {
      i36 = labelsRenumbered->size[0];
      if (!(k <= i36)) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i36, &hc_emlrtBCI, sp);
      }

      if (labelsRenumbered->data[k - 1] > 0) {
        i36 = regionLengths->size[0];
        i37 = labelsRenumbered->data[k - 1];
        if (!((i37 >= 1) && (i37 <= i36))) {
          emlrtDynamicBoundsCheckR2012b(i37, 1, i36, &ud_emlrtBCI, sp);
        }

        i36 = endRow->size[0];
        if (!(k <= i36)) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i36, &vd_emlrtBCI, sp);
        }

        i36 = startRow->size[0];
        if (!(k <= i36)) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i36, &wd_emlrtBCI, sp);
        }

        i36 = regionLengths->size[0];
        firstRunOnPreviousColumn = labelsRenumbered->data[k - 1];
        if (!((firstRunOnPreviousColumn >= 1) && (firstRunOnPreviousColumn <=
              i36))) {
          emlrtDynamicBoundsCheckR2012b(firstRunOnPreviousColumn, 1, i36,
            &xd_emlrtBCI, sp);
        }

        regionLengths->data[firstRunOnPreviousColumn - 1] =
          ((regionLengths->data[i37 - 1] + endRow->data[k - 1]) - startRow->
           data[k - 1]) + 1;
      }
    }

    st.site = &wl_emlrtRSI;
    b_st.site = &hm_emlrtRSI;
    c_st.site = &im_emlrtRSI;
    if (regionLengths->size[0] == 0) {
      y = 0.0;
    } else {
      d_st.site = &jm_emlrtRSI;
      y = regionLengths->data[0];
      e_st.site = &km_emlrtRSI;
      overflow = ((!(2 > regionLengths->size[0])) && (regionLengths->size[0] >
        2147483646));
      if (overflow) {
        f_st.site = &lb_emlrtRSI;
        check_forloop_overflow_error(&f_st);
      }

      for (k = 2; k <= regionLengths->size[0]; k++) {
        y += (real_T)regionLengths->data[k - 1];
      }
    }

    emxInit_real_T1(&c_st, &pixelIdxList, 1, &sc_emlrtRTEI, true);
    emxInit_int32_T(&c_st, &x, 1, &oc_emlrtRTEI, true);
    if (!(y >= 0.0)) {
      emlrtNonNegativeCheckR2012b(y, &j_emlrtDCI, sp);
    }

    if (y != (int32_T)y) {
      emlrtIntegerCheckR2012b(y, &i_emlrtDCI, sp);
    }

    i36 = pixelIdxList->size[0];
    pixelIdxList->size[0] = (int32_T)y;
    emxEnsureCapacity_real_T(sp, pixelIdxList, i36, &oc_emlrtRTEI);
    st.site = &xl_emlrtRSI;
    i36 = x->size[0];
    x->size[0] = regionLengths->size[0];
    emxEnsureCapacity_int32_T(&st, x, i36, &oc_emlrtRTEI);
    firstRunOnPreviousColumn = regionLengths->size[0];
    for (i36 = 0; i36 < firstRunOnPreviousColumn; i36++) {
      x->data[i36] = regionLengths->data[i36];
    }

    b_st.site = &lm_emlrtRSI;
    firstRunOnPreviousColumn = 2;
    if (regionLengths->size[0] != 1) {
      firstRunOnPreviousColumn = 1;
    }

    c_st.site = &mm_emlrtRSI;
    if (1 == firstRunOnPreviousColumn) {
      d_st.site = &nm_emlrtRSI;
      e_st.site = &om_emlrtRSI;
      if ((regionLengths->size[0] != 0) && (regionLengths->size[0] != 1)) {
        for (k = 1; k < regionLengths->size[0]; k++) {
          x->data[k] += x->data[k - 1];
        }
      }
    }

    emxInit_int32_T(&c_st, &idxCount, 1, &tc_emlrtRTEI, true);
    i36 = idxCount->size[0];
    idxCount->size[0] = 1 + x->size[0];
    emxEnsureCapacity_int32_T(sp, idxCount, i36, &oc_emlrtRTEI);
    idxCount->data[0] = 0;
    firstRunOnPreviousColumn = x->size[0];
    for (i36 = 0; i36 < firstRunOnPreviousColumn; i36++) {
      idxCount->data[i36 + 1] = x->data[i36];
    }

    emxFree_int32_T(sp, &x);
    st.site = &yl_emlrtRSI;
    for (k = 1; k <= numRuns; k++) {
      i36 = startCol->size[0];
      if (!(k <= i36)) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i36, &gc_emlrtBCI, sp);
      }

      firstRunOnPreviousColumn = (startCol->data[k - 1] - 1) * varargin_1->size
        [0];
      i36 = labelsRenumbered->size[0];
      if (!(k <= i36)) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i36, &qd_emlrtBCI, sp);
      }

      runCounter = labelsRenumbered->data[k - 1];
      if (labelsRenumbered->data[k - 1] > 0) {
        i36 = startRow->size[0];
        if (!(k <= i36)) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i36, &fc_emlrtBCI, sp);
        }

        i36 = endRow->size[0];
        if (!(k <= i36)) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i36, &ec_emlrtBCI, sp);
        }

        st.site = &am_emlrtRSI;
        for (nextLabel = startRow->data[k - 1]; nextLabel <= endRow->data[k - 1];
             nextLabel++) {
          i36 = idxCount->size[0];
          if (!((runCounter >= 1) && (runCounter <= i36))) {
            emlrtDynamicBoundsCheckR2012b(runCounter, 1, i36, &dc_emlrtBCI, sp);
          }

          i36 = idxCount->size[0];
          if (!((runCounter >= 1) && (runCounter <= i36))) {
            emlrtDynamicBoundsCheckR2012b(runCounter, 1, i36, &rd_emlrtBCI, sp);
          }

          idxCount->data[runCounter - 1]++;
          i36 = pixelIdxList->size[0];
          i37 = idxCount->size[0];
          if (!((runCounter >= 1) && (runCounter <= i37))) {
            emlrtDynamicBoundsCheckR2012b(runCounter, 1, i37, &td_emlrtBCI, sp);
          }

          i37 = idxCount->data[runCounter - 1];
          if (!((i37 >= 1) && (i37 <= i36))) {
            emlrtDynamicBoundsCheckR2012b(i37, 1, i36, &sd_emlrtBCI, sp);
          }

          pixelIdxList->data[i37 - 1] = nextLabel + firstRunOnPreviousColumn;
        }
      }
    }

    emxFree_int32_T(sp, &idxCount);
    emxFree_int32_T(sp, &labelsRenumbered);
    for (i36 = 0; i36 < 2; i36++) {
      CC_ImageSize[i36] = varargin_1->size[i36];
    }

    i36 = CC_RegionIndices->size[0];
    CC_RegionIndices->size[0] = pixelIdxList->size[0];
    emxEnsureCapacity_real_T(sp, CC_RegionIndices, i36, &oc_emlrtRTEI);
    firstRunOnPreviousColumn = pixelIdxList->size[0];
    for (i36 = 0; i36 < firstRunOnPreviousColumn; i36++) {
      CC_RegionIndices->data[i36] = pixelIdxList->data[i36];
    }

    emxFree_real_T(sp, &pixelIdxList);
    i36 = CC_RegionLengths->size[0];
    CC_RegionLengths->size[0] = regionLengths->size[0];
    emxEnsureCapacity_int32_T(sp, CC_RegionLengths, i36, &oc_emlrtRTEI);
    firstRunOnPreviousColumn = regionLengths->size[0];
    for (i36 = 0; i36 < firstRunOnPreviousColumn; i36++) {
      CC_RegionLengths->data[i36] = regionLengths->data[i36];
    }
  }

  emxFree_int32_T(sp, &startCol);
  emxFree_int32_T(sp, &endRow);
  emxFree_int32_T(sp, &startRow);
  emxFree_int32_T(sp, &regionLengths);
  *CC_Connectivity = 8.0;
  *CC_NumObjects = numComponents;
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (bwconncomp.c) */
