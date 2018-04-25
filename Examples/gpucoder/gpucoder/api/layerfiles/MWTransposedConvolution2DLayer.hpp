/* Copyright 2017 The MathWorks, Inc. */

#include "cnn_api.hpp"
//#include <cassert>

#ifndef GPUCODER_TRANSPOSEDCONVOLUTION_HPP
#define GPUCODER_TRANSPOSEDCONVOLUTION_HPP

/**
 * Codegen class for Transposed Convolution 2D Layer
 *
 */
class MWTargetNetworkImpl;
class MWTransposedConvolution2DLayer: public MWCNNLayer
{
  private:
    
    // float* MW_mangled_w;
    // float* MW_mangled_b;

  public:
    MWTransposedConvolution2DLayer();
    ~MWTransposedConvolution2DLayer();

    /** Create Transposed Convolution (or deConvolution) layer */
    void createTransposedConvLayer(MWTensor*, int, int, int, int, int, int, int, int, const char*, const char*, MWTargetNetworkImpl*);
};

#endif
