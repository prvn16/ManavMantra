/* Copyright 2017 The MathWorks, Inc. */

#ifndef __MAX_UNPOOLING_IMPL_HPP
#define __MAX_UNPOOLING_IMPL_HPP

#include "MWCNNLayerImpl.hpp"

/**
  *  Codegen class for Unpooling layer
**/
class MWCNNLayer;
class MWTargetNetworkImpl;
class MWMaxUnpoolingLayerImpl : public MWCNNLayerImpl
{
  public:
    
    MWMaxUnpoolingLayerImpl(MWCNNLayer*, MWTargetNetworkImpl*);
    ~MWMaxUnpoolingLayerImpl();

    void createUnpoolingLayer();
    virtual void predict();
    virtual void cleanup();

  private:
    
    void doMaxUnpoolingForwardImpl(float* inputBuffer,
                                   float* indexBuffer,
                                   float* outputBuffer,
                                   int ZCArwzdUdwQuFQUWjnUE,
                                   int vxtNGOWYjhKeBBSzuIMB,
                                   int jLyhrFjMmVnNjoeDJCwH,
                                   int NMMfJylfQjiIUAKhXCJb );    
};



#endif
