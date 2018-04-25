#include "MWMaxUnpoolingLayerImpl.hpp"
#include "MWMaxUnpoolingLayer.hpp"
#include <cassert>
 MWMaxUnpoolingLayerImpl::MWMaxUnpoolingLayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
createUnpoolingLayer(); } MWMaxUnpoolingLayerImpl::~MWMaxUnpoolingLayerImpl() { 
 } void MWMaxUnpoolingLayerImpl::createUnpoolingLayer() { MWTensor* opTensor = 
getLayer()->getOutputTensor(0); CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*opTensor->getBatchSize()* opTensor->getChannels()* 
opTensor->getHeight()* opTensor->getWidth())); 
CUDA_CALL(cudaMemset(REXdEoRjxuQJkqgIDihy,0.0f, 
sizeof(float)*opTensor->getBatchSize()* opTensor->getChannels()* 
opTensor->getHeight()* opTensor->getWidth() ));  
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, opTensor->getBatchSize(), 
opTensor->getChannels(), opTensor->getHeight(), opTensor->getWidth())); } void 
MWMaxUnpoolingLayerImpl::predict() { assert(this->getData() != 
getLayer()->getInputTensor(0)->getData()); 
doMaxUnpoolingForwardImpl(getLayer()->getInputTensor(0)->getData(), 
getLayer()->getInputTensor(1)->getData(), 
getLayer()->getOutputTensor(0)->getData(), 
getLayer()->getInputTensor(0)->getHeight(), 
getLayer()->getInputTensor(0)->getWidth(), 
getLayer()->getInputTensor(0)->getChannels(), 
getLayer()->getInputTensor(0)->getBatchSize()); return; } void __global__ 
MaxUnpoolingImpl(float * inputBuffer, float * indexBuffer, float * 
outputBuffer, const int CGbFsczkgkhjcHoCKzBx) { for(int i = blockDim.x * blockIdx.x + 
threadIdx.x; i < CGbFsczkgkhjcHoCKzBx; i+= blockDim.x*gridDim.x) { 
outputBuffer[static_cast<int>(indexBuffer[i])] = inputBuffer[i]; } } void 
MWMaxUnpoolingLayerImpl::doMaxUnpoolingForwardImpl(float* inputBuffer, float* 
indexBuffer, float* outputBuffer, int ZCArwzdUdwQuFQUWjnUE, int vxtNGOWYjhKeBBSzuIMB, 
int jLyhrFjMmVnNjoeDJCwH, int NMMfJylfQjiIUAKhXCJb ) { int 
hljcfGWsvZXJZNrImpJB = ZCArwzdUdwQuFQUWjnUE*vxtNGOWYjhKeBBSzuIMB* 
jLyhrFjMmVnNjoeDJCwH*NMMfJylfQjiIUAKhXCJb; int 
sRECVoNNtDdcBOWgDyar = (hljcfGWsvZXJZNrImpJB < 1024) ? hljcfGWsvZXJZNrImpJB : 
1024; int NnAKUXChhnRnQmWsknGy = (hljcfGWsvZXJZNrImpJB + 
sRECVoNNtDdcBOWgDyar - 1)/sRECVoNNtDdcBOWgDyar; 
MaxUnpoolingImpl<<<NnAKUXChhnRnQmWsknGy, sRECVoNNtDdcBOWgDyar>>>( 
inputBuffer, indexBuffer, outputBuffer, hljcfGWsvZXJZNrImpJB); } void 
MWMaxUnpoolingLayerImpl::cleanup() { if (hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } for(int idx 
= 0; idx < getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { call_cuda_free(data); 
} } }