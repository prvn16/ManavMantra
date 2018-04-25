/* Copyright 2017 The MathWorks, Inc. */

#include "cnn_api.hpp"

#ifndef __UNPOOLING_LAYER_HPP
#define __UNPOOLING_LAYER_HPP

/**
  *  Codegen class for UnpoolingLayer  
**/
class MWTensor;
class MWMaxUnpoolingLayer : public MWCNNLayer
{
  public:
    MWMaxUnpoolingLayer();
    ~MWMaxUnpoolingLayer();

    void createMaxUnpoolingLayer(MWTensor*, MWTensor*, MWTargetNetworkImpl*);
};

#endif
