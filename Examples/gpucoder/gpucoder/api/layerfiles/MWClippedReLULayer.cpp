/* Copyright 2017 The MathWorks, Inc. */

#include "MWClippedReLULayer.hpp"
#include "MWClippedReLULayerImpl.hpp"

MWClippedReLULayer::MWClippedReLULayer()
{
}

MWClippedReLULayer::~MWClippedReLULayer()
{
}

//Create ClippedReLULayer
void MWClippedReLULayer::createClippedReLULayer(MWTensor* MW_mangled_in,
                                                double MW_mangled_aCeiling,
                                                MWTargetNetworkImpl* ntwk_impl,
                                                int inPlace)
{
    setInputTensor(MW_mangled_in);

    allocateOutputTensor(getInputTensor()->getHeight(),
                         getInputTensor()->getWidth(),
                         getInputTensor()->getChannels(),
                         getInputTensor()->getBatchSize(),
                         NULL);            

    m_impl = new MWClippedReLULayerImpl(this, MW_mangled_aCeiling, ntwk_impl, inPlace);

    MWTensor *opTensor = getOutputTensor();
    opTensor->setData(m_impl->getData());
}
