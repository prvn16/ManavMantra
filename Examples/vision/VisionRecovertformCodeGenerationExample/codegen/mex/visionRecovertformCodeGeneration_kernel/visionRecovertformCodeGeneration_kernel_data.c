/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * visionRecovertformCodeGeneration_kernel_data.c
 *
 * Code generation for function 'visionRecovertformCodeGeneration_kernel_data'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;
emlrtContext emlrtContextGlobal = { true,/* bFirstTime */
  false,                               /* bInitialized */
  131466U,                             /* fVersionInfo */
  NULL,                                /* fErrorFunction */
  "visionRecovertformCodeGeneration_kernel",/* fFunctionName */
  NULL,                                /* fRTCallStack */
  false,                               /* bDebugMode */
  { 933878966U, 2751585356U, 3052266547U, 2808075253U },/* fSigWrd */
  NULL                                 /* fSigMem */
};

emlrtRSInfo n_emlrtRSI = { 128,        /* lineNo */
  "detectSURFFeatures",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pathName */
};

emlrtRSInfo o_emlrtRSI = { 39,         /* lineNo */
  "validateImage",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\validateImage.m"/* pathName */
};

emlrtRSInfo p_emlrtRSI = { 49,         /* lineNo */
  "validateImage",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\validateImage.m"/* pathName */
};

emlrtRSInfo q_emlrtRSI = { 70,         /* lineNo */
  "validateattributes",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\lang\\validateattributes.m"/* pathName */
};

emlrtRSInfo r_emlrtRSI = { 12,         /* lineNo */
  "SURFPoints_cg",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPoints_cg.m"/* pathName */
};

emlrtRSInfo s_emlrtRSI = { 25,         /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo t_emlrtRSI = { 26,         /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo u_emlrtRSI = { 194,        /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo v_emlrtRSI = { 196,        /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo w_emlrtRSI = { 197,        /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo x_emlrtRSI = { 198,        /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo y_emlrtRSI = { 203,        /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo ab_emlrtRSI = { 204,       /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo bb_emlrtRSI = { 240,       /* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

emlrtRSInfo cb_emlrtRSI = { 241,       /* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

emlrtRSInfo db_emlrtRSI = { 245,       /* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

emlrtRSInfo gb_emlrtRSI = { 357,       /* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

emlrtRSInfo ib_emlrtRSI = { 323,       /* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

emlrtRSInfo jb_emlrtRSI = { 216,       /* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

emlrtRSInfo lb_emlrtRSI = { 146,       /* lineNo */
  "allOrAny",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\allOrAny.m"/* pathName */
};

emlrtRSInfo mb_emlrtRSI = { 21,        /* lineNo */
  "eml_int_forloop_overflow_check",    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\eml\\eml_int_forloop_overflow_check.m"/* pathName */
};

emlrtRSInfo tb_emlrtRSI = { 22,        /* lineNo */
  "repmat",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pathName */
};

emlrtRSInfo dc_emlrtRSI = { 48,        /* lineNo */
  "checkPoints",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkPoints.m"/* pathName */
};

emlrtRSInfo qc_emlrtRSI = { 49,        /* lineNo */
  "power",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\power.m"/* pathName */
};

emlrtRSInfo rc_emlrtRSI = { 58,        /* lineNo */
  "power",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\power.m"/* pathName */
};

emlrtRSInfo sc_emlrtRSI = { 45,        /* lineNo */
  "applyBinaryScalarFunction",         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\applyBinaryScalarFunction.m"/* pathName */
};

emlrtRSInfo tc_emlrtRSI = { 65,        /* lineNo */
  "applyBinaryScalarFunction",         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\applyBinaryScalarFunction.m"/* pathName */
};

emlrtRSInfo uc_emlrtRSI = { 189,       /* lineNo */
  "applyBinaryScalarFunction",         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\applyBinaryScalarFunction.m"/* pathName */
};

emlrtRSInfo vc_emlrtRSI = { 9,         /* lineNo */
  "sum",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\sum.m"/* pathName */
};

emlrtRSInfo wc_emlrtRSI = { 64,        /* lineNo */
  "sumprod",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumprod.m"/* pathName */
};

emlrtRSInfo xc_emlrtRSI = { 71,        /* lineNo */
  "combineVectorElements",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\combineVectorElements.m"/* pathName */
};

emlrtRSInfo yc_emlrtRSI = { 80,        /* lineNo */
  "blockedSummation",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pathName */
};

emlrtRSInfo ad_emlrtRSI = { 172,       /* lineNo */
  "blockedSummation",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pathName */
};

emlrtRSInfo bd_emlrtRSI = { 158,       /* lineNo */
  "blockedSummation",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pathName */
};

emlrtRSInfo cd_emlrtRSI = { 136,       /* lineNo */
  "blockedSummation",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pathName */
};

emlrtRSInfo dd_emlrtRSI = { 12,        /* lineNo */
  "sqrt",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\sqrt.m"/* pathName */
};

emlrtRSInfo cf_emlrtRSI = { 506,       /* lineNo */
  "sortIdx",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sortIdx.m"/* pathName */
};

emlrtRSInfo hf_emlrtRSI = { 20,        /* lineNo */
  "cat",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pathName */
};

emlrtRSInfo if_emlrtRSI = { 100,       /* lineNo */
  "cat",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pathName */
};

emlrtRSInfo lg_emlrtRSI = { 69,        /* lineNo */
  "randperm",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\randfun\\randperm.m"/* pathName */
};

emlrtRSInfo mg_emlrtRSI = { 57,        /* lineNo */
  "randperm",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\randfun\\randperm.m"/* pathName */
};

emlrtRSInfo ng_emlrtRSI = { 50,        /* lineNo */
  "randperm",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\randfun\\randperm.m"/* pathName */
};

emlrtRSInfo og_emlrtRSI = { 40,        /* lineNo */
  "randperm",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\randfun\\randperm.m"/* pathName */
};

emlrtRSInfo yg_emlrtRSI = { 38,        /* lineNo */
  "mean",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\mean.m"/* pathName */
};

emlrtRSInfo ah_emlrtRSI = { 193,       /* lineNo */
  "blockedSummation",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pathName */
};

emlrtRSInfo ch_emlrtRSI = { 21,        /* lineNo */
  "eml_mtimes_helper",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_helper.m"/* pathName */
};

emlrtRSInfo fh_emlrtRSI = { 25,        /* lineNo */
  "cat",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pathName */
};

emlrtRSInfo vh_emlrtRSI = { 7,         /* lineNo */
  "int",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\int.m"/* pathName */
};

emlrtRSInfo wh_emlrtRSI = { 8,         /* lineNo */
  "majority",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\majority.m"/* pathName */
};

emlrtRSInfo xh_emlrtRSI = { 31,        /* lineNo */
  "infocheck",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\infocheck.m"/* pathName */
};

emlrtRSInfo yh_emlrtRSI = { 45,        /* lineNo */
  "infocheck",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\infocheck.m"/* pathName */
};

emlrtRSInfo ai_emlrtRSI = { 48,        /* lineNo */
  "infocheck",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\infocheck.m"/* pathName */
};

emlrtRSInfo ii_emlrtRSI = { 1,         /* lineNo */
  "mrdivide",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\mrdivide.p"/* pathName */
};

emlrtRSInfo li_emlrtRSI = { 76,        /* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

emlrtRSInfo dj_emlrtRSI = { 40,        /* lineNo */
  "mpower",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\mpower.m"/* pathName */
};

emlrtRSInfo tj_emlrtRSI = { 25,        /* lineNo */
  "colon",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m"/* pathName */
};

emlrtRSInfo uj_emlrtRSI = { 78,        /* lineNo */
  "colon",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m"/* pathName */
};

emlrtRSInfo vj_emlrtRSI = { 121,       /* lineNo */
  "colon",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m"/* pathName */
};

emlrtRSInfo fk_emlrtRSI = { 111,       /* lineNo */
  "affine2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pathName */
};

emlrtRSInfo gk_emlrtRSI = { 353,       /* lineNo */
  "affine2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pathName */
};

emlrtRSInfo hk_emlrtRSI = { 359,       /* lineNo */
  "affine2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pathName */
};

emlrtRSInfo ik_emlrtRSI = { 364,       /* lineNo */
  "affine2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pathName */
};

emlrtRSInfo jk_emlrtRSI = { 281,       /* lineNo */
  "affine2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pathName */
};

emlrtRSInfo kk_emlrtRSI = { 380,       /* lineNo */
  "affine2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pathName */
};

emlrtRSInfo xk_emlrtRSI = { 42,        /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

emlrtRSInfo yk_emlrtRSI = { 46,        /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

emlrtRSInfo al_emlrtRSI = { 128,       /* lineNo */
  "imref2d",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\imref2d.m"/* pathName */
};

emlrtRSInfo bl_emlrtRSI = { 151,       /* lineNo */
  "imref2d",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\imref2d.m"/* pathName */
};

emlrtRSInfo cl_emlrtRSI = { 152,       /* lineNo */
  "imref2d",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\imref2d.m"/* pathName */
};

emlrtRSInfo dl_emlrtRSI = { 354,       /* lineNo */
  "imref2d",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\imref2d.m"/* pathName */
};

emlrtRSInfo el_emlrtRSI = { 376,       /* lineNo */
  "imref2d",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\imref2d.m"/* pathName */
};

emlrtRSInfo sl_emlrtRSI = { 143,       /* lineNo */
  "xtrsm",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\xtrsm.m"/* pathName */
};

emlrtRSInfo mm_emlrtRSI = { 26,        /* lineNo */
  "xzunormqr",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzunormqr.m"/* pathName */
};

emlrtRSInfo nm_emlrtRSI = { 20,        /* lineNo */
  "xzunormqr",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzunormqr.m"/* pathName */
};

emlrtRSInfo om_emlrtRSI = { 15,        /* lineNo */
  "xzunormqr",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzunormqr.m"/* pathName */
};

emlrtMCInfo b_emlrtMCI = { 41,         /* lineNo */
  5,                                   /* colNo */
  "repmat",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pName */
};

emlrtMCInfo e_emlrtMCI = { 53,         /* lineNo */
  19,                                  /* colNo */
  "flt2str",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\flt2str.m"/* pName */
};

emlrtRTEInfo bb_emlrtRTEI = { 24,      /* lineNo */
  17,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

emlrtRTEInfo cb_emlrtRTEI = { 216,     /* lineNo */
  43,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

emlrtRTEInfo db_emlrtRTEI = { 216,     /* lineNo */
  61,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

emlrtRTEInfo uf_emlrtRTEI = { 45,      /* lineNo */
  6,                                   /* colNo */
  "applyBinaryScalarFunction",         /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\applyBinaryScalarFunction.m"/* pName */
};

emlrtRTEInfo vf_emlrtRTEI = { 58,      /* lineNo */
  5,                                   /* colNo */
  "power",                             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\power.m"/* pName */
};

emlrtRTEInfo xf_emlrtRTEI = { 80,      /* lineNo */
  13,                                  /* colNo */
  "blockedSummation",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\blockedSummation.m"/* pName */
};

emlrtRTEInfo xh_emlrtRTEI = { 364,     /* lineNo */
  13,                                  /* colNo */
  "affine2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pName */
};

emlrtBCInfo d_emlrtBCI = { -1,         /* iFirst */
  -1,                                  /* iLast */
  368,                                 /* lineNo */
  49,                                  /* colNo */
  "",                                  /* aName */
  "affine2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m",/* pName */
  0                                    /* checkKind */
};

emlrtRTEInfo yh_emlrtRTEI = { 368,     /* lineNo */
  13,                                  /* colNo */
  "affine2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pName */
};

emlrtRTEInfo ai_emlrtRTEI = { 281,     /* lineNo */
  27,                                  /* colNo */
  "cat",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pName */
};

emlrtRTEInfo bi_emlrtRTEI = { 13,      /* lineNo */
  37,                                  /* colNo */
  "validatepositive",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatepositive.m"/* pName */
};

emlrtRTEInfo ci_emlrtRTEI = { 13,      /* lineNo */
  37,                                  /* colNo */
  "validatefinite",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatefinite.m"/* pName */
};

emlrtRTEInfo fi_emlrtRTEI = { 331,     /* lineNo */
  17,                                  /* colNo */
  "FeaturePointsImpl",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pName */
};

emlrtRTEInfo gi_emlrtRTEI = { 216,     /* lineNo */
  13,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

emlrtRTEInfo hi_emlrtRTEI = { 12,      /* lineNo */
  37,                                  /* colNo */
  "validatenonempty",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatenonempty.m"/* pName */
};

emlrtRTEInfo ii_emlrtRTEI = { 13,      /* lineNo */
  37,                                  /* colNo */
  "validatenonnan",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatenonnan.m"/* pName */
};

emlrtRTEInfo ji_emlrtRTEI = { 15,      /* lineNo */
  37,                                  /* colNo */
  "validatesize",                      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatesize.m"/* pName */
};

emlrtRTEInfo li_emlrtRTEI = { 46,      /* lineNo */
  19,                                  /* colNo */
  "allOrAny",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\allOrAny.m"/* pName */
};

emlrtRTEInfo oi_emlrtRTEI = { 13,      /* lineNo */
  15,                                  /* colNo */
  "rdivide",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\rdivide.m"/* pName */
};

emlrtRTEInfo wi_emlrtRTEI = { 17,      /* lineNo */
  19,                                  /* colNo */
  "scalexpAlloc",                      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\scalexpAlloc.m"/* pName */
};

emlrtRTEInfo aj_emlrtRTEI = { 88,      /* lineNo */
  23,                                  /* colNo */
  "eml_mtimes_helper",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_helper.m"/* pName */
};

const real_T dv0[3] = { 0.0, 0.0, 1.0 };

const char_T cv0[15] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'p', 'm', 'a', 'x',
  's', 'i', 'z', 'e' };

emlrtRSInfo sm_emlrtRSI = { 41,        /* lineNo */
  "repmat",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pathName */
};

emlrtRSInfo um_emlrtRSI = { 53,        /* lineNo */
  "flt2str",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\flt2str.m"/* pathName */
};

/* End of code generation (visionRecovertformCodeGeneration_kernel_data.c) */
