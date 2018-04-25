#include "MWLeakyReLULayerImpl.hpp"
#include "MWLeakyReLULayer.hpp"
 MWLeakyReLULayerImpl::MWLeakyReLULayerImpl(MWCNNLayer* layer, double 
LtEgcYoEYjkrWuohutgw, MWTargetNetworkImpl* ntwk_impl, int inPlace) : 
MWCNNLayerImpl(layer, ntwk_impl) , oYbqYsqgVhrUzFEKbBbR(LtEgcYoEYjkrWuohutgw) , 
aLsOwwcceEmRSYzllBNs(inPlace) { MWTensor* op = getLayer()->getOutputTensor(); if 
(inPlace) { REXdEoRjxuQJkqgIDihy = getLayer()->getInputTensor()->getData(); } else { 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, sizeof(float)*op->getHeight()* 
op->getWidth()*op->getChannels()*op->getBatchSize())); } 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(0), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, op->getBatchSize(), op->getChannels(), 
op->getHeight(), op->getWidth())); } 
MWLeakyReLULayerImpl::~MWLeakyReLULayerImpl() { } void 
MWLeakyReLULayerImpl::predict() { MWTensor* op = getLayer()->getOutputTensor(); 
leakyReLUForwardImpl(op->getHeight(), op->getWidth(), op->getChannels(), 
op->getBatchSize(), oYbqYsqgVhrUzFEKbBbR, getData()); } void 
MWLeakyReLULayerImpl::cleanup() { if (hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor(0))); }  if 
(!aLsOwwcceEmRSYzllBNs) { MWTensor* op = getLayer()->getOutputTensor(0); float* 
data = op->getData(); if (data) { call_cuda_free(data); } }  } void __global__ 
leakyReLUImpl(float * AFQBkxwYGKLsACiDKwRM, const double ATEikvMQPqBefhJzjzhc, const int 
CGbFsczkgkhjcHoCKzBx) { int const i = blockDim.x * blockIdx.x + threadIdx.x; if (i < 
CGbFsczkgkhjcHoCKzBx) { float tf = float(AFQBkxwYGKLsACiDKwRM[i]<0); AFQBkxwYGKLsACiDKwRM[i] = 
AFQBkxwYGKLsACiDKwRM[i] - tf*ATEikvMQPqBefhJzjzhc*AFQBkxwYGKLsACiDKwRM[i]; } } void 
leakyReLUForwardImpl(int ZCArwzdUdwQuFQUWjnUE, int vxtNGOWYjhKeBBSzuIMB, int 
jLyhrFjMmVnNjoeDJCwH, int NMMfJylfQjiIUAKhXCJb,  const double 
oYbqYsqgVhrUzFEKbBbR, float* output) { int hljcfGWsvZXJZNrImpJB = 
ZCArwzdUdwQuFQUWjnUE*vxtNGOWYjhKeBBSzuIMB* 
jLyhrFjMmVnNjoeDJCwH*NMMfJylfQjiIUAKhXCJb; int 
sRECVoNNtDdcBOWgDyar = (hljcfGWsvZXJZNrImpJB < 1024) ? hljcfGWsvZXJZNrImpJB : 
1024; int NnAKUXChhnRnQmWsknGy = (hljcfGWsvZXJZNrImpJB + 
sRECVoNNtDdcBOWgDyar - 1)/sRECVoNNtDdcBOWgDyar; 
leakyReLUImpl<<<NnAKUXChhnRnQmWsknGy, sRECVoNNtDdcBOWgDyar>>>( 
output, (1 - oYbqYsqgVhrUzFEKbBbR), hljcfGWsvZXJZNrImpJB); }