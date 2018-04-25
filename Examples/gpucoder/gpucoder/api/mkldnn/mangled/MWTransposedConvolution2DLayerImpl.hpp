/* Copyright 2017 The MathWorks, Inc. */
#ifndef GPUCODER_TRANSPOSEDCONVOLUTIONIMPL_HPP
#define GPUCODER_TRANSPOSEDCONVOLUTIONIMPL_HPP


#include "MWTransposedConvolution2DLayer.hpp"
#include "MWTransposedConvolution2DLayerImpl.hpp"
#include "MWCNNLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"

class MWTransposedConvolution2DLayerImpl : public MWCNNLayerImpl {
  private:
    void loadWeights(const char*);
    void loadBias(const char*);

    int CufLFODQDXTAPyRqYodN; // Filter height for CONV and FC
    int DRzwhbNPpftRRIXXfHzd;  // Filter width for CONV and FC

    int FwLnexHgxHRquTKmNpoa;
    int FpguQZSermqZCMRiUfML;
    int FshVHIJMRAhtQirYPlZd;
    int GFggoMvRWucDMqzlWzCl;

    int CqtPRJvHlGJFssiPzsOm[2];
    int BdqURaHPmdnfzvtUvocl[2];

  public:
    MWTransposedConvolution2DLayerImpl(MWCNNLayer*,
                                       int,
                                       int,
                                       int,
                                       int,
                                       int,
                                       int,
                                       int,
                                       int,
                                       const char*,
                                       const char*,
                                       MWTargetNetworkImpl*);


    ~MWTransposedConvolution2DLayerImpl();
    void createTransposedConv2DLayer(int, int, int, int, const char*, const char*);

    void predict();
    void cleanup();

  private:
    float* tqZLvfMHdgZzbchUyDzd;
    float* XNZmftADYzuZnIYIpBaT;
};

#endif

// LocalWords:  FC
