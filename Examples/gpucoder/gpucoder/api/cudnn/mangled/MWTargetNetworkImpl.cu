#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"
#include "MWCNNLayerImpl.hpp"
 void MWTargetNetworkImpl::preSetup() { QjgQHaUACFNSteMrRtRj = new 
cublasHandle_t; cublasCreate(QjgQHaUACFNSteMrRtRj); 
QwUuNuQNtlPXrIwRNiSZ = new cudnnHandle_t; 
cudnnCreate(QwUuNuQNtlPXrIwRNiSZ); } void MWTargetNetworkImpl::postSetup() 
{ createWorkSpace(&wtNPjzxHKNoJIigzXrEl); } void 
MWTargetNetworkImpl::createWorkSpace(float** xHViLEwTujGGrPZZgmbF) { 
CUDA_CALL(cudaMalloc((void**)xHViLEwTujGGrPZZgmbF, 
oJUVMnJggjhEdQLWzIUC)); } void 
MWTargetNetworkImpl::setWorkSpaceSize(size_t wss) { oJUVMnJggjhEdQLWzIUC 
= wss;  } size_t* MWTargetNetworkImpl::getWorkSpaceSize() { return 
&oJUVMnJggjhEdQLWzIUC; } float* MWTargetNetworkImpl::getWorkSpace() { 
return wtNPjzxHKNoJIigzXrEl; } cublasHandle_t* 
MWTargetNetworkImpl::getCublasHandle() { return QjgQHaUACFNSteMrRtRj; } 
cudnnHandle_t* MWTargetNetworkImpl::getCudnnHandle() { return 
QwUuNuQNtlPXrIwRNiSZ; } void MWTargetNetworkImpl::cleanup() { if 
(wtNPjzxHKNoJIigzXrEl) { cudaFree(wtNPjzxHKNoJIigzXrEl); } if 
(QjgQHaUACFNSteMrRtRj) { cublasDestroy(*QjgQHaUACFNSteMrRtRj); } if 
(QwUuNuQNtlPXrIwRNiSZ) { cudnnDestroy(*QwUuNuQNtlPXrIwRNiSZ); } }