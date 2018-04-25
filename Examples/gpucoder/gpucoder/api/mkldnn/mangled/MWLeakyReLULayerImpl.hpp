/* Copyright 2017 The MathWorks, Inc. */

#ifndef __LEAKY_RELU_IMPL_HPP
#define __LEAKY_RELU_IMPL_HPP

#include "MWLeakyReLULayer.hpp"
#include "MWLeakyReLULayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp" 
#include "MWCNNLayerImpl.hpp"

//LeakyReLULayer
class MWLeakyReLULayerImpl: public MWCNNLayerImpl
{
  public:
    MWLeakyReLULayerImpl(MWCNNLayer*, double, MWTargetNetworkImpl*, int);
    ~MWLeakyReLULayerImpl();

    void createLeakyReLULayer();
    void predict();
    void cleanup();

  private:
    double rxMAtVYGgGtZoKBkJcjc;
    int fSbUUBgjKRbNXrHrlOLo;
};

#endif
