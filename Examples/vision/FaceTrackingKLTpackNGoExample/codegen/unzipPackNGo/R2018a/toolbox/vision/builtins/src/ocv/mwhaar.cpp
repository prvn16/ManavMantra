/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                        Intel License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000, Intel Corporation, all rights reserved.
// Third party copyrights are property of their respective owners.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * The name of Intel Corporation may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
//M*/

/* Haar features calculation */

#include "precomp_objdetect.hpp"
#include "mwobjdetect.hpp"
#include <stdio.h>
#include "opencv2/core.hpp"

#if CV_SSE2
#   if 1 /*!CV_SSE4_1 && !CV_SSE4_2*/
#       define _mm_blendv_pd(a, b, m) _mm_xor_pd(a, _mm_and_pd(_mm_xor_pd(b, a), m))
#       define _mm_blendv_ps(a, b, m) _mm_xor_ps(a, _mm_and_ps(_mm_xor_ps(b, a), m))
#   endif
#endif

#if 0 /*CV_AVX*/
#  define CV_HAAR_USE_AVX 1
#  if defined _MSC_VER
#    pragma warning( disable : 4752 )
#  endif
#else
#  if CV_SSE2
#    define CV_HAAR_USE_SSE 1
#  endif
#endif

/* these settings affect the quality of detection: change with care */
#define CV_ADJUST_FEATURES 1
#define CV_ADJUST_WEIGHTS  0

typedef int sumtype;
typedef double sqsumtype;

// Copied over from "opencv2/core/private.hpp", which is 
// not recommended to be used outside of the openCV source.
CV_INLINE int cvAlign( int size, int align )
{
    assert( (align & (align-1)) == 0 && size < INT_MAX );
    return (size + align - 1) & -align;
}

static inline void* cvAlignPtr( const void* ptr, int align = 32 )
{
    CV_DbgAssert ( (align & (align-1)) == 0 );
    return (void*)( ((size_t)ptr + align - 1) & ~(size_t)(align-1) );
}

typedef struct MWCvHidHaarFeature
{
    struct
    {
        sumtype *p0, *p1, *p2, *p3;
        float weight;
    }
    rect[CV_HAAR_FEATURE_MAX];
} MWCvHidHaarFeature;


typedef struct MWCvHidHaarTreeNode
{
    MWCvHidHaarFeature feature;
    float threshold;
    int left;
    int right;
} MWCvHidHaarTreeNode;


typedef struct MWCvHidHaarClassifier
{
    int count;
    //MWCvHaarFeature* orig_feature;
    MWCvHidHaarTreeNode* node;
    float* alpha;
} MWCvHidHaarClassifier;


typedef struct MWCvHidHaarStageClassifier
{
    int  count;
    float threshold;
    MWCvHidHaarClassifier* classifier;
    int two_rects;

    struct MWCvHidHaarStageClassifier* next;
    struct MWCvHidHaarStageClassifier* child;
    struct MWCvHidHaarStageClassifier* parent;
} MWCvHidHaarStageClassifier;


typedef struct MWCvHidHaarClassifierCascade
{
    int  count;
    int  isStumpBased;
    int  has_tilted_features;
    int  is_tree;
    double inv_window_area;
    CvMat sum, sqsum, tilted;
    MWCvHidHaarStageClassifier* stage_classifier;
    sqsumtype *pq0, *pq1, *pq2, *pq3;
    sumtype *p0, *p1, *p2, *p3;

    void** ipp_stages;
} MWCvHidHaarClassifierCascade;


const int icv_object_win_border = 1;
const float icv_stage_threshold_bias = 0.0001f;

static MWCvHaarClassifierCascade*
icvCreateHaarClassifierCascade( int stage_count )
{
    MWCvHaarClassifierCascade* cascade = 0;

    int block_size = sizeof(*cascade) + stage_count*sizeof(*cascade->stage_classifier);

    if( stage_count <= 0 )
        CV_Error( CV_StsOutOfRange, "Number of stages should be positive" );

    cascade = (MWCvHaarClassifierCascade*)cvAlloc( block_size );
    memset( cascade, 0, block_size );

    cascade->stage_classifier = (MWCvHaarStageClassifier*)(cascade + 1);
    cascade->flags = MWCV_HAAR_MAGIC_VAL;
    cascade->count = stage_count;

    return cascade;
}

static void
icvReleaseHidHaarClassifierCascade( MWCvHidHaarClassifierCascade** _cascade )
{
    if( _cascade && *_cascade )
    {
#ifdef HAVE_IPP
        MWCvHidHaarClassifierCascade* cascade = *_cascade;
        if( cascade->ipp_stages )
        {
            int i;
            for( i = 0; i < cascade->count; i++ )
            {
                if( cascade->ipp_stages[i] )
                    ippiHaarClassifierFree_32f( (IppiHaarClassifier_32f*)cascade->ipp_stages[i] );
            }
        }
        cvFree( &cascade->ipp_stages );
#endif
        cvFree( _cascade );
    }
}

/* create more efficient internal representation of haar classifier cascade */
static MWCvHidHaarClassifierCascade*
icvCreateHidHaarClassifierCascade( MWCvHaarClassifierCascade* cascade )
{
    CvRect* ipp_features = 0;
    float *ipp_weights = 0, *ipp_thresholds = 0, *ipp_val1 = 0, *ipp_val2 = 0;
    int* ipp_counts = 0;

    MWCvHidHaarClassifierCascade* out = 0;

    int i, j, k, l;
    int datasize;
    int total_classifiers = 0;
    int total_nodes = 0;
    char errorstr[1000];
    MWCvHidHaarClassifier* haar_classifier_ptr;
    MWCvHidHaarTreeNode* haar_node_ptr;
    CvSize orig_window_size;
    int has_tilted_features = 0;
    int max_count = 0;

    if( !MWCV_IS_HAAR_CLASSIFIER(cascade) )
        CV_Error( !cascade ? CV_StsNullPtr : CV_StsBadArg, "Invalid classifier pointer" );

    if( cascade->hid_cascade )
        CV_Error( CV_StsError, "hid_cascade has been already created" );

    if( !cascade->stage_classifier )
        CV_Error( CV_StsNullPtr, "" );

    if( cascade->count <= 0 )
        CV_Error( CV_StsOutOfRange, "Negative number of cascade stages" );

    orig_window_size = cascade->orig_window_size;

    /* check input structure correctness and calculate total memory size needed for
       internal representation of the classifier cascade */
    for( i = 0; i < cascade->count; i++ )
    {
        MWCvHaarStageClassifier* stage_classifier = cascade->stage_classifier + i;

        if( !stage_classifier->classifier ||
            stage_classifier->count <= 0 )
        {
            sprintf( errorstr, "header of the stage classifier #%d is invalid "
                     "(has null pointers or non-positive classfier count)", i );
            CV_Error( CV_StsError, errorstr );
        }

        max_count = MAX( max_count, stage_classifier->count );
        total_classifiers += stage_classifier->count;

        for( j = 0; j < stage_classifier->count; j++ )
        {
            MWCvHaarClassifier* classifier = stage_classifier->classifier + j;

            total_nodes += classifier->count;
            for( l = 0; l < classifier->count; l++ )
            {
                for( k = 0; k < CV_HAAR_FEATURE_MAX; k++ )
                {
                    if( classifier->haar_feature[l].rect[k].r.width )
                    {
                        CvRect r = classifier->haar_feature[l].rect[k].r;
                        int tilted = classifier->haar_feature[l].tilted;
                        has_tilted_features |= tilted != 0;
                        if( r.width < 0 || r.height < 0 || r.y < 0 ||
                            r.x + r.width > orig_window_size.width
                            ||
                            (!tilted &&
                            (r.x < 0 || r.y + r.height > orig_window_size.height))
                            ||
                            (tilted && (r.x - r.height < 0 ||
                            r.y + r.width + r.height > orig_window_size.height)))
                        {
                            sprintf( errorstr, "rectangle #%d of the classifier #%d of "
                                     "the stage classifier #%d is not inside "
                                     "the reference (original) cascade window", k, j, i );
                            CV_Error( CV_StsNullPtr, errorstr );
                        }
                    }
                }
            }
        }
    }

    // this is an upper boundary for the whole hidden cascade size
    datasize = sizeof(MWCvHidHaarClassifierCascade) +
               sizeof(MWCvHidHaarStageClassifier)*cascade->count +
               sizeof(MWCvHidHaarClassifier) * total_classifiers +
               sizeof(MWCvHidHaarTreeNode) * total_nodes +
               sizeof(void*)*(total_nodes + total_classifiers);

    out = (MWCvHidHaarClassifierCascade*)cvAlloc( datasize );
    memset( out, 0, sizeof(*out) );

    /* init header */
    out->count = cascade->count;
    out->stage_classifier = (MWCvHidHaarStageClassifier*)(out + 1);
    haar_classifier_ptr = (MWCvHidHaarClassifier*)(out->stage_classifier + cascade->count);
    haar_node_ptr = (MWCvHidHaarTreeNode*)(haar_classifier_ptr + total_classifiers);

    out->isStumpBased = 1;
    out->has_tilted_features = has_tilted_features;
    out->is_tree = 0;

    /* initialize internal representation */
    for( i = 0; i < cascade->count; i++ )
    {
        MWCvHaarStageClassifier* stage_classifier = cascade->stage_classifier + i;
        MWCvHidHaarStageClassifier* hid_stage_classifier = out->stage_classifier + i;

        hid_stage_classifier->count = stage_classifier->count;
        hid_stage_classifier->threshold = stage_classifier->threshold - icv_stage_threshold_bias;
        hid_stage_classifier->classifier = haar_classifier_ptr;
        hid_stage_classifier->two_rects = 1;
        haar_classifier_ptr += stage_classifier->count;

        hid_stage_classifier->parent = (stage_classifier->parent == -1)
            ? NULL : out->stage_classifier + stage_classifier->parent;
        hid_stage_classifier->next = (stage_classifier->next == -1)
            ? NULL : out->stage_classifier + stage_classifier->next;
        hid_stage_classifier->child = (stage_classifier->child == -1)
            ? NULL : out->stage_classifier + stage_classifier->child;

        out->is_tree |= hid_stage_classifier->next != NULL;

        for( j = 0; j < stage_classifier->count; j++ )
        {
            MWCvHaarClassifier* classifier = stage_classifier->classifier + j;
            MWCvHidHaarClassifier* hid_classifier = hid_stage_classifier->classifier + j;
            int node_count = classifier->count;
            float* alpha_ptr = (float*)(haar_node_ptr + node_count);

            hid_classifier->count = node_count;
            hid_classifier->node = haar_node_ptr;
            hid_classifier->alpha = alpha_ptr;

            for( l = 0; l < node_count; l++ )
            {
                MWCvHidHaarTreeNode* node = hid_classifier->node + l;
                MWCvHaarFeature* feature = classifier->haar_feature + l;
                memset( node, -1, sizeof(*node) );
                node->threshold = classifier->threshold[l];
                node->left = classifier->left[l];
                node->right = classifier->right[l];

                if( fabs(feature->rect[2].weight) < DBL_EPSILON ||
                    feature->rect[2].r.width == 0 ||
                    feature->rect[2].r.height == 0 )
                    memset( &(node->feature.rect[2]), 0, sizeof(node->feature.rect[2]) );
                else
                    hid_stage_classifier->two_rects = 0;
            }

            memcpy( alpha_ptr, classifier->alpha, (node_count+1)*sizeof(alpha_ptr[0]));
            haar_node_ptr =
                (MWCvHidHaarTreeNode*)cvAlignPtr(alpha_ptr+node_count+1, sizeof(void*));

            out->isStumpBased &= node_count == 1;
        }
    }
/*
#ifdef HAVE_IPP
    int can_use_ipp = !out->has_tilted_features && !out->is_tree && out->isStumpBased;

    if( can_use_ipp )
    {
        int ipp_datasize = cascade->count*sizeof(out->ipp_stages[0]);
        float ipp_weight_scale=(float)(1./((orig_window_size.width-icv_object_win_border*2)*
            (orig_window_size.height-icv_object_win_border*2)));

        out->ipp_stages = (void**)cvAlloc( ipp_datasize );
        memset( out->ipp_stages, 0, ipp_datasize );

        ipp_features = (CvRect*)cvAlloc( max_count*3*sizeof(ipp_features[0]) );
        ipp_weights = (float*)cvAlloc( max_count*3*sizeof(ipp_weights[0]) );
        ipp_thresholds = (float*)cvAlloc( max_count*sizeof(ipp_thresholds[0]) );
        ipp_val1 = (float*)cvAlloc( max_count*sizeof(ipp_val1[0]) );
        ipp_val2 = (float*)cvAlloc( max_count*sizeof(ipp_val2[0]) );
        ipp_counts = (int*)cvAlloc( max_count*sizeof(ipp_counts[0]) );

        for( i = 0; i < cascade->count; i++ )
        {
            MWCvHaarStageClassifier* stage_classifier = cascade->stage_classifier + i;
            for( j = 0, k = 0; j < stage_classifier->count; j++ )
            {
                MWCvHaarClassifier* classifier = stage_classifier->classifier + j;
                int rect_count = 2 + (classifier->haar_feature->rect[2].r.width != 0);

                ipp_thresholds[j] = classifier->threshold[0];
                ipp_val1[j] = classifier->alpha[0];
                ipp_val2[j] = classifier->alpha[1];
                ipp_counts[j] = rect_count;

                for( l = 0; l < rect_count; l++, k++ )
                {
                    ipp_features[k] = classifier->haar_feature->rect[l].r;
                    //ipp_features[k].y = orig_window_size.height - ipp_features[k].y - ipp_features[k].height;
                    ipp_weights[k] = classifier->haar_feature->rect[l].weight*ipp_weight_scale;
                }
            }

            if( ippiHaarClassifierInitAlloc_32f( (IppiHaarClassifier_32f**)&out->ipp_stages[i],
                (const IppiRect*)ipp_features, ipp_weights, ipp_thresholds,
                ipp_val1, ipp_val2, ipp_counts, stage_classifier->count ) < 0 )
                break;
        }

        if( i < cascade->count )
        {
            for( j = 0; j < i; j++ )
                if( out->ipp_stages[i] )
                    ippiHaarClassifierFree_32f( (IppiHaarClassifier_32f*)out->ipp_stages[i] );
            cvFree( &out->ipp_stages );
        }
    }
#endif
*/
    cascade->hid_cascade = out;
    assert( (char*)haar_node_ptr - (char*)out <= datasize );

    cvFree( &ipp_features );
    cvFree( &ipp_weights );
    cvFree( &ipp_thresholds );
    cvFree( &ipp_val1 );
    cvFree( &ipp_val2 );
    cvFree( &ipp_counts );

    return out;
}


#define sum_elem_ptr(sum,row,col)  \
    ((sumtype*)CV_MAT_ELEM_PTR_FAST((sum),(row),(col),sizeof(sumtype)))

#define sqsum_elem_ptr(sqsum,row,col)  \
    ((sqsumtype*)CV_MAT_ELEM_PTR_FAST((sqsum),(row),(col),sizeof(sqsumtype)))

#define calc_sum(rect,offset) \
    ((rect).p0[offset] - (rect).p1[offset] - (rect).p2[offset] + (rect).p3[offset])

#define calc_sumf(rect,offset) \
    static_cast<float>((rect).p0[offset] - (rect).p1[offset] - (rect).p2[offset] + (rect).p3[offset])


CV_IMPL void
cvSetImagesForHaarClassifierCascade( MWCvHaarClassifierCascade* _cascade,
                                     const CvArr* _sum,
                                     const CvArr* _sqsum,
                                     const CvArr* _tilted_sum,
                                     double scale )
{
    CvMat sum_stub, *sum = (CvMat*)_sum;
    CvMat sqsum_stub, *sqsum = (CvMat*)_sqsum;
    CvMat tilted_stub, *tilted = (CvMat*)_tilted_sum;
    MWCvHidHaarClassifierCascade* cascade;
    int coi0 = 0, coi1 = 0;
    int i;
    CvRect equRect;
    double weight_scale;

    if( !MWCV_IS_HAAR_CLASSIFIER(_cascade) )
        CV_Error( !_cascade ? CV_StsNullPtr : CV_StsBadArg, "Invalid classifier pointer" );

    if( scale <= 0 )
        CV_Error( CV_StsOutOfRange, "Scale must be positive" );

    sum = cvGetMat( sum, &sum_stub, &coi0 );
    sqsum = cvGetMat( sqsum, &sqsum_stub, &coi1 );

    if( coi0 || coi1 )
        CV_Error( CV_BadCOI, "COI is not supported" );

    if( !CV_ARE_SIZES_EQ( sum, sqsum ))
        CV_Error( CV_StsUnmatchedSizes, "All integral images must have the same size" );

    if( CV_MAT_TYPE(sqsum->type) != CV_64FC1 ||
        CV_MAT_TYPE(sum->type) != CV_32SC1 )
        CV_Error( CV_StsUnsupportedFormat,
        "Only (32s, 64f, 32s) combination of (sum,sqsum,tilted_sum) formats is allowed" );

    if( !_cascade->hid_cascade )
        icvCreateHidHaarClassifierCascade(_cascade);

    cascade = _cascade->hid_cascade;

    if( cascade->has_tilted_features )
    {
        tilted = cvGetMat( tilted, &tilted_stub, &coi1 );

        if( CV_MAT_TYPE(tilted->type) != CV_32SC1 )
            CV_Error( CV_StsUnsupportedFormat,
            "Only (32s, 64f, 32s) combination of (sum,sqsum,tilted_sum) formats is allowed" );

        if( sum->step != tilted->step )
            CV_Error( CV_StsUnmatchedSizes,
            "Sum and tilted_sum must have the same stride (step, widthStep)" );

        if( !CV_ARE_SIZES_EQ( sum, tilted ))
            CV_Error( CV_StsUnmatchedSizes, "All integral images must have the same size" );
        cascade->tilted = *tilted;
    }

    _cascade->scale = scale;
    _cascade->real_window_size.width = cvRound( _cascade->orig_window_size.width * scale );
    _cascade->real_window_size.height = cvRound( _cascade->orig_window_size.height * scale );

    cascade->sum = *sum;
    cascade->sqsum = *sqsum;

    equRect.x = equRect.y = cvRound(scale);
    equRect.width = cvRound((_cascade->orig_window_size.width-2)*scale);
    equRect.height = cvRound((_cascade->orig_window_size.height-2)*scale);
    weight_scale = 1./(equRect.width*equRect.height);
    cascade->inv_window_area = weight_scale;

    cascade->p0 = sum_elem_ptr(*sum, equRect.y, equRect.x);
    cascade->p1 = sum_elem_ptr(*sum, equRect.y, equRect.x + equRect.width );
    cascade->p2 = sum_elem_ptr(*sum, equRect.y + equRect.height, equRect.x );
    cascade->p3 = sum_elem_ptr(*sum, equRect.y + equRect.height,
                                     equRect.x + equRect.width );

    cascade->pq0 = sqsum_elem_ptr(*sqsum, equRect.y, equRect.x);
    cascade->pq1 = sqsum_elem_ptr(*sqsum, equRect.y, equRect.x + equRect.width );
    cascade->pq2 = sqsum_elem_ptr(*sqsum, equRect.y + equRect.height, equRect.x );
    cascade->pq3 = sqsum_elem_ptr(*sqsum, equRect.y + equRect.height,
                                          equRect.x + equRect.width );

    /* init pointers in haar features according to real window size and
       given image pointers */
    for( i = 0; i < _cascade->count; i++ )
    {
        int j, k, l;
        for( j = 0; j < cascade->stage_classifier[i].count; j++ )
        {
            for( l = 0; l < cascade->stage_classifier[i].classifier[j].count; l++ )
            {
                MWCvHaarFeature* feature =
                    &_cascade->stage_classifier[i].classifier[j].haar_feature[l];
                /* MWCvHidHaarClassifier* classifier =
                    cascade->stage_classifier[i].classifier + j; */
                MWCvHidHaarFeature* hidfeature =
                    &cascade->stage_classifier[i].classifier[j].node[l].feature;
                double sum0 = 0, area0 = 0;
                CvRect r[3];

                int base_w = -1, base_h = -1;
                int new_base_w = 0, new_base_h = 0;
                int kx, ky;
                int flagx = 0, flagy = 0;
                int x0 = 0, y0 = 0;
                int nr;

                /* align blocks */
                for( k = 0; k < CV_HAAR_FEATURE_MAX; k++ )
                {
                    if( !hidfeature->rect[k].p0 )
                        break;
                    r[k] = feature->rect[k].r;
                    base_w = (int)CV_IMIN( (unsigned)base_w, (unsigned)(r[k].width-1) );
                    base_w = (int)CV_IMIN( (unsigned)base_w, (unsigned)(r[k].x - r[0].x-1) );
                    base_h = (int)CV_IMIN( (unsigned)base_h, (unsigned)(r[k].height-1) );
                    base_h = (int)CV_IMIN( (unsigned)base_h, (unsigned)(r[k].y - r[0].y-1) );
                }

                nr = k;

                base_w += 1;
                base_h += 1;
                kx = r[0].width / base_w;
                ky = r[0].height / base_h;

                if( kx <= 0 )
                {
                    flagx = 1;
                    new_base_w = cvRound( r[0].width * scale ) / kx;
                    x0 = cvRound( r[0].x * scale );
                }

                if( ky <= 0 )
                {
                    flagy = 1;
                    new_base_h = cvRound( r[0].height * scale ) / ky;
                    y0 = cvRound( r[0].y * scale );
                }

                for( k = 0; k < nr; k++ )
                {
                    CvRect tr;
                    double correction_ratio;

                    if( flagx )
                    {
                        tr.x = (r[k].x - r[0].x) * new_base_w / base_w + x0;
                        tr.width = r[k].width * new_base_w / base_w;
                    }
                    else
                    {
                        tr.x = cvRound( r[k].x * scale );
                        tr.width = cvRound( r[k].width * scale );
                    }

                    if( flagy )
                    {
                        tr.y = (r[k].y - r[0].y) * new_base_h / base_h + y0;
                        tr.height = r[k].height * new_base_h / base_h;
                    }
                    else
                    {
                        tr.y = cvRound( r[k].y * scale );
                        tr.height = cvRound( r[k].height * scale );
                    }

#if CV_ADJUST_WEIGHTS
                    {
                    // RAINER START
                    const float orig_feature_size =  (float)(feature->rect[k].r.width)*feature->rect[k].r.height;
                    const float orig_norm_size = (float)(_cascade->orig_window_size.width)*(_cascade->orig_window_size.height);
                    const float feature_size = float(tr.width*tr.height);
                    //const float normSize    = float(equRect.width*equRect.height);
                    float target_ratio = orig_feature_size / orig_norm_size;
                    //float isRatio = featureSize / normSize;
                    //correctionRatio = targetRatio / isRatio / normSize;
                    correction_ratio = target_ratio / feature_size;
                    // RAINER END
                    }
#else
                    correction_ratio = weight_scale * (!feature->tilted ? 1 : 0.5);
#endif

                    if( !feature->tilted )
                    {
                        hidfeature->rect[k].p0 = sum_elem_ptr(*sum, tr.y, tr.x);
                        hidfeature->rect[k].p1 = sum_elem_ptr(*sum, tr.y, tr.x + tr.width);
                        hidfeature->rect[k].p2 = sum_elem_ptr(*sum, tr.y + tr.height, tr.x);
                        hidfeature->rect[k].p3 = sum_elem_ptr(*sum, tr.y + tr.height, tr.x + tr.width);
                    }
                    else
                    {
                        hidfeature->rect[k].p2 = sum_elem_ptr(*tilted, tr.y + tr.width, tr.x + tr.width);
                        hidfeature->rect[k].p3 = sum_elem_ptr(*tilted, tr.y + tr.width + tr.height,
                                                              tr.x + tr.width - tr.height);
                        hidfeature->rect[k].p0 = sum_elem_ptr(*tilted, tr.y, tr.x);
                        hidfeature->rect[k].p1 = sum_elem_ptr(*tilted, tr.y + tr.height, tr.x - tr.height);
                    }

                    hidfeature->rect[k].weight = (float)(feature->rect[k].weight * correction_ratio);

                    if( k == 0 )
                        area0 = tr.width * tr.height;
                    else
                        sum0 += hidfeature->rect[k].weight * tr.width * tr.height;
                }

                hidfeature->rect[0].weight = (float)(-sum0/area0);
            } /* l */
        } /* j */
    }
}


// AVX version icvEvalHidHaarClassifier.  Process 8 CvHidHaarClassifiers per call. Check AVX support before invocation!!
#ifdef CV_HAAR_USE_AVX
CV_INLINE
double icvEvalHidHaarClassifierAVX( MWCvHidHaarClassifier* classifier,
                                    double variance_norm_factor, size_t p_offset )
{
    int  CV_DECL_ALIGNED(32) idxV[8] = {0,0,0,0,0,0,0,0};
    uchar flags[8] = {0,0,0,0,0,0,0,0};
    MWCvHidHaarTreeNode* nodes[8];
    double res = 0;
    uchar exitConditionFlag = 0;
    for(;;)
    {
        float CV_DECL_ALIGNED(32) tmp[8] = {0,0,0,0,0,0,0,0};
        nodes[0] = (classifier+0)->node + idxV[0];
        nodes[1] = (classifier+1)->node + idxV[1];
        nodes[2] = (classifier+2)->node + idxV[2];
        nodes[3] = (classifier+3)->node + idxV[3];
        nodes[4] = (classifier+4)->node + idxV[4];
        nodes[5] = (classifier+5)->node + idxV[5];
        nodes[6] = (classifier+6)->node + idxV[6];
        nodes[7] = (classifier+7)->node + idxV[7];

        __m256 t = _mm256_set1_ps(static_cast<float>(variance_norm_factor));

        t = _mm256_mul_ps(t, _mm256_set_ps(nodes[7]->threshold,
                                           nodes[6]->threshold,
                                           nodes[5]->threshold,
                                           nodes[4]->threshold,
                                           nodes[3]->threshold,
                                           nodes[2]->threshold,
                                           nodes[1]->threshold,
                                           nodes[0]->threshold));

        __m256 offset = _mm256_set_ps(calc_sumf(nodes[7]->feature.rect[0], p_offset),
                                      calc_sumf(nodes[6]->feature.rect[0], p_offset),
                                      calc_sumf(nodes[5]->feature.rect[0], p_offset),
                                      calc_sumf(nodes[4]->feature.rect[0], p_offset),
                                      calc_sumf(nodes[3]->feature.rect[0], p_offset),
                                      calc_sumf(nodes[2]->feature.rect[0], p_offset),
                                      calc_sumf(nodes[1]->feature.rect[0], p_offset),
                                      calc_sumf(nodes[0]->feature.rect[0], p_offset));

        __m256 weight = _mm256_set_ps(nodes[7]->feature.rect[0].weight,
                                      nodes[6]->feature.rect[0].weight,
                                      nodes[5]->feature.rect[0].weight,
                                      nodes[4]->feature.rect[0].weight,
                                      nodes[3]->feature.rect[0].weight,
                                      nodes[2]->feature.rect[0].weight,
                                      nodes[1]->feature.rect[0].weight,
                                      nodes[0]->feature.rect[0].weight);

        __m256 sum = _mm256_mul_ps(offset, weight);

        offset = _mm256_set_ps(calc_sumf(nodes[7]->feature.rect[1], p_offset),
                               calc_sumf(nodes[6]->feature.rect[1], p_offset),
                               calc_sumf(nodes[5]->feature.rect[1], p_offset),
                               calc_sumf(nodes[4]->feature.rect[1], p_offset),
                               calc_sumf(nodes[3]->feature.rect[1], p_offset),
                               calc_sumf(nodes[2]->feature.rect[1], p_offset),
                               calc_sumf(nodes[1]->feature.rect[1], p_offset),
                               calc_sumf(nodes[0]->feature.rect[1], p_offset));

        weight = _mm256_set_ps(nodes[7]->feature.rect[1].weight,
                               nodes[6]->feature.rect[1].weight,
                               nodes[5]->feature.rect[1].weight,
                               nodes[4]->feature.rect[1].weight,
                               nodes[3]->feature.rect[1].weight,
                               nodes[2]->feature.rect[1].weight,
                               nodes[1]->feature.rect[1].weight,
                               nodes[0]->feature.rect[1].weight);

        sum = _mm256_add_ps(sum, _mm256_mul_ps(offset, weight));

        if( nodes[0]->feature.rect[2].p0 )
            tmp[0] = calc_sumf(nodes[0]->feature.rect[2], p_offset) * nodes[0]->feature.rect[2].weight;
        if( nodes[1]->feature.rect[2].p0 )
            tmp[1] = calc_sumf(nodes[1]->feature.rect[2], p_offset) * nodes[1]->feature.rect[2].weight;
        if( nodes[2]->feature.rect[2].p0 )
            tmp[2] = calc_sumf(nodes[2]->feature.rect[2], p_offset) * nodes[2]->feature.rect[2].weight;
        if( nodes[3]->feature.rect[2].p0 )
            tmp[3] = calc_sumf(nodes[3]->feature.rect[2], p_offset) * nodes[3]->feature.rect[2].weight;
        if( nodes[4]->feature.rect[2].p0 )
            tmp[4] = calc_sumf(nodes[4]->feature.rect[2], p_offset) * nodes[4]->feature.rect[2].weight;
        if( nodes[5]->feature.rect[2].p0 )
            tmp[5] = calc_sumf(nodes[5]->feature.rect[2], p_offset) * nodes[5]->feature.rect[2].weight;
        if( nodes[6]->feature.rect[2].p0 )
            tmp[6] = calc_sumf(nodes[6]->feature.rect[2], p_offset) * nodes[6]->feature.rect[2].weight;
        if( nodes[7]->feature.rect[2].p0 )
            tmp[7] = calc_sumf(nodes[7]->feature.rect[2], p_offset) * nodes[7]->feature.rect[2].weight;

        sum = _mm256_add_ps(sum,_mm256_load_ps(tmp));

        __m256 left  = _mm256_set_ps(static_cast<float>(nodes[7]->left), static_cast<float>(nodes[6]->left),
                                     static_cast<float>(nodes[5]->left), static_cast<float>(nodes[4]->left),
                                     static_cast<float>(nodes[3]->left), static_cast<float>(nodes[2]->left),
                                     static_cast<float>(nodes[1]->left), static_cast<float>(nodes[0]->left));
        __m256 right = _mm256_set_ps(static_cast<float>(nodes[7]->right),static_cast<float>(nodes[6]->right),
                                     static_cast<float>(nodes[5]->right),static_cast<float>(nodes[4]->right),
                                     static_cast<float>(nodes[3]->right),static_cast<float>(nodes[2]->right),
                                     static_cast<float>(nodes[1]->right),static_cast<float>(nodes[0]->right));

        _mm256_store_si256((__m256i*)idxV, _mm256_cvttps_epi32(_mm256_blendv_ps(right, left, _mm256_cmp_ps(sum, t, _CMP_LT_OQ))));

        for(int i = 0; i < 8; i++)
        {
            if(idxV[i]<=0)
            {
                if(!flags[i])
                {
                    exitConditionFlag++;
                    flags[i] = 1;
                    res += (classifier+i)->alpha[-idxV[i]];
                }
                idxV[i]=0;
            }
        }
        if(exitConditionFlag == 8)
            return res;
    }
}
#endif //CV_HAAR_USE_AVX

CV_INLINE
double icvEvalHidHaarClassifier( MWCvHidHaarClassifier* classifier,
                                 double variance_norm_factor,
                                 size_t p_offset )
{
    int idx = 0;
    /*#if CV_HAAR_USE_SSE && !CV_HAAR_USE_AVX
        if(cv::checkHardwareSupport(CV_CPU_SSE2))//based on old SSE variant. Works slow
        {
            double CV_DECL_ALIGNED(16) temp[2];
            __m128d zero = _mm_setzero_pd();
            do
            {
                MWCvHidHaarTreeNode* node = classifier->node + idx;
                __m128d t = _mm_set1_pd((node->threshold)*variance_norm_factor);
                __m128d left = _mm_set1_pd(node->left);
                __m128d right = _mm_set1_pd(node->right);

                double _sum = calc_sum(node->feature.rect[0],p_offset) * node->feature.rect[0].weight;
                _sum += calc_sum(node->feature.rect[1],p_offset) * node->feature.rect[1].weight;
                if( node->feature.rect[2].p0 )
                    _sum += calc_sum(node->feature.rect[2],p_offset) * node->feature.rect[2].weight;

                __m128d sum = _mm_set1_pd(_sum);
                t = _mm_cmplt_sd(sum, t);
                sum = _mm_blendv_pd(right, left, t);

                _mm_store_pd(temp, sum);
                idx = (int)temp[0];
            }
            while(idx > 0 );

        }
        else
    #endif*/
    {
        do
        {
            MWCvHidHaarTreeNode* node = classifier->node + idx;
            double t = node->threshold * variance_norm_factor;

            double sum = calc_sum(node->feature.rect[0],p_offset) * node->feature.rect[0].weight;
            sum += calc_sum(node->feature.rect[1],p_offset) * node->feature.rect[1].weight;

            if( node->feature.rect[2].p0 )
                sum += calc_sum(node->feature.rect[2],p_offset) * node->feature.rect[2].weight;

            idx = sum < t ? node->left : node->right;
        }
        while( idx > 0 );
    }
    return classifier->alpha[-idx];
}



static int
cvRunHaarClassifierCascadeSum( const MWCvHaarClassifierCascade* _cascade,
                               CvPoint pt, double& stage_sum, int start_stage )
{
#ifdef CV_HAAR_USE_AVX
    bool haveAVX = false;
    if(cv::checkHardwareSupport(CV_CPU_AVX))
    if(__xgetbv()&0x6)// Check if the OS will save the YMM registers
       haveAVX = true;
#else
#  ifdef CV_HAAR_USE_SSE
    bool haveSSE2 = cv::checkHardwareSupport(CV_CPU_SSE2);
#  endif
#endif

    int p_offset, pq_offset;
    int i, j;
    double mean, variance_norm_factor;
    MWCvHidHaarClassifierCascade* cascade;

    if( !MWCV_IS_HAAR_CLASSIFIER(_cascade) )
        CV_Error( !_cascade ? CV_StsNullPtr : CV_StsBadArg, "Invalid cascade pointer" );

    cascade = _cascade->hid_cascade;
    if( !cascade )
        CV_Error( CV_StsNullPtr, "Hidden cascade has not been created.\n"
            "Use cvSetImagesForHaarClassifierCascade" );

    if( pt.x < 0 || pt.y < 0 ||
        pt.x + _cascade->real_window_size.width >= cascade->sum.width ||
        pt.y + _cascade->real_window_size.height >= cascade->sum.height )
        return -1;

    p_offset = pt.y * (cascade->sum.step/sizeof(sumtype)) + pt.x;
    pq_offset = pt.y * (cascade->sqsum.step/sizeof(sqsumtype)) + pt.x;
    mean = calc_sum(*cascade,p_offset)*cascade->inv_window_area;
    variance_norm_factor = cascade->pq0[pq_offset] - cascade->pq1[pq_offset] -
                           cascade->pq2[pq_offset] + cascade->pq3[pq_offset];
    variance_norm_factor = variance_norm_factor*cascade->inv_window_area - mean*mean;
    if( variance_norm_factor >= 0. )
        variance_norm_factor = sqrt(variance_norm_factor);
    else
        variance_norm_factor = 1.;

    if( cascade->is_tree )
    {
        MWCvHidHaarStageClassifier* ptr = cascade->stage_classifier;
        assert( start_stage == 0 );

        while( ptr )
        {
            stage_sum = 0.0;
            j = 0;

#ifdef CV_HAAR_USE_AVX
            if(haveAVX)
            {
                for( ; j <= ptr->count - 8; j += 8 )
                {
                    stage_sum += icvEvalHidHaarClassifierAVX(
                        ptr->classifier + j,
                        variance_norm_factor, p_offset );
                }
            }
#endif
            for( ; j < ptr->count; j++ )
            {
                stage_sum += icvEvalHidHaarClassifier( ptr->classifier + j, variance_norm_factor, p_offset );
            }

            if( stage_sum >= ptr->threshold )
            {
                ptr = ptr->child;
            }
            else
            {
                while( ptr && ptr->next == NULL ) ptr = ptr->parent;
                if( ptr == NULL )
                    return 0;
                ptr = ptr->next;
            }
        }
    }
    else if( cascade->isStumpBased )
    {
#ifdef CV_HAAR_USE_AVX
        if(haveAVX)
        {
            MWCvHidHaarClassifier* classifiers[8];
            MWCvHidHaarTreeNode* nodes[8];
            for( i = start_stage; i < cascade->count; i++ )
            {
                stage_sum = 0.0;
                j = 0;
                float CV_DECL_ALIGNED(32) buf[8];
                if( cascade->stage_classifier[i].two_rects )
                {
                    for( ; j <= cascade->stage_classifier[i].count - 8; j += 8 )
                    {
                        classifiers[0] = cascade->stage_classifier[i].classifier + j;
                        nodes[0] = classifiers[0]->node;
                        classifiers[1] = cascade->stage_classifier[i].classifier + j + 1;
                        nodes[1] = classifiers[1]->node;
                        classifiers[2] = cascade->stage_classifier[i].classifier + j + 2;
                        nodes[2] = classifiers[2]->node;
                        classifiers[3] = cascade->stage_classifier[i].classifier + j + 3;
                        nodes[3] = classifiers[3]->node;
                        classifiers[4] = cascade->stage_classifier[i].classifier + j + 4;
                        nodes[4] = classifiers[4]->node;
                        classifiers[5] = cascade->stage_classifier[i].classifier + j + 5;
                        nodes[5] = classifiers[5]->node;
                        classifiers[6] = cascade->stage_classifier[i].classifier + j + 6;
                        nodes[6] = classifiers[6]->node;
                        classifiers[7] = cascade->stage_classifier[i].classifier + j + 7;
                        nodes[7] = classifiers[7]->node;

                        __m256 t = _mm256_set1_ps(static_cast<float>(variance_norm_factor));
                        t = _mm256_mul_ps(t, _mm256_set_ps(nodes[7]->threshold,
                                                           nodes[6]->threshold,
                                                           nodes[5]->threshold,
                                                           nodes[4]->threshold,
                                                           nodes[3]->threshold,
                                                           nodes[2]->threshold,
                                                           nodes[1]->threshold,
                                                           nodes[0]->threshold));

                        __m256 offset = _mm256_set_ps(calc_sumf(nodes[7]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[6]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[5]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[4]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[3]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[2]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[1]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[0]->feature.rect[0], p_offset));

                        __m256 weight = _mm256_set_ps(nodes[7]->feature.rect[0].weight,
                                                      nodes[6]->feature.rect[0].weight,
                                                      nodes[5]->feature.rect[0].weight,
                                                      nodes[4]->feature.rect[0].weight,
                                                      nodes[3]->feature.rect[0].weight,
                                                      nodes[2]->feature.rect[0].weight,
                                                      nodes[1]->feature.rect[0].weight,
                                                      nodes[0]->feature.rect[0].weight);

                        __m256 sum = _mm256_mul_ps(offset, weight);

                        offset = _mm256_set_ps(calc_sumf(nodes[7]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[6]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[5]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[4]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[3]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[2]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[1]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[0]->feature.rect[1], p_offset));

                        weight = _mm256_set_ps(nodes[7]->feature.rect[1].weight,
                                               nodes[6]->feature.rect[1].weight,
                                               nodes[5]->feature.rect[1].weight,
                                               nodes[4]->feature.rect[1].weight,
                                               nodes[3]->feature.rect[1].weight,
                                               nodes[2]->feature.rect[1].weight,
                                               nodes[1]->feature.rect[1].weight,
                                               nodes[0]->feature.rect[1].weight);

                        sum = _mm256_add_ps(sum, _mm256_mul_ps(offset,weight));

                        __m256 alpha0 = _mm256_set_ps(classifiers[7]->alpha[0],
                                                      classifiers[6]->alpha[0],
                                                      classifiers[5]->alpha[0],
                                                      classifiers[4]->alpha[0],
                                                      classifiers[3]->alpha[0],
                                                      classifiers[2]->alpha[0],
                                                      classifiers[1]->alpha[0],
                                                      classifiers[0]->alpha[0]);
                        __m256 alpha1 = _mm256_set_ps(classifiers[7]->alpha[1],
                                                      classifiers[6]->alpha[1],
                                                      classifiers[5]->alpha[1],
                                                      classifiers[4]->alpha[1],
                                                      classifiers[3]->alpha[1],
                                                      classifiers[2]->alpha[1],
                                                      classifiers[1]->alpha[1],
                                                      classifiers[0]->alpha[1]);

                        _mm256_store_ps(buf, _mm256_blendv_ps(alpha0, alpha1, _mm256_cmp_ps(t, sum, _CMP_LE_OQ)));
                        stage_sum += (buf[0]+buf[1]+buf[2]+buf[3]+buf[4]+buf[5]+buf[6]+buf[7]);
                    }

                    for( ; j < cascade->stage_classifier[i].count; j++ )
                    {
                        MWCvHidHaarClassifier* classifier = cascade->stage_classifier[i].classifier + j;
                        MWCvHidHaarTreeNode* node = classifier->node;

                        double t = node->threshold*variance_norm_factor;
                        double sum = calc_sum(node->feature.rect[0],p_offset) * node->feature.rect[0].weight;
                        sum += calc_sum(node->feature.rect[1],p_offset) * node->feature.rect[1].weight;
                        stage_sum += classifier->alpha[sum >= t];
                    }
                }
                else
                {
                    for( ; j <= (cascade->stage_classifier[i].count)-8; j+=8 )
                    {
                        float  CV_DECL_ALIGNED(32) tmp[8] = {0,0,0,0,0,0,0,0};

                        classifiers[0] = cascade->stage_classifier[i].classifier + j;
                        nodes[0] = classifiers[0]->node;
                        classifiers[1] = cascade->stage_classifier[i].classifier + j + 1;
                        nodes[1] = classifiers[1]->node;
                        classifiers[2] = cascade->stage_classifier[i].classifier + j + 2;
                        nodes[2] = classifiers[2]->node;
                        classifiers[3] = cascade->stage_classifier[i].classifier + j + 3;
                        nodes[3] = classifiers[3]->node;
                        classifiers[4] = cascade->stage_classifier[i].classifier + j + 4;
                        nodes[4] = classifiers[4]->node;
                        classifiers[5] = cascade->stage_classifier[i].classifier + j + 5;
                        nodes[5] = classifiers[5]->node;
                        classifiers[6] = cascade->stage_classifier[i].classifier + j + 6;
                        nodes[6] = classifiers[6]->node;
                        classifiers[7] = cascade->stage_classifier[i].classifier + j + 7;
                        nodes[7] = classifiers[7]->node;

                        __m256 t = _mm256_set1_ps(static_cast<float>(variance_norm_factor));

                        t = _mm256_mul_ps(t, _mm256_set_ps(nodes[7]->threshold,
                                                           nodes[6]->threshold,
                                                           nodes[5]->threshold,
                                                           nodes[4]->threshold,
                                                           nodes[3]->threshold,
                                                           nodes[2]->threshold,
                                                           nodes[1]->threshold,
                                                           nodes[0]->threshold));

                        __m256 offset = _mm256_set_ps(calc_sumf(nodes[7]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[6]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[5]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[4]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[3]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[2]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[1]->feature.rect[0], p_offset),
                                                      calc_sumf(nodes[0]->feature.rect[0], p_offset));

                        __m256 weight = _mm256_set_ps(nodes[7]->feature.rect[0].weight,
                                                      nodes[6]->feature.rect[0].weight,
                                                      nodes[5]->feature.rect[0].weight,
                                                      nodes[4]->feature.rect[0].weight,
                                                      nodes[3]->feature.rect[0].weight,
                                                      nodes[2]->feature.rect[0].weight,
                                                      nodes[1]->feature.rect[0].weight,
                                                      nodes[0]->feature.rect[0].weight);

                        __m256 sum = _mm256_mul_ps(offset, weight);

                        offset = _mm256_set_ps(calc_sumf(nodes[7]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[6]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[5]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[4]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[3]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[2]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[1]->feature.rect[1], p_offset),
                                               calc_sumf(nodes[0]->feature.rect[1], p_offset));

                        weight = _mm256_set_ps(nodes[7]->feature.rect[1].weight,
                                               nodes[6]->feature.rect[1].weight,
                                               nodes[5]->feature.rect[1].weight,
                                               nodes[4]->feature.rect[1].weight,
                                               nodes[3]->feature.rect[1].weight,
                                               nodes[2]->feature.rect[1].weight,
                                               nodes[1]->feature.rect[1].weight,
                                               nodes[0]->feature.rect[1].weight);

                        sum = _mm256_add_ps(sum, _mm256_mul_ps(offset, weight));

                        if( nodes[0]->feature.rect[2].p0 )
                            tmp[0] = calc_sumf(nodes[0]->feature.rect[2],p_offset) * nodes[0]->feature.rect[2].weight;
                        if( nodes[1]->feature.rect[2].p0 )
                            tmp[1] = calc_sumf(nodes[1]->feature.rect[2],p_offset) * nodes[1]->feature.rect[2].weight;
                        if( nodes[2]->feature.rect[2].p0 )
                            tmp[2] = calc_sumf(nodes[2]->feature.rect[2],p_offset) * nodes[2]->feature.rect[2].weight;
                        if( nodes[3]->feature.rect[2].p0 )
                            tmp[3] = calc_sumf(nodes[3]->feature.rect[2],p_offset) * nodes[3]->feature.rect[2].weight;
                        if( nodes[4]->feature.rect[2].p0 )
                            tmp[4] = calc_sumf(nodes[4]->feature.rect[2],p_offset) * nodes[4]->feature.rect[2].weight;
                        if( nodes[5]->feature.rect[2].p0 )
                            tmp[5] = calc_sumf(nodes[5]->feature.rect[2],p_offset) * nodes[5]->feature.rect[2].weight;
                        if( nodes[6]->feature.rect[2].p0 )
                            tmp[6] = calc_sumf(nodes[6]->feature.rect[2],p_offset) * nodes[6]->feature.rect[2].weight;
                        if( nodes[7]->feature.rect[2].p0 )
                            tmp[7] = calc_sumf(nodes[7]->feature.rect[2],p_offset) * nodes[7]->feature.rect[2].weight;

                        sum = _mm256_add_ps(sum, _mm256_load_ps(tmp));

                        __m256 alpha0 = _mm256_set_ps(classifiers[7]->alpha[0],
                                                      classifiers[6]->alpha[0],
                                                      classifiers[5]->alpha[0],
                                                      classifiers[4]->alpha[0],
                                                      classifiers[3]->alpha[0],
                                                      classifiers[2]->alpha[0],
                                                      classifiers[1]->alpha[0],
                                                      classifiers[0]->alpha[0]);
                        __m256 alpha1 = _mm256_set_ps(classifiers[7]->alpha[1],
                                                      classifiers[6]->alpha[1],
                                                      classifiers[5]->alpha[1],
                                                      classifiers[4]->alpha[1],
                                                      classifiers[3]->alpha[1],
                                                      classifiers[2]->alpha[1],
                                                      classifiers[1]->alpha[1],
                                                      classifiers[0]->alpha[1]);

                        __m256 outBuf = _mm256_blendv_ps(alpha0, alpha1, _mm256_cmp_ps(t, sum, _CMP_LE_OQ ));
                        outBuf = _mm256_hadd_ps(outBuf, outBuf);
                        outBuf = _mm256_hadd_ps(outBuf, outBuf);
                        _mm256_store_ps(buf, outBuf);
                        stage_sum += (buf[0] + buf[4]);
                    }

                    for( ; j < cascade->stage_classifier[i].count; j++ )
                    {
                        MWCvHidHaarClassifier* classifier = cascade->stage_classifier[i].classifier + j;
                        MWCvHidHaarTreeNode* node = classifier->node;

                        double t = node->threshold*variance_norm_factor;
                        double sum = calc_sum(node->feature.rect[0],p_offset) * node->feature.rect[0].weight;
                        sum += calc_sum(node->feature.rect[1],p_offset) * node->feature.rect[1].weight;
                        if( node->feature.rect[2].p0 )
                            sum += calc_sum(node->feature.rect[2],p_offset) * node->feature.rect[2].weight;
                        stage_sum += classifier->alpha[sum >= t];
                    }
                }
                if( stage_sum < cascade->stage_classifier[i].threshold )
                    return -i;
            }
        }
        else
#elif defined CV_HAAR_USE_SSE //old SSE optimization
        if(haveSSE2)
        {
            for( i = start_stage; i < cascade->count; i++ )
            {
                __m128d vstage_sum = _mm_setzero_pd();
                if( cascade->stage_classifier[i].two_rects )
                {
                    for( j = 0; j < cascade->stage_classifier[i].count; j++ )
                    {
                        MWCvHidHaarClassifier* classifier = cascade->stage_classifier[i].classifier + j;
                        MWCvHidHaarTreeNode* node = classifier->node;

                        // ayasin - NHM perf optim. Avoid use of costly flaky jcc
                        __m128d t = _mm_set_sd(node->threshold*variance_norm_factor);
                        __m128d a = _mm_set_sd(classifier->alpha[0]);
                        __m128d b = _mm_set_sd(classifier->alpha[1]);
                        __m128d sum = _mm_set_sd(calc_sum(node->feature.rect[0],p_offset) * node->feature.rect[0].weight +
                                                 calc_sum(node->feature.rect[1],p_offset) * node->feature.rect[1].weight);
                        t = _mm_cmpgt_sd(t, sum);
                        vstage_sum = _mm_add_sd(vstage_sum, _mm_blendv_pd(b, a, t));
                    }
                }
                else
                {
                    for( j = 0; j < cascade->stage_classifier[i].count; j++ )
                    {
                        MWCvHidHaarClassifier* classifier = cascade->stage_classifier[i].classifier + j;
                        MWCvHidHaarTreeNode* node = classifier->node;
                        // ayasin - NHM perf optim. Avoid use of costly flaky jcc
                        __m128d t = _mm_set_sd(node->threshold*variance_norm_factor);
                        __m128d a = _mm_set_sd(classifier->alpha[0]);
                        __m128d b = _mm_set_sd(classifier->alpha[1]);
                        double _sum = calc_sum(node->feature.rect[0],p_offset) * node->feature.rect[0].weight;
                        _sum += calc_sum(node->feature.rect[1],p_offset) * node->feature.rect[1].weight;
                        if( node->feature.rect[2].p0 )
                            _sum += calc_sum(node->feature.rect[2],p_offset) * node->feature.rect[2].weight;
                        __m128d sum = _mm_set_sd(_sum);

                        t = _mm_cmpgt_sd(t, sum);
                        vstage_sum = _mm_add_sd(vstage_sum, _mm_blendv_pd(b, a, t));
                    }
                }
                __m128d i_threshold = _mm_set1_pd(cascade->stage_classifier[i].threshold);
                if( _mm_comilt_sd(vstage_sum, i_threshold) )
                    return -i;
            }
        }
        else
#endif // AVX or SSE
        {
            for( i = start_stage; i < cascade->count; i++ )
            {
                stage_sum = 0.0;
                if( cascade->stage_classifier[i].two_rects )
                {
                    for( j = 0; j < cascade->stage_classifier[i].count; j++ )
                    {
                        MWCvHidHaarClassifier* classifier = cascade->stage_classifier[i].classifier + j;
                        MWCvHidHaarTreeNode* node = classifier->node;
                        double t = node->threshold*variance_norm_factor;
                        double sum = calc_sum(node->feature.rect[0],p_offset) * node->feature.rect[0].weight;
                        sum += calc_sum(node->feature.rect[1],p_offset) * node->feature.rect[1].weight;
                        stage_sum += classifier->alpha[sum >= t];
                    }
                }
                else
                {
                    for( j = 0; j < cascade->stage_classifier[i].count; j++ )
                    {
                        MWCvHidHaarClassifier* classifier = cascade->stage_classifier[i].classifier + j;
                        MWCvHidHaarTreeNode* node = classifier->node;
                        double t = node->threshold*variance_norm_factor;
                        double sum = calc_sum(node->feature.rect[0],p_offset) * node->feature.rect[0].weight;
                        sum += calc_sum(node->feature.rect[1],p_offset) * node->feature.rect[1].weight;
                        if( node->feature.rect[2].p0 )
                            sum += calc_sum(node->feature.rect[2],p_offset) * node->feature.rect[2].weight;
                        stage_sum += classifier->alpha[sum >= t];
                    }
                }
                if( stage_sum < cascade->stage_classifier[i].threshold )
                    return -i;
            }
        }
    }
    else
    {
        for( i = start_stage; i < cascade->count; i++ )
        {
            stage_sum = 0.0;
            int k = 0;

#ifdef CV_HAAR_USE_AVX
            if(haveAVX)
            {
                for( ; k < cascade->stage_classifier[i].count - 8; k += 8 )
                {
                    stage_sum += icvEvalHidHaarClassifierAVX(
                        cascade->stage_classifier[i].classifier + k,
                        variance_norm_factor, p_offset );
                }
            }
#endif
            for(; k < cascade->stage_classifier[i].count; k++ )
            {

                stage_sum += icvEvalHidHaarClassifier(
                    cascade->stage_classifier[i].classifier + k,
                    variance_norm_factor, p_offset );
            }

            if( stage_sum < cascade->stage_classifier[i].threshold )
                return -i;
        }
    }
    return 1;
}


CV_IMPL int
cvRunHaarClassifierCascade( const MWCvHaarClassifierCascade* _cascade,
                            CvPoint pt, int start_stage )
{
    double stage_sum;
    return cvRunHaarClassifierCascadeSum(_cascade, pt, stage_sum, start_stage);
}

namespace cv
{

class HaarDetectObjects_ScaleImage_Invoker : public ParallelLoopBody
{
public:
    HaarDetectObjects_ScaleImage_Invoker( const MWCvHaarClassifierCascade* _cascade,
                                          int _stripSize, double _factor,
                                          const Mat& _sum1, const Mat& _sqsum1, Mat* _norm1,
                                          Mat* _mask1, Rect _equRect, std::vector<Rect>& _vec,
                                          std::vector<int>& _levels, std::vector<double>& _weights,
                                          bool _outputLevels, Mutex *_mtx )
    {
        cascade = _cascade;
        stripSize = _stripSize;
        factor = _factor;
        sum1 = _sum1;
        sqsum1 = _sqsum1;
        norm1 = _norm1;
        mask1 = _mask1;
        equRect = _equRect;
        vec = &_vec;
        rejectLevels = _outputLevels ? &_levels : 0;
        levelWeights = _outputLevels ? &_weights : 0;
        mtx = _mtx;
    }

    void operator()( const Range& range ) const
    {
        Size winSize0 = cascade->orig_window_size;
        Size winSize(cvRound(winSize0.width*factor), cvRound(winSize0.height*factor));
        int y1 = range.start*stripSize, y2 = min(range.end*stripSize, sum1.rows - 1 - winSize0.height);

        if (y2 <= y1 || sum1.cols <= 1 + winSize0.width)
            return;

        Size ssz(sum1.cols - 1 - winSize0.width, y2 - y1);
        int x, y, ystep = factor > 2 ? 1 : 2;

#ifdef HAVE_IPP
        if( cascade->hid_cascade->ipp_stages )
        {
            IppiRect iequRect = {equRect.x, equRect.y, equRect.width, equRect.height};
            ippiRectStdDev_32f_C1R(sum1.ptr<float>(y1), sum1.step,
                                   sqsum1.ptr<double>(y1), sqsum1.step,
                                   norm1->ptr<float>(y1), norm1->step,
                                   ippiSize(ssz.width, ssz.height), iequRect );

            int positive = (ssz.width/ystep)*((ssz.height + ystep-1)/ystep);

            if( ystep == 1 )
                (*mask1) = Scalar::all(1);
            else
                for( y = y1; y < y2; y++ )
                {
                    uchar* mask1row = mask1->ptr(y);
                    memset( mask1row, 0, ssz.width );

                    if( y % ystep == 0 )
                        for( x = 0; x < ssz.width; x += ystep )
                            mask1row[x] = (uchar)1;
                }

            for( int j = 0; j < cascade->count; j++ )
            {
                if( ippiApplyHaarClassifier_32f_C1R(
                            sum1.ptr<float>(y1), sum1.step,
                            norm1->ptr<float>(y1), norm1->step,
                            mask1->ptr<uchar>(y1), mask1->step,
                            ippiSize(ssz.width, ssz.height), &positive,
                            cascade->hid_cascade->stage_classifier[j].threshold,
                            (IppiHaarClassifier_32f*)cascade->hid_cascade->ipp_stages[j]) < 0 )
                    positive = 0;
                if( positive <= 0 )
                    break;
            }

            if( positive > 0 )
                for( y = y1; y < y2; y += ystep )
                {
                    uchar* mask1row = mask1->ptr(y);
                    for( x = 0; x < ssz.width; x += ystep )
                        if( mask1row[x] != 0 )
                        {
                            mtx->lock();
                            vec->push_back(Rect(cvRound(x*factor), cvRound(y*factor),
                                                winSize.width, winSize.height));
                            mtx->unlock();
                            if( --positive == 0 )
                                break;
                        }
                    if( positive == 0 )
                        break;
                }
        }
        else
#endif // IPP
            for( y = y1; y < y2; y += ystep )
                for( x = 0; x < ssz.width; x += ystep )
                {
                    double gypWeight;
                    int result = cvRunHaarClassifierCascadeSum( cascade, cvPoint(x,y), gypWeight, 0 );
                    if( rejectLevels )
                    {
                        if( result == 1 )
                            result = -1*cascade->count;
                        if( cascade->count + result < 4 )
                        {
                            mtx->lock();
                            vec->push_back(Rect(cvRound(x*factor), cvRound(y*factor),
                                           winSize.width, winSize.height));
                            rejectLevels->push_back(-result);
                            levelWeights->push_back(gypWeight);
                            mtx->unlock();
                        }
                    }
                    else
                    {
                        if( result > 0 )
                        {
                            mtx->lock();
                            vec->push_back(Rect(cvRound(x*factor), cvRound(y*factor),
                                           winSize.width, winSize.height));
                            mtx->unlock();
                        }
                    }
                }
    }

    const MWCvHaarClassifierCascade* cascade;
    int stripSize;
    double factor;
    Mat sum1, sqsum1, *norm1, *mask1;
    Rect equRect;
    std::vector<Rect>* vec;
    std::vector<int>* rejectLevels;
    std::vector<double>* levelWeights;
    Mutex* mtx;
};


class HaarDetectObjects_ScaleCascade_Invoker : public ParallelLoopBody
{
public:
    HaarDetectObjects_ScaleCascade_Invoker( const MWCvHaarClassifierCascade* _cascade,
                                            Size _winsize, const Range& _xrange, double _ystep,
                                            size_t _sumstep, const int** _p, const int** _pq,
                                            std::vector<Rect>& _vec, Mutex* _mtx )
    {
        cascade = _cascade;
        winsize = _winsize;
        xrange = _xrange;
        ystep = _ystep;
        sumstep = _sumstep;
        p = _p; pq = _pq;
        vec = &_vec;
        mtx = _mtx;
    }

    void operator()( const Range& range ) const
    {
        int iy, startY = range.start, endY = range.end;
        const int *p0 = p[0], *p1 = p[1], *p2 = p[2], *p3 = p[3];
        const int *pq0 = pq[0], *pq1 = pq[1], *pq2 = pq[2], *pq3 = pq[3];
        bool doCannyPruning = p0 != 0;
        int sstep = (int)(sumstep/sizeof(p0[0]));

        for( iy = startY; iy < endY; iy++ )
        {
            int ix, y = cvRound(iy*ystep), ixstep = 1;
            for( ix = xrange.start; ix < xrange.end; ix += ixstep )
            {
                int x = cvRound(ix*ystep); // it should really be ystep, not ixstep

                if( doCannyPruning )
                {
                    int offset = y*sstep + x;
                    int s = p0[offset] - p1[offset] - p2[offset] + p3[offset];
                    int sq = pq0[offset] - pq1[offset] - pq2[offset] + pq3[offset];
                    if( s < 100 || sq < 20 )
                    {
                        ixstep = 2;
                        continue;
                    }
                }

                int result = cvRunHaarClassifierCascade( cascade, cvPoint(x, y), 0 );
                if( result > 0 )
                {
                    mtx->lock();
                    vec->push_back(Rect(x, y, winsize.width, winsize.height));
                    mtx->unlock();
                }
                ixstep = result != 0 ? 1 : 2;
            }
        }
    }

    const MWCvHaarClassifierCascade* cascade;
    double ystep;
    size_t sumstep;
    Size winsize;
    Range xrange;
    const int** p;
    const int** pq;
    std::vector<Rect>* vec;
    Mutex* mtx;
};


}


CvSeq*
cvHaarDetectObjectsForROC( const CvArr* _img,
                     MWCvHaarClassifierCascade* cascade, CvMemStorage* storage,
                     std::vector<int>& rejectLevels, std::vector<double>& levelWeights,
                     double scaleFactor, int minNeighbors, int flags,
                     CvSize minSize, CvSize maxSize, bool outputRejectLevels )
{
    const double GROUP_EPS = 0.2;
    CvMat stub, *img = (CvMat*)_img;
    cv::Ptr<CvMat> temp, sum, tilted, sqsum, normImg, sumcanny, imgSmall;
    CvSeq* result_seq = 0;
    cv::Ptr<CvMemStorage> temp_storage;

    std::vector<cv::Rect> allCandidates;
    std::vector<cv::Rect> rectList;
    std::vector<int> rweights;
    double factor;
    int coi;
    bool doCannyPruning = (flags & CV_HAAR_DO_CANNY_PRUNING) != 0;
    bool findBiggestObject = (flags & CV_HAAR_FIND_BIGGEST_OBJECT) != 0;
    bool roughSearch = (flags & CV_HAAR_DO_ROUGH_SEARCH) != 0;
    cv::Mutex mtx;

    if( !MWCV_IS_HAAR_CLASSIFIER(cascade) )
        CV_Error( !cascade ? CV_StsNullPtr : CV_StsBadArg, "Invalid classifier cascade" );

    if( !storage )
        CV_Error( CV_StsNullPtr, "Null storage pointer" );

    img = cvGetMat( img, &stub, &coi );
    if( coi )
        CV_Error( CV_BadCOI, "COI is not supported" );

    if( CV_MAT_DEPTH(img->type) != CV_8U )
        CV_Error( CV_StsUnsupportedFormat, "Only 8-bit images are supported" );

    if( scaleFactor <= 1 )
        CV_Error( CV_StsOutOfRange, "scale factor must be > 1" );

    if( findBiggestObject )
        flags &= ~CV_HAAR_SCALE_IMAGE;

    if( maxSize.height == 0 || maxSize.width == 0 )
    {
        maxSize.height = img->rows;
        maxSize.width = img->cols;
    }

    temp = cvCreateMat( img->rows, img->cols, CV_8UC1 );
    sum = cvCreateMat( img->rows + 1, img->cols + 1, CV_32SC1 );
    sqsum = cvCreateMat( img->rows + 1, img->cols + 1, CV_64FC1 );

    if( !cascade->hid_cascade )
        icvCreateHidHaarClassifierCascade(cascade);

    if( cascade->hid_cascade->has_tilted_features )
        tilted = cvCreateMat( img->rows + 1, img->cols + 1, CV_32SC1 );

    result_seq = cvCreateSeq( 0, sizeof(CvSeq), sizeof(MWCvAvgComp), storage );

    if( CV_MAT_CN(img->type) > 1 )
    {
        cvCvtColor( img, temp, CV_BGR2GRAY );
        img = temp;
    }

    if( findBiggestObject )
        flags &= ~(CV_HAAR_SCALE_IMAGE|CV_HAAR_DO_CANNY_PRUNING);

    if( flags & CV_HAAR_SCALE_IMAGE )
    {
        CvSize winSize0 = cascade->orig_window_size;
#ifdef HAVE_IPP
        int use_ipp = cascade->hid_cascade->ipp_stages != 0;

        if( use_ipp )
            normImg = cvCreateMat( img->rows, img->cols, CV_32FC1 );
#endif
        imgSmall = cvCreateMat( img->rows + 1, img->cols + 1, CV_8UC1 );

        for( factor = 1; ; factor *= scaleFactor )
        {
            CvSize winSize = CvSize(cvRound(winSize0.width*factor),
                                cvRound(winSize0.height*factor));
            CvSize sz = CvSize(cvRound( img->cols/factor ), cvRound( img->rows/factor ));
            CvSize sz1 = CvSize(sz.width - winSize0.width + 1, sz.height - winSize0.height + 1 );

            CvRect equRect = CvRect( icv_object_win_border, icv_object_win_border,
                winSize0.width - icv_object_win_border*2,
                winSize0.height - icv_object_win_border*2 );

            CvMat img1, sum1, sqsum1, norm1, tilted1, mask1;
            CvMat* _tilted = 0;

            if( sz1.width <= 0 || sz1.height <= 0 )
                break;
            if( winSize.width > maxSize.width || winSize.height > maxSize.height )
                break;
            if( winSize.width < minSize.width || winSize.height < minSize.height )
                continue;

            img1 = cvMat( sz.height, sz.width, CV_8UC1, imgSmall->data.ptr );
            sum1 = cvMat( sz.height+1, sz.width+1, CV_32SC1, sum->data.ptr );
            sqsum1 = cvMat( sz.height+1, sz.width+1, CV_64FC1, sqsum->data.ptr );
            if( tilted )
            {
                tilted1 = cvMat( sz.height+1, sz.width+1, CV_32SC1, tilted->data.ptr );
                _tilted = &tilted1;
            }
            norm1 = cvMat( sz1.height, sz1.width, CV_32FC1, normImg ? normImg->data.ptr : 0 );
            mask1 = cvMat( sz1.height, sz1.width, CV_8UC1, temp->data.ptr );

            cvResize( img, &img1, CV_INTER_LINEAR );
            cvIntegral( &img1, &sum1, &sqsum1, _tilted );

            int ystep = factor > 2 ? 1 : 2;
            const int LOCS_PER_THREAD = 1000;
            int stripCount = ((sz1.width/ystep)*(sz1.height + ystep-1)/ystep + LOCS_PER_THREAD/2)/LOCS_PER_THREAD;
            stripCount = std::min(std::max(stripCount, 1), 100);

#ifdef HAVE_IPP
            if( use_ipp )
            {
                cv::Mat fsum(sum1.rows, sum1.cols, CV_32F, sum1.data.ptr, sum1.step);
                cv::Mat(&sum1).convertTo(fsum, CV_32F, 1, -(1<<24));
            }
            else
#endif
                cvSetImagesForHaarClassifierCascade( cascade, &sum1, &sqsum1, _tilted, 1. );

            cv::Mat _norm1 = cv::cvarrToMat(&norm1), _mask1 = cv::cvarrToMat(&mask1);
            cv::parallel_for_(cv::Range(0, stripCount),
                         cv::HaarDetectObjects_ScaleImage_Invoker(cascade,
                                (((sz1.height + stripCount - 1)/stripCount + ystep-1)/ystep)*ystep,
                                factor, cv::cvarrToMat(&sum1), cv::cvarrToMat(&sqsum1), &_norm1, &_mask1,
                                cv::Rect(equRect), allCandidates, rejectLevels, levelWeights, outputRejectLevels, &mtx));
        }
    }
    else
    {
        int n_factors = 0;
        cv::Rect scanROI;

        cvIntegral( img, sum, sqsum, tilted );

        if( doCannyPruning )
        {
            sumcanny = cvCreateMat( img->rows + 1, img->cols + 1, CV_32SC1 );
            cvCanny( img, temp, 0, 50, 3 );
            cvIntegral( temp, sumcanny );
        }

        for( n_factors = 0, factor = 1;
             factor*cascade->orig_window_size.width < img->cols - 10 &&
             factor*cascade->orig_window_size.height < img->rows - 10;
             n_factors++, factor *= scaleFactor )
            ;

        if( findBiggestObject )
        {
            scaleFactor = 1./scaleFactor;
            factor *= scaleFactor;
        }
        else
            factor = 1;

        for( ; n_factors-- > 0; factor *= scaleFactor )
        {
            const double ystep = std::max( 2., factor );
            CvSize winSize = CvSize( cvRound( cascade->orig_window_size.width * factor ),
                                cvRound( cascade->orig_window_size.height * factor ));
            CvRect equRect = CvRect( 0, 0, 0, 0 );
            int *p[4] = {0,0,0,0};
            int *pq[4] = {0,0,0,0};
            int startX = 0, startY = 0;
            int endX = cvRound((img->cols - winSize.width) / ystep);
            int endY = cvRound((img->rows - winSize.height) / ystep);

            if( winSize.width < minSize.width || winSize.height < minSize.height )
            {
                if( findBiggestObject )
                    break;
                continue;
            }

            if ( winSize.width > maxSize.width || winSize.height > maxSize.height )
            {
                if( !findBiggestObject )
                    break;
                continue;
            }

            cvSetImagesForHaarClassifierCascade( cascade, sum, sqsum, tilted, factor );
            cvZero( temp );

            if( doCannyPruning )
            {
                equRect.x = cvRound(winSize.width*0.15);
                equRect.y = cvRound(winSize.height*0.15);
                equRect.width = cvRound(winSize.width*0.7);
                equRect.height = cvRound(winSize.height*0.7);

                p[0] = (int*)(sumcanny->data.ptr + equRect.y*sumcanny->step) + equRect.x;
                p[1] = (int*)(sumcanny->data.ptr + equRect.y*sumcanny->step)
                            + equRect.x + equRect.width;
                p[2] = (int*)(sumcanny->data.ptr + (equRect.y + equRect.height)*sumcanny->step) + equRect.x;
                p[3] = (int*)(sumcanny->data.ptr + (equRect.y + equRect.height)*sumcanny->step)
                            + equRect.x + equRect.width;

                pq[0] = (int*)(sum->data.ptr + equRect.y*sum->step) + equRect.x;
                pq[1] = (int*)(sum->data.ptr + equRect.y*sum->step)
                            + equRect.x + equRect.width;
                pq[2] = (int*)(sum->data.ptr + (equRect.y + equRect.height)*sum->step) + equRect.x;
                pq[3] = (int*)(sum->data.ptr + (equRect.y + equRect.height)*sum->step)
                            + equRect.x + equRect.width;
            }

            if( scanROI.area() > 0 )
            {
                //adjust start_height and stop_height
                startY = cvRound(scanROI.y / ystep);
                endY = cvRound((scanROI.y + scanROI.height - winSize.height) / ystep);

                startX = cvRound(scanROI.x / ystep);
                endX = cvRound((scanROI.x + scanROI.width - winSize.width) / ystep);
            }

            cv::parallel_for_(cv::Range(startY, endY),
                cv::HaarDetectObjects_ScaleCascade_Invoker(cascade, winSize, cv::Range(startX, endX),
                                                           ystep, sum->step, (const int**)p,
                                                           (const int**)pq, allCandidates, &mtx ));

            if( findBiggestObject && !allCandidates.empty() && scanROI.area() == 0 )
            {
                rectList.resize(allCandidates.size());
                std::copy(allCandidates.begin(), allCandidates.end(), rectList.begin());

                MWgroupRectangles(rectList, std::max(minNeighbors, 1), GROUP_EPS);

                if( !rectList.empty() )
                {
                    size_t i, sz = rectList.size();
                    cv::Rect maxRect;

                    for( i = 0; i < sz; i++ )
                    {
                        if( rectList[i].area() > maxRect.area() )
                            maxRect = rectList[i];
                    }

                    allCandidates.push_back(maxRect);

                    scanROI = maxRect;
                    int dx = cvRound(maxRect.width*GROUP_EPS);
                    int dy = cvRound(maxRect.height*GROUP_EPS);
                    scanROI.x = std::max(scanROI.x - dx, 0);
                    scanROI.y = std::max(scanROI.y - dy, 0);
                    scanROI.width = std::min(scanROI.width + dx*2, img->cols-1-scanROI.x);
                    scanROI.height = std::min(scanROI.height + dy*2, img->rows-1-scanROI.y);

                    double minScale = roughSearch ? 0.6 : 0.4;
                    minSize.width = cvRound(maxRect.width*minScale);
                    minSize.height = cvRound(maxRect.height*minScale);
                }
            }
        }
    }

    rectList.resize(allCandidates.size());
    if(!allCandidates.empty())
        std::copy(allCandidates.begin(), allCandidates.end(), rectList.begin());

    if( minNeighbors != 0 || findBiggestObject )
    {
        if( outputRejectLevels )
        {
            MWgroupRectangles(rectList, rejectLevels, levelWeights, minNeighbors, GROUP_EPS );
        }
        else
        {
            MWgroupRectangles(rectList, rweights, std::max(minNeighbors, 1), GROUP_EPS);
        }
    }
    else
        rweights.resize(rectList.size(),0);

    if( findBiggestObject && rectList.size() )
    {
        MWCvAvgComp result_comp = {CvRect(0,0,0,0),0};

        for( size_t i = 0; i < rectList.size(); i++ )
        {
            cv::Rect r = rectList[i];
            if( r.area() > cv::Rect(result_comp.rect).area() )
            {
                result_comp.rect = r;
                result_comp.neighbors = rweights[i];
            }
        }
        cvSeqPush( result_seq, &result_comp );
    }
    else
    {
        for( size_t i = 0; i < rectList.size(); i++ )
        {
            MWCvAvgComp c;
            c.rect = rectList[i];
            c.neighbors = !rweights.empty() ? rweights[i] : 0;
            cvSeqPush( result_seq, &c );
        }
    }

    return result_seq;
}

CV_IMPL CvSeq*
cvHaarDetectObjects( const CvArr* _img,
                     MWCvHaarClassifierCascade* cascade, CvMemStorage* storage,
                     double scaleFactor,
                     int minNeighbors, int flags, CvSize minSize, CvSize maxSize )
{
    std::vector<int> fakeLevels;
    std::vector<double> fakeWeights;
    return cvHaarDetectObjectsForROC( _img, cascade, storage, fakeLevels, fakeWeights,
                                scaleFactor, minNeighbors, flags, minSize, maxSize, false );

}


static MWCvHaarClassifierCascade*
icvLoadCascadeCART( const char** input_cascade, int n, CvSize orig_window_size )
{
    int i;
    MWCvHaarClassifierCascade* cascade = icvCreateHaarClassifierCascade(n);
    cascade->orig_window_size = orig_window_size;

    for( i = 0; i < n; i++ )
    {
        int j, count, l;
        float threshold = 0;
        const char* stage = input_cascade[i];
        int dl = 0;

        /* tree links */
        int parent = -1;
        int next = -1;

        sscanf( stage, "%d%n", &count, &dl );
        stage += dl;

        assert( count > 0 );
        cascade->stage_classifier[i].count = count;
        cascade->stage_classifier[i].classifier =
            (MWCvHaarClassifier*)cvAlloc( count*sizeof(cascade->stage_classifier[i].classifier[0]));

        for( j = 0; j < count; j++ )
        {
            MWCvHaarClassifier* classifier = cascade->stage_classifier[i].classifier + j;
            int k, rects = 0;
            char str[100];

            sscanf( stage, "%d%n", &classifier->count, &dl );
            stage += dl;

            classifier->haar_feature = (MWCvHaarFeature*) cvAlloc(
                classifier->count * ( sizeof( *classifier->haar_feature ) +
                                      sizeof( *classifier->threshold ) +
                                      sizeof( *classifier->left ) +
                                      sizeof( *classifier->right ) ) +
                (classifier->count + 1) * sizeof( *classifier->alpha ) );
            classifier->threshold = (float*) (classifier->haar_feature+classifier->count);
            classifier->left = (int*) (classifier->threshold + classifier->count);
            classifier->right = (int*) (classifier->left + classifier->count);
            classifier->alpha = (float*) (classifier->right + classifier->count);

            for( l = 0; l < classifier->count; l++ )
            {
                sscanf( stage, "%d%n", &rects, &dl );
                stage += dl;

                assert( rects >= 2 && rects <= CV_HAAR_FEATURE_MAX );

                for( k = 0; k < rects; k++ )
                {
                    CvRect r;
                    int band = 0;
                    sscanf( stage, "%d%d%d%d%d%f%n",
                            &r.x, &r.y, &r.width, &r.height, &band,
                            &(classifier->haar_feature[l].rect[k].weight), &dl );
                    stage += dl;
                    classifier->haar_feature[l].rect[k].r = r;
                }
                sscanf( stage, "%s%n", str, &dl );
                stage += dl;

                classifier->haar_feature[l].tilted = strncmp( str, "tilted", 6 ) == 0;

                for( k = rects; k < CV_HAAR_FEATURE_MAX; k++ )
                {
                    memset( classifier->haar_feature[l].rect + k, 0,
                            sizeof(classifier->haar_feature[l].rect[k]) );
                }

                sscanf( stage, "%f%d%d%n", &(classifier->threshold[l]),
                                       &(classifier->left[l]),
                                       &(classifier->right[l]), &dl );
                stage += dl;
            }
            for( l = 0; l <= classifier->count; l++ )
            {
                sscanf( stage, "%f%n", &(classifier->alpha[l]), &dl );
                stage += dl;
            }
        }

        sscanf( stage, "%f%n", &threshold, &dl );
        stage += dl;

        cascade->stage_classifier[i].threshold = threshold;

        /* load tree links */
        if( sscanf( stage, "%d%d%n", &parent, &next, &dl ) != 2 )
        {
            parent = i - 1;
            next = -1;
        }
        stage += dl;

        cascade->stage_classifier[i].parent = parent;
        cascade->stage_classifier[i].next = next;
        cascade->stage_classifier[i].child = -1;

        if( parent != -1 && cascade->stage_classifier[parent].child == -1 )
        {
            cascade->stage_classifier[parent].child = i;
        }
    }

    return cascade;
}

#ifndef _MAX_PATH
#define _MAX_PATH 1024
#endif

CV_IMPL MWCvHaarClassifierCascade*
cvLoadHaarClassifierCascade( const char* directory, CvSize orig_window_size )
{
    if( !directory )
        CV_Error( CV_StsNullPtr, "Null path is passed" );

    char name[_MAX_PATH];

    int n = (int)strlen(directory)-1;
    const char* slash = directory[n] == '\\' || directory[n] == '/' ? "" : "/";
    int size = 0;

    /* try to read the classifier from directory */
    for( n = 0; ; n++ )
    {
        sprintf( name, "%s%s%d/AdaBoostCARTHaarClassifier.txt", directory, slash, n );
        FILE* f = fopen( name, "rb" );
        if( !f )
            break;
        fseek( f, 0, SEEK_END );
        size += ftell( f ) + 1;
        fclose(f);
    }

    if( n == 0 && slash[0] )
        return (MWCvHaarClassifierCascade*)cvLoad( directory );

    if( n == 0 )
        CV_Error( CV_StsBadArg, "Invalid path" );

    size += (n+1)*sizeof(char*);
    const char** input_cascade = (const char**)cvAlloc( size );

    if( !input_cascade )
      CV_Error( CV_StsNoMem, "Could not allocate memory for input_cascade" );

    char* ptr = (char*)(input_cascade + n + 1);

    for( int i = 0; i < n; i++ )
    {
        sprintf( name, "%s/%d/AdaBoostCARTHaarClassifier.txt", directory, i );
        FILE* f = fopen( name, "rb" );
        if( !f )
            CV_Error( CV_StsError, "" );
        fseek( f, 0, SEEK_END );
        size = ftell( f );
        fseek( f, 0, SEEK_SET );
        size_t elements_read = fread( ptr, 1, size, f );
        CV_Assert(elements_read == (size_t)(size));
        fclose(f);
        input_cascade[i] = ptr;
        ptr += size;
        *ptr++ = '\0';
    }

    input_cascade[n] = 0;

    MWCvHaarClassifierCascade* cascade = icvLoadCascadeCART( input_cascade, n, orig_window_size );

    if( input_cascade )
        cvFree( &input_cascade );

    return cascade;
}


CV_IMPL void
MWcvReleaseHaarClassifierCascade( MWCvHaarClassifierCascade** _cascade )
{
    if( _cascade && *_cascade )
    {
        int i, j;
        MWCvHaarClassifierCascade* cascade = *_cascade;

        for( i = 0; i < cascade->count; i++ )
        {
            for( j = 0; j < cascade->stage_classifier[i].count; j++ )
                cvFree( &cascade->stage_classifier[i].classifier[j].haar_feature );
            cvFree( &cascade->stage_classifier[i].classifier );
        }
        icvReleaseHidHaarClassifierCascade( &cascade->hid_cascade );
        cvFree( _cascade );
    }
}



/* End of file. */
