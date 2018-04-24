/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * depthEstimationFromStereoVideo_kernel_data.h
 *
 * Code generation for function 'depthEstimationFromStereoVideo_kernel_data'
 *
 */

#ifndef DEPTHESTIMATIONFROMSTEREOVIDEO_KERNEL_DATA_H
#define DEPTHESTIMATIONFROMSTEREOVIDEO_KERNEL_DATA_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "depthEstimationFromStereoVideo_kernel_types.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern const volatile char_T *emlrtBreakCheckR2012bFlagVar;
extern visioncodegen_ShapeInserter h3111;
extern boolean_T h3111_not_empty;
extern const mxArray *eml_mx;
extern const mxArray *b_eml_mx;
extern emlrtContext emlrtContextGlobal;
extern emlrtRSInfo db_emlrtRSI;
extern emlrtRSInfo eb_emlrtRSI;
extern emlrtRSInfo lb_emlrtRSI;
extern emlrtRSInfo ic_emlrtRSI;
extern emlrtRSInfo jd_emlrtRSI;
extern emlrtRSInfo kd_emlrtRSI;
extern emlrtRSInfo ld_emlrtRSI;
extern emlrtRSInfo sd_emlrtRSI;
extern emlrtRSInfo td_emlrtRSI;
extern emlrtRSInfo ud_emlrtRSI;
extern emlrtRSInfo vd_emlrtRSI;
extern emlrtRSInfo wd_emlrtRSI;
extern emlrtRSInfo xd_emlrtRSI;
extern emlrtRSInfo yd_emlrtRSI;
extern emlrtRSInfo ae_emlrtRSI;
extern emlrtRSInfo be_emlrtRSI;
extern emlrtRSInfo ce_emlrtRSI;
extern emlrtRSInfo pe_emlrtRSI;
extern emlrtRSInfo qe_emlrtRSI;
extern emlrtRSInfo re_emlrtRSI;
extern emlrtRSInfo te_emlrtRSI;
extern emlrtRSInfo ue_emlrtRSI;
extern emlrtRSInfo ve_emlrtRSI;
extern emlrtRSInfo bf_emlrtRSI;
extern emlrtRSInfo df_emlrtRSI;
extern emlrtRSInfo gf_emlrtRSI;
extern emlrtRSInfo kf_emlrtRSI;
extern emlrtRSInfo lf_emlrtRSI;
extern emlrtRSInfo mf_emlrtRSI;
extern emlrtRSInfo tf_emlrtRSI;
extern emlrtRSInfo uf_emlrtRSI;
extern emlrtRSInfo mg_emlrtRSI;
extern emlrtRSInfo ng_emlrtRSI;
extern emlrtRSInfo og_emlrtRSI;
extern emlrtRSInfo pg_emlrtRSI;
extern emlrtRSInfo qg_emlrtRSI;
extern emlrtRSInfo lh_emlrtRSI;
extern emlrtRSInfo nh_emlrtRSI;
extern emlrtRSInfo oh_emlrtRSI;
extern emlrtRSInfo ph_emlrtRSI;
extern emlrtRSInfo rh_emlrtRSI;
extern emlrtRSInfo sh_emlrtRSI;
extern emlrtRSInfo bi_emlrtRSI;
extern emlrtRSInfo ci_emlrtRSI;
extern emlrtRSInfo di_emlrtRSI;
extern emlrtRSInfo ei_emlrtRSI;
extern emlrtRSInfo fi_emlrtRSI;
extern emlrtRSInfo hi_emlrtRSI;
extern emlrtRSInfo ui_emlrtRSI;
extern emlrtRSInfo vi_emlrtRSI;
extern emlrtRSInfo bj_emlrtRSI;
extern emlrtRSInfo ck_emlrtRSI;
extern emlrtRSInfo gk_emlrtRSI;
extern emlrtRSInfo hk_emlrtRSI;
extern emlrtRSInfo kk_emlrtRSI;
extern emlrtRSInfo lk_emlrtRSI;
extern emlrtRSInfo ok_emlrtRSI;
extern emlrtRSInfo hm_emlrtRSI;
extern emlrtRSInfo im_emlrtRSI;
extern emlrtRSInfo jm_emlrtRSI;
extern emlrtRSInfo km_emlrtRSI;
extern emlrtRSInfo lm_emlrtRSI;
extern emlrtRSInfo mm_emlrtRSI;
extern emlrtRSInfo pm_emlrtRSI;
extern emlrtRSInfo qm_emlrtRSI;
extern emlrtRSInfo ao_emlrtRSI;
extern emlrtRSInfo bo_emlrtRSI;
extern emlrtRSInfo co_emlrtRSI;
extern emlrtRSInfo do_emlrtRSI;
extern emlrtRSInfo eo_emlrtRSI;
extern emlrtRSInfo xp_emlrtRSI;
extern emlrtRSInfo yp_emlrtRSI;
extern emlrtRSInfo aq_emlrtRSI;
extern emlrtRSInfo nq_emlrtRSI;
extern emlrtRSInfo tq_emlrtRSI;
extern emlrtRSInfo vq_emlrtRSI;
extern emlrtRSInfo pr_emlrtRSI;
extern emlrtRSInfo rr_emlrtRSI;
extern emlrtRSInfo es_emlrtRSI;
extern emlrtRSInfo fs_emlrtRSI;
extern emlrtRSInfo gs_emlrtRSI;
extern emlrtRSInfo js_emlrtRSI;
extern emlrtRSInfo ks_emlrtRSI;
extern emlrtRSInfo ls_emlrtRSI;
extern emlrtMCInfo d_emlrtMCI;
extern emlrtMCInfo f_emlrtMCI;
extern emlrtRTEInfo b_emlrtRTEI;
extern emlrtRTEInfo c_emlrtRTEI;
extern emlrtRTEInfo ab_emlrtRTEI;
extern emlrtRTEInfo xc_emlrtRTEI;
extern emlrtRTEInfo ke_emlrtRTEI;
extern emlrtRTEInfo le_emlrtRTEI;
extern emlrtRTEInfo me_emlrtRTEI;
extern emlrtRTEInfo ne_emlrtRTEI;
extern emlrtRTEInfo oe_emlrtRTEI;
extern emlrtRTEInfo se_emlrtRTEI;
extern emlrtRTEInfo te_emlrtRTEI;
extern emlrtRTEInfo ue_emlrtRTEI;
extern emlrtRTEInfo we_emlrtRTEI;
extern emlrtRTEInfo xe_emlrtRTEI;
extern emlrtRTEInfo cf_emlrtRTEI;
extern emlrtRTEInfo df_emlrtRTEI;
extern emlrtRTEInfo ff_emlrtRTEI;
extern emlrtRTEInfo hf_emlrtRTEI;
extern emlrtRTEInfo kf_emlrtRTEI;
extern emlrtRTEInfo qf_emlrtRTEI;
extern emlrtRTEInfo dg_emlrtRTEI;
extern const char_T cv1[15];
extern emlrtRSInfo qs_emlrtRSI;
extern emlrtRSInfo ss_emlrtRSI;

#endif

/* End of code generation (depthEstimationFromStereoVideo_kernel_data.h) */
