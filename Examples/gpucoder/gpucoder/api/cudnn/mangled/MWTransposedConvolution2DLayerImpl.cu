#include <stdio.h>
#include "cnn_api.hpp"
#include "MWTransposedConvolution2DLayer.hpp"
#include "MWCNNLayerImpl.hpp"
#include "MWTransposedConvolution2DLayerImpl.hpp"
#include <cassert>
 
MWTransposedConvolution2DLayerImpl::MWTransposedConvolution2DLayerImpl(MWCNNLayer* 
layer, int filt_H, int filt_W, int numIpFeatures, int numFilts, int 
IbSWJNMuIiKbocfQKqXb, int IwKnaBoXVubIRYcxEJLH, int FrpxvsDMwwgbpqHXWxmN, int 
GnxRkpzrPZimKtYYHSuG,  const char* vjDFlBZzKvbpPseAtMBP, const char* 
NldNILHvuQqQPSAHXxdT, MWTargetNetworkImpl* ntwk_impl)  : MWCNNLayerImpl(layer, 
ntwk_impl)  , vIWQzNvYZSuxmOTVDFhU(NULL) , NDjzAZSYJuWymuKDNZYB(NULL) , 
AwZQzUhuWVLGrWgLHRuM(filt_H) , AzTsxYcYjIEJsGQbeYHm(filt_W) , 
DqxLTLaJwwgQqmrtCDuu(numIpFeatures) , CpMjJjtGOeWOzwxpAAQP(numFilts) { 
gzSTokDHvkXefhiGDcWL = ntwk_impl; 
CUDNN_CALL(cudnnCreateConvolutionDescriptor(&RqCYCrGsNvzKYrRMXbsI)); 
CUDNN_CALL(cudnnCreateFilterDescriptor(&VCbcPxtPsBLTrHYdEvqn)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(&NZjOkZPwLzQsdEVkwMcX)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
createTransposedConv2DLayer(IbSWJNMuIiKbocfQKqXb, IwKnaBoXVubIRYcxEJLH, 
FrpxvsDMwwgbpqHXWxmN, GnxRkpzrPZimKtYYHSuG, vjDFlBZzKvbpPseAtMBP, 
NldNILHvuQqQPSAHXxdT); } 
MWTransposedConvolution2DLayerImpl::~MWTransposedConvolution2DLayerImpl() { } 
void MWTransposedConvolution2DLayerImpl::createTransposedConv2DLayer(int 
IbSWJNMuIiKbocfQKqXb, int IwKnaBoXVubIRYcxEJLH, int FrpxvsDMwwgbpqHXWxmN, int 
GnxRkpzrPZimKtYYHSuG, const char* vjDFlBZzKvbpPseAtMBP, const char* 
NldNILHvuQqQPSAHXxdT) { MWTransposedConvolution2DLayer* convLayer = static_cast<MWTransposedConvolution2DLayer*>(getLayer());
#if (CUDNN_MAJOR <= 5)
 { CUDNN_CALL(cudnnSetConvolution2dDescriptor(RqCYCrGsNvzKYrRMXbsI, 
FrpxvsDMwwgbpqHXWxmN, GnxRkpzrPZimKtYYHSuG, IbSWJNMuIiKbocfQKqXb, 
IwKnaBoXVubIRYcxEJLH, 1, 1, CUDNN_CROSS_CORRELATION));  }
#else
 { CUDNN_CALL(cudnnSetConvolution2dDescriptor(RqCYCrGsNvzKYrRMXbsI, 
FrpxvsDMwwgbpqHXWxmN, GnxRkpzrPZimKtYYHSuG, IbSWJNMuIiKbocfQKqXb, 
IwKnaBoXVubIRYcxEJLH, 1, 1, CUDNN_CROSS_CORRELATION, CUDNN_DATA_FLOAT));  }
#endif
 int numOutFeatures_fwdConv = DqxLTLaJwwgQqmrtCDuu;  int 
numInFeatures_fwdConv = CpMjJjtGOeWOzwxpAAQP;  
CUDNN_CALL(cudnnSetFilter4dDescriptor(VCbcPxtPsBLTrHYdEvqn, CUDNN_DATA_FLOAT, 
CUDNN_TENSOR_NCHW, numOutFeatures_fwdConv, numInFeatures_fwdConv, 
AwZQzUhuWVLGrWgLHRuM, AzTsxYcYjIEJsGQbeYHm));  MWTensor* ipTensor = 
convLayer->getInputTensor(0); MWTensor* opTensor = 
convLayer->getOutputTensor(0); int puSFZkRJmyuFPfQRswDK = opTensor->getHeight(); 
int rSmEWccbJFfPGddhPemm = opTensor->getWidth(); cudnnTensorDescriptor_t 
eFaDPmxDdzHlRYSAoMmX = *getCuDNNDescriptor(ipTensor); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, opTensor->getBatchSize(), 
opTensor->getChannels(), puSFZkRJmyuFPfQRswDK, rSmEWccbJFfPGddhPemm)); 
CUDNN_CALL(cudnnGetConvolutionBackwardDataAlgorithm(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
VCbcPxtPsBLTrHYdEvqn,*getCuDNNDescriptor(ipTensor), RqCYCrGsNvzKYrRMXbsI, 
*getOutputDescriptor(), CUDNN_CONVOLUTION_BWD_DATA_PREFER_FASTEST, 0, 
&PtkeOkuClHzhOfpmBevf)); size_t ugnnrhsgTeWucrMPCJUc = 0; 
CUDNN_CALL(cudnnGetConvolutionBackwardDataWorkspaceSize(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
VCbcPxtPsBLTrHYdEvqn,*getCuDNNDescriptor(ipTensor), RqCYCrGsNvzKYrRMXbsI, 
*getOutputDescriptor(), PtkeOkuClHzhOfpmBevf, &ugnnrhsgTeWucrMPCJUc)); 
if( ugnnrhsgTeWucrMPCJUc > *gzSTokDHvkXefhiGDcWL->getWorkSpaceSize()) { 
gzSTokDHvkXefhiGDcWL->setWorkSpaceSize(ugnnrhsgTeWucrMPCJUc); } 
CUDA_CALL(cudaMalloc((void**)&vIWQzNvYZSuxmOTVDFhU, 
sizeof(float)*DqxLTLaJwwgQqmrtCDuu*opTensor->getChannels()*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm)); 
CUDNN_CALL(cudnnSetTensor4dDescriptor(NZjOkZPwLzQsdEVkwMcX, CUDNN_TENSOR_NCHW, 
CUDNN_DATA_FLOAT, 1, opTensor->getChannels(), 1, 1)); 
CUDA_CALL(cudaMalloc((void**)&NDjzAZSYJuWymuKDNZYB, 
sizeof(float)*opTensor->getChannels())); 
CUDA_CALL(cudaMalloc((void**)&REXdEoRjxuQJkqgIDihy, sizeof(float) * 
opTensor->getBatchSize() * opTensor->getChannels() * opTensor->getHeight() * 
opTensor->getWidth())); loadWeights(vjDFlBZzKvbpPseAtMBP); 
loadBias(NldNILHvuQqQPSAHXxdT); return; } void 
MWTransposedConvolution2DLayerImpl::predict() { MWTransposedConvolution2DLayer* 
convLayer = static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* 
ipTensor = convLayer->getInputTensor(0); MWTensor* opTensor = 
convLayer->getOutputTensor(0); 
CUDNN_CALL(cudnnConvolutionBackwardData(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), 
getOnePtr(), VCbcPxtPsBLTrHYdEvqn, vIWQzNvYZSuxmOTVDFhU,  
*getCuDNNDescriptor(ipTensor), ipTensor->getData(), RqCYCrGsNvzKYrRMXbsI,  
PtkeOkuClHzhOfpmBevf, gzSTokDHvkXefhiGDcWL->getWorkSpace(),  
*gzSTokDHvkXefhiGDcWL->getWorkSpaceSize(), getZeroPtr(),  
*getOutputDescriptor(), opTensor->getData())); 
CUDNN_CALL(cudnnAddTensor(*gzSTokDHvkXefhiGDcWL->getCudnnHandle(), getOnePtr(),  
NZjOkZPwLzQsdEVkwMcX, NDjzAZSYJuWymuKDNZYB, getOnePtr(), 
*getOutputDescriptor(),opTensor->getData())); } void 
MWTransposedConvolution2DLayerImpl::cleanup(){ 
CUDNN_CALL(cudnnDestroyConvolutionDescriptor(RqCYCrGsNvzKYrRMXbsI)); 
CUDNN_CALL(cudnnDestroyFilterDescriptor(VCbcPxtPsBLTrHYdEvqn)); if 
(vIWQzNvYZSuxmOTVDFhU) { call_cuda_free(vIWQzNvYZSuxmOTVDFhU); } 
CUDNN_CALL(cudnnDestroyTensorDescriptor(NZjOkZPwLzQsdEVkwMcX)); if 
(NDjzAZSYJuWymuKDNZYB) { call_cuda_free(NDjzAZSYJuWymuKDNZYB); } if (hasOutputDescriptor()) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); } if 
(getData()) { call_cuda_free(getData()); } } void 
MWTransposedConvolution2DLayerImpl::loadWeights(const char* 
UdmcwaUkepxfZrpdpcAN) { MWTransposedConvolution2DLayer* convLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* opTensor = 
convLayer->getOutputTensor(0); FILE* WIxRBCJtmETvfxpuRuus = 
MWCNNLayer::openBinaryFile(UdmcwaUkepxfZrpdpcAN); assert(WIxRBCJtmETvfxpuRuus); int 
hDaNSVZAofAENeIAiWEw = 
DqxLTLaJwwgQqmrtCDuu*opTensor->getChannels()*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm; 
 float* OKaRVOctKLlnIyGmjRNW = (float*)malloc(sizeof(float)*hDaNSVZAofAENeIAiWEw); 
fread(OKaRVOctKLlnIyGmjRNW, sizeof(float), hDaNSVZAofAENeIAiWEw, WIxRBCJtmETvfxpuRuus); if( 
AwZQzUhuWVLGrWgLHRuM != 1 && AzTsxYcYjIEJsGQbeYHm != 1 ) { float* 
ONvcEjLBnVNUdjMKOAwF = 
(float*)malloc(sizeof(float)*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm); 
for(int k=0; k<hDaNSVZAofAENeIAiWEw/AwZQzUhuWVLGrWgLHRuM/AzTsxYcYjIEJsGQbeYHm; 
k++) { for(int i=0; i<AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm; i++) 
ONvcEjLBnVNUdjMKOAwF[i]=OKaRVOctKLlnIyGmjRNW[k*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm+i]; 
for(int j=0; j<AwZQzUhuWVLGrWgLHRuM; j++) for(int i=0; 
i<AzTsxYcYjIEJsGQbeYHm; i++) 
OKaRVOctKLlnIyGmjRNW[k*AwZQzUhuWVLGrWgLHRuM*AzTsxYcYjIEJsGQbeYHm+j*AzTsxYcYjIEJsGQbeYHm+i]=ONvcEjLBnVNUdjMKOAwF[j+i*AwZQzUhuWVLGrWgLHRuM]; 
} free(ONvcEjLBnVNUdjMKOAwF); } CUDA_CALL(cudaMemcpy(vIWQzNvYZSuxmOTVDFhU, 
OKaRVOctKLlnIyGmjRNW, sizeof(float)*hDaNSVZAofAENeIAiWEw, cudaMemcpyHostToDevice)); 
printf("%s loaded. Size = %d. %f\n", UdmcwaUkepxfZrpdpcAN, hDaNSVZAofAENeIAiWEw, 
OKaRVOctKLlnIyGmjRNW[0]); free(OKaRVOctKLlnIyGmjRNW); fclose(WIxRBCJtmETvfxpuRuus); return; 
} void MWTransposedConvolution2DLayerImpl::loadBias(const char* 
UdmcwaUkepxfZrpdpcAN) { MWTransposedConvolution2DLayer* convLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* opTensor = 
convLayer->getOutputTensor(0); FILE* WIxRBCJtmETvfxpuRuus = 
MWCNNLayer::openBinaryFile(UdmcwaUkepxfZrpdpcAN); assert(WIxRBCJtmETvfxpuRuus); int 
hDaNSVZAofAENeIAiWEw = opTensor->getChannels();  float* OKaRVOctKLlnIyGmjRNW = 
(float*)malloc(sizeof(float)*hDaNSVZAofAENeIAiWEw); fread(OKaRVOctKLlnIyGmjRNW, 
sizeof(float), hDaNSVZAofAENeIAiWEw, WIxRBCJtmETvfxpuRuus); 
CUDA_CALL(cudaMemcpy(NDjzAZSYJuWymuKDNZYB, OKaRVOctKLlnIyGmjRNW, 
sizeof(float)*hDaNSVZAofAENeIAiWEw, cudaMemcpyHostToDevice)); 
free(OKaRVOctKLlnIyGmjRNW); fclose(WIxRBCJtmETvfxpuRuus); return; }