/* Copyright 2017 The MathWorks, Inc. */

#include "cnn_api.hpp"

#ifndef __LEAKY_RELU_HPP
#define __LEAKY_RELU_HPP

/**
  *  Codegen class for Leaky ReLU Layer
  *  Leaky rectified linear unit (ReLU) layer
 
  *  This type of layer performs a simple threshold operation,
  *  where any input value less than zero is multiplied by a scalar
  *  multiple. This is equivalent to:
  *  out = in;        % For in>0
  *  out = scale.*in; % For in<=0
**/
class MWTargetNetworkImpl;
class MWLeakyReLULayer : public MWCNNLayer
{
  public:
    
    MWLeakyReLULayer();
    ~MWLeakyReLULayer();

    // args: [previousLayer, scale factor]
    void createLeakyReLULayer(MWTensor*, double, MWTargetNetworkImpl*, int);

};

#endif
