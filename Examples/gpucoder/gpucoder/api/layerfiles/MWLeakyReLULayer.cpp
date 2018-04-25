/* Copyright 2017 The MathWorks, Inc. */

#include "MWLeakyReLULayer.hpp"
#include "MWLeakyReLULayerImpl.hpp"

MWLeakyReLULayer::MWLeakyReLULayer()
{   
}

MWLeakyReLULayer::~MWLeakyReLULayer()
{
}

//Create ReLULayer
void MWLeakyReLULayer::createLeakyReLULayer(MWTensor* m_in,
                                            double aScale,
                                            MWTargetNetworkImpl* network_impl,
                                            int inPlace)
{

    setInputTensor(m_in);
    allocateOutputTensor(getInputTensor()->getHeight(),
                         getInputTensor()->getWidth(),
                         getInputTensor()->getChannels(),
                         getInputTensor()->getBatchSize(),
                         NULL);
    

    m_impl = new MWLeakyReLULayerImpl(this, aScale, network_impl, inPlace);
    MWTensor *opTensor = getOutputTensor();
    opTensor->setData(m_impl->getData());
}
