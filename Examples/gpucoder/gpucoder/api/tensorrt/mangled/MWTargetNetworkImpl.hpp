/* Copyright 2017 The MathWorks, Inc. */

#ifndef CNN_TARGET_NTWK_IMPL
#define CNN_TARGET_NTWK_IMPL

#include <cudnn.h>
#include "cnn_exec.hpp"

/*TensorRT related header files */
#include "NvInfer.h"
#include "NvCaffeParser.h"
#include "cuda_runtime_api.h"

using namespace nvinfer1;
using namespace nvcaffeparser1;

class MWTargetNetworkImpl {
  public:
    MWTargetNetworkImpl() {
    }
    ~MWTargetNetworkImpl() {
    }
    void preSetup();
    void postSetup();
    void predict(CnnMain* );
    void cleanup();
    float* getWorkSpace();           // Get the workspace buffer in GPU memory
    cudnnHandle_t* getCudnnHandle(); // Get the cuDNN handle to use for GPU computation
    
    CnnMain* cnnmainPtr;
    INetworkDefinition* network;
    int batchSize;

  private:
    IBuilder* builder;
    ICudaEngine* engine;
    IExecutionContext* context;
    size_t rytJDHzuydvYOLNNROYf;
    float* yeRJnYjpvmkKjBpyWlaV;
    
    cudnnHandle_t* iFWfUCwhmxBsOTMvFHgz;
};
#endif
