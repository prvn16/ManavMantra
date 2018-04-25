#include <stdio.h>
#include "cnn_api.hpp"
#include "MWTransposedConvolution2DLayer.hpp"
#include "MWCNNLayerImpl.hpp"
#include "MWTransposedConvolution2DLayerImpl.hpp"
#include <stdlib.h>
#include <cassert>
#include <omp.h>
#include "mkldnn.hpp"
 using namespace mkldnn; 
MWTransposedConvolution2DLayerImpl::MWTransposedConvolution2DLayerImpl( 
MWCNNLayer* layer, int filt_H, int filt_W, int numIpFeatures, int numFilts, int 
TbrNrGxaFFHrzKUcfHNZ, int TfsmDFpPPOscKZifVzSQ, int GZGFVDrXwFLJleoTDywO, int 
IIiwAtyrOtLzLWAUlTey, const char* yPBlKhIGljihkXaXbYpB, const char* 
YNDVziqpDddiXQKYZZhX, MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer) , 
CufLFODQDXTAPyRqYodN(filt_H) , DRzwhbNPpftRRIXXfHzd(filt_W) , 
FwLnexHgxHRquTKmNpoa(1) , FshVHIJMRAhtQirYPlZd(numFilts) , 
GFggoMvRWucDMqzlWzCl(numIpFeatures) , tqZLvfMHdgZzbchUyDzd(NULL) , 
XNZmftADYzuZnIYIpBaT(NULL) { lHtftnmGBvlSSoGOXVui = ntwk_impl; 
createTransposedConv2DLayer(TbrNrGxaFFHrzKUcfHNZ, TfsmDFpPPOscKZifVzSQ, 
GZGFVDrXwFLJleoTDywO, IIiwAtyrOtLzLWAUlTey, yPBlKhIGljihkXaXbYpB, 
YNDVziqpDddiXQKYZZhX); } 
MWTransposedConvolution2DLayerImpl::~MWTransposedConvolution2DLayerImpl() { } 
void MWTransposedConvolution2DLayerImpl::createTransposedConv2DLayer( int 
TbrNrGxaFFHrzKUcfHNZ, int TfsmDFpPPOscKZifVzSQ, int GZGFVDrXwFLJleoTDywO, int 
IIiwAtyrOtLzLWAUlTey, const char* yPBlKhIGljihkXaXbYpB, const char* 
YNDVziqpDddiXQKYZZhX) { MWTransposedConvolution2DLayer* 
TransposedConvolution2DLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* ipTensor = 
TransposedConvolution2DLayer->getInputTensor(0); MWTensor* opTensor = 
TransposedConvolution2DLayer->getOutputTensor(0); CqtPRJvHlGJFssiPzsOm[0] = 
TbrNrGxaFFHrzKUcfHNZ; CqtPRJvHlGJFssiPzsOm[1] = TfsmDFpPPOscKZifVzSQ; 
BdqURaHPmdnfzvtUvocl[0] = GZGFVDrXwFLJleoTDywO; BdqURaHPmdnfzvtUvocl[1] = 
IIiwAtyrOtLzLWAUlTey; tqZLvfMHdgZzbchUyDzd = (float*)calloc(ipTensor->getChannels() / 
FwLnexHgxHRquTKmNpoa * opTensor->getChannels() * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd, sizeof(float)); XNZmftADYzuZnIYIpBaT = 
(float*)calloc(ipTensor->getChannels(), sizeof(float)); 
setData((float*)calloc(opTensor->getBatchSize() * opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(), sizeof(float))); 
loadWeights(yPBlKhIGljihkXaXbYpB); loadBias(YNDVziqpDddiXQKYZZhX); return; } 
void MWTransposedConvolution2DLayerImpl::predict() { auto eng = 
engine(engine::kind::cpu, 0); MWTransposedConvolution2DLayer* convLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* ipTensor = 
convLayer->getInputTensor(0); MWTensor* opTensor = 
convLayer->getOutputTensor(0); int n_i = opTensor->getBatchSize(); int c_i = 
opTensor->getChannels(); int h_i = opTensor->getHeight(); int w_i = 
opTensor->getWidth(); int n_o = ipTensor->getBatchSize(); int c_o = 
ipTensor->getChannels(); int h_o = ipTensor->getHeight(); int w_o = 
ipTensor->getWidth(); int dilate_h = 0; int dilate_w = 0; int wts_oc = c_o; int 
wts_ic = c_i; int wts_h = CufLFODQDXTAPyRqYodN; int wts_w = 
DRzwhbNPpftRRIXXfHzd; auto c_src_desc = memory::desc({n_i, c_i, h_i, w_i}, 
memory::data_type::f32, memory::format::nchw); auto c_weights_desc = 
FwLnexHgxHRquTKmNpoa > 1 ? memory::desc({FwLnexHgxHRquTKmNpoa, wts_oc / 
FwLnexHgxHRquTKmNpoa, wts_ic / FwLnexHgxHRquTKmNpoa, wts_h, wts_w}, 
memory::data_type::f32, memory::format::goihw) : memory::desc({wts_oc, wts_ic, 
wts_h, wts_w}, memory::data_type::f32, memory::format::oihw); auto c_dst_desc = 
memory::desc({n_o, c_o, h_o, w_o}, memory::data_type::f32, 
memory::format::nchw); auto c_src_desc_f = memory::desc({n_i, c_i, h_i, w_i}, 
memory::data_type::f32, memory::format::nchw); auto c_dst_desc_f = 
memory::desc({n_o, c_o, h_o, w_o}, memory::data_type::f32, 
memory::format::nchw); auto src_primitive_desc = 
memory::primitive_desc(c_src_desc, eng); auto weights_primitive_desc = 
memory::primitive_desc(c_weights_desc, eng); auto dst_primitive_desc = 
memory::primitive_desc(c_dst_desc, eng); auto src_primitive_desc_f = 
memory::primitive_desc(c_src_desc_f, eng); auto dst_primitive_desc_f = 
memory::primitive_desc(c_dst_desc_f, eng); auto c_diff_src = 
memory(src_primitive_desc, opTensor->getData()); auto c_weights = 
memory(weights_primitive_desc, tqZLvfMHdgZzbchUyDzd); auto c_diff_dst = 
memory(dst_primitive_desc, ipTensor->getData()); std::vector<int> padR = 
{BdqURaHPmdnfzvtUvocl[0], BdqURaHPmdnfzvtUvocl[1]}; for (int i = 0; i < 2; 
++i) { if ((h_i - ((wts_h - 1) * (dilate_h + 1) + 1) + 
BdqURaHPmdnfzvtUvocl[0] + padR[0]) / CqtPRJvHlGJFssiPzsOm[0] + 1 != h_o) { 
++padR[0]; } if ((w_i - ((wts_w - 1) * (dilate_w + 1) + 1) + 
BdqURaHPmdnfzvtUvocl[1] + padR[1]) / CqtPRJvHlGJFssiPzsOm[1] + 1 != w_o) { 
++padR[1]; } } auto conv_desc = convolution_forward::desc( 
prop_kind::forward_training, convolution_direct, c_src_desc_f, c_weights_desc, 
c_dst_desc_f, {CqtPRJvHlGJFssiPzsOm[0], CqtPRJvHlGJFssiPzsOm[1]}, 
{dilate_h, dilate_w}, {BdqURaHPmdnfzvtUvocl[0], BdqURaHPmdnfzvtUvocl[1]}, 
padR, padding_kind::zero); auto conv_primitive_desc = 
convolution_forward::primitive_desc(conv_desc, eng); auto conv_bwd_data_desc = 
convolution_backward_data::desc( convolution_direct, c_src_desc, 
c_weights_desc, c_dst_desc, {CqtPRJvHlGJFssiPzsOm[0], 
CqtPRJvHlGJFssiPzsOm[1]}, {dilate_h, dilate_w}, {BdqURaHPmdnfzvtUvocl[0], 
BdqURaHPmdnfzvtUvocl[1]}, padR, padding_kind::zero); auto 
conv_bwd_data_primitive_desc = 
convolution_backward_data::primitive_desc(conv_bwd_data_desc, eng, 
conv_primitive_desc); auto conv_bwd_data = 
convolution_backward_data(conv_bwd_data_primitive_desc, c_diff_dst, c_weights, 
c_diff_src); std::vector<primitive> pipeline; 
pipeline.push_back(conv_bwd_data); 
stream(stream::kind::lazy).submit(pipeline).wait(); float* out_ptr = 
opTensor->getData(); int n = opTensor->getBatchSize(); int c = 
opTensor->getChannels(); int h = opTensor->getHeight(); int w = 
opTensor->getWidth(); float bias = 0.0;
#pragma omp parallel for schedule(static)
 for (int i = 0; i < n; i++) { for (int j = 0; j < c; j++) { bias = 
XNZmftADYzuZnIYIpBaT[j]; for (int k = 0; k < h; k++) { for (int l = 0; l < w; l++) { 
*out_ptr += bias; out_ptr++; } } } } } void 
MWTransposedConvolution2DLayerImpl::cleanup() { free(tqZLvfMHdgZzbchUyDzd); 
free(XNZmftADYzuZnIYIpBaT); for (int idx = 0; idx < getLayer()->getNumOutputs(); idx++) 
{ float* data = getLayer()->getOutputTensor(idx)->getData(); if (data) { 
free(data); } } } void MWTransposedConvolution2DLayerImpl::loadWeights(const 
char* bQjijJlpNAVdwDDQgpaX) { MWTransposedConvolution2DLayer* convLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* ipTensor = 
convLayer->getInputTensor(0); MWTensor* opTensor = 
convLayer->getOutputTensor(0); FILE* eVAFqeShtGZAZluKdMvQ = 
MWCNNLayer::openBinaryFile(bQjijJlpNAVdwDDQgpaX); int lsqeARVLtpJTWezgnTkg = 
ipTensor->getChannels() * opTensor->getChannels() * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd;  fread(tqZLvfMHdgZzbchUyDzd, sizeof(float), lsqeARVLtpJTWezgnTkg, 
eVAFqeShtGZAZluKdMvQ); if (CufLFODQDXTAPyRqYodN != 1 && DRzwhbNPpftRRIXXfHzd != 
1) { float* ZKjSVYDDjACizBkGbqBq = (float*)malloc(sizeof(float) * 
CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd); for (int k = 0; k < 
lsqeARVLtpJTWezgnTkg / CufLFODQDXTAPyRqYodN / DRzwhbNPpftRRIXXfHzd; k++) { for 
(int i = 0; i < CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd; i++) { 
ZKjSVYDDjACizBkGbqBq[i] = tqZLvfMHdgZzbchUyDzd[k * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd + i]; } for (int j = 0; j < CufLFODQDXTAPyRqYodN; 
j++) for (int i = 0; i < DRzwhbNPpftRRIXXfHzd; i++) { tqZLvfMHdgZzbchUyDzd[k * 
CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd + j * DRzwhbNPpftRRIXXfHzd + 
i] = ZKjSVYDDjACizBkGbqBq[j + i * CufLFODQDXTAPyRqYodN]; } } 
free(ZKjSVYDDjACizBkGbqBq); } printf("%s loaded. Size = %d. %f\n", 
bQjijJlpNAVdwDDQgpaX, lsqeARVLtpJTWezgnTkg, tqZLvfMHdgZzbchUyDzd[0]); fclose(eVAFqeShtGZAZluKdMvQ); 
return; } void MWTransposedConvolution2DLayerImpl::loadBias(const char* 
bQjijJlpNAVdwDDQgpaX) { MWTransposedConvolution2DLayer* convLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* opTensor = 
convLayer->getOutputTensor(0); FILE* eVAFqeShtGZAZluKdMvQ = 
MWCNNLayer::openBinaryFile(bQjijJlpNAVdwDDQgpaX); assert(eVAFqeShtGZAZluKdMvQ); int 
lsqeARVLtpJTWezgnTkg = opTensor->getChannels();  fread(XNZmftADYzuZnIYIpBaT, sizeof(float), 
lsqeARVLtpJTWezgnTkg, eVAFqeShtGZAZluKdMvQ); fclose(eVAFqeShtGZAZluKdMvQ); return; }