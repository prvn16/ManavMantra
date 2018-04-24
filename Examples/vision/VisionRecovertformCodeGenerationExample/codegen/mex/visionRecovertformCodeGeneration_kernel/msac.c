/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * msac.c
 *
 * Code generation for function 'msac'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "msac.h"
#include "mod.h"
#include "rand.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "error.h"
#include "sum.h"
#include "estimateGeometricTransform.h"
#include "any.h"
#include "all1.h"

/* Variable Definitions */
static emlrtRSInfo yf_emlrtRSI = { 107,/* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo ag_emlrtRSI = { 105,/* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo bg_emlrtRSI = { 103,/* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo cg_emlrtRSI = { 102,/* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo dg_emlrtRSI = { 98, /* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo eg_emlrtRSI = { 97, /* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo fg_emlrtRSI = { 86, /* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo gg_emlrtRSI = { 85, /* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo hg_emlrtRSI = { 77, /* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo ig_emlrtRSI = { 70, /* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo jg_emlrtRSI = { 66, /* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo kg_emlrtRSI = { 24, /* lineNo */
  "randperm",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\randfun\\randperm.m"/* pathName */
};

static emlrtRSInfo mi_emlrtRSI = { 128,/* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo ni_emlrtRSI = { 130,/* lineNo */
  "msac",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pathName */
};

static emlrtRSInfo aj_emlrtRSI = { 7,  /* lineNo */
  "computeLoopNumber",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\computeLoopNumber.m"/* pathName */
};

static emlrtRSInfo bj_emlrtRSI = { 14, /* lineNo */
  "computeLoopNumber",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\computeLoopNumber.m"/* pathName */
};

static emlrtRSInfo cj_emlrtRSI = { 15, /* lineNo */
  "computeLoopNumber",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\computeLoopNumber.m"/* pathName */
};

static emlrtRSInfo ej_emlrtRSI = { 13, /* lineNo */
  "log10",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\log10.m"/* pathName */
};

static emlrtRSInfo fj_emlrtRSI = { 426,/* lineNo */
  "estimateGeometricTransform",        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\estimateGeometricTransform.m"/* pathName */
};

static emlrtRTEInfo re_emlrtRTEI = { 54,/* lineNo */
  1,                                   /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo se_emlrtRTEI = { 120,/* lineNo */
  5,                                   /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo te_emlrtRTEI = { 1,/* lineNo */
  70,                                  /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo ue_emlrtRTEI = { 102,/* lineNo */
  37,                                  /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo ve_emlrtRTEI = { 83,/* lineNo */
  13,                                  /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo we_emlrtRTEI = { 85,/* lineNo */
  34,                                  /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo xe_emlrtRTEI = { 106,/* lineNo */
  9,                                   /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo ye_emlrtRTEI = { 109,/* lineNo */
  13,                                  /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo af_emlrtRTEI = { 128,/* lineNo */
  1,                                   /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m"/* pName */
};

static emlrtRTEInfo vi_emlrtRTEI = { 23,/* lineNo */
  19,                                  /* colNo */
  "randperm",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\randfun\\randperm.m"/* pName */
};

static emlrtBCInfo mb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  102,                                 /* lineNo */
  47,                                  /* colNo */
  "",                                  /* aName */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo nb_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  129,                                 /* lineNo */
  1,                                   /* colNo */
  "",                                  /* aName */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo ob_emlrtBCI = { -1, /* iFirst */
  -1,                                  /* iLast */
  69,                                  /* lineNo */
  30,                                  /* colNo */
  "",                                  /* aName */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m",/* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo f_emlrtDCI = { 69,  /* lineNo */
  30,                                  /* colNo */
  "msac",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+ransac\\msac.m",/* pName */
  1                                    /* checkKind */
};

/* Function Definitions */
void msac(const emlrtStack *sp, const emxArray_real32_T *allPoints, boolean_T
          *isFound, real32_T bestModelParams_data[], int32_T
          bestModelParams_size[2], emxArray_boolean_T *inliers)
{
  emxArray_boolean_T *bestInliers;
  int32_T numPts;
  int32_T idxTrial;
  int32_T numTrials;
  real32_T bestDis;
  int32_T skipTrials;
  int32_T i12;
  int32_T loop_ub;
  emxArray_real32_T *dis;
  emxArray_boolean_T *b_dis;
  int32_T num;
  boolean_T tmp_data[9];
  real_T indices_data[2];
  real_T t;
  real_T selectedLoc;
  int32_T tmp_size[1];
  boolean_T b_tmp_data[9];
  real_T j;
  real_T newEntry;
  real_T hashTbl_data[2];
  real_T link_data[2];
  emxArray_boolean_T c_tmp_data;
  boolean_T d_tmp_data[9];
  int32_T val_data[2];
  real_T i;
  int32_T nleftm1;
  real_T loc_data[2];
  int32_T samplePoints_size[3];
  boolean_T isValidModel;
  int32_T b_bestInliers[1];
  emxArray_real32_T samplePoints_data;
  real32_T b_samplePoints_data[8];
  emxArray_int32_T *r14;
  emxArray_real32_T *b_allPoints;
  int32_T b_i;
  real32_T modelParams[9];
  int32_T i13;
  boolean_T bv0[9];
  boolean_T bv1[9];
  boolean_T exitg1;
  real32_T inlierNum;
  real32_T x_data[9];
  int32_T b_tmp_size[1];
  emxArray_boolean_T e_tmp_data;
  boolean_T f_tmp_data[9];
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
  emxInit_boolean_T(sp, &bestInliers, 1, &re_emlrtRTEI, true);
  numPts = allPoints->size[0];
  idxTrial = 1;
  numTrials = 1000;
  bestDis = 1.5F * (real32_T)allPoints->size[0];
  bestModelParams_size[0] = 0;
  bestModelParams_size[1] = 0;
  skipTrials = 0;
  i12 = bestInliers->size[0];
  bestInliers->size[0] = allPoints->size[0];
  emxEnsureCapacity_boolean_T(sp, bestInliers, i12, &re_emlrtRTEI);
  loop_ub = allPoints->size[0];
  for (i12 = 0; i12 < loop_ub; i12++) {
    bestInliers->data[i12] = false;
  }

  emxInit_real32_T1(sp, &dis, 1, &af_emlrtRTEI, true);
  emxInit_boolean_T(sp, &b_dis, 1, &we_emlrtRTEI, true);
  while ((idxTrial <= numTrials) && (skipTrials < 10000)) {
    st.site = &jg_emlrtRSI;
    if (!(2 <= numPts)) {
      emlrtErrorWithMessageIdR2018a(&st, &vi_emlrtRTEI,
        "MATLAB:randperm:inputKTooLarge", "MATLAB:randperm:inputKTooLarge", 0);
    }

    b_st.site = &kg_emlrtRSI;
    for (i12 = 0; i12 < 2; i12++) {
      indices_data[i12] = 0.0;
    }

    if (2 >= numPts) {
      indices_data[0] = 1.0;
      selectedLoc = b_rand() * 2.0;
      j = muDoubleScalarFloor(selectedLoc);
      indices_data[1] = indices_data[(int32_T)(j + 1.0) - 1];
      indices_data[(int32_T)(j + 1.0) - 1] = 2.0;
    } else if (2.0 >= (real_T)numPts / 4.0) {
      t = 0.0;
      for (num = 0; num < 2; num++) {
        selectedLoc = (real_T)numPts - t;
        i = (2.0 - (real_T)num) / selectedLoc;
        newEntry = b_rand();
        while (newEntry > i) {
          t++;
          selectedLoc--;
          i += (1.0 - i) * ((2.0 - (real_T)num) / selectedLoc);
        }

        t++;
        selectedLoc = b_rand() * ((real_T)num + 1.0);
        j = muDoubleScalarFloor(selectedLoc);
        indices_data[num] = indices_data[(int32_T)(j + 1.0) - 1];
        indices_data[(int32_T)(j + 1.0) - 1] = t;
      }
    } else {
      for (i12 = 0; i12 < 2; i12++) {
        hashTbl_data[i12] = 0.0;
        link_data[i12] = 0.0;
        val_data[i12] = 0;
        loc_data[i12] = 0.0;
      }

      newEntry = 1.0;
      for (num = 0; num < 2; num++) {
        nleftm1 = (numPts - num) - 1;
        selectedLoc = b_rand() * ((real_T)nleftm1 + 1.0);
        selectedLoc = muDoubleScalarFloor(selectedLoc);
        i = 1.0 + b_mod(selectedLoc);
        j = hashTbl_data[(int32_T)i - 1];
        while ((j > 0.0) && (loc_data[(int32_T)j - 1] != selectedLoc)) {
          j = link_data[(int32_T)j - 1];
        }

        if (j > 0.0) {
          indices_data[num] = (real_T)val_data[(int32_T)j - 1] + 1.0;
        } else {
          indices_data[num] = selectedLoc + 1.0;
          j = newEntry;
          newEntry++;
          loc_data[(int32_T)j - 1] = selectedLoc;
          link_data[(int32_T)j - 1] = hashTbl_data[(int32_T)i - 1];
          hashTbl_data[(int32_T)i - 1] = j;
        }

        if (1 + num < 2) {
          selectedLoc = hashTbl_data[(int32_T)(1.0 + b_mod(nleftm1)) - 1];
          while ((selectedLoc > 0.0) && (loc_data[(int32_T)selectedLoc - 1] !=
                  nleftm1)) {
            selectedLoc = link_data[(int32_T)selectedLoc - 1];
          }

          if (selectedLoc > 0.0) {
            val_data[(int32_T)j - 1] = val_data[(int32_T)selectedLoc - 1];
          } else {
            val_data[(int32_T)j - 1] = nleftm1;
          }
        }
      }
    }

    num = allPoints->size[0];
    samplePoints_size[0] = 2;
    samplePoints_size[1] = 2;
    samplePoints_size[2] = 2;
    for (i12 = 0; i12 < 2; i12++) {
      for (nleftm1 = 0; nleftm1 < 2; nleftm1++) {
        for (b_i = 0; b_i < 2; b_i++) {
          selectedLoc = indices_data[b_i];
          if (selectedLoc != (int32_T)selectedLoc) {
            emlrtIntegerCheckR2012b(selectedLoc, &f_emlrtDCI, sp);
          }

          i13 = (int32_T)selectedLoc;
          if (!((i13 >= 1) && (i13 <= num))) {
            emlrtDynamicBoundsCheckR2012b(i13, 1, num, &ob_emlrtBCI, sp);
          }

          b_samplePoints_data[(b_i + samplePoints_size[0] * nleftm1) +
            samplePoints_size[0] * samplePoints_size[1] * i12] = allPoints->
            data[((i13 + allPoints->size[0] * nleftm1) + allPoints->size[0] *
                  allPoints->size[1] * i12) - 1];
        }
      }
    }

    samplePoints_data.data = (real32_T *)&b_samplePoints_data;
    samplePoints_data.size = (int32_T *)&samplePoints_size;
    samplePoints_data.allocatedSize = 8;
    samplePoints_data.numDimensions = 3;
    samplePoints_data.canFreeData = false;
    st.site = &ig_emlrtRSI;
    computeSimilarity(&st, &samplePoints_data, modelParams);
    for (i12 = 0; i12 < 9; i12++) {
      bv0[i12] = !muSingleScalarIsInf(modelParams[i12]);
      bv1[i12] = !muSingleScalarIsNaN(modelParams[i12]);
    }

    isValidModel = true;
    num = 0;
    exitg1 = false;
    while ((!exitg1) && (num < 9)) {
      if (!(bv0[num] && bv1[num])) {
        isValidModel = false;
        exitg1 = true;
      } else {
        num++;
      }
    }

    if (isValidModel) {
      st.site = &hg_emlrtRSI;
      b_st.site = &mi_emlrtRSI;
      evaluateTForm(&b_st, modelParams, allPoints, dis);
      nleftm1 = dis->size[0];
      for (b_i = 0; b_i < nleftm1; b_i++) {
        if (dis->data[b_i] > 1.5F) {
          i12 = dis->size[0];
          if (!((b_i + 1 >= 1) && (b_i + 1 <= i12))) {
            emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, i12, &nb_emlrtBCI, &st);
          }

          dis->data[b_i] = 1.5F;
        }
      }

      b_st.site = &ni_emlrtRSI;
      inlierNum = sum(&b_st, dis);
      if (inlierNum < bestDis) {
        bestDis = inlierNum;
        i12 = bestInliers->size[0];
        bestInliers->size[0] = dis->size[0];
        emxEnsureCapacity_boolean_T(sp, bestInliers, i12, &ve_emlrtRTEI);
        loop_ub = dis->size[0];
        for (i12 = 0; i12 < loop_ub; i12++) {
          bestInliers->data[i12] = (dis->data[i12] < 1.5F);
        }

        bestModelParams_size[0] = 3;
        bestModelParams_size[1] = 3;
        for (i12 = 0; i12 < 9; i12++) {
          bestModelParams_data[i12] = modelParams[i12];
        }

        i12 = b_dis->size[0];
        b_dis->size[0] = dis->size[0];
        emxEnsureCapacity_boolean_T(sp, b_dis, i12, &we_emlrtRTEI);
        loop_ub = dis->size[0];
        for (i12 = 0; i12 < loop_ub; i12++) {
          b_dis->data[i12] = (dis->data[i12] < 1.5F);
        }

        st.site = &gg_emlrtRSI;
        inlierNum = (real32_T)b_sum(&st, b_dis);
        st.site = &fg_emlrtRSI;
        b_st.site = &aj_emlrtRSI;
        inlierNum = muSingleScalarPower(inlierNum / (real32_T)numPts, 2.0F);
        if (inlierNum < 1.1920929E-7F) {
          num = MAX_int32_T;
        } else {
          b_st.site = &bj_emlrtRSI;
          b_st.site = &cj_emlrtRSI;
          if (1.0F - inlierNum < 0.0F) {
            c_st.site = &ej_emlrtRSI;
            f_error(&c_st);
          }

          num = (int32_T)muSingleScalarCeil(-1.99999785F / muSingleScalarLog10
            (1.0F - inlierNum));
        }

        numTrials = muIntScalarMin_sint32(numTrials, num);
      }

      idxTrial++;
    } else {
      skipTrials++;
    }
  }

  emxFree_boolean_T(sp, &b_dis);
  st.site = &eg_emlrtRSI;
  num = bestModelParams_size[0] * bestModelParams_size[1];
  loop_ub = bestModelParams_size[0] * bestModelParams_size[1];
  for (i12 = 0; i12 < loop_ub; i12++) {
    tmp_data[i12] = muSingleScalarIsInf(bestModelParams_data[i12]);
  }

  loop_ub = bestModelParams_size[0] * bestModelParams_size[1];
  for (i12 = 0; i12 < loop_ub; i12++) {
    b_tmp_data[i12] = muSingleScalarIsNaN(bestModelParams_data[i12]);
  }

  tmp_size[0] = num;
  for (i12 = 0; i12 < num; i12++) {
    d_tmp_data[i12] = ((!tmp_data[i12]) && (!b_tmp_data[i12]));
  }

  c_tmp_data.data = (boolean_T *)&d_tmp_data;
  c_tmp_data.size = (int32_T *)&tmp_size;
  c_tmp_data.allocatedSize = 9;
  c_tmp_data.numDimensions = 1;
  c_tmp_data.canFreeData = false;
  b_st.site = &fj_emlrtRSI;
  isValidModel = c_all(&b_st, &c_tmp_data);
  if (isValidModel && (!(bestInliers->size[0] == 0))) {
    b_bestInliers[0] = bestInliers->size[0];
    c_tmp_data = *bestInliers;
    c_tmp_data.size = (int32_T *)&b_bestInliers;
    c_tmp_data.numDimensions = 1;
    st.site = &dg_emlrtRSI;
    if (b_sum(&st, &c_tmp_data) >= 2.0) {
      *isFound = true;
    } else {
      *isFound = false;
    }
  } else {
    *isFound = false;
  }

  emxInit_int32_T(sp, &r14, 1, &te_emlrtRTEI, true);
  emxInit_real32_T2(sp, &b_allPoints, 3, &ue_emlrtRTEI, true);
  if (*isFound) {
    nleftm1 = bestInliers->size[0] - 1;
    num = 0;
    for (b_i = 0; b_i <= nleftm1; b_i++) {
      if (bestInliers->data[b_i]) {
        num++;
      }
    }

    i12 = r14->size[0];
    r14->size[0] = num;
    emxEnsureCapacity_int32_T(sp, r14, i12, &te_emlrtRTEI);
    num = 0;
    for (b_i = 0; b_i <= nleftm1; b_i++) {
      if (bestInliers->data[b_i]) {
        r14->data[num] = b_i + 1;
        num++;
      }
    }

    num = allPoints->size[0];
    i12 = b_allPoints->size[0] * b_allPoints->size[1] * b_allPoints->size[2];
    b_allPoints->size[0] = r14->size[0];
    b_allPoints->size[1] = 2;
    b_allPoints->size[2] = 2;
    emxEnsureCapacity_real32_T2(sp, b_allPoints, i12, &ue_emlrtRTEI);
    for (i12 = 0; i12 < 2; i12++) {
      for (nleftm1 = 0; nleftm1 < 2; nleftm1++) {
        loop_ub = r14->size[0];
        for (b_i = 0; b_i < loop_ub; b_i++) {
          i13 = r14->data[b_i];
          if (!((i13 >= 1) && (i13 <= num))) {
            emlrtDynamicBoundsCheckR2012b(i13, 1, num, &mb_emlrtBCI, sp);
          }

          b_allPoints->data[(b_i + b_allPoints->size[0] * nleftm1) +
            b_allPoints->size[0] * b_allPoints->size[1] * i12] = allPoints->
            data[((i13 + allPoints->size[0] * nleftm1) + allPoints->size[0] *
                  allPoints->size[1] * i12) - 1];
        }
      }
    }

    st.site = &cg_emlrtRSI;
    computeSimilarity(&st, b_allPoints, modelParams);
    st.site = &bg_emlrtRSI;
    b_st.site = &mi_emlrtRSI;
    evaluateTForm(&b_st, modelParams, allPoints, dis);
    nleftm1 = dis->size[0];
    for (b_i = 0; b_i < nleftm1; b_i++) {
      if (dis->data[b_i] > 1.5F) {
        i12 = dis->size[0];
        if (!((b_i + 1 >= 1) && (b_i + 1 <= i12))) {
          emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, i12, &nb_emlrtBCI, &st);
        }

        dis->data[b_i] = 1.5F;
      }
    }

    b_st.site = &ni_emlrtRSI;
    sum(&b_st, dis);
    bestModelParams_size[0] = 3;
    bestModelParams_size[1] = 3;
    for (i12 = 0; i12 < 9; i12++) {
      bestModelParams_data[i12] = modelParams[i12];
    }

    st.site = &ag_emlrtRSI;
    for (i12 = 0; i12 < 9; i12++) {
      x_data[i12] = modelParams[i12];
    }

    for (i12 = 0; i12 < 9; i12++) {
      tmp_data[i12] = muSingleScalarIsInf(x_data[i12]);
    }

    for (i12 = 0; i12 < 9; i12++) {
      b_tmp_data[i12] = muSingleScalarIsNaN(x_data[i12]);
    }

    b_tmp_size[0] = 9;
    for (i12 = 0; i12 < 9; i12++) {
      f_tmp_data[i12] = ((!tmp_data[i12]) && (!b_tmp_data[i12]));
    }

    e_tmp_data.data = (boolean_T *)&f_tmp_data;
    e_tmp_data.size = (int32_T *)&b_tmp_size;
    e_tmp_data.allocatedSize = 9;
    e_tmp_data.numDimensions = 1;
    e_tmp_data.canFreeData = false;
    b_st.site = &fj_emlrtRSI;
    isValidModel = c_all(&b_st, &e_tmp_data);
    i12 = inliers->size[0];
    inliers->size[0] = dis->size[0];
    emxEnsureCapacity_boolean_T(sp, inliers, i12, &xe_emlrtRTEI);
    loop_ub = dis->size[0];
    for (i12 = 0; i12 < loop_ub; i12++) {
      inliers->data[i12] = (dis->data[i12] < 1.5F);
    }

    st.site = &yf_emlrtRSI;
    if ((!isValidModel) || (!any(&st, inliers))) {
      *isFound = false;
      i12 = inliers->size[0];
      inliers->size[0] = allPoints->size[0];
      emxEnsureCapacity_boolean_T(sp, inliers, i12, &ye_emlrtRTEI);
      loop_ub = allPoints->size[0];
      for (i12 = 0; i12 < loop_ub; i12++) {
        inliers->data[i12] = false;
      }
    }
  } else {
    i12 = inliers->size[0];
    inliers->size[0] = allPoints->size[0];
    emxEnsureCapacity_boolean_T(sp, inliers, i12, &se_emlrtRTEI);
    loop_ub = allPoints->size[0];
    for (i12 = 0; i12 < loop_ub; i12++) {
      inliers->data[i12] = false;
    }
  }

  emxFree_real32_T(sp, &b_allPoints);
  emxFree_real32_T(sp, &dis);
  emxFree_int32_T(sp, &r14);
  emxFree_boolean_T(sp, &bestInliers);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (msac.c) */
