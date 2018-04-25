/* Copyright 2017 The MathWorks, Inc. */

#ifndef CNN_TARGET_NTWK_IMPL
#define CNN_TARGET_NTWK_IMPL

#include <cudnn.h>
#include <cublas_v2.h>

class MWTargetNetworkImpl
{
  public:
    
    MWTargetNetworkImpl()
        : wtNPjzxHKNoJIigzXrEl(0)
        , QjgQHaUACFNSteMrRtRj(0)
        , QwUuNuQNtlPXrIwRNiSZ(0)
    {}
    ~MWTargetNetworkImpl() {}
    void preSetup();
    void postSetup();
    void cleanup();

    void setWorkSpaceSize(size_t);  // Set the workspace size of this layer and previous layers   
    size_t* getWorkSpaceSize();     // Get the workspace size of this layer and previous layers
    float* getWorkSpace();          // Get the workspace buffer in GPU memory    
    cublasHandle_t* getCublasHandle();      // Get the cuBLAS handle to use for GPU computation
    cudnnHandle_t* getCudnnHandle();        // Get the cuDNN handle to use for GPU computation    
       
  private:    
    size_t oJUVMnJggjhEdQLWzIUC;    
    float* wtNPjzxHKNoJIigzXrEl;    
    cublasHandle_t* QjgQHaUACFNSteMrRtRj;
    cudnnHandle_t* QwUuNuQNtlPXrIwRNiSZ;

  private:
    void createWorkSpace(float**);  // Create the workspace needed for this layer
    
};
#endif
