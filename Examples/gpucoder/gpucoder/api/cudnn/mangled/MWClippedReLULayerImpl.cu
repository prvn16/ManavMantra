#include "MWClippedReLULayerImpl.hpp"
#include "cnn_api.hpp"
#include <math.h>
 MWClippedReLULayerImpl::MWClippedReLULayerImpl(MWCNNLayer* layer , double 
KCudOrFMfgCzUPMcdePX, MWTargetNetworkImpl* ntwk_impl, int inPlace) : 
MWCNNLayerImpl(layer, ntwk_impl) , aLsOwwcceEmRSYzllBNs(inPlace)  { 
createClippedReLULayer(KCudOrFMfgCzUPMcdePX); } void __global__ 
ClippedReLUImpl(float* juRPduBvIGpwaZiftkzr, const double ATEikvMQPqBefhJzjzhc, const int 
CGbFsczkgkhjcHoCKzBx) { int const i = blockDim.x * blockIdx.x + threadIdx.x; if (i < 
CGbFsczkgkhjcHoCKzBx) { float tf = float(juRPduBvIGpwaZiftkzr[i] > 0); juRPduBvIGpwaZiftkzr[i] = 
tf*((juRPduBvIGpwaZiftkzr[i] < ATEikvMQPqBefhJzjzhc) ? juRPduBvIGpwaZiftkzr[i] : ATEikvMQPqBefhJzjzhc); } } 
void MWClippedReLULayerImpl::clippedReLUForwardImpl(int ZCArwzdUdwQuFQUWjnUE, int 
vxtNGOWYjhKeBBSzuIMB, int jLyhrFjMmVnNjoeDJCwH, int NMMfJylfQjiIUAKhXCJb, 
const double OwenhowBxTAXHXmJpIKd, float* output) { int hljcfGWsvZXJZNrImpJB = 
ZCArwzdUdwQuFQUWjnUE*vxtNGOWYjhKeBBSzuIMB* 
jLyhrFjMmVnNjoeDJCwH*NMMfJylfQjiIUAKhXCJb; int omxlPZbBePZdWaJOBUUG = 
std::floor(static_cast<float>(hljcfGWsvZXJZNrImpJB)/static_cast<float>(32)) * 32; 
int sRECVoNNtDdcBOWgDyar = (omxlPZbBePZdWaJOBUUG < 1024) ? omxlPZbBePZdWaJOBUUG : 
1024; int NnAKUXChhnRnQmWsknGy = (hljcfGWsvZXJZNrImpJB + 
sRECVoNNtDdcBOWgDyar - 1)/sRECVoNNtDdcBOWgDyar; 
ClippedReLUImpl<<<NnAKUXChhnRnQmWsknGy, 
sRECVoNNtDdcBOWgDyar>>>(output, OwenhowBxTAXHXmJpIKd, hljcfGWsvZXJZNrImpJB); 
} void MWClippedReLULayerImpl::createClippedReLULayer(double 
KCudOrFMfgCzUPMcdePX) { OwenhowBxTAXHXmJpIKd = KCudOrFMfgCzUPMcdePX; MWTensor* op = 
getLayer()->getOutputTensor(); if (aLsOwwcceEmRSYzllBNs) { REXdEoRjxuQJkqgIDihy = 
getLayer()->getInputTensor()->getData(); } else { 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, sizeof(float)*op->getHeight()* 
op->getWidth()*op->getChannels()*op->getBatchSize())); } 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, op->getBatchSize(), op->getChannels(), 
op->getHeight(), op->getWidth())); } void MWClippedReLULayerImpl::predict() { 
MWTensor* op = getLayer()->getOutputTensor(0); 
clippedReLUForwardImpl(op->getHeight(), op->getWidth(), op->getChannels(), 
op->getBatchSize(), OwenhowBxTAXHXmJpIKd, getData()); } void 
MWClippedReLULayerImpl::cleanup() { if (hasOutputDescriptor()) {  
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } if 
(!aLsOwwcceEmRSYzllBNs) { MWTensor* op = getLayer()->getOutputTensor(0); float* 
data = op->getData(); if (data) { call_cuda_free(data); } }  }