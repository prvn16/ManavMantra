/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * CameraParametersImpl.c
 *
 * Code generation for function 'CameraParametersImpl'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "CameraParametersImpl.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "distortPoints.h"
#include "ImageTransformer.h"
#include "sum.h"
#include "sub2ind.h"
#include "ceil.h"
#include "floor.h"
#include "meshgrid.h"
#include "matlabCodegenHandle.h"
#include "sort1.h"
#include "unaryMinOrMax.h"
#include "abs.h"
#include "bwtraceboundary.h"
#include "regionprops.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo rb_emlrtRSI = { 43, /* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo tc_emlrtRSI = { 193,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo uc_emlrtRSI = { 246,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo vc_emlrtRSI = { 266,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo wc_emlrtRSI = { 310,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo xc_emlrtRSI = { 316,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo yc_emlrtRSI = { 321,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ad_emlrtRSI = { 331,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo bd_emlrtRSI = { 336,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo cd_emlrtRSI = { 356,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo dd_emlrtRSI = { 733,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ed_emlrtRSI = { 741,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo fd_emlrtRSI = { 751,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo gd_emlrtRSI = { 771,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo hd_emlrtRSI = { 781,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo id_emlrtRSI = { 816,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ug_emlrtRSI = { 959,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo vg_emlrtRSI = { 966,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo wg_emlrtRSI = { 1007,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo xg_emlrtRSI = { 1027,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo yg_emlrtRSI = { 1028,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ah_emlrtRSI = { 1029,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo bh_emlrtRSI = { 1030,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ch_emlrtRSI = { 1037,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo dh_emlrtRSI = { 1042,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo eh_emlrtRSI = { 1043,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo fh_emlrtRSI = { 1044,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo gh_emlrtRSI = { 1045,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo hh_emlrtRSI = { 1049,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ih_emlrtRSI = { 1071,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo jh_emlrtRSI = { 1072,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo kh_emlrtRSI = { 1076,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ji_emlrtRSI = { 89, /* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo cj_emlrtRSI = { 1109,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo dj_emlrtRSI = { 1110,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ej_emlrtRSI = { 1121,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo fj_emlrtRSI = { 1126,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo gj_emlrtRSI = { 1127,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo hj_emlrtRSI = { 1128,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ij_emlrtRSI = { 1129,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo jj_emlrtRSI = { 1130,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo kj_emlrtRSI = { 1131,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo lj_emlrtRSI = { 1132,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo mj_emlrtRSI = { 1133,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo nj_emlrtRSI = { 1146,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo oj_emlrtRSI = { 1147,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo pj_emlrtRSI = { 1148,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo qj_emlrtRSI = { 1149,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo fk_emlrtRSI = { 867,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ik_emlrtRSI = { 40, /* lineNo */
  "minOrMax",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pathName */
};

static emlrtRSInfo jk_emlrtRSI = { 114,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo hl_emlrtRSI = { 963,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo il_emlrtRSI = { 1176,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo jl_emlrtRSI = { 1182,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo kl_emlrtRSI = { 1183,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ll_emlrtRSI = { 1185,/* lineNo */
  "CameraParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pathName */
};

static emlrtRSInfo ln_emlrtRSI = { 15, /* lineNo */
  "min",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\min.m"/* pathName */
};

static emlrtRSInfo mn_emlrtRSI = { 16, /* lineNo */
  "minOrMax",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pathName */
};

static emlrtRSInfo nn_emlrtRSI = { 38, /* lineNo */
  "minOrMax",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pathName */
};

static emlrtRSInfo on_emlrtRSI = { 112,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRTEInfo q_emlrtRTEI = { 954,/* lineNo */
  17,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo r_emlrtRTEI = { 966,/* lineNo */
  21,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo s_emlrtRTEI = { 1110,/* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo t_emlrtRTEI = { 1121,/* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo u_emlrtRTEI = { 1130,/* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo v_emlrtRTEI = { 1131,/* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo w_emlrtRTEI = { 1132,/* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo x_emlrtRTEI = { 1133,/* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo y_emlrtRTEI = { 976,/* lineNo */
  17,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo bb_emlrtRTEI = { 1071,/* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo cb_emlrtRTEI = { 1042,/* lineNo */
  21,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo db_emlrtRTEI = { 987,/* lineNo */
  17,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo gc_emlrtRTEI = { 1176,/* lineNo */
  1,                                   /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo hc_emlrtRTEI = { 1180,/* lineNo */
  1,                                   /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtECInfo c_emlrtECI = { -1,  /* nDims */
  1117,                                /* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtECInfo d_emlrtECI = { -1,  /* nDims */
  1118,                                /* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtRTEInfo af_emlrtRTEI = { 1142,/* lineNo */
  13,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtBCInfo k_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  1136,                                /* lineNo */
  51,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo l_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  1137,                                /* lineNo */
  51,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo m_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  1138,                                /* lineNo */
  52,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo n_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  1139,                                /* lineNo */
  53,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRTEInfo bf_emlrtRTEI = { 22,/* lineNo */
  27,                                  /* colNo */
  "unaryMinOrMax",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pName */
};

static emlrtBCInfo o_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  1114,                                /* lineNo */
  70,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo emlrtDCI = { 1027,  /* lineNo */
  61,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo b_emlrtDCI = { 1028,/* lineNo */
  61,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo c_emlrtDCI = { 1029,/* lineNo */
  42,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo d_emlrtDCI = { 1030,/* lineNo */
  42,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  1                                    /* checkKind */
};

static emlrtECInfo e_emlrtECI = { -1,  /* nDims */
  1046,                                /* lineNo */
  36,                                  /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtBCInfo p_emlrtBCI = { 1,   /* iFirst */
  307200,                              /* iLast */
  1008,                                /* lineNo */
  18,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  3                                    /* checkKind */
};

static emlrtBCInfo q_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  1048,                                /* lineNo */
  37,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo r_emlrtBCI = { 1,   /* iFirst */
  307200,                              /* iLast */
  1050,                                /* lineNo */
  26,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  3                                    /* checkKind */
};

static emlrtRTEInfo jf_emlrtRTEI = { 1208,/* lineNo */
  9,                                   /* colNo */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m"/* pName */
};

static emlrtBCInfo s_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  1209,                                /* lineNo */
  24,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo t_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  1209,                                /* lineNo */
  27,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo tb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1186,                                /* lineNo */
  14,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ub_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1182,                                /* lineNo */
  23,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo vb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1183,                                /* lineNo */
  16,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo wb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1182,                                /* lineNo */
  11,                                  /* colNo */
  "",                                  /* aName */
  "CameraParametersImpl",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\CameraParametersImpl.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRTEInfo bg_emlrtRTEI = { 21,/* lineNo */
  27,                                  /* colNo */
  "validatege",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatege.m"/* pName */
};

/* Function Declarations */
static void c_CameraParametersImpl_createUn(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_C *this,
  emxArray_uint8_T *undistortedMask, real_T xBoundsBig[2], real_T yBoundsBig[2]);
static void c_CameraParametersImpl_distortP(const emlrtStack *sp, const
  c_vision_internal_calibration_C *this, const emxArray_real_T *points,
  emxArray_real_T *distortedPoints);
static void d_CameraParametersImpl_createUn(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_C *this,
  emxArray_uint8_T *undistortedMask, real_T xBoundsBig[2], real_T yBoundsBig[2]);
static void getInitialBoundaryPixel(const emlrtStack *sp, const emxArray_uint8_T
  *undistortedMask, real_T boundaryPixel[2]);

/* Function Definitions */
static void c_CameraParametersImpl_createUn(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_C *this,
  emxArray_uint8_T *undistortedMask, real_T xBoundsBig[2], real_T yBoundsBig[2])
{
  c_vision_internal_calibration_I myMap;
  int32_T i11;
  real_T dv1[640];
  real_T dv2[480];
  int32_T n;
  real_T intrinsicMatrix[9];
  int32_T trueCount;
  int32_T nm1d2;
  emxArray_int32_T *r11;
  boolean_T p;
  boolean_T b_p;
  emxArray_real_T *allPts;
  emxArray_real_T *varargin_1;
  int32_T loop_ub;
  emxArray_real_T *varargin_2;
  real_T b_varargin_1[2];
  real_T b_varargin_2[2];
  boolean_T exitg1;
  real_T numUnmapped;
  int32_T numTrials;
  real_T p1[2];
  emxArray_real_T *newPts;
  real_T p2[2];
  emxArray_real_T *ptsOut;
  emxArray_boolean_T *r12;
  emxArray_boolean_T *r13;
  emxArray_int32_T *r14;
  emxArray_int32_T *r15;
  emxArray_real_T *y;
  emxArray_real_T *c_varargin_1;
  emxArray_real_T *c_varargin_2;
  emxArray_real_T *d_varargin_1;
  emxArray_real_T *d_varargin_2;
  emxArray_real_T *e_varargin_1;
  emxArray_real_T *e_varargin_2;
  emxArray_real_T *r16;
  emxArray_real_T *f_varargin_1;
  static const char_T cv10[5] = { 'u', 'i', 'n', 't', '8' };

  real_T w;
  real_T h;
  real_T lastNumUnmapped;
  static const char_T outputView[5] = { 'v', 'a', 'l', 'i', 'd' };

  real_T ndbl;
  real_T apnd;
  real_T cdiff;
  real_T absa;
  real_T absb;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  d_emxInitStruct_vision_internal(sp, &myMap, &bb_emlrtRTEI, true);
  for (i11 = 0; i11 < 2; i11++) {
    xBoundsBig[i11] = 1.0 + 639.0 * (real_T)i11;
    yBoundsBig[i11] = 1.0 + 479.0 * (real_T)i11;
  }

  for (i11 = 0; i11 < 640; i11++) {
    dv1[i11] = 1.0 + (real_T)i11;
  }

  for (i11 = 0; i11 < 480; i11++) {
    dv2[i11] = 1.0 + (real_T)i11;
  }

  meshgrid(dv1, dv2, SD->u2.f4.b_X, SD->u2.f4.Y);
  for (i11 = 0; i11 < 3; i11++) {
    for (n = 0; n < 3; n++) {
      intrinsicMatrix[n + 3 * i11] = this->IntrinsicMatrixInternal[i11 + 3 * n];
    }
  }

  for (i11 = 0; i11 < 307200; i11++) {
    SD->u2.f4.X[i11] = SD->u2.f4.b_X[i11];
    SD->u2.f4.X[307200 + i11] = SD->u2.f4.Y[i11];
    SD->u2.f4.mask[i11] = 0U;
  }

  distortPoints(SD, SD->u2.f4.X, intrinsicMatrix, this->RadialDistortion,
                this->TangentialDistortion, SD->u2.f4.ptsOut);
  memcpy(&SD->u2.f4.X[0], &SD->u2.f4.ptsOut[0], 614400U * sizeof(real_T));
  b_floor(SD->u2.f4.X);
  memcpy(&SD->u2.f4.b_ptsOut[0], &SD->u2.f4.ptsOut[0], 307200U * sizeof(real_T));
  for (i11 = 0; i11 < 640; i11++) {
    memcpy(&SD->u2.f4.b_X[i11 * 480], &SD->u2.f4.b_ptsOut[i11 * 480], 480U *
           sizeof(real_T));
  }

  c_floor(SD->u2.f4.b_X);
  memcpy(&SD->u2.f4.b_ptsOut[0], &SD->u2.f4.ptsOut[307200], 307200U * sizeof
         (real_T));
  for (i11 = 0; i11 < 640; i11++) {
    memcpy(&SD->u2.f4.Y[i11 * 480], &SD->u2.f4.b_ptsOut[i11 * 480], 480U *
           sizeof(real_T));
  }

  b_ceil(SD->u2.f4.Y);
  memcpy(&SD->u2.f4.b_ptsOut[0], &SD->u2.f4.ptsOut[0], 307200U * sizeof(real_T));
  b_ceil(SD->u2.f4.b_ptsOut);
  memcpy(&SD->u2.f4.dv3[0], &SD->u2.f4.ptsOut[307200], 307200U * sizeof(real_T));
  c_floor(SD->u2.f4.dv3);
  c_ceil(SD->u2.f4.ptsOut);
  for (i11 = 0; i11 < 2; i11++) {
    memcpy(&SD->u2.f4.allPts[i11 * 1228800], &SD->u2.f4.X[i11 * 307200], 307200U
           * sizeof(real_T));
  }

  for (i11 = 0; i11 < 307200; i11++) {
    SD->u2.f4.allPts[i11 + 307200] = SD->u2.f4.b_X[i11];
    SD->u2.f4.allPts[i11 + 1536000] = SD->u2.f4.Y[i11];
    SD->u2.f4.allPts[i11 + 614400] = SD->u2.f4.b_ptsOut[i11];
    SD->u2.f4.allPts[i11 + 1843200] = SD->u2.f4.dv3[i11];
  }

  for (i11 = 0; i11 < 2; i11++) {
    memcpy(&SD->u2.f4.allPts[i11 * 1228800 + 921600], &SD->u2.f4.ptsOut[i11 *
           307200], 307200U * sizeof(real_T));
  }

  trueCount = 0;
  for (nm1d2 = 0; nm1d2 < 1228800; nm1d2++) {
    p = ((SD->u2.f4.allPts[nm1d2] >= 1.0) && (SD->u2.f4.allPts[1228800 + nm1d2] >=
          1.0) && (SD->u2.f4.allPts[nm1d2] <= 640.0));
    b_p = (SD->u2.f4.allPts[1228800 + nm1d2] <= 480.0);
    if (p && b_p) {
      trueCount++;
    }

    SD->u2.f4.bv0[nm1d2] = p;
    SD->u2.f4.bv1[nm1d2] = b_p;
  }

  emxInit_int32_T(sp, &r11, 1, &y_emlrtRTEI, true);
  i11 = r11->size[0];
  r11->size[0] = trueCount;
  emxEnsureCapacity_int32_T(sp, r11, i11, &y_emlrtRTEI);
  trueCount = 0;
  for (nm1d2 = 0; nm1d2 < 1228800; nm1d2++) {
    if (SD->u2.f4.bv0[nm1d2] && SD->u2.f4.bv1[nm1d2]) {
      r11->data[trueCount] = nm1d2 + 1;
      trueCount++;
    }
  }

  emxInit_real_T(sp, &allPts, 2, &y_emlrtRTEI, true);
  st.site = &wg_emlrtRSI;
  trueCount = r11->size[0];
  i11 = allPts->size[0] * allPts->size[1];
  allPts->size[0] = r11->size[0];
  allPts->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, allPts, i11, &y_emlrtRTEI);
  for (i11 = 0; i11 < 2; i11++) {
    loop_ub = r11->size[0];
    for (n = 0; n < loop_ub; n++) {
      allPts->data[n + allPts->size[0] * i11] = SD->u2.f4.allPts[(r11->data[n] +
        1228800 * i11) - 1];
    }
  }

  emxInit_real_T1(&st, &varargin_1, 1, &y_emlrtRTEI, true);
  i11 = varargin_1->size[0];
  varargin_1->size[0] = trueCount;
  emxEnsureCapacity_real_T(&st, varargin_1, i11, &y_emlrtRTEI);
  for (i11 = 0; i11 < trueCount; i11++) {
    varargin_1->data[i11] = allPts->data[i11 + allPts->size[0]];
  }

  trueCount = r11->size[0];
  i11 = allPts->size[0] * allPts->size[1];
  allPts->size[0] = r11->size[0];
  allPts->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, allPts, i11, &y_emlrtRTEI);
  for (i11 = 0; i11 < 2; i11++) {
    loop_ub = r11->size[0];
    for (n = 0; n < loop_ub; n++) {
      allPts->data[n + allPts->size[0] * i11] = SD->u2.f4.allPts[(r11->data[n] +
        1228800 * i11) - 1];
    }
  }

  emxInit_real_T1(&st, &varargin_2, 1, &y_emlrtRTEI, true);
  i11 = varargin_2->size[0];
  varargin_2->size[0] = trueCount;
  emxEnsureCapacity_real_T(&st, varargin_2, i11, &y_emlrtRTEI);
  for (i11 = 0; i11 < trueCount; i11++) {
    varargin_2->data[i11] = allPts->data[i11];
  }

  emxFree_real_T(&st, &allPts);
  b_st.site = &lh_emlrtRSI;
  if (!allinrange(varargin_1, 480)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
      "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange", 0);
  }

  trueCount = r11->size[0];
  b_varargin_1[0] = trueCount;
  b_varargin_1[1] = 1.0;
  trueCount = r11->size[0];
  b_varargin_2[0] = trueCount;
  b_varargin_2[1] = 1.0;
  p = false;
  b_p = true;
  trueCount = 0;
  exitg1 = false;
  while ((!exitg1) && (trueCount < 2)) {
    if (!(b_varargin_1[trueCount] == b_varargin_2[trueCount])) {
      b_p = false;
      exitg1 = true;
    } else {
      trueCount++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &me_emlrtRTEI,
      "MATLAB:sub2ind:SubscriptVectorSize", "MATLAB:sub2ind:SubscriptVectorSize",
      0);
  }

  if (!allinrange(varargin_2, 640)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
      "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange", 0);
  }

  i11 = r11->size[0];
  r11->size[0] = varargin_1->size[0];
  emxEnsureCapacity_int32_T(sp, r11, i11, &y_emlrtRTEI);
  loop_ub = varargin_1->size[0];
  for (i11 = 0; i11 < loop_ub; i11++) {
    n = (int32_T)varargin_1->data[i11] + 480 * ((int32_T)varargin_2->data[i11] -
      1);
    if (!((n >= 1) && (n <= 307200))) {
      emlrtDynamicBoundsCheckR2012b(n, 1, 307200, &p_emlrtBCI, sp);
    }

    r11->data[i11] = n;
  }

  loop_ub = r11->size[0];
  for (i11 = 0; i11 < loop_ub; i11++) {
    SD->u2.f4.mask[r11->data[i11] - 1] = 1U;
  }

  emxFree_int32_T(sp, &r11);
  numUnmapped = 307200.0 - sum(SD->u2.f4.mask);
  if (numUnmapped > 0.0) {
    for (i11 = 0; i11 < 2; i11++) {
      p1[i11] = 1.0;
      p2[i11] = 640.0 + -160.0 * (real_T)i11;
    }

    numTrials = 0;
    emxInit_real_T(sp, &newPts, 2, &cb_emlrtRTEI, true);
    emxInit_real_T(sp, &ptsOut, 2, &db_emlrtRTEI, true);
    emxInit_boolean_T(sp, &r12, 1, &y_emlrtRTEI, true);
    emxInit_boolean_T(sp, &r13, 1, &y_emlrtRTEI, true);
    emxInit_int32_T(sp, &r14, 1, &y_emlrtRTEI, true);
    emxInit_int32_T(sp, &r15, 1, &y_emlrtRTEI, true);
    emxInit_real_T(sp, &y, 2, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &c_varargin_1, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &c_varargin_2, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &d_varargin_1, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &d_varargin_2, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &e_varargin_1, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &e_varargin_2, 1, &y_emlrtRTEI, true);
    emxInit_real_T(sp, &r16, 2, &y_emlrtRTEI, true);
    emxInit_real_T(sp, &f_varargin_1, 2, &y_emlrtRTEI, true);
    while ((numTrials < 5) && (numUnmapped > 0.0)) {
      for (i11 = 0; i11 < 2; i11++) {
        p1[i11]--;
        p2[i11]++;
      }

      w = (p2[0] - p1[0]) + 1.0;
      h = (p2[1] - p1[1]) + 1.0;
      lastNumUnmapped = numUnmapped;
      st.site = &xg_emlrtRSI;
      numUnmapped = (p1[0] + w) - 1.0;
      b_st.site = &nh_emlrtRSI;
      if (muDoubleScalarIsNaN(numUnmapped)) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (numUnmapped < p1[0]) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 0;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
      } else if ((muDoubleScalarIsInf(p1[0]) || muDoubleScalarIsInf(numUnmapped))
                 && (p1[0] == numUnmapped)) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (p1[0] == p1[0]) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = (int32_T)(numUnmapped - p1[0]) + 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        loop_ub = (int32_T)(numUnmapped - p1[0]);
        for (i11 = 0; i11 <= loop_ub; i11++) {
          y->data[y->size[0] * i11] = p1[0] + (real_T)i11;
        }
      } else {
        c_st.site = &oh_emlrtRSI;
        ndbl = muDoubleScalarFloor((numUnmapped - p1[0]) + 0.5);
        apnd = p1[0] + ndbl;
        cdiff = apnd - numUnmapped;
        absa = muDoubleScalarAbs(p1[0]);
        absb = muDoubleScalarAbs(numUnmapped);
        if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 *
            muDoubleScalarMax(absa, absb)) {
          ndbl++;
          apnd = numUnmapped;
        } else if (cdiff > 0.0) {
          apnd = p1[0] + (ndbl - 1.0);
        } else {
          ndbl++;
        }

        if (ndbl >= 0.0) {
          n = (int32_T)ndbl;
        } else {
          n = 0;
        }

        d_st.site = &ph_emlrtRSI;
        if (ndbl > 2.147483647E+9) {
          emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
            "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
        }

        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = n;
        emxEnsureCapacity_real_T1(&c_st, y, i11, &ab_emlrtRTEI);
        if (n > 0) {
          y->data[0] = p1[0];
          if (n > 1) {
            y->data[n - 1] = apnd;
            nm1d2 = (n - 1) / 2;
            for (trueCount = 1; trueCount < nm1d2; trueCount++) {
              y->data[trueCount] = p1[0] + (real_T)trueCount;
              y->data[(n - trueCount) - 1] = apnd - (real_T)trueCount;
            }

            if (nm1d2 << 1 == n - 1) {
              y->data[nm1d2] = (p1[0] + apnd) / 2.0;
            } else {
              y->data[nm1d2] = p1[0] + (real_T)nm1d2;
              y->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
            }
          }
        }
      }

      i11 = varargin_1->size[0];
      varargin_1->size[0] = y->size[1];
      emxEnsureCapacity_real_T(sp, varargin_1, i11, &y_emlrtRTEI);
      loop_ub = y->size[1];
      for (i11 = 0; i11 < loop_ub; i11++) {
        varargin_1->data[i11] = y->data[y->size[0] * i11];
      }

      if (w != (int32_T)w) {
        emlrtIntegerCheckR2012b(w, &emlrtDCI, sp);
      }

      i11 = varargin_2->size[0];
      varargin_2->size[0] = (int32_T)w;
      emxEnsureCapacity_real_T(sp, varargin_2, i11, &y_emlrtRTEI);
      loop_ub = (int32_T)w;
      for (i11 = 0; i11 < loop_ub; i11++) {
        varargin_2->data[i11] = p1[1];
      }

      st.site = &yg_emlrtRSI;
      numUnmapped = (p1[0] + w) - 1.0;
      b_st.site = &nh_emlrtRSI;
      if (muDoubleScalarIsNaN(numUnmapped)) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (numUnmapped < p1[0]) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 0;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
      } else if ((muDoubleScalarIsInf(p1[0]) || muDoubleScalarIsInf(numUnmapped))
                 && (p1[0] == numUnmapped)) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (p1[0] == p1[0]) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = (int32_T)(numUnmapped - p1[0]) + 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        loop_ub = (int32_T)(numUnmapped - p1[0]);
        for (i11 = 0; i11 <= loop_ub; i11++) {
          y->data[y->size[0] * i11] = p1[0] + (real_T)i11;
        }
      } else {
        c_st.site = &oh_emlrtRSI;
        ndbl = muDoubleScalarFloor((numUnmapped - p1[0]) + 0.5);
        apnd = p1[0] + ndbl;
        cdiff = apnd - numUnmapped;
        absa = muDoubleScalarAbs(p1[0]);
        absb = muDoubleScalarAbs(numUnmapped);
        if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 *
            muDoubleScalarMax(absa, absb)) {
          ndbl++;
          apnd = numUnmapped;
        } else if (cdiff > 0.0) {
          apnd = p1[0] + (ndbl - 1.0);
        } else {
          ndbl++;
        }

        if (ndbl >= 0.0) {
          n = (int32_T)ndbl;
        } else {
          n = 0;
        }

        d_st.site = &ph_emlrtRSI;
        if (ndbl > 2.147483647E+9) {
          emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
            "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
        }

        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = n;
        emxEnsureCapacity_real_T1(&c_st, y, i11, &ab_emlrtRTEI);
        if (n > 0) {
          y->data[0] = p1[0];
          if (n > 1) {
            y->data[n - 1] = apnd;
            nm1d2 = (n - 1) / 2;
            for (trueCount = 1; trueCount < nm1d2; trueCount++) {
              y->data[trueCount] = p1[0] + (real_T)trueCount;
              y->data[(n - trueCount) - 1] = apnd - (real_T)trueCount;
            }

            if (nm1d2 << 1 == n - 1) {
              y->data[nm1d2] = (p1[0] + apnd) / 2.0;
            } else {
              y->data[nm1d2] = p1[0] + (real_T)nm1d2;
              y->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
            }
          }
        }
      }

      i11 = c_varargin_1->size[0];
      c_varargin_1->size[0] = y->size[1];
      emxEnsureCapacity_real_T(sp, c_varargin_1, i11, &y_emlrtRTEI);
      loop_ub = y->size[1];
      for (i11 = 0; i11 < loop_ub; i11++) {
        c_varargin_1->data[i11] = y->data[y->size[0] * i11];
      }

      if (w != (int32_T)w) {
        emlrtIntegerCheckR2012b(w, &b_emlrtDCI, sp);
      }

      i11 = c_varargin_2->size[0];
      c_varargin_2->size[0] = (int32_T)w;
      emxEnsureCapacity_real_T(sp, c_varargin_2, i11, &y_emlrtRTEI);
      loop_ub = (int32_T)w;
      for (i11 = 0; i11 < loop_ub; i11++) {
        c_varargin_2->data[i11] = p2[1];
      }

      if (h != (int32_T)h) {
        emlrtIntegerCheckR2012b(h, &c_emlrtDCI, sp);
      }

      i11 = d_varargin_1->size[0];
      d_varargin_1->size[0] = (int32_T)h;
      emxEnsureCapacity_real_T(sp, d_varargin_1, i11, &y_emlrtRTEI);
      loop_ub = (int32_T)h;
      for (i11 = 0; i11 < loop_ub; i11++) {
        d_varargin_1->data[i11] = p1[0];
      }

      st.site = &ah_emlrtRSI;
      numUnmapped = (p1[1] + h) - 1.0;
      b_st.site = &nh_emlrtRSI;
      if (muDoubleScalarIsNaN(numUnmapped)) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (numUnmapped < p1[1]) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 0;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
      } else if ((muDoubleScalarIsInf(p1[1]) || muDoubleScalarIsInf(numUnmapped))
                 && (p1[1] == numUnmapped)) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (p1[1] == p1[1]) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = (int32_T)(numUnmapped - p1[1]) + 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        loop_ub = (int32_T)(numUnmapped - p1[1]);
        for (i11 = 0; i11 <= loop_ub; i11++) {
          y->data[y->size[0] * i11] = p1[1] + (real_T)i11;
        }
      } else {
        c_st.site = &oh_emlrtRSI;
        ndbl = muDoubleScalarFloor((numUnmapped - p1[1]) + 0.5);
        apnd = p1[1] + ndbl;
        cdiff = apnd - numUnmapped;
        absa = muDoubleScalarAbs(p1[1]);
        absb = muDoubleScalarAbs(numUnmapped);
        if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 *
            muDoubleScalarMax(absa, absb)) {
          ndbl++;
          apnd = numUnmapped;
        } else if (cdiff > 0.0) {
          apnd = p1[1] + (ndbl - 1.0);
        } else {
          ndbl++;
        }

        if (ndbl >= 0.0) {
          n = (int32_T)ndbl;
        } else {
          n = 0;
        }

        d_st.site = &ph_emlrtRSI;
        if (ndbl > 2.147483647E+9) {
          emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
            "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
        }

        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = n;
        emxEnsureCapacity_real_T1(&c_st, y, i11, &ab_emlrtRTEI);
        if (n > 0) {
          y->data[0] = p1[1];
          if (n > 1) {
            y->data[n - 1] = apnd;
            nm1d2 = (n - 1) / 2;
            for (trueCount = 1; trueCount < nm1d2; trueCount++) {
              y->data[trueCount] = p1[1] + (real_T)trueCount;
              y->data[(n - trueCount) - 1] = apnd - (real_T)trueCount;
            }

            if (nm1d2 << 1 == n - 1) {
              y->data[nm1d2] = (p1[1] + apnd) / 2.0;
            } else {
              y->data[nm1d2] = p1[1] + (real_T)nm1d2;
              y->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
            }
          }
        }
      }

      i11 = d_varargin_2->size[0];
      d_varargin_2->size[0] = y->size[1];
      emxEnsureCapacity_real_T(sp, d_varargin_2, i11, &y_emlrtRTEI);
      loop_ub = y->size[1];
      for (i11 = 0; i11 < loop_ub; i11++) {
        d_varargin_2->data[i11] = y->data[y->size[0] * i11];
      }

      if (h != (int32_T)h) {
        emlrtIntegerCheckR2012b(h, &d_emlrtDCI, sp);
      }

      i11 = e_varargin_1->size[0];
      e_varargin_1->size[0] = (int32_T)h;
      emxEnsureCapacity_real_T(sp, e_varargin_1, i11, &y_emlrtRTEI);
      loop_ub = (int32_T)h;
      for (i11 = 0; i11 < loop_ub; i11++) {
        e_varargin_1->data[i11] = p2[0];
      }

      st.site = &bh_emlrtRSI;
      numUnmapped = (p1[1] + h) - 1.0;
      b_st.site = &nh_emlrtRSI;
      if (muDoubleScalarIsNaN(numUnmapped)) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (numUnmapped < p1[1]) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 0;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
      } else if ((muDoubleScalarIsInf(p1[1]) || muDoubleScalarIsInf(numUnmapped))
                 && (p1[1] == numUnmapped)) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (p1[1] == p1[1]) {
        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = (int32_T)(numUnmapped - p1[1]) + 1;
        emxEnsureCapacity_real_T1(&b_st, y, i11, &y_emlrtRTEI);
        loop_ub = (int32_T)(numUnmapped - p1[1]);
        for (i11 = 0; i11 <= loop_ub; i11++) {
          y->data[y->size[0] * i11] = p1[1] + (real_T)i11;
        }
      } else {
        c_st.site = &oh_emlrtRSI;
        ndbl = muDoubleScalarFloor((numUnmapped - p1[1]) + 0.5);
        apnd = p1[1] + ndbl;
        cdiff = apnd - numUnmapped;
        absa = muDoubleScalarAbs(p1[1]);
        absb = muDoubleScalarAbs(numUnmapped);
        if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 *
            muDoubleScalarMax(absa, absb)) {
          ndbl++;
          apnd = numUnmapped;
        } else if (cdiff > 0.0) {
          apnd = p1[1] + (ndbl - 1.0);
        } else {
          ndbl++;
        }

        if (ndbl >= 0.0) {
          n = (int32_T)ndbl;
        } else {
          n = 0;
        }

        d_st.site = &ph_emlrtRSI;
        if (ndbl > 2.147483647E+9) {
          emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
            "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
        }

        i11 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = n;
        emxEnsureCapacity_real_T1(&c_st, y, i11, &ab_emlrtRTEI);
        if (n > 0) {
          y->data[0] = p1[1];
          if (n > 1) {
            y->data[n - 1] = apnd;
            nm1d2 = (n - 1) / 2;
            for (trueCount = 1; trueCount < nm1d2; trueCount++) {
              y->data[trueCount] = p1[1] + (real_T)trueCount;
              y->data[(n - trueCount) - 1] = apnd - (real_T)trueCount;
            }

            if (nm1d2 << 1 == n - 1) {
              y->data[nm1d2] = (p1[1] + apnd) / 2.0;
            } else {
              y->data[nm1d2] = p1[1] + (real_T)nm1d2;
              y->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
            }
          }
        }
      }

      i11 = e_varargin_2->size[0];
      e_varargin_2->size[0] = y->size[1];
      emxEnsureCapacity_real_T(sp, e_varargin_2, i11, &y_emlrtRTEI);
      loop_ub = y->size[1];
      for (i11 = 0; i11 < loop_ub; i11++) {
        e_varargin_2->data[i11] = y->data[y->size[0] * i11];
      }

      st.site = &xg_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (varargin_2->size[0] != varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      st.site = &yg_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (c_varargin_2->size[0] != c_varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      st.site = &ah_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (d_varargin_2->size[0] != d_varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      st.site = &bh_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (e_varargin_2->size[0] != e_varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      for (i11 = 0; i11 < 3; i11++) {
        for (n = 0; n < 3; n++) {
          intrinsicMatrix[n + 3 * i11] = this->IntrinsicMatrixInternal[i11 + 3 *
            n];
        }
      }

      i11 = f_varargin_1->size[0] * f_varargin_1->size[1];
      f_varargin_1->size[0] = ((varargin_1->size[0] + c_varargin_1->size[0]) +
        d_varargin_1->size[0]) + e_varargin_1->size[0];
      f_varargin_1->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, f_varargin_1, i11, &y_emlrtRTEI);
      loop_ub = varargin_1->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        f_varargin_1->data[i11] = varargin_1->data[i11];
      }

      loop_ub = varargin_2->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        f_varargin_1->data[i11 + f_varargin_1->size[0]] = varargin_2->data[i11];
      }

      loop_ub = c_varargin_1->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        f_varargin_1->data[i11 + varargin_1->size[0]] = c_varargin_1->data[i11];
      }

      loop_ub = c_varargin_2->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        f_varargin_1->data[(i11 + varargin_1->size[0]) + f_varargin_1->size[0]] =
          c_varargin_2->data[i11];
      }

      loop_ub = d_varargin_1->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        f_varargin_1->data[(i11 + varargin_1->size[0]) + c_varargin_1->size[0]] =
          d_varargin_1->data[i11];
      }

      loop_ub = d_varargin_2->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        f_varargin_1->data[((i11 + varargin_1->size[0]) + c_varargin_1->size[0])
          + f_varargin_1->size[0]] = d_varargin_2->data[i11];
      }

      loop_ub = e_varargin_1->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        f_varargin_1->data[((i11 + varargin_1->size[0]) + c_varargin_1->size[0])
          + d_varargin_1->size[0]] = e_varargin_1->data[i11];
      }

      loop_ub = e_varargin_2->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        f_varargin_1->data[(((i11 + varargin_1->size[0]) + c_varargin_1->size[0])
                            + d_varargin_1->size[0]) + f_varargin_1->size[0]] =
          e_varargin_2->data[i11];
      }

      st.site = &ch_emlrtRSI;
      b_distortPoints(&st, f_varargin_1, intrinsicMatrix, this->RadialDistortion,
                      this->TangentialDistortion, ptsOut);
      loop_ub = ptsOut->size[0];
      i11 = varargin_1->size[0];
      varargin_1->size[0] = loop_ub;
      emxEnsureCapacity_real_T(sp, varargin_1, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        varargin_1->data[i11] = ptsOut->data[i11];
      }

      st.site = &eh_emlrtRSI;
      e_floor(&st, varargin_1);
      loop_ub = ptsOut->size[0];
      i11 = varargin_2->size[0];
      varargin_2->size[0] = loop_ub;
      emxEnsureCapacity_real_T(sp, varargin_2, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        varargin_2->data[i11] = ptsOut->data[i11 + ptsOut->size[0]];
      }

      st.site = &eh_emlrtRSI;
      d_ceil(&st, varargin_2);
      loop_ub = ptsOut->size[0];
      i11 = c_varargin_1->size[0];
      c_varargin_1->size[0] = loop_ub;
      emxEnsureCapacity_real_T(sp, c_varargin_1, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        c_varargin_1->data[i11] = ptsOut->data[i11];
      }

      st.site = &fh_emlrtRSI;
      d_ceil(&st, c_varargin_1);
      loop_ub = ptsOut->size[0];
      i11 = c_varargin_2->size[0];
      c_varargin_2->size[0] = loop_ub;
      emxEnsureCapacity_real_T(sp, c_varargin_2, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        c_varargin_2->data[i11] = ptsOut->data[i11 + ptsOut->size[0]];
      }

      st.site = &fh_emlrtRSI;
      e_floor(&st, c_varargin_2);
      st.site = &eh_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (varargin_2->size[0] != varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      st.site = &fh_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (c_varargin_2->size[0] != c_varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      i11 = r16->size[0] * r16->size[1];
      r16->size[0] = ptsOut->size[0];
      r16->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, r16, i11, &y_emlrtRTEI);
      loop_ub = ptsOut->size[0] * ptsOut->size[1];
      for (i11 = 0; i11 < loop_ub; i11++) {
        r16->data[i11] = ptsOut->data[i11];
      }

      st.site = &dh_emlrtRSI;
      d_floor(&st, r16);
      st.site = &gh_emlrtRSI;
      e_ceil(&st, ptsOut);
      i11 = newPts->size[0] * newPts->size[1];
      newPts->size[0] = ((r16->size[0] + varargin_1->size[0]) +
                         c_varargin_1->size[0]) + ptsOut->size[0];
      newPts->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, newPts, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < 2; i11++) {
        loop_ub = r16->size[0];
        for (n = 0; n < loop_ub; n++) {
          newPts->data[n + newPts->size[0] * i11] = r16->data[n + r16->size[0] *
            i11];
        }
      }

      loop_ub = varargin_1->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        newPts->data[i11 + r16->size[0]] = varargin_1->data[i11];
      }

      loop_ub = varargin_2->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        newPts->data[(i11 + r16->size[0]) + newPts->size[0]] = varargin_2->
          data[i11];
      }

      loop_ub = c_varargin_1->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        newPts->data[(i11 + r16->size[0]) + varargin_1->size[0]] =
          c_varargin_1->data[i11];
      }

      loop_ub = c_varargin_2->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        newPts->data[((i11 + r16->size[0]) + varargin_1->size[0]) + newPts->
          size[0]] = c_varargin_2->data[i11];
      }

      for (i11 = 0; i11 < 2; i11++) {
        loop_ub = ptsOut->size[0];
        for (n = 0; n < loop_ub; n++) {
          newPts->data[(((n + r16->size[0]) + varargin_1->size[0]) +
                        c_varargin_1->size[0]) + newPts->size[0] * i11] =
            ptsOut->data[n + ptsOut->size[0] * i11];
        }
      }

      loop_ub = newPts->size[0];
      i11 = r12->size[0];
      r12->size[0] = loop_ub;
      emxEnsureCapacity_boolean_T(sp, r12, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        r12->data[i11] = (newPts->data[i11] >= 1.0);
      }

      loop_ub = newPts->size[0];
      i11 = r13->size[0];
      r13->size[0] = loop_ub;
      emxEnsureCapacity_boolean_T(sp, r13, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        r13->data[i11] = (newPts->data[i11 + newPts->size[0]] >= 1.0);
      }

      i11 = r12->size[0];
      n = r13->size[0];
      if (i11 != n) {
        emlrtSizeEqCheck1DR2012b(i11, n, &e_emlrtECI, sp);
      }

      i11 = r12->size[0];
      emxEnsureCapacity_boolean_T(sp, r12, i11, &y_emlrtRTEI);
      loop_ub = r12->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        r12->data[i11] = (r12->data[i11] && r13->data[i11]);
      }

      loop_ub = newPts->size[0];
      i11 = r13->size[0];
      r13->size[0] = loop_ub;
      emxEnsureCapacity_boolean_T(sp, r13, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        r13->data[i11] = (newPts->data[i11] <= 640.0);
      }

      i11 = r12->size[0];
      n = r13->size[0];
      if (i11 != n) {
        emlrtSizeEqCheck1DR2012b(i11, n, &e_emlrtECI, sp);
      }

      i11 = r12->size[0];
      emxEnsureCapacity_boolean_T(sp, r12, i11, &y_emlrtRTEI);
      loop_ub = r12->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        r12->data[i11] = (r12->data[i11] && r13->data[i11]);
      }

      loop_ub = newPts->size[0];
      i11 = r13->size[0];
      r13->size[0] = loop_ub;
      emxEnsureCapacity_boolean_T(sp, r13, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        r13->data[i11] = (newPts->data[i11 + newPts->size[0]] <= 480.0);
      }

      i11 = r12->size[0];
      n = r13->size[0];
      if (i11 != n) {
        emlrtSizeEqCheck1DR2012b(i11, n, &e_emlrtECI, sp);
      }

      n = r12->size[0] - 1;
      trueCount = 0;
      for (nm1d2 = 0; nm1d2 <= n; nm1d2++) {
        if (r12->data[nm1d2] && r13->data[nm1d2]) {
          trueCount++;
        }
      }

      i11 = r15->size[0];
      r15->size[0] = trueCount;
      emxEnsureCapacity_int32_T(sp, r15, i11, &y_emlrtRTEI);
      trueCount = 0;
      for (nm1d2 = 0; nm1d2 <= n; nm1d2++) {
        if (r12->data[nm1d2] && r13->data[nm1d2]) {
          r15->data[trueCount] = nm1d2 + 1;
          trueCount++;
        }
      }

      nm1d2 = newPts->size[0];
      i11 = f_varargin_1->size[0] * f_varargin_1->size[1];
      f_varargin_1->size[0] = r15->size[0];
      f_varargin_1->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, f_varargin_1, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < 2; i11++) {
        loop_ub = r15->size[0];
        for (n = 0; n < loop_ub; n++) {
          trueCount = r15->data[n];
          if (!((trueCount >= 1) && (trueCount <= nm1d2))) {
            emlrtDynamicBoundsCheckR2012b(trueCount, 1, nm1d2, &q_emlrtBCI, sp);
          }

          f_varargin_1->data[n + f_varargin_1->size[0] * i11] = newPts->data
            [(trueCount + newPts->size[0] * i11) - 1];
        }
      }

      i11 = newPts->size[0] * newPts->size[1];
      newPts->size[0] = f_varargin_1->size[0];
      newPts->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, newPts, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < 2; i11++) {
        loop_ub = f_varargin_1->size[0];
        for (n = 0; n < loop_ub; n++) {
          newPts->data[n + newPts->size[0] * i11] = f_varargin_1->data[n +
            f_varargin_1->size[0] * i11];
        }
      }

      st.site = &hh_emlrtRSI;
      loop_ub = newPts->size[0];
      i11 = varargin_1->size[0];
      varargin_1->size[0] = loop_ub;
      emxEnsureCapacity_real_T(&st, varargin_1, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        varargin_1->data[i11] = newPts->data[i11 + newPts->size[0]];
      }

      loop_ub = newPts->size[0];
      i11 = varargin_2->size[0];
      varargin_2->size[0] = loop_ub;
      emxEnsureCapacity_real_T(&st, varargin_2, i11, &y_emlrtRTEI);
      for (i11 = 0; i11 < loop_ub; i11++) {
        varargin_2->data[i11] = newPts->data[i11];
      }

      b_st.site = &lh_emlrtRSI;
      if (!allinrange(varargin_1, 480)) {
        emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
          "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange", 0);
      }

      i11 = newPts->size[0];
      b_varargin_1[0] = i11;
      b_varargin_1[1] = 1.0;
      i11 = newPts->size[0];
      b_varargin_2[0] = i11;
      b_varargin_2[1] = 1.0;
      p = false;
      b_p = true;
      trueCount = 0;
      exitg1 = false;
      while ((!exitg1) && (trueCount < 2)) {
        if (!((int32_T)(uint32_T)b_varargin_1[trueCount] == (int32_T)(uint32_T)
              b_varargin_2[trueCount])) {
          b_p = false;
          exitg1 = true;
        } else {
          trueCount++;
        }
      }

      if (b_p) {
        p = true;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&b_st, &me_emlrtRTEI,
          "MATLAB:sub2ind:SubscriptVectorSize",
          "MATLAB:sub2ind:SubscriptVectorSize", 0);
      }

      if (!allinrange(varargin_2, 640)) {
        emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
          "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange", 0);
      }

      i11 = r14->size[0];
      r14->size[0] = varargin_1->size[0];
      emxEnsureCapacity_int32_T(sp, r14, i11, &y_emlrtRTEI);
      loop_ub = varargin_1->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        n = (int32_T)varargin_1->data[i11] + 480 * ((int32_T)varargin_2->
          data[i11] - 1);
        if (!((n >= 1) && (n <= 307200))) {
          emlrtDynamicBoundsCheckR2012b(n, 1, 307200, &r_emlrtBCI, sp);
        }

        r14->data[i11] = n;
      }

      loop_ub = r14->size[0];
      for (i11 = 0; i11 < loop_ub; i11++) {
        SD->u2.f4.mask[r14->data[i11] - 1] = 1U;
      }

      numUnmapped = 307200.0 - sum(SD->u2.f4.mask);
      if (lastNumUnmapped == numUnmapped) {
        numTrials++;
      } else {
        numTrials = 0;
      }

      xBoundsBig[0] = p1[0];
      xBoundsBig[1] = p2[0];
      yBoundsBig[0] = p1[1];
      yBoundsBig[1] = p2[1];
    }

    emxFree_real_T(sp, &f_varargin_1);
    emxFree_real_T(sp, &r16);
    emxFree_real_T(sp, &e_varargin_2);
    emxFree_real_T(sp, &e_varargin_1);
    emxFree_real_T(sp, &d_varargin_2);
    emxFree_real_T(sp, &d_varargin_1);
    emxFree_real_T(sp, &c_varargin_2);
    emxFree_real_T(sp, &c_varargin_1);
    emxFree_real_T(sp, &y);
    emxFree_int32_T(sp, &r15);
    emxFree_int32_T(sp, &r14);
    emxFree_boolean_T(sp, &r13);
    emxFree_boolean_T(sp, &r12);
    emxFree_real_T(sp, &ptsOut);
    emxFree_real_T(sp, &newPts);
  }

  emxFree_real_T(sp, &varargin_2);
  emxFree_real_T(sp, &varargin_1);
  st.site = &ih_emlrtRSI;
  c_ImageTransformer_ImageTransfo(&st, &myMap);
  for (i11 = 0; i11 < 3; i11++) {
    for (n = 0; n < 3; n++) {
      intrinsicMatrix[n + 3 * i11] = this->IntrinsicMatrixInternal[i11 + 3 * n];
    }
  }

  st.site = &jh_emlrtRSI;
  for (i11 = 0; i11 < 2; i11++) {
    b_varargin_1[i11] = this->RadialDistortion[i11];
    b_varargin_2[i11] = this->TangentialDistortion[i11];
  }

  i11 = myMap.SizeOfImage->size[0] * myMap.SizeOfImage->size[1];
  myMap.SizeOfImage->size[0] = 1;
  myMap.SizeOfImage->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, myMap.SizeOfImage, i11, &y_emlrtRTEI);
  for (i11 = 0; i11 < 2; i11++) {
    myMap.SizeOfImage->data[i11] = 480.0 + 160.0 * (real_T)i11;
  }

  i11 = myMap.ClassOfImage->size[0] * myMap.ClassOfImage->size[1];
  myMap.ClassOfImage->size[0] = 1;
  myMap.ClassOfImage->size[1] = 5;
  emxEnsureCapacity_char_T(&st, myMap.ClassOfImage, i11, &y_emlrtRTEI);
  for (i11 = 0; i11 < 5; i11++) {
    myMap.ClassOfImage->data[i11] = cv10[i11];
  }

  i11 = myMap.OutputView->size[0] * myMap.OutputView->size[1];
  myMap.OutputView->size[0] = 1;
  myMap.OutputView->size[1] = 5;
  emxEnsureCapacity_char_T(&st, myMap.OutputView, i11, &y_emlrtRTEI);
  for (i11 = 0; i11 < 5; i11++) {
    myMap.OutputView->data[i11] = outputView[i11];
  }

  for (i11 = 0; i11 < 2; i11++) {
    myMap.XBounds[i11] = xBoundsBig[i11];
  }

  for (i11 = 0; i11 < 2; i11++) {
    myMap.YBounds[i11] = yBoundsBig[i11];
  }

  b_st.site = &ji_emlrtRSI;
  ImageTransformer_computeMap(&b_st, &myMap, intrinsicMatrix, b_varargin_1,
    b_varargin_2);
  st.site = &kh_emlrtRSI;
  ImageTransformer_transformImage(SD, &st, &myMap, undistortedMask);
  c_emxFreeStruct_vision_internal(sp, &myMap);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

static void c_CameraParametersImpl_distortP(const emlrtStack *sp, const
  c_vision_internal_calibration_C *this, const emxArray_real_T *points,
  emxArray_real_T *distortedPoints)
{
  int32_T i30;
  real_T dv5[9];
  int32_T i31;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  for (i30 = 0; i30 < 3; i30++) {
    for (i31 = 0; i31 < 3; i31++) {
      dv5[i31 + 3 * i30] = this->IntrinsicMatrixInternal[i30 + 3 * i31];
    }
  }

  st.site = &fk_emlrtRSI;
  b_distortPoints(&st, points, dv5, this->RadialDistortion,
                  this->TangentialDistortion, distortedPoints);
}

static void d_CameraParametersImpl_createUn(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_C *this,
  emxArray_uint8_T *undistortedMask, real_T xBoundsBig[2], real_T yBoundsBig[2])
{
  c_vision_internal_calibration_I myMap;
  int32_T i33;
  real_T dv6[640];
  real_T dv7[480];
  int32_T n;
  real_T intrinsicMatrix[9];
  int32_T trueCount;
  int32_T nm1d2;
  emxArray_int32_T *r22;
  boolean_T p;
  boolean_T b_p;
  emxArray_real_T *allPts;
  emxArray_real_T *varargin_1;
  int32_T loop_ub;
  emxArray_real_T *varargin_2;
  real_T b_varargin_1[2];
  real_T b_varargin_2[2];
  boolean_T exitg1;
  real_T numUnmapped;
  int32_T numTrials;
  real_T p1[2];
  emxArray_real_T *newPts;
  real_T p2[2];
  emxArray_real_T *ptsOut;
  emxArray_boolean_T *r23;
  emxArray_boolean_T *r24;
  emxArray_int32_T *r25;
  emxArray_int32_T *r26;
  emxArray_real_T *y;
  emxArray_real_T *c_varargin_1;
  emxArray_real_T *c_varargin_2;
  emxArray_real_T *d_varargin_1;
  emxArray_real_T *d_varargin_2;
  emxArray_real_T *e_varargin_1;
  emxArray_real_T *e_varargin_2;
  emxArray_real_T *r27;
  emxArray_real_T *f_varargin_1;
  static const char_T cv12[5] = { 'u', 'i', 'n', 't', '8' };

  real_T w;
  real_T h;
  real_T lastNumUnmapped;
  static const char_T outputView[4] = { 'f', 'u', 'l', 'l' };

  real_T ndbl;
  real_T apnd;
  real_T cdiff;
  real_T absa;
  real_T absb;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  d_emxInitStruct_vision_internal(sp, &myMap, &bb_emlrtRTEI, true);
  for (i33 = 0; i33 < 2; i33++) {
    xBoundsBig[i33] = 1.0 + 639.0 * (real_T)i33;
    yBoundsBig[i33] = 1.0 + 479.0 * (real_T)i33;
  }

  for (i33 = 0; i33 < 640; i33++) {
    dv6[i33] = 1.0 + (real_T)i33;
  }

  for (i33 = 0; i33 < 480; i33++) {
    dv7[i33] = 1.0 + (real_T)i33;
  }

  meshgrid(dv6, dv7, SD->u2.f3.b_X, SD->u2.f3.Y);
  for (i33 = 0; i33 < 3; i33++) {
    for (n = 0; n < 3; n++) {
      intrinsicMatrix[n + 3 * i33] = this->IntrinsicMatrixInternal[i33 + 3 * n];
    }
  }

  for (i33 = 0; i33 < 307200; i33++) {
    SD->u2.f3.X[i33] = SD->u2.f3.b_X[i33];
    SD->u2.f3.X[307200 + i33] = SD->u2.f3.Y[i33];
    SD->u2.f3.mask[i33] = 0U;
  }

  distortPoints(SD, SD->u2.f3.X, intrinsicMatrix, this->RadialDistortion,
                this->TangentialDistortion, SD->u2.f3.ptsOut);
  memcpy(&SD->u2.f3.X[0], &SD->u2.f3.ptsOut[0], 614400U * sizeof(real_T));
  b_floor(SD->u2.f3.X);
  memcpy(&SD->u2.f3.b_ptsOut[0], &SD->u2.f3.ptsOut[0], 307200U * sizeof(real_T));
  for (i33 = 0; i33 < 640; i33++) {
    memcpy(&SD->u2.f3.b_X[i33 * 480], &SD->u2.f3.b_ptsOut[i33 * 480], 480U *
           sizeof(real_T));
  }

  c_floor(SD->u2.f3.b_X);
  memcpy(&SD->u2.f3.b_ptsOut[0], &SD->u2.f3.ptsOut[307200], 307200U * sizeof
         (real_T));
  for (i33 = 0; i33 < 640; i33++) {
    memcpy(&SD->u2.f3.Y[i33 * 480], &SD->u2.f3.b_ptsOut[i33 * 480], 480U *
           sizeof(real_T));
  }

  b_ceil(SD->u2.f3.Y);
  memcpy(&SD->u2.f3.b_ptsOut[0], &SD->u2.f3.ptsOut[0], 307200U * sizeof(real_T));
  b_ceil(SD->u2.f3.b_ptsOut);
  memcpy(&SD->u2.f3.dv8[0], &SD->u2.f3.ptsOut[307200], 307200U * sizeof(real_T));
  c_floor(SD->u2.f3.dv8);
  c_ceil(SD->u2.f3.ptsOut);
  for (i33 = 0; i33 < 2; i33++) {
    memcpy(&SD->u2.f3.allPts[i33 * 1228800], &SD->u2.f3.X[i33 * 307200], 307200U
           * sizeof(real_T));
  }

  for (i33 = 0; i33 < 307200; i33++) {
    SD->u2.f3.allPts[i33 + 307200] = SD->u2.f3.b_X[i33];
    SD->u2.f3.allPts[i33 + 1536000] = SD->u2.f3.Y[i33];
    SD->u2.f3.allPts[i33 + 614400] = SD->u2.f3.b_ptsOut[i33];
    SD->u2.f3.allPts[i33 + 1843200] = SD->u2.f3.dv8[i33];
  }

  for (i33 = 0; i33 < 2; i33++) {
    memcpy(&SD->u2.f3.allPts[i33 * 1228800 + 921600], &SD->u2.f3.ptsOut[i33 *
           307200], 307200U * sizeof(real_T));
  }

  trueCount = 0;
  for (nm1d2 = 0; nm1d2 < 1228800; nm1d2++) {
    p = ((SD->u2.f3.allPts[nm1d2] >= 1.0) && (SD->u2.f3.allPts[1228800 + nm1d2] >=
          1.0) && (SD->u2.f3.allPts[nm1d2] <= 640.0));
    b_p = (SD->u2.f3.allPts[1228800 + nm1d2] <= 480.0);
    if (p && b_p) {
      trueCount++;
    }

    SD->u2.f3.bv2[nm1d2] = p;
    SD->u2.f3.bv3[nm1d2] = b_p;
  }

  emxInit_int32_T(sp, &r22, 1, &y_emlrtRTEI, true);
  i33 = r22->size[0];
  r22->size[0] = trueCount;
  emxEnsureCapacity_int32_T(sp, r22, i33, &y_emlrtRTEI);
  trueCount = 0;
  for (nm1d2 = 0; nm1d2 < 1228800; nm1d2++) {
    if (SD->u2.f3.bv2[nm1d2] && SD->u2.f3.bv3[nm1d2]) {
      r22->data[trueCount] = nm1d2 + 1;
      trueCount++;
    }
  }

  emxInit_real_T(sp, &allPts, 2, &y_emlrtRTEI, true);
  st.site = &wg_emlrtRSI;
  trueCount = r22->size[0];
  i33 = allPts->size[0] * allPts->size[1];
  allPts->size[0] = r22->size[0];
  allPts->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, allPts, i33, &y_emlrtRTEI);
  for (i33 = 0; i33 < 2; i33++) {
    loop_ub = r22->size[0];
    for (n = 0; n < loop_ub; n++) {
      allPts->data[n + allPts->size[0] * i33] = SD->u2.f3.allPts[(r22->data[n] +
        1228800 * i33) - 1];
    }
  }

  emxInit_real_T1(&st, &varargin_1, 1, &y_emlrtRTEI, true);
  i33 = varargin_1->size[0];
  varargin_1->size[0] = trueCount;
  emxEnsureCapacity_real_T(&st, varargin_1, i33, &y_emlrtRTEI);
  for (i33 = 0; i33 < trueCount; i33++) {
    varargin_1->data[i33] = allPts->data[i33 + allPts->size[0]];
  }

  trueCount = r22->size[0];
  i33 = allPts->size[0] * allPts->size[1];
  allPts->size[0] = r22->size[0];
  allPts->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, allPts, i33, &y_emlrtRTEI);
  for (i33 = 0; i33 < 2; i33++) {
    loop_ub = r22->size[0];
    for (n = 0; n < loop_ub; n++) {
      allPts->data[n + allPts->size[0] * i33] = SD->u2.f3.allPts[(r22->data[n] +
        1228800 * i33) - 1];
    }
  }

  emxInit_real_T1(&st, &varargin_2, 1, &y_emlrtRTEI, true);
  i33 = varargin_2->size[0];
  varargin_2->size[0] = trueCount;
  emxEnsureCapacity_real_T(&st, varargin_2, i33, &y_emlrtRTEI);
  for (i33 = 0; i33 < trueCount; i33++) {
    varargin_2->data[i33] = allPts->data[i33];
  }

  emxFree_real_T(&st, &allPts);
  b_st.site = &lh_emlrtRSI;
  if (!allinrange(varargin_1, 480)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
      "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange", 0);
  }

  trueCount = r22->size[0];
  b_varargin_1[0] = trueCount;
  b_varargin_1[1] = 1.0;
  trueCount = r22->size[0];
  b_varargin_2[0] = trueCount;
  b_varargin_2[1] = 1.0;
  p = false;
  b_p = true;
  trueCount = 0;
  exitg1 = false;
  while ((!exitg1) && (trueCount < 2)) {
    if (!(b_varargin_1[trueCount] == b_varargin_2[trueCount])) {
      b_p = false;
      exitg1 = true;
    } else {
      trueCount++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &me_emlrtRTEI,
      "MATLAB:sub2ind:SubscriptVectorSize", "MATLAB:sub2ind:SubscriptVectorSize",
      0);
  }

  if (!allinrange(varargin_2, 640)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
      "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange", 0);
  }

  i33 = r22->size[0];
  r22->size[0] = varargin_1->size[0];
  emxEnsureCapacity_int32_T(sp, r22, i33, &y_emlrtRTEI);
  loop_ub = varargin_1->size[0];
  for (i33 = 0; i33 < loop_ub; i33++) {
    n = (int32_T)varargin_1->data[i33] + 480 * ((int32_T)varargin_2->data[i33] -
      1);
    if (!((n >= 1) && (n <= 307200))) {
      emlrtDynamicBoundsCheckR2012b(n, 1, 307200, &p_emlrtBCI, sp);
    }

    r22->data[i33] = n;
  }

  loop_ub = r22->size[0];
  for (i33 = 0; i33 < loop_ub; i33++) {
    SD->u2.f3.mask[r22->data[i33] - 1] = 1U;
  }

  emxFree_int32_T(sp, &r22);
  numUnmapped = 307200.0 - sum(SD->u2.f3.mask);
  if (numUnmapped > 0.0) {
    for (i33 = 0; i33 < 2; i33++) {
      p1[i33] = 1.0;
      p2[i33] = 640.0 + -160.0 * (real_T)i33;
    }

    numTrials = 0;
    emxInit_real_T(sp, &newPts, 2, &cb_emlrtRTEI, true);
    emxInit_real_T(sp, &ptsOut, 2, &db_emlrtRTEI, true);
    emxInit_boolean_T(sp, &r23, 1, &y_emlrtRTEI, true);
    emxInit_boolean_T(sp, &r24, 1, &y_emlrtRTEI, true);
    emxInit_int32_T(sp, &r25, 1, &y_emlrtRTEI, true);
    emxInit_int32_T(sp, &r26, 1, &y_emlrtRTEI, true);
    emxInit_real_T(sp, &y, 2, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &c_varargin_1, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &c_varargin_2, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &d_varargin_1, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &d_varargin_2, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &e_varargin_1, 1, &y_emlrtRTEI, true);
    emxInit_real_T1(sp, &e_varargin_2, 1, &y_emlrtRTEI, true);
    emxInit_real_T(sp, &r27, 2, &y_emlrtRTEI, true);
    emxInit_real_T(sp, &f_varargin_1, 2, &y_emlrtRTEI, true);
    while ((numTrials < 5) && (numUnmapped > 0.0)) {
      for (i33 = 0; i33 < 2; i33++) {
        p1[i33]--;
        p2[i33]++;
      }

      w = (p2[0] - p1[0]) + 1.0;
      h = (p2[1] - p1[1]) + 1.0;
      lastNumUnmapped = numUnmapped;
      st.site = &xg_emlrtRSI;
      numUnmapped = (p1[0] + w) - 1.0;
      b_st.site = &nh_emlrtRSI;
      if (muDoubleScalarIsNaN(numUnmapped)) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (numUnmapped < p1[0]) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 0;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
      } else if ((muDoubleScalarIsInf(p1[0]) || muDoubleScalarIsInf(numUnmapped))
                 && (p1[0] == numUnmapped)) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (p1[0] == p1[0]) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = (int32_T)(numUnmapped - p1[0]) + 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        loop_ub = (int32_T)(numUnmapped - p1[0]);
        for (i33 = 0; i33 <= loop_ub; i33++) {
          y->data[y->size[0] * i33] = p1[0] + (real_T)i33;
        }
      } else {
        c_st.site = &oh_emlrtRSI;
        ndbl = muDoubleScalarFloor((numUnmapped - p1[0]) + 0.5);
        apnd = p1[0] + ndbl;
        cdiff = apnd - numUnmapped;
        absa = muDoubleScalarAbs(p1[0]);
        absb = muDoubleScalarAbs(numUnmapped);
        if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 *
            muDoubleScalarMax(absa, absb)) {
          ndbl++;
          apnd = numUnmapped;
        } else if (cdiff > 0.0) {
          apnd = p1[0] + (ndbl - 1.0);
        } else {
          ndbl++;
        }

        if (ndbl >= 0.0) {
          n = (int32_T)ndbl;
        } else {
          n = 0;
        }

        d_st.site = &ph_emlrtRSI;
        if (ndbl > 2.147483647E+9) {
          emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
            "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
        }

        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = n;
        emxEnsureCapacity_real_T1(&c_st, y, i33, &ab_emlrtRTEI);
        if (n > 0) {
          y->data[0] = p1[0];
          if (n > 1) {
            y->data[n - 1] = apnd;
            nm1d2 = (n - 1) / 2;
            for (trueCount = 1; trueCount < nm1d2; trueCount++) {
              y->data[trueCount] = p1[0] + (real_T)trueCount;
              y->data[(n - trueCount) - 1] = apnd - (real_T)trueCount;
            }

            if (nm1d2 << 1 == n - 1) {
              y->data[nm1d2] = (p1[0] + apnd) / 2.0;
            } else {
              y->data[nm1d2] = p1[0] + (real_T)nm1d2;
              y->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
            }
          }
        }
      }

      i33 = varargin_1->size[0];
      varargin_1->size[0] = y->size[1];
      emxEnsureCapacity_real_T(sp, varargin_1, i33, &y_emlrtRTEI);
      loop_ub = y->size[1];
      for (i33 = 0; i33 < loop_ub; i33++) {
        varargin_1->data[i33] = y->data[y->size[0] * i33];
      }

      if (w != (int32_T)w) {
        emlrtIntegerCheckR2012b(w, &emlrtDCI, sp);
      }

      i33 = varargin_2->size[0];
      varargin_2->size[0] = (int32_T)w;
      emxEnsureCapacity_real_T(sp, varargin_2, i33, &y_emlrtRTEI);
      loop_ub = (int32_T)w;
      for (i33 = 0; i33 < loop_ub; i33++) {
        varargin_2->data[i33] = p1[1];
      }

      st.site = &yg_emlrtRSI;
      numUnmapped = (p1[0] + w) - 1.0;
      b_st.site = &nh_emlrtRSI;
      if (muDoubleScalarIsNaN(numUnmapped)) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (numUnmapped < p1[0]) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 0;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
      } else if ((muDoubleScalarIsInf(p1[0]) || muDoubleScalarIsInf(numUnmapped))
                 && (p1[0] == numUnmapped)) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (p1[0] == p1[0]) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = (int32_T)(numUnmapped - p1[0]) + 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        loop_ub = (int32_T)(numUnmapped - p1[0]);
        for (i33 = 0; i33 <= loop_ub; i33++) {
          y->data[y->size[0] * i33] = p1[0] + (real_T)i33;
        }
      } else {
        c_st.site = &oh_emlrtRSI;
        ndbl = muDoubleScalarFloor((numUnmapped - p1[0]) + 0.5);
        apnd = p1[0] + ndbl;
        cdiff = apnd - numUnmapped;
        absa = muDoubleScalarAbs(p1[0]);
        absb = muDoubleScalarAbs(numUnmapped);
        if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 *
            muDoubleScalarMax(absa, absb)) {
          ndbl++;
          apnd = numUnmapped;
        } else if (cdiff > 0.0) {
          apnd = p1[0] + (ndbl - 1.0);
        } else {
          ndbl++;
        }

        if (ndbl >= 0.0) {
          n = (int32_T)ndbl;
        } else {
          n = 0;
        }

        d_st.site = &ph_emlrtRSI;
        if (ndbl > 2.147483647E+9) {
          emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
            "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
        }

        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = n;
        emxEnsureCapacity_real_T1(&c_st, y, i33, &ab_emlrtRTEI);
        if (n > 0) {
          y->data[0] = p1[0];
          if (n > 1) {
            y->data[n - 1] = apnd;
            nm1d2 = (n - 1) / 2;
            for (trueCount = 1; trueCount < nm1d2; trueCount++) {
              y->data[trueCount] = p1[0] + (real_T)trueCount;
              y->data[(n - trueCount) - 1] = apnd - (real_T)trueCount;
            }

            if (nm1d2 << 1 == n - 1) {
              y->data[nm1d2] = (p1[0] + apnd) / 2.0;
            } else {
              y->data[nm1d2] = p1[0] + (real_T)nm1d2;
              y->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
            }
          }
        }
      }

      i33 = c_varargin_1->size[0];
      c_varargin_1->size[0] = y->size[1];
      emxEnsureCapacity_real_T(sp, c_varargin_1, i33, &y_emlrtRTEI);
      loop_ub = y->size[1];
      for (i33 = 0; i33 < loop_ub; i33++) {
        c_varargin_1->data[i33] = y->data[y->size[0] * i33];
      }

      if (w != (int32_T)w) {
        emlrtIntegerCheckR2012b(w, &b_emlrtDCI, sp);
      }

      i33 = c_varargin_2->size[0];
      c_varargin_2->size[0] = (int32_T)w;
      emxEnsureCapacity_real_T(sp, c_varargin_2, i33, &y_emlrtRTEI);
      loop_ub = (int32_T)w;
      for (i33 = 0; i33 < loop_ub; i33++) {
        c_varargin_2->data[i33] = p2[1];
      }

      if (h != (int32_T)h) {
        emlrtIntegerCheckR2012b(h, &c_emlrtDCI, sp);
      }

      i33 = d_varargin_1->size[0];
      d_varargin_1->size[0] = (int32_T)h;
      emxEnsureCapacity_real_T(sp, d_varargin_1, i33, &y_emlrtRTEI);
      loop_ub = (int32_T)h;
      for (i33 = 0; i33 < loop_ub; i33++) {
        d_varargin_1->data[i33] = p1[0];
      }

      st.site = &ah_emlrtRSI;
      numUnmapped = (p1[1] + h) - 1.0;
      b_st.site = &nh_emlrtRSI;
      if (muDoubleScalarIsNaN(numUnmapped)) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (numUnmapped < p1[1]) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 0;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
      } else if ((muDoubleScalarIsInf(p1[1]) || muDoubleScalarIsInf(numUnmapped))
                 && (p1[1] == numUnmapped)) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (p1[1] == p1[1]) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = (int32_T)(numUnmapped - p1[1]) + 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        loop_ub = (int32_T)(numUnmapped - p1[1]);
        for (i33 = 0; i33 <= loop_ub; i33++) {
          y->data[y->size[0] * i33] = p1[1] + (real_T)i33;
        }
      } else {
        c_st.site = &oh_emlrtRSI;
        ndbl = muDoubleScalarFloor((numUnmapped - p1[1]) + 0.5);
        apnd = p1[1] + ndbl;
        cdiff = apnd - numUnmapped;
        absa = muDoubleScalarAbs(p1[1]);
        absb = muDoubleScalarAbs(numUnmapped);
        if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 *
            muDoubleScalarMax(absa, absb)) {
          ndbl++;
          apnd = numUnmapped;
        } else if (cdiff > 0.0) {
          apnd = p1[1] + (ndbl - 1.0);
        } else {
          ndbl++;
        }

        if (ndbl >= 0.0) {
          n = (int32_T)ndbl;
        } else {
          n = 0;
        }

        d_st.site = &ph_emlrtRSI;
        if (ndbl > 2.147483647E+9) {
          emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
            "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
        }

        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = n;
        emxEnsureCapacity_real_T1(&c_st, y, i33, &ab_emlrtRTEI);
        if (n > 0) {
          y->data[0] = p1[1];
          if (n > 1) {
            y->data[n - 1] = apnd;
            nm1d2 = (n - 1) / 2;
            for (trueCount = 1; trueCount < nm1d2; trueCount++) {
              y->data[trueCount] = p1[1] + (real_T)trueCount;
              y->data[(n - trueCount) - 1] = apnd - (real_T)trueCount;
            }

            if (nm1d2 << 1 == n - 1) {
              y->data[nm1d2] = (p1[1] + apnd) / 2.0;
            } else {
              y->data[nm1d2] = p1[1] + (real_T)nm1d2;
              y->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
            }
          }
        }
      }

      i33 = d_varargin_2->size[0];
      d_varargin_2->size[0] = y->size[1];
      emxEnsureCapacity_real_T(sp, d_varargin_2, i33, &y_emlrtRTEI);
      loop_ub = y->size[1];
      for (i33 = 0; i33 < loop_ub; i33++) {
        d_varargin_2->data[i33] = y->data[y->size[0] * i33];
      }

      if (h != (int32_T)h) {
        emlrtIntegerCheckR2012b(h, &d_emlrtDCI, sp);
      }

      i33 = e_varargin_1->size[0];
      e_varargin_1->size[0] = (int32_T)h;
      emxEnsureCapacity_real_T(sp, e_varargin_1, i33, &y_emlrtRTEI);
      loop_ub = (int32_T)h;
      for (i33 = 0; i33 < loop_ub; i33++) {
        e_varargin_1->data[i33] = p2[0];
      }

      st.site = &bh_emlrtRSI;
      numUnmapped = (p1[1] + h) - 1.0;
      b_st.site = &nh_emlrtRSI;
      if (muDoubleScalarIsNaN(numUnmapped)) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (numUnmapped < p1[1]) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 0;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
      } else if ((muDoubleScalarIsInf(p1[1]) || muDoubleScalarIsInf(numUnmapped))
                 && (p1[1] == numUnmapped)) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        y->data[0] = rtNaN;
      } else if (p1[1] == p1[1]) {
        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = (int32_T)(numUnmapped - p1[1]) + 1;
        emxEnsureCapacity_real_T1(&b_st, y, i33, &y_emlrtRTEI);
        loop_ub = (int32_T)(numUnmapped - p1[1]);
        for (i33 = 0; i33 <= loop_ub; i33++) {
          y->data[y->size[0] * i33] = p1[1] + (real_T)i33;
        }
      } else {
        c_st.site = &oh_emlrtRSI;
        ndbl = muDoubleScalarFloor((numUnmapped - p1[1]) + 0.5);
        apnd = p1[1] + ndbl;
        cdiff = apnd - numUnmapped;
        absa = muDoubleScalarAbs(p1[1]);
        absb = muDoubleScalarAbs(numUnmapped);
        if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 *
            muDoubleScalarMax(absa, absb)) {
          ndbl++;
          apnd = numUnmapped;
        } else if (cdiff > 0.0) {
          apnd = p1[1] + (ndbl - 1.0);
        } else {
          ndbl++;
        }

        if (ndbl >= 0.0) {
          n = (int32_T)ndbl;
        } else {
          n = 0;
        }

        d_st.site = &ph_emlrtRSI;
        if (ndbl > 2.147483647E+9) {
          emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
            "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
        }

        i33 = y->size[0] * y->size[1];
        y->size[0] = 1;
        y->size[1] = n;
        emxEnsureCapacity_real_T1(&c_st, y, i33, &ab_emlrtRTEI);
        if (n > 0) {
          y->data[0] = p1[1];
          if (n > 1) {
            y->data[n - 1] = apnd;
            nm1d2 = (n - 1) / 2;
            for (trueCount = 1; trueCount < nm1d2; trueCount++) {
              y->data[trueCount] = p1[1] + (real_T)trueCount;
              y->data[(n - trueCount) - 1] = apnd - (real_T)trueCount;
            }

            if (nm1d2 << 1 == n - 1) {
              y->data[nm1d2] = (p1[1] + apnd) / 2.0;
            } else {
              y->data[nm1d2] = p1[1] + (real_T)nm1d2;
              y->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
            }
          }
        }
      }

      i33 = e_varargin_2->size[0];
      e_varargin_2->size[0] = y->size[1];
      emxEnsureCapacity_real_T(sp, e_varargin_2, i33, &y_emlrtRTEI);
      loop_ub = y->size[1];
      for (i33 = 0; i33 < loop_ub; i33++) {
        e_varargin_2->data[i33] = y->data[y->size[0] * i33];
      }

      st.site = &xg_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (varargin_2->size[0] != varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      st.site = &yg_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (c_varargin_2->size[0] != c_varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      st.site = &ah_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (d_varargin_2->size[0] != d_varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      st.site = &bh_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (e_varargin_2->size[0] != e_varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      for (i33 = 0; i33 < 3; i33++) {
        for (n = 0; n < 3; n++) {
          intrinsicMatrix[n + 3 * i33] = this->IntrinsicMatrixInternal[i33 + 3 *
            n];
        }
      }

      i33 = f_varargin_1->size[0] * f_varargin_1->size[1];
      f_varargin_1->size[0] = ((varargin_1->size[0] + c_varargin_1->size[0]) +
        d_varargin_1->size[0]) + e_varargin_1->size[0];
      f_varargin_1->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, f_varargin_1, i33, &y_emlrtRTEI);
      loop_ub = varargin_1->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        f_varargin_1->data[i33] = varargin_1->data[i33];
      }

      loop_ub = varargin_2->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        f_varargin_1->data[i33 + f_varargin_1->size[0]] = varargin_2->data[i33];
      }

      loop_ub = c_varargin_1->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        f_varargin_1->data[i33 + varargin_1->size[0]] = c_varargin_1->data[i33];
      }

      loop_ub = c_varargin_2->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        f_varargin_1->data[(i33 + varargin_1->size[0]) + f_varargin_1->size[0]] =
          c_varargin_2->data[i33];
      }

      loop_ub = d_varargin_1->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        f_varargin_1->data[(i33 + varargin_1->size[0]) + c_varargin_1->size[0]] =
          d_varargin_1->data[i33];
      }

      loop_ub = d_varargin_2->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        f_varargin_1->data[((i33 + varargin_1->size[0]) + c_varargin_1->size[0])
          + f_varargin_1->size[0]] = d_varargin_2->data[i33];
      }

      loop_ub = e_varargin_1->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        f_varargin_1->data[((i33 + varargin_1->size[0]) + c_varargin_1->size[0])
          + d_varargin_1->size[0]] = e_varargin_1->data[i33];
      }

      loop_ub = e_varargin_2->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        f_varargin_1->data[(((i33 + varargin_1->size[0]) + c_varargin_1->size[0])
                            + d_varargin_1->size[0]) + f_varargin_1->size[0]] =
          e_varargin_2->data[i33];
      }

      st.site = &ch_emlrtRSI;
      b_distortPoints(&st, f_varargin_1, intrinsicMatrix, this->RadialDistortion,
                      this->TangentialDistortion, ptsOut);
      loop_ub = ptsOut->size[0];
      i33 = varargin_1->size[0];
      varargin_1->size[0] = loop_ub;
      emxEnsureCapacity_real_T(sp, varargin_1, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        varargin_1->data[i33] = ptsOut->data[i33];
      }

      st.site = &eh_emlrtRSI;
      e_floor(&st, varargin_1);
      loop_ub = ptsOut->size[0];
      i33 = varargin_2->size[0];
      varargin_2->size[0] = loop_ub;
      emxEnsureCapacity_real_T(sp, varargin_2, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        varargin_2->data[i33] = ptsOut->data[i33 + ptsOut->size[0]];
      }

      st.site = &eh_emlrtRSI;
      d_ceil(&st, varargin_2);
      loop_ub = ptsOut->size[0];
      i33 = c_varargin_1->size[0];
      c_varargin_1->size[0] = loop_ub;
      emxEnsureCapacity_real_T(sp, c_varargin_1, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        c_varargin_1->data[i33] = ptsOut->data[i33];
      }

      st.site = &fh_emlrtRSI;
      d_ceil(&st, c_varargin_1);
      loop_ub = ptsOut->size[0];
      i33 = c_varargin_2->size[0];
      c_varargin_2->size[0] = loop_ub;
      emxEnsureCapacity_real_T(sp, c_varargin_2, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        c_varargin_2->data[i33] = ptsOut->data[i33 + ptsOut->size[0]];
      }

      st.site = &fh_emlrtRSI;
      e_floor(&st, c_varargin_2);
      st.site = &eh_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (varargin_2->size[0] != varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      st.site = &fh_emlrtRSI;
      b_st.site = &rh_emlrtRSI;
      c_st.site = &sh_emlrtRSI;
      p = true;
      if (c_varargin_2->size[0] != c_varargin_1->size[0]) {
        p = false;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch",
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      i33 = r27->size[0] * r27->size[1];
      r27->size[0] = ptsOut->size[0];
      r27->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, r27, i33, &y_emlrtRTEI);
      loop_ub = ptsOut->size[0] * ptsOut->size[1];
      for (i33 = 0; i33 < loop_ub; i33++) {
        r27->data[i33] = ptsOut->data[i33];
      }

      st.site = &dh_emlrtRSI;
      d_floor(&st, r27);
      st.site = &gh_emlrtRSI;
      e_ceil(&st, ptsOut);
      i33 = newPts->size[0] * newPts->size[1];
      newPts->size[0] = ((r27->size[0] + varargin_1->size[0]) +
                         c_varargin_1->size[0]) + ptsOut->size[0];
      newPts->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, newPts, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < 2; i33++) {
        loop_ub = r27->size[0];
        for (n = 0; n < loop_ub; n++) {
          newPts->data[n + newPts->size[0] * i33] = r27->data[n + r27->size[0] *
            i33];
        }
      }

      loop_ub = varargin_1->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        newPts->data[i33 + r27->size[0]] = varargin_1->data[i33];
      }

      loop_ub = varargin_2->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        newPts->data[(i33 + r27->size[0]) + newPts->size[0]] = varargin_2->
          data[i33];
      }

      loop_ub = c_varargin_1->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        newPts->data[(i33 + r27->size[0]) + varargin_1->size[0]] =
          c_varargin_1->data[i33];
      }

      loop_ub = c_varargin_2->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        newPts->data[((i33 + r27->size[0]) + varargin_1->size[0]) + newPts->
          size[0]] = c_varargin_2->data[i33];
      }

      for (i33 = 0; i33 < 2; i33++) {
        loop_ub = ptsOut->size[0];
        for (n = 0; n < loop_ub; n++) {
          newPts->data[(((n + r27->size[0]) + varargin_1->size[0]) +
                        c_varargin_1->size[0]) + newPts->size[0] * i33] =
            ptsOut->data[n + ptsOut->size[0] * i33];
        }
      }

      loop_ub = newPts->size[0];
      i33 = r23->size[0];
      r23->size[0] = loop_ub;
      emxEnsureCapacity_boolean_T(sp, r23, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        r23->data[i33] = (newPts->data[i33] >= 1.0);
      }

      loop_ub = newPts->size[0];
      i33 = r24->size[0];
      r24->size[0] = loop_ub;
      emxEnsureCapacity_boolean_T(sp, r24, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        r24->data[i33] = (newPts->data[i33 + newPts->size[0]] >= 1.0);
      }

      i33 = r23->size[0];
      n = r24->size[0];
      if (i33 != n) {
        emlrtSizeEqCheck1DR2012b(i33, n, &e_emlrtECI, sp);
      }

      i33 = r23->size[0];
      emxEnsureCapacity_boolean_T(sp, r23, i33, &y_emlrtRTEI);
      loop_ub = r23->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        r23->data[i33] = (r23->data[i33] && r24->data[i33]);
      }

      loop_ub = newPts->size[0];
      i33 = r24->size[0];
      r24->size[0] = loop_ub;
      emxEnsureCapacity_boolean_T(sp, r24, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        r24->data[i33] = (newPts->data[i33] <= 640.0);
      }

      i33 = r23->size[0];
      n = r24->size[0];
      if (i33 != n) {
        emlrtSizeEqCheck1DR2012b(i33, n, &e_emlrtECI, sp);
      }

      i33 = r23->size[0];
      emxEnsureCapacity_boolean_T(sp, r23, i33, &y_emlrtRTEI);
      loop_ub = r23->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        r23->data[i33] = (r23->data[i33] && r24->data[i33]);
      }

      loop_ub = newPts->size[0];
      i33 = r24->size[0];
      r24->size[0] = loop_ub;
      emxEnsureCapacity_boolean_T(sp, r24, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        r24->data[i33] = (newPts->data[i33 + newPts->size[0]] <= 480.0);
      }

      i33 = r23->size[0];
      n = r24->size[0];
      if (i33 != n) {
        emlrtSizeEqCheck1DR2012b(i33, n, &e_emlrtECI, sp);
      }

      n = r23->size[0] - 1;
      trueCount = 0;
      for (nm1d2 = 0; nm1d2 <= n; nm1d2++) {
        if (r23->data[nm1d2] && r24->data[nm1d2]) {
          trueCount++;
        }
      }

      i33 = r26->size[0];
      r26->size[0] = trueCount;
      emxEnsureCapacity_int32_T(sp, r26, i33, &y_emlrtRTEI);
      trueCount = 0;
      for (nm1d2 = 0; nm1d2 <= n; nm1d2++) {
        if (r23->data[nm1d2] && r24->data[nm1d2]) {
          r26->data[trueCount] = nm1d2 + 1;
          trueCount++;
        }
      }

      nm1d2 = newPts->size[0];
      i33 = f_varargin_1->size[0] * f_varargin_1->size[1];
      f_varargin_1->size[0] = r26->size[0];
      f_varargin_1->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, f_varargin_1, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < 2; i33++) {
        loop_ub = r26->size[0];
        for (n = 0; n < loop_ub; n++) {
          trueCount = r26->data[n];
          if (!((trueCount >= 1) && (trueCount <= nm1d2))) {
            emlrtDynamicBoundsCheckR2012b(trueCount, 1, nm1d2, &q_emlrtBCI, sp);
          }

          f_varargin_1->data[n + f_varargin_1->size[0] * i33] = newPts->data
            [(trueCount + newPts->size[0] * i33) - 1];
        }
      }

      i33 = newPts->size[0] * newPts->size[1];
      newPts->size[0] = f_varargin_1->size[0];
      newPts->size[1] = 2;
      emxEnsureCapacity_real_T1(sp, newPts, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < 2; i33++) {
        loop_ub = f_varargin_1->size[0];
        for (n = 0; n < loop_ub; n++) {
          newPts->data[n + newPts->size[0] * i33] = f_varargin_1->data[n +
            f_varargin_1->size[0] * i33];
        }
      }

      st.site = &hh_emlrtRSI;
      loop_ub = newPts->size[0];
      i33 = varargin_1->size[0];
      varargin_1->size[0] = loop_ub;
      emxEnsureCapacity_real_T(&st, varargin_1, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        varargin_1->data[i33] = newPts->data[i33 + newPts->size[0]];
      }

      loop_ub = newPts->size[0];
      i33 = varargin_2->size[0];
      varargin_2->size[0] = loop_ub;
      emxEnsureCapacity_real_T(&st, varargin_2, i33, &y_emlrtRTEI);
      for (i33 = 0; i33 < loop_ub; i33++) {
        varargin_2->data[i33] = newPts->data[i33];
      }

      b_st.site = &lh_emlrtRSI;
      if (!allinrange(varargin_1, 480)) {
        emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
          "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange", 0);
      }

      i33 = newPts->size[0];
      b_varargin_1[0] = i33;
      b_varargin_1[1] = 1.0;
      i33 = newPts->size[0];
      b_varargin_2[0] = i33;
      b_varargin_2[1] = 1.0;
      p = false;
      b_p = true;
      trueCount = 0;
      exitg1 = false;
      while ((!exitg1) && (trueCount < 2)) {
        if (!((int32_T)(uint32_T)b_varargin_1[trueCount] == (int32_T)(uint32_T)
              b_varargin_2[trueCount])) {
          b_p = false;
          exitg1 = true;
        } else {
          trueCount++;
        }
      }

      if (b_p) {
        p = true;
      }

      if (!p) {
        emlrtErrorWithMessageIdR2018a(&b_st, &me_emlrtRTEI,
          "MATLAB:sub2ind:SubscriptVectorSize",
          "MATLAB:sub2ind:SubscriptVectorSize", 0);
      }

      if (!allinrange(varargin_2, 640)) {
        emlrtErrorWithMessageIdR2018a(&b_st, &le_emlrtRTEI,
          "MATLAB:sub2ind:IndexOutOfRange", "MATLAB:sub2ind:IndexOutOfRange", 0);
      }

      i33 = r25->size[0];
      r25->size[0] = varargin_1->size[0];
      emxEnsureCapacity_int32_T(sp, r25, i33, &y_emlrtRTEI);
      loop_ub = varargin_1->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        n = (int32_T)varargin_1->data[i33] + 480 * ((int32_T)varargin_2->
          data[i33] - 1);
        if (!((n >= 1) && (n <= 307200))) {
          emlrtDynamicBoundsCheckR2012b(n, 1, 307200, &r_emlrtBCI, sp);
        }

        r25->data[i33] = n;
      }

      loop_ub = r25->size[0];
      for (i33 = 0; i33 < loop_ub; i33++) {
        SD->u2.f3.mask[r25->data[i33] - 1] = 1U;
      }

      numUnmapped = 307200.0 - sum(SD->u2.f3.mask);
      if (lastNumUnmapped == numUnmapped) {
        numTrials++;
      } else {
        numTrials = 0;
      }

      xBoundsBig[0] = p1[0];
      xBoundsBig[1] = p2[0];
      yBoundsBig[0] = p1[1];
      yBoundsBig[1] = p2[1];
    }

    emxFree_real_T(sp, &f_varargin_1);
    emxFree_real_T(sp, &r27);
    emxFree_real_T(sp, &e_varargin_2);
    emxFree_real_T(sp, &e_varargin_1);
    emxFree_real_T(sp, &d_varargin_2);
    emxFree_real_T(sp, &d_varargin_1);
    emxFree_real_T(sp, &c_varargin_2);
    emxFree_real_T(sp, &c_varargin_1);
    emxFree_real_T(sp, &y);
    emxFree_int32_T(sp, &r26);
    emxFree_int32_T(sp, &r25);
    emxFree_boolean_T(sp, &r24);
    emxFree_boolean_T(sp, &r23);
    emxFree_real_T(sp, &ptsOut);
    emxFree_real_T(sp, &newPts);
  }

  emxFree_real_T(sp, &varargin_2);
  emxFree_real_T(sp, &varargin_1);
  st.site = &ih_emlrtRSI;
  c_ImageTransformer_ImageTransfo(&st, &myMap);
  for (i33 = 0; i33 < 3; i33++) {
    for (n = 0; n < 3; n++) {
      intrinsicMatrix[n + 3 * i33] = this->IntrinsicMatrixInternal[i33 + 3 * n];
    }
  }

  st.site = &jh_emlrtRSI;
  for (i33 = 0; i33 < 2; i33++) {
    b_varargin_1[i33] = this->RadialDistortion[i33];
    b_varargin_2[i33] = this->TangentialDistortion[i33];
  }

  i33 = myMap.SizeOfImage->size[0] * myMap.SizeOfImage->size[1];
  myMap.SizeOfImage->size[0] = 1;
  myMap.SizeOfImage->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, myMap.SizeOfImage, i33, &y_emlrtRTEI);
  for (i33 = 0; i33 < 2; i33++) {
    myMap.SizeOfImage->data[i33] = 480.0 + 160.0 * (real_T)i33;
  }

  i33 = myMap.ClassOfImage->size[0] * myMap.ClassOfImage->size[1];
  myMap.ClassOfImage->size[0] = 1;
  myMap.ClassOfImage->size[1] = 5;
  emxEnsureCapacity_char_T(&st, myMap.ClassOfImage, i33, &y_emlrtRTEI);
  for (i33 = 0; i33 < 5; i33++) {
    myMap.ClassOfImage->data[i33] = cv12[i33];
  }

  i33 = myMap.OutputView->size[0] * myMap.OutputView->size[1];
  myMap.OutputView->size[0] = 1;
  myMap.OutputView->size[1] = 4;
  emxEnsureCapacity_char_T(&st, myMap.OutputView, i33, &y_emlrtRTEI);
  for (i33 = 0; i33 < 4; i33++) {
    myMap.OutputView->data[i33] = outputView[i33];
  }

  for (i33 = 0; i33 < 2; i33++) {
    myMap.XBounds[i33] = xBoundsBig[i33];
  }

  for (i33 = 0; i33 < 2; i33++) {
    myMap.YBounds[i33] = yBoundsBig[i33];
  }

  b_st.site = &ji_emlrtRSI;
  ImageTransformer_computeMap(&b_st, &myMap, intrinsicMatrix, b_varargin_1,
    b_varargin_2);
  st.site = &kh_emlrtRSI;
  ImageTransformer_transformImage(SD, &st, &myMap, undistortedMask);
  c_emxFreeStruct_vision_internal(sp, &myMap);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

static void getInitialBoundaryPixel(const emlrtStack *sp, const emxArray_uint8_T
  *undistortedMask, real_T boundaryPixel[2])
{
  int32_T sRow;
  int32_T sCol;
  int32_T cx;
  int32_T i21;
  int32_T i22;
  int32_T i;
  boolean_T exitg1;
  real_T b_i;
  int32_T i23;
  int32_T i24;
  sRow = -1;
  sCol = -1;
  cx = (int32_T)muDoubleScalarFloor((real_T)undistortedMask->size[1] / 2.0);
  i21 = (int32_T)muDoubleScalarFloor((real_T)undistortedMask->size[0] / 2.0);
  i22 = (int32_T)((real_T)undistortedMask->size[0] + (1.0 - (real_T)i21));
  emlrtForLoopVectorCheckR2012b(i21, 1.0, undistortedMask->size[0],
    mxDOUBLE_CLASS, i22, &jf_emlrtRTEI, sp);
  i = 0;
  exitg1 = false;
  while ((!exitg1) && (i <= i22 - 1)) {
    b_i = (real_T)i21 + (real_T)i;
    i23 = undistortedMask->size[0];
    i24 = (int32_T)b_i;
    if (!((i24 >= 1) && (i24 <= i23))) {
      emlrtDynamicBoundsCheckR2012b(i24, 1, i23, &s_emlrtBCI, sp);
    }

    i23 = undistortedMask->size[1];
    if (!((cx >= 1) && (cx <= i23))) {
      emlrtDynamicBoundsCheckR2012b(cx, 1, i23, &t_emlrtBCI, sp);
    }

    if (undistortedMask->data[(i24 + undistortedMask->size[0] * (cx - 1)) - 1] ==
        0) {
      sRow = (int32_T)b_i - 1;
      sCol = cx;
      exitg1 = true;
    } else {
      i++;
    }
  }

  if (sRow == -1) {
    sRow = undistortedMask->size[0];
    sCol = cx;
  }

  boundaryPixel[0] = sRow;
  boundaryPixel[1] = sCol;
}

void c_CameraParametersImpl_CameraPa(const emlrtStack *sp,
  c_vision_internal_calibration_C **this, const real_T
  varargin_1_RadialDistortion[2], const real_T varargin_1_TangentialDistortion[2],
  const char_T varargin_1_WorldUnits[2], real_T c_varargin_1_NumRadialDistortio,
  const real_T varargin_1_RotationVectors[36], const real_T
  varargin_1_TranslationVectors[36], const real_T varargin_1_IntrinsicMatrix[9])
{
  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  int32_T i60;
  real_T radialDistortion[2];
  real_T rotationVectors[36];
  real_T numRadialCoeffs;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &tc_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  b_st.site = &db_emlrtRSI;
  c_st.site = &eb_emlrtRSI;
  st.site = &uc_emlrtRSI;
  b_st.site = &wc_emlrtRSI;
  c_st.site = &dd_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 9)) {
    if ((!muDoubleScalarIsInf(varargin_1_IntrinsicMatrix[k])) &&
        (!muDoubleScalarIsNaN(varargin_1_IntrinsicMatrix[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:cameraParameters:expectedFinite", 3, 4, 15, "IntrinsicMatrix");
  }

  for (k = 0; k < 3; k++) {
    for (i60 = 0; i60 < 3; i60++) {
      (*this)->IntrinsicMatrixInternal[i60 + 3 * k] =
        varargin_1_IntrinsicMatrix[k + 3 * i60];
    }
  }

  for (k = 0; k < 2; k++) {
    (*this)->RadialDistortion[k] = varargin_1_RadialDistortion[k];
  }

  b_st.site = &xc_emlrtRSI;
  for (k = 0; k < 2; k++) {
    radialDistortion[k] = (*this)->RadialDistortion[k];
  }

  c_st.site = &ed_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if ((!muDoubleScalarIsInf(radialDistortion[k])) && (!muDoubleScalarIsNaN
         (radialDistortion[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:cameraParameters:expectedFinite", 3, 4, 16, "RadialDistortion");
  }

  for (k = 0; k < 2; k++) {
    (*this)->TangentialDistortion[k] = varargin_1_TangentialDistortion[k];
  }

  b_st.site = &yc_emlrtRSI;
  for (k = 0; k < 2; k++) {
    radialDistortion[k] = (*this)->TangentialDistortion[k];
  }

  c_st.site = &fd_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if ((!muDoubleScalarIsInf(radialDistortion[k])) && (!muDoubleScalarIsNaN
         (radialDistortion[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:cameraParameters:expectedFinite", 3, 4, 20, "TangentialDistortion");
  }

  for (k = 0; k < 36; k++) {
    (*this)->RotationVectors[k] = varargin_1_RotationVectors[k];
  }

  b_st.site = &ad_emlrtRSI;
  for (k = 0; k < 36; k++) {
    rotationVectors[k] = (*this)->RotationVectors[k];
  }

  c_st.site = &gd_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 36)) {
    if ((!muDoubleScalarIsInf(rotationVectors[k])) && (!muDoubleScalarIsNaN
         (rotationVectors[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:cameraParameters:expectedFinite", 3, 4, 15, "RotationVectors");
  }

  for (k = 0; k < 36; k++) {
    (*this)->TranslationVectors[k] = varargin_1_TranslationVectors[k];
  }

  b_st.site = &bd_emlrtRSI;
  for (k = 0; k < 36; k++) {
    rotationVectors[k] = (*this)->TranslationVectors[k];
  }

  c_st.site = &hd_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 36)) {
    if ((!muDoubleScalarIsInf(rotationVectors[k])) && (!muDoubleScalarIsNaN
         (rotationVectors[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &ue_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:cameraParameters:expectedFinite", 3, 4, 18, "TranslationVectors");
  }

  for (k = 0; k < 2; k++) {
    (*this)->WorldUnits[k] = varargin_1_WorldUnits[k];
  }

  (*this)->NumRadialDistortionCoefficients = c_varargin_1_NumRadialDistortio;
  b_st.site = &cd_emlrtRSI;
  numRadialCoeffs = (*this)->NumRadialDistortionCoefficients;
  c_st.site = &id_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  if ((!muDoubleScalarIsInf(numRadialCoeffs)) && (!muDoubleScalarIsNaN
       (numRadialCoeffs)) && (muDoubleScalarFloor(numRadialCoeffs) ==
       numRadialCoeffs)) {
  } else {
    p = false;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &se_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedInteger",
      "MATLAB:cameraParameters:expectedInteger", 3, 4, 31,
      "NumRadialDistortionCoefficients");
  }

  d_st.site = &ic_emlrtRSI;
  p = true;
  if (!(numRadialCoeffs >= 2.0)) {
    p = false;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &bg_emlrtRTEI,
      "MATLAB:validateattributes:expectedScalar",
      "MATLAB:cameraParameters:notGreaterEqual", 9, 4, 31,
      "NumRadialDistortionCoefficients", 4, 2, ">=", 4, 1, "2");
  }

  d_st.site = &ic_emlrtRSI;
  p = true;
  if (!(numRadialCoeffs <= 3.0)) {
    p = false;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &qf_emlrtRTEI,
      "MATLAB:validateattributes:expectedScalar",
      "MATLAB:cameraParameters:notLessEqual", 9, 4, 31,
      "NumRadialDistortionCoefficients", 4, 2, "<=", 4, 1, "3");
  }

  st.site = &vc_emlrtRSI;
  b_st.site = &rb_emlrtRSI;
}

void c_CameraParametersImpl_computeU(e_depthEstimationFromStereoVide *SD, const
  emlrtStack *sp, const c_vision_internal_calibration_C *this, real_T xBounds[2],
  real_T yBounds[2])
{
  emxArray_uint8_T *undistortedMask;
  emxArray_real_T *boundaryPixelsUndistorted;
  emxArray_real_T *b_boundaryPixelsUndistorted;
  real_T xBoundsBig[2];
  real_T yBoundsBig[2];
  real_T boundaryPixel[2];
  int32_T loop_ub;
  int32_T c_boundaryPixelsUndistorted;
  int32_T i9;
  emxArray_int32_T *r1;
  int32_T i;
  int32_T i10;
  emxArray_real_T *d_boundaryPixelsUndistorted;
  int32_T iv9[1];
  int32_T iv10[1];
  emxArray_real_T *boundaryPixelsDistorted;
  real_T maxY;
  real_T minX;
  real_T maxX;
  real_T minY;
  emxArray_boolean_T *topIdx;
  emxArray_real_T *r2;
  emxArray_boolean_T *botIdx;
  emxArray_boolean_T *leftIdx;
  emxArray_boolean_T *rightIdx;
  emxArray_int32_T *r3;
  emxArray_int32_T *r4;
  emxArray_int32_T *r5;
  emxArray_int32_T *r6;
  boolean_T b0;
  emxArray_int32_T *r7;
  emxArray_int32_T *r8;
  emxArray_int32_T *r9;
  emxArray_int32_T *r10;
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
  emxInit_uint8_T(sp, &undistortedMask, 2, &q_emlrtRTEI, true);
  emxInit_real_T(sp, &boundaryPixelsUndistorted, 2, &s_emlrtRTEI, true);
  emxInit_real_T(sp, &b_boundaryPixelsUndistorted, 2, &s_emlrtRTEI, true);
  st.site = &ug_emlrtRSI;
  c_CameraParametersImpl_createUn(SD, &st, this, undistortedMask, xBoundsBig,
    yBoundsBig);
  st.site = &vg_emlrtRSI;
  b_st.site = &cj_emlrtRSI;
  getInitialBoundaryPixel(&b_st, undistortedMask, boundaryPixel);
  b_st.site = &dj_emlrtRSI;
  bwtraceboundary(&b_st, undistortedMask, boundaryPixel,
                  boundaryPixelsUndistorted);
  loop_ub = boundaryPixelsUndistorted->size[0];
  c_boundaryPixelsUndistorted = boundaryPixelsUndistorted->size[1];
  i9 = b_boundaryPixelsUndistorted->size[0] * b_boundaryPixelsUndistorted->size
    [1];
  b_boundaryPixelsUndistorted->size[0] = loop_ub;
  b_boundaryPixelsUndistorted->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, b_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  emxFree_uint8_T(&st, &undistortedMask);
  for (i9 = 0; i9 < 2; i9++) {
    for (i = 0; i < loop_ub; i++) {
      i10 = 2 - i9;
      if (!(i10 <= c_boundaryPixelsUndistorted)) {
        emlrtDynamicBoundsCheckR2012b(i10, 1, c_boundaryPixelsUndistorted,
          &o_emlrtBCI, &st);
      }

      b_boundaryPixelsUndistorted->data[i + b_boundaryPixelsUndistorted->size[0]
        * i9] = boundaryPixelsUndistorted->data[i +
        boundaryPixelsUndistorted->size[0] * (i10 - 1)];
    }
  }

  emxInit_int32_T(&st, &r1, 1, &q_emlrtRTEI, true);
  loop_ub = boundaryPixelsUndistorted->size[0];
  i9 = r1->size[0];
  r1->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&st, r1, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    r1->data[i9] = i9;
  }

  emxInit_real_T1(&st, &d_boundaryPixelsUndistorted, 1, &q_emlrtRTEI, true);
  i9 = boundaryPixelsUndistorted->size[0];
  iv9[0] = r1->size[0];
  iv10[0] = i9;
  emlrtSubAssignSizeCheckR2012b(&iv9[0], 1, &iv10[0], 1, &c_emlrtECI, &st);
  loop_ub = boundaryPixelsUndistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  emxFree_real_T(&st, &boundaryPixelsUndistorted);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = b_boundaryPixelsUndistorted->data[i9]
      + xBoundsBig[0];
  }

  loop_ub = d_boundaryPixelsUndistorted->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    b_boundaryPixelsUndistorted->data[r1->data[i9]] =
      d_boundaryPixelsUndistorted->data[i9];
  }

  loop_ub = b_boundaryPixelsUndistorted->size[0];
  i9 = r1->size[0];
  r1->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&st, r1, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    r1->data[i9] = i9;
  }

  i9 = b_boundaryPixelsUndistorted->size[0];
  iv9[0] = r1->size[0];
  iv10[0] = i9;
  emlrtSubAssignSizeCheckR2012b(&iv9[0], 1, &iv10[0], 1, &d_emlrtECI, &st);
  c_boundaryPixelsUndistorted = b_boundaryPixelsUndistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = c_boundaryPixelsUndistorted;
  emxEnsureCapacity_real_T(&st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < c_boundaryPixelsUndistorted; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = b_boundaryPixelsUndistorted->data[i9
      + b_boundaryPixelsUndistorted->size[0]] + yBoundsBig[0];
  }

  loop_ub = d_boundaryPixelsUndistorted->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    b_boundaryPixelsUndistorted->data[r1->data[i9] +
      b_boundaryPixelsUndistorted->size[0]] = d_boundaryPixelsUndistorted->
      data[i9];
  }

  emxFree_int32_T(&st, &r1);
  emxInit_real_T(&st, &boundaryPixelsDistorted, 2, &t_emlrtRTEI, true);
  b_st.site = &ej_emlrtRSI;
  c_CameraParametersImpl_distortP(&b_st, this, b_boundaryPixelsUndistorted,
    boundaryPixelsDistorted);
  b_st.site = &fj_emlrtRSI;
  c_st.site = &gk_emlrtRSI;
  d_st.site = &hk_emlrtRSI;
  e_st.site = &ik_emlrtRSI;
  i9 = boundaryPixelsDistorted->size[0];
  if (i9 == 1) {
  } else {
    i9 = boundaryPixelsDistorted->size[0];
    if (i9 != 1) {
    } else {
      emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
        "Coder:toolbox:autoDimIncompatibility",
        "Coder:toolbox:autoDimIncompatibility", 0);
    }
  }

  i9 = boundaryPixelsDistorted->size[0];
  if (!(i9 >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  loop_ub = boundaryPixelsDistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&e_st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = boundaryPixelsDistorted->data[i9];
  }

  f_st.site = &jk_emlrtRSI;
  maxY = minOrMaxRealFloatVector(&f_st, d_boundaryPixelsUndistorted);
  minX = muDoubleScalarMax(1.0, maxY);
  b_st.site = &gj_emlrtRSI;
  c_st.site = &ok_emlrtRSI;
  d_st.site = &hk_emlrtRSI;
  e_st.site = &ik_emlrtRSI;
  i9 = boundaryPixelsDistorted->size[0];
  if (i9 == 1) {
  } else {
    i9 = boundaryPixelsDistorted->size[0];
    if (i9 != 1) {
    } else {
      emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
        "Coder:toolbox:autoDimIncompatibility",
        "Coder:toolbox:autoDimIncompatibility", 0);
    }
  }

  i9 = boundaryPixelsDistorted->size[0];
  if (!(i9 >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  loop_ub = boundaryPixelsDistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&e_st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = boundaryPixelsDistorted->data[i9];
  }

  f_st.site = &jk_emlrtRSI;
  maxY = b_minOrMaxRealFloatVector(&f_st, d_boundaryPixelsUndistorted);
  maxX = muDoubleScalarMin(640.0, maxY);
  b_st.site = &hj_emlrtRSI;
  c_st.site = &gk_emlrtRSI;
  d_st.site = &hk_emlrtRSI;
  e_st.site = &ik_emlrtRSI;
  i9 = boundaryPixelsDistorted->size[0];
  if (i9 == 1) {
  } else {
    i9 = boundaryPixelsDistorted->size[0];
    if (i9 != 1) {
    } else {
      emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
        "Coder:toolbox:autoDimIncompatibility",
        "Coder:toolbox:autoDimIncompatibility", 0);
    }
  }

  i9 = boundaryPixelsDistorted->size[0];
  if (!(i9 >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  loop_ub = boundaryPixelsDistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&e_st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = boundaryPixelsDistorted->data[i9 +
      boundaryPixelsDistorted->size[0]];
  }

  f_st.site = &jk_emlrtRSI;
  maxY = minOrMaxRealFloatVector(&f_st, d_boundaryPixelsUndistorted);
  minY = muDoubleScalarMax(1.0, maxY);
  b_st.site = &ij_emlrtRSI;
  c_st.site = &ok_emlrtRSI;
  d_st.site = &hk_emlrtRSI;
  e_st.site = &ik_emlrtRSI;
  i9 = boundaryPixelsDistorted->size[0];
  if (i9 == 1) {
  } else {
    i9 = boundaryPixelsDistorted->size[0];
    if (i9 != 1) {
    } else {
      emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
        "Coder:toolbox:autoDimIncompatibility",
        "Coder:toolbox:autoDimIncompatibility", 0);
    }
  }

  i9 = boundaryPixelsDistorted->size[0];
  if (!(i9 >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  loop_ub = boundaryPixelsDistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&e_st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = boundaryPixelsDistorted->data[i9 +
      boundaryPixelsDistorted->size[0]];
  }

  f_st.site = &jk_emlrtRSI;
  maxY = b_minOrMaxRealFloatVector(&f_st, d_boundaryPixelsUndistorted);
  maxY = muDoubleScalarMin(480.0, maxY);
  loop_ub = boundaryPixelsDistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = boundaryPixelsDistorted->data[i9 +
      boundaryPixelsDistorted->size[0]] - minY;
  }

  emxInit_boolean_T(&st, &topIdx, 1, &u_emlrtRTEI, true);
  emxInit_real_T1(&st, &r2, 1, &q_emlrtRTEI, true);
  b_st.site = &jj_emlrtRSI;
  b_abs(&b_st, d_boundaryPixelsUndistorted, r2);
  i9 = topIdx->size[0];
  topIdx->size[0] = r2->size[0];
  emxEnsureCapacity_boolean_T(&st, topIdx, i9, &q_emlrtRTEI);
  loop_ub = r2->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    topIdx->data[i9] = (r2->data[i9] < 7.0);
  }

  loop_ub = boundaryPixelsDistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = boundaryPixelsDistorted->data[i9 +
      boundaryPixelsDistorted->size[0]] - maxY;
  }

  emxInit_boolean_T(&st, &botIdx, 1, &v_emlrtRTEI, true);
  b_st.site = &kj_emlrtRSI;
  b_abs(&b_st, d_boundaryPixelsUndistorted, r2);
  i9 = botIdx->size[0];
  botIdx->size[0] = r2->size[0];
  emxEnsureCapacity_boolean_T(&st, botIdx, i9, &q_emlrtRTEI);
  loop_ub = r2->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    botIdx->data[i9] = (r2->data[i9] < 7.0);
  }

  loop_ub = boundaryPixelsDistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = boundaryPixelsDistorted->data[i9] -
      minX;
  }

  emxInit_boolean_T(&st, &leftIdx, 1, &w_emlrtRTEI, true);
  b_st.site = &lj_emlrtRSI;
  b_abs(&b_st, d_boundaryPixelsUndistorted, r2);
  i9 = leftIdx->size[0];
  leftIdx->size[0] = r2->size[0];
  emxEnsureCapacity_boolean_T(&st, leftIdx, i9, &q_emlrtRTEI);
  loop_ub = r2->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    leftIdx->data[i9] = (r2->data[i9] < 7.0);
  }

  loop_ub = boundaryPixelsDistorted->size[0];
  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = loop_ub;
  emxEnsureCapacity_real_T(&st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = boundaryPixelsDistorted->data[i9] -
      maxX;
  }

  emxFree_real_T(&st, &boundaryPixelsDistorted);
  emxInit_boolean_T(&st, &rightIdx, 1, &x_emlrtRTEI, true);
  b_st.site = &mj_emlrtRSI;
  b_abs(&b_st, d_boundaryPixelsUndistorted, r2);
  i9 = rightIdx->size[0];
  rightIdx->size[0] = r2->size[0];
  emxEnsureCapacity_boolean_T(&st, rightIdx, i9, &q_emlrtRTEI);
  loop_ub = r2->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    rightIdx->data[i9] = (r2->data[i9] < 7.0);
  }

  emxFree_real_T(&st, &r2);
  c_boundaryPixelsUndistorted = topIdx->size[0];
  for (i = 0; i < c_boundaryPixelsUndistorted; i++) {
    if (topIdx->data[i]) {
      i9 = b_boundaryPixelsUndistorted->size[0];
      if (!((i + 1 >= 1) && (i + 1 <= i9))) {
        emlrtDynamicBoundsCheckR2012b(i + 1, 1, i9, &k_emlrtBCI, &st);
      }
    }
  }

  c_boundaryPixelsUndistorted = botIdx->size[0];
  for (i = 0; i < c_boundaryPixelsUndistorted; i++) {
    if (botIdx->data[i]) {
      i9 = b_boundaryPixelsUndistorted->size[0];
      if (!((i + 1 >= 1) && (i + 1 <= i9))) {
        emlrtDynamicBoundsCheckR2012b(i + 1, 1, i9, &l_emlrtBCI, &st);
      }
    }
  }

  c_boundaryPixelsUndistorted = leftIdx->size[0];
  for (i = 0; i < c_boundaryPixelsUndistorted; i++) {
    if (leftIdx->data[i]) {
      i9 = b_boundaryPixelsUndistorted->size[0];
      if (!((i + 1 >= 1) && (i + 1 <= i9))) {
        emlrtDynamicBoundsCheckR2012b(i + 1, 1, i9, &m_emlrtBCI, &st);
      }
    }
  }

  c_boundaryPixelsUndistorted = rightIdx->size[0];
  for (i = 0; i < c_boundaryPixelsUndistorted; i++) {
    if (rightIdx->data[i]) {
      i9 = b_boundaryPixelsUndistorted->size[0];
      if (!((i + 1 >= 1) && (i + 1 <= i9))) {
        emlrtDynamicBoundsCheckR2012b(i + 1, 1, i9, &n_emlrtBCI, &st);
      }
    }
  }

  c_boundaryPixelsUndistorted = topIdx->size[0] - 1;
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (topIdx->data[i]) {
      loop_ub++;
    }
  }

  emxInit_int32_T(&st, &r3, 1, &q_emlrtRTEI, true);
  i9 = r3->size[0];
  r3->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&st, r3, i9, &r_emlrtRTEI);
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (topIdx->data[i]) {
      r3->data[loop_ub] = i + 1;
      loop_ub++;
    }
  }

  emxInit_int32_T(&st, &r4, 1, &q_emlrtRTEI, true);
  emxInit_int32_T(&st, &r5, 1, &q_emlrtRTEI, true);
  emxInit_int32_T(&st, &r6, 1, &q_emlrtRTEI, true);
  if (r3->size[0] == 0) {
    b0 = true;
  } else {
    c_boundaryPixelsUndistorted = botIdx->size[0] - 1;
    loop_ub = 0;
    for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
      if (botIdx->data[i]) {
        loop_ub++;
      }
    }

    i9 = r4->size[0];
    r4->size[0] = loop_ub;
    emxEnsureCapacity_int32_T(&st, r4, i9, &r_emlrtRTEI);
    loop_ub = 0;
    for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
      if (botIdx->data[i]) {
        r4->data[loop_ub] = i + 1;
        loop_ub++;
      }
    }

    if (r4->size[0] == 0) {
      b0 = true;
    } else {
      c_boundaryPixelsUndistorted = leftIdx->size[0] - 1;
      loop_ub = 0;
      for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
        if (leftIdx->data[i]) {
          loop_ub++;
        }
      }

      i9 = r5->size[0];
      r5->size[0] = loop_ub;
      emxEnsureCapacity_int32_T(&st, r5, i9, &r_emlrtRTEI);
      loop_ub = 0;
      for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
        if (leftIdx->data[i]) {
          r5->data[loop_ub] = i + 1;
          loop_ub++;
        }
      }

      if (r5->size[0] == 0) {
        b0 = true;
      } else {
        c_boundaryPixelsUndistorted = rightIdx->size[0] - 1;
        loop_ub = 0;
        for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
          if (rightIdx->data[i]) {
            loop_ub++;
          }
        }

        i9 = r6->size[0];
        r6->size[0] = loop_ub;
        emxEnsureCapacity_int32_T(&st, r6, i9, &r_emlrtRTEI);
        loop_ub = 0;
        for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
          if (rightIdx->data[i]) {
            r6->data[loop_ub] = i + 1;
            loop_ub++;
          }
        }

        if (r6->size[0] == 0) {
          b0 = true;
        } else {
          b0 = false;
        }
      }
    }
  }

  emxFree_int32_T(&st, &r6);
  emxFree_int32_T(&st, &r5);
  emxFree_int32_T(&st, &r4);
  emxFree_int32_T(&st, &r3);
  if (b0) {
    emlrtErrorWithMessageIdR2018a(&st, &af_emlrtRTEI,
      "vision:calibrate:cannotComputeValidBounds",
      "vision:calibrate:cannotComputeValidBounds", 0);
  }

  c_boundaryPixelsUndistorted = topIdx->size[0] - 1;
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (topIdx->data[i]) {
      loop_ub++;
    }
  }

  emxInit_int32_T(&st, &r7, 1, &q_emlrtRTEI, true);
  i9 = r7->size[0];
  r7->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&st, r7, i9, &r_emlrtRTEI);
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (topIdx->data[i]) {
      r7->data[loop_ub] = i + 1;
      loop_ub++;
    }
  }

  emxFree_boolean_T(&st, &topIdx);
  b_st.site = &nj_emlrtRSI;
  c_st.site = &ok_emlrtRSI;
  d_st.site = &hk_emlrtRSI;
  e_st.site = &ik_emlrtRSI;
  if ((r7->size[0] == 1) || (r7->size[0] != 1)) {
  } else {
    emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
      "Coder:toolbox:autoDimIncompatibility",
      "Coder:toolbox:autoDimIncompatibility", 0);
  }

  if (!(r7->size[0] >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = r7->size[0];
  emxEnsureCapacity_real_T(&e_st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  loop_ub = r7->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = b_boundaryPixelsUndistorted->data
      [(r7->data[i9] + b_boundaryPixelsUndistorted->size[0]) - 1];
  }

  emxFree_int32_T(&e_st, &r7);
  f_st.site = &jk_emlrtRSI;
  maxY = b_minOrMaxRealFloatVector(&f_st, d_boundaryPixelsUndistorted);
  c_boundaryPixelsUndistorted = botIdx->size[0] - 1;
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (botIdx->data[i]) {
      loop_ub++;
    }
  }

  emxInit_int32_T(&st, &r8, 1, &q_emlrtRTEI, true);
  i9 = r8->size[0];
  r8->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&st, r8, i9, &r_emlrtRTEI);
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (botIdx->data[i]) {
      r8->data[loop_ub] = i + 1;
      loop_ub++;
    }
  }

  emxFree_boolean_T(&st, &botIdx);
  b_st.site = &oj_emlrtRSI;
  c_st.site = &gk_emlrtRSI;
  d_st.site = &hk_emlrtRSI;
  e_st.site = &ik_emlrtRSI;
  if ((r8->size[0] == 1) || (r8->size[0] != 1)) {
  } else {
    emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
      "Coder:toolbox:autoDimIncompatibility",
      "Coder:toolbox:autoDimIncompatibility", 0);
  }

  if (!(r8->size[0] >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = r8->size[0];
  emxEnsureCapacity_real_T(&e_st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  loop_ub = r8->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = b_boundaryPixelsUndistorted->data
      [(r8->data[i9] + b_boundaryPixelsUndistorted->size[0]) - 1];
  }

  emxFree_int32_T(&e_st, &r8);
  f_st.site = &jk_emlrtRSI;
  minY = minOrMaxRealFloatVector(&f_st, d_boundaryPixelsUndistorted);
  c_boundaryPixelsUndistorted = leftIdx->size[0] - 1;
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (leftIdx->data[i]) {
      loop_ub++;
    }
  }

  emxInit_int32_T(&st, &r9, 1, &q_emlrtRTEI, true);
  i9 = r9->size[0];
  r9->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&st, r9, i9, &r_emlrtRTEI);
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (leftIdx->data[i]) {
      r9->data[loop_ub] = i + 1;
      loop_ub++;
    }
  }

  emxFree_boolean_T(&st, &leftIdx);
  b_st.site = &pj_emlrtRSI;
  c_st.site = &ok_emlrtRSI;
  d_st.site = &hk_emlrtRSI;
  e_st.site = &ik_emlrtRSI;
  if ((r9->size[0] == 1) || (r9->size[0] != 1)) {
  } else {
    emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
      "Coder:toolbox:autoDimIncompatibility",
      "Coder:toolbox:autoDimIncompatibility", 0);
  }

  if (!(r9->size[0] >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = r9->size[0];
  emxEnsureCapacity_real_T(&e_st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  loop_ub = r9->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = b_boundaryPixelsUndistorted->data
      [r9->data[i9] - 1];
  }

  emxFree_int32_T(&e_st, &r9);
  f_st.site = &jk_emlrtRSI;
  minX = b_minOrMaxRealFloatVector(&f_st, d_boundaryPixelsUndistorted);
  c_boundaryPixelsUndistorted = rightIdx->size[0] - 1;
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (rightIdx->data[i]) {
      loop_ub++;
    }
  }

  emxInit_int32_T(&st, &r10, 1, &q_emlrtRTEI, true);
  i9 = r10->size[0];
  r10->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&st, r10, i9, &r_emlrtRTEI);
  loop_ub = 0;
  for (i = 0; i <= c_boundaryPixelsUndistorted; i++) {
    if (rightIdx->data[i]) {
      r10->data[loop_ub] = i + 1;
      loop_ub++;
    }
  }

  emxFree_boolean_T(&st, &rightIdx);
  b_st.site = &qj_emlrtRSI;
  c_st.site = &gk_emlrtRSI;
  d_st.site = &hk_emlrtRSI;
  e_st.site = &ik_emlrtRSI;
  if ((r10->size[0] == 1) || (r10->size[0] != 1)) {
  } else {
    emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
      "Coder:toolbox:autoDimIncompatibility",
      "Coder:toolbox:autoDimIncompatibility", 0);
  }

  if (!(r10->size[0] >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  i9 = d_boundaryPixelsUndistorted->size[0];
  d_boundaryPixelsUndistorted->size[0] = r10->size[0];
  emxEnsureCapacity_real_T(&e_st, d_boundaryPixelsUndistorted, i9, &q_emlrtRTEI);
  loop_ub = r10->size[0];
  for (i9 = 0; i9 < loop_ub; i9++) {
    d_boundaryPixelsUndistorted->data[i9] = b_boundaryPixelsUndistorted->
      data[r10->data[i9] - 1];
  }

  emxFree_int32_T(&e_st, &r10);
  emxFree_real_T(&e_st, &b_boundaryPixelsUndistorted);
  f_st.site = &jk_emlrtRSI;
  maxX = minOrMaxRealFloatVector(&f_st, d_boundaryPixelsUndistorted);
  xBounds[0] = muDoubleScalarCeil(minX);
  xBounds[1] = muDoubleScalarFloor(maxX);
  sort(xBounds);
  yBounds[0] = muDoubleScalarCeil(maxY);
  yBounds[1] = muDoubleScalarFloor(minY);
  sort(yBounds);
  emxFree_real_T(sp, &d_boundaryPixelsUndistorted);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void d_CameraParametersImpl_computeU(e_depthEstimationFromStereoVide *SD, const
  emlrtStack *sp, const c_vision_internal_calibration_C *this, real_T xBounds[2],
  real_T yBounds[2])
{
  emxArray_uint8_T *undistortedMask;
  emxArray_boolean_T *b_undistortedMask;
  real_T xBoundsBig[2];
  real_T yBoundsBig[2];
  int32_T i32;
  int32_T loop_ub;
  emxArray_struct_T *props;
  real_T center[2];
  emxArray_real_T *dists;
  real_T ex;
  real_T a;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_uint8_T(sp, &undistortedMask, 2, &q_emlrtRTEI, true);
  emxInit_boolean_T1(sp, &b_undistortedMask, 2, &q_emlrtRTEI, true);
  st.site = &ug_emlrtRSI;
  d_CameraParametersImpl_createUn(SD, &st, this, undistortedMask, xBoundsBig,
    yBoundsBig);
  st.site = &hl_emlrtRSI;
  i32 = b_undistortedMask->size[0] * b_undistortedMask->size[1];
  b_undistortedMask->size[0] = undistortedMask->size[0];
  b_undistortedMask->size[1] = undistortedMask->size[1];
  emxEnsureCapacity_boolean_T1(&st, b_undistortedMask, i32, &q_emlrtRTEI);
  loop_ub = undistortedMask->size[0] * undistortedMask->size[1];
  for (i32 = 0; i32 < loop_ub; i32++) {
    b_undistortedMask->data[i32] = (undistortedMask->data[i32] != 0);
  }

  emxInit_struct_T(&st, &props, 1, &gc_emlrtRTEI, true);
  b_st.site = &il_emlrtRSI;
  regionprops(&b_st, b_undistortedMask, props);
  emxFree_boolean_T(&st, &b_undistortedMask);
  for (i32 = 0; i32 < 2; i32++) {
    center[i32] = (real_T)undistortedMask->size[i32] / 2.0;
  }

  emxFree_uint8_T(&st, &undistortedMask);
  for (loop_ub = 0; loop_ub < 2; loop_ub++) {
    center[loop_ub] = muDoubleScalarRound(center[loop_ub]);
  }

  emxInit_real_T(&st, &dists, 2, &hc_emlrtRTEI, true);
  i32 = dists->size[0] * dists->size[1];
  dists->size[0] = 1;
  dists->size[1] = props->size[0];
  emxEnsureCapacity_real_T1(&st, dists, i32, &q_emlrtRTEI);
  loop_ub = props->size[0];
  for (i32 = 0; i32 < loop_ub; i32++) {
    dists->data[i32] = 0.0;
  }

  for (loop_ub = 1; loop_ub - 1 < props->size[0]; loop_ub++) {
    b_st.site = &jl_emlrtRSI;
    i32 = props->size[0];
    if (!((loop_ub >= 1) && (loop_ub <= i32))) {
      emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i32, &ub_emlrtBCI, &b_st);
    }

    ex = props->data[loop_ub - 1].Centroid[0] - center[1];
    c_st.site = &bi_emlrtRSI;
    b_st.site = &kl_emlrtRSI;
    i32 = props->size[0];
    if (!((loop_ub >= 1) && (loop_ub <= i32))) {
      emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i32, &vb_emlrtBCI, &b_st);
    }

    a = props->data[loop_ub - 1].Centroid[1] - center[0];
    c_st.site = &bi_emlrtRSI;
    i32 = dists->size[1];
    if (!((loop_ub >= 1) && (loop_ub <= i32))) {
      emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i32, &wb_emlrtBCI, &st);
    }

    dists->data[loop_ub - 1] = ex * ex + a * a;
  }

  b_st.site = &ll_emlrtRSI;
  c_st.site = &ln_emlrtRSI;
  d_st.site = &mn_emlrtRSI;
  e_st.site = &nn_emlrtRSI;
  if ((dists->size[1] == 1) || (dists->size[1] != 1)) {
  } else {
    emlrtErrorWithMessageIdR2018a(&e_st, &bf_emlrtRTEI,
      "Coder:toolbox:autoDimIncompatibility",
      "Coder:toolbox:autoDimIncompatibility", 0);
  }

  if (!(dists->size[1] >= 1)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &cf_emlrtRTEI,
      "Coder:toolbox:eml_min_or_max_varDimZero",
      "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }

  f_st.site = &on_emlrtRSI;
  if (dists->size[1] <= 2) {
    if (dists->size[1] == 1) {
      loop_ub = 1;
    } else if ((dists->data[0] > dists->data[1]) || (muDoubleScalarIsNaN
                (dists->data[0]) && (!muDoubleScalarIsNaN(dists->data[1])))) {
      loop_ub = 2;
    } else {
      loop_ub = 1;
    }
  } else {
    g_st.site = &lk_emlrtRSI;
    loop_ub = b_findFirst(&g_st, dists);
    if (loop_ub == 0) {
      loop_ub = 1;
    } else {
      g_st.site = &kk_emlrtRSI;
      minOrMaxRealFloatVectorKernel(&g_st, dists, loop_ub, dists->size[1], &ex,
        &loop_ub);
    }
  }

  emxFree_real_T(&f_st, &dists);
  i32 = props->size[0];
  if (!((loop_ub >= 1) && (loop_ub <= i32))) {
    emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i32, &tb_emlrtBCI, &st);
  }

  xBounds[0] = muDoubleScalarCeil((xBoundsBig[0] + props->data[loop_ub - 1].
    BoundingBox[0]) - 1.0);
  xBounds[1] = muDoubleScalarFloor(xBounds[0] + props->data[loop_ub - 1].
    BoundingBox[2]);
  yBounds[0] = muDoubleScalarCeil((yBoundsBig[0] + props->data[loop_ub - 1].
    BoundingBox[1]) - 1.0);
  yBounds[1] = muDoubleScalarFloor(yBounds[0] + props->data[loop_ub - 1].
    BoundingBox[3]);
  emxFree_struct_T(sp, &props);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (CameraParametersImpl.c) */
