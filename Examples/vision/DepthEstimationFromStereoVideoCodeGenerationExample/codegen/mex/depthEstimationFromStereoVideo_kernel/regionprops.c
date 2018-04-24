/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * regionprops.c
 *
 * Code generation for function 'regionprops'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include <string.h>
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "regionprops.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "matlabCodegenHandle.h"
#include "eml_int_forloop_overflow_check.h"
#include "ind2sub.h"
#include "assertValidSizeArg.h"
#include "bwconncomp.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Type Definitions */
#ifndef typedef_struct_T
#define typedef_struct_T

typedef struct {
  boolean_T Area;
  boolean_T Centroid;
  boolean_T BoundingBox;
  boolean_T MajorAxisLength;
  boolean_T MinorAxisLength;
  boolean_T Eccentricity;
  boolean_T Orientation;
  boolean_T Image;
  boolean_T FilledImage;
  boolean_T FilledArea;
  boolean_T EulerNumber;
  boolean_T Extrema;
  boolean_T EquivDiameter;
  boolean_T Extent;
  boolean_T PixelIdxList;
  boolean_T PixelList;
  boolean_T Perimeter;
  boolean_T PixelValues;
  boolean_T WeightedCentroid;
  boolean_T MeanIntensity;
  boolean_T MinIntensity;
  boolean_T MaxIntensity;
  boolean_T SubarrayIdx;
} struct_T;

#endif                                 /*typedef_struct_T*/

/* Variable Definitions */
static emlrtRSInfo ml_emlrtRSI = { 193,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo nl_emlrtRSI = { 115,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo ol_emlrtRSI = { 99, /* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo pl_emlrtRSI = { 78, /* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo ql_emlrtRSI = { 75, /* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo rl_emlrtRSI = { 73, /* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo sl_emlrtRSI = { 32, /* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo rm_emlrtRSI = { 1256,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo sm_emlrtRSI = { 1423,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo tm_emlrtRSI = { 1778,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo um_emlrtRSI = { 291,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo vm_emlrtRSI = { 501,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo wm_emlrtRSI = { 511,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo xm_emlrtRSI = { 512,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo ym_emlrtRSI = { 735,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo an_emlrtRSI = { 737,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo bn_emlrtRSI = { 19, /* lineNo */
  "ind2sub",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\ind2sub.m"/* pathName */
};

static emlrtRSInfo cn_emlrtRSI = { 49, /* lineNo */
  "minOrMax",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pathName */
};

static emlrtRSInfo dn_emlrtRSI = { 128,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo en_emlrtRSI = { 259,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo fn_emlrtRSI = { 325,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo gn_emlrtRSI = { 404,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo hn_emlrtRSI = { 385,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo in_emlrtRSI = { 389,/* lineNo */
  "regionprops",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pathName */
};

static emlrtRSInfo jn_emlrtRSI = { 38, /* lineNo */
  "mean",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\mean.m"/* pathName */
};

static emlrtRTEInfo ic_emlrtRTEI = { 1,/* lineNo */
  23,                                  /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo jc_emlrtRTEI = { 47,/* lineNo */
  9,                                   /* colNo */
  "repmat",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pName */
};

static emlrtRTEInfo kc_emlrtRTEI = { 75,/* lineNo */
  2,                                   /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo lc_emlrtRTEI = { 1666,/* lineNo */
  5,                                   /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo mc_emlrtRTEI = { 216,/* lineNo */
  9,                                   /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo nc_emlrtRTEI = { 230,/* lineNo */
  13,                                  /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo uc_emlrtRTEI = { 495,/* lineNo */
  5,                                   /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo vc_emlrtRTEI = { 721,/* lineNo */
  5,                                   /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo wc_emlrtRTEI = { 379,/* lineNo */
  5,                                   /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo ae_emlrtRTEI = { 501,/* lineNo */
  6,                                   /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtRTEInfo be_emlrtRTEI = { 30,/* lineNo */
  1,                                   /* colNo */
  "ind2sub",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\ind2sub.m"/* pName */
};

static emlrtRTEInfo ce_emlrtRTEI = { 42,/* lineNo */
  5,                                   /* colNo */
  "ind2sub",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\ind2sub.m"/* pName */
};

static emlrtRTEInfo de_emlrtRTEI = { 385,/* lineNo */
  6,                                   /* colNo */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m"/* pName */
};

static emlrtBCInfo xb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  294,                                 /* lineNo */
  60,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo yb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  294,                                 /* lineNo */
  74,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ac_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  294,                                 /* lineNo */
  51,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo bc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  294,                                 /* lineNo */
  65,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo cc_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  294,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo kf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  507,                                 /* lineNo */
  22,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo lf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  513,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo mf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  509,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo nf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  734,                                 /* lineNo */
  27,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo of_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  735,                                 /* lineNo */
  47,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRTEInfo cg_emlrtRTEI = { 38,/* lineNo */
  15,                                  /* colNo */
  "ind2sub",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\ind2sub.m"/* pName */
};

static emlrtBCInfo pf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  739,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo qf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  737,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo rf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  389,                                 /* lineNo */
  40,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo sf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  389,                                 /* lineNo */
  15,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo tf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1834,                                /* lineNo */
  56,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo uf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1834,                                /* lineNo */
  18,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo vf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1836,                                /* lineNo */
  41,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo wf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1837,                                /* lineNo */
  55,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo xf_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  1837,                                /* lineNo */
  26,                                  /* colNo */
  "",                                  /* aName */
  "regionprops",                       /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\regionprops.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRSInfo ts_emlrtRSI = { 18, /* lineNo */
  "indexDivide",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\indexDivide.m"/* pathName */
};

/* Function Declarations */
static void ComputeBoundingBox(const emlrtStack *sp, const real_T imageSize[2],
  b_emxArray_struct_T *stats, struct_T *statsAlreadyComputed);
static void ComputeCentroid(const emlrtStack *sp, const real_T imageSize[2],
  b_emxArray_struct_T *stats, struct_T *statsAlreadyComputed);
static void ComputePixelList(const emlrtStack *sp, const real_T imageSize[2],
  b_emxArray_struct_T *stats, struct_T *statsAlreadyComputed);
static int32_T div_s32(const emlrtStack *sp, int32_T numerator, int32_T
  denominator);
static void populateOutputStatsStructure(const emlrtStack *sp, emxArray_struct_T
  *outstats, const b_emxArray_struct_T *stats);

/* Function Definitions */
static void ComputeBoundingBox(const emlrtStack *sp, const real_T imageSize[2],
  b_emxArray_struct_T *stats, struct_T *statsAlreadyComputed)
{
  b_emxArray_struct_T *b_stats;
  int32_T j;
  int32_T m;
  int32_T k;
  static const real_T dv10[4] = { 0.5, 0.5, 0.0, 0.0 };

  boolean_T overflow;
  real_T min_corner[2];
  int32_T i;
  boolean_T p;
  real_T maxval[2];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  if (!statsAlreadyComputed->BoundingBox) {
    emxInit_struct_T1(sp, &b_stats, 1, &uc_emlrtRTEI, true);
    statsAlreadyComputed->BoundingBox = true;
    j = b_stats->size[0];
    b_stats->size[0] = stats->size[0];
    emxEnsureCapacity_struct_T(sp, b_stats, j, &uc_emlrtRTEI);
    m = stats->size[0];
    for (j = 0; j < m; j++) {
      emxCopyStruct_struct_T(sp, &b_stats->data[j], &stats->data[j],
        &uc_emlrtRTEI);
    }

    st.site = &vm_emlrtRSI;
    ComputePixelList(&st, imageSize, b_stats, statsAlreadyComputed);
    j = stats->size[0];
    stats->size[0] = b_stats->size[0];
    emxEnsureCapacity_struct_T(sp, stats, j, &uc_emlrtRTEI);
    m = b_stats->size[0];
    for (j = 0; j < m; j++) {
      emxCopyStruct_struct_T(sp, &stats->data[j], &b_stats->data[j],
        &ae_emlrtRTEI);
    }

    for (k = 0; k < b_stats->size[0]; k++) {
      j = stats->size[0];
      m = k + 1;
      if (!((m >= 1) && (m <= j))) {
        emlrtDynamicBoundsCheckR2012b(m, 1, j, &kf_emlrtBCI, sp);
      }

      if (stats->data[k].PixelList->size[0] == 0) {
        m = stats->size[0];
        for (j = 0; j < 4; j++) {
          if (!((k + 1 >= 1) && (k + 1 <= m))) {
            emlrtDynamicBoundsCheckR2012b(k + 1, 1, m, &mf_emlrtBCI, sp);
          }

          stats->data[k].BoundingBox[j] = dv10[j];
        }
      } else {
        st.site = &wm_emlrtRSI;
        b_st.site = &gk_emlrtRSI;
        c_st.site = &hk_emlrtRSI;
        d_st.site = &cn_emlrtRSI;
        if (!(stats->data[k].PixelList->size[0] >= 1)) {
          emlrtErrorWithMessageIdR2018a(&d_st, &cf_emlrtRTEI,
            "Coder:toolbox:eml_min_or_max_varDimZero",
            "Coder:toolbox:eml_min_or_max_varDimZero", 0);
        }

        e_st.site = &dn_emlrtRSI;
        f_st.site = &en_emlrtRSI;
        g_st.site = &fn_emlrtRSI;
        m = stats->data[k].PixelList->size[0];
        overflow = ((!(2 > m)) && (m > 2147483646));
        for (j = 0; j < 2; j++) {
          min_corner[j] = stats->data[k].PixelList->data[stats->data[k].
            PixelList->size[0] * j];
          h_st.site = &gn_emlrtRSI;
          if (overflow) {
            i_st.site = &lb_emlrtRSI;
            check_forloop_overflow_error(&i_st);
          }

          for (i = 1; i < m; i++) {
            p = ((!muDoubleScalarIsNaN(stats->data[k].PixelList->data[i +
                   stats->data[k].PixelList->size[0] * j])) &&
                 (muDoubleScalarIsNaN(min_corner[j]) || (min_corner[j] >
                   stats->data[k].PixelList->data[i + stats->data[k]
                   .PixelList->size[0] * j])));
            if (p) {
              min_corner[j] = stats->data[k].PixelList->data[i + stats->data[k].
                PixelList->size[0] * j];
            }
          }
        }

        for (j = 0; j < 2; j++) {
          min_corner[j] -= 0.5;
        }

        st.site = &xm_emlrtRSI;
        b_st.site = &ok_emlrtRSI;
        c_st.site = &hk_emlrtRSI;
        d_st.site = &cn_emlrtRSI;
        if (!(stats->data[k].PixelList->size[0] >= 1)) {
          emlrtErrorWithMessageIdR2018a(&d_st, &cf_emlrtRTEI,
            "Coder:toolbox:eml_min_or_max_varDimZero",
            "Coder:toolbox:eml_min_or_max_varDimZero", 0);
        }

        e_st.site = &dn_emlrtRSI;
        f_st.site = &en_emlrtRSI;
        g_st.site = &fn_emlrtRSI;
        m = stats->data[k].PixelList->size[0];
        overflow = ((!(2 > m)) && (m > 2147483646));
        for (j = 0; j < 2; j++) {
          maxval[j] = stats->data[k].PixelList->data[stats->data[k]
            .PixelList->size[0] * j];
          h_st.site = &gn_emlrtRSI;
          if (overflow) {
            i_st.site = &lb_emlrtRSI;
            check_forloop_overflow_error(&i_st);
          }

          for (i = 1; i < m; i++) {
            p = ((!muDoubleScalarIsNaN(stats->data[k].PixelList->data[i +
                   stats->data[k].PixelList->size[0] * j])) &&
                 (muDoubleScalarIsNaN(maxval[j]) || (maxval[j] < stats->data[k].
                   PixelList->data[i + stats->data[k].PixelList->size[0] * j])));
            if (p) {
              maxval[j] = stats->data[k].PixelList->data[i + stats->data[k].
                PixelList->size[0] * j];
            }
          }
        }

        m = stats->size[0];
        for (j = 0; j < 2; j++) {
          if (!((k + 1 >= 1) && (k + 1 <= m))) {
            emlrtDynamicBoundsCheckR2012b(k + 1, 1, m, &lf_emlrtBCI, sp);
          }

          stats->data[k].BoundingBox[j] = min_corner[j];
        }

        for (j = 0; j < 2; j++) {
          if (!((k + 1 >= 1) && (k + 1 <= m))) {
            emlrtDynamicBoundsCheckR2012b(k + 1, 1, m, &lf_emlrtBCI, sp);
          }

          stats->data[k].BoundingBox[j + 2] = (maxval[j] + 0.5) - min_corner[j];
        }
      }
    }

    emxFree_struct_T1(sp, &b_stats);
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

static void ComputeCentroid(const emlrtStack *sp, const real_T imageSize[2],
  b_emxArray_struct_T *stats, struct_T *statsAlreadyComputed)
{
  b_emxArray_struct_T *b_stats;
  int32_T xpageoffset;
  int32_T vlen;
  int32_T k;
  boolean_T overflow;
  int32_T i;
  real_T y[2];
  int32_T b_k;
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
  if (!statsAlreadyComputed->Centroid) {
    emxInit_struct_T1(sp, &b_stats, 1, &wc_emlrtRTEI, true);
    statsAlreadyComputed->Centroid = true;
    xpageoffset = b_stats->size[0];
    b_stats->size[0] = stats->size[0];
    emxEnsureCapacity_struct_T(sp, b_stats, xpageoffset, &wc_emlrtRTEI);
    vlen = stats->size[0];
    for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
      emxCopyStruct_struct_T(sp, &b_stats->data[xpageoffset], &stats->
        data[xpageoffset], &wc_emlrtRTEI);
    }

    st.site = &hn_emlrtRSI;
    ComputePixelList(&st, imageSize, b_stats, statsAlreadyComputed);
    xpageoffset = stats->size[0];
    stats->size[0] = b_stats->size[0];
    emxEnsureCapacity_struct_T(sp, stats, xpageoffset, &wc_emlrtRTEI);
    vlen = b_stats->size[0];
    for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
      emxCopyStruct_struct_T(sp, &stats->data[xpageoffset], &b_stats->
        data[xpageoffset], &de_emlrtRTEI);
    }

    for (k = 0; k < b_stats->size[0]; k++) {
      st.site = &in_emlrtRSI;
      xpageoffset = stats->size[0];
      vlen = k + 1;
      if (!((vlen >= 1) && (vlen <= xpageoffset))) {
        emlrtDynamicBoundsCheckR2012b(vlen, 1, xpageoffset, &rf_emlrtBCI, &st);
      }

      b_st.site = &jn_emlrtRSI;
      vlen = stats->data[k].PixelList->size[0];
      if (stats->data[k].PixelList->size[0] == 0) {
        for (xpageoffset = 0; xpageoffset < 2; xpageoffset++) {
          y[xpageoffset] = 0.0;
        }
      } else {
        c_st.site = &jm_emlrtRSI;
        overflow = ((!(2 > vlen)) && (vlen > 2147483646));
        for (i = 0; i < 2; i++) {
          xpageoffset = i * stats->data[k].PixelList->size[0];
          y[i] = stats->data[k].PixelList->data[xpageoffset];
          d_st.site = &km_emlrtRSI;
          if (overflow) {
            e_st.site = &lb_emlrtRSI;
            check_forloop_overflow_error(&e_st);
          }

          for (b_k = 2; b_k <= vlen; b_k++) {
            y[i] += stats->data[k].PixelList->data[(xpageoffset + b_k) - 1];
          }
        }
      }

      vlen = stats->data[k].PixelList->size[0];
      i = stats->size[0];
      for (xpageoffset = 0; xpageoffset < 2; xpageoffset++) {
        if (!((k + 1 >= 1) && (k + 1 <= i))) {
          emlrtDynamicBoundsCheckR2012b(k + 1, 1, i, &sf_emlrtBCI, &st);
        }

        stats->data[k].Centroid[xpageoffset] = y[xpageoffset] / (real_T)vlen;
      }
    }

    emxFree_struct_T1(sp, &b_stats);
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

static void ComputePixelList(const emlrtStack *sp, const real_T imageSize[2],
  b_emxArray_struct_T *stats, struct_T *statsAlreadyComputed)
{
  int32_T i62;
  int32_T k;
  emxArray_int32_T *i;
  emxArray_int32_T *j;
  emxArray_int32_T *idx;
  emxArray_int32_T *vk;
  int32_T i63;
  int32_T b_stats;
  int32_T loop_ub;
  boolean_T b4;
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
  if (!statsAlreadyComputed->PixelList) {
    statsAlreadyComputed->PixelList = true;
    i62 = stats->size[0];
    k = 1;
    emxInit_int32_T(sp, &i, 1, &vc_emlrtRTEI, true);
    emxInit_int32_T(sp, &j, 1, &vc_emlrtRTEI, true);
    emxInit_int32_T(sp, &idx, 1, &be_emlrtRTEI, true);
    emxInit_int32_T(sp, &vk, 1, &ce_emlrtRTEI, true);
    while (k - 1 <= i62 - 1) {
      i63 = stats->size[0];
      b_stats = (k - 1) + 1;
      if (!((b_stats >= 1) && (b_stats <= i63))) {
        emlrtDynamicBoundsCheckR2012b(b_stats, 1, i63, &nf_emlrtBCI, sp);
      }

      if (!(stats->data[k - 1].PixelIdxList->size[0] == 0)) {
        st.site = &ym_emlrtRSI;
        i63 = stats->size[0];
        b_stats = (k - 1) + 1;
        if (!((b_stats >= 1) && (b_stats <= i63))) {
          emlrtDynamicBoundsCheckR2012b(b_stats, 1, i63, &of_emlrtBCI, &st);
        }

        b_st.site = &bn_emlrtRSI;
        i63 = idx->size[0];
        idx->size[0] = stats->data[k - 1].PixelIdxList->size[0];
        emxEnsureCapacity_int32_T(&b_st, idx, i63, &vc_emlrtRTEI);
        loop_ub = stats->data[k - 1].PixelIdxList->size[0];
        for (i63 = 0; i63 < loop_ub; i63++) {
          idx->data[i63] = (int32_T)stats->data[k - 1].PixelIdxList->data[i63];
        }

        if (!b_allinrange(idx, (int32_T)imageSize[0] * (int32_T)imageSize[1])) {
          emlrtErrorWithMessageIdR2018a(&b_st, &cg_emlrtRTEI,
            "Coder:MATLAB:ind2sub_IndexOutOfRange",
            "Coder:MATLAB:ind2sub_IndexOutOfRange", 0);
        }

        i63 = idx->size[0];
        emxEnsureCapacity_int32_T(&b_st, idx, i63, &vc_emlrtRTEI);
        loop_ub = idx->size[0];
        for (i63 = 0; i63 < loop_ub; i63++) {
          idx->data[i63]--;
        }

        i63 = vk->size[0];
        vk->size[0] = idx->size[0];
        emxEnsureCapacity_int32_T(&b_st, vk, i63, &vc_emlrtRTEI);
        loop_ub = idx->size[0];
        for (i63 = 0; i63 < loop_ub; i63++) {
          c_st.site = &ts_emlrtRSI;
          vk->data[i63] = div_s32(&c_st, idx->data[i63], (int32_T)imageSize[0]);
        }

        i63 = idx->size[0];
        emxEnsureCapacity_int32_T(&b_st, idx, i63, &vc_emlrtRTEI);
        loop_ub = idx->size[0];
        for (i63 = 0; i63 < loop_ub; i63++) {
          idx->data[i63] -= vk->data[i63] * (int32_T)imageSize[0];
        }

        i63 = i->size[0];
        i->size[0] = idx->size[0];
        emxEnsureCapacity_int32_T(&st, i, i63, &vc_emlrtRTEI);
        loop_ub = idx->size[0];
        for (i63 = 0; i63 < loop_ub; i63++) {
          i->data[i63] = idx->data[i63] + 1;
        }

        i63 = j->size[0];
        j->size[0] = vk->size[0];
        emxEnsureCapacity_int32_T(&st, j, i63, &vc_emlrtRTEI);
        loop_ub = vk->size[0];
        for (i63 = 0; i63 < loop_ub; i63++) {
          j->data[i63] = vk->data[i63] + 1;
        }

        st.site = &an_emlrtRSI;
        b_st.site = &rh_emlrtRSI;
        c_st.site = &sh_emlrtRSI;
        b4 = true;
        if (i->size[0] != j->size[0]) {
          b4 = false;
        }

        if (!b4) {
          emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
            "MATLAB:catenate:matrixDimensionMismatch",
            "MATLAB:catenate:matrixDimensionMismatch", 0);
        }

        b_stats = stats->size[0];
        if (!((k >= 1) && (k <= b_stats))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, b_stats, &qf_emlrtBCI, &b_st);
        }

        i63 = stats->data[k - 1].PixelList->size[0] * stats->data[k - 1].
          PixelList->size[1];
        stats->data[k - 1].PixelList->size[0] = j->size[0];
        if (!((k >= 1) && (k <= b_stats))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, b_stats, &qf_emlrtBCI, &b_st);
        }

        stats->data[k - 1].PixelList->size[1] = 2;
        emxEnsureCapacity_real_T1(&b_st, stats->data[k - 1].PixelList, i63,
          &vc_emlrtRTEI);
        loop_ub = j->size[0];
        for (i63 = 0; i63 < loop_ub; i63++) {
          if (!((k >= 1) && (k <= b_stats))) {
            emlrtDynamicBoundsCheckR2012b(k, 1, b_stats, &qf_emlrtBCI, &b_st);
            emlrtDynamicBoundsCheckR2012b(k, 1, b_stats, &qf_emlrtBCI, &b_st);
          }

          stats->data[k - 1].PixelList->data[i63] = j->data[i63];
        }

        loop_ub = i->size[0];
        for (i63 = 0; i63 < loop_ub; i63++) {
          if (!((k >= 1) && (k <= b_stats))) {
            emlrtDynamicBoundsCheckR2012b(k, 1, b_stats, &qf_emlrtBCI, &b_st);
            emlrtDynamicBoundsCheckR2012b(k, 1, b_stats, &qf_emlrtBCI, &b_st);
          }

          stats->data[k - 1].PixelList->data[i63 + stats->data[k - 1].
            PixelList->size[0]] = i->data[i63];
        }
      } else {
        i63 = stats->size[0];
        if (!((k >= 1) && (k <= i63))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i63, &pf_emlrtBCI, sp);
        }

        i63 = k - 1;
        b_stats = stats->data[i63].PixelList->size[0] * stats->data[i63].
          PixelList->size[1];
        stats->data[i63].PixelList->size[0] = 0;
        i63 = stats->size[0];
        if (!((k >= 1) && (k <= i63))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, i63, &pf_emlrtBCI, sp);
        }

        i63 = k - 1;
        stats->data[i63].PixelList->size[1] = 2;
        emxEnsureCapacity_real_T1(sp, stats->data[i63].PixelList, b_stats,
          &vc_emlrtRTEI);
        b_stats = stats->size[0];
        if (!((k >= 1) && (k <= b_stats))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, b_stats, &pf_emlrtBCI, sp);
        }

        b_stats = stats->size[0];
        if (!((k >= 1) && (k <= b_stats))) {
          emlrtDynamicBoundsCheckR2012b(k, 1, b_stats, &pf_emlrtBCI, sp);
        }
      }

      k++;
    }

    emxFree_int32_T(sp, &vk);
    emxFree_int32_T(sp, &idx);
    emxFree_int32_T(sp, &j);
    emxFree_int32_T(sp, &i);
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

static int32_T div_s32(const emlrtStack *sp, int32_T numerator, int32_T
  denominator)
{
  int32_T quotient;
  uint32_T absNumerator;
  uint32_T absDenominator;
  boolean_T quotientNeedsNegation;
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
    absNumerator /= absDenominator;
    if (quotientNeedsNegation) {
      quotient = -(int32_T)absNumerator;
    } else {
      quotient = (int32_T)absNumerator;
    }
  }

  return quotient;
}

static void populateOutputStatsStructure(const emlrtStack *sp, emxArray_struct_T
  *outstats, const b_emxArray_struct_T *stats)
{
  int32_T k;
  int32_T i64;
  int32_T vIdx;
  for (k = 1; k - 1 < stats->size[0]; k++) {
    i64 = stats->size[0];
    vIdx = (k - 1) + 1;
    if (!((vIdx >= 1) && (vIdx <= i64))) {
      emlrtDynamicBoundsCheckR2012b(vIdx, 1, i64, &tf_emlrtBCI, sp);
    }

    i64 = outstats->size[0];
    if (!((k >= 1) && (k <= i64))) {
      emlrtDynamicBoundsCheckR2012b(k, 1, i64, &uf_emlrtBCI, sp);
    }

    i64 = outstats->size[0];
    vIdx = (k - 1) + 1;
    if (!((vIdx >= 1) && (vIdx <= i64))) {
      emlrtDynamicBoundsCheckR2012b(vIdx, 1, i64, &vf_emlrtBCI, sp);
    }

    for (vIdx = 0; vIdx < 2; vIdx++) {
      i64 = stats->size[0];
      if (!((k >= 1) && (k <= i64))) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i64, &wf_emlrtBCI, sp);
      }

      i64 = outstats->size[0];
      if (!((k >= 1) && (k <= i64))) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i64, &xf_emlrtBCI, sp);
      }

      outstats->data[k - 1].Centroid[vIdx] = stats->data[k - 1].Centroid[vIdx];
    }

    i64 = stats->size[0];
    vIdx = (k - 1) + 1;
    if (!((vIdx >= 1) && (vIdx <= i64))) {
      emlrtDynamicBoundsCheckR2012b(vIdx, 1, i64, &tf_emlrtBCI, sp);
    }

    i64 = outstats->size[0];
    if (!((k >= 1) && (k <= i64))) {
      emlrtDynamicBoundsCheckR2012b(k, 1, i64, &uf_emlrtBCI, sp);
    }

    i64 = outstats->size[0];
    vIdx = (k - 1) + 1;
    if (!((vIdx >= 1) && (vIdx <= i64))) {
      emlrtDynamicBoundsCheckR2012b(vIdx, 1, i64, &vf_emlrtBCI, sp);
    }

    for (vIdx = 0; vIdx < 4; vIdx++) {
      i64 = stats->size[0];
      if (!((k >= 1) && (k <= i64))) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i64, &wf_emlrtBCI, sp);
      }

      i64 = outstats->size[0];
      if (!((k >= 1) && (k <= i64))) {
        emlrtDynamicBoundsCheckR2012b(k, 1, i64, &xf_emlrtBCI, sp);
      }

      outstats->data[k - 1].BoundingBox[vIdx] = stats->data[k - 1]
        .BoundingBox[vIdx];
    }
  }
}

void regionprops(const emlrtStack *sp, const emxArray_boolean_T *varargin_1,
                 emxArray_struct_T *outstats)
{
  emxArray_real_T *CC_RegionIndices;
  emxArray_int32_T *CC_RegionLengths;
  real_T expl_temp;
  real_T CC_ImageSize[2];
  real_T CC_NumObjects;
  int32_T dim;
  b_struct_T s;
  c_struct_T statsOneObj;
  struct_T statsAlreadyComputed;
  b_emxArray_struct_T *stats;
  int32_T loop_ub;
  emxArray_int32_T *regionLengths;
  emxArray_int32_T *idxCount;
  int32_T k;
  int32_T i34;
  int32_T i35;
  int32_T b_stats;
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
  emxInit_real_T1(sp, &CC_RegionIndices, 1, &ic_emlrtRTEI, true);
  emxInit_int32_T(sp, &CC_RegionLengths, 1, &ic_emlrtRTEI, true);
  st.site = &sl_emlrtRSI;
  bwconncomp(&st, varargin_1, &expl_temp, CC_ImageSize, &CC_NumObjects,
             CC_RegionIndices, CC_RegionLengths);
  st.site = &rl_emlrtRSI;
  b_st.site = &rm_emlrtRSI;
  c_st.site = &sm_emlrtRSI;
  d_st.site = &ck_emlrtRSI;
  b_assertValidSizeArg(&d_st, CC_NumObjects);
  for (dim = 0; dim < 2; dim++) {
    s.Centroid[dim] = 0.0;
  }

  for (dim = 0; dim < 4; dim++) {
    s.BoundingBox[dim] = 0.0;
  }

  emxInitStruct_struct_T(&c_st, &statsOneObj, &lc_emlrtRTEI, true);
  st.site = &ql_emlrtRSI;
  statsAlreadyComputed.Area = false;
  statsOneObj.Area = 0.0;
  statsAlreadyComputed.Centroid = false;
  for (dim = 0; dim < 2; dim++) {
    statsOneObj.Centroid[dim] = 0.0;
  }

  statsAlreadyComputed.BoundingBox = false;
  for (dim = 0; dim < 4; dim++) {
    statsOneObj.BoundingBox[dim] = 0.0;
  }

  statsAlreadyComputed.MajorAxisLength = false;
  statsOneObj.MajorAxisLength = 0.0;
  statsAlreadyComputed.MinorAxisLength = false;
  statsOneObj.MinorAxisLength = 0.0;
  statsAlreadyComputed.Eccentricity = false;
  statsOneObj.Eccentricity = 0.0;
  statsAlreadyComputed.Orientation = false;
  statsOneObj.Orientation = 0.0;
  statsAlreadyComputed.Image = false;
  dim = statsOneObj.Image->size[0] * statsOneObj.Image->size[1];
  statsOneObj.Image->size[0] = 0;
  statsOneObj.Image->size[1] = 0;
  emxEnsureCapacity_boolean_T1(&st, statsOneObj.Image, dim, &ic_emlrtRTEI);
  statsAlreadyComputed.FilledImage = false;
  dim = statsOneObj.FilledImage->size[0] * statsOneObj.FilledImage->size[1];
  statsOneObj.FilledImage->size[0] = 0;
  statsOneObj.FilledImage->size[1] = 0;
  emxEnsureCapacity_boolean_T1(&st, statsOneObj.FilledImage, dim, &ic_emlrtRTEI);
  statsAlreadyComputed.FilledArea = false;
  statsOneObj.FilledArea = 0.0;
  statsAlreadyComputed.EulerNumber = false;
  statsOneObj.EulerNumber = 0.0;
  statsAlreadyComputed.Extrema = false;
  memset(&statsOneObj.Extrema[0], 0, sizeof(real_T) << 4);
  statsAlreadyComputed.EquivDiameter = false;
  statsOneObj.EquivDiameter = 0.0;
  statsAlreadyComputed.Extent = false;
  statsOneObj.Extent = 0.0;
  dim = statsOneObj.PixelIdxList->size[0];
  statsOneObj.PixelIdxList->size[0] = 0;
  emxEnsureCapacity_real_T(&st, statsOneObj.PixelIdxList, dim, &ic_emlrtRTEI);
  statsAlreadyComputed.PixelList = false;
  dim = statsOneObj.PixelList->size[0] * statsOneObj.PixelList->size[1];
  statsOneObj.PixelList->size[0] = 0;
  statsOneObj.PixelList->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, statsOneObj.PixelList, dim, &ic_emlrtRTEI);
  statsAlreadyComputed.Perimeter = false;
  statsOneObj.Perimeter = 0.0;
  statsAlreadyComputed.PixelValues = false;
  dim = statsOneObj.PixelValues->size[0];
  statsOneObj.PixelValues->size[0] = 0;
  emxEnsureCapacity_real_T(&st, statsOneObj.PixelValues, dim, &ic_emlrtRTEI);
  statsAlreadyComputed.WeightedCentroid = false;
  for (dim = 0; dim < 2; dim++) {
    statsOneObj.WeightedCentroid[dim] = 0.0;
  }

  statsAlreadyComputed.MeanIntensity = false;
  statsOneObj.MeanIntensity = 0.0;
  statsAlreadyComputed.MinIntensity = false;
  statsOneObj.MinIntensity = 0.0;
  statsAlreadyComputed.MaxIntensity = false;
  statsOneObj.MaxIntensity = 0.0;
  statsAlreadyComputed.SubarrayIdx = false;
  dim = statsOneObj.SubarrayIdx->size[0] * statsOneObj.SubarrayIdx->size[1];
  statsOneObj.SubarrayIdx->size[0] = 1;
  statsOneObj.SubarrayIdx->size[1] = 0;
  emxEnsureCapacity_real_T1(&st, statsOneObj.SubarrayIdx, dim, &ic_emlrtRTEI);
  for (dim = 0; dim < 2; dim++) {
    statsOneObj.SubarrayIdxLengths[dim] = 0.0;
  }

  b_st.site = &tm_emlrtRSI;
  c_st.site = &ck_emlrtRSI;
  b_assertValidSizeArg(&c_st, CC_NumObjects);
  emxInit_struct_T1(&b_st, &stats, 1, &kc_emlrtRTEI, true);
  dim = stats->size[0];
  stats->size[0] = (int32_T)CC_NumObjects;
  emxEnsureCapacity_struct_T(&b_st, stats, dim, &ic_emlrtRTEI);
  loop_ub = (int32_T)CC_NumObjects;
  for (dim = 0; dim < loop_ub; dim++) {
    emxCopyStruct_struct_T(&b_st, &stats->data[dim], &statsOneObj, &jc_emlrtRTEI);
  }

  emxFreeStruct_struct_T(&b_st, &statsOneObj);
  st.site = &pl_emlrtRSI;
  statsAlreadyComputed.PixelIdxList = true;
  if (CC_NumObjects != 0.0) {
    emxInit_int32_T(&st, &regionLengths, 1, &mc_emlrtRTEI, true);
    dim = regionLengths->size[0];
    regionLengths->size[0] = CC_RegionLengths->size[0];
    emxEnsureCapacity_int32_T(&st, regionLengths, dim, &ic_emlrtRTEI);
    loop_ub = CC_RegionLengths->size[0];
    for (dim = 0; dim < loop_ub; dim++) {
      regionLengths->data[dim] = CC_RegionLengths->data[dim];
    }

    b_st.site = &um_emlrtRSI;
    c_st.site = &lm_emlrtRSI;
    dim = 2;
    if (CC_RegionLengths->size[0] != 1) {
      dim = 1;
    }

    d_st.site = &mm_emlrtRSI;
    if ((1 == dim) && (CC_RegionLengths->size[0] != 0) &&
        (CC_RegionLengths->size[0] != 1)) {
      for (k = 1; k < CC_RegionLengths->size[0]; k++) {
        regionLengths->data[k] += regionLengths->data[k - 1];
      }
    }

    emxInit_int32_T(&d_st, &idxCount, 1, &nc_emlrtRTEI, true);
    dim = idxCount->size[0];
    idxCount->size[0] = 1 + regionLengths->size[0];
    emxEnsureCapacity_int32_T(&st, idxCount, dim, &ic_emlrtRTEI);
    idxCount->data[0] = 0;
    loop_ub = regionLengths->size[0];
    for (dim = 0; dim < loop_ub; dim++) {
      idxCount->data[dim + 1] = regionLengths->data[dim];
    }

    emxFree_int32_T(&st, &regionLengths);
    for (k = 0; k < (int32_T)CC_NumObjects; k++) {
      dim = idxCount->size[0];
      i34 = k + 1;
      if (!((i34 >= 1) && (i34 <= dim))) {
        emlrtDynamicBoundsCheckR2012b(i34, 1, dim, &xb_emlrtBCI, &st);
      }

      dim = idxCount->size[0];
      i34 = (int32_T)((1.0 + (real_T)k) + 1.0);
      if (!((i34 >= 1) && (i34 <= dim))) {
        emlrtDynamicBoundsCheckR2012b(i34, 1, dim, &yb_emlrtBCI, &st);
      }

      if (idxCount->data[k] + 1 > idxCount->data[(int32_T)((1.0 + (real_T)k) +
           1.0) - 1]) {
        dim = 0;
        i35 = 0;
      } else {
        dim = CC_RegionIndices->size[0];
        i34 = idxCount->data[k] + 1;
        if (!((i34 >= 1) && (i34 <= dim))) {
          emlrtDynamicBoundsCheckR2012b(i34, 1, dim, &ac_emlrtBCI, &st);
        }

        dim = i34 - 1;
        i34 = CC_RegionIndices->size[0];
        i35 = idxCount->data[(int32_T)((1.0 + (real_T)k) + 1.0) - 1];
        if (!((i35 >= 1) && (i35 <= i34))) {
          emlrtDynamicBoundsCheckR2012b(i35, 1, i34, &bc_emlrtBCI, &st);
        }
      }

      b_stats = stats->size[0];
      i34 = 1 + k;
      if (!((i34 >= 1) && (i34 <= b_stats))) {
        emlrtDynamicBoundsCheckR2012b(i34, 1, b_stats, &cc_emlrtBCI, &st);
      }

      i34 = stats->data[k].PixelIdxList->size[0];
      stats->data[k].PixelIdxList->size[0] = i35 - dim;
      emxEnsureCapacity_real_T(&st, stats->data[k].PixelIdxList, i34,
        &ic_emlrtRTEI);
      loop_ub = i35 - dim;
      for (i34 = 0; i34 < loop_ub; i34++) {
        i35 = 1 + k;
        if (!((i35 >= 1) && (i35 <= b_stats))) {
          emlrtDynamicBoundsCheckR2012b(i35, 1, b_stats, &cc_emlrtBCI, &st);
        }

        stats->data[i35 - 1].PixelIdxList->data[i34] = CC_RegionIndices->
          data[dim + i34];
      }
    }

    emxFree_int32_T(&st, &idxCount);
  }

  emxFree_int32_T(&st, &CC_RegionLengths);
  emxFree_real_T(&st, &CC_RegionIndices);
  st.site = &ol_emlrtRSI;
  ComputeCentroid(&st, CC_ImageSize, stats, &statsAlreadyComputed);
  st.site = &nl_emlrtRSI;
  ComputeBoundingBox(&st, CC_ImageSize, stats, &statsAlreadyComputed);
  dim = outstats->size[0];
  outstats->size[0] = (int32_T)CC_NumObjects;
  emxEnsureCapacity_struct_T1(sp, outstats, dim, &ic_emlrtRTEI);
  loop_ub = (int32_T)CC_NumObjects;
  for (dim = 0; dim < loop_ub; dim++) {
    outstats->data[dim] = s;
  }

  st.site = &ml_emlrtRSI;
  populateOutputStatsStructure(&st, outstats, stats);
  emxFree_struct_T1(sp, &stats);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (regionprops.c) */
