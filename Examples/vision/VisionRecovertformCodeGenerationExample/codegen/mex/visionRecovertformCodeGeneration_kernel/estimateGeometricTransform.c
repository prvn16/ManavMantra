/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * estimateGeometricTransform.c
 *
 * Code generation for function 'estimateGeometricTransform'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include <string.h>
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "estimateGeometricTransform.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "isequal.h"
#include "det.h"
#include "validateattributes.h"
#include "any.h"
#include "eml_int_forloop_overflow_check.h"
#include "scalexpAlloc.h"
#include "warning.h"
#include "svd1.h"
#include "normalizePoints.h"
#include "msac.h"
#include "validatesize.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"
#include "blas.h"

/* Variable Definitions */
static emlrtRSInfo lf_emlrtRSI = { 117,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo mf_emlrtRSI = { 126,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo nf_emlrtRSI = { 128,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo of_emlrtRSI = { 137,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo pf_emlrtRSI = { 159,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo qf_emlrtRSI = { 168,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo rf_emlrtRSI = { 237,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo sf_emlrtRSI = { 10, /* lineNo */
  "checkAndConvertMatchedPoints",      /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkAndConvertMatchedPoints.m"/* pathName */
};

static emlrtRSInfo tf_emlrtRSI = { 12, /* lineNo */
  "checkAndConvertMatchedPoints",      /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkAndConvertMatchedPoints.m"/* pathName */
};

static emlrtRSInfo uf_emlrtRSI = { 32, /* lineNo */
  "checkAndConvertPoints",             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkAndConvertPoints.m"/* pathName */
};

static emlrtRSInfo vf_emlrtRSI = { 16, /* lineNo */
  "checkPoints",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkPoints.m"/* pathName */
};

static emlrtRSInfo wf_emlrtRSI = { 27, /* lineNo */
  "checkPoints",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkPoints.m"/* pathName */
};

static emlrtRSInfo xf_emlrtRSI = { 64, /* lineNo */
  "cat",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\cat.m"/* pathName */
};

static emlrtRSInfo pg_emlrtRSI = { 332,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo qg_emlrtRSI = { 337,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo rg_emlrtRSI = { 339,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo sg_emlrtRSI = { 341,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo tg_emlrtRSI = { 347,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo ug_emlrtRSI = { 397,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo vg_emlrtRSI = { 399,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo bh_emlrtRSI = { 52, /* lineNo */
  "eml_mtimes_helper",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_helper.m"/* pathName */
};

static emlrtRSInfo dh_emlrtRSI = { 114,/* lineNo */
  "mtimes",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\mtimes.m"/* pathName */
};

static emlrtRSInfo eh_emlrtRSI = { 118,/* lineNo */
  "mtimes",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\mtimes.m"/* pathName */
};

static emlrtRSInfo gh_emlrtRSI = { 12, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m"/* pathName */
};

static emlrtRSInfo hh_emlrtRSI = { 25, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m"/* pathName */
};

static emlrtRSInfo ih_emlrtRSI = { 33, /* lineNo */
  "svd",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m"/* pathName */
};

static emlrtRSInfo jh_emlrtRSI = { 28, /* lineNo */
  "anyNonFinite",                      /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\anyNonFinite.m"/* pathName */
};

static emlrtRSInfo kh_emlrtRSI = { 36, /* lineNo */
  "vAllOrAny",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\vAllOrAny.m"/* pathName */
};

static emlrtRSInfo lh_emlrtRSI = { 96, /* lineNo */
  "vAllOrAny",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\vAllOrAny.m"/* pathName */
};

static emlrtRSInfo hi_emlrtRSI = { 407,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo ji_emlrtRSI = { 48, /* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo ki_emlrtRSI = { 251,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo oi_emlrtRSI = { 416,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo pi_emlrtRSI = { 417,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo qi_emlrtRSI = { 419,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo ri_emlrtRSI = { 421,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo si_emlrtRSI = { 422,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRSInfo ti_emlrtRSI = { 12, /* lineNo */
  "hypot",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\hypot.m"/* pathName */
};

static emlrtRSInfo ui_emlrtRSI = { 203,/* lineNo */
  "applyBinaryScalarFunction",         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\applyBinaryScalarFunction.m"/* pathName */
};

static emlrtRSInfo vi_emlrtRSI = { 16, /* lineNo */
  "abs",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\abs.m"/* pathName */
};

static emlrtRSInfo wi_emlrtRSI = { 74, /* lineNo */
  "applyScalarFunction",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\applyScalarFunction.m"/* pathName */
};

static emlrtRTEInfo ie_emlrtRTEI = { 142,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo je_emlrtRTEI = { 126,/* lineNo */
  19,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo ke_emlrtRTEI = { 151,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo le_emlrtRTEI = { 152,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo me_emlrtRTEI = { 2,/* lineNo */
  7,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo ne_emlrtRTEI = { 148,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo oe_emlrtRTEI = { 149,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo pe_emlrtRTEI = { 128,/* lineNo */
  24,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo qe_emlrtRTEI = { 126,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo bf_emlrtRTEI = { 336,/* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo cf_emlrtRTEI = { 337,/* lineNo */
  13,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo df_emlrtRTEI = { 337,/* lineNo */
  33,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo ef_emlrtRTEI = { 338,/* lineNo */
  23,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo ff_emlrtRTEI = { 337,/* lineNo */
  32,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo gf_emlrtRTEI = { 339,/* lineNo */
  13,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo hf_emlrtRTEI = { 340,/* lineNo */
  23,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo if_emlrtRTEI = { 103,/* lineNo */
  1,                                   /* colNo */
  "cat",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pName */
};

static emlrtRTEInfo jf_emlrtRTEI = { 339,/* lineNo */
  32,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo kf_emlrtRTEI = { 32,/* lineNo */
  14,                                  /* colNo */
  "svd",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m"/* pName */
};

static emlrtRTEInfo lf_emlrtRTEI = { 329,/* lineNo */
  14,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo mf_emlrtRTEI = { 398,/* lineNo */
  37,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo nf_emlrtRTEI = { 400,/* lineNo */
  37,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo of_emlrtRTEI = { 402,/* lineNo */
  12,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo pf_emlrtRTEI = { 402,/* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo qf_emlrtRTEI = { 403,/* lineNo */
  12,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo rf_emlrtRTEI = { 403,/* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo sf_emlrtRTEI = { 393,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo gg_emlrtRTEI = { 112,/* lineNo */
  9,                                   /* colNo */
  "cat",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pName */
};

static emlrtRTEInfo hg_emlrtRTEI = { 412,/* lineNo */
  11,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo ig_emlrtRTEI = { 416,/* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo jg_emlrtRTEI = { 417,/* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo kg_emlrtRTEI = { 418,/* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo lg_emlrtRTEI = { 118,/* lineNo */
  13,                                  /* colNo */
  "mtimes",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\mtimes.m"/* pName */
};

static emlrtRTEInfo mg_emlrtRTEI = { 419,/* lineNo */
  21,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo ng_emlrtRTEI = { 419,/* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo og_emlrtRTEI = { 420,/* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo pg_emlrtRTEI = { 19,/* lineNo */
  24,                                  /* colNo */
  "scalexpAllocNoCheck",               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\scalexpAllocNoCheck.m"/* pName */
};

static emlrtRTEInfo qg_emlrtRTEI = { 421,/* lineNo */
  15,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo rg_emlrtRTEI = { 421,/* lineNo */
  26,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo sg_emlrtRTEI = { 12,/* lineNo */
  5,                                   /* colNo */
  "hypot",                             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\hypot.m"/* pName */
};

static emlrtRTEInfo tg_emlrtRTEI = { 16,/* lineNo */
  5,                                   /* colNo */
  "abs",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\abs.m"/* pName */
};

static emlrtRTEInfo ug_emlrtRTEI = { 422,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo vg_emlrtRTEI = { 411,/* lineNo */
  16,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo ri_emlrtRTEI = { 16,/* lineNo */
  37,                                  /* colNo */
  "checkAndConvertMatchedPoints",      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkAndConvertMatchedPoints.m"/* pName */
};

static emlrtRTEInfo si_emlrtRTEI = { 54,/* lineNo */
  27,                                  /* colNo */
  "cat",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\cat.m"/* pName */
};

static emlrtRTEInfo ti_emlrtRTEI = { 179,/* lineNo */
  5,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtRTEInfo ui_emlrtRTEI = { 182,/* lineNo */
  45,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtBCInfo jb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  148,                                 /* lineNo */
  36,                                  /* colNo */
  "",                                  /* aName */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo kb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  149,                                 /* lineNo */
  36,                                  /* colNo */
  "",                                  /* aName */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo lb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  168,                                 /* lineNo */
  32,                                  /* colNo */
  "",                                  /* aName */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo pb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  337,                                 /* lineNo */
  13,                                  /* colNo */
  "",                                  /* aName */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo qb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  337,                                 /* lineNo */
  17,                                  /* colNo */
  "",                                  /* aName */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  0                                    /* checkKind */
};

static emlrtECInfo h_emlrtECI = { -1,  /* nDims */
  337,                                 /* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtBCInfo rb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  339,                                 /* lineNo */
  13,                                  /* colNo */
  "",                                  /* aName */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo sb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  339,                                 /* lineNo */
  17,                                  /* colNo */
  "",                                  /* aName */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  0                                    /* checkKind */
};

static emlrtECInfo i_emlrtECI = { -1,  /* nDims */
  339,                                 /* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtDCInfo g_emlrtDCI = { 336, /* lineNo */
  21,                                  /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo h_emlrtDCI = { 336, /* lineNo */
  1,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  1                                    /* checkKind */
};

static emlrtRTEInfo yi_emlrtRTEI = { 83,/* lineNo */
  23,                                  /* colNo */
  "eml_mtimes_helper",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_helper.m"/* pName */
};

static emlrtECInfo j_emlrtECI = { 2,   /* nDims */
  420,                                 /* lineNo */
  9,                                   /* colNo */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pName */
};

static emlrtBCInfo tb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  422,                                 /* lineNo */
  1,                                   /* colNo */
  "",                                  /* aName */
  "estimateGeometricTransform",        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m",/* pName */
  0                                    /* checkKind */
};

/* Function Declarations */
static int32_T div_s32_floor(const emlrtStack *sp, int32_T numerator, int32_T
  denominator);
static void normalizePoints(const emlrtStack *sp, const emxArray_real32_T
  *points, emxArray_real32_T *samples1, emxArray_real32_T *samples2, real32_T
  normMatrix1[9], real32_T normMatrix2[9]);

/* Function Definitions */
static int32_T div_s32_floor(const emlrtStack *sp, int32_T numerator, int32_T
  denominator)
{
  int32_T quotient;
  uint32_T absNumerator;
  uint32_T absDenominator;
  boolean_T quotientNeedsNegation;
  uint32_T tempAbsQuotient;
  if (denominator == 0) {
    if (numerator >= 0) {
      quotient = MAX_int32_T;
    } else {
      quotient = MIN_int32_T;
    }

    emlrtDivisionByZeroErrorR2012b(NULL, sp);
  } else {
    if (numerator < 0) {
      absNumerator = ~(uint32_T)numerator + 1U;
    } else {
      absNumerator = (uint32_T)numerator;
    }

    if (denominator < 0) {
      absDenominator = ~(uint32_T)denominator + 1U;
    } else {
      absDenominator = (uint32_T)denominator;
    }

    quotientNeedsNegation = ((numerator < 0) != (denominator < 0));
    tempAbsQuotient = absNumerator / absDenominator;
    if (quotientNeedsNegation) {
      absNumerator %= absDenominator;
      if (absNumerator > 0U) {
        tempAbsQuotient++;
      }

      quotient = -(int32_T)tempAbsQuotient;
    } else {
      quotient = (int32_T)tempAbsQuotient;
    }
  }

  return quotient;
}

static void normalizePoints(const emlrtStack *sp, const emxArray_real32_T
  *points, emxArray_real32_T *samples1, emxArray_real32_T *samples2, real32_T
  normMatrix1[9], real32_T normMatrix2[9])
{
  emxArray_real32_T *b_points;
  int32_T loop_ub;
  int32_T i15;
  emxArray_real32_T *b_samples1;
  int32_T i16;
  emxArray_real32_T *b_samples2;
  emxArray_real32_T *c_samples1;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real32_T(sp, &b_points, 2, &mf_emlrtRTEI, true);
  loop_ub = points->size[0];
  i15 = b_points->size[0] * b_points->size[1];
  b_points->size[0] = 2;
  b_points->size[1] = loop_ub;
  emxEnsureCapacity_real32_T(sp, b_points, i15, &mf_emlrtRTEI);
  for (i15 = 0; i15 < loop_ub; i15++) {
    for (i16 = 0; i16 < 2; i16++) {
      b_points->data[i16 + b_points->size[0] * i15] = points->data[i15 +
        points->size[0] * i16];
    }
  }

  emxInit_real32_T(sp, &b_samples1, 2, &sf_emlrtRTEI, true);
  st.site = &ug_emlrtRSI;
  b_normalizePoints(&st, b_points, b_samples1, normMatrix1);
  loop_ub = points->size[0];
  i15 = b_points->size[0] * b_points->size[1];
  b_points->size[0] = 2;
  b_points->size[1] = loop_ub;
  emxEnsureCapacity_real32_T(sp, b_points, i15, &nf_emlrtRTEI);
  for (i15 = 0; i15 < loop_ub; i15++) {
    for (i16 = 0; i16 < 2; i16++) {
      b_points->data[i16 + b_points->size[0] * i15] = points->data[(i15 +
        points->size[0] * i16) + points->size[0] * points->size[1]];
    }
  }

  emxInit_real32_T(sp, &b_samples2, 2, &sf_emlrtRTEI, true);
  emxInit_real32_T(sp, &c_samples1, 2, &of_emlrtRTEI, true);
  st.site = &vg_emlrtRSI;
  b_normalizePoints(&st, b_points, b_samples2, normMatrix2);
  i15 = c_samples1->size[0] * c_samples1->size[1];
  c_samples1->size[0] = b_samples1->size[1];
  c_samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, c_samples1, i15, &of_emlrtRTEI);
  emxFree_real32_T(sp, &b_points);
  for (i15 = 0; i15 < 2; i15++) {
    loop_ub = b_samples1->size[1];
    for (i16 = 0; i16 < loop_ub; i16++) {
      c_samples1->data[i16 + c_samples1->size[0] * i15] = b_samples1->data[i15 +
        b_samples1->size[0] * i16];
    }
  }

  loop_ub = b_samples1->size[1];
  i15 = samples1->size[0] * samples1->size[1];
  samples1->size[0] = loop_ub;
  samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, samples1, i15, &pf_emlrtRTEI);
  emxFree_real32_T(sp, &b_samples1);
  for (i15 = 0; i15 < 2; i15++) {
    for (i16 = 0; i16 < loop_ub; i16++) {
      samples1->data[i16 + samples1->size[0] * i15] = c_samples1->data[i16 +
        loop_ub * i15];
    }
  }

  i15 = c_samples1->size[0] * c_samples1->size[1];
  c_samples1->size[0] = b_samples2->size[1];
  c_samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, c_samples1, i15, &qf_emlrtRTEI);
  for (i15 = 0; i15 < 2; i15++) {
    loop_ub = b_samples2->size[1];
    for (i16 = 0; i16 < loop_ub; i16++) {
      c_samples1->data[i16 + c_samples1->size[0] * i15] = b_samples2->data[i15 +
        b_samples2->size[0] * i16];
    }
  }

  loop_ub = b_samples2->size[1];
  i15 = samples2->size[0] * samples2->size[1];
  samples2->size[0] = loop_ub;
  samples2->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, samples2, i15, &rf_emlrtRTEI);
  emxFree_real32_T(sp, &b_samples2);
  for (i15 = 0; i15 < 2; i15++) {
    for (i16 = 0; i16 < loop_ub; i16++) {
      samples2->data[i16 + samples2->size[0] * i15] = c_samples1->data[i16 +
        loop_ub * i15];
    }
  }

  emxFree_real32_T(sp, &c_samples1);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void computeSimilarity(const emlrtStack *sp, const emxArray_real32_T *points,
  real32_T T[9])
{
  emxArray_real32_T *constraints;
  emxArray_real32_T *points1;
  emxArray_real32_T *points2;
  real32_T normMatrix1[9];
  real32_T normMatrix2[9];
  int32_T i14;
  real_T d0;
  int32_T r2;
  uint32_T u0;
  int32_T nx;
  int32_T r3;
  emxArray_int32_T *r15;
  int32_T loop_ub;
  emxArray_real32_T *varargin_1;
  emxArray_int8_T *varargin_4;
  boolean_T empty_non_axis_sizes;
  emxArray_real32_T *r16;
  int32_T r1;
  int32_T iv6[2];
  emxArray_real32_T *reshapes_f1;
  emxArray_int8_T *reshapes_f2;
  emxArray_int8_T *reshapes_f3;
  emxArray_real32_T *U1;
  real32_T s1_data[5];
  int32_T s1_size[1];
  real32_T V1[25];
  uint32_T uv0[2];
  static const int8_T iv7[3] = { 0, 0, 1 };

  real32_T B[9];
  real32_T maxval;
  real32_T a21;
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
  emxInit_real32_T(sp, &constraints, 2, &bf_emlrtRTEI, true);
  emxInit_real32_T(sp, &points1, 2, &lf_emlrtRTEI, true);
  emxInit_real32_T(sp, &points2, 2, &lf_emlrtRTEI, true);
  st.site = &pg_emlrtRSI;
  normalizePoints(&st, points, points1, points2, normMatrix1, normMatrix2);
  i14 = constraints->size[0] * constraints->size[1];
  d0 = 2.0 * (real_T)points1->size[0];
  if (d0 != (int32_T)d0) {
    emlrtIntegerCheckR2012b(d0, &g_emlrtDCI, sp);
  }

  constraints->size[0] = (int32_T)d0;
  constraints->size[1] = 5;
  emxEnsureCapacity_real32_T(sp, constraints, i14, &bf_emlrtRTEI);
  d0 = 2.0 * (real_T)points1->size[0];
  if (d0 != (int32_T)d0) {
    emlrtIntegerCheckR2012b(d0, &h_emlrtDCI, sp);
  }

  r2 = (int32_T)d0 * 5;
  for (i14 = 0; i14 < r2; i14++) {
    constraints->data[i14] = 0.0F;
  }

  u0 = (uint32_T)points1->size[0] << 1;
  if (1U > u0) {
    i14 = 1;
    r3 = -1;
  } else {
    nx = (int32_T)(2.0 * (real_T)points1->size[0]);
    if (!(1 <= nx)) {
      emlrtDynamicBoundsCheckR2012b(1, 1, nx, &pb_emlrtBCI, sp);
    }

    i14 = 2;
    nx = (int32_T)(2.0 * (real_T)points1->size[0]);
    r3 = (int32_T)u0;
    if (!((r3 >= 1) && (r3 <= nx))) {
      emlrtDynamicBoundsCheckR2012b(r3, 1, nx, &qb_emlrtBCI, sp);
    }

    r3--;
  }

  emxInit_int32_T(sp, &r15, 1, &lf_emlrtRTEI, true);
  loop_ub = r15->size[0];
  st.site = &qg_emlrtRSI;
  r15->size[0] = div_s32_floor(&st, r3, i14) + 1;
  emxEnsureCapacity_int32_T(sp, r15, loop_ub, &cf_emlrtRTEI);
  st.site = &qg_emlrtRSI;
  r2 = div_s32_floor(&st, r3, i14);
  for (r3 = 0; r3 <= r2; r3++) {
    r15->data[r3] = i14 * r3;
  }

  emxInit_real32_T1(sp, &varargin_1, 1, &df_emlrtRTEI, true);
  st.site = &qg_emlrtRSI;
  r2 = points1->size[0];
  i14 = varargin_1->size[0];
  varargin_1->size[0] = r2;
  emxEnsureCapacity_real32_T1(&st, varargin_1, i14, &df_emlrtRTEI);
  for (i14 = 0; i14 < r2; i14++) {
    varargin_1->data[i14] = -points1->data[i14 + points1->size[0]];
  }

  emxInit_int8_T(&st, &varargin_4, 1, &ef_emlrtRTEI, true);
  i14 = varargin_4->size[0];
  varargin_4->size[0] = points1->size[0];
  emxEnsureCapacity_int8_T(&st, varargin_4, i14, &ef_emlrtRTEI);
  r2 = points1->size[0];
  for (i14 = 0; i14 < r2; i14++) {
    varargin_4->data[i14] = -1;
  }

  b_st.site = &hf_emlrtRSI;
  c_st.site = &if_emlrtRSI;
  empty_non_axis_sizes = true;
  i14 = points1->size[0];
  if (i14 != varargin_1->size[0]) {
    empty_non_axis_sizes = false;
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if (points1->size[0] != varargin_1->size[0]) {
    empty_non_axis_sizes = false;
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if (varargin_4->size[0] != varargin_1->size[0]) {
    empty_non_axis_sizes = false;
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  i14 = points2->size[0];
  if (i14 != varargin_1->size[0]) {
    empty_non_axis_sizes = false;
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  emxInit_real32_T(&c_st, &r16, 2, &kf_emlrtRTEI, true);
  r2 = points1->size[0] - 1;
  nx = points1->size[0];
  r1 = points2->size[0] - 1;
  i14 = r16->size[0] * r16->size[1];
  r16->size[0] = varargin_1->size[0];
  r16->size[1] = 5;
  emxEnsureCapacity_real32_T(&b_st, r16, i14, &ff_emlrtRTEI);
  loop_ub = varargin_1->size[0];
  for (i14 = 0; i14 < loop_ub; i14++) {
    r16->data[i14] = varargin_1->data[i14];
  }

  for (i14 = 0; i14 <= r2; i14++) {
    r16->data[i14 + r16->size[0]] = points1->data[i14];
  }

  for (i14 = 0; i14 < nx; i14++) {
    r16->data[i14 + (r16->size[0] << 1)] = 0.0F;
  }

  r2 = varargin_4->size[0];
  for (i14 = 0; i14 < r2; i14++) {
    r16->data[i14 + r16->size[0] * 3] = varargin_4->data[i14];
  }

  emxFree_int8_T(&b_st, &varargin_4);
  for (i14 = 0; i14 <= r1; i14++) {
    r16->data[i14 + (r16->size[0] << 2)] = points2->data[i14 + points2->size[0]];
  }

  iv6[0] = r15->size[0];
  iv6[1] = 5;
  emlrtSubAssignSizeCheckR2012b(&iv6[0], 2, &(*(int32_T (*)[2])r16->size)[0], 2,
    &h_emlrtECI, sp);
  for (i14 = 0; i14 < 5; i14++) {
    r2 = r16->size[0];
    for (r3 = 0; r3 < r2; r3++) {
      constraints->data[r15->data[r3] + constraints->size[0] * i14] = r16->
        data[r3 + r16->size[0] * i14];
    }
  }

  u0 = (uint32_T)points1->size[0] << 1;
  if (2U > u0) {
    i14 = 1;
    r3 = 1;
    nx = 0;
  } else {
    i14 = constraints->size[0];
    if (!(2 <= i14)) {
      emlrtDynamicBoundsCheckR2012b(2, 1, i14, &rb_emlrtBCI, sp);
    }

    i14 = 2;
    r3 = 2;
    loop_ub = constraints->size[0];
    nx = (int32_T)u0;
    if (!((nx >= 1) && (nx <= loop_ub))) {
      emlrtDynamicBoundsCheckR2012b(nx, 1, loop_ub, &sb_emlrtBCI, sp);
    }
  }

  loop_ub = r15->size[0];
  st.site = &rg_emlrtRSI;
  r15->size[0] = div_s32_floor(&st, nx - i14, r3) + 1;
  emxEnsureCapacity_int32_T(sp, r15, loop_ub, &gf_emlrtRTEI);
  st.site = &rg_emlrtRSI;
  r2 = div_s32_floor(&st, nx - i14, r3);
  for (loop_ub = 0; loop_ub <= r2; loop_ub++) {
    r15->data[loop_ub] = (i14 + r3 * loop_ub) - 1;
  }

  st.site = &rg_emlrtRSI;
  r2 = points2->size[0];
  i14 = varargin_1->size[0];
  varargin_1->size[0] = r2;
  emxEnsureCapacity_real32_T1(&st, varargin_1, i14, &hf_emlrtRTEI);
  for (i14 = 0; i14 < r2; i14++) {
    varargin_1->data[i14] = -points2->data[i14];
  }

  emxFree_real32_T(&st, &points2);
  b_st.site = &fh_emlrtRSI;
  if (!(points1->size[0] == 0)) {
    nx = points1->size[0];
  } else if (!(points1->size[0] == 0)) {
    nx = points1->size[0];
  } else if (!(points1->size[0] == 0)) {
    nx = points1->size[0];
  } else if (!(varargin_1->size[0] == 0)) {
    nx = varargin_1->size[0];
  } else {
    nx = muIntScalarMax_sint32(points1->size[0], 0);
    if (points1->size[0] > nx) {
      nx = points1->size[0];
    }

    if (points1->size[0] > nx) {
      nx = points1->size[0];
    }
  }

  c_st.site = &if_emlrtRSI;
  if ((points1->size[0] == nx) || (points1->size[0] == 0)) {
    empty_non_axis_sizes = true;
  } else {
    empty_non_axis_sizes = false;
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if ((points1->size[0] == nx) || (points1->size[0] == 0)) {
  } else {
    empty_non_axis_sizes = false;
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if ((points1->size[0] == nx) || (points1->size[0] == 0)) {
  } else {
    empty_non_axis_sizes = false;
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  if ((varargin_1->size[0] == nx) || (varargin_1->size[0] == 0)) {
  } else {
    empty_non_axis_sizes = false;
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  empty_non_axis_sizes = (nx == 0);
  if (empty_non_axis_sizes || (!(points1->size[0] == 0))) {
    loop_ub = 2;
  } else {
    loop_ub = 0;
  }

  emxInit_real32_T(&b_st, &reshapes_f1, 2, &if_emlrtRTEI, true);
  i14 = reshapes_f1->size[0] * reshapes_f1->size[1];
  reshapes_f1->size[0] = nx;
  reshapes_f1->size[1] = loop_ub;
  emxEnsureCapacity_real32_T(&b_st, reshapes_f1, i14, &if_emlrtRTEI);
  r2 = nx * loop_ub;
  for (i14 = 0; i14 < r2; i14++) {
    reshapes_f1->data[i14] = points1->data[i14];
  }

  if (empty_non_axis_sizes || (!(points1->size[0] == 0))) {
    loop_ub = 1;
  } else {
    loop_ub = 0;
  }

  emxInit_int8_T1(&b_st, &reshapes_f2, 2, &if_emlrtRTEI, true);
  i14 = reshapes_f2->size[0] * reshapes_f2->size[1];
  reshapes_f2->size[0] = nx;
  reshapes_f2->size[1] = loop_ub;
  emxEnsureCapacity_int8_T1(&b_st, reshapes_f2, i14, &if_emlrtRTEI);
  r2 = nx * loop_ub;
  for (i14 = 0; i14 < r2; i14++) {
    reshapes_f2->data[i14] = 1;
  }

  if (empty_non_axis_sizes || (!(points1->size[0] == 0))) {
    loop_ub = 1;
  } else {
    loop_ub = 0;
  }

  emxFree_real32_T(&b_st, &points1);
  emxInit_int8_T1(&b_st, &reshapes_f3, 2, &if_emlrtRTEI, true);
  i14 = reshapes_f3->size[0] * reshapes_f3->size[1];
  reshapes_f3->size[0] = nx;
  reshapes_f3->size[1] = loop_ub;
  emxEnsureCapacity_int8_T1(&b_st, reshapes_f3, i14, &if_emlrtRTEI);
  r2 = nx * loop_ub;
  for (i14 = 0; i14 < r2; i14++) {
    reshapes_f3->data[i14] = 0;
  }

  if (empty_non_axis_sizes || (!(varargin_1->size[0] == 0))) {
    loop_ub = 1;
  } else {
    loop_ub = 0;
  }

  emxInit_real32_T(&b_st, &U1, 2, &lf_emlrtRTEI, true);
  i14 = U1->size[0] * U1->size[1];
  U1->size[0] = reshapes_f1->size[0];
  U1->size[1] = ((reshapes_f1->size[1] + reshapes_f2->size[1]) +
                 reshapes_f3->size[1]) + loop_ub;
  emxEnsureCapacity_real32_T(&b_st, U1, i14, &jf_emlrtRTEI);
  r2 = reshapes_f1->size[1];
  for (i14 = 0; i14 < r2; i14++) {
    r1 = reshapes_f1->size[0];
    for (r3 = 0; r3 < r1; r3++) {
      U1->data[r3 + U1->size[0] * i14] = reshapes_f1->data[r3 +
        reshapes_f1->size[0] * i14];
    }
  }

  r2 = reshapes_f2->size[1];
  for (i14 = 0; i14 < r2; i14++) {
    r1 = reshapes_f2->size[0];
    for (r3 = 0; r3 < r1; r3++) {
      U1->data[r3 + U1->size[0] * (i14 + reshapes_f1->size[1])] =
        reshapes_f2->data[r3 + reshapes_f2->size[0] * i14];
    }
  }

  r2 = reshapes_f3->size[1];
  for (i14 = 0; i14 < r2; i14++) {
    r1 = reshapes_f3->size[0];
    for (r3 = 0; r3 < r1; r3++) {
      U1->data[r3 + U1->size[0] * ((i14 + reshapes_f1->size[1]) +
        reshapes_f2->size[1])] = reshapes_f3->data[r3 + reshapes_f3->size[0] *
        i14];
    }
  }

  for (i14 = 0; i14 < loop_ub; i14++) {
    for (r3 = 0; r3 < nx; r3++) {
      U1->data[r3 + U1->size[0] * (((i14 + reshapes_f1->size[1]) +
        reshapes_f2->size[1]) + reshapes_f3->size[1])] = varargin_1->data[r3 +
        nx * i14];
    }
  }

  emxFree_int8_T(&b_st, &reshapes_f3);
  emxFree_int8_T(&b_st, &reshapes_f2);
  emxFree_real32_T(&b_st, &reshapes_f1);
  emxFree_real32_T(&b_st, &varargin_1);
  iv6[0] = r15->size[0];
  iv6[1] = 5;
  emlrtSubAssignSizeCheckR2012b(&iv6[0], 2, &(*(int32_T (*)[2])U1->size)[0], 2,
    &i_emlrtECI, sp);
  nx = r15->size[0];
  for (i14 = 0; i14 < 5; i14++) {
    for (r3 = 0; r3 < nx; r3++) {
      constraints->data[r15->data[r3] + constraints->size[0] * i14] = U1->
        data[r3 + nx * i14];
    }
  }

  emxFree_int32_T(sp, &r15);
  st.site = &sg_emlrtRSI;
  b_st.site = &gh_emlrtRSI;
  c_st.site = &jh_emlrtRSI;
  d_st.site = &kh_emlrtRSI;
  nx = constraints->size[0] * 5;
  empty_non_axis_sizes = true;
  e_st.site = &lh_emlrtRSI;
  if ((!(1 > nx)) && (nx > 2147483646)) {
    f_st.site = &mb_emlrtRSI;
    check_forloop_overflow_error(&f_st);
  }

  for (loop_ub = 0; loop_ub < nx; loop_ub++) {
    if (empty_non_axis_sizes && ((!muSingleScalarIsInf(constraints->data[loop_ub]))
         && (!muSingleScalarIsNaN(constraints->data[loop_ub])))) {
      empty_non_axis_sizes = true;
    } else {
      empty_non_axis_sizes = false;
    }
  }

  if (empty_non_axis_sizes) {
    b_st.site = &hh_emlrtRSI;
    svd(&b_st, constraints, U1, s1_data, s1_size, V1);
  } else {
    for (i14 = 0; i14 < 2; i14++) {
      uv0[i14] = (uint32_T)constraints->size[i14];
    }

    i14 = r16->size[0] * r16->size[1];
    r16->size[0] = (int32_T)uv0[0];
    r16->size[1] = 5;
    emxEnsureCapacity_real32_T(&st, r16, i14, &kf_emlrtRTEI);
    r2 = (int32_T)uv0[0] * 5;
    for (i14 = 0; i14 < r2; i14++) {
      r16->data[i14] = 0.0F;
    }

    b_st.site = &ih_emlrtRSI;
    svd(&b_st, r16, U1, s1_data, s1_size, V1);
    for (i14 = 0; i14 < 25; i14++) {
      V1[i14] = ((real32_T)rtNaN);
    }
  }

  emxFree_real32_T(&st, &U1);
  emxFree_real32_T(&st, &r16);
  emxFree_real32_T(&st, &constraints);
  T[3] = -V1[21] / V1[24];
  T[4] = V1[20] / V1[24];
  T[5] = V1[23] / V1[24];
  for (i14 = 0; i14 < 3; i14++) {
    T[i14] = V1[20 + i14] / V1[24];
    T[6 + i14] = iv7[i14];
  }

  st.site = &tg_emlrtRSI;
  b_st.site = &hi_emlrtRSI;
  for (i14 = 0; i14 < 3; i14++) {
    for (r3 = 0; r3 < 3; r3++) {
      B[r3 + 3 * i14] = normMatrix2[i14 + 3 * r3];
    }
  }

  c_st.site = &ii_emlrtRSI;
  d_st.site = &ji_emlrtRSI;
  r1 = 0;
  r2 = 1;
  r3 = 2;
  maxval = muSingleScalarAbs(B[0]);
  a21 = muSingleScalarAbs(B[1]);
  if (a21 > maxval) {
    maxval = a21;
    r1 = 1;
    r2 = 0;
  }

  if (muSingleScalarAbs(B[2]) > maxval) {
    r1 = 2;
    r2 = 1;
    r3 = 0;
  }

  B[r2] /= B[r1];
  B[r3] /= B[r1];
  B[3 + r2] -= B[r2] * B[3 + r1];
  B[3 + r3] -= B[r3] * B[3 + r1];
  B[6 + r2] -= B[r2] * B[6 + r1];
  B[6 + r3] -= B[r3] * B[6 + r1];
  if (muSingleScalarAbs(B[3 + r3]) > muSingleScalarAbs(B[3 + r2])) {
    nx = r2;
    r2 = r3;
    r3 = nx;
  }

  B[3 + r3] /= B[3 + r2];
  B[6 + r3] -= B[3 + r3] * B[6 + r2];
  if ((B[r1] == 0.0F) || (B[3 + r2] == 0.0F) || (B[6 + r3] == 0.0F)) {
    e_st.site = &ki_emlrtRSI;
    f_st.site = &li_emlrtRSI;
    warning(&f_st);
  }

  for (loop_ub = 0; loop_ub < 3; loop_ub++) {
    normMatrix2[loop_ub + 3 * r1] = T[loop_ub] / B[r1];
    normMatrix2[loop_ub + 3 * r2] = T[3 + loop_ub] - normMatrix2[loop_ub + 3 *
      r1] * B[3 + r1];
    normMatrix2[loop_ub + 3 * r3] = T[6 + loop_ub] - normMatrix2[loop_ub + 3 *
      r1] * B[6 + r1];
    normMatrix2[loop_ub + 3 * r2] /= B[3 + r2];
    normMatrix2[loop_ub + 3 * r3] -= normMatrix2[loop_ub + 3 * r2] * B[6 + r2];
    normMatrix2[loop_ub + 3 * r3] /= B[6 + r3];
    normMatrix2[loop_ub + 3 * r2] -= normMatrix2[loop_ub + 3 * r3] * B[3 + r3];
    normMatrix2[loop_ub + 3 * r1] -= normMatrix2[loop_ub + 3 * r3] * B[r3];
    normMatrix2[loop_ub + 3 * r1] -= normMatrix2[loop_ub + 3 * r2] * B[r2];
  }

  for (i14 = 0; i14 < 3; i14++) {
    for (r3 = 0; r3 < 3; r3++) {
      T[i14 + 3 * r3] = 0.0F;
      for (loop_ub = 0; loop_ub < 3; loop_ub++) {
        T[i14 + 3 * r3] += normMatrix1[loop_ub + 3 * i14] * normMatrix2[loop_ub
          + 3 * r3];
      }
    }
  }

  maxval = T[8];
  for (i14 = 0; i14 < 9; i14++) {
    T[i14] /= maxval;
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void estimateGeometricTransform(const emlrtStack *sp, const emxArray_real32_T
  *matchedPoints1, const emxArray_real32_T *matchedPoints2, real_T
  *tform_Dimensionality, real32_T tform_T_data[], int32_T tform_T_size[2],
  emxArray_real32_T *inlierPoints1, emxArray_real32_T *inlierPoints2)
{
  int32_T i11;
  boolean_T p;
  uint32_T varargin_1[2];
  boolean_T b_p;
  uint32_T varargin_2[2];
  int32_T k;
  boolean_T exitg1;
  int32_T status;
  int8_T failedMatrix[9];
  emxArray_boolean_T *inliers;
  emxArray_real32_T *points;
  uint32_T ysize_idx_0;
  int32_T loop_ub;
  int32_T tmatrix_size[2];
  real32_T tmatrix_data[9];
  int32_T b;
  int32_T iy;
  emxArray_int32_T *r12;
  emxArray_boolean_T *b_inliers;
  emxArray_int32_T *r13;
  real32_T A_data[6];
  real32_T b_varargin_1;
  boolean_T guard1 = false;
  boolean_T tmp_data[9];
  int32_T tmp_size[1];
  boolean_T b_tmp_data[9];
  static const int8_T iv5[3] = { 0, 0, 1 };

  emxArray_boolean_T c_tmp_data;
  boolean_T d_tmp_data[9];
  int32_T b_tmatrix_size[1];
  real32_T b_tmatrix_data[3];
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &lf_emlrtRSI;
  b_st.site = &rf_emlrtRSI;
  c_st.site = &sf_emlrtRSI;
  d_st.site = &uf_emlrtRSI;
  e_st.site = &vf_emlrtRSI;
  f_st.site = &wf_emlrtRSI;
  g_st.site = &dc_emlrtRSI;
  h_st.site = &q_emlrtRSI;
  if (!size_check(matchedPoints1)) {
    emlrtErrorWithMessageIdR2018a(&h_st, &ji_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:estimateGeometricTransform:incorrectSize", 3, 4, 14,
      "MATCHEDPOINTS1");
  }

  c_st.site = &tf_emlrtRSI;
  d_st.site = &uf_emlrtRSI;
  e_st.site = &vf_emlrtRSI;
  f_st.site = &wf_emlrtRSI;
  g_st.site = &dc_emlrtRSI;
  h_st.site = &q_emlrtRSI;
  if (!size_check(matchedPoints2)) {
    emlrtErrorWithMessageIdR2018a(&h_st, &ji_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:estimateGeometricTransform:incorrectSize", 3, 4, 14,
      "MATCHEDPOINTS2");
  }

  for (i11 = 0; i11 < 2; i11++) {
    varargin_1[i11] = (uint32_T)matchedPoints1->size[i11];
    varargin_2[i11] = (uint32_T)matchedPoints2->size[i11];
  }

  p = false;
  b_p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (!((int32_T)varargin_1[k] == (int32_T)varargin_2[k])) {
      b_p = false;
      exitg1 = true;
    } else {
      k++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ri_emlrtRTEI,
      "vision:points:numPtsMismatch", "vision:points:numPtsMismatch", 6, 4, 14,
      "MATCHEDPOINTS1", 4, 14, "MATCHEDPOINTS2");
  }

  status = (matchedPoints1->size[0] < 2);
  for (i11 = 0; i11 < 9; i11++) {
    failedMatrix[i11] = 0;
  }

  for (k = 0; k < 3; k++) {
    failedMatrix[k + 3 * k] = 1;
  }

  emxInit_boolean_T1(sp, &inliers, 2, &pe_emlrtRTEI, true);
  if (status == 0) {
    emxInit_real32_T2(sp, &points, 3, &qe_emlrtRTEI, true);
    st.site = &mf_emlrtRSI;
    ysize_idx_0 = (uint32_T)matchedPoints1->size[0];
    i11 = points->size[0] * points->size[1] * points->size[2];
    points->size[0] = (int32_T)ysize_idx_0;
    points->size[1] = 2;
    points->size[2] = 2;
    emxEnsureCapacity_real32_T2(&st, points, i11, &je_emlrtRTEI);
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 2)) {
      if (points->size[k] != matchedPoints1->size[k]) {
        emlrtErrorWithMessageIdR2018a(&st, &si_emlrtRTEI,
          "Coder:MATLAB:catenate_dimensionMismatch",
          "Coder:MATLAB:catenate_dimensionMismatch", 0);
        exitg1 = true;
      } else {
        k++;
      }
    }

    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 2)) {
      if (points->size[k] != matchedPoints2->size[k]) {
        emlrtErrorWithMessageIdR2018a(&st, &si_emlrtRTEI,
          "Coder:MATLAB:catenate_dimensionMismatch",
          "Coder:MATLAB:catenate_dimensionMismatch", 0);
        exitg1 = true;
      } else {
        k++;
      }
    }

    iy = -1;
    b = matchedPoints1->size[0] << 1;
    b_st.site = &xf_emlrtRSI;
    if ((!(1 > b)) && (b > 2147483646)) {
      c_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&c_st);
    }

    for (k = 1; k <= b; k++) {
      iy++;
      points->data[iy] = matchedPoints1->data[k - 1];
    }

    b = matchedPoints2->size[0] << 1;
    b_st.site = &xf_emlrtRSI;
    if ((!(1 > b)) && (b > 2147483646)) {
      c_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&c_st);
    }

    for (k = 1; k <= b; k++) {
      iy++;
      points->data[iy] = matchedPoints2->data[k - 1];
    }

    emxInit_boolean_T(&st, &b_inliers, 1, &me_emlrtRTEI, true);
    st.site = &nf_emlrtRSI;
    msac(&st, points, &p, tmatrix_data, tmatrix_size, b_inliers);
    i11 = inliers->size[0] * inliers->size[1];
    inliers->size[0] = b_inliers->size[0];
    inliers->size[1] = 1;
    emxEnsureCapacity_boolean_T1(sp, inliers, i11, &pe_emlrtRTEI);
    loop_ub = b_inliers->size[0];
    emxFree_real32_T(sp, &points);
    for (i11 = 0; i11 < loop_ub; i11++) {
      inliers->data[i11] = b_inliers->data[i11];
    }

    emxFree_boolean_T(sp, &b_inliers);
    if (!p) {
      status = 2;
    }

    st.site = &of_emlrtRSI;
    b_varargin_1 = det(&st, tmatrix_data, tmatrix_size);
    p = false;
    b_p = true;
    if (!(b_varargin_1 == 0.0F)) {
      b_p = false;
    }

    if (b_p) {
      p = true;
    }

    guard1 = false;
    if (p) {
      guard1 = true;
    } else {
      k = tmatrix_size[0] * tmatrix_size[1];
      loop_ub = tmatrix_size[0] * tmatrix_size[1];
      for (i11 = 0; i11 < loop_ub; i11++) {
        tmp_data[i11] = muSingleScalarIsInf(tmatrix_data[i11]);
      }

      loop_ub = tmatrix_size[0] * tmatrix_size[1];
      for (i11 = 0; i11 < loop_ub; i11++) {
        b_tmp_data[i11] = muSingleScalarIsNaN(tmatrix_data[i11]);
      }

      tmp_size[0] = k;
      for (i11 = 0; i11 < k; i11++) {
        d_tmp_data[i11] = !((!tmp_data[i11]) && (!b_tmp_data[i11]));
      }

      c_tmp_data.data = (boolean_T *)&d_tmp_data;
      c_tmp_data.size = (int32_T *)&tmp_size;
      c_tmp_data.allocatedSize = 9;
      c_tmp_data.numDimensions = 1;
      c_tmp_data.canFreeData = false;
      st.site = &of_emlrtRSI;
      if (any(&st, &c_tmp_data)) {
        guard1 = true;
      }
    }

    if (guard1) {
      status = 2;
      tmatrix_size[0] = 3;
      tmatrix_size[1] = 3;
      for (i11 = 0; i11 < 9; i11++) {
        tmatrix_data[i11] = failedMatrix[i11];
      }
    }
  } else {
    i11 = inliers->size[0] * inliers->size[1];
    inliers->size[0] = matchedPoints1->size[0];
    inliers->size[1] = matchedPoints1->size[0];
    emxEnsureCapacity_boolean_T1(sp, inliers, i11, &ie_emlrtRTEI);
    loop_ub = matchedPoints1->size[0] * matchedPoints1->size[0];
    for (i11 = 0; i11 < loop_ub; i11++) {
      inliers->data[i11] = false;
    }

    tmatrix_size[0] = 3;
    tmatrix_size[1] = 3;
    for (i11 = 0; i11 < 9; i11++) {
      tmatrix_data[i11] = failedMatrix[i11];
    }
  }

  if (status == 0) {
    b = inliers->size[0] * inliers->size[1] - 1;
    k = 0;
    for (iy = 0; iy <= b; iy++) {
      if (inliers->data[iy]) {
        k++;
      }
    }

    emxInit_int32_T(sp, &r12, 1, &me_emlrtRTEI, true);
    i11 = r12->size[0];
    r12->size[0] = k;
    emxEnsureCapacity_int32_T(sp, r12, i11, &me_emlrtRTEI);
    k = 0;
    for (iy = 0; iy <= b; iy++) {
      if (inliers->data[iy]) {
        r12->data[k] = iy + 1;
        k++;
      }
    }

    k = matchedPoints1->size[0];
    i11 = inlierPoints1->size[0] * inlierPoints1->size[1];
    inlierPoints1->size[0] = r12->size[0];
    inlierPoints1->size[1] = 2;
    emxEnsureCapacity_real32_T(sp, inlierPoints1, i11, &ne_emlrtRTEI);
    for (i11 = 0; i11 < 2; i11++) {
      loop_ub = r12->size[0];
      for (b = 0; b < loop_ub; b++) {
        iy = r12->data[b];
        if (!((iy >= 1) && (iy <= k))) {
          emlrtDynamicBoundsCheckR2012b(iy, 1, k, &jb_emlrtBCI, sp);
        }

        inlierPoints1->data[b + inlierPoints1->size[0] * i11] =
          matchedPoints1->data[(iy + matchedPoints1->size[0] * i11) - 1];
      }
    }

    emxFree_int32_T(sp, &r12);
    b = inliers->size[0] * inliers->size[1] - 1;
    k = 0;
    for (iy = 0; iy <= b; iy++) {
      if (inliers->data[iy]) {
        k++;
      }
    }

    emxInit_int32_T(sp, &r13, 1, &me_emlrtRTEI, true);
    i11 = r13->size[0];
    r13->size[0] = k;
    emxEnsureCapacity_int32_T(sp, r13, i11, &me_emlrtRTEI);
    k = 0;
    for (iy = 0; iy <= b; iy++) {
      if (inliers->data[iy]) {
        r13->data[k] = iy + 1;
        k++;
      }
    }

    k = matchedPoints2->size[0];
    i11 = inlierPoints2->size[0] * inlierPoints2->size[1];
    inlierPoints2->size[0] = r13->size[0];
    inlierPoints2->size[1] = 2;
    emxEnsureCapacity_real32_T(sp, inlierPoints2, i11, &oe_emlrtRTEI);
    for (i11 = 0; i11 < 2; i11++) {
      loop_ub = r13->size[0];
      for (b = 0; b < loop_ub; b++) {
        iy = r13->data[b];
        if (!((iy >= 1) && (iy <= k))) {
          emlrtDynamicBoundsCheckR2012b(iy, 1, k, &kb_emlrtBCI, sp);
        }

        inlierPoints2->data[b + inlierPoints2->size[0] * i11] =
          matchedPoints2->data[(iy + matchedPoints2->size[0] * i11) - 1];
      }
    }

    emxFree_int32_T(sp, &r13);
  } else {
    i11 = inlierPoints1->size[0] * inlierPoints1->size[1];
    inlierPoints1->size[0] = 0;
    inlierPoints1->size[1] = 0;
    emxEnsureCapacity_real32_T(sp, inlierPoints1, i11, &ke_emlrtRTEI);
    i11 = inlierPoints2->size[0] * inlierPoints2->size[1];
    inlierPoints2->size[0] = 0;
    inlierPoints2->size[1] = 0;
    emxEnsureCapacity_real32_T(sp, inlierPoints2, i11, &le_emlrtRTEI);
    tmatrix_size[0] = 3;
    tmatrix_size[1] = 3;
    for (i11 = 0; i11 < 9; i11++) {
      tmatrix_data[i11] = failedMatrix[i11];
    }
  }

  emxFree_boolean_T(sp, &inliers);
  st.site = &pf_emlrtRSI;
  if (status == 1) {
    emlrtErrorWithMessageIdR2018a(&st, &ti_emlrtRTEI,
      "vision:points:notEnoughMatchedPts", "vision:points:notEnoughMatchedPts",
      8, 4, 14, "matchedPoints1", 4, 14, "matchedPoints2", 6, 2.0);
  }

  if (status == 2) {
    emlrtErrorWithMessageIdR2018a(&st, &ui_emlrtRTEI,
      "vision:points:notEnoughInlierMatches",
      "vision:points:notEnoughInlierMatches", 6, 4, 14, "matchedPoints1", 4, 14,
      "matchedPoints2");
  }

  st.site = &qf_emlrtRSI;
  loop_ub = tmatrix_size[0];
  for (i11 = 0; i11 < 2; i11++) {
    for (b = 0; b < loop_ub; b++) {
      iy = 1 + i11;
      if (!(iy <= tmatrix_size[1])) {
        emlrtDynamicBoundsCheckR2012b(iy, 1, tmatrix_size[1], &lb_emlrtBCI, &st);
      }

      A_data[b + loop_ub * i11] = tmatrix_data[b + tmatrix_size[0] * (iy - 1)];
    }
  }

  b_st.site = &fk_emlrtRSI;
  varargin_1[0] = (uint32_T)tmatrix_size[0];
  varargin_1[1] = 2U;
  p = false;
  b_p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (!((int8_T)varargin_1[k] == 3 - k)) {
      b_p = false;
      exitg1 = true;
    } else {
      k++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (p) {
    c_st.site = &gk_emlrtRSI;
    d_st.site = &fh_emlrtRSI;
    e_st.site = &if_emlrtRSI;
    if ((tmatrix_size[0] == 3) || (tmatrix_size[0] == 0)) {
    } else {
      emlrtErrorWithMessageIdR2018a(&e_st, &ai_emlrtRTEI,
        "MATLAB:catenate:matrixDimensionMismatch",
        "MATLAB:catenate:matrixDimensionMismatch", 0);
    }

    if (!(tmatrix_size[0] == 0)) {
      k = 2;
    } else {
      k = 0;
    }

    tmatrix_size[0] = 3;
    tmatrix_size[1] = k + 1;
    for (i11 = 0; i11 < k; i11++) {
      for (b = 0; b < 3; b++) {
        tmatrix_data[b + 3 * i11] = A_data[b + 3 * i11];
      }
    }

    for (i11 = 0; i11 < 3; i11++) {
      tmatrix_data[i11 + 3 * k] = iv5[i11];
    }
  } else {
    tmatrix_size[1] = 2;
    loop_ub <<= 1;
    if (0 <= loop_ub - 1) {
      memcpy(&tmatrix_data[0], &A_data[0], (uint32_T)(loop_ub * (int32_T)sizeof
              (real32_T)));
    }
  }

  c_st.site = &hk_emlrtRSI;
  validateattributes(&c_st, tmatrix_data, tmatrix_size);
  c_st.site = &ik_emlrtRSI;
  b_varargin_1 = det(&c_st, tmatrix_data, tmatrix_size);
  p = false;
  b_p = true;
  if (!(b_varargin_1 == 0.0F)) {
    b_p = false;
  }

  if (b_p) {
    p = true;
  }

  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &xh_emlrtRTEI,
      "images:geotrans:singularTransformationMatrix",
      "images:geotrans:singularTransformationMatrix", 0);
  }

  if (!(3 <= tmatrix_size[1])) {
    emlrtDynamicBoundsCheckR2012b(3, 1, tmatrix_size[1], &d_emlrtBCI, &b_st);
  }

  loop_ub = tmatrix_size[0];
  b_tmatrix_size[0] = tmatrix_size[0];
  for (i11 = 0; i11 < loop_ub; i11++) {
    b_tmatrix_data[i11] = tmatrix_data[i11 + (tmatrix_size[0] << 1)];
  }

  if (!isequal(b_tmatrix_data, b_tmatrix_size, dv0)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &yh_emlrtRTEI,
      "images:geotrans:invalidAffineMatrix",
      "images:geotrans:invalidAffineMatrix", 0);
  }

  tform_T_size[0] = tmatrix_size[0];
  tform_T_size[1] = tmatrix_size[1];
  loop_ub = tmatrix_size[0] * tmatrix_size[1];
  if (0 <= loop_ub - 1) {
    memcpy(&tform_T_data[0], &tmatrix_data[0], (uint32_T)(loop_ub * (int32_T)
            sizeof(real32_T)));
  }

  *tform_Dimensionality = 2.0;
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void evaluateTForm(const emlrtStack *sp, const real32_T tform[9], const
                   emxArray_real32_T *points, emxArray_real32_T *dis)
{
  int32_T i19;
  int32_T result;
  boolean_T empty_non_axis_sizes;
  int32_T b_result;
  int32_T c_result;
  cell_wrap_26 reshapes[2];
  int32_T loop_ub;
  emxArray_real32_T *b_points;
  emxArray_real32_T *pt1h;
  int32_T i20;
  emxArray_real32_T *b_pt1h;
  char_T TRANSA;
  char_T TRANSB;
  real32_T alpha1;
  real32_T beta1;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  emxArray_real32_T *w;
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  emxArray_real32_T *delta;
  uint32_T varargin_1[2];
  uint32_T varargin_2[2];
  boolean_T p;
  boolean_T exitg1;
  emxArray_real32_T *pt;
  int32_T iv11[2];
  int32_T b_pt[2];
  emxArray_real32_T *z;
  emxArray_real32_T *b_delta;
  emxArray_real32_T *c_delta;
  emxArray_boolean_T *r18;
  emxArray_int32_T *r19;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &oi_emlrtRSI;
  b_st.site = &fh_emlrtRSI;
  i19 = points->size[0];
  if (!(i19 == 0)) {
    result = points->size[0];
  } else {
    i19 = points->size[0];
    if (!(i19 == 0)) {
      result = points->size[0];
    } else {
      i19 = points->size[0];
      if (i19 > 0) {
        result = points->size[0];
      } else {
        result = 0;
      }

      i19 = points->size[0];
      if (i19 > result) {
        result = points->size[0];
      }
    }
  }

  c_st.site = &if_emlrtRSI;
  i19 = points->size[0];
  if (i19 == result) {
    empty_non_axis_sizes = true;
  } else {
    i19 = points->size[0];
    if (i19 == 0) {
      empty_non_axis_sizes = true;
    } else {
      empty_non_axis_sizes = false;
      emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
        "MATLAB:catenate:matrixDimensionMismatch",
        "MATLAB:catenate:matrixDimensionMismatch", 0);
    }
  }

  i19 = points->size[0];
  if (i19 == result) {
  } else {
    i19 = points->size[0];
    if (i19 == 0) {
    } else {
      empty_non_axis_sizes = false;
    }
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ai_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  empty_non_axis_sizes = (result == 0);
  if (empty_non_axis_sizes) {
    b_result = 2;
  } else {
    i19 = points->size[0];
    if (!(i19 == 0)) {
      b_result = 2;
    } else {
      b_result = 0;
    }
  }

  if (empty_non_axis_sizes) {
    c_result = 1;
  } else {
    i19 = points->size[0];
    if (!(i19 == 0)) {
      c_result = 1;
    } else {
      c_result = 0;
    }
  }

  emxInitMatrix_cell_wrap_26(&b_st, reshapes, &if_emlrtRTEI, true);
  i19 = reshapes[1].f1->size[0] * reshapes[1].f1->size[1];
  reshapes[1].f1->size[0] = result;
  reshapes[1].f1->size[1] = c_result;
  emxEnsureCapacity_real32_T(&b_st, reshapes[1].f1, i19, &gg_emlrtRTEI);
  loop_ub = result * c_result;
  for (i19 = 0; i19 < loop_ub; i19++) {
    reshapes[1].f1->data[i19] = 1.0F;
  }

  emxInit_real32_T(&b_st, &b_points, 2, &hg_emlrtRTEI, true);
  loop_ub = points->size[0];
  i19 = b_points->size[0] * b_points->size[1];
  b_points->size[0] = loop_ub;
  b_points->size[1] = 2;
  emxEnsureCapacity_real32_T(&b_st, b_points, i19, &hg_emlrtRTEI);
  for (i19 = 0; i19 < 2; i19++) {
    for (i20 = 0; i20 < loop_ub; i20++) {
      b_points->data[i20 + b_points->size[0] * i19] = points->data[i20 +
        points->size[0] * i19];
    }
  }

  emxInit_real32_T(&b_st, &pt1h, 2, &ig_emlrtRTEI, true);
  i19 = pt1h->size[0] * pt1h->size[1];
  pt1h->size[0] = result;
  pt1h->size[1] = b_result + reshapes[1].f1->size[1];
  emxEnsureCapacity_real32_T(&b_st, pt1h, i19, &ig_emlrtRTEI);
  for (i19 = 0; i19 < b_result; i19++) {
    for (i20 = 0; i20 < result; i20++) {
      pt1h->data[i20 + pt1h->size[0] * i19] = b_points->data[i20 + result * i19];
    }
  }

  emxFree_real32_T(&b_st, &b_points);
  loop_ub = reshapes[1].f1->size[1];
  for (i19 = 0; i19 < loop_ub; i19++) {
    c_result = reshapes[1].f1->size[0];
    for (i20 = 0; i20 < c_result; i20++) {
      pt1h->data[i20 + pt1h->size[0] * (i19 + b_result)] = reshapes[1].f1->
        data[i20 + reshapes[1].f1->size[0] * i19];
    }
  }

  emxFreeMatrix_cell_wrap_26(&b_st, reshapes);
  st.site = &pi_emlrtRSI;
  b_st.site = &ch_emlrtRSI;
  if (!(pt1h->size[1] == 3)) {
    if ((pt1h->size[0] == 1) && (pt1h->size[1] == 1)) {
      emlrtErrorWithMessageIdR2018a(&b_st, &yi_emlrtRTEI,
        "Coder:toolbox:mtimes_noDynamicScalarExpansion",
        "Coder:toolbox:mtimes_noDynamicScalarExpansion", 0);
    } else {
      emlrtErrorWithMessageIdR2018a(&b_st, &aj_emlrtRTEI,
        "Coder:MATLAB:innerdim", "Coder:MATLAB:innerdim", 0);
    }
  }

  b_st.site = &bh_emlrtRSI;
  emxInit_real32_T(&b_st, &b_pt1h, 2, &ig_emlrtRTEI, true);
  if (pt1h->size[0] == 0) {
    i19 = b_pt1h->size[0] * b_pt1h->size[1];
    b_pt1h->size[0] = pt1h->size[0];
    b_pt1h->size[1] = 3;
    emxEnsureCapacity_real32_T(&b_st, b_pt1h, i19, &jg_emlrtRTEI);
    loop_ub = pt1h->size[0] * 3;
    for (i19 = 0; i19 < loop_ub; i19++) {
      b_pt1h->data[i19] = 0.0F;
    }
  } else {
    c_st.site = &dh_emlrtRSI;
    c_st.site = &eh_emlrtRSI;
    TRANSA = 'N';
    TRANSB = 'N';
    alpha1 = 1.0F;
    beta1 = 0.0F;
    m_t = (ptrdiff_t)pt1h->size[0];
    n_t = (ptrdiff_t)3;
    k_t = (ptrdiff_t)3;
    lda_t = (ptrdiff_t)pt1h->size[0];
    ldb_t = (ptrdiff_t)3;
    ldc_t = (ptrdiff_t)pt1h->size[0];
    i19 = b_pt1h->size[0] * b_pt1h->size[1];
    b_pt1h->size[0] = pt1h->size[0];
    b_pt1h->size[1] = 3;
    emxEnsureCapacity_real32_T(&c_st, b_pt1h, i19, &lg_emlrtRTEI);
    sgemm(&TRANSA, &TRANSB, &m_t, &n_t, &k_t, &alpha1, &pt1h->data[0], &lda_t,
          &tform[0], &ldb_t, &beta1, &b_pt1h->data[0], &ldc_t);
  }

  emxFree_real32_T(&b_st, &pt1h);
  emxInit_real32_T1(&b_st, &w, 1, &kg_emlrtRTEI, true);
  loop_ub = b_pt1h->size[0];
  i19 = w->size[0];
  w->size[0] = loop_ub;
  emxEnsureCapacity_real32_T1(sp, w, i19, &kg_emlrtRTEI);
  for (i19 = 0; i19 < loop_ub; i19++) {
    w->data[i19] = b_pt1h->data[i19 + (b_pt1h->size[0] << 1)];
  }

  emxInit_real32_T(sp, &delta, 2, &og_emlrtRTEI, true);
  st.site = &qi_emlrtRSI;
  b_st.site = &hf_emlrtRSI;
  c_st.site = &if_emlrtRSI;
  i19 = delta->size[0] * delta->size[1];
  delta->size[0] = w->size[0];
  delta->size[1] = 2;
  emxEnsureCapacity_real32_T(&b_st, delta, i19, &mg_emlrtRTEI);
  loop_ub = w->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    delta->data[i19] = w->data[i19];
  }

  loop_ub = w->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    delta->data[i19 + delta->size[0]] = w->data[i19];
  }

  st.site = &qi_emlrtRSI;
  i19 = b_pt1h->size[0];
  varargin_1[0] = (uint32_T)i19;
  varargin_1[1] = 2U;
  for (i19 = 0; i19 < 2; i19++) {
    varargin_2[i19] = (uint32_T)delta->size[i19];
  }

  empty_non_axis_sizes = false;
  p = true;
  c_result = 0;
  exitg1 = false;
  while ((!exitg1) && (c_result < 2)) {
    if (!((int32_T)varargin_1[c_result] == (int32_T)varargin_2[c_result])) {
      p = false;
      exitg1 = true;
    } else {
      c_result++;
    }
  }

  if (p) {
    empty_non_axis_sizes = true;
  }

  if (!empty_non_axis_sizes) {
    emlrtErrorWithMessageIdR2018a(&st, &oi_emlrtRTEI, "MATLAB:dimagree",
      "MATLAB:dimagree", 0);
  }

  emxInit_real32_T(&st, &pt, 2, &ng_emlrtRTEI, true);
  loop_ub = b_pt1h->size[0];
  i19 = pt->size[0] * pt->size[1];
  pt->size[0] = loop_ub;
  pt->size[1] = 2;
  emxEnsureCapacity_real32_T(&st, pt, i19, &ng_emlrtRTEI);
  for (i19 = 0; i19 < 2; i19++) {
    for (i20 = 0; i20 < loop_ub; i20++) {
      pt->data[i20 + pt->size[0] * i19] = b_pt1h->data[i20 + b_pt1h->size[0] *
        i19] / delta->data[i20 + delta->size[0] * i19];
    }
  }

  i19 = points->size[0];
  for (i20 = 0; i20 < 2; i20++) {
    b_pt[i20] = pt->size[i20];
  }

  iv11[0] = i19;
  iv11[1] = 2;
  if ((b_pt[0] != iv11[0]) || (b_pt[1] != 2)) {
    emlrtSizeEqCheckNDR2012b(&b_pt[0], &iv11[0], &j_emlrtECI, sp);
  }

  i19 = delta->size[0] * delta->size[1];
  delta->size[0] = pt->size[0];
  delta->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, delta, i19, &og_emlrtRTEI);
  for (i19 = 0; i19 < 2; i19++) {
    loop_ub = pt->size[0];
    for (i20 = 0; i20 < loop_ub; i20++) {
      delta->data[i20 + delta->size[0] * i19] = pt->data[i20 + pt->size[0] * i19]
        - points->data[(i20 + points->size[0] * i19) + points->size[0] *
        points->size[1]];
    }
  }

  emxFree_real32_T(sp, &pt);
  emxInit_real32_T1(sp, &z, 1, &pg_emlrtRTEI, true);
  st.site = &ri_emlrtRSI;
  b_st.site = &ti_emlrtRSI;
  c_st.site = &sc_emlrtRSI;
  result = delta->size[0];
  emxInit_real32_T1(&c_st, &b_delta, 1, &qg_emlrtRTEI, true);
  i19 = z->size[0];
  z->size[0] = result;
  emxEnsureCapacity_real32_T1(&c_st, z, i19, &pg_emlrtRTEI);
  i19 = w->size[0];
  w->size[0] = result;
  emxEnsureCapacity_real32_T1(&c_st, w, i19, &uf_emlrtRTEI);
  loop_ub = delta->size[0];
  i19 = b_delta->size[0];
  b_delta->size[0] = loop_ub;
  emxEnsureCapacity_real32_T1(&c_st, b_delta, i19, &qg_emlrtRTEI);
  for (i19 = 0; i19 < loop_ub; i19++) {
    b_delta->data[i19] = delta->data[i19];
  }

  emxInit_real32_T1(&c_st, &c_delta, 1, &rg_emlrtRTEI, true);
  loop_ub = delta->size[0];
  i19 = c_delta->size[0];
  c_delta->size[0] = loop_ub;
  emxEnsureCapacity_real32_T1(&c_st, c_delta, i19, &rg_emlrtRTEI);
  for (i19 = 0; i19 < loop_ub; i19++) {
    c_delta->data[i19] = delta->data[i19 + delta->size[0]];
  }

  if (!c_dimagree(w, b_delta, c_delta)) {
    emlrtErrorWithMessageIdR2018a(&c_st, &wi_emlrtRTEI, "MATLAB:dimagree",
      "MATLAB:dimagree", 0);
  }

  emxFree_real32_T(&c_st, &c_delta);
  emxFree_real32_T(&c_st, &b_delta);
  i19 = dis->size[0];
  dis->size[0] = result;
  emxEnsureCapacity_real32_T1(&b_st, dis, i19, &sg_emlrtRTEI);
  c_st.site = &tc_emlrtRSI;
  d_st.site = &ui_emlrtRSI;
  empty_non_axis_sizes = ((!(1 > z->size[0])) && (z->size[0] > 2147483646));
  emxFree_real32_T(&d_st, &z);
  if (empty_non_axis_sizes) {
    e_st.site = &mb_emlrtRSI;
    check_forloop_overflow_error(&e_st);
  }

  for (c_result = 0; c_result < result; c_result++) {
    dis->data[c_result] = muSingleScalarHypot(delta->data[c_result], delta->
      data[c_result + delta->size[0]]);
  }

  emxFree_real32_T(&c_st, &delta);
  st.site = &si_emlrtRSI;
  b_st.site = &vi_emlrtRSI;
  i19 = b_pt1h->size[0];
  i20 = b_pt1h->size[0];
  c_result = w->size[0];
  w->size[0] = i20;
  emxEnsureCapacity_real32_T1(&b_st, w, c_result, &tg_emlrtRTEI);
  c_st.site = &wi_emlrtRSI;
  i20 = b_pt1h->size[0];
  if (1 > i20) {
    empty_non_axis_sizes = false;
  } else {
    i20 = b_pt1h->size[0];
    empty_non_axis_sizes = (i20 > 2147483646);
  }

  if (empty_non_axis_sizes) {
    d_st.site = &mb_emlrtRSI;
    check_forloop_overflow_error(&d_st);
  }

  for (c_result = 0; c_result < i19; c_result++) {
    w->data[c_result] = muSingleScalarAbs(b_pt1h->data[c_result + (b_pt1h->size
      [0] << 1)]);
  }

  emxFree_real32_T(&b_st, &b_pt1h);
  emxInit_boolean_T(&b_st, &r18, 1, &vg_emlrtRTEI, true);
  i19 = r18->size[0];
  r18->size[0] = w->size[0];
  emxEnsureCapacity_boolean_T(sp, r18, i19, &ug_emlrtRTEI);
  loop_ub = w->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    r18->data[i19] = (w->data[i19] < 1.1920929E-7F);
  }

  emxFree_real32_T(sp, &w);
  b_result = r18->size[0] - 1;
  c_result = 0;
  for (result = 0; result <= b_result; result++) {
    if (r18->data[result]) {
      c_result++;
    }
  }

  emxInit_int32_T(sp, &r19, 1, &vg_emlrtRTEI, true);
  i19 = r19->size[0];
  r19->size[0] = c_result;
  emxEnsureCapacity_int32_T(sp, r19, i19, &vg_emlrtRTEI);
  c_result = 0;
  for (result = 0; result <= b_result; result++) {
    if (r18->data[result]) {
      r19->data[c_result] = result + 1;
      c_result++;
    }
  }

  emxFree_boolean_T(sp, &r18);
  loop_ub = r19->size[0] - 1;
  c_result = dis->size[0];
  for (i19 = 0; i19 <= loop_ub; i19++) {
    i20 = r19->data[i19];
    if (!((i20 >= 1) && (i20 <= c_result))) {
      emlrtDynamicBoundsCheckR2012b(i20, 1, c_result, &tb_emlrtBCI, sp);
    }

    dis->data[i20 - 1] = ((real32_T)rtInf);
  }

  emxFree_int32_T(sp, &r19);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (estimateGeometricTransform.c) */
