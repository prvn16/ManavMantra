#include "MWAdditionLayer.hpp"
#include "MWAdditionLayerImpl.hpp"
#include <stdarg.h>
#include <cassert>
 MWAdditionLayerImpl::MWAdditionLayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl)  : MWCNNLayerImpl(layer, ntwk_impl)  { 
createAdditionLayer(); } MWAdditionLayerImpl::~MWAdditionLayerImpl() { } void 
MWAdditionLayerImpl::createAdditionLayer() { MWAdditionLayer* AdditionLayer = 
static_cast<MWAdditionLayer*>(getLayer()); MWTensor* ipTensor = 
AdditionLayer->getInputTensor(0); MWTensor* opTensor = 
AdditionLayer->getOutputTensor(0); 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*ipTensor->getHeight()*ipTensor->getWidth()*ipTensor->getChannels()*ipTensor->getBatchSize())); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor(0))); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(0), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, ipTensor->getBatchSize(), 
ipTensor->getChannels(), ipTensor->getHeight(), ipTensor->getWidth())); return 
;  } void __global__ addImpl(float* in1, float* in2, float* out, size_t 
maxElems) { size_t i = blockDim.x * blockIdx.x + threadIdx.x; for (; i < 
maxElems; i += size_t(blockDim.x*gridDim.x)) { out[i] = in1[i] + in2[i]; } } 
void MWAdditionLayerImpl::predict() { MWAdditionLayer* AdditionLayer = 
static_cast<MWAdditionLayer*>(getLayer()); MWTensor* ipTensor = 
AdditionLayer->getInputTensor(0); MWTensor* ipTensor1 = 
AdditionLayer->getInputTensor(1); MWTensor* opTensor = 
AdditionLayer->getOutputTensor(0); int hljcfGWsvZXJZNrImpJB = 
ipTensor->getHeight()*ipTensor->getWidth()*ipTensor->getChannels()*ipTensor->getBatchSize(); 
int sRECVoNNtDdcBOWgDyar = (hljcfGWsvZXJZNrImpJB < 1024) ? 
hljcfGWsvZXJZNrImpJB : 1024; int NnAKUXChhnRnQmWsknGy = (hljcfGWsvZXJZNrImpJB + 
sRECVoNNtDdcBOWgDyar - 1)/sRECVoNNtDdcBOWgDyar; 
addImpl<<<NnAKUXChhnRnQmWsknGy, sRECVoNNtDdcBOWgDyar>>>( 
ipTensor->getData(), ipTensor1->getData(), getData(), hljcfGWsvZXJZNrImpJB); for 
(int k = 2; k < AdditionLayer->getNumInputs(); k++) { 
addImpl<<<NnAKUXChhnRnQmWsknGy, sRECVoNNtDdcBOWgDyar>>>( 
AdditionLayer->getInputTensor(k)->getData(), getData(), getData(), 
hljcfGWsvZXJZNrImpJB); } } void MWAdditionLayerImpl::cleanup() { MWAdditionLayer* 
AdditionLayer = static_cast<MWAdditionLayer*>(getLayer()); if 
(hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } for(int idx 
= 0; idx < AdditionLayer->getNumOutputs(); idx++) {  MWTensor* op = 
AdditionLayer->getOutputTensor(idx); float* data = op->getData(); if (data) { 
call_cuda_free(data); } }  }