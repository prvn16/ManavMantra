/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: msac.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "msac.h"
#include "mod.h"
#include "sum.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "estimateGeometricTransform.h"
#include "rand.h"
#include "any.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static float rt_powf_snf(float u0, float u1);

/* Function Definitions */

/*
 * Arguments    : float u0
 *                float u1
 * Return Type  : float
 */
static float rt_powf_snf(float u0, float u1)
{
  float y;
  float f2;
  float f3;
  if (rtIsNaNF(u0) || rtIsNaNF(u1)) {
    y = ((real32_T)rtNaN);
  } else {
    f2 = (float)fabs(u0);
    f3 = (float)fabs(u1);
    if (rtIsInfF(u1)) {
      if (f2 == 1.0F) {
        y = 1.0F;
      } else if (f2 > 1.0F) {
        if (u1 > 0.0F) {
          y = ((real32_T)rtInf);
        } else {
          y = 0.0F;
        }
      } else if (u1 > 0.0F) {
        y = 0.0F;
      } else {
        y = ((real32_T)rtInf);
      }
    } else if (f3 == 0.0F) {
      y = 1.0F;
    } else if (f3 == 1.0F) {
      if (u1 > 0.0F) {
        y = u0;
      } else {
        y = 1.0F / u0;
      }
    } else if (u1 == 2.0F) {
      y = u0 * u0;
    } else if ((u1 == 0.5F) && (u0 >= 0.0F)) {
      y = (float)sqrt(u0);
    } else if ((u0 < 0.0F) && (u1 > (float)floor(u1))) {
      y = ((real32_T)rtNaN);
    } else {
      y = (float)pow(u0, u1);
    }
  }

  return y;
}

/*
 * Arguments    : const emxArray_real32_T *allPoints
 *                boolean_T *isFound
 *                float bestModelParams_data[]
 *                int bestModelParams_size[2]
 *                emxArray_boolean_T *inliers
 * Return Type  : void
 */
void msac(const emxArray_real32_T *allPoints, boolean_T *isFound, float
          bestModelParams_data[], int bestModelParams_size[2],
          emxArray_boolean_T *inliers)
{
  emxArray_boolean_T *bestInliers;
  int numPts;
  int idxTrial;
  int numTrials;
  float bestDis;
  int skipTrials;
  int i25;
  int nleftm1;
  emxArray_real32_T *dis;
  emxArray_boolean_T *b_dis;
  int b_bestInliers[1];
  double indices_data[2];
  emxArray_boolean_T c_bestInliers;
  emxArray_int32_T *r13;
  double t;
  double selectedLoc;
  emxArray_real32_T *b_allPoints;
  int num;
  double j;
  double newEntry;
  double hashTbl_data[2];
  int end;
  double link_data[2];
  int val_data[2];
  double i;
  double loc_data[2];
  int samplePoints_size[3];
  emxArray_real32_T samplePoints_data;
  float b_samplePoints_data[8];
  int i26;
  float modelParams[9];
  boolean_T isValidModel;
  boolean_T bv0[9];
  boolean_T bv1[9];
  boolean_T exitg1;
  float inlierProbability;
  static int iv6[2] = { 3, 3 };

  emxInit_boolean_T(&bestInliers, 1);
  numPts = allPoints->size[0];
  idxTrial = 1;
  numTrials = 1000;
  bestDis = 4.0F * (float)allPoints->size[0];
  bestModelParams_size[0] = 0;
  bestModelParams_size[1] = 0;
  skipTrials = 0;
  i25 = bestInliers->size[0];
  bestInliers->size[0] = allPoints->size[0];
  emxEnsureCapacity_boolean_T2(bestInliers, i25);
  nleftm1 = allPoints->size[0];
  for (i25 = 0; i25 < nleftm1; i25++) {
    bestInliers->data[i25] = false;
  }

  emxInit_real32_T1(&dis, 1);
  emxInit_boolean_T(&b_dis, 1);
  while ((idxTrial <= numTrials) && (skipTrials < 10000)) {
    for (i25 = 0; i25 < 2; i25++) {
      indices_data[i25] = 0.0;
    }

    if (2 >= numPts) {
      indices_data[0] = 1.0;
      selectedLoc = b_rand() * 2.0;
      j = floor(selectedLoc);
      indices_data[1] = indices_data[(int)(j + 1.0) - 1];
      indices_data[(int)(j + 1.0) - 1] = 2.0;
    } else if (2.0 >= (double)numPts / 4.0) {
      t = 0.0;
      for (num = 0; num < 2; num++) {
        selectedLoc = (double)numPts - t;
        i = (2.0 - (double)num) / selectedLoc;
        newEntry = b_rand();
        while (newEntry > i) {
          t++;
          selectedLoc--;
          i += (1.0 - i) * ((2.0 - (double)num) / selectedLoc);
        }

        t++;
        selectedLoc = b_rand() * ((double)num + 1.0);
        j = floor(selectedLoc);
        indices_data[num] = indices_data[(int)(j + 1.0) - 1];
        indices_data[(int)(j + 1.0) - 1] = t;
      }
    } else {
      for (i25 = 0; i25 < 2; i25++) {
        hashTbl_data[i25] = 0.0;
        link_data[i25] = 0.0;
        val_data[i25] = 0;
        loc_data[i25] = 0.0;
      }

      newEntry = 1.0;
      for (num = 0; num < 2; num++) {
        nleftm1 = (numPts - num) - 1;
        selectedLoc = b_rand() * ((double)nleftm1 + 1.0);
        selectedLoc = floor(selectedLoc);
        i = 1.0 + b_mod(selectedLoc);
        j = hashTbl_data[(int)i - 1];
        while ((j > 0.0) && (loc_data[(int)j - 1] != selectedLoc)) {
          j = link_data[(int)j - 1];
        }

        if (j > 0.0) {
          indices_data[num] = (double)val_data[(int)j - 1] + 1.0;
        } else {
          indices_data[num] = selectedLoc + 1.0;
          j = newEntry;
          newEntry++;
          loc_data[(int)j - 1] = selectedLoc;
          link_data[(int)j - 1] = hashTbl_data[(int)i - 1];
          hashTbl_data[(int)i - 1] = j;
        }

        if (1 + num < 2) {
          selectedLoc = hashTbl_data[(int)(1.0 + b_mod(nleftm1)) - 1];
          while ((selectedLoc > 0.0) && (loc_data[(int)selectedLoc - 1] !=
                  nleftm1)) {
            selectedLoc = link_data[(int)selectedLoc - 1];
          }

          if (selectedLoc > 0.0) {
            val_data[(int)j - 1] = val_data[(int)selectedLoc - 1];
          } else {
            val_data[(int)j - 1] = nleftm1;
          }
        }
      }
    }

    nleftm1 = allPoints->size[1];
    samplePoints_size[0] = 2;
    samplePoints_size[1] = nleftm1;
    samplePoints_size[2] = 2;
    for (i25 = 0; i25 < 2; i25++) {
      for (end = 0; end < nleftm1; end++) {
        for (i26 = 0; i26 < 2; i26++) {
          b_samplePoints_data[(i26 + samplePoints_size[0] * end) +
            samplePoints_size[0] * samplePoints_size[1] * i25] = allPoints->
            data[(((int)indices_data[i26] + allPoints->size[0] * end) +
                  allPoints->size[0] * allPoints->size[1] * i25) - 1];
        }
      }
    }

    samplePoints_data.data = (float *)&b_samplePoints_data;
    samplePoints_data.size = (int *)&samplePoints_size;
    samplePoints_data.allocatedSize = 8;
    samplePoints_data.numDimensions = 3;
    samplePoints_data.canFreeData = false;
    computeSimilarity(&samplePoints_data, modelParams);
    for (i25 = 0; i25 < 9; i25++) {
      bv0[i25] = !rtIsInfF(modelParams[i25]);
      bv1[i25] = !rtIsNaNF(modelParams[i25]);
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
      evaluateTForm(modelParams, allPoints, dis);
      end = dis->size[0];
      for (nleftm1 = 0; nleftm1 < end; nleftm1++) {
        if (dis->data[nleftm1] > 4.0F) {
          dis->data[nleftm1] = 4.0F;
        }
      }

      inlierProbability = sum(dis);
      if (inlierProbability < bestDis) {
        bestDis = inlierProbability;
        i25 = bestInliers->size[0];
        bestInliers->size[0] = dis->size[0];
        emxEnsureCapacity_boolean_T2(bestInliers, i25);
        nleftm1 = dis->size[0];
        for (i25 = 0; i25 < nleftm1; i25++) {
          bestInliers->data[i25] = (dis->data[i25] < 4.0F);
        }

        bestModelParams_size[0] = 3;
        bestModelParams_size[1] = 3;
        for (i25 = 0; i25 < 9; i25++) {
          bestModelParams_data[i25] = modelParams[i25];
        }

        i25 = b_dis->size[0];
        b_dis->size[0] = dis->size[0];
        emxEnsureCapacity_boolean_T2(b_dis, i25);
        nleftm1 = dis->size[0];
        for (i25 = 0; i25 < nleftm1; i25++) {
          b_dis->data[i25] = (dis->data[i25] < 4.0F);
        }

        inlierProbability = rt_powf_snf((float)b_sum(b_dis) / (float)numPts,
          2.0F);
        if (inlierProbability < 1.1920929E-7F) {
          num = MAX_int32_T;
        } else {
          num = (int)(float)ceil(-1.99999785F / (float)log10(1.0F -
            inlierProbability));
        }

        if (!(numTrials < num)) {
          numTrials = num;
        }
      }

      idxTrial++;
    } else {
      skipTrials++;
    }
  }

  emxFree_boolean_T(&b_dis);
  if (checkTForm(bestModelParams_data, bestModelParams_size) &&
      (!(bestInliers->size[0] == 0))) {
    b_bestInliers[0] = bestInliers->size[0];
    c_bestInliers = *bestInliers;
    c_bestInliers.size = (int *)&b_bestInliers;
    c_bestInliers.numDimensions = 1;
    if (b_sum(&c_bestInliers) >= 2.0) {
      *isFound = true;
    } else {
      *isFound = false;
    }
  } else {
    *isFound = false;
  }

  emxInit_int32_T(&r13, 1);
  emxInit_real32_T2(&b_allPoints, 3);
  if (*isFound) {
    end = bestInliers->size[0] - 1;
    num = 0;
    for (nleftm1 = 0; nleftm1 <= end; nleftm1++) {
      if (bestInliers->data[nleftm1]) {
        num++;
      }
    }

    i25 = r13->size[0];
    r13->size[0] = num;
    emxEnsureCapacity_int32_T(r13, i25);
    num = 0;
    for (nleftm1 = 0; nleftm1 <= end; nleftm1++) {
      if (bestInliers->data[nleftm1]) {
        r13->data[num] = nleftm1 + 1;
        num++;
      }
    }

    nleftm1 = allPoints->size[1];
    i25 = b_allPoints->size[0] * b_allPoints->size[1] * b_allPoints->size[2];
    b_allPoints->size[0] = r13->size[0];
    b_allPoints->size[1] = nleftm1;
    b_allPoints->size[2] = 2;
    emxEnsureCapacity_real32_T1(b_allPoints, i25);
    for (i25 = 0; i25 < 2; i25++) {
      for (end = 0; end < nleftm1; end++) {
        num = r13->size[0];
        for (i26 = 0; i26 < num; i26++) {
          b_allPoints->data[(i26 + b_allPoints->size[0] * end) +
            b_allPoints->size[0] * b_allPoints->size[1] * i25] = allPoints->
            data[((r13->data[i26] + allPoints->size[0] * end) + allPoints->size
                  [0] * allPoints->size[1] * i25) - 1];
        }
      }
    }

    computeSimilarity(b_allPoints, modelParams);
    evaluateTForm(modelParams, allPoints, dis);
    end = dis->size[0];
    for (nleftm1 = 0; nleftm1 < end; nleftm1++) {
      if (dis->data[nleftm1] > 4.0F) {
        dis->data[nleftm1] = 4.0F;
      }
    }

    bestModelParams_size[0] = 3;
    bestModelParams_size[1] = 3;
    for (i25 = 0; i25 < 9; i25++) {
      bestModelParams_data[i25] = modelParams[i25];
    }

    i25 = inliers->size[0];
    inliers->size[0] = dis->size[0];
    emxEnsureCapacity_boolean_T2(inliers, i25);
    nleftm1 = dis->size[0];
    for (i25 = 0; i25 < nleftm1; i25++) {
      inliers->data[i25] = (dis->data[i25] < 4.0F);
    }

    if ((!checkTForm(modelParams, iv6)) || (!any(inliers))) {
      *isFound = false;
      i25 = inliers->size[0];
      inliers->size[0] = allPoints->size[0];
      emxEnsureCapacity_boolean_T2(inliers, i25);
      nleftm1 = allPoints->size[0];
      for (i25 = 0; i25 < nleftm1; i25++) {
        inliers->data[i25] = false;
      }
    }
  } else {
    i25 = inliers->size[0];
    inliers->size[0] = allPoints->size[0];
    emxEnsureCapacity_boolean_T2(inliers, i25);
    nleftm1 = allPoints->size[0];
    for (i25 = 0; i25 < nleftm1; i25++) {
      inliers->data[i25] = false;
    }
  }

  emxFree_real32_T(&b_allPoints);
  emxFree_real32_T(&dis);
  emxFree_int32_T(&r13);
  emxFree_boolean_T(&bestInliers);
}

/*
 * File trailer for msac.c
 *
 * [EOF]
 */
