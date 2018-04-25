/* Copyright 2017 The MathWorks, Inc. */

#ifndef __LEAKY_RELU_IMPL_HPP
#define __LEAKY_RELU_IMPL_HPP

#include "MWCNNLayerImpl.hpp"

class MWLeakyReLULayerImpl: public MWCNNLayerImpl
{
  public:
    
    MWLeakyReLULayerImpl(MWCNNLayer* , double, MWTargetNetworkImpl*, int);
    ~MWLeakyReLULayerImpl();
   
    void predict();
    void cleanup();

   
  private:
    double oYbqYsqgVhrUzFEKbBbR;
    int aLsOwwcceEmRSYzllBNs;
};

void leakyReLUForwardImpl(int ZCArwzdUdwQuFQUWjnUE,
                          int vxtNGOWYjhKeBBSzuIMB,
                          int jLyhrFjMmVnNjoeDJCwH,
                          int NMMfJylfQjiIUAKhXCJb,                          
                          const double shEncNmxJsMuJKwbrwok,
                          float* output);

#endif
