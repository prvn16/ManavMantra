#include "cnn_api.hpp"
#include "MWClippedReLULayer.hpp"
#include "MWCNNLayerImpl.hpp"
#include "MWClippedReLULayerImpl.hpp"
#include <math.h>
#include "mkldnn.hpp"
 using namespace mkldnn; 
MWClippedReLULayerImpl::MWClippedReLULayerImpl(MWCNNLayer* layer, double 
WOJynDmqVUPWjAGVIuMQ, MWTargetNetworkImpl* ntwk_impl, int inPlace)  : 
MWCNNLayerImpl(layer) , fSbUUBgjKRbNXrHrlOLo(inPlace) { lHtftnmGBvlSSoGOXVui = 
ntwk_impl; rxMAtVYGgGtZoKBkJcjc = WOJynDmqVUPWjAGVIuMQ; 
createClippedReLULayer(); } MWClippedReLULayerImpl::~MWClippedReLULayerImpl() { 
} void MWClippedReLULayerImpl::createClippedReLULayer() { MWClippedReLULayer* 
reluLayer = static_cast<MWClippedReLULayer*>(getLayer()); MWTensor* ipTensor = 
reluLayer->getInputTensor(); if (fSbUUBgjKRbNXrHrlOLo) { 
setData(ipTensor->getData()); } else { 
setData((float*)calloc(ipTensor->getBatchSize() * ipTensor->getChannels() * 
ipTensor->getHeight() * ipTensor->getWidth(), sizeof(float))); }  } void 
MWClippedReLULayerImpl::predict() { MWClippedReLULayer* reluLayer = 
static_cast<MWClippedReLULayer*>(getLayer()); MWTensor* ipTensor = 
reluLayer->getInputTensor(); MWTensor* opTensor = reluLayer->getOutputTensor() 
; const double negative_slope = rxMAtVYGgGtZoKBkJcjc; float *relu_src_buffer = 
ipTensor->getData(); float *relu_dst_buffer = opTensor->getData(); auto 
cpu_engine = engine(engine::cpu, 0); memory::dims relu_src_tz = 
{ipTensor->getBatchSize(), ipTensor->getChannels(), ipTensor->getHeight(), 
ipTensor->getWidth()}; auto eng = engine(engine::cpu, 0); auto src_desc = 
memory::desc(relu_src_tz, memory::data_type::f32, memory::format::nchw); auto 
dst_desc = memory::desc(relu_src_tz, memory::data_type::f32, 
memory::format::nchw); auto src = memory({src_desc, eng}); auto dst = 
memory({dst_desc, eng}); src.set_data_handle(relu_src_buffer); 
dst.set_data_handle(relu_dst_buffer); auto relu_desc = 
eltwise_forward::desc(prop_kind::forward_training, 
algorithm::eltwise_bounded_relu, src_desc, negative_slope); auto relu_prim_desc 
= eltwise_forward::primitive_desc(relu_desc, eng); auto relu = 
eltwise_forward(relu_prim_desc, src, dst); std::vector<primitive> pipeline; 
pipeline.push_back(relu); auto s = stream(stream::kind::eager); s.submit(pipeline).wait();
#if MW_RELU_TAP 
 mw_interm_tap(opTensor->getData(),opTensor->getBatchSize()* 
opTensor->getChannels()* opTensor->getHeight()* opTensor->getWidth(),tap_count++);
#endif 
 return; } void MWClippedReLULayerImpl::cleanup() { if (!fSbUUBgjKRbNXrHrlOLo) { 
float* data = getLayer()->getOutputTensor(0)->getData(); if (data) { 
free(data); }  } }