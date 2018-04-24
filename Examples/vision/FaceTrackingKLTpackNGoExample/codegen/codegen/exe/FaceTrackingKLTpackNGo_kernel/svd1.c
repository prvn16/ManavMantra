/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: svd1.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <math.h>
#include <string.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "svd1.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "xaxpy.h"
#include "xdotc.h"
#include "xnrm2.h"
#include "xscal.h"
#include "xrot.h"
#include "xrotg.h"
#include "sqrt.h"
#include "xswap.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *A
 *                emxArray_real32_T *U
 *                float s_data[]
 *                int s_size[1]
 *                float V[25]
 * Return Type  : void
 */
void svd(const emxArray_real32_T *A, emxArray_real32_T *U, float s_data[], int
         s_size[1], float V[25])
{
  emxArray_real32_T *b_A;
  int m;
  int ns;
  int n;
  int minnp;
  float b_s_data[5];
  emxArray_real32_T *work;
  float e[5];
  int nrt;
  int nct;
  int qp1jj;
  int q;
  int qq;
  int nmq;
  boolean_T apply_transform;
  float ztest0;
  int mm;
  float ztest;
  float snorm;
  boolean_T exitg1;
  float f;
  float scale;
  float sqds;
  float b;
  emxInit_real32_T(&b_A, 2);
  m = b_A->size[0] * b_A->size[1];
  b_A->size[0] = A->size[0];
  b_A->size[1] = 5;
  emxEnsureCapacity_real32_T(b_A, m);
  ns = A->size[0] * A->size[1];
  for (m = 0; m < ns; m++) {
    b_A->data[m] = A->data[m];
  }

  n = A->size[0];
  ns = A->size[0] + 1;
  if (!(ns < 5)) {
    ns = 5;
  }

  minnp = A->size[0];
  if (!(minnp < 5)) {
    minnp = 5;
  }

  if (0 <= ns - 1) {
    memset(&b_s_data[0], 0, (unsigned int)(ns * (int)sizeof(float)));
  }

  for (ns = 0; ns < 5; ns++) {
    e[ns] = 0.0F;
  }

  emxInit_real32_T1(&work, 1);
  ns = A->size[0];
  m = work->size[0];
  work->size[0] = ns;
  emxEnsureCapacity_real32_T2(work, m);
  for (m = 0; m < ns; m++) {
    work->data[m] = 0.0F;
  }

  ns = A->size[0];
  m = U->size[0] * U->size[1];
  U->size[0] = ns;
  U->size[1] = minnp;
  emxEnsureCapacity_real32_T(U, m);
  ns *= minnp;
  for (m = 0; m < ns; m++) {
    U->data[m] = 0.0F;
  }

  memset(&V[0], 0, 25U * sizeof(float));
  if (A->size[0] == 0) {
    for (ns = 0; ns < 5; ns++) {
      V[ns + 5 * ns] = 1.0F;
    }
  } else {
    nrt = A->size[0];
    if (3 < nrt) {
      nrt = 3;
    }

    if (A->size[0] > 1) {
      nct = A->size[0] - 1;
    } else {
      nct = 0;
    }

    if (!(nct < 5)) {
      nct = 5;
    }

    if (nct > nrt) {
      m = nct;
    } else {
      m = nrt;
    }

    for (q = 0; q < m; q++) {
      qq = q + n * q;
      nmq = n - q;
      apply_transform = false;
      if (q + 1 <= nct) {
        ztest0 = xnrm2(nmq, b_A, qq + 1);
        if (ztest0 > 0.0F) {
          apply_transform = true;
          if (b_A->data[qq] < 0.0F) {
            ztest0 = -ztest0;
          }

          b_s_data[q] = ztest0;
          if ((float)fabs(b_s_data[q]) >= 9.86076132E-32F) {
            ztest0 = 1.0F / b_s_data[q];
            ns = qq + nmq;
            for (qp1jj = qq; qp1jj < ns; qp1jj++) {
              b_A->data[qp1jj] *= ztest0;
            }
          } else {
            ns = qq + nmq;
            for (qp1jj = qq; qp1jj < ns; qp1jj++) {
              b_A->data[qp1jj] /= b_s_data[q];
            }
          }

          b_A->data[qq]++;
          b_s_data[q] = -b_s_data[q];
        } else {
          b_s_data[q] = 0.0F;
        }
      }

      for (mm = q + 1; mm + 1 < 6; mm++) {
        ns = q + n * mm;
        if (apply_transform) {
          ztest0 = -(xdotc(nmq, b_A, qq + 1, b_A, ns + 1) / b_A->data[q +
                     b_A->size[0] * q]);
          xaxpy(nmq, ztest0, qq + 1, b_A, ns + 1);
        }

        e[mm] = b_A->data[ns];
      }

      if (q + 1 <= nct) {
        for (ns = q; ns < n; ns++) {
          U->data[ns + U->size[0] * q] = b_A->data[ns + b_A->size[0] * q];
        }
      }

      if (q + 1 <= nrt) {
        ztest0 = b_xnrm2(4 - q, e, q + 2);
        if (ztest0 == 0.0F) {
          e[q] = 0.0F;
        } else {
          if (e[q + 1] < 0.0F) {
            e[q] = -ztest0;
          } else {
            e[q] = ztest0;
          }

          ztest0 = e[q];
          if ((float)fabs(e[q]) >= 9.86076132E-32F) {
            ztest0 = 1.0F / e[q];
            for (qp1jj = q + 1; qp1jj < 5; qp1jj++) {
              e[qp1jj] *= ztest0;
            }
          } else {
            for (qp1jj = q + 1; qp1jj < 5; qp1jj++) {
              e[qp1jj] /= ztest0;
            }
          }

          e[q + 1]++;
          e[q] = -e[q];
          if (q + 2 <= n) {
            for (ns = q + 1; ns < n; ns++) {
              work->data[ns] = 0.0F;
            }

            for (mm = q + 1; mm + 1 < 6; mm++) {
              b_xaxpy(nmq - 1, e[mm], b_A, (q + n * mm) + 2, work, q + 2);
            }

            for (mm = q + 1; mm + 1 < 6; mm++) {
              c_xaxpy(nmq - 1, -e[mm] / e[q + 1], work, q + 2, b_A, (q + n * mm)
                      + 2);
            }
          }
        }

        for (ns = q + 1; ns + 1 < 6; ns++) {
          V[ns + 5 * q] = e[ns];
        }
      }
    }

    m = A->size[0] + 1;
    if (5 < m) {
      m = 5;
    }

    if (nct < 5) {
      b_s_data[nct] = b_A->data[nct + b_A->size[0] * nct];
    }

    if (A->size[0] < m) {
      b_s_data[m - 1] = 0.0F;
    }

    if (nrt + 1 < m) {
      e[nrt] = b_A->data[nrt + b_A->size[0] * (m - 1)];
    }

    e[m - 1] = 0.0F;
    if (nct + 1 <= minnp) {
      for (mm = nct; mm < minnp; mm++) {
        for (ns = 1; ns <= n; ns++) {
          U->data[(ns + U->size[0] * mm) - 1] = 0.0F;
        }

        U->data[mm + U->size[0] * mm] = 1.0F;
      }
    }

    for (q = nct - 1; q + 1 > 0; q--) {
      nmq = n - q;
      qq = q + n * q;
      if (b_s_data[q] != 0.0F) {
        for (mm = q + 1; mm < minnp; mm++) {
          ns = (q + n * mm) + 1;
          ztest0 = -(b_xdotc(nmq, U, qq + 1, U, ns) / U->data[qq]);
          d_xaxpy(nmq, ztest0, qq + 1, U, ns);
        }

        for (ns = q; ns < n; ns++) {
          U->data[ns + U->size[0] * q] = -U->data[ns + U->size[0] * q];
        }

        U->data[qq]++;
        for (ns = 1; ns <= q; ns++) {
          U->data[(ns + U->size[0] * q) - 1] = 0.0F;
        }
      } else {
        for (ns = 1; ns <= n; ns++) {
          U->data[(ns + U->size[0] * q) - 1] = 0.0F;
        }

        U->data[qq] = 1.0F;
      }
    }

    for (q = 4; q >= 0; q--) {
      if ((q + 1 <= nrt) && (e[q] != 0.0F)) {
        ns = (q + 5 * q) + 2;
        for (mm = q + 1; mm + 1 < 6; mm++) {
          qp1jj = (q + 5 * mm) + 2;
          e_xaxpy(4 - q, -(c_xdotc(4 - q, V, ns, V, qp1jj) / V[ns - 1]), ns, V,
                  qp1jj);
        }
      }

      for (ns = 0; ns < 5; ns++) {
        V[ns + 5 * q] = 0.0F;
      }

      V[q + 5 * q] = 1.0F;
    }

    for (q = 0; q < m; q++) {
      if (b_s_data[q] != 0.0F) {
        ztest = (float)fabs(b_s_data[q]);
        ztest0 = b_s_data[q] / ztest;
        b_s_data[q] = ztest;
        if (q + 1 < m) {
          e[q] /= ztest0;
        }

        if (q + 1 <= n) {
          xscal(n, ztest0, U, 1 + n * q);
        }
      }

      if ((q + 1 < m) && (e[q] != 0.0F)) {
        ztest = (float)fabs(e[q]);
        ztest0 = ztest / e[q];
        e[q] = ztest;
        b_s_data[q + 1] *= ztest0;
        b_xscal(ztest0, V, 1 + 5 * (q + 1));
      }
    }

    mm = m;
    nct = 0;
    snorm = 0.0F;
    for (ns = 0; ns < m; ns++) {
      ztest0 = (float)fabs(b_s_data[ns]);
      ztest = (float)fabs(e[ns]);
      if ((ztest0 > ztest) || rtIsNaNF(ztest)) {
      } else {
        ztest0 = ztest;
      }

      if (!((snorm > ztest0) || rtIsNaNF(ztest0))) {
        snorm = ztest0;
      }
    }

    while ((m > 0) && (!(nct >= 75))) {
      q = m - 1;
      exitg1 = false;
      while (!(exitg1 || (q == 0))) {
        ztest0 = (float)fabs(e[q - 1]);
        if ((ztest0 <= 1.1920929E-7F * ((float)fabs(b_s_data[q - 1]) + (float)
              fabs(b_s_data[q]))) || (ztest0 <= 9.86076132E-32F) || ((nct > 20) &&
             (ztest0 <= 1.1920929E-7F * snorm))) {
          e[q - 1] = 0.0F;
          exitg1 = true;
        } else {
          q--;
        }
      }

      if (q == m - 1) {
        ns = 4;
      } else {
        qp1jj = m;
        ns = m;
        exitg1 = false;
        while ((!exitg1) && (ns >= q)) {
          qp1jj = ns;
          if (ns == q) {
            exitg1 = true;
          } else {
            ztest0 = 0.0F;
            if (ns < m) {
              ztest0 = (float)fabs(e[ns - 1]);
            }

            if (ns > q + 1) {
              ztest0 += (float)fabs(e[ns - 2]);
            }

            ztest = (float)fabs(b_s_data[ns - 1]);
            if ((ztest <= 1.1920929E-7F * ztest0) || (ztest <= 9.86076132E-32F))
            {
              b_s_data[ns - 1] = 0.0F;
              exitg1 = true;
            } else {
              ns--;
            }
          }
        }

        if (qp1jj == q) {
          ns = 3;
        } else if (qp1jj == m) {
          ns = 1;
        } else {
          ns = 2;
          q = qp1jj;
        }
      }

      switch (ns) {
       case 1:
        f = e[m - 2];
        e[m - 2] = 0.0F;
        for (qp1jj = m - 3; qp1jj + 2 >= q + 1; qp1jj--) {
          xrotg(&b_s_data[qp1jj + 1], &f, &ztest0, &ztest);
          if (qp1jj + 2 > q + 1) {
            f = -ztest * e[qp1jj];
            e[qp1jj] *= ztest0;
          }

          xrot(V, 1 + 5 * (qp1jj + 1), 1 + 5 * (m - 1), ztest0, ztest);
        }
        break;

       case 2:
        f = e[q - 1];
        e[q - 1] = 0.0F;
        for (qp1jj = q; qp1jj < m; qp1jj++) {
          xrotg(&b_s_data[qp1jj], &f, &ztest0, &ztest);
          f = -ztest * e[qp1jj];
          e[qp1jj] *= ztest0;
          b_xrot(n, U, 1 + n * qp1jj, 1 + n * (q - 1), ztest0, ztest);
        }
        break;

       case 3:
        scale = (float)fabs(b_s_data[m - 1]);
        ztest = (float)fabs(b_s_data[m - 2]);
        if (!((scale > ztest) || rtIsNaNF(ztest))) {
          scale = ztest;
        }

        ztest = (float)fabs(e[m - 2]);
        if (!((scale > ztest) || rtIsNaNF(ztest))) {
          scale = ztest;
        }

        ztest = (float)fabs(b_s_data[q]);
        if (!((scale > ztest) || rtIsNaNF(ztest))) {
          scale = ztest;
        }

        ztest = (float)fabs(e[q]);
        if (!((scale > ztest) || rtIsNaNF(ztest))) {
          scale = ztest;
        }

        f = b_s_data[m - 1] / scale;
        ztest0 = b_s_data[m - 2] / scale;
        ztest = e[m - 2] / scale;
        sqds = b_s_data[q] / scale;
        b = ((ztest0 + f) * (ztest0 - f) + ztest * ztest) / 2.0F;
        ztest0 = f * ztest;
        ztest0 *= ztest0;
        if ((b != 0.0F) || (ztest0 != 0.0F)) {
          ztest = b * b + ztest0;
          c_sqrt(&ztest);
          if (b < 0.0F) {
            ztest = -ztest;
          }

          ztest = ztest0 / (b + ztest);
        } else {
          ztest = 0.0F;
        }

        f = (sqds + f) * (sqds - f) + ztest;
        b = sqds * (e[q] / scale);
        for (qp1jj = q + 1; qp1jj < m; qp1jj++) {
          xrotg(&f, &b, &ztest0, &ztest);
          if (qp1jj > q + 1) {
            e[qp1jj - 2] = f;
          }

          f = ztest0 * b_s_data[qp1jj - 1] + ztest * e[qp1jj - 1];
          e[qp1jj - 1] = ztest0 * e[qp1jj - 1] - ztest * b_s_data[qp1jj - 1];
          b = ztest * b_s_data[qp1jj];
          b_s_data[qp1jj] *= ztest0;
          xrot(V, 1 + 5 * (qp1jj - 1), 1 + 5 * qp1jj, ztest0, ztest);
          b_s_data[qp1jj - 1] = f;
          xrotg(&b_s_data[qp1jj - 1], &b, &ztest0, &ztest);
          f = ztest0 * e[qp1jj - 1] + ztest * b_s_data[qp1jj];
          b_s_data[qp1jj] = -ztest * e[qp1jj - 1] + ztest0 * b_s_data[qp1jj];
          b = ztest * e[qp1jj];
          e[qp1jj] *= ztest0;
          if (qp1jj < n) {
            b_xrot(n, U, 1 + n * (qp1jj - 1), 1 + n * qp1jj, ztest0, ztest);
          }
        }

        e[m - 2] = f;
        nct++;
        break;

       default:
        if (b_s_data[q] < 0.0F) {
          b_s_data[q] = -b_s_data[q];
          b_xscal(-1.0F, V, 1 + 5 * q);
        }

        ns = q + 1;
        while ((q + 1 < mm) && (b_s_data[q] < b_s_data[ns])) {
          ztest = b_s_data[q];
          b_s_data[q] = b_s_data[ns];
          b_s_data[ns] = ztest;
          xswap(V, 1 + 5 * q, 1 + 5 * (q + 1));
          if (q + 1 < n) {
            b_xswap(n, U, 1 + n * q, 1 + n * (q + 1));
          }

          q = ns;
          ns++;
        }

        nct = 0;
        m--;
        break;
      }
    }
  }

  emxFree_real32_T(&work);
  emxFree_real32_T(&b_A);
  s_size[0] = minnp;
  for (qp1jj = 0; qp1jj < minnp; qp1jj++) {
    s_data[qp1jj] = b_s_data[qp1jj];
  }
}

/*
 * File trailer for svd1.c
 *
 * [EOF]
 */
