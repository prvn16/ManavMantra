#include "MWAdditionLayer.hpp"
#include "MWAdditionLayerImpl.hpp"
#include <stdarg.h>
#include <cassert>
#include <omp.h>
 MWAdditionLayerImpl::MWAdditionLayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl)  : MWCNNLayerImpl(layer)  { lHtftnmGBvlSSoGOXVui 
= ntwk_impl; createAdditionLayer(); } 
MWAdditionLayerImpl::~MWAdditionLayerImpl() { } void 
MWAdditionLayerImpl::createAdditionLayer() { MWAdditionLayer* AdditionLayer = 
static_cast<MWAdditionLayer*>(getLayer()); MWTensor* ipTensor = 
AdditionLayer->getInputTensor(0); 
setData((float*)calloc(ipTensor->getHeight()*ipTensor->getWidth()*ipTensor->getChannels()*ipTensor->getBatchSize(),sizeof(float))); 
return ;  } void addImpl(float* in1, float* in2, float* out, size_t maxElems) {
#pragma omp parallel for schedule(static)
 for (unsigned int i=0; i < maxElems; ++i) { out[i] = in1[i] + in2[i]; } } void 
MWAdditionLayerImpl::predict() { MWAdditionLayer* AdditionLayer = 
static_cast<MWAdditionLayer*>(getLayer()); MWTensor* ipTensor = 
AdditionLayer->getInputTensor(0); MWTensor* ipTensor1 = 
AdditionLayer->getInputTensor(1); int mbKaFvmHqfBiTISNPGKJ = 
ipTensor->getHeight()*ipTensor->getWidth()*ipTensor->getChannels()*ipTensor->getBatchSize(); 
addImpl(ipTensor->getData(), ipTensor1->getData(), getData(), 
mbKaFvmHqfBiTISNPGKJ); for (int k = 2; k < AdditionLayer->getNumInputs(); k++) { 
addImpl(AdditionLayer->getInputTensor(k)->getData(), getData(), getData(), 
mbKaFvmHqfBiTISNPGKJ); } } void MWAdditionLayerImpl::cleanup() { MWAdditionLayer* 
AdditionLayer = static_cast<MWAdditionLayer*>(getLayer()); for(int idx = 0; idx 
< AdditionLayer->getNumOutputs(); idx++) {  MWTensor* op = 
AdditionLayer->getOutputTensor(idx); float* data = op->getData(); if (data) { 
free(data); } }  }