/* Copyright 2017 The MathWorks, Inc. */

#include "MWTransposedConvolution2DLayer.hpp"
#include "MWTransposedConvolution2DLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"

//utils
#include <stdio.h>

MWTransposedConvolution2DLayer::MWTransposedConvolution2DLayer()
{
}

MWTransposedConvolution2DLayer::~MWTransposedConvolution2DLayer()
{
}

// m_k is the user input for NumOutFeatureMaps
// m_c is the user input for NumInFeatureMaps    
void MWTransposedConvolution2DLayer::createTransposedConvLayer(MWTensor* m_in
                                                               , int m_r
                                                               , int m_s
                                                               , int m_c
                                                               , int m_k
                                                               , int m_StrideH
                                                               , int m_StrideW
                                                               , int m_PaddingH
                                                               , int m_PaddingW
                                                               , const char* m_weights_file
                                                               , const char* m_bias_file
                                                               , MWTargetNetworkImpl* ntwk_impl)
{
    setInputTensor(m_in);
    
    int m_FilterHeight = m_r;
    int m_FilterWidth  = m_s;    
    int m_NumInputFeatures = m_c;
    int m_NumFilters  =  m_k;

    // Calculate output dim
    int m_temp_h = m_StrideH*(getInputTensor()->getHeight()-1) + m_FilterHeight - 2*m_PaddingH;
    int m_temp_w = m_StrideW*(getInputTensor()->getWidth()-1) +  m_FilterWidth -  2*m_PaddingW;
    
    allocateOutputTensor(m_temp_h, m_temp_w, m_k, getInputTensor()->getBatchSize(), NULL);
    m_impl = new MWTransposedConvolution2DLayerImpl(this, 
                                                    m_FilterHeight,
                                                    m_FilterWidth,
                                                    m_NumInputFeatures,
                                                    m_NumFilters,
                                                    m_StrideH,
                                                    m_StrideW,
                                                    m_PaddingH,
                                                    m_PaddingW,
                                                    m_weights_file,
                                                    m_bias_file,
                                                    ntwk_impl);

    /*Setting the MWTensor pointer */
    MWTensor *opTensor = getOutputTensor();
    opTensor->setData(m_impl->getData());
}
