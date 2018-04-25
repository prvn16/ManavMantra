/* Copyright 2017 The MathWorks, Inc. */

#ifndef __CLIPPED_RELU_IMPL_HPP
#define __CLIPPED_RELU_IMPL_HPP

#include "MWCNNLayerImpl.hpp"

class MWClippedReLULayerImpl: public MWCNNLayerImpl
{
  public:
    
    MWClippedReLULayerImpl(MWCNNLayer* layer , double KCudOrFMfgCzUPMcdePX, MWTargetNetworkImpl* ntwk_impl, int);
    ~MWClippedReLULayerImpl() {}
   
    void predict();
    void cleanup();
    
  private:
    
    double OwenhowBxTAXHXmJpIKd;
    int aLsOwwcceEmRSYzllBNs;

  private:
    
    void createClippedReLULayer(double KCudOrFMfgCzUPMcdePX);
    
    void clippedReLUForwardImpl(int ZCArwzdUdwQuFQUWjnUE,
                                int vxtNGOWYjhKeBBSzuIMB,
                                int jLyhrFjMmVnNjoeDJCwH,
                                int NMMfJylfQjiIUAKhXCJb,
                                const double OwenhowBxTAXHXmJpIKd,
                                float* output);
   
 
};



#endif
