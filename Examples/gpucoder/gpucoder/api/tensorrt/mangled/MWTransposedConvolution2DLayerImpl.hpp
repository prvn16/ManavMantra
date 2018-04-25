/* Copyright 2017 The MathWorks, Inc. */
#ifndef GPUCODER_TRANSPOSEDCONVOLUTIONIMPL_HPP
#define GPUCODER_TRANSPOSEDCONVOLUTIONIMPL_HPP


#include "MWTransposedConvolution2DLayer.hpp"
#include "MWTransposedConvolution2DLayerImpl.hpp"
#include "MWCNNLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"

/* TensorRT related header files */
#include "NvInfer.h"
#include "NvCaffeParser.h"
#include "cuda_runtime_api.h"

using namespace nvinfer1;
using namespace nvcaffeparser1;

class MWTransposedConvolution2DLayerImpl : public MWCNNLayerImpl {




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


  private:
    int GbdgxISzcqHOpzQEBrvP; // Filter height for CONV and FC
    int JABfZsGuaCAmcRcqOYEO;  // Filter width for CONV and FC
    int JxwPQNPACGfmGpNncpCY;    // specifies if  convolution is grouped or not
    IDeconvolutionLayer* DeconvLayer;
    float* wqggPBXZvtlxnxwngvAq;         // Convolution  filter wieghts 
    float* eUSuiwvLvXVXrpUkgBVu;         // Convolution bias 
    Weights filt_weights;        //TensorRT container which holds weights 
    Weights filt_bias;           //TensorRT container which holds bias 
    void createTransposedConv2DLayer(int, int, int, int, const char*, const char*);
    void cleanup();
    void loadWeights(const char*);
    void loadBias(const char*);
};
#endif