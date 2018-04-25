/* Copyright 2017 The MathWorks, Inc. */

#ifndef __CLIPPED_RELU_IMPL_HPP
#define __CLIPPED_RELU_IMPL_HPP

#include "MWClippedReLULayer.hpp"
#include "MWClippedReLULayerImpl.hpp"
#include "MWCNNLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"

//ClippedReLULayer
class MWClippedReLULayerImpl: public MWCNNLayerImpl
{
  public:
    MWClippedReLULayerImpl(MWCNNLayer*, double, MWTargetNetworkImpl*, int);
    ~MWClippedReLULayerImpl();

    void createClippedReLULayer();
    void predict();
    void cleanup();

  private:
    double rxMAtVYGgGtZoKBkJcjc;
    int fSbUUBgjKRbNXrHrlOLo;
};

								
#endif
