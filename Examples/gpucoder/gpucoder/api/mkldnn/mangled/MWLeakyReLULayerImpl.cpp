#include "MWLeakyReLULayerImpl.hpp"
#include "MWLeakyReLULayer.hpp"
#include "cnn_api.hpp"
#include "MWCNNLayerImpl.hpp"
#include "mkldnn.hpp"
 using namespace mkldnn; extern int tap_count; extern void mw_interm_tap(float 
*inp, int size,int count); 
MWLeakyReLULayerImpl::MWLeakyReLULayerImpl(MWCNNLayer* layer, double 
WOJynDmqVUPWjAGVIuMQ, MWTargetNetworkImpl* ntwk_impl, int inPlace)  : 
MWCNNLayerImpl(layer) , fSbUUBgjKRbNXrHrlOLo(inPlace) { lHtftnmGBvlSSoGOXVui = 
ntwk_impl; rxMAtVYGgGtZoKBkJcjc = WOJynDmqVUPWjAGVIuMQ; 
createLeakyReLULayer(); } MWLeakyReLULayerImpl::~MWLeakyReLULayerImpl() { } 
void MWLeakyReLULayerImpl::createLeakyReLULayer() { MWLeakyReLULayer* reluLayer 
= static_cast<MWLeakyReLULayer*>(getLayer()); MWTensor* ipTensor = 
reluLayer->getInputTensor(); if (fSbUUBgjKRbNXrHrlOLo) { 
setData(ipTensor->getData()); } else { 
setData((float*)calloc(ipTensor->getBatchSize() * ipTensor->getChannels() * 
ipTensor->getHeight() * ipTensor->getWidth(), sizeof(float))); } } void 
MWLeakyReLULayerImpl::predict() { MWLeakyReLULayer* reluLayer = 
static_cast<MWLeakyReLULayer*>(getLayer()); MWTensor* ipTensor = 
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
eltwise_forward::desc(prop_kind::forward_training, algorithm::eltwise_relu, 
src_desc, negative_slope); auto relu_prim_desc = 
eltwise_forward::primitive_desc(relu_desc, eng); auto relu = 
eltwise_forward(relu_prim_desc, src, dst); std::vector<primitive> pipeline; 
pipeline.push_back(relu); auto s = stream(stream::kind::eager); s.submit(pipeline).wait();
#if MW_RELU_TAP 
 mw_interm_tap(opTensor->getData(),opTensor->getBatchSize()* 
opTensor->getChannels()* opTensor->getHeight()* opTensor->getWidth(),tap_count++);
#endif 
 return; } void MWLeakyReLULayerImpl::cleanup() { if (!fSbUUBgjKRbNXrHrlOLo) { 
float* data = getLayer()->getOutputTensor(0)->getData(); if (data) { 
free(data); }  } }