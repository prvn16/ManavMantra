#include "MWBatchNormalizationLayer.hpp"
#include "MWBatchNormalizationLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"
#include "MWCNNLayerImpl.hpp"
#include <stdio.h>
#include <cassert> 
 MWBatchNormalizationLayerImpl::MWBatchNormalizationLayerImpl(MWCNNLayer* 
layer, double const MCrRCXUsCsGPMgQbvMOt, const char* 
MEmIeGILUZNEWEagSzRk, const char* MIBnYCbKBdUrlfqlHdoo, const char* 
MNuwXDSoGEYeABeVTwOh, const char* MUmglsoWcEiRiAZsclur, 
MWTargetNetworkImpl* ntwk_impl, int inPlace) : MWCNNLayerImpl(layer, ntwk_impl) 
 , oYbqYsqgVhrUzFEKbBbR(NULL) , jscBrjkVJyVfMMDjFpgl(NULL) , 
ujSEtllBwMdSJhSkFCia(NULL) , vFNECEAeLZsYsUxvlgqL(NULL) , 
aLsOwwcceEmRSYzllBNs(inPlace) { 
CUDNN_CALL(cudnnCreateTensorDescriptor(&NtWaRGCHLeTapjWdEHHS)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
createBatchNormalizationLayer(MCrRCXUsCsGPMgQbvMOt, MEmIeGILUZNEWEagSzRk, 
MIBnYCbKBdUrlfqlHdoo, MNuwXDSoGEYeABeVTwOh, 
MUmglsoWcEiRiAZsclur); } 
MWBatchNormalizationLayerImpl::~MWBatchNormalizationLayerImpl() { } void 
MWBatchNormalizationLayerImpl::createBatchNormalizationLayer(double const 
MCrRCXUsCsGPMgQbvMOt, const char* MEmIeGILUZNEWEagSzRk, const char* 
MIBnYCbKBdUrlfqlHdoo, const char* MNuwXDSoGEYeABeVTwOh, const char* 
MUmglsoWcEiRiAZsclur) { MWBatchNormalizationLayer* BNLayer = 
static_cast<MWBatchNormalizationLayer*>(getLayer()); MWTensor* ipTensor = 
BNLayer->getInputTensor(); MWTensor* opTensor = BNLayer->getOutputTensor(); 
UEESbUvbMihFnquvuFij = MCrRCXUsCsGPMgQbvMOt; 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, opTensor->getBatchSize(), 
opTensor->getChannels(), opTensor->getHeight(), opTensor->getWidth())); const 
size_t numBytes = sizeof(float)*ipTensor->getChannels(); 
CUDA_CALL(cudaMalloc((void**)&oYbqYsqgVhrUzFEKbBbR, numBytes)); 
CUDA_CALL(cudaMalloc((void**)&jscBrjkVJyVfMMDjFpgl, numBytes)); 
CUDA_CALL(cudaMalloc((void**)&ujSEtllBwMdSJhSkFCia, numBytes)); 
CUDA_CALL(cudaMalloc((void**)&vFNECEAeLZsYsUxvlgqL, numBytes)); 
fvTCtkwXgyScJYogJVFU = CUDNN_BATCHNORM_SPATIAL; 
CUDNN_CALL(cudnnDeriveBNTensorDescriptor(NtWaRGCHLeTapjWdEHHS, 
*getOutputDescriptor(), fvTCtkwXgyScJYogJVFU));  loadScale(MIBnYCbKBdUrlfqlHdoo); 
loadOffset(MEmIeGILUZNEWEagSzRk); 
loadTrainedMean(MNuwXDSoGEYeABeVTwOh); 
loadTrainedVariance(MUmglsoWcEiRiAZsclur); if (aLsOwwcceEmRSYzllBNs) 
{ REXdEoRjxuQJkqgIDihy = getLayer()->getInputTensor()->getData(); } else { 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*opTensor->getHeight()* 
opTensor->getWidth()*opTensor->getChannels()*opTensor->getBatchSize())); } } 
void MWBatchNormalizationLayerImpl::iLoadParamOntoGPU(char const * const 
UzaGmBLFEwmwaFXebUma, int const hnewnpwgzKmOdualajhn, float* 
XCLDbxHBtWRStETWIkId) { FILE* WIxRBCJtmETvfxpuRuus = fopen(UzaGmBLFEwmwaFXebUma,"rb"); 
assert(WIxRBCJtmETvfxpuRuus); int const OVOphSOolqRQDDoKPwxy = 
sizeof(float)*hnewnpwgzKmOdualajhn; float* OKaRVOctKLlnIyGmjRNW = 
(float*)malloc(OVOphSOolqRQDDoKPwxy); fread(OKaRVOctKLlnIyGmjRNW, sizeof(float), 
hnewnpwgzKmOdualajhn, WIxRBCJtmETvfxpuRuus); fclose(WIxRBCJtmETvfxpuRuus); 
CUDA_CALL(cudaMemcpy(XCLDbxHBtWRStETWIkId, OKaRVOctKLlnIyGmjRNW, 
OVOphSOolqRQDDoKPwxy, cudaMemcpyHostToDevice)); free(OKaRVOctKLlnIyGmjRNW); } 
void MWBatchNormalizationLayerImpl::loadScale(const char* UzaGmBLFEwmwaFXebUma) 
{ MWBatchNormalizationLayer* BNLayer = 
static_cast<MWBatchNormalizationLayer*>(getLayer()); MWTensor* opTensor = 
BNLayer->getOutputTensor(); iLoadParamOntoGPU(UzaGmBLFEwmwaFXebUma, 
opTensor->getChannels(), oYbqYsqgVhrUzFEKbBbR); } void 
MWBatchNormalizationLayerImpl::loadOffset(const char* UzaGmBLFEwmwaFXebUma) { 
MWBatchNormalizationLayer* BNLayer = 
static_cast<MWBatchNormalizationLayer*>(getLayer()); MWTensor* opTensor = 
BNLayer->getOutputTensor(); iLoadParamOntoGPU(UzaGmBLFEwmwaFXebUma, 
opTensor->getChannels(), jscBrjkVJyVfMMDjFpgl); } void 
MWBatchNormalizationLayerImpl::loadTrainedMean(const char* UzaGmBLFEwmwaFXebUma) 
{ MWBatchNormalizationLayer* BNLayer = 
static_cast<MWBatchNormalizationLayer*>(getLayer()); MWTensor* opTensor = 
BNLayer->getOutputTensor(); iLoadParamOntoGPU(UzaGmBLFEwmwaFXebUma, 
opTensor->getChannels(), ujSEtllBwMdSJhSkFCia); } void 
MWBatchNormalizationLayerImpl::loadTrainedVariance(const char* 
UzaGmBLFEwmwaFXebUma) { MWBatchNormalizationLayer* BNLayer = 
static_cast<MWBatchNormalizationLayer*>(getLayer()); MWTensor* opTensor = 
BNLayer->getOutputTensor(); iLoadParamOntoGPU(UzaGmBLFEwmwaFXebUma, 
opTensor->getChannels(), vFNECEAeLZsYsUxvlgqL); } void 
MWBatchNormalizationLayerImpl::predict() { MWBatchNormalizationLayer* BNLayer = 
static_cast<MWBatchNormalizationLayer*>(getLayer()); MWTensor* ipTensor = 
BNLayer->getInputTensor(); MWTensor* opTensor = BNLayer->getOutputTensor(); 
const cudnnTensorDescriptor_t ZinudJuZuGitiNTsJpBR = 
*getCuDNNDescriptor(ipTensor); float* bDTIjtxZiSHtjwzgEluE = ipTensor->getData(); 
cudnnTensorDescriptor_t kNsviQGMPdXzNMRixGWR = *getOutputDescriptor(); float* 
kkqTyvjYvRFtTOyQUwrF = getData(); 
CUDNN_CALL(cudnnBatchNormalizationForwardInference( 
*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), fvTCtkwXgyScJYogJVFU, getOnePtr(), 
getZeroPtr(),  ZinudJuZuGitiNTsJpBR, bDTIjtxZiSHtjwzgEluE, kNsviQGMPdXzNMRixGWR, 
kkqTyvjYvRFtTOyQUwrF, NtWaRGCHLeTapjWdEHHS, oYbqYsqgVhrUzFEKbBbR, 
jscBrjkVJyVfMMDjFpgl, ujSEtllBwMdSJhSkFCia, vFNECEAeLZsYsUxvlgqL, 
UEESbUvbMihFnquvuFij)); } void MWBatchNormalizationLayerImpl::cleanup() { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(NtWaRGCHLeTapjWdEHHS)); if 
(hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } 
if(oYbqYsqgVhrUzFEKbBbR) { call_cuda_free(oYbqYsqgVhrUzFEKbBbR); } 
if(jscBrjkVJyVfMMDjFpgl) { call_cuda_free(jscBrjkVJyVfMMDjFpgl); } 
if(ujSEtllBwMdSJhSkFCia) { call_cuda_free(ujSEtllBwMdSJhSkFCia); } 
if(vFNECEAeLZsYsUxvlgqL) { call_cuda_free(vFNECEAeLZsYsUxvlgqL); } 
if (!aLsOwwcceEmRSYzllBNs) { MWTensor* op = getLayer()->getOutputTensor(0); 
float* data = op->getData(); if (data) { call_cuda_free(data); } }  }