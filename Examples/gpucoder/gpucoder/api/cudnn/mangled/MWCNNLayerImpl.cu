#include <cstdlib>
#include <cassert>
#include <stdio.h>
#include "MWCNNLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"
#ifdef RANDOM
#include <curand.h>
 curandGenerator_t WprSrhAStKGxyXeoxETy; void 
curand_call_line_file(curandStatus_t olKGEIcsxmLSoMhRhEtP, const int 
fOpFYwKNwIfWjnPzNuob, const char *UKtMXCCqdjeyaVHabkxg) { if (olKGEIcsxmLSoMhRhEtP != 
CURAND_STATUS_SUCCESS) { printf("%d, line: %d, file: %s\n", olKGEIcsxmLSoMhRhEtP, 
fOpFYwKNwIfWjnPzNuob, UKtMXCCqdjeyaVHabkxg); exit(EXIT_FAILURE); } }
#endif
 float* malloc_call_line_file(size_t msize, const int fOpFYwKNwIfWjnPzNuob, const 
char *UKtMXCCqdjeyaVHabkxg) { float * mem = (float*)malloc(msize); if (!mem) { 
printf("%s, line: %d, file: %s\n", "Memory allocation failed. ", 
fOpFYwKNwIfWjnPzNuob, UKtMXCCqdjeyaVHabkxg); exit(EXIT_FAILURE); } return mem; } void 
call_cuda_free(float* mem) { cudaError_t olKGEIcsxmLSoMhRhEtP = cudaFree(mem); if 
(olKGEIcsxmLSoMhRhEtP != cudaErrorCudartUnloading) { CUDA_CALL(olKGEIcsxmLSoMhRhEtP); 
} } void cuda_call_line_file(cudaError_t olKGEIcsxmLSoMhRhEtP, const int 
fOpFYwKNwIfWjnPzNuob, const char *UKtMXCCqdjeyaVHabkxg) { if (olKGEIcsxmLSoMhRhEtP != 
cudaSuccess) { printf("%s, line: %d, file: %s\n", 
cudaGetErrorString(olKGEIcsxmLSoMhRhEtP), fOpFYwKNwIfWjnPzNuob, UKtMXCCqdjeyaVHabkxg); 
exit(EXIT_FAILURE); } } void cudnn_call_line_file(cudnnStatus_t 
olKGEIcsxmLSoMhRhEtP, const int fOpFYwKNwIfWjnPzNuob, const char *UKtMXCCqdjeyaVHabkxg) { if 
(olKGEIcsxmLSoMhRhEtP != CUDNN_STATUS_SUCCESS) { 
printf("%s, line: %d, file: %s\n", cudnnGetErrorString(olKGEIcsxmLSoMhRhEtP), 
fOpFYwKNwIfWjnPzNuob, UKtMXCCqdjeyaVHabkxg); exit(EXIT_FAILURE); } } const char* 
cublasGetErrorString(cublasStatus_t olKGEIcsxmLSoMhRhEtP) { 
switch(olKGEIcsxmLSoMhRhEtP) { case CUBLAS_STATUS_SUCCESS: return 
"CUBLAS_STATUS_SUCCESS"; case CUBLAS_STATUS_NOT_INITIALIZED: return 
"CUBLAS_STATUS_NOT_INITIALIZED"; case CUBLAS_STATUS_ALLOC_FAILED: return 
"CUBLAS_STATUS_ALLOC_FAILED"; case CUBLAS_STATUS_INVALID_VALUE: return 
"CUBLAS_STATUS_INVALID_VALUE";  case CUBLAS_STATUS_ARCH_MISMATCH: return 
"CUBLAS_STATUS_ARCH_MISMATCH";  case CUBLAS_STATUS_MAPPING_ERROR: return 
"CUBLAS_STATUS_MAPPING_ERROR"; case CUBLAS_STATUS_EXECUTION_FAILED: return 
"CUBLAS_STATUS_EXECUTION_FAILED";  case CUBLAS_STATUS_INTERNAL_ERROR: return 
"CUBLAS_STATUS_INTERNAL_ERROR";  case CUBLAS_STATUS_NOT_SUPPORTED: return 
"CUBLAS_STATUS_NOT_SUPPORTED";  case CUBLAS_STATUS_LICENSE_ERROR: return 
"CUBLAS_STATUS_LICENSE_ERROR";  } return "unknown error"; } void 
cublas_call_line_file(cublasStatus_t olKGEIcsxmLSoMhRhEtP, const int 
fOpFYwKNwIfWjnPzNuob, const char *UKtMXCCqdjeyaVHabkxg) { if (olKGEIcsxmLSoMhRhEtP != 
CUBLAS_STATUS_SUCCESS) { printf("%s, line: %d, file: %s\n", 
cublasGetErrorString(olKGEIcsxmLSoMhRhEtP), fOpFYwKNwIfWjnPzNuob, UKtMXCCqdjeyaVHabkxg); 
exit(EXIT_FAILURE); } } MWCNNLayerImpl::MWCNNLayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl) : TxNFOfYScyqGlEFFxbAv(0.0), SGsAudmgjmvcUXzzrUtf(1.0), 
SDWKEQTZaTFZByPlzUDR(-1.0), eybNKlJCSDUvsznWynwK(layer), 
gzSTokDHvkXefhiGDcWL(ntwk_impl), REXdEoRjxuQJkqgIDihy(0)  { } float* 
MWCNNLayerImpl::getZeroPtr() { return &TxNFOfYScyqGlEFFxbAv; } float* 
MWCNNLayerImpl::getOnePtr() { return &SGsAudmgjmvcUXzzrUtf; } float* 
MWCNNLayerImpl::getNegOnePtr() { return &SDWKEQTZaTFZByPlzUDR; } 
cudnnTensorDescriptor_t* MWCNNLayerImpl::getOutputDescriptor(int index) { 
std::map<int, cudnnTensorDescriptor_t*>::iterator it = 
lWJYwWaFPmWNQDPrlqER.find(index); if (it == lWJYwWaFPmWNQDPrlqER.end()) { 
cudnnTensorDescriptor_t* tmp = new cudnnTensorDescriptor_t; if (!tmp) { 
printf("%s, line: %d, file: %s\n", 
"Error! Out of memory. Unable to allocate output descriptors. ", __LINE__ , 
__FILE__); exit(EXIT_FAILURE); } lWJYwWaFPmWNQDPrlqER[index] = tmp; return 
tmp; } else { assert(it->second); return it->second; } } bool 
MWCNNLayerImpl::hasOutputDescriptor(int index) const { std::map<int, 
cudnnTensorDescriptor_t*>::const_iterator it = 
lWJYwWaFPmWNQDPrlqER.find(index); return (it != lWJYwWaFPmWNQDPrlqER.end()); 
} cudnnTensorDescriptor_t* MWCNNLayerImpl::getCuDNNDescriptor(MWTensor* tensor) 
{ MWCNNLayerImpl* impl = tensor->getOwner()->getImpl(); if (!impl || 
dynamic_cast<MWPassthroughLayer*>(tensor->getOwner())) { 
assert(dynamic_cast<MWPassthroughLayer*>(tensor->getOwner())); return 
getCuDNNDescriptor(tensor->getOwner()->getInputTensor(0)); } return 
impl->getOutputDescriptor(tensor->getSourcePortIndex()); } 
MWInputLayerImpl::MWInputLayerImpl(MWCNNLayer* layer, int fxxCPKTclxXPxrdMAkwi, int 
YgcpEBUCwCLaPhyntIio, int vIWQzNvYZSuxmOTVDFhU, int OumvfgWXDdmsQaciHMHx, bool wMySyzzledUmSLTWhuYH, 
const char* avg_file_name, MWTargetNetworkImpl* ntwk_impl) : 
MWCNNLayerImpl(layer, ntwk_impl) { createInputLayer(fxxCPKTclxXPxrdMAkwi, YgcpEBUCwCLaPhyntIio, 
vIWQzNvYZSuxmOTVDFhU, OumvfgWXDdmsQaciHMHx, wMySyzzledUmSLTWhuYH, avg_file_name); } 
MWInputLayerImpl::~MWInputLayerImpl() { } void 
MWInputLayerImpl::createInputLayer(int fxxCPKTclxXPxrdMAkwi, int YgcpEBUCwCLaPhyntIio, int 
vIWQzNvYZSuxmOTVDFhU, int OumvfgWXDdmsQaciHMHx, bool wMySyzzledUmSLTWhuYH, const char* 
avg_file_name){ CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*YgcpEBUCwCLaPhyntIio*vIWQzNvYZSuxmOTVDFhU*OumvfgWXDdmsQaciHMHx*fxxCPKTclxXPxrdMAkwi)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
CUDNN_CALL(cudnnCreateTensorDescriptor(&MdSWZSOAjugbWppryHbR)); 
euppfEoiaoCTcVgRPVhA = wMySyzzledUmSLTWhuYH; 
gzSTokDHvkXefhiGDcWL->setWorkSpaceSize(0); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, fxxCPKTclxXPxrdMAkwi, OumvfgWXDdmsQaciHMHx, YgcpEBUCwCLaPhyntIio, 
vIWQzNvYZSuxmOTVDFhU)); if( euppfEoiaoCTcVgRPVhA ) { 
CUDNN_CALL(cudnnSetTensor4dDescriptor(MdSWZSOAjugbWppryHbR, CUDNN_TENSOR_NCHW, 
CUDNN_DATA_FLOAT, 1, OumvfgWXDdmsQaciHMHx, YgcpEBUCwCLaPhyntIio, vIWQzNvYZSuxmOTVDFhU)); 
CUDA_CALL(cudaMalloc((void**)&JwxFdqOKggeawILBfGgg, 
sizeof(float)*OumvfgWXDdmsQaciHMHx*YgcpEBUCwCLaPhyntIio*vIWQzNvYZSuxmOTVDFhU)); int hDaNSVZAofAENeIAiWEw = 
OumvfgWXDdmsQaciHMHx*YgcpEBUCwCLaPhyntIio*vIWQzNvYZSuxmOTVDFhU;  loadAvg(avg_file_name, 
hDaNSVZAofAENeIAiWEw); }
#ifdef RANDOM
 curandGenerateUniform(WprSrhAStKGxyXeoxETy, MW_data, fxxCPKTclxXPxrdMAkwi*OumvfgWXDdmsQaciHMHx*YgcpEBUCwCLaPhyntIio*vIWQzNvYZSuxmOTVDFhU);
#endif
 gzSTokDHvkXefhiGDcWL->setWorkSpaceSize(0); return; } void 
MWInputLayerImpl::loadAvg(const char* UdmcwaUkepxfZrpdpcAN, int hDaNSVZAofAENeIAiWEw) 
{ FILE* WIxRBCJtmETvfxpuRuus = MWCNNLayer::openBinaryFile(UdmcwaUkepxfZrpdpcAN); 
assert(WIxRBCJtmETvfxpuRuus); float* OKaRVOctKLlnIyGmjRNW = 
MALLOC_CALL(sizeof(float)*hDaNSVZAofAENeIAiWEw); fread(OKaRVOctKLlnIyGmjRNW, 
sizeof(float), hDaNSVZAofAENeIAiWEw, WIxRBCJtmETvfxpuRuus); 
CUDA_CALL(cudaMemcpy(JwxFdqOKggeawILBfGgg, OKaRVOctKLlnIyGmjRNW, 
sizeof(float)*hDaNSVZAofAENeIAiWEw, cudaMemcpyHostToDevice)); 
free(OKaRVOctKLlnIyGmjRNW); fclose(WIxRBCJtmETvfxpuRuus); return; } void 
MWInputLayerImpl::predict() { if ( euppfEoiaoCTcVgRPVhA ) 
CUDNN_CALL(cudnnAddTensor(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
getNegOnePtr(), MdSWZSOAjugbWppryHbR, JwxFdqOKggeawILBfGgg, getOnePtr(), 
*getOutputDescriptor(), getData())); return; } void MWInputLayerImpl::cleanup() 
{ if (hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } for(int idx 
= 0; idx < eybNKlJCSDUvsznWynwK->getNumOutputs(); idx++) {  float* data = 
eybNKlJCSDUvsznWynwK->getOutputTensor(idx)->getData(); if (data) { 
call_cuda_free(data); } } if ( euppfEoiaoCTcVgRPVhA ) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(MdSWZSOAjugbWppryHbR)); if (JwxFdqOKggeawILBfGgg) 
{ call_cuda_free(JwxFdqOKggeawILBfGgg); } } return; } 
MWConvLayerImpl::MWConvLayerImpl(MWCNNLayer* layer, int filt_H, int filt_W, int 
numGrps, int numChnls, int numFilts, int IbSWJNMuIiKbocfQKqXb, int 
IwKnaBoXVubIRYcxEJLH, int GeeOVBfQrpMacIFBLKOo, int GFienSVKLlDQuZeqAdLC, int 
GsZlHFuhbvjLtRMDjXnW, int HJHXkKmgFxxIOsIvRRnF, const char* 
vjDFlBZzKvbpPseAtMBP, const char* NldNILHvuQqQPSAHXxdT, MWTargetNetworkImpl* 
ntwk_impl)  : MWCNNLayerImpl(layer, ntwk_impl)  , xkUNToJIgvoLoUQuzKRF(NULL) , 
vIWQzNvYZSuxmOTVDFhU(NULL) , NDjzAZSYJuWymuKDNZYB(NULL) , veFyKKHbdqBIvQLYBqfF(NULL) , 
ZDWLzHUkuZuIUZHfbGDY(NULL) , dJcdBfQQLhIAYHPxwQeg(NULL) , eqOmMKQRpqBqRQCnJmxt(0) , 
AwZQzUhuWVLGrWgLHRuM(filt_H) , AzTsxYcYjIEJsGQbeYHm (filt_W) , 
DSsxcjIrUgZCKZovyNQf (numGrps) , CZNYmBcNFSZWvaCklqeM (numChnls) , 
CpMjJjtGOeWOzwxpAAQP (numFilts) { gzSTokDHvkXefhiGDcWL = ntwk_impl; 
CUDNN_CALL(cudnnCreateConvolutionDescriptor(&QMgBqCuvjnbWHWiVPEwn)); 
CUDNN_CALL(cudnnCreateFilterDescriptor(&VCbcPxtPsBLTrHYdEvqn)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(&NZjOkZPwLzQsdEVkwMcX)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
createConvLayer(IbSWJNMuIiKbocfQKqXb, IwKnaBoXVubIRYcxEJLH, GeeOVBfQrpMacIFBLKOo, 
GFienSVKLlDQuZeqAdLC, GsZlHFuhbvjLtRMDjXnW, HJHXkKmgFxxIOsIvRRnF, 
vjDFlBZzKvbpPseAtMBP, NldNILHvuQqQPSAHXxdT); } 
MWConvLayerImpl::~MWConvLayerImpl() { } float MWConvLayerImpl::getIsGrouped() { 
return eqOmMKQRpqBqRQCnJmxt; } void MWConvLayerImpl::setIsGrouped(float ig) { 
eqOmMKQRpqBqRQCnJmxt = ig; return; } void MWConvLayerImpl::setOutput2(float* 
out2) { xkUNToJIgvoLoUQuzKRF = out2; return; } float* MWConvLayerImpl::getOutput2() { 
return xkUNToJIgvoLoUQuzKRF; } cudnnTensorDescriptor_t* 
MWConvLayerImpl::getGroupDescriptor() { return &XVcMnvCXvZpKICKIjgZi; } void 
MWConvLayerImpl::createConvLayer(int IbSWJNMuIiKbocfQKqXb, int 
IwKnaBoXVubIRYcxEJLH, int GeeOVBfQrpMacIFBLKOo, int GFienSVKLlDQuZeqAdLC , int 
GsZlHFuhbvjLtRMDjXnW, int HJHXkKmgFxxIOsIvRRnF, const char* 
vjDFlBZzKvbpPseAtMBP, const char* NldNILHvuQqQPSAHXxdT) { MWTensor* ipTensor 
= getLayer()->getInputTensor(0); int QVgVGfoCXYiYXzPhvVPX = 
GeeOVBfQrpMacIFBLKOo; int QhTesEEIHwhNmHSeYbRR = 
GsZlHFuhbvjLtRMDjXnW; if ((GeeOVBfQrpMacIFBLKOo != GFienSVKLlDQuZeqAdLC) || 
(GsZlHFuhbvjLtRMDjXnW != HJHXkKmgFxxIOsIvRRnF)) { float* newInput; int inputH 
= ipTensor->getHeight() + GeeOVBfQrpMacIFBLKOo + GFienSVKLlDQuZeqAdLC; int 
inputW = ipTensor->getWidth() + GsZlHFuhbvjLtRMDjXnW + HJHXkKmgFxxIOsIvRRnF; 
CUDA_CALL(cudaMalloc((void**)&newInput, sizeof(float)*ipTensor->getBatchSize() 
* ipTensor->getChannels() * inputH * inputW)); CUDA_CALL(cudaMemset(newInput, 
0, 
sizeof(float)*ipTensor->getBatchSize()*ipTensor->getChannels()*inputH*inputW)); 
ZDWLzHUkuZuIUZHfbGDY = new MWTensor(inputH, inputW, ipTensor->getChannels(), 
ipTensor->getBatchSize(), newInput,getLayer(), 0); 
CUDNN_CALL(cudnnCreateTensorDescriptor(&eFaDPmxDdzHlRYSAoMmX)); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(eFaDPmxDdzHlRYSAoMmX, CUDNN_TENSOR_NCHW, 
CUDNN_DATA_FLOAT, ZDWLzHUkuZuIUZHfbGDY->getBatchSize(), ZDWLzHUkuZuIUZHfbGDY->getChannels(), 
ZDWLzHUkuZuIUZHfbGDY->getHeight(), ZDWLzHUkuZuIUZHfbGDY->getWidth())); 
QVgVGfoCXYiYXzPhvVPX = 0;  QhTesEEIHwhNmHSeYbRR = 0;  } else { 
ZDWLzHUkuZuIUZHfbGDY = ipTensor; eFaDPmxDdzHlRYSAoMmX = 
*getCuDNNDescriptor(ZDWLzHUkuZuIUZHfbGDY);  } fSKMHAqIghbYYgyIpNDw = 
GeeOVBfQrpMacIFBLKOo; fhikqqlnUKCjleVKDqiG = GsZlHFuhbvjLtRMDjXnW;  
assert(ZDWLzHUkuZuIUZHfbGDY != NULL); MWConvLayer* convLayer = static_cast<MWConvLayer*>(getLayer());
#if (CUDNN_MAJOR <= 5)
 { CUDNN_CALL(cudnnSetConvolution2dDescriptor(QMgBqCuvjnbWHWiVPEwn, 
QVgVGfoCXYiYXzPhvVPX, QhTesEEIHwhNmHSeYbRR, IbSWJNMuIiKbocfQKqXb, 
IwKnaBoXVubIRYcxEJLH, 1, 1, CUDNN_CROSS_CORRELATION));  }
#else
 { CUDNN_CALL(cudnnSetConvolution2dDescriptor(QMgBqCuvjnbWHWiVPEwn, 
QVgVGfoCXYiYXzPhvVPX, QhTesEEIHwhNmHSeYbRR, IbSWJNMuIiKbocfQKqXb, 
IwKnaBoXVubIRYcxEJLH, 1, 1, CUDNN_CROSS_CORRELATION, CUDNN_DATA_FLOAT));  }
#endif
 int qWwjVYwfnvEnFKlgpqwA, pckLLTEdVPoCZLRwyDnM; int numInputFeatures = 
CZNYmBcNFSZWvaCklqeM*DSsxcjIrUgZCKZovyNQf; int 
jhFUWlztBndwjbXwYNaJ,puSFZkRJmyuFPfQRswDK,rSmEWccbJFfPGddhPemm; MWTensor* 
opTensor = convLayer->getOutputTensor(0); jhFUWlztBndwjbXwYNaJ = 
opTensor->getChannels(); puSFZkRJmyuFPfQRswDK = opTensor->getHeight(); 
rSmEWccbJFfPGddhPemm = opTensor->getWidth();  size_t sxuOMwKXOKfuExclRaSe = 0; if( 
DSsxcjIrUgZCKZovyNQf == 1 ) { 
CUDNN_CALL(cudnnSetFilter4dDescriptor(VCbcPxtPsBLTrHYdEvqn, CUDNN_DATA_FLOAT, 
CUDNN_TENSOR_NCHW, jhFUWlztBndwjbXwYNaJ, numInputFeatures, 
AwZQzUhuWVLGrWgLHRuM, AzTsxYcYjIEJsGQbeYHm));  
CUDNN_CALL(cudnnSetTensor4dDescriptor(NZjOkZPwLzQsdEVkwMcX, CUDNN_TENSOR_NCHW, 
CUDNN_DATA_FLOAT, 1, jhFUWlztBndwjbXwYNaJ, 1, 1)); 
CUDNN_CALL(cudnnGetConvolution2dForwardOutputDim(QMgBqCuvjnbWHWiVPEwn, 
eFaDPmxDdzHlRYSAoMmX, VCbcPxtPsBLTrHYdEvqn, &qWwjVYwfnvEnFKlgpqwA, 
&pckLLTEdVPoCZLRwyDnM, &puSFZkRJmyuFPfQRswDK, &rSmEWccbJFfPGddhPemm)); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, qWwjVYwfnvEnFKlgpqwA, pckLLTEdVPoCZLRwyDnM, 
opTensor->getHeight(), opTensor->getWidth())); assert(opTensor->getHeight() == 
puSFZkRJmyuFPfQRswDK); assert(opTensor->getWidth() == rSmEWccbJFfPGddhPemm);
#if (CUDNN_MAJOR < 7)
 { 
CUDNN_CALL(cudnnGetConvolutionForwardAlgorithm(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
eFaDPmxDdzHlRYSAoMmX, VCbcPxtPsBLTrHYdEvqn, QMgBqCuvjnbWHWiVPEwn, 
*getOutputDescriptor(), CUDNN_CONVOLUTION_FWD_PREFER_FASTEST, 0, 
&PmFfARVzoHVAYkfpuvqK)); }
#else
 { cudnnConvolutionFwdAlgoPerf_t perf_results[3]; int returnedAlgoCount; 
CUDNN_CALL(cudnnGetConvolutionForwardAlgorithm_v7(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
eFaDPmxDdzHlRYSAoMmX, VCbcPxtPsBLTrHYdEvqn, QMgBqCuvjnbWHWiVPEwn, 
*getOutputDescriptor(), 3, &returnedAlgoCount, perf_results)); 
PmFfARVzoHVAYkfpuvqK = perf_results[0].algo; }
#endif
 
CUDNN_CALL(cudnnGetConvolutionForwardWorkspaceSize(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
eFaDPmxDdzHlRYSAoMmX, VCbcPxtPsBLTrHYdEvqn, QMgBqCuvjnbWHWiVPEwn, 
*getOutputDescriptor(), PmFfARVzoHVAYkfpuvqK, &sxuOMwKXOKfuExclRaSe)); } else { 
setIsGrouped(1); MWTensor* ipTensor = ZDWLzHUkuZuIUZHfbGDY;  dJcdBfQQLhIAYHPxwQeg = 
ipTensor->getData() + ipTensor->getChannels()/DSsxcjIrUgZCKZovyNQf * 
ipTensor->getHeight() * ipTensor->getWidth(); 
CUDNN_CALL(cudnnCreateTensorDescriptor(&enPbWLzEmxYCBmzGJutZ)); 
CUDNN_CALL(cudnnSetTensor4dDescriptorEx(enPbWLzEmxYCBmzGJutZ, 
CUDNN_DATA_FLOAT, ipTensor->getBatchSize(), 
ipTensor->getChannels()/DSsxcjIrUgZCKZovyNQf, ipTensor->getHeight(), 
ipTensor->getWidth(), 
ipTensor->getChannels()*ipTensor->getHeight()*ipTensor->getWidth(), 
ipTensor->getHeight()*ipTensor->getWidth(), ipTensor->getWidth(), 1)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getGroupDescriptor()));  
CUDNN_CALL(cudnnSetFilter4dDescriptor(VCbcPxtPsBLTrHYdEvqn, CUDNN_DATA_FLOAT, 
CUDNN_TENSOR_NCHW, CpMjJjtGOeWOzwxpAAQP, CZNYmBcNFSZWvaCklqeM, 
AwZQzUhuWVLGrWgLHRuM, AzTsxYcYjIEJsGQbeYHm));  
CUDNN_CALL(cudnnGetConvolution2dForwardOutputDim(QMgBqCuvjnbWHWiVPEwn, 
enPbWLzEmxYCBmzGJutZ, VCbcPxtPsBLTrHYdEvqn, &qWwjVYwfnvEnFKlgpqwA, 
&pckLLTEdVPoCZLRwyDnM, &puSFZkRJmyuFPfQRswDK, &rSmEWccbJFfPGddhPemm)); 
assert(opTensor->getHeight() == puSFZkRJmyuFPfQRswDK); assert(opTensor->getWidth() 
== rSmEWccbJFfPGddhPemm); 
CUDNN_CALL(cudnnSetTensor4dDescriptorEx(*getGroupDescriptor(), 
CUDNN_DATA_FLOAT, qWwjVYwfnvEnFKlgpqwA, pckLLTEdVPoCZLRwyDnM, puSFZkRJmyuFPfQRswDK, 
rSmEWccbJFfPGddhPemm, 
pckLLTEdVPoCZLRwyDnM*DSsxcjIrUgZCKZovyNQf*puSFZkRJmyuFPfQRswDK*rSmEWccbJFfPGddhPemm, 
puSFZkRJmyuFPfQRswDK*rSmEWccbJFfPGddhPemm, rSmEWccbJFfPGddhPemm, 1)); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, qWwjVYwfnvEnFKlgpqwA, 
pckLLTEdVPoCZLRwyDnM*DSsxcjIrUgZCKZovyNQf, puSFZkRJmyuFPfQRswDK, rSmEWccbJFfPGddhPemm)); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(NZjOkZPwLzQsdEVkwMcX, CUDNN_TENSOR_NCHW, 
CUDNN_DATA_FLOAT, 1, pckLLTEdVPoCZLRwyDnM*DSsxcjIrUgZCKZovyNQf, 1, 1));
#if (CUDNN_MAJOR < 7) 
 
CUDNN_CALL(cudnnGetConvolutionForwardAlgorithm(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
enPbWLzEmxYCBmzGJutZ, VCbcPxtPsBLTrHYdEvqn, QMgBqCuvjnbWHWiVPEwn, 
*getGroupDescriptor(), CUDNN_CONVOLUTION_FWD_PREFER_FASTEST, 0, &PmFfARVzoHVAYkfpuvqK));
#else
 cudnnConvolutionFwdAlgoPerf_t perf_results[3]; int returnedAlgoCount; 
CUDNN_CALL(cudnnGetConvolutionForwardAlgorithm_v7(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
enPbWLzEmxYCBmzGJutZ, VCbcPxtPsBLTrHYdEvqn, QMgBqCuvjnbWHWiVPEwn, 
*getGroupDescriptor(), 3, &returnedAlgoCount,perf_results)); 
PmFfARVzoHVAYkfpuvqK = perf_results[0].algo;
#endif
 
CUDNN_CALL(cudnnGetConvolutionForwardWorkspaceSize(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
enPbWLzEmxYCBmzGJutZ, VCbcPxtPsBLTrHYdEvqn, QMgBqCuvjnbWHWiVPEwn, 
*getGroupDescriptor(), PmFfARVzoHVAYkfpuvqK, &sxuOMwKXOKfuExclRaSe)); } if( 
sxuOMwKXOKfuExclRaSe > *gzSTokDHvkXefhiGDcWL->getWorkSpaceSize() ) { 
gzSTokDHvkXefhiGDcWL->setWorkSpaceSize(sxuOMwKXOKfuExclRaSe); }  
assert(qWwjVYwfnvEnFKlgpqwA == ipTensor->getBatchSize()); 
assert(jhFUWlztBndwjbXwYNaJ == pckLLTEdVPoCZLRwyDnM * 
DSsxcjIrUgZCKZovyNQf); CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float) * opTensor->getBatchSize() * opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth())); 
CUDA_CALL(cudaMalloc((void**)&vIWQzNvYZSuxmOTVDFhU, 
sizeof(float)*CZNYmBcNFSZWvaCklqeM*jhFUWlztBndwjbXwYNaJ*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm)); 
CUDA_CALL(cudaMalloc((void**)&NDjzAZSYJuWymuKDNZYB, sizeof(float)*jhFUWlztBndwjbXwYNaJ));
#ifdef RANDOM
 curandGenerateNormal(WprSrhAStKGxyXeoxETy, vIWQzNvYZSuxmOTVDFhU, 
CZNYmBcNFSZWvaCklqeM*jhFUWlztBndwjbXwYNaJ*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm, 
0, 0.1); curandGenerateNormal(WprSrhAStKGxyXeoxETy, NDjzAZSYJuWymuKDNZYB, 
jhFUWlztBndwjbXwYNaJ, -0.5, 1);
#endif
 if( DSsxcjIrUgZCKZovyNQf == 2 ) { veFyKKHbdqBIvQLYBqfF = vIWQzNvYZSuxmOTVDFhU + 
CpMjJjtGOeWOzwxpAAQP * CZNYmBcNFSZWvaCklqeM * AwZQzUhuWVLGrWgLHRuM * 
AzTsxYcYjIEJsGQbeYHm; setOutput2(getData() + jhFUWlztBndwjbXwYNaJ/ 2 
* puSFZkRJmyuFPfQRswDK * rSmEWccbJFfPGddhPemm); setIsGrouped(1); } 
loadWeights(vjDFlBZzKvbpPseAtMBP); loadBias(NldNILHvuQqQPSAHXxdT); return; } 
void __global__ padInputImpl(float* in, int inputH, int inputW, int inputCh, 
int outputH, int outputW, int offsetH, int offsetW, float* out, int inputElems) 
{ for(int i = blockDim.x * blockIdx.x + threadIdx.x; i < inputElems; i+= 
blockDim.x*gridDim.x) { int idxB = i/(inputH*inputW*inputCh); int rem = (i - 
idxB*(inputH*inputW*inputCh)); int idxCh = rem/(inputH*inputW); int rem1 = rem 
- idxCh*(inputH*inputW); int idxH = rem1/inputW; int idxCol = rem1 - 
idxH*inputW; if ((idxH < inputH) && (idxCol < inputW)) { int outputR = idxH + 
offsetH; int outputCol = idxCol + offsetW; int outputCh = inputCh; *(out + 
idxB*(outputH*outputW*outputCh) + idxCh*(outputH*outputW) + outputR*(outputW) + 
outputCol) = *(in + i); } } } void MWConvLayerImpl::predict() { MWConvLayer* 
convLayer = static_cast<MWConvLayer*>(getLayer()); if (ZDWLzHUkuZuIUZHfbGDY != 
convLayer->getInputTensor()) { CUDA_CALL(cudaMemset(ZDWLzHUkuZuIUZHfbGDY->getData(), 
0, 
sizeof(float)*ZDWLzHUkuZuIUZHfbGDY->getBatchSize()*ZDWLzHUkuZuIUZHfbGDY->getChannels()*ZDWLzHUkuZuIUZHfbGDY->getHeight()*ZDWLzHUkuZuIUZHfbGDY->getWidth())); 
 int iPqBiFnIJMxelVhQBZex = 
convLayer->getInputTensor()->getHeight()*convLayer->getInputTensor()->getWidth()*convLayer->getInputTensor()->getBatchSize()*convLayer->getInputTensor()->getChannels(); 
int sRECVoNNtDdcBOWgDyar = (iPqBiFnIJMxelVhQBZex < 1024) ? 
iPqBiFnIJMxelVhQBZex : 1024; int NnAKUXChhnRnQmWsknGy = (iPqBiFnIJMxelVhQBZex 
+ sRECVoNNtDdcBOWgDyar - 1)/sRECVoNNtDdcBOWgDyar;  
padInputImpl<<<NnAKUXChhnRnQmWsknGy, 
sRECVoNNtDdcBOWgDyar>>>(convLayer->getInputTensor()->getData(), 
convLayer->getInputTensor()->getHeight(), 
convLayer->getInputTensor()->getWidth(), 
convLayer->getInputTensor()->getChannels(), ZDWLzHUkuZuIUZHfbGDY->getHeight(), 
ZDWLzHUkuZuIUZHfbGDY->getWidth(), fSKMHAqIghbYYgyIpNDw, fhikqqlnUKCjleVKDqiG,  
ZDWLzHUkuZuIUZHfbGDY->getData(), iPqBiFnIJMxelVhQBZex); } if(DSsxcjIrUgZCKZovyNQf == 1 
) { assert(getData() != ZDWLzHUkuZuIUZHfbGDY->getData()); 
CUDNN_CALL(cudnnConvolutionForward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(),getOnePtr(), 
eFaDPmxDdzHlRYSAoMmX, ZDWLzHUkuZuIUZHfbGDY->getData(), VCbcPxtPsBLTrHYdEvqn, 
vIWQzNvYZSuxmOTVDFhU, QMgBqCuvjnbWHWiVPEwn, PmFfARVzoHVAYkfpuvqK, 
gzSTokDHvkXefhiGDcWL->getWorkSpace(), *gzSTokDHvkXefhiGDcWL->getWorkSpaceSize(), 
getZeroPtr(), *getOutputDescriptor(),getData())); 
CUDNN_CALL(cudnnAddTensor(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), getOnePtr(), 
NZjOkZPwLzQsdEVkwMcX, NDjzAZSYJuWymuKDNZYB, getOnePtr(), 
*getOutputDescriptor(),getData())); } else { assert(getData() != 
ZDWLzHUkuZuIUZHfbGDY->getData()); 
CUDNN_CALL(cudnnConvolutionForward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
getOnePtr(), enPbWLzEmxYCBmzGJutZ, ZDWLzHUkuZuIUZHfbGDY->getData(), 
VCbcPxtPsBLTrHYdEvqn, vIWQzNvYZSuxmOTVDFhU, QMgBqCuvjnbWHWiVPEwn, PmFfARVzoHVAYkfpuvqK, 
gzSTokDHvkXefhiGDcWL->getWorkSpace(), *gzSTokDHvkXefhiGDcWL->getWorkSpaceSize(), 
getZeroPtr(), *getGroupDescriptor(), getData())); 
CUDNN_CALL(cudnnConvolutionForward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
getOnePtr(), enPbWLzEmxYCBmzGJutZ, dJcdBfQQLhIAYHPxwQeg, VCbcPxtPsBLTrHYdEvqn, 
veFyKKHbdqBIvQLYBqfF, QMgBqCuvjnbWHWiVPEwn, PmFfARVzoHVAYkfpuvqK, 
gzSTokDHvkXefhiGDcWL->getWorkSpace(), *gzSTokDHvkXefhiGDcWL->getWorkSpaceSize(), 
getZeroPtr(), *getGroupDescriptor(), getOutput2())); 
CUDNN_CALL(cudnnAddTensor(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), getOnePtr(), 
NZjOkZPwLzQsdEVkwMcX, NDjzAZSYJuWymuKDNZYB, getOnePtr(), *getOutputDescriptor(), 
getData())); } } void MWConvLayerImpl::cleanup() { 
CUDNN_CALL(cudnnDestroyConvolutionDescriptor(QMgBqCuvjnbWHWiVPEwn)); 
CUDNN_CALL(cudnnDestroyFilterDescriptor(VCbcPxtPsBLTrHYdEvqn)); if 
(vIWQzNvYZSuxmOTVDFhU) { call_cuda_free(vIWQzNvYZSuxmOTVDFhU); } 
CUDNN_CALL(cudnnDestroyTensorDescriptor(NZjOkZPwLzQsdEVkwMcX)); if 
(NDjzAZSYJuWymuKDNZYB) { call_cuda_free(NDjzAZSYJuWymuKDNZYB); } if (hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } if 
(ZDWLzHUkuZuIUZHfbGDY != getLayer()->getInputTensor(0)) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(eFaDPmxDdzHlRYSAoMmX)); 
call_cuda_free(ZDWLzHUkuZuIUZHfbGDY->getData()); } if (getIsGrouped()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(enPbWLzEmxYCBmzGJutZ));  
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getGroupDescriptor())); } for(int idx 
= 0; idx < getLayer()->getNumOutputs(); idx++) {  float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { call_cuda_free(data); 
} } return; } void MWConvLayerImpl::loadWeights(const char* 
UdmcwaUkepxfZrpdpcAN) { MWConvLayer* convLayer = 
static_cast<MWConvLayer*>(getLayer()); FILE* WIxRBCJtmETvfxpuRuus = 
MWCNNLayer::openBinaryFile(UdmcwaUkepxfZrpdpcAN); assert(WIxRBCJtmETvfxpuRuus); 
assert(CZNYmBcNFSZWvaCklqeM == 
ZDWLzHUkuZuIUZHfbGDY->getChannels()/DSsxcjIrUgZCKZovyNQf); int hDaNSVZAofAENeIAiWEw = 
CZNYmBcNFSZWvaCklqeM*convLayer->getOutputTensor()->getChannels()*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm; 
 float* OKaRVOctKLlnIyGmjRNW = MALLOC_CALL(sizeof(float)*hDaNSVZAofAENeIAiWEw); 
fread(OKaRVOctKLlnIyGmjRNW, sizeof(float), hDaNSVZAofAENeIAiWEw, WIxRBCJtmETvfxpuRuus); if( 
AwZQzUhuWVLGrWgLHRuM != 1 && AzTsxYcYjIEJsGQbeYHm != 1 ) { float* 
ONvcEjLBnVNUdjMKOAwF = 
MALLOC_CALL(sizeof(float)*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm); 
for(int k=0; k<hDaNSVZAofAENeIAiWEw/AwZQzUhuWVLGrWgLHRuM/AzTsxYcYjIEJsGQbeYHm; 
k++) { for(int i=0; i<AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm; i++) 
ONvcEjLBnVNUdjMKOAwF[i]=OKaRVOctKLlnIyGmjRNW[k*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm+i]; 
for(int j=0; j<AwZQzUhuWVLGrWgLHRuM; j++) for(int i=0; 
i<AzTsxYcYjIEJsGQbeYHm; i++) 
OKaRVOctKLlnIyGmjRNW[k*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm+j*AzTsxYcYjIEJsGQbeYHm+i]=ONvcEjLBnVNUdjMKOAwF[j+i*AwZQzUhuWVLGrWgLHRuM]; 
} free(ONvcEjLBnVNUdjMKOAwF); } CUDA_CALL(cudaMemcpy(vIWQzNvYZSuxmOTVDFhU, 
OKaRVOctKLlnIyGmjRNW, sizeof(float)*hDaNSVZAofAENeIAiWEw, cudaMemcpyHostToDevice));
#if 0
 printf("%s loaded. Size = %d. %f\n", UdmcwaUkepxfZrpdpcAN, hDaNSVZAofAENeIAiWEw, OKaRVOctKLlnIyGmjRNW[0]);
#endif
 free(OKaRVOctKLlnIyGmjRNW); fclose(WIxRBCJtmETvfxpuRuus); return; } void 
MWConvLayerImpl::loadBias(const char* UdmcwaUkepxfZrpdpcAN) { MWConvLayer* 
convLayer = static_cast<MWConvLayer*>(getLayer()); FILE* WIxRBCJtmETvfxpuRuus = 
MWCNNLayer::openBinaryFile(UdmcwaUkepxfZrpdpcAN);  assert(WIxRBCJtmETvfxpuRuus); int 
hDaNSVZAofAENeIAiWEw = convLayer->getOutputTensor()->getChannels();  float* 
OKaRVOctKLlnIyGmjRNW = MALLOC_CALL(sizeof(float)*hDaNSVZAofAENeIAiWEw); 
fread(OKaRVOctKLlnIyGmjRNW, sizeof(float), hDaNSVZAofAENeIAiWEw, WIxRBCJtmETvfxpuRuus); 
CUDA_CALL(cudaMemcpy(NDjzAZSYJuWymuKDNZYB, OKaRVOctKLlnIyGmjRNW, 
sizeof(float)*hDaNSVZAofAENeIAiWEw, cudaMemcpyHostToDevice)); 
free(OKaRVOctKLlnIyGmjRNW); fclose(WIxRBCJtmETvfxpuRuus); return; } 
MWReLULayerImpl::MWReLULayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl* 
ntwk_impl, int inPlace)  : MWCNNLayerImpl(layer, ntwk_impl) , 
aLsOwwcceEmRSYzllBNs(inPlace)  { 
CUDNN_CALL(cudnnCreateActivationDescriptor(&npGnQZLrEfVTQnEbwqij)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
createReLULayer(); } MWReLULayerImpl::~MWReLULayerImpl() { } void 
MWReLULayerImpl::createReLULayer() { MWReLULayer* reluLayer = 
static_cast<MWReLULayer*>(getLayer()); MWTensor* ipTensor = 
reluLayer->getInputTensor(0); MWTensor* opTensor = 
reluLayer->getOutputTensor(0); 
CUDNN_CALL(cudnnSetActivationDescriptor(npGnQZLrEfVTQnEbwqij, 
CUDNN_ACTIVATION_RELU, CUDNN_NOT_PROPAGATE_NAN, 0));  
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, opTensor->getBatchSize(), 
opTensor->getChannels(), opTensor->getHeight(), opTensor->getWidth())); if 
(aLsOwwcceEmRSYzllBNs) {  REXdEoRjxuQJkqgIDihy = 
reluLayer->getInputTensor()->getData(); } else { 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*opTensor->getHeight()* 
opTensor->getWidth()*opTensor->getChannels()*opTensor->getBatchSize())); }  } 
void MWReLULayerImpl::predict() { MWReLULayer* reluLayer = 
static_cast<MWReLULayer*>(getLayer()); cudnnTensorDescriptor_t ipDesc = 
*getCuDNNDescriptor(reluLayer->getInputTensor()); 
CUDNN_CALL(cudnnActivationForward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
npGnQZLrEfVTQnEbwqij, getOnePtr(), ipDesc, 
reluLayer->getInputTensor()->getData(), getZeroPtr(), *getOutputDescriptor(), 
REXdEoRjxuQJkqgIDihy)); } void MWReLULayerImpl::cleanup() { 
CUDNN_CALL(cudnnDestroyActivationDescriptor(npGnQZLrEfVTQnEbwqij)); if 
(hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } if 
(!aLsOwwcceEmRSYzllBNs) { MWTensor* op = getLayer()->getOutputTensor(0); float* 
data = op->getData(); if (data) { call_cuda_free(data); } }  } 
MWNormLayerImpl::MWNormLayerImpl(MWCNNLayer* layer, unsigned 
JgLfgHrHMEMmMYTettJF,  double AHqhysOOIgbDpWZoPUFT,  double 
AIXLuRgdeiqpaCehGSYD,  double BRSPqxNffoBYKqpSVHne, MWTargetNetworkImpl* ntwk_impl) : 
MWCNNLayerImpl(layer, ntwk_impl)  { 
CUDNN_CALL(cudnnCreateLRNDescriptor(&gTcJMwtYuwiqqUmqvKhT)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
createNormLayer(JgLfgHrHMEMmMYTettJF, AHqhysOOIgbDpWZoPUFT, 
AIXLuRgdeiqpaCehGSYD, BRSPqxNffoBYKqpSVHne); } MWNormLayerImpl::~MWNormLayerImpl() { } void 
MWNormLayerImpl::createNormLayer( unsigned JgLfgHrHMEMmMYTettJF,  
double AHqhysOOIgbDpWZoPUFT,  double AIXLuRgdeiqpaCehGSYD,  double BRSPqxNffoBYKqpSVHne) { 
MWNormLayer* normLayer = static_cast<MWNormLayer*>(getLayer()); MWTensor* 
ipTensor = normLayer->getInputTensor(0); MWTensor* opTensor = 
normLayer->getOutputTensor(0); int numOutputFeatures = opTensor->getChannels(); 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*opTensor->getHeight()*opTensor->getWidth()*numOutputFeatures*opTensor->getBatchSize())); 
CUDNN_CALL(cudnnSetLRNDescriptor(gTcJMwtYuwiqqUmqvKhT, 
JgLfgHrHMEMmMYTettJF, AHqhysOOIgbDpWZoPUFT, AIXLuRgdeiqpaCehGSYD, 
BRSPqxNffoBYKqpSVHne)); CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, opTensor->getBatchSize(), 
opTensor->getChannels(), opTensor->getHeight(), opTensor->getWidth())); return; 
} void MWNormLayerImpl::predict() { MWNormLayer* normLayer = 
static_cast<MWNormLayer*>(getLayer()); cudnnTensorDescriptor_t ipDesc = 
*getCuDNNDescriptor(normLayer->getInputTensor()); 
CUDNN_CALL(cudnnLRNCrossChannelForward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
gTcJMwtYuwiqqUmqvKhT, CUDNN_LRN_CROSS_CHANNEL_DIM1, getOnePtr(), ipDesc, 
normLayer->getInputTensor()->getData(),getZeroPtr(), *getOutputDescriptor(), 
normLayer->getOutputTensor()->getData())); } void MWNormLayerImpl::cleanup() { 
CUDNN_CALL(cudnnDestroyLRNDescriptor(gTcJMwtYuwiqqUmqvKhT)); if 
(hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } for(int idx 
= 0; idx < getLayer()->getNumOutputs(); idx++) {  MWTensor* op = 
getLayer()->getOutputTensor(idx); float* data = op->getData(); if (data) { 
call_cuda_free(data); } }  } void __global__ MWSetDyForBackPropImpl(float * 
SIBpKtDURUWQaaenbwrC, const int jaqKGCwoANNDMHgAsehk); void __global__ 
doMWMaxPoolingLayerImpl(float * cQBKlCKXxecGPJrXBXdk, float * 
cCXqPFPPcoHzYMDpnUxQ, const int CGbFsczkgkhjcHoCKzBx); 
MWMaxPoolingLayerImpl::MWMaxPoolingLayerImpl(MWCNNLayer* layer, int 
HtQBsWTCGEkpylRklilw,  int IAlDgIFcchbwRGBSfVfA,  int IbSWJNMuIiKbocfQKqXb,  int 
IwKnaBoXVubIRYcxEJLH, int GeeOVBfQrpMacIFBLKOo, int GFienSVKLlDQuZeqAdLC,  int 
GsZlHFuhbvjLtRMDjXnW, int HJHXkKmgFxxIOsIvRRnF, bool KHClOltUSuqFVVErSxVb, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) , 
BLjrjqvCcCommiXWQLjs(KHClOltUSuqFVVErSxVb) , cQBKlCKXxecGPJrXBXdk(0) 
, SIBpKtDURUWQaaenbwrC(0) , cCXqPFPPcoHzYMDpnUxQ(0)  {  
CUDNN_CALL(cudnnCreatePoolingDescriptor(&lteHjcLsItGbVPMQtGDB)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
createMaxPoolingLayer(HtQBsWTCGEkpylRklilw,IAlDgIFcchbwRGBSfVfA,IbSWJNMuIiKbocfQKqXb,IwKnaBoXVubIRYcxEJLH,GeeOVBfQrpMacIFBLKOo,GFienSVKLlDQuZeqAdLC,GsZlHFuhbvjLtRMDjXnW,HJHXkKmgFxxIOsIvRRnF); 
} MWMaxPoolingLayerImpl::~MWMaxPoolingLayerImpl() { } void 
MWMaxPoolingLayerImpl::createMaxPoolingLayer(int HtQBsWTCGEkpylRklilw,  int 
IAlDgIFcchbwRGBSfVfA,  int IbSWJNMuIiKbocfQKqXb, int IwKnaBoXVubIRYcxEJLH, int 
GeeOVBfQrpMacIFBLKOo, int GFienSVKLlDQuZeqAdLC,  int GsZlHFuhbvjLtRMDjXnW, 
int HJHXkKmgFxxIOsIvRRnF) { MWMaxPoolingLayer* maxpoolLayer = 
static_cast<MWMaxPoolingLayer*>(getLayer()); MWTensor* ipTensor = 
maxpoolLayer->getInputTensor(0); int nNULvWnBXnnWdpEkHPAH = 
GeeOVBfQrpMacIFBLKOo; int nlIRrOJaFuVaywxOqOyb = 
GsZlHFuhbvjLtRMDjXnW; cudnnTensorDescriptor_t eFaDPmxDdzHlRYSAoMmX = 
*getCuDNNDescriptor(ipTensor);  
CUDNN_CALL(cudnnSetPooling2dDescriptor(lteHjcLsItGbVPMQtGDB, CUDNN_POOLING_MAX, 
CUDNN_NOT_PROPAGATE_NAN, HtQBsWTCGEkpylRklilw, IAlDgIFcchbwRGBSfVfA, 
nNULvWnBXnnWdpEkHPAH, nlIRrOJaFuVaywxOqOyb, IbSWJNMuIiKbocfQKqXb, 
IwKnaBoXVubIRYcxEJLH)); int fxxCPKTclxXPxrdMAkwi, OumvfgWXDdmsQaciHMHx, YgcpEBUCwCLaPhyntIio, 
vIWQzNvYZSuxmOTVDFhU; CUDNN_CALL(cudnnGetPooling2dForwardOutputDim(lteHjcLsItGbVPMQtGDB, 
eFaDPmxDdzHlRYSAoMmX, &fxxCPKTclxXPxrdMAkwi ,&OumvfgWXDdmsQaciHMHx, &YgcpEBUCwCLaPhyntIio, 
&vIWQzNvYZSuxmOTVDFhU)); YgcpEBUCwCLaPhyntIio = getLayer()->getOutputTensor(0)->getHeight(); 
vIWQzNvYZSuxmOTVDFhU = getLayer()->getOutputTensor(0)->getWidth(); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, fxxCPKTclxXPxrdMAkwi, OumvfgWXDdmsQaciHMHx, YgcpEBUCwCLaPhyntIio, 
vIWQzNvYZSuxmOTVDFhU)); CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*fxxCPKTclxXPxrdMAkwi*OumvfgWXDdmsQaciHMHx*YgcpEBUCwCLaPhyntIio*vIWQzNvYZSuxmOTVDFhU)); if 
(BLjrjqvCcCommiXWQLjs){ 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor(1))); const int 
hljcfGWsvZXJZNrImpJB = 
(ipTensor->getHeight())*(ipTensor->getWidth())*(ipTensor->getChannels())*(ipTensor->getBatchSize()); 
CUDA_CALL(cudaMalloc((void**)&cQBKlCKXxecGPJrXBXdk, 
sizeof(float)*hljcfGWsvZXJZNrImpJB)); 
CUDA_CALL(cudaMalloc((void**)&cCXqPFPPcoHzYMDpnUxQ, 
sizeof(float)*fxxCPKTclxXPxrdMAkwi*OumvfgWXDdmsQaciHMHx*YgcpEBUCwCLaPhyntIio*vIWQzNvYZSuxmOTVDFhU)); 
assert((OumvfgWXDdmsQaciHMHx == ipTensor->getChannels()) && (fxxCPKTclxXPxrdMAkwi == 
ipTensor->getBatchSize()));  const int jaqKGCwoANNDMHgAsehk = 
vIWQzNvYZSuxmOTVDFhU*YgcpEBUCwCLaPhyntIio*OumvfgWXDdmsQaciHMHx*fxxCPKTclxXPxrdMAkwi; 
CUDA_CALL(cudaMalloc((void**)&SIBpKtDURUWQaaenbwrC, 
sizeof(float)*jaqKGCwoANNDMHgAsehk)); int sRECVoNNtDdcBOWgDyar = 
(jaqKGCwoANNDMHgAsehk < 1024) ? jaqKGCwoANNDMHgAsehk : 1024; int 
NnAKUXChhnRnQmWsknGy = (jaqKGCwoANNDMHgAsehk + sRECVoNNtDdcBOWgDyar - 
1)/sRECVoNNtDdcBOWgDyar; 
MWSetDyForBackPropImpl<<<NnAKUXChhnRnQmWsknGy, 
sRECVoNNtDdcBOWgDyar>>>( SIBpKtDURUWQaaenbwrC, jaqKGCwoANNDMHgAsehk); } } void 
MWMaxPoolingLayerImpl::predict() { MWMaxPoolingLayer* maxpoolLayer = 
static_cast<MWMaxPoolingLayer*>(getLayer()); cudnnTensorDescriptor_t 
eFaDPmxDdzHlRYSAoMmX = *getCuDNNDescriptor(maxpoolLayer->getInputTensor()); 
MWTensor* ipTensor = getLayer()->getInputTensor(0); 
CUDNN_CALL(cudnnPoolingForward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
lteHjcLsItGbVPMQtGDB, getOnePtr(), eFaDPmxDdzHlRYSAoMmX, ipTensor->getData(), 
getZeroPtr(), *getOutputDescriptor(), 
maxpoolLayer->getOutputTensor()->getData())); if (BLjrjqvCcCommiXWQLjs) { 
CUDNN_CALL(cudnnPoolingBackward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
lteHjcLsItGbVPMQtGDB, getOnePtr(), *getOutputDescriptor(0), 
getLayer()->getOutputTensor(0)->getData(), *getOutputDescriptor(0), 
SIBpKtDURUWQaaenbwrC, eFaDPmxDdzHlRYSAoMmX, ipTensor->getData(), getZeroPtr(), 
eFaDPmxDdzHlRYSAoMmX, cQBKlCKXxecGPJrXBXdk)); int hljcfGWsvZXJZNrImpJB = 
ipTensor->getHeight()*(ipTensor->getWidth())*(ipTensor->getChannels())*(ipTensor->getBatchSize()); 
int sRECVoNNtDdcBOWgDyar = (hljcfGWsvZXJZNrImpJB < 1024) ? 
hljcfGWsvZXJZNrImpJB : 1024; int NnAKUXChhnRnQmWsknGy = (hljcfGWsvZXJZNrImpJB + 
sRECVoNNtDdcBOWgDyar - 1)/sRECVoNNtDdcBOWgDyar; 
doMWMaxPoolingLayerImpl<<<NnAKUXChhnRnQmWsknGy, 
sRECVoNNtDdcBOWgDyar>>>( cQBKlCKXxecGPJrXBXdk, 
maxpoolLayer->getOutputTensor(1)->getData(), hljcfGWsvZXJZNrImpJB); } return; } 
void MWMaxPoolingLayerImpl::cleanup() { 
CUDNN_CALL(cudnnDestroyPoolingDescriptor(lteHjcLsItGbVPMQtGDB)); if 
(hasOutputDescriptor(0)) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor(0))); } if 
(BLjrjqvCcCommiXWQLjs) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor(1))); } for(int 
idx = 0; idx < getLayer()->getNumOutputs(); idx++) {  float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { call_cuda_free(data); 
} } if (cQBKlCKXxecGPJrXBXdk){ 
call_cuda_free(cQBKlCKXxecGPJrXBXdk); } if (SIBpKtDURUWQaaenbwrC){ 
call_cuda_free(SIBpKtDURUWQaaenbwrC); }  } float* 
MWMaxPoolingLayerImpl::getIndexData()  { return cCXqPFPPcoHzYMDpnUxQ; } void 
__global__ MWSetDyForBackPropImpl(float * SIBpKtDURUWQaaenbwrC, const int 
jaqKGCwoANNDMHgAsehk) { for(int i = blockDim.x * blockIdx.x + threadIdx.x; i < 
jaqKGCwoANNDMHgAsehk; i+= blockDim.x*gridDim.x) { SIBpKtDURUWQaaenbwrC[i] = i+1; } } 
void __global__ doMWMaxPoolingLayerImpl(float * cQBKlCKXxecGPJrXBXdk, 
float * cCXqPFPPcoHzYMDpnUxQ, const int CGbFsczkgkhjcHoCKzBx) { for(int i = 
blockDim.x * blockIdx.x + threadIdx.x; i < CGbFsczkgkhjcHoCKzBx; i+= 
blockDim.x*gridDim.x) { if (static_cast<int>(cQBKlCKXxecGPJrXBXdk[i]) 
!= 0){ 
cCXqPFPPcoHzYMDpnUxQ[static_cast<int>(cQBKlCKXxecGPJrXBXdk[i])-1] = 
i; } } } MWFCLayerImpl::MWFCLayerImpl(MWCNNLayer* layer, const char* 
vjDFlBZzKvbpPseAtMBP,  const char* NldNILHvuQqQPSAHXxdT, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl)  { 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
CUDNN_CALL(cudnnCreateTensorDescriptor(&NZjOkZPwLzQsdEVkwMcX)); 
createFCLayer(vjDFlBZzKvbpPseAtMBP, NldNILHvuQqQPSAHXxdT); } 
MWFCLayerImpl::~MWFCLayerImpl() { } void MWFCLayerImpl::createFCLayer(const 
char* vjDFlBZzKvbpPseAtMBP, const char* NldNILHvuQqQPSAHXxdT) { MWFCLayer* 
fcLayer = static_cast<MWFCLayer*>(getLayer()); 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*fcLayer->getOutputTensor()->getBatchSize()*fcLayer->getOutputTensor()->getChannels())); 
CUDA_CALL(cudaMalloc((void**)&vIWQzNvYZSuxmOTVDFhU, 
sizeof(float)*fcLayer->getInputTensor()->getChannels() 
*fcLayer->getInputTensor()->getWidth()*fcLayer->getInputTensor()->getHeight()*fcLayer->getOutputTensor()->getChannels())); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, 
fcLayer->getOutputTensor()->getBatchSize(),fcLayer->getOutputTensor()->getChannels(), 
1, 1)); CUDNN_CALL(cudnnSetTensor4dDescriptor(NZjOkZPwLzQsdEVkwMcX, 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, 1, 
fcLayer->getOutputTensor()->getChannels(), 1, 1)); 
CUDA_CALL(cudaMalloc((void**)&NDjzAZSYJuWymuKDNZYB, sizeof(float)*fcLayer->getOutputTensor()->getChannels()));
#ifdef RANDOM
 curandGenerateNormal(WprSrhAStKGxyXeoxETy, vIWQzNvYZSuxmOTVDFhU, 
fcLayer->getInputTensor()->getChannels()*fcLayer->getInputTensor()->getWidth()*fcLayer->getInputTensor()->getHeight()*fcLayer->getOutputTensor()->getChannels(), 
0, 0.1); curandGenerateNormal(WprSrhAStKGxyXeoxETy, NDjzAZSYJuWymuKDNZYB, 
fcLayer->getOutputTensor()->getChannels(), -0.5, 1);
#endif
 loadWeights(vjDFlBZzKvbpPseAtMBP); loadBias(NldNILHvuQqQPSAHXxdT); return; 
} void MWFCLayerImpl::loadWeights(const char* UdmcwaUkepxfZrpdpcAN) {  
MWFCLayer* fcLayer = static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(0); MWTensor* opTensor = fcLayer->getOutputTensor(0); 
FILE* WIxRBCJtmETvfxpuRuus = MWCNNLayer::openBinaryFile(UdmcwaUkepxfZrpdpcAN); 
assert(WIxRBCJtmETvfxpuRuus); int hDaNSVZAofAENeIAiWEw = 
ipTensor->getChannels()*ipTensor->getHeight()*ipTensor->getWidth()*opTensor->getChannels(); 
 float* OKaRVOctKLlnIyGmjRNW = MALLOC_CALL(sizeof(float)*hDaNSVZAofAENeIAiWEw); 
fread(OKaRVOctKLlnIyGmjRNW, sizeof(float), hDaNSVZAofAENeIAiWEw, WIxRBCJtmETvfxpuRuus); if( 
ipTensor->getHeight() != 1 && ipTensor->getWidth() != 1 ) { float* 
ONvcEjLBnVNUdjMKOAwF = 
MALLOC_CALL(sizeof(float)*ipTensor->getHeight()*ipTensor->getWidth()); for(int 
k=0; k<hDaNSVZAofAENeIAiWEw/ipTensor->getHeight()/ipTensor->getWidth(); k++) { 
for(int i=0; i<ipTensor->getHeight()*ipTensor->getWidth(); i++) 
ONvcEjLBnVNUdjMKOAwF[i]=OKaRVOctKLlnIyGmjRNW[k*ipTensor->getHeight()*ipTensor->getWidth()+i]; 
for(int j=0; j<ipTensor->getHeight(); j++) for(int i=0; i<ipTensor->getWidth(); 
i++) 
OKaRVOctKLlnIyGmjRNW[k*ipTensor->getHeight()*ipTensor->getWidth()+j*ipTensor->getWidth()+i]=ONvcEjLBnVNUdjMKOAwF[j+i*ipTensor->getHeight()]; 
} free(ONvcEjLBnVNUdjMKOAwF); } CUDA_CALL(cudaMemcpy(vIWQzNvYZSuxmOTVDFhU, 
OKaRVOctKLlnIyGmjRNW, sizeof(float)*hDaNSVZAofAENeIAiWEw, cudaMemcpyHostToDevice));
#if 0
 printf("%s loaded. Size = %d. %f\n", UdmcwaUkepxfZrpdpcAN, hDaNSVZAofAENeIAiWEw, OKaRVOctKLlnIyGmjRNW[0]);
#endif
 free(OKaRVOctKLlnIyGmjRNW); fclose(WIxRBCJtmETvfxpuRuus); return; } void 
MWFCLayerImpl::loadBias(const char* UdmcwaUkepxfZrpdpcAN) { MWFCLayer* fcLayer = 
static_cast<MWFCLayer*>(getLayer()); MWTensor* opTensor = 
fcLayer->getOutputTensor(0); FILE* WIxRBCJtmETvfxpuRuus = 
MWCNNLayer::openBinaryFile(UdmcwaUkepxfZrpdpcAN); assert(WIxRBCJtmETvfxpuRuus); int 
hDaNSVZAofAENeIAiWEw = opTensor->getChannels();  float* OKaRVOctKLlnIyGmjRNW = 
MALLOC_CALL(sizeof(float)*hDaNSVZAofAENeIAiWEw); fread(OKaRVOctKLlnIyGmjRNW, 
sizeof(float), hDaNSVZAofAENeIAiWEw, WIxRBCJtmETvfxpuRuus); 
CUDA_CALL(cudaMemcpy(NDjzAZSYJuWymuKDNZYB, OKaRVOctKLlnIyGmjRNW, 
sizeof(float)*hDaNSVZAofAENeIAiWEw, cudaMemcpyHostToDevice)); 
free(OKaRVOctKLlnIyGmjRNW); fclose(WIxRBCJtmETvfxpuRuus); return; } void 
MWFCLayerImpl::predict() { MWFCLayer* fcLayer = 
static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(0); MWTensor* opTensor = fcLayer->getOutputTensor(0); 
int DqxLTLaJwwgQqmrtCDuu = 
ipTensor->getChannels()*ipTensor->getHeight()*ipTensor->getWidth(); int 
ECTnqgWHyHCHCLBZlffd = opTensor->getChannels(); int bMAyVFGSPDjmUbziYLAy=1; 
int bUVPfnrJhLfHzOLUUrKk=1; if( opTensor->getBatchSize()==1 ) { 
CUDA_CALL(cudaMemcpy(getData(), NDjzAZSYJuWymuKDNZYB, 
sizeof(float)*ECTnqgWHyHCHCLBZlffd, cudaMemcpyDeviceToDevice)); 
CUBLAS_CALL(cublasSgemv(*gzSTokDHvkXefhiGDcWL->getCublasHandle(), CUBLAS_OP_T, 
DqxLTLaJwwgQqmrtCDuu, ECTnqgWHyHCHCLBZlffd, getOnePtr(), 
vIWQzNvYZSuxmOTVDFhU, DqxLTLaJwwgQqmrtCDuu, ipTensor->getData(), 
bMAyVFGSPDjmUbziYLAy, getOnePtr(),getData(), bUVPfnrJhLfHzOLUUrKk)); } else { 
CUBLAS_CALL(cublasSgemm(*gzSTokDHvkXefhiGDcWL->getCublasHandle(), CUBLAS_OP_T, 
CUBLAS_OP_N, ECTnqgWHyHCHCLBZlffd, opTensor->getBatchSize(), 
DqxLTLaJwwgQqmrtCDuu, getOnePtr(), vIWQzNvYZSuxmOTVDFhU, 
DqxLTLaJwwgQqmrtCDuu, ipTensor->getData(), DqxLTLaJwwgQqmrtCDuu, 
getZeroPtr(),getData(), ECTnqgWHyHCHCLBZlffd)); 
CUDNN_CALL(cudnnAddTensor(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), getOnePtr(), 
NZjOkZPwLzQsdEVkwMcX, NDjzAZSYJuWymuKDNZYB, getOnePtr(), 
*getOutputDescriptor(),getData())); } return; } void MWFCLayerImpl::cleanup() { 
if (vIWQzNvYZSuxmOTVDFhU) { call_cuda_free(vIWQzNvYZSuxmOTVDFhU); } if (hasOutputDescriptor(0)) 
{ CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor(0))); } 
CUDNN_CALL(cudnnDestroyTensorDescriptor(NZjOkZPwLzQsdEVkwMcX)); if 
(NDjzAZSYJuWymuKDNZYB) { call_cuda_free(NDjzAZSYJuWymuKDNZYB); } for(int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) {  float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { call_cuda_free(data); 
} } } MWSoftmaxLayerImpl::MWSoftmaxLayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl)  {  
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
createSoftmaxLayer(); } MWSoftmaxLayerImpl::~MWSoftmaxLayerImpl() { } void 
MWSoftmaxLayerImpl::createSoftmaxLayer() { MWSoftmaxLayer* sfmxLayer = 
static_cast<MWSoftmaxLayer*>(getLayer()); MWTensor* ipTensor = 
sfmxLayer->getInputTensor(0); MWTensor* opTensor = 
sfmxLayer->getOutputTensor(0); int numOutputFeatures = ipTensor->getChannels(); 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*ipTensor->getHeight()*ipTensor->getWidth()*numOutputFeatures*ipTensor->getBatchSize())); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, opTensor->getBatchSize(), 
opTensor->getChannels(), opTensor->getHeight(), opTensor->getWidth()));  
return; } void MWSoftmaxLayerImpl::predict() { MWSoftmaxLayer* sfmxLayer = 
static_cast<MWSoftmaxLayer*>(getLayer()); MWTensor* ipTensor = 
sfmxLayer->getInputTensor(0); MWTensor* opTensor = 
sfmxLayer->getOutputTensor(0); cudnnTensorDescriptor_t ipDesc = 
*getCuDNNDescriptor(ipTensor);  
CUDNN_CALL(cudnnSoftmaxForward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
CUDNN_SOFTMAX_ACCURATE, CUDNN_SOFTMAX_MODE_CHANNEL, getOnePtr(), ipDesc, 
ipTensor->getData(), getZeroPtr(), *getOutputDescriptor(), getData())); } void 
MWSoftmaxLayerImpl::cleanup() { if (hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } for(int idx 
= 0; idx < getLayer()->getNumOutputs(); idx++) {  float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { call_cuda_free(data); 
} } } MWAvgPoolingLayerImpl::MWAvgPoolingLayerImpl(MWCNNLayer* layer, int 
HtQBsWTCGEkpylRklilw,  int IAlDgIFcchbwRGBSfVfA,  int IbSWJNMuIiKbocfQKqXb,  int 
IwKnaBoXVubIRYcxEJLH,  int FrpxvsDMwwgbpqHXWxmN,  int GnxRkpzrPZimKtYYHSuG, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl)  { 
CUDNN_CALL(cudnnCreatePoolingDescriptor(&lteHjcLsItGbVPMQtGDB)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
createAvgPoolingLayer(HtQBsWTCGEkpylRklilw, IAlDgIFcchbwRGBSfVfA, IbSWJNMuIiKbocfQKqXb, 
IwKnaBoXVubIRYcxEJLH, FrpxvsDMwwgbpqHXWxmN, GnxRkpzrPZimKtYYHSuG); } 
MWAvgPoolingLayerImpl::~MWAvgPoolingLayerImpl() { } void 
MWAvgPoolingLayerImpl::createAvgPoolingLayer(int HtQBsWTCGEkpylRklilw, int 
IAlDgIFcchbwRGBSfVfA, int IbSWJNMuIiKbocfQKqXb, int IwKnaBoXVubIRYcxEJLH, int 
FrpxvsDMwwgbpqHXWxmN, int GnxRkpzrPZimKtYYHSuG) { MWAvgPoolingLayer* avgpoolLayer 
= static_cast<MWAvgPoolingLayer*>(getLayer()); MWTensor* ipTensor = 
avgpoolLayer->getInputTensor(0); 
CUDNN_CALL(cudnnSetPooling2dDescriptor(lteHjcLsItGbVPMQtGDB, 
CUDNN_POOLING_AVERAGE_COUNT_INCLUDE_PADDING, CUDNN_NOT_PROPAGATE_NAN, 
HtQBsWTCGEkpylRklilw, IAlDgIFcchbwRGBSfVfA, FrpxvsDMwwgbpqHXWxmN, GnxRkpzrPZimKtYYHSuG, 
IbSWJNMuIiKbocfQKqXb, IwKnaBoXVubIRYcxEJLH)); int fxxCPKTclxXPxrdMAkwi, OumvfgWXDdmsQaciHMHx, 
YgcpEBUCwCLaPhyntIio, vIWQzNvYZSuxmOTVDFhU;  cudnnTensorDescriptor_t eFaDPmxDdzHlRYSAoMmX = 
*getCuDNNDescriptor(ipTensor); 
CUDNN_CALL(cudnnGetPooling2dForwardOutputDim(lteHjcLsItGbVPMQtGDB, 
eFaDPmxDdzHlRYSAoMmX, &fxxCPKTclxXPxrdMAkwi ,&OumvfgWXDdmsQaciHMHx, &YgcpEBUCwCLaPhyntIio, 
&vIWQzNvYZSuxmOTVDFhU)); CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, fxxCPKTclxXPxrdMAkwi, OumvfgWXDdmsQaciHMHx, YgcpEBUCwCLaPhyntIio, 
vIWQzNvYZSuxmOTVDFhU)); CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, 
sizeof(float)*fxxCPKTclxXPxrdMAkwi*OumvfgWXDdmsQaciHMHx*YgcpEBUCwCLaPhyntIio*vIWQzNvYZSuxmOTVDFhU)); } void 
MWAvgPoolingLayerImpl::predict() { MWAvgPoolingLayer* avgpoolLayer = 
static_cast<MWAvgPoolingLayer*>(getLayer()); MWTensor* ipTensor = 
avgpoolLayer->getInputTensor(0); MWTensor* opTensor = 
avgpoolLayer->getOutputTensor(0); cudnnTensorDescriptor_t eFaDPmxDdzHlRYSAoMmX = 
*getCuDNNDescriptor(ipTensor); 
CUDNN_CALL(cudnnPoolingForward(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
lteHjcLsItGbVPMQtGDB, getOnePtr(), eFaDPmxDdzHlRYSAoMmX, ipTensor->getData(), 
getZeroPtr(), *getOutputDescriptor(),opTensor->getData())); } void 
MWAvgPoolingLayerImpl::cleanup() { 
CUDNN_CALL(cudnnDestroyPoolingDescriptor(lteHjcLsItGbVPMQtGDB)); if 
(hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); }  for(int 
idx = 0; idx < getLayer()->getNumOutputs(); idx++) {  float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { call_cuda_free(data); 
} } } MWOutputLayerImpl::MWOutputLayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
createOutputLayer(); } MWOutputLayerImpl::~MWOutputLayerImpl() { } void 
MWOutputLayerImpl::createOutputLayer() { MWOutputLayer* opLayer = 
static_cast<MWOutputLayer*>(getLayer()); MWTensor* ipTensor = 
opLayer->getInputTensor(0); setData(ipTensor->getData()); return; } void 
MWOutputLayerImpl::predict() { } void MWOutputLayerImpl::cleanup() { }