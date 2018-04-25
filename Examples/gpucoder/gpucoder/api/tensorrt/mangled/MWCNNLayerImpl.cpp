#include <cstdlib>
#include <cassert>
#include <stdio.h>
#include <cassert>
#include <iostream>
#include "MWCNNLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"
#ifdef RANDOM
#include <curand.h>
 curandGenerator_t ncMionCCOTOYjWcmaIVD; void 
curand_call_line_file(curandStatus_t uznbYLhhKtdvhPWaHJnR, const int 
qBTcAwVGZERyCjGYByPe, const char* kMyEnepVyoNObTPqIpWo) { if (uznbYLhhKtdvhPWaHJnR != 
CURAND_STATUS_SUCCESS) { printf("%d, line: %d, file: %s\n", uznbYLhhKtdvhPWaHJnR, 
qBTcAwVGZERyCjGYByPe, kMyEnepVyoNObTPqIpWo); exit(EXIT_FAILURE); } }
#endif
 void call_cuda_free(float* mem) { cudaError_t uznbYLhhKtdvhPWaHJnR = 
cudaFree(mem); if (uznbYLhhKtdvhPWaHJnR != cudaErrorCudartUnloading) { 
CUDA_CALL(uznbYLhhKtdvhPWaHJnR); } } void cuda_call_line_file(cudaError_t 
uznbYLhhKtdvhPWaHJnR, const int qBTcAwVGZERyCjGYByPe, const char* kMyEnepVyoNObTPqIpWo) { if 
(uznbYLhhKtdvhPWaHJnR != cudaSuccess) { printf("%s, line: %d, file: %s\n", 
cudaGetErrorString(uznbYLhhKtdvhPWaHJnR), qBTcAwVGZERyCjGYByPe, kMyEnepVyoNObTPqIpWo); 
exit(EXIT_FAILURE); } } void cudnn_call_line_file(cudnnStatus_t 
uznbYLhhKtdvhPWaHJnR, const int qBTcAwVGZERyCjGYByPe, const char* kMyEnepVyoNObTPqIpWo) { if 
(uznbYLhhKtdvhPWaHJnR != CUDNN_STATUS_SUCCESS) { 
printf("%s, line: %d, file: %s\n", cudnnGetErrorString(uznbYLhhKtdvhPWaHJnR), 
qBTcAwVGZERyCjGYByPe, kMyEnepVyoNObTPqIpWo); exit(EXIT_FAILURE); } } ITensor* 
MWCNNLayerImpl::getprevLayerTensor(MWTensor* ipTensor) { ITensor* 
prevLayerTensor; if (ipTensor->getOwner()->getImpl() == NULL) { prevLayerTensor 
= 
ipTensor->getOwner()->getInputTensor()->getOwner()->getImpl()->getOpTensorPtr(); 
} else { prevLayerTensor = ipTensor->getOwner()->getImpl()->getOpTensorPtr(); } 
} void MWCNNLayerImpl::predict() { return; } void MWCNNLayerImpl::cleanup() { 
return; } void MWCNNLayerImpl::setOpTensorPtr(ITensor* outputTensor) { 
KZWeXiYFmdpQdsgidKeG = outputTensor; } ITensor* MWCNNLayerImpl::getOpTensorPtr() 
{ return KZWeXiYFmdpQdsgidKeG; } MWCNNLayerImpl::MWCNNLayerImpl(MWCNNLayer* 
layer, MWTargetNetworkImpl* ntwk_impl) : pdleXafalaHAmketaFyq(layer) , 
rIcMzXptfYweLArNRnBw(ntwk_impl) , jfkhqXBmwICFStMidrQt(0.0) , jHzoRQWaHafftmrmuvHO(1.0) , 
jHaoHEqZgMiwRsdCogKz(-1.0) , iMyHYqdPsEjdhQptHQNt(0) { } float* 
MWCNNLayerImpl::getZeroPtr() { return &jfkhqXBmwICFStMidrQt; } float* 
MWCNNLayerImpl::getOnePtr() { return &jHzoRQWaHafftmrmuvHO; } float* 
MWCNNLayerImpl::getNegOnePtr() { return &jHaoHEqZgMiwRsdCogKz; } 
cudnnTensorDescriptor_t* MWCNNLayerImpl::getOutputDescriptor(int index) { 
std::map<int, cudnnTensorDescriptor_t*>::iterator it = 
rrWNoFNRUEdlTvIOmCla.find(index); if (it == rrWNoFNRUEdlTvIOmCla.end()) { 
cudnnTensorDescriptor_t* tmp = new cudnnTensorDescriptor_t; 
rrWNoFNRUEdlTvIOmCla[index] = tmp; return tmp; } else { return it->second; } } 
cudnnTensorDescriptor_t* MWCNNLayerImpl::getCuDNNDescriptor(MWTensor* tensor) { 
return 
tensor->getOwner()->getImpl()->getOutputDescriptor(tensor->getSourcePortIndex()); 
} MWInputLayerImpl::MWInputLayerImpl(MWCNNLayer* layer, int qEXwbWWsnOADJeTXfRVa, int 
oRMQjdFKfeFQQeMVxdmM, int wqggPBXZvtlxnxwngvAq, int iADjqLChtuDbEWfMYFLp, bool xcusoQxPPodcHwVviCWI, 
const char* avg_file_name, MWTargetNetworkImpl* ntwk_impl) : 
MWCNNLayerImpl(layer, ntwk_impl) { createInputLayer(qEXwbWWsnOADJeTXfRVa, oRMQjdFKfeFQQeMVxdmM, 
wqggPBXZvtlxnxwngvAq, iADjqLChtuDbEWfMYFLp, xcusoQxPPodcHwVviCWI, avg_file_name); } 
MWInputLayerImpl::~MWInputLayerImpl() { } void 
MWInputLayerImpl::createInputLayer(int qEXwbWWsnOADJeTXfRVa, int oRMQjdFKfeFQQeMVxdmM, int 
wqggPBXZvtlxnxwngvAq, int iADjqLChtuDbEWfMYFLp, bool xcusoQxPPodcHwVviCWI, const char* 
avg_file_name) { CUDA_CALL(cudaMalloc((void**)&iMyHYqdPsEjdhQptHQNt, sizeof(float) * 
oRMQjdFKfeFQQeMVxdmM * wqggPBXZvtlxnxwngvAq * iADjqLChtuDbEWfMYFLp * qEXwbWWsnOADJeTXfRVa)); 
CUDNN_CALL(cudnnCreateTensorDescriptor(getOutputDescriptor())); 
CUDNN_CALL(cudnnCreateTensorDescriptor(&cwCXkgHfZmFQRzNVUlCO)); 
pbePKOGQbvmzToFbiRkR = xcusoQxPPodcHwVviCWI; 
CUDNN_CALL(cudnnSetTensor4dDescriptor(*getOutputDescriptor(), 
CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, qEXwbWWsnOADJeTXfRVa, iADjqLChtuDbEWfMYFLp, oRMQjdFKfeFQQeMVxdmM, 
wqggPBXZvtlxnxwngvAq)); if (pbePKOGQbvmzToFbiRkR) { 
CUDNN_CALL(cudnnSetTensor4dDescriptor(cwCXkgHfZmFQRzNVUlCO, CUDNN_TENSOR_NCHW, 
CUDNN_DATA_FLOAT, 1, iADjqLChtuDbEWfMYFLp, oRMQjdFKfeFQQeMVxdmM, wqggPBXZvtlxnxwngvAq)); 
CUDA_CALL(cudaMalloc((void**)&bLhHPDtQpqOAnMiVledO, sizeof(float) * iADjqLChtuDbEWfMYFLp * 
oRMQjdFKfeFQQeMVxdmM * wqggPBXZvtlxnxwngvAq)); int rlQsibXJSWJVnUVpdNeL = iADjqLChtuDbEWfMYFLp * oRMQjdFKfeFQQeMVxdmM 
* wqggPBXZvtlxnxwngvAq;  loadAvg(avg_file_name, rlQsibXJSWJVnUVpdNeL); }
#ifdef RANDOM
 curandGenerateUniform(ncMionCCOTOYjWcmaIVD, MW_data, qEXwbWWsnOADJeTXfRVa * 
iADjqLChtuDbEWfMYFLp * oRMQjdFKfeFQQeMVxdmM * wqggPBXZvtlxnxwngvAq);
#endif
 rIcMzXptfYweLArNRnBw->batchSize = qEXwbWWsnOADJeTXfRVa; InputLayerITensor = 
rIcMzXptfYweLArNRnBw->network->addInput( "data", DataType::kFLOAT, 
DimsCHW{iADjqLChtuDbEWfMYFLp, wqggPBXZvtlxnxwngvAq, oRMQjdFKfeFQQeMVxdmM}); 
setOpTensorPtr(InputLayerITensor); return; } void 
MWInputLayerImpl::loadAvg(const char* leWFtIPrKkXLixGWBGJW, int rlQsibXJSWJVnUVpdNeL) 
{ FILE* nDsbARncmIrIaLubvLVZ = MWCNNLayer::openBinaryFile(leWFtIPrKkXLixGWBGJW); 
assert(nDsbARncmIrIaLubvLVZ); float* gcGbhKACQPAogUYXHedj = (float*)malloc(sizeof(float) 
* rlQsibXJSWJVnUVpdNeL); fread(gcGbhKACQPAogUYXHedj, sizeof(float), rlQsibXJSWJVnUVpdNeL, 
nDsbARncmIrIaLubvLVZ); CUDA_CALL(cudaMemcpy(bLhHPDtQpqOAnMiVledO, gcGbhKACQPAogUYXHedj, 
sizeof(float) * rlQsibXJSWJVnUVpdNeL, cudaMemcpyHostToDevice)); 
free(gcGbhKACQPAogUYXHedj); fclose(nDsbARncmIrIaLubvLVZ); return; } void 
MWInputLayerImpl::predict() { if (pbePKOGQbvmzToFbiRkR) { 
CUDNN_CALL(cudnnAddTensor(*rIcMzXptfYweLArNRnBw->getCudnnHandle(), 
getNegOnePtr(), cwCXkgHfZmFQRzNVUlCO, bLhHPDtQpqOAnMiVledO, getOnePtr(), 
*getOutputDescriptor(), getData())); } return; } void 
MWInputLayerImpl::cleanup() { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(*getOutputDescriptor())); for (int idx 
= 0; idx < pdleXafalaHAmketaFyq->getNumOutputs(); idx++) { float* data = 
pdleXafalaHAmketaFyq->getOutputTensor(idx)->getData(); if (data) { 
call_cuda_free(data); } } if (pbePKOGQbvmzToFbiRkR) { 
CUDNN_CALL(cudnnDestroyTensorDescriptor(cwCXkgHfZmFQRzNVUlCO)); if (bLhHPDtQpqOAnMiVledO) 
{ call_cuda_free(bLhHPDtQpqOAnMiVledO); } } return; } 
MWConvLayerImpl::MWConvLayerImpl(MWCNNLayer* layer, int filt_H, int filt_W, int 
numGrps, int numChnls, int numFilts, int YFrWUSnoOKzYyZzANuxg, int 
ZUTPCvgISoRdtnhGqXzM, int QTXuPiGKeBUnmRzhlIDp, int NDHPlSVpLroiIBRnjwyO, int 
NbunkIVaMPVYgAQHXXYd, int QMNXyOvXaZDsCpiIJPsn, const char* 
xHiBGayUfxIpXKkCTDNU, const char* gNROjwaqhxDPvBWUCUcQ, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) , GbdgxISzcqHOpzQEBrvP(filt_H) 
, JABfZsGuaCAmcRcqOYEO(filt_W) , JxwPQNPACGfmGpNncpCY(numGrps) , 
wqggPBXZvtlxnxwngvAq(NULL) , eUSuiwvLvXVXrpUkgBVu(NULL) { createConvLayer(YFrWUSnoOKzYyZzANuxg, 
ZUTPCvgISoRdtnhGqXzM, QTXuPiGKeBUnmRzhlIDp, NDHPlSVpLroiIBRnjwyO, 
NbunkIVaMPVYgAQHXXYd, QMNXyOvXaZDsCpiIJPsn, xHiBGayUfxIpXKkCTDNU, 
gNROjwaqhxDPvBWUCUcQ); } MWConvLayerImpl::~MWConvLayerImpl() { } void 
MWConvLayerImpl::createConvLayer(int YFrWUSnoOKzYyZzANuxg, int 
ZUTPCvgISoRdtnhGqXzM, int QTXuPiGKeBUnmRzhlIDp, int NDHPlSVpLroiIBRnjwyO, int 
NbunkIVaMPVYgAQHXXYd, int QMNXyOvXaZDsCpiIJPsn, const char* 
xHiBGayUfxIpXKkCTDNU, const char* gNROjwaqhxDPvBWUCUcQ) { int 
asymmetricPadding; asymmetricPadding = 
QTXuPiGKeBUnmRzhlIDp==NDHPlSVpLroiIBRnjwyO?(QTXuPiGKeBUnmRzhlIDp==NbunkIVaMPVYgAQHXXYd? 
(QTXuPiGKeBUnmRzhlIDp==QMNXyOvXaZDsCpiIJPsn?1:0):0):0; 
if(asymmetricPadding==0){ 
printf("Asymmetric Padding not supported for tensorRT"); throw 
std::runtime_error("Unsupported Padding"); } MWConvLayer* convLayer = 
static_cast<MWConvLayer*>(getLayer()); MWTensor* ipTensor = 
convLayer->getInputTensor(0); MWTensor* opTensor = 
convLayer->getOutputTensor(0); wqggPBXZvtlxnxwngvAq = 
(float*)calloc(ipTensor->getChannels() / JxwPQNPACGfmGpNncpCY * 
opTensor->getChannels() * GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO, 
sizeof(float)); eUSuiwvLvXVXrpUkgBVu = (float*)calloc(opTensor->getChannels(), 
sizeof(float)); loadWeights(xHiBGayUfxIpXKkCTDNU); 
loadBias(gNROjwaqhxDPvBWUCUcQ); filt_weights.values = wqggPBXZvtlxnxwngvAq; 
filt_weights.count = ipTensor->getChannels() / JxwPQNPACGfmGpNncpCY * 
opTensor->getChannels() * GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO; 
filt_weights.type = DataType::kFLOAT; filt_bias.values = eUSuiwvLvXVXrpUkgBVu; 
filt_bias.count = opTensor->getChannels(); filt_bias.type = DataType::kFLOAT; 
ITensor* prevLayerTensor = getprevLayerTensor(ipTensor); ConvLayerT = 
rIcMzXptfYweLArNRnBw->network->addConvolution( *prevLayerTensor, 
opTensor->getChannels(), DimsHW{GbdgxISzcqHOpzQEBrvP, 
JABfZsGuaCAmcRcqOYEO}, filt_weights, filt_bias); 
ConvLayerT->setStride(DimsHW{YFrWUSnoOKzYyZzANuxg, ZUTPCvgISoRdtnhGqXzM}); 
ConvLayerT->setPadding(DimsHW{(QTXuPiGKeBUnmRzhlIDp+NDHPlSVpLroiIBRnjwyO)/2, 
(NbunkIVaMPVYgAQHXXYd + QMNXyOvXaZDsCpiIJPsn)/2}); 
ConvLayerT->setNbGroups(JxwPQNPACGfmGpNncpCY); 
setOpTensorPtr(ConvLayerT->getOutput(0)); return; } void 
MWConvLayerImpl::cleanup() { free(wqggPBXZvtlxnxwngvAq); free(eUSuiwvLvXVXrpUkgBVu); return; } 
void MWConvLayerImpl::loadWeights(const char* leWFtIPrKkXLixGWBGJW) { 
MWConvLayer* convLayer = static_cast<MWConvLayer*>(getLayer()); FILE* 
nDsbARncmIrIaLubvLVZ = MWCNNLayer::openBinaryFile(leWFtIPrKkXLixGWBGJW); 
assert(nDsbARncmIrIaLubvLVZ); int rlQsibXJSWJVnUVpdNeL = 
convLayer->getInputTensor()->getChannels() / JxwPQNPACGfmGpNncpCY * 
convLayer->getOutputTensor()->getChannels() * GbdgxISzcqHOpzQEBrvP * 
JABfZsGuaCAmcRcqOYEO;  fread(wqggPBXZvtlxnxwngvAq, sizeof(float), rlQsibXJSWJVnUVpdNeL, 
nDsbARncmIrIaLubvLVZ); if (GbdgxISzcqHOpzQEBrvP != 1 && JABfZsGuaCAmcRcqOYEO != 
1) { float* hvqKUzPqCuUJRfoNlbwW = (float*)malloc(sizeof(float) * 
GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO); for (int k = 0; k < 
rlQsibXJSWJVnUVpdNeL / GbdgxISzcqHOpzQEBrvP / JABfZsGuaCAmcRcqOYEO; k++) { for 
(int i = 0; i < GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO; i++) { 
hvqKUzPqCuUJRfoNlbwW[i] = wqggPBXZvtlxnxwngvAq[k * GbdgxISzcqHOpzQEBrvP * 
JABfZsGuaCAmcRcqOYEO + i]; } for (int j = 0; j < GbdgxISzcqHOpzQEBrvP; 
j++) for (int i = 0; i < JABfZsGuaCAmcRcqOYEO; i++) { wqggPBXZvtlxnxwngvAq[k * 
GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO + j * JABfZsGuaCAmcRcqOYEO + 
i] = hvqKUzPqCuUJRfoNlbwW[j + i * GbdgxISzcqHOpzQEBrvP]; } } 
free(hvqKUzPqCuUJRfoNlbwW); } fclose(nDsbARncmIrIaLubvLVZ); return; } void 
MWConvLayerImpl::loadBias(const char* leWFtIPrKkXLixGWBGJW) { MWConvLayer* 
convLayer = static_cast<MWConvLayer*>(getLayer()); FILE* nDsbARncmIrIaLubvLVZ = 
MWCNNLayer::openBinaryFile(leWFtIPrKkXLixGWBGJW); assert(nDsbARncmIrIaLubvLVZ); int 
rlQsibXJSWJVnUVpdNeL = convLayer->getOutputTensor()->getChannels();  
fread(eUSuiwvLvXVXrpUkgBVu, sizeof(float), rlQsibXJSWJVnUVpdNeL, nDsbARncmIrIaLubvLVZ); 
fclose(nDsbARncmIrIaLubvLVZ); return; } MWReLULayerImpl::MWReLULayerImpl(MWCNNLayer* 
layer, MWTargetNetworkImpl* ntwk_impl, int ) : MWCNNLayerImpl(layer, ntwk_impl) 
{ createReLULayer(); } MWReLULayerImpl::~MWReLULayerImpl() { } void 
MWReLULayerImpl::createReLULayer() { MWReLULayer* reluLayer = 
static_cast<MWReLULayer*>(getLayer()); MWTensor* ipTensor = 
reluLayer->getInputTensor(0); ITensor* prevLayerTensor = 
getprevLayerTensor(ipTensor); ReLULayer = 
rIcMzXptfYweLArNRnBw->network->addActivation(*prevLayerTensor, 
ActivationType::kRELU); setOpTensorPtr(ReLULayer->getOutput(0)); return; } 
MWNormLayerImpl::MWNormLayerImpl(MWCNNLayer* layer, unsigned 
aFDPITUhkPdupMfPOBnd, double BHuHNDGoRwGRouCxeMbw, double GLovsOhUpzOJhKgXUAJY, 
double JLDBTuxkNCsKfaFIEVHB, MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, 
ntwk_impl) { createNormLayer(aFDPITUhkPdupMfPOBnd, BHuHNDGoRwGRouCxeMbw, 
GLovsOhUpzOJhKgXUAJY, JLDBTuxkNCsKfaFIEVHB); } MWNormLayerImpl::~MWNormLayerImpl() { } void 
MWNormLayerImpl::createNormLayer(unsigned aFDPITUhkPdupMfPOBnd, double 
BHuHNDGoRwGRouCxeMbw, double GLovsOhUpzOJhKgXUAJY, double JLDBTuxkNCsKfaFIEVHB) { MWNormLayer* 
normLayer = static_cast<MWNormLayer*>(getLayer()); MWTensor* ipTensor = 
normLayer->getInputTensor(0); ITensor* prevLayerTensor = 
getprevLayerTensor(ipTensor); NormLayer = 
rIcMzXptfYweLArNRnBw->network->addLRN(*prevLayerTensor, 
aFDPITUhkPdupMfPOBnd, BHuHNDGoRwGRouCxeMbw, GLovsOhUpzOJhKgXUAJY, JLDBTuxkNCsKfaFIEVHB); 
setOpTensorPtr(NormLayer->getOutput(0)); return; } 
MWMaxPoolingLayerImpl::MWMaxPoolingLayerImpl(MWCNNLayer* layer, int 
RgjhbaFFVMpznMgMQMrE, int TaAJDyqFVJXfAfCJhOuU, int YFrWUSnoOKzYyZzANuxg, int 
ZUTPCvgISoRdtnhGqXzM, int QTXuPiGKeBUnmRzhlIDp, int NDHPlSVpLroiIBRnjwyO, int 
NbunkIVaMPVYgAQHXXYd, int QMNXyOvXaZDsCpiIJPsn, bool bYBVtTnVUuGDUlaTmmHp, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
assert(!bYBVtTnVUuGDUlaTmmHp); createMaxPoolingLayer(RgjhbaFFVMpznMgMQMrE, 
TaAJDyqFVJXfAfCJhOuU, YFrWUSnoOKzYyZzANuxg, ZUTPCvgISoRdtnhGqXzM, QTXuPiGKeBUnmRzhlIDp, 
NDHPlSVpLroiIBRnjwyO , NbunkIVaMPVYgAQHXXYd, QMNXyOvXaZDsCpiIJPsn); } 
MWMaxPoolingLayerImpl::~MWMaxPoolingLayerImpl() { } float* 
MWMaxPoolingLayerImpl::getIndexData() { assert(false); } void 
MWMaxPoolingLayerImpl::createMaxPoolingLayer(int RgjhbaFFVMpznMgMQMrE, int 
TaAJDyqFVJXfAfCJhOuU, int YFrWUSnoOKzYyZzANuxg, int ZUTPCvgISoRdtnhGqXzM, int 
QTXuPiGKeBUnmRzhlIDp, int NDHPlSVpLroiIBRnjwyO, int NbunkIVaMPVYgAQHXXYd, int 
QMNXyOvXaZDsCpiIJPsn) { MWMaxPoolingLayer* maxpoolLayer = 
static_cast<MWMaxPoolingLayer*>(getLayer()); MWTensor* ipTensor = 
maxpoolLayer->getInputTensor(0); ITensor* prevLayerTensor = 
getprevLayerTensor(ipTensor); MaxPoolingLayer = 
rIcMzXptfYweLArNRnBw->network->addPooling( *prevLayerTensor, PoolingType::kMAX, 
DimsHW{RgjhbaFFVMpznMgMQMrE, TaAJDyqFVJXfAfCJhOuU}); 
MaxPoolingLayer->setStride(DimsHW{YFrWUSnoOKzYyZzANuxg, YFrWUSnoOKzYyZzANuxg}); 
MaxPoolingLayer->setPadding(DimsHW{(QTXuPiGKeBUnmRzhlIDp+NDHPlSVpLroiIBRnjwyO)/2, 
(NbunkIVaMPVYgAQHXXYd+QMNXyOvXaZDsCpiIJPsn)/2}); 
setOpTensorPtr(MaxPoolingLayer->getOutput(0)); } 
MWFCLayerImpl::MWFCLayerImpl(MWCNNLayer* layer, const char* 
xHiBGayUfxIpXKkCTDNU, const char* gNROjwaqhxDPvBWUCUcQ, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
createFCLayer(xHiBGayUfxIpXKkCTDNU, gNROjwaqhxDPvBWUCUcQ); } 
MWFCLayerImpl::~MWFCLayerImpl() { } void MWFCLayerImpl::createFCLayer(const 
char* xHiBGayUfxIpXKkCTDNU, const char* gNROjwaqhxDPvBWUCUcQ) { MWFCLayer* 
fcLayer = static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(0); MWTensor* opTensor = fcLayer->getOutputTensor(0); 
int numInpFeatures = ipTensor->getChannels() * ipTensor->getHeight() * 
ipTensor->getWidth(); wqggPBXZvtlxnxwngvAq = (float*)calloc(numInpFeatures * 
opTensor->getChannels(), sizeof(float)); eUSuiwvLvXVXrpUkgBVu = 
(float*)calloc(opTensor->getChannels(), sizeof(float)); 
loadWeights(xHiBGayUfxIpXKkCTDNU); loadBias(gNROjwaqhxDPvBWUCUcQ); ITensor* 
prevLayerTensor = getprevLayerTensor(ipTensor); filt_weights.values = 
wqggPBXZvtlxnxwngvAq; filt_weights.count = numInpFeatures * opTensor->getChannels(); 
filt_weights.type = DataType::kFLOAT; filt_bias.values = eUSuiwvLvXVXrpUkgBVu; 
filt_bias.count = opTensor->getChannels(); filt_bias.type = DataType::kFLOAT; 
FCLayer = rIcMzXptfYweLArNRnBw->network->addFullyConnected( *prevLayerTensor, 
opTensor->getChannels(), filt_weights, filt_bias); 
setOpTensorPtr(FCLayer->getOutput(0)); return; } void 
MWFCLayerImpl::loadWeights(const char* leWFtIPrKkXLixGWBGJW) { MWFCLayer* 
fcLayer = static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(0); MWTensor* opTensor = fcLayer->getOutputTensor(0); 
FILE* nDsbARncmIrIaLubvLVZ = MWCNNLayer::openBinaryFile(leWFtIPrKkXLixGWBGJW); 
assert(nDsbARncmIrIaLubvLVZ); int rlQsibXJSWJVnUVpdNeL = ipTensor->getChannels() * 
ipTensor->getHeight() * ipTensor->getWidth() * opTensor->getChannels();  
fread(wqggPBXZvtlxnxwngvAq, sizeof(float), rlQsibXJSWJVnUVpdNeL, nDsbARncmIrIaLubvLVZ); if 
(ipTensor->getHeight() != 1 && ipTensor->getWidth() != 1) { float* 
hvqKUzPqCuUJRfoNlbwW = (float*)malloc(sizeof(float) * ipTensor->getHeight() * 
ipTensor->getWidth()); for (int k = 0; k < rlQsibXJSWJVnUVpdNeL / 
ipTensor->getHeight() / ipTensor->getWidth(); k++) { for (int i = 0; i < 
ipTensor->getHeight() * ipTensor->getWidth(); i++) { hvqKUzPqCuUJRfoNlbwW[i] = 
wqggPBXZvtlxnxwngvAq[k * ipTensor->getHeight() * ipTensor->getWidth() + i]; } for (int 
j = 0; j < ipTensor->getHeight(); j++) for (int i = 0; i < 
ipTensor->getWidth(); i++) { wqggPBXZvtlxnxwngvAq[k * ipTensor->getHeight() * 
ipTensor->getWidth() + j * ipTensor->getWidth() + i] = hvqKUzPqCuUJRfoNlbwW[j + i 
* ipTensor->getHeight()]; } } free(hvqKUzPqCuUJRfoNlbwW); } 
fclose(nDsbARncmIrIaLubvLVZ); return; } void MWFCLayerImpl::loadBias(const char* 
leWFtIPrKkXLixGWBGJW) { MWFCLayer* fcLayer = 
static_cast<MWFCLayer*>(getLayer()); MWTensor* opTensor = 
fcLayer->getOutputTensor(0); FILE* nDsbARncmIrIaLubvLVZ = 
MWCNNLayer::openBinaryFile(leWFtIPrKkXLixGWBGJW); assert(nDsbARncmIrIaLubvLVZ); int 
rlQsibXJSWJVnUVpdNeL = opTensor->getChannels();  fread(eUSuiwvLvXVXrpUkgBVu, sizeof(float), 
rlQsibXJSWJVnUVpdNeL, nDsbARncmIrIaLubvLVZ); fclose(nDsbARncmIrIaLubvLVZ); return; } void 
MWFCLayerImpl::cleanup() { free(wqggPBXZvtlxnxwngvAq); free(eUSuiwvLvXVXrpUkgBVu); } 
MWSoftmaxLayerImpl::MWSoftmaxLayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { createSoftmaxLayer(); } 
MWSoftmaxLayerImpl::~MWSoftmaxLayerImpl() { } void 
MWSoftmaxLayerImpl::createSoftmaxLayer() { MWSoftmaxLayer* sfmxLayer = 
static_cast<MWSoftmaxLayer*>(getLayer()); MWTensor* ipTensor = 
sfmxLayer->getInputTensor(0); MWTensor* opTensor = 
sfmxLayer->getOutputTensor(0); ITensor* prevLayerTensor = 
getprevLayerTensor(ipTensor); SoftmaxLayer = 
rIcMzXptfYweLArNRnBw->network->addSoftMax(*prevLayerTensor); 
setOpTensorPtr(SoftmaxLayer->getOutput(0)); return; } 
MWOutputLayerImpl::MWOutputLayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { createOutputLayer(); } 
MWOutputLayerImpl::~MWOutputLayerImpl() { } void 
MWOutputLayerImpl::createOutputLayer() { MWOutputLayer* opLayer = 
static_cast<MWOutputLayer*>(getLayer()); MWTensor* ipTensor = 
opLayer->getInputTensor(0); MWTensor* opTensor = opLayer->getOutputTensor(0); 
CUDA_CALL(cudaMalloc((void**)&iMyHYqdPsEjdhQptHQNt, sizeof(float) * 
opTensor->getBatchSize() * opTensor->getChannels() * opTensor->getHeight() * 
opTensor->getWidth())); ITensor* prevLayerTensor = 
getprevLayerTensor(ipTensor); prevLayerTensor->setName("prob"); 
rIcMzXptfYweLArNRnBw->network->markOutput(*prevLayerTensor); return; } void 
MWOutputLayerImpl::cleanup() { for (int idx = 0; idx < 
pdleXafalaHAmketaFyq->getNumOutputs(); idx++) { float* data = 
pdleXafalaHAmketaFyq->getOutputTensor(idx)->getData(); if (data) { 
call_cuda_free(data); } } } 
MWAvgPoolingLayerImpl::MWAvgPoolingLayerImpl(MWCNNLayer* layer, int 
RgjhbaFFVMpznMgMQMrE, int TaAJDyqFVJXfAfCJhOuU, int YFrWUSnoOKzYyZzANuxg, int 
ZUTPCvgISoRdtnhGqXzM, int LHIWBuIwgwCuuNBzenxH, int MRnAxrRZGjgErnCjJcbo, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
createAvgPoolingLayer(RgjhbaFFVMpznMgMQMrE, TaAJDyqFVJXfAfCJhOuU, YFrWUSnoOKzYyZzANuxg, 
ZUTPCvgISoRdtnhGqXzM, LHIWBuIwgwCuuNBzenxH, MRnAxrRZGjgErnCjJcbo); } 
MWAvgPoolingLayerImpl::~MWAvgPoolingLayerImpl() { } void 
MWAvgPoolingLayerImpl::createAvgPoolingLayer(int RgjhbaFFVMpznMgMQMrE, int 
TaAJDyqFVJXfAfCJhOuU, int YFrWUSnoOKzYyZzANuxg, int ZUTPCvgISoRdtnhGqXzM, int 
LHIWBuIwgwCuuNBzenxH, int MRnAxrRZGjgErnCjJcbo) { MWAvgPoolingLayer* AvgpoolLayer 
= static_cast<MWAvgPoolingLayer*>(getLayer()); MWTensor* ipTensor = 
AvgpoolLayer->getInputTensor(0); ITensor* prevLayerTensor = 
getprevLayerTensor(ipTensor); AvgPoolingLayer = 
rIcMzXptfYweLArNRnBw->network->addPooling( *prevLayerTensor, 
PoolingType::kAVERAGE, DimsHW{RgjhbaFFVMpznMgMQMrE, TaAJDyqFVJXfAfCJhOuU}); 
AvgPoolingLayer->setStride(DimsHW{YFrWUSnoOKzYyZzANuxg, YFrWUSnoOKzYyZzANuxg}); 
setOpTensorPtr(AvgPoolingLayer->getOutput(0)); }