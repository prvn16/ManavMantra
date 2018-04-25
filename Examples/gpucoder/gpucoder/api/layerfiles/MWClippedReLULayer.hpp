/* Copyright 2017 The MathWorks, Inc. */

#include "cnn_api.hpp"

#ifndef __CLIPPED_RELU_HPP
#define __CLIPPED_RELU_HPP

/**
 *  Codegen class for Clipped ReLU Layer
 *  Clipped rectified linear unit (ReLU) layer

 *  ClippedReLU(x, ceiling) = min(max(0, x), ceiling)
 **/
class MWTargetNetworkImpl;
class MWClippedReLULayer: public MWCNNLayer
{
  public:
    MWClippedReLULayer();
    ~MWClippedReLULayer();

    // args: [previousLayer, ceiling]
    void createClippedReLULayer(MWTensor* , double, MWTargetNetworkImpl*, int );
};

#endif
