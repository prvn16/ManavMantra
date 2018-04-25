#include "MWDepthConcatenationLayerImpl.hpp"
#include "MWDepthConcatenationLayer.hpp"
#include <stdarg.h>
#include <cassert>
 MWDepthConcatenationLayerImpl::MWDepthConcatenationLayerImpl(MWCNNLayer* 
layer, MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
createDepthConcatenationLayer(); } 
MWDepthConcatenationLayerImpl::~MWDepthConcatenationLayerImpl() {  } void 
MWDepthConcatenationLayerImpl::createDepthConcatenationLayer() {  MWTensor* 
opTensor = getLayer()->getOutputTensor(0);  
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*opTensor->getHeight()*opTensor->getWidth()*opTensor->getChannels()*opTensor->getBatchSize())); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor(0))); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(0), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, opTensor->getBatchSize(), 
opTensor->getChannels(), opTensor->getHeight(), opTensor->getWidth())); } void 
__global__ concatImpl(float* in, float* out, size_t numElems,  size_t 
batchSize,  size_t outStride,  size_t startOffset)  { size_t i = blockDim.x * 
blockIdx.x + threadIdx.x; size_t maxElems = numElems*batchSize; for (; i < 
maxElems; i += size_t(blockDim.x*gridDim.x)) { size_t batchOffset = i/numElems; 
size_t elemOffset = i - (batchOffset*numElems);  int outOffset = startOffset + 
batchOffset*outStride; out[elemOffset + outOffset] = in[i];  } } void 
MWDepthConcatenationLayerImpl::predict() { int outputOffset = 0; MWTensor* 
opTensor = getLayer()->getOutputTensor(0); int outputStridePerBatch = 
opTensor->getHeight()*opTensor->getWidth()*opTensor->getChannels(); for (int k 
= 0; k < getLayer()->getNumInputs(); k++) { MWTensor* ipTensor = 
getLayer()->getInputTensor(k); int hljcfGWsvZXJZNrImpJB = 
ipTensor->getBatchSize()* ipTensor->getHeight()* ipTensor->getWidth()* 
ipTensor->getChannels();  int sRECVoNNtDdcBOWgDyar = 
ceil(hljcfGWsvZXJZNrImpJB/32)*32; sRECVoNNtDdcBOWgDyar = 
(sRECVoNNtDdcBOWgDyar < 1024) ? sRECVoNNtDdcBOWgDyar : 1024; int 
NnAKUXChhnRnQmWsknGy = (hljcfGWsvZXJZNrImpJB + sRECVoNNtDdcBOWgDyar - 
1)/sRECVoNNtDdcBOWgDyar; int numElemsPerBatch = 
ipTensor->getHeight()*ipTensor->getWidth()*ipTensor->getChannels(); 
concatImpl<<<NnAKUXChhnRnQmWsknGy, 
sRECVoNNtDdcBOWgDyar>>>(ipTensor->getData(), getData(), numElemsPerBatch, 
ipTensor->getBatchSize(), outputStridePerBatch, outputOffset); outputOffset += 
numElemsPerBatch; } } void MWDepthConcatenationLayerImpl::cleanup() { if 
(hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } if 
(REXdEoRjxuQJkqgIDihy) { call_cuda_free(REXdEoRjxuQJkqgIDihy); } }