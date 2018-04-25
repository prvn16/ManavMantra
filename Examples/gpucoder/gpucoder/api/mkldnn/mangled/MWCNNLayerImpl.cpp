#include <cassert>
#include <cstring>
#include <stdio.h>
#include "MWCNNLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"
#include "mkldnn.hpp"
#if USE_MKL_INTEL
#include "mkl_cblas.h"
#include "mkl_trans.h"
#endif
 using namespace mkldnn; MWCNNLayerImpl::MWCNNLayerImpl(MWCNNLayer* layer) : 
kFQQPKSOkZeHlmrkAXuE(layer) , atVCyzqXZAZxwlkRLBRA(0) { } void 
MWCNNLayerImpl::setData(float* data) { atVCyzqXZAZxwlkRLBRA = data; } 
MWInputLayerImpl::MWInputLayerImpl(MWCNNLayer* layer, int kqftrrQBBOgGsrDSkIUk, int 
edQOkUJIZbwzEeIcCLzG, int tqZLvfMHdgZzbchUyDzd, int aPzBTLIjCXEQZUlbxayX, bool zRhMJbzYfMHEzDwdpDGW, 
const char* avg_file_name, MWTargetNetworkImpl* ntwk_impl) : 
MWCNNLayerImpl(layer) { lHtftnmGBvlSSoGOXVui = ntwk_impl; 
createInputLayer(kqftrrQBBOgGsrDSkIUk, edQOkUJIZbwzEeIcCLzG, tqZLvfMHdgZzbchUyDzd, aPzBTLIjCXEQZUlbxayX, 
zRhMJbzYfMHEzDwdpDGW, avg_file_name); } MWInputLayerImpl::~MWInputLayerImpl() { } 
int tap_count = 0; void mw_interm_tap(float* inp, int size, int count) { FILE* 
fp; int i; char str[500];
#define TXT_FILE 1
#if TXT_FILE
 sprintf(str, "taps/mw_interm_tap_%d.txt", count); fp = fopen(str, "w"); for (i 
= 0; i < size; i++) { fprintf(fp, "%f\n", inp[i]); }
#else
 sprintf(str, "taps/mw_interm_tap_%d.bin", count); fp = fopen(str, "wb"); 
fwrite(inp, 4, size, fp);
#endif
 fclose(fp); } void MWInputLayerImpl::createInputLayer(int kqftrrQBBOgGsrDSkIUk, int 
edQOkUJIZbwzEeIcCLzG, int tqZLvfMHdgZzbchUyDzd, int aPzBTLIjCXEQZUlbxayX, bool zRhMJbzYfMHEzDwdpDGW, 
const char* avg_file_name) { gsJtSpgIkTNvahoTFqow = zRhMJbzYfMHEzDwdpDGW; 
setData( (float*)calloc(kqftrrQBBOgGsrDSkIUk * aPzBTLIjCXEQZUlbxayX * edQOkUJIZbwzEeIcCLzG * 
tqZLvfMHdgZzbchUyDzd, sizeof(float))); int lsqeARVLtpJTWezgnTkg = aPzBTLIjCXEQZUlbxayX * edQOkUJIZbwzEeIcCLzG 
* tqZLvfMHdgZzbchUyDzd; if (zRhMJbzYfMHEzDwdpDGW) { loadAvg(avg_file_name, 
lsqeARVLtpJTWezgnTkg); } return; } void MWInputLayerImpl::loadAvg(const char* 
bQjijJlpNAVdwDDQgpaX, int lsqeARVLtpJTWezgnTkg) { size_t retVal; FILE* eVAFqeShtGZAZluKdMvQ = 
MWCNNLayer::openBinaryFile(bQjijJlpNAVdwDDQgpaX); if (eVAFqeShtGZAZluKdMvQ == NULL) { 
printf("Unabel to open file\n"); } UWAGLbDcvybdWBtshhsr = 
(float*)calloc(lsqeARVLtpJTWezgnTkg, sizeof(float)); retVal = fread(UWAGLbDcvybdWBtshhsr, 
sizeof(float), lsqeARVLtpJTWezgnTkg, eVAFqeShtGZAZluKdMvQ); if (retVal != 
(size_t)lsqeARVLtpJTWezgnTkg) { printf("MWInputLayer::loadAvg - File read Failed\n"); 
} fclose(eVAFqeShtGZAZluKdMvQ); return; } void MWInputLayerImpl::predict() { float* 
inp = getData(); int i, btch; MWInputLayer* inpLayer = 
static_cast<MWInputLayer*>(getLayer()); MWTensor* opTensor = 
inpLayer->getOutputTensor(0); if (gsJtSpgIkTNvahoTFqow) { for (btch = 0; btch < 
opTensor->getBatchSize(); btch++) { for (i = 0; i < opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(); i++) { inp[i] = inp[i] - 
UWAGLbDcvybdWBtshhsr[i]; } inp += opTensor->getChannels() * opTensor->getHeight() * 
opTensor->getWidth(); }
#if MW_INPUT_TAP
 mw_interm_tap(getData(), opTensor->getBatchSize() * opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 } return; } void MWInputLayerImpl::cleanup() { for (int idx = 0; idx < 
kFQQPKSOkZeHlmrkAXuE->getNumOutputs(); idx++) { float* data = 
kFQQPKSOkZeHlmrkAXuE->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
if (gsJtSpgIkTNvahoTFqow) { if (UWAGLbDcvybdWBtshhsr) { free(UWAGLbDcvybdWBtshhsr); } } return; 
} MWConvLayerImpl::MWConvLayerImpl(MWCNNLayer* layer, int filt_H, int filt_W, 
int numGrps, int numChnls, int numFilts, int TbrNrGxaFFHrzKUcfHNZ, int 
TfsmDFpPPOscKZifVzSQ, int MgAiRWiTutoTMxKXjmHQ, int JsZenQeBPMhwsyEhVHiD, int 
LgxABSJPBXdCozJkFqTg, int LklYEpYUjaLTgcFFAaJX, const char* 
yPBlKhIGljihkXaXbYpB, const char* YNDVziqpDddiXQKYZZhX, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer) , zzWugmJRYlNEuAzHMpeQ(NULL) , tqZLvfMHdgZzbchUyDzd(NULL) , 
XNZmftADYzuZnIYIpBaT(NULL) , uOjfVTZSbCZATdZVDwrL(NULL) , fXhhiexIRPLyKXApPmmy(NULL) , 
gWETwFdWHfKuelmlKNCC(0) , CufLFODQDXTAPyRqYodN(filt_H) , 
DRzwhbNPpftRRIXXfHzd(filt_W) , FwLnexHgxHRquTKmNpoa(numGrps) , 
FpguQZSermqZCMRiUfML(numChnls) , FshVHIJMRAhtQirYPlZd(numFilts) { 
lHtftnmGBvlSSoGOXVui = ntwk_impl; gWETwFdWHfKuelmlKNCC = 0; if 
(FwLnexHgxHRquTKmNpoa == 2) { gWETwFdWHfKuelmlKNCC = 1; } 
createConvLayer(TbrNrGxaFFHrzKUcfHNZ, TfsmDFpPPOscKZifVzSQ, MgAiRWiTutoTMxKXjmHQ, 
JsZenQeBPMhwsyEhVHiD, LgxABSJPBXdCozJkFqTg,LklYEpYUjaLTgcFFAaJX, 
yPBlKhIGljihkXaXbYpB, YNDVziqpDddiXQKYZZhX); } 
MWConvLayerImpl::~MWConvLayerImpl() { } void 
MWConvLayerImpl::createConvLayer(int TbrNrGxaFFHrzKUcfHNZ, int 
TfsmDFpPPOscKZifVzSQ, int MgAiRWiTutoTMxKXjmHQ, int JsZenQeBPMhwsyEhVHiD, int 
LgxABSJPBXdCozJkFqTg, int LklYEpYUjaLTgcFFAaJX, const char* 
yPBlKhIGljihkXaXbYpB, const char* YNDVziqpDddiXQKYZZhX) { MWConvLayer* 
convLayer = static_cast<MWConvLayer*>(getLayer()); MWTensor* ipTensor = 
convLayer->getInputTensor(0); MWTensor* opTensor = 
convLayer->getOutputTensor(0); CqtPRJvHlGJFssiPzsOm[0] = TbrNrGxaFFHrzKUcfHNZ; 
CqtPRJvHlGJFssiPzsOm[1] = TfsmDFpPPOscKZifVzSQ; ClEhcJFlvGCgiavziIag = 
MgAiRWiTutoTMxKXjmHQ; BlRIQPyqJZORKENzSdYf = JsZenQeBPMhwsyEhVHiD; 
BuyZFXzwOMxcePIbCLfl = LgxABSJPBXdCozJkFqTg; CDJtexcMbXMWAmnNZsNf = 
LklYEpYUjaLTgcFFAaJX; NonAlignFlag = gWETwFdWHfKuelmlKNCC ? false : 
(opTensor->getChannels() % 8 != 0 || ipTensor->getChannels() % 8 != 0); if 
(NonAlignFlag == true) { int NumOutputFeatures = opTensor->getChannels() + (8 - 
((opTensor->getChannels() % 8 ? opTensor->getChannels() % 8 : 8))); int 
NumInputFeatures = ipTensor->getChannels() + (8 - ((ipTensor->getChannels() % 8 
? ipTensor->getChannels() % 8 : 8))); 
setData((float*)calloc(opTensor->getBatchSize() * opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(), sizeof(float))); tqZLvfMHdgZzbchUyDzd = 
(float*)calloc(NumInputFeatures / FwLnexHgxHRquTKmNpoa * NumOutputFeatures * 
CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd, sizeof(float)); XNZmftADYzuZnIYIpBaT 
= (float*)calloc(NumOutputFeatures, sizeof(float)); fylVqSnTjNbHDtlPhzaj = 
(float*)calloc(ipTensor->getBatchSize() * NumInputFeatures * 
ipTensor->getHeight() * ipTensor->getWidth(), sizeof(float)); 
muwRQxtWMMXAPxSuMYBw = (float*)calloc(opTensor->getBatchSize() * 
NumOutputFeatures * opTensor->getHeight() * opTensor->getWidth(), 
sizeof(float)); } else { tqZLvfMHdgZzbchUyDzd = (float*)calloc(ipTensor->getChannels() 
/ FwLnexHgxHRquTKmNpoa * opTensor->getChannels() * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd, sizeof(float)); XNZmftADYzuZnIYIpBaT = 
(float*)calloc(opTensor->getChannels(), sizeof(float)); 
setData((float*)calloc(opTensor->getBatchSize() * opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(), sizeof(float))); } 
loadWeights(yPBlKhIGljihkXaXbYpB); loadBias(YNDVziqpDddiXQKYZZhX); return; } 
void MWConvLayerImpl::predict() { MWConvLayer* convLayer = 
static_cast<MWConvLayer*>(getLayer()); MWTensor* ipTensor = 
convLayer->getInputTensor(); MWTensor* opTensor = convLayer->getOutputTensor(); 
int n = ipTensor->getBatchSize(); int c = NonAlignFlag ? 
ipTensor->getChannels() + (8 - ((ipTensor->getChannels() % 8 ? 
ipTensor->getChannels() % 8 : 8))) : ipTensor->getChannels(); int h = 
ipTensor->getHeight(); int w = ipTensor->getWidth(); auto eng = 
engine(engine::cpu, 0); int wgt_h = CufLFODQDXTAPyRqYodN; int wgt_w = 
DRzwhbNPpftRRIXXfHzd; int num_filts = NonAlignFlag ? opTensor->getChannels() 
+ (8 - ((opTensor->getChannels() % 8 ? opTensor->getChannels() % 8 : 8))) : 
opTensor->getChannels(); float* twppmWSuyDzoZjSbrMHi = tqZLvfMHdgZzbchUyDzd; float* 
XYbzSmRQGatVJtGmDZSo = XNZmftADYzuZnIYIpBaT; float* input = NonAlignFlag ? 
fylVqSnTjNbHDtlPhzaj : ipTensor->getData(); float* output = NonAlignFlag ? 
muwRQxtWMMXAPxSuMYBw : getData(); if (NonAlignFlag == true) { float* 
prevLayerOp = ipTensor->getData(); float* input_ptr = fylVqSnTjNbHDtlPhzaj; 
for (int i = 0; i < n; i++) { std::memcpy(input_ptr, prevLayerOp, 
ipTensor->getChannels() * h * w * sizeof(float)); prevLayerOp += 
ipTensor->getChannels() * h * w; input_ptr += c * h * w; } } auto aprop_kind = 
prop_kind::forward; bool with_bias = true; auto c_src_desc = memory::desc({n, 
c, h, w}, memory::data_type::f32, memory::format::nchw); auto c_weights_desc = 
FwLnexHgxHRquTKmNpoa > 1 ? memory::desc({FwLnexHgxHRquTKmNpoa, num_filts / 
FwLnexHgxHRquTKmNpoa, c / FwLnexHgxHRquTKmNpoa, wgt_h, wgt_w}, 
memory::data_type::f32, memory::format::goihw) : memory::desc({num_filts, c, 
wgt_h, wgt_w}, memory::data_type::f32, memory::format::oihw); auto c_bias_desc 
= with_bias ? memory::desc({num_filts}, memory::data_type::f32, 
memory::format::x) : memory::desc({}, memory::data_type::f32, 
memory::format::x); auto c_dst_desc = memory::desc({n, num_filts, 
opTensor->getHeight(), opTensor->getWidth()}, memory::data_type::f32, 
memory::format::nchw); auto src_primitive_desc = 
memory::primitive_desc(c_src_desc, eng); auto weights_primitive_desc = 
memory::primitive_desc(c_weights_desc, eng); auto bias_primitive_desc = 
memory::primitive_desc(c_bias_desc, eng); auto dst_primitive_desc = 
memory::primitive_desc(c_dst_desc, eng); auto c_src = 
memory(src_primitive_desc, input); auto c_weights = 
memory(weights_primitive_desc, twppmWSuyDzoZjSbrMHi); auto c_bias = with_bias ? 
memory(bias_primitive_desc, XYbzSmRQGatVJtGmDZSo) : memory(bias_primitive_desc); auto 
c_dst = memory(dst_primitive_desc, output); auto conv_src_md = memory::desc({n, 
c, h, w}, memory::data_type::f32, memory::format::any); auto conv_bias_md = 
memory::desc({num_filts}, memory::data_type::f32, memory::format::any); auto 
conv_weights_md = FwLnexHgxHRquTKmNpoa > 1 ? 
memory::desc({FwLnexHgxHRquTKmNpoa, num_filts / FwLnexHgxHRquTKmNpoa, c / 
FwLnexHgxHRquTKmNpoa, wgt_h, wgt_w}, memory::data_type::f32, 
memory::format::any) : memory::desc({num_filts, c, wgt_h, wgt_w}, 
memory::data_type::f32, memory::format::any); auto conv_dst_md = 
memory::desc({n, num_filts, opTensor->getHeight(), opTensor->getWidth()}, 
memory::data_type::f32, memory::format::any); std::vector<int> padR = 
{BlRIQPyqJZORKENzSdYf, CDJtexcMbXMWAmnNZsNf}; for (int i = 0; i < 2; 
++i) { if ((h + ClEhcJFlvGCgiavziIag + padR[0] - wgt_h) / 
CqtPRJvHlGJFssiPzsOm[0] + 1 != opTensor->getHeight()) { ++padR[0]; } if ((w + 
BuyZFXzwOMxcePIbCLfl + padR[1] - wgt_w) / CqtPRJvHlGJFssiPzsOm[1] + 1 != 
opTensor->getWidth()) { ++padR[1]; } } auto conv_desc = with_bias ? 
convolution_forward::desc( aprop_kind, convolution_direct, conv_src_md, 
conv_weights_md, conv_bias_md, conv_dst_md, {CqtPRJvHlGJFssiPzsOm[0], 
CqtPRJvHlGJFssiPzsOm[1]}, {ClEhcJFlvGCgiavziIag, 
BuyZFXzwOMxcePIbCLfl}, padR, padding_kind::zero) : 
convolution_forward::desc( aprop_kind, convolution_direct, conv_src_md, 
conv_weights_md, conv_dst_md, {CqtPRJvHlGJFssiPzsOm[0], 
CqtPRJvHlGJFssiPzsOm[1]}, {ClEhcJFlvGCgiavziIag, 
BuyZFXzwOMxcePIbCLfl}, padR, padding_kind::zero); auto conv_primitive_desc 
= convolution_forward::primitive_desc(conv_desc, eng); auto conv_src_memory = 
c_src; primitive conv_reorder_src; bool reorder_conv_src = false; if 
(memory::primitive_desc(conv_primitive_desc.src_primitive_desc()) != 
c_src.get_primitive_desc()) { conv_src_memory = 
memory(conv_primitive_desc.src_primitive_desc()); conv_reorder_src = 
reorder(c_src, conv_src_memory); reorder_conv_src = true; } auto 
conv_weights_memory = c_weights; primitive conv_reorder_weights; bool 
reorder_conv_weights = false; if 
(memory::primitive_desc(conv_primitive_desc.weights_primitive_desc()) != 
c_weights.get_primitive_desc()) { conv_weights_memory = 
memory(conv_primitive_desc.weights_primitive_desc()); conv_reorder_weights = 
reorder(c_weights, conv_weights_memory); reorder_conv_weights = true; } auto 
conv_dst_memory = c_dst; primitive conv_reorder_dst; bool reorder_conv_dst = 
false; if (memory::primitive_desc(conv_primitive_desc.dst_primitive_desc()) != 
c_dst.get_primitive_desc()) { conv_dst_memory = 
memory(conv_primitive_desc.dst_primitive_desc()); conv_reorder_dst = 
reorder(conv_dst_memory, c_dst); reorder_conv_dst = true; } auto conv = 
with_bias ? convolution_forward(conv_primitive_desc, conv_src_memory, 
conv_weights_memory, c_bias, conv_dst_memory) : 
convolution_forward(conv_primitive_desc, conv_src_memory, conv_weights_memory, 
conv_dst_memory); std::vector<primitive> pipeline; if (reorder_conv_src) { 
pipeline.push_back(conv_reorder_src); } if (reorder_conv_weights) { 
pipeline.push_back(conv_reorder_weights); } pipeline.push_back(conv); if 
(reorder_conv_dst) { pipeline.push_back(conv_reorder_dst); } auto s = 
stream(stream::kind::lazy); s.submit(pipeline).wait(); if (NonAlignFlag == 
true) { float* CurLayerOp = getData(); float* output_ptr = 
muwRQxtWMMXAPxSuMYBw; for (int i = 0; i < n; i++) { std::memcpy(CurLayerOp, 
output_ptr, opTensor->getChannels() * opTensor->getHeight() * 
opTensor->getWidth() * sizeof(float)); CurLayerOp += opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(); output_ptr += num_filts * 
opTensor->getHeight() * opTensor->getWidth(); } }
#if MW_CONV_TAP
 mw_interm_tap(output, opTensor->getBatchSize() * opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWConvLayerImpl::cleanup() { if (NonAlignFlag == true) { 
free(fylVqSnTjNbHDtlPhzaj); free(muwRQxtWMMXAPxSuMYBw); } 
free(tqZLvfMHdgZzbchUyDzd); free(XNZmftADYzuZnIYIpBaT); for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } void MWConvLayerImpl::loadWeights(const char* bQjijJlpNAVdwDDQgpaX) { 
MWConvLayer* convLayer = static_cast<MWConvLayer*>(getLayer()); MWTensor* 
ipTensor = convLayer->getInputTensor(); MWTensor* opTensor = 
convLayer->getOutputTensor(); float* vpXxoeEhdEosLSsYXkNG = 
(float*)calloc(ipTensor->getChannels() / FwLnexHgxHRquTKmNpoa * 
opTensor->getChannels() * CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd, 
sizeof(float)); size_t retVal; FILE* eVAFqeShtGZAZluKdMvQ = 
MWCNNLayer::openBinaryFile(bQjijJlpNAVdwDDQgpaX); int lsqeARVLtpJTWezgnTkg = 
ipTensor->getChannels() / FwLnexHgxHRquTKmNpoa * opTensor->getChannels() * 
CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd;  retVal = 
fread(vpXxoeEhdEosLSsYXkNG, sizeof(float), lsqeARVLtpJTWezgnTkg, eVAFqeShtGZAZluKdMvQ); if (retVal 
!= (size_t)lsqeARVLtpJTWezgnTkg) { 
printf("MWConvLayer::loadWeights - File read Failed\n"); } if 
(CufLFODQDXTAPyRqYodN != 1 && DRzwhbNPpftRRIXXfHzd != 1) { float* 
uOjfVTZSbCZATdZVDwrL = (float*)malloc(sizeof(float) * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd); for (int k = 0; k < lsqeARVLtpJTWezgnTkg / 
CufLFODQDXTAPyRqYodN / DRzwhbNPpftRRIXXfHzd; k++) { for (int i = 0; i < 
CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd; i++) { uOjfVTZSbCZATdZVDwrL[i] = 
vpXxoeEhdEosLSsYXkNG[k * CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd + i]; } for 
(int j = 0; j < CufLFODQDXTAPyRqYodN; j++) for (int i = 0; i < 
DRzwhbNPpftRRIXXfHzd; i++) { vpXxoeEhdEosLSsYXkNG[k * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd + j * DRzwhbNPpftRRIXXfHzd + i] = uOjfVTZSbCZATdZVDwrL[j + i 
* CufLFODQDXTAPyRqYodN]; } } free(uOjfVTZSbCZATdZVDwrL); } if (NonAlignFlag == 
true) { int NumInputFeatures = ipTensor->getChannels() + (8 - 
((ipTensor->getChannels() % 8 ? ipTensor->getChannels() % 8 : 8))); float* 
yCdIUfwoZFngCRRRkCTg = vpXxoeEhdEosLSsYXkNG; float* wXLECKaOWaQNZlVHfnNP = tqZLvfMHdgZzbchUyDzd; for 
(int i = 0; i < opTensor->getChannels(); i++) { memcpy(wXLECKaOWaQNZlVHfnNP, 
yCdIUfwoZFngCRRRkCTg, ipTensor->getChannels() * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd * sizeof(float)); wXLECKaOWaQNZlVHfnNP += (NumInputFeatures 
* CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd); yCdIUfwoZFngCRRRkCTg += 
(ipTensor->getChannels() * CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd); } 
} else { memcpy(tqZLvfMHdgZzbchUyDzd, vpXxoeEhdEosLSsYXkNG, lsqeARVLtpJTWezgnTkg * sizeof(float)); } 
fclose(eVAFqeShtGZAZluKdMvQ); free(vpXxoeEhdEosLSsYXkNG); return; } void 
MWConvLayerImpl::loadBias(const char* bQjijJlpNAVdwDDQgpaX) { size_t retVal; 
MWConvLayer* convLayer = static_cast<MWConvLayer*>(getLayer()); MWTensor* 
opTensor = convLayer->getOutputTensor(); float* YGiQICncmsGZkNUyiQyg = 
XNZmftADYzuZnIYIpBaT; FILE* eVAFqeShtGZAZluKdMvQ = 
MWCNNLayer::openBinaryFile(bQjijJlpNAVdwDDQgpaX); int lsqeARVLtpJTWezgnTkg = 
opTensor->getChannels();  retVal = fread(YGiQICncmsGZkNUyiQyg, sizeof(float), 
lsqeARVLtpJTWezgnTkg, eVAFqeShtGZAZluKdMvQ); if (retVal != (size_t)lsqeARVLtpJTWezgnTkg) { 
printf("MWConvLayer::loadBias - File read Failed\n"); } fclose(eVAFqeShtGZAZluKdMvQ); 
return; } MWReLULayerImpl::MWReLULayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl, int inPlace) : MWCNNLayerImpl(layer) , 
fSbUUBgjKRbNXrHrlOLo(inPlace) { lHtftnmGBvlSSoGOXVui = ntwk_impl; 
createReLULayer(); } MWReLULayerImpl::~MWReLULayerImpl() { } void 
MWReLULayerImpl::createReLULayer() { MWReLULayer* reluLayer = 
static_cast<MWReLULayer*>(getLayer()); MWTensor* ipTensor = 
reluLayer->getInputTensor(); if (fSbUUBgjKRbNXrHrlOLo) {  
setData(ipTensor->getData()); } else { 
setData((float*)calloc(ipTensor->getBatchSize() * ipTensor->getChannels() * 
ipTensor->getHeight() * ipTensor->getWidth(), sizeof(float))); } } void 
MWReLULayerImpl::predict() { MWReLULayer* reluLayer = 
static_cast<MWReLULayer*>(getLayer()); MWTensor* ipTensor = 
reluLayer->getInputTensor(); MWTensor* opTensor = reluLayer->getOutputTensor(); 
const double negative_slope = 0.0; float* relu_src_buffer = 
ipTensor->getData(); float* relu_dst_buffer = opTensor->getData(); auto 
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
 mw_interm_tap(opTensor->getData(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWReLULayerImpl::cleanup() { if (!fSbUUBgjKRbNXrHrlOLo) { float* 
data = getLayer()->getOutputTensor(0)->getData(); if (data) { free(data); }  } 
} MWNormLayerImpl::MWNormLayerImpl(MWCNNLayer* layer, unsigned 
URgvgDXnZskIYGdtimcU, double AuqaQHxmPQSyYRemQvyX, double BUOdotSvmFyUWQKMUdra, 
double jmcFOAbZArjGDNhshSro, MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer) { 
lHtftnmGBvlSSoGOXVui = ntwk_impl; createNormLayer(URgvgDXnZskIYGdtimcU, 
AuqaQHxmPQSyYRemQvyX, BUOdotSvmFyUWQKMUdra); } MWNormLayerImpl::~MWNormLayerImpl() { } 
void MWNormLayerImpl::createNormLayer(unsigned URgvgDXnZskIYGdtimcU, 
double AuqaQHxmPQSyYRemQvyX, double BUOdotSvmFyUWQKMUdra) { MWNormLayer* normLayer = 
static_cast<MWNormLayer*>(getLayer()); MWTensor* ipTensor = 
normLayer->getInputTensor(); FLuSVNoPhAFKtLUchSvv = AuqaQHxmPQSyYRemQvyX; 
FeVcBgtQmTLtmnNcJGMY = BUOdotSvmFyUWQKMUdra; EvebzoroiuKkIxwjkGnD = 
URgvgDXnZskIYGdtimcU; setData((float*)calloc(ipTensor->getBatchSize() * 
ipTensor->getChannels() * ipTensor->getHeight() * ipTensor->getWidth(), 
sizeof(float))); return; } void MWNormLayerImpl::predict() { MWNormLayer* 
normLayer = static_cast<MWNormLayer*>(getLayer()); MWTensor* ipTensor = 
normLayer->getInputTensor(); MWTensor* opTensor = normLayer->getOutputTensor(); 
float* lrn_src_buffer = ipTensor->getData(); float* lrn_dst_buffer = 
opTensor->getData(); auto eng = engine(engine::cpu, 0); auto l_src_desc = 
memory::desc({ipTensor->getBatchSize(), ipTensor->getChannels(), 
ipTensor->getHeight(), ipTensor->getWidth()}, memory::data_type::f32, 
memory::format::nchw); auto l_dst_desc = 
memory::desc({opTensor->getBatchSize(), opTensor->getChannels(), 
opTensor->getHeight(), opTensor->getWidth()}, memory::data_type::f32, 
memory::format::nchw); auto src_primitive_desc = 
memory::primitive_desc(l_src_desc, eng); auto dst_primitive_desc = 
memory::primitive_desc(l_dst_desc, eng); auto l_src = 
memory(src_primitive_desc, lrn_src_buffer); auto l_dst = 
memory(dst_primitive_desc, lrn_dst_buffer); auto lrn_desc = 
lrn_forward::desc(prop_kind::forward_scoring, algorithm::lrn_across_channels, 
l_src_desc, EvebzoroiuKkIxwjkGnD, FLuSVNoPhAFKtLUchSvv, FeVcBgtQmTLtmnNcJGMY); 
auto lrn_prim_desc = lrn_forward::primitive_desc(lrn_desc, eng); auto l = 
lrn_forward(lrn_prim_desc, l_src, l_dst); std::vector<primitive> pipeline; auto 
s = stream(stream::kind::lazy); pipeline.push_back(l); s.submit(pipeline).wait();
#if MW_NORM_TAP
 mw_interm_tap(opTensor->getData(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWNormLayerImpl::cleanup() { for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } MWMaxPoolingLayerImpl::MWMaxPoolingLayerImpl(MWCNNLayer* layer, int 
PoolH, int PoolW, int SUjIWYfjMcdzSZaCSVRT, int SUleyRyvAggTFnSdxLru, int 
MgAiRWiTutoTMxKXjmHQ, int JsZenQeBPMhwsyEhVHiD, int LgxABSJPBXdCozJkFqTg, int 
LklYEpYUjaLTgcFFAaJX, bool UpnEytIWGokwbTFkBcSx, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer) { lHtftnmGBvlSSoGOXVui = ntwk_impl; 
assert(!UpnEytIWGokwbTFkBcSx); createMaxPoolingLayer(PoolH, PoolW, 
SUjIWYfjMcdzSZaCSVRT, SUleyRyvAggTFnSdxLru, MgAiRWiTutoTMxKXjmHQ, 
JsZenQeBPMhwsyEhVHiD, LgxABSJPBXdCozJkFqTg, LklYEpYUjaLTgcFFAaJX); } 
MWMaxPoolingLayerImpl::~MWMaxPoolingLayerImpl() { } float* 
MWMaxPoolingLayerImpl::getIndexData() { assert(false); } void 
MWMaxPoolingLayerImpl::createMaxPoolingLayer(int PoolH, int PoolW, int 
TbrNrGxaFFHrzKUcfHNZ, int TfsmDFpPPOscKZifVzSQ, int MgAiRWiTutoTMxKXjmHQ, int 
JsZenQeBPMhwsyEhVHiD, int LgxABSJPBXdCozJkFqTg, int LklYEpYUjaLTgcFFAaJX) { 
MWMaxPoolingLayer* maxPoolLayer = static_cast<MWMaxPoolingLayer*>(getLayer()); 
MWTensor* ipTensor = maxPoolLayer->getInputTensor(); MWTensor* opTensor = 
maxPoolLayer->getOutputTensor(); RVrPByQXdKmunRZHKWJD[0] = 
TbrNrGxaFFHrzKUcfHNZ; RVrPByQXdKmunRZHKWJD[1] = TfsmDFpPPOscKZifVzSQ; 
QhTWatiCfcWYsHdkcyhZ = MgAiRWiTutoTMxKXjmHQ; OzygUJRIZYnGLzSjgahB = 
JsZenQeBPMhwsyEhVHiD; PfisSEEWDaQFynnzlcin = LgxABSJPBXdCozJkFqTg; 
PtRNGuserCxHAQfyEjFc = LklYEpYUjaLTgcFFAaJX; NmExSIssnXpisMKKatUq = PoolH; 
THfVbcZJtANcLKxEriuV = PoolW; setData((float*)calloc(opTensor->getBatchSize() * 
ipTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), 
sizeof(float))); return; } void MWMaxPoolingLayerImpl::predict() { 
MWMaxPoolingLayer* maxPoolLayer = static_cast<MWMaxPoolingLayer*>(getLayer()); 
MWTensor* ipTensor = maxPoolLayer->getInputTensor(); MWTensor* opTensor = 
maxPoolLayer->getOutputTensor(); int n = ipTensor->getBatchSize(); int c = 
ipTensor->getChannels(); int h = ipTensor->getHeight(); int w = 
ipTensor->getWidth(); auto cpu_engine = engine(engine::cpu, 0); float* 
pool_src_t = ipTensor->getData(); float* pool_dst_buffer_t = 
opTensor->getData(); float* pool_reorder_src = (float*)malloc(n * c * h * w * 
sizeof(float)); float* inp_ptr = pool_src_t; memory::format format_block8 = 
memory::format::nchw; bool ChanBlock8 = true; if (c % 8 != 0) { ChanBlock8 = 
false; } if (ChanBlock8) { format_block8 = memory::format::nChw8c; inp_ptr = 
pool_reorder_src; } memory::dims pool_usr_tz = {n, c, h, w}; memory::dims 
pool_dst_tz = {n, c, opTensor->getHeight(), opTensor->getWidth()}; memory::dims 
pool_kernel = {NmExSIssnXpisMKKatUq, THfVbcZJtANcLKxEriuV}; memory::dims 
RQSttSyDKXCHDWSijmNk = {RVrPByQXdKmunRZHKWJD[0], RVrPByQXdKmunRZHKWJD[1]}; 
auto RAtlBpdedvgxUsgDTsch = {QhTWatiCfcWYsHdkcyhZ, 
PfisSEEWDaQFynnzlcin}; auto pool_user_src_memory = memory( {{{pool_usr_tz}, 
memory::data_type::f32, memory::format::nchw}, cpu_engine}, inp_ptr); auto 
pool_user_dst_memory = memory({{{pool_dst_tz}, memory::data_type::f32, 
memory::format::nchw}, cpu_engine}, pool_dst_buffer_t); auto pool_usr_md = 
memory::desc({pool_usr_tz}, memory::data_type::f32, format_block8); auto 
pool_dst_md = memory::desc({pool_dst_tz}, memory::data_type::f32, 
format_block8); auto mpd_i = memory::primitive_desc( {{pool_usr_tz}, 
memory::data_type::f32, memory::format::nchw}, cpu_engine); auto mpd_o = 
memory::primitive_desc({{pool_usr_tz}, memory::data_type::f32, format_block8}, 
cpu_engine); auto src = memory(mpd_i, pool_src_t); auto dst = memory(mpd_o, 
pool_reorder_src); auto pool_desc = pooling_forward::desc( prop_kind::forward, 
pooling_max, pool_usr_md, pool_dst_md, RQSttSyDKXCHDWSijmNk, pool_kernel, 
RAtlBpdedvgxUsgDTsch, {OzygUJRIZYnGLzSjgahB,PtRNGuserCxHAQfyEjFc}, 
padding_kind::zero); auto pool_pd = pooling_forward::primitive_desc(pool_desc, 
cpu_engine); auto pool_dst_memory = pool_user_dst_memory; if 
(memory::primitive_desc(pool_pd.dst_primitive_desc()) != 
pool_user_dst_memory.get_primitive_desc()) { pool_dst_memory = 
memory(pool_pd.dst_primitive_desc()); } auto pool_indices_memory = 
memory(pool_dst_memory.get_primitive_desc()); std::vector<primitive> net; if 
(ChanBlock8) { net.push_back(reorder(src, dst)); } net.push_back( 
pooling_forward(pool_pd, pool_user_src_memory, pool_dst_memory, 
pool_indices_memory)); if (pool_dst_memory != pool_user_dst_memory) { 
net.push_back(reorder(pool_dst_memory, pool_user_dst_memory)); } 
stream(stream::kind::eager).submit(net).wait(); free(pool_reorder_src);
#if MW_POOL_TAP
 mw_interm_tap(opTensor->getData(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWMaxPoolingLayerImpl::cleanup() { for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } MWFCLayerImpl::MWFCLayerImpl(MWCNNLayer* layer, const char* 
yPBlKhIGljihkXaXbYpB, const char* YNDVziqpDddiXQKYZZhX, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer) { lHtftnmGBvlSSoGOXVui = ntwk_impl; 
createFCLayer(yPBlKhIGljihkXaXbYpB, YNDVziqpDddiXQKYZZhX); } 
MWFCLayerImpl::~MWFCLayerImpl() { } void MWFCLayerImpl::createFCLayer(const 
char* yPBlKhIGljihkXaXbYpB, const char* YNDVziqpDddiXQKYZZhX) { MWFCLayer* 
fcLayer = static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(); MWTensor* opTensor = fcLayer->getOutputTensor(); 
CufLFODQDXTAPyRqYodN = ipTensor->getHeight(); DRzwhbNPpftRRIXXfHzd = 
ipTensor->getWidth(); tqZLvfMHdgZzbchUyDzd = (float*)calloc(ipTensor->getChannels() * 
ipTensor->getHeight() * ipTensor->getWidth() * opTensor->getChannels(), 
sizeof(float)); XNZmftADYzuZnIYIpBaT = (float*)calloc(opTensor->getChannels(), 
sizeof(float)); setData((float*)calloc(opTensor->getBatchSize() * 
opTensor->getChannels(), sizeof(float))); loadWeights(yPBlKhIGljihkXaXbYpB); 
loadBias(YNDVziqpDddiXQKYZZhX); return; } void MWFCLayerImpl::loadWeights(const 
char* bQjijJlpNAVdwDDQgpaX) { size_t retVal; MWFCLayer* fcLayer = 
static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(); MWTensor* opTensor = fcLayer->getOutputTensor(); 
FILE* eVAFqeShtGZAZluKdMvQ = MWCNNLayer::openBinaryFile(bQjijJlpNAVdwDDQgpaX); int 
lsqeARVLtpJTWezgnTkg = (ipTensor->getChannels() * ipTensor->getHeight() * 
ipTensor->getWidth()) * opTensor->getChannels();  retVal = fread(tqZLvfMHdgZzbchUyDzd, 
sizeof(float), lsqeARVLtpJTWezgnTkg, eVAFqeShtGZAZluKdMvQ); if (retVal != 
(size_t)lsqeARVLtpJTWezgnTkg) { 
printf("MWFCLayer::loadWeights - File read Failed\n"); } if 
(CufLFODQDXTAPyRqYodN != 1 && DRzwhbNPpftRRIXXfHzd != 1) { float* 
uOjfVTZSbCZATdZVDwrL = (float*)malloc(sizeof(float) * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd); for (int k = 0; k < lsqeARVLtpJTWezgnTkg / 
CufLFODQDXTAPyRqYodN / DRzwhbNPpftRRIXXfHzd; k++) { for (int i = 0; i < 
CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd; i++) { uOjfVTZSbCZATdZVDwrL[i] = 
tqZLvfMHdgZzbchUyDzd[k * CufLFODQDXTAPyRqYodN * DRzwhbNPpftRRIXXfHzd + i]; } for 
(int j = 0; j < CufLFODQDXTAPyRqYodN; j++) for (int i = 0; i < 
DRzwhbNPpftRRIXXfHzd; i++) { tqZLvfMHdgZzbchUyDzd[k * CufLFODQDXTAPyRqYodN * 
DRzwhbNPpftRRIXXfHzd + j * DRzwhbNPpftRRIXXfHzd + i] = uOjfVTZSbCZATdZVDwrL[j + i 
* CufLFODQDXTAPyRqYodN]; } } free(uOjfVTZSbCZATdZVDwrL); } fclose(eVAFqeShtGZAZluKdMvQ); 
return; } void MWFCLayerImpl::loadBias(const char* bQjijJlpNAVdwDDQgpaX) { 
size_t retVal; MWFCLayer* fcLayer = static_cast<MWFCLayer*>(getLayer()); 
MWTensor* opTensor = fcLayer->getOutputTensor(); FILE* eVAFqeShtGZAZluKdMvQ = 
MWCNNLayer::openBinaryFile(bQjijJlpNAVdwDDQgpaX); int lsqeARVLtpJTWezgnTkg = 
opTensor->getChannels();  retVal = fread(XNZmftADYzuZnIYIpBaT, sizeof(float), 
lsqeARVLtpJTWezgnTkg, eVAFqeShtGZAZluKdMvQ); if (retVal != (size_t)lsqeARVLtpJTWezgnTkg) { 
printf("MWFCLayer::loadBias - File read Failed\n"); } fclose(eVAFqeShtGZAZluKdMvQ); 
return; } void MWFCLayerImpl::predict() { MWFCLayer* fcLayer = 
static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(); MWTensor* opTensor = fcLayer->getOutputTensor();
#if USE_MKL_INTEL
 if (ipTensor->getBatchSize() == 1) { int rowsA = opTensor->getChannels(); int 
colsA = ipTensor->getChannels() * ipTensor->getWidth() * ipTensor->getHeight(); 
float* inpMatrix = tqZLvfMHdgZzbchUyDzd; float* inpVector = ipTensor->getData(); float* 
opVector = opTensor->getData(); memcpy(opVector, XNZmftADYzuZnIYIpBaT, rowsA * 
sizeof(float)); CBLAS_TRANSPOSE transA = CblasNoTrans; 
cblas_sgemv(CblasRowMajor, transA, rowsA, colsA, 1.0, inpMatrix, colsA, 
inpVector, 1.0, 1.0, opVector, 1.0);
#if MW_FC_TAP
 mw_interm_tap(opTensor->getData(), ipTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 } else { int rowsA = opTensor->getChannels(); int colsA = 
ipTensor->getChannels() * ipTensor->getWidth() * ipTensor->getHeight(); int 
rowsC = opTensor->getChannels(); int colsC = ipTensor->getBatchSize(); float* 
inpMatrix = tqZLvfMHdgZzbchUyDzd; float* inpVector = ipTensor->getData(); float* 
opVector = (float*)malloc(ipTensor->getBatchSize() * opTensor->getChannels() * 
sizeof(float)); float* opVector_b = (float*)malloc(ipTensor->getBatchSize() * 
opTensor->getChannels() * sizeof(float)); int btch; for (btch = 0; btch < 
ipTensor->getBatchSize(); btch++) { memcpy(&opVector_b[btch * rowsA], 
XNZmftADYzuZnIYIpBaT, rowsA * sizeof(float)); } CBLAS_LAYOUT order = CblasRowMajor; 
CBLAS_TRANSPOSE transA = CblasNoTrans;  CBLAS_TRANSPOSE transB = CblasTrans;  
mkl_somatcopy('R', 'T', ipTensor->getBatchSize(), opTensor->getChannels(), 1.0, 
opVector_b, opTensor->getChannels(), opVector, ipTensor->getBatchSize()); 
cblas_sgemm(order, transA, transB, rowsC, colsC, colsA, 1.0, inpMatrix, colsA, 
inpVector, colsA, 1.0, opVector, colsC); mkl_somatcopy('R', 'T', 
opTensor->getChannels(), ipTensor->getBatchSize(), 1.0, opVector, 
ipTensor->getBatchSize(), opTensor->getData(), opTensor->getChannels());
#if MW_FC_TAP
 mw_interm_tap(opTensor->getData(), ipTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 free(opVector); free(opVector_b); }
#else
 auto eng = engine(engine::cpu, 0); auto ip_src_desc = 
memory::desc({ipTensor->getBatchSize(), ipTensor->getChannels() * 
ipTensor->getHeight() * ipTensor->getWidth()}, memory::data_type::f32, 
memory::format::nc); auto ip_weights_desc = 
memory::desc({opTensor->getChannels(), ipTensor->getChannels() * 
ipTensor->getHeight() * ipTensor->getWidth()}, memory::data_type::f32, 
memory::format::oi); auto ip_bias_desc = 
memory::desc({opTensor->getChannels()}, memory::data_type::f32, 
memory::format::x); auto ip_dst_desc = memory::desc({ipTensor->getBatchSize(), 
opTensor->getChannels()}, memory::data_type::f32, memory::format::nc); auto 
ip_src = memory(memory::primitive_desc(ip_src_desc, eng)); auto ip_weights = 
memory(memory::primitive_desc(ip_weights_desc, eng)); auto ip_bias = 
memory(memory::primitive_desc(ip_bias_desc, eng)); auto ip_dst = 
memory(memory::primitive_desc(ip_dst_desc, eng)); auto dst_ref = 
memory(memory::primitive_desc(ip_dst_desc, eng)); 
ip_src.set_data_handle(ipTensor->getData()); 
ip_weights.set_data_handle(tqZLvfMHdgZzbchUyDzd); 
ip_bias.set_data_handle(XNZmftADYzuZnIYIpBaT); 
ip_dst.set_data_handle(opTensor->getData()); auto ip_desc = 
inner_product_forward::desc(prop_kind::forward, ip_src_desc, ip_weights_desc, 
ip_bias_desc, ip_dst_desc); auto ip_primitive_desc = 
inner_product_forward::primitive_desc(ip_desc, eng); auto ip = 
inner_product_forward(ip_primitive_desc, ip_src, ip_weights, ip_bias, ip_dst); 
std::vector<primitive> pipeline; pipeline.push_back(ip); stream(stream::kind::lazy).submit(pipeline).wait();
#if MW_FC_TAP
 mw_interm_tap(opTensor->getData(), ipTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
#endif
 return; } void MWFCLayerImpl::cleanup() { free(tqZLvfMHdgZzbchUyDzd); 
free(XNZmftADYzuZnIYIpBaT); for (int idx = 0; idx < getLayer()->getNumOutputs(); idx++) 
{ float* data = getLayer()->getOutputTensor(idx)->getData(); if (data) { 
free(data); } } return; } MWSoftmaxLayerImpl::MWSoftmaxLayerImpl(MWCNNLayer* 
layer, MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer) { 
lHtftnmGBvlSSoGOXVui = ntwk_impl; createSoftmaxLayer(); } 
MWSoftmaxLayerImpl::~MWSoftmaxLayerImpl() { } void 
MWSoftmaxLayerImpl::createSoftmaxLayer() { MWSoftmaxLayer* sfmxLayer = 
static_cast<MWSoftmaxLayer*>(getLayer()); MWTensor* opTensor = 
sfmxLayer->getOutputTensor(); setData((float*)calloc(opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), 
sizeof(float))); return; } void MWSoftmaxLayerImpl::predict() { MWSoftmaxLayer* 
sfmxLayer = static_cast<MWSoftmaxLayer*>(getLayer()); MWTensor* ipTensor = 
sfmxLayer->getInputTensor(); MWTensor* opTensor = sfmxLayer->getOutputTensor(); 
float* sfmx_src_buffer = ipTensor->getData(); float* sfmx_dst_buffer = 
opTensor->getData(); auto eng = engine(engine::cpu, 0); auto mem_desc = 
memory::desc({ipTensor->getBatchSize(), ipTensor->getChannels(), 
ipTensor->getHeight(), ipTensor->getWidth()}, memory::data_type::f32, 
memory::format::nchw); auto mem_prim_desc = memory::primitive_desc(mem_desc, 
eng); auto src = memory(mem_prim_desc, sfmx_src_buffer); auto dst = 
memory(mem_prim_desc, sfmx_dst_buffer); auto softmax_desc = 
softmax_forward::desc(prop_kind::forward_scoring, mem_desc, 1); auto 
softmax_prim_desc = softmax_forward::primitive_desc(softmax_desc, eng); auto 
softmax = softmax_forward(softmax_prim_desc, src, dst); std::vector<primitive> 
pipeline; pipeline.push_back(softmax); auto s = stream(stream::kind::lazy); s.submit(pipeline).wait();
#if MW_SFMX_TAP
 mw_interm_tap(opTensor->getData(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWSoftmaxLayerImpl::cleanup() { for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } MWAvgPoolingLayerImpl::MWAvgPoolingLayerImpl(MWCNNLayer* layer, int 
NNhshzQGJHLSGjDiVerE, int SugesRlPIbOVzRgNWRnl, int TbrNrGxaFFHrzKUcfHNZ, int 
TfsmDFpPPOscKZifVzSQ, int GZGFVDrXwFLJleoTDywO, int IIiwAtyrOtLzLWAUlTey, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer) { lHtftnmGBvlSSoGOXVui = 
ntwk_impl; createAvgPoolingLayer(NNhshzQGJHLSGjDiVerE, SugesRlPIbOVzRgNWRnl, 
TbrNrGxaFFHrzKUcfHNZ, TfsmDFpPPOscKZifVzSQ, GZGFVDrXwFLJleoTDywO, 
IIiwAtyrOtLzLWAUlTey); } MWAvgPoolingLayerImpl::~MWAvgPoolingLayerImpl() { } 
void MWAvgPoolingLayerImpl::createAvgPoolingLayer(int NNhshzQGJHLSGjDiVerE, int 
SugesRlPIbOVzRgNWRnl, int TbrNrGxaFFHrzKUcfHNZ, int TfsmDFpPPOscKZifVzSQ, int 
GZGFVDrXwFLJleoTDywO, int IIiwAtyrOtLzLWAUlTey) { MWAvgPoolingLayer* avgpoolLayer 
= static_cast<MWAvgPoolingLayer*>(getLayer()); MWTensor* ipTensor = 
avgpoolLayer->getInputTensor(0); MWTensor* opTensor = 
avgpoolLayer->getOutputTensor(0); RVrPByQXdKmunRZHKWJD[0] = 
TbrNrGxaFFHrzKUcfHNZ; RVrPByQXdKmunRZHKWJD[1] = TfsmDFpPPOscKZifVzSQ; 
OiVqrkNdXioJhALWMMvm[0] = GZGFVDrXwFLJleoTDywO; OiVqrkNdXioJhALWMMvm[1] = 
IIiwAtyrOtLzLWAUlTey; NmExSIssnXpisMKKatUq = NNhshzQGJHLSGjDiVerE; 
THfVbcZJtANcLKxEriuV = SugesRlPIbOVzRgNWRnl; 
setData((float*)calloc(opTensor->getBatchSize() * ipTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(), sizeof(float))); } void 
MWAvgPoolingLayerImpl::predict() { MWAvgPoolingLayer* avgpoolLayer = 
static_cast<MWAvgPoolingLayer*>(getLayer()); MWTensor* ipTensor = 
avgpoolLayer->getInputTensor(0); MWTensor* opTensor = 
avgpoolLayer->getOutputTensor(0); int n = ipTensor->getBatchSize(); int c = 
ipTensor->getChannels(); int h = ipTensor->getHeight(); int w = 
ipTensor->getWidth(); auto cpu_engine = engine(engine::cpu, 0); float* 
pool_src_t = ipTensor->getData(); float* pool_dst_buffer_t = 
opTensor->getData(); float* pool_reorder_src = (float*)malloc(n * c * h * w * 
sizeof(float)); memory::dims pool_usr_tz = {n, c, h, w}; memory::dims 
pool_dst_tz = {n, c, opTensor->getHeight(), opTensor->getWidth()}; memory::dims 
pool_kernel = {NmExSIssnXpisMKKatUq, THfVbcZJtANcLKxEriuV}; memory::dims 
RQSttSyDKXCHDWSijmNk = {RVrPByQXdKmunRZHKWJD[0], RVrPByQXdKmunRZHKWJD[1]}; 
auto RAtlBpdedvgxUsgDTsch = {OiVqrkNdXioJhALWMMvm[0], 
OiVqrkNdXioJhALWMMvm[1]}; auto pool_user_src_memory = memory({{{pool_usr_tz}, 
memory::data_type::f32, memory::format::nchw}, cpu_engine}, pool_reorder_src); 
auto pool_user_dst_memory = memory({{{pool_dst_tz}, memory::data_type::f32, 
memory::format::nchw}, cpu_engine}, pool_dst_buffer_t); auto pool_usr_md = 
memory::desc({pool_usr_tz}, memory::data_type::f32, memory::format::nChw8c); 
auto pool_dst_md = memory::desc({pool_dst_tz}, memory::data_type::f32, 
memory::format::nChw8c); auto mpd_i = memory::primitive_desc( {{pool_usr_tz}, 
memory::data_type::f32, memory::format::nchw}, cpu_engine); auto mpd_o = 
memory::primitive_desc( {{pool_usr_tz}, memory::data_type::f32, 
memory::format::nChw8c}, cpu_engine); auto src = memory(mpd_i, pool_src_t); 
auto dst = memory(mpd_o, pool_reorder_src); auto pool_desc = 
pooling_forward::desc( prop_kind::forward, pooling_avg, pool_usr_md, 
pool_dst_md, RQSttSyDKXCHDWSijmNk, pool_kernel, RAtlBpdedvgxUsgDTsch, 
RAtlBpdedvgxUsgDTsch, padding_kind::zero); auto pool_pd = 
pooling_forward::primitive_desc(pool_desc, cpu_engine); auto pool_dst_memory = 
pool_user_dst_memory; if (memory::primitive_desc(pool_pd.dst_primitive_desc()) 
!= pool_user_dst_memory.get_primitive_desc()) { pool_dst_memory = 
memory(pool_pd.dst_primitive_desc()); } auto pool_indices_memory = 
memory(pool_dst_memory.get_primitive_desc()); std::vector<primitive> net; 
net.push_back(reorder(src, dst)); net.push_back( pooling_forward(pool_pd, 
pool_user_src_memory, pool_dst_memory, pool_indices_memory)); if 
(pool_dst_memory != pool_user_dst_memory) { 
net.push_back(reorder(pool_dst_memory, pool_user_dst_memory)); } 
stream(stream::kind::eager).submit(net).wait(); free(pool_reorder_src);
#if MW_POOL_TAP
 mw_interm_tap(opTensor->getData(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWAvgPoolingLayerImpl::cleanup() { for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } } 
MWOutputLayerImpl::MWOutputLayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer) { createOutputLayer(); } 
MWOutputLayerImpl::~MWOutputLayerImpl() { } void 
MWOutputLayerImpl::createOutputLayer() { MWOutputLayer* opLayer = 
static_cast<MWOutputLayer*>(getLayer()); MWTensor* ipTensor = 
opLayer->getInputTensor(0); setData(ipTensor->getData()); } void 
MWOutputLayerImpl::predict() { } void MWOutputLayerImpl::cleanup() { }