#include <stdio.h>
#include <cassert>
#include "cnn_api.hpp"
#include "MWTransposedConvolution2DLayer.hpp"
#include "MWCNNLayerImpl.hpp"
#include "MWTransposedConvolution2DLayerImpl.hpp"
 MWTransposedConvolution2DLayerImpl::MWTransposedConvolution2DLayerImpl( 
MWCNNLayer* layer, int filt_H, int filt_W, int numIpFeatures, int numFilts, int 
YFrWUSnoOKzYyZzANuxg, int ZUTPCvgISoRdtnhGqXzM, int LHIWBuIwgwCuuNBzenxH, int 
MRnAxrRZGjgErnCjJcbo, const char* xHiBGayUfxIpXKkCTDNU, const char* 
gNROjwaqhxDPvBWUCUcQ, MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, 
ntwk_impl) , GbdgxISzcqHOpzQEBrvP(filt_H) , JABfZsGuaCAmcRcqOYEO(filt_W) , 
JxwPQNPACGfmGpNncpCY(1) , wqggPBXZvtlxnxwngvAq(NULL) , eUSuiwvLvXVXrpUkgBVu(NULL) { 
createTransposedConv2DLayer(YFrWUSnoOKzYyZzANuxg, ZUTPCvgISoRdtnhGqXzM, 
LHIWBuIwgwCuuNBzenxH, MRnAxrRZGjgErnCjJcbo, xHiBGayUfxIpXKkCTDNU, 
gNROjwaqhxDPvBWUCUcQ); } 
MWTransposedConvolution2DLayerImpl::~MWTransposedConvolution2DLayerImpl() { } 
void MWTransposedConvolution2DLayerImpl::createTransposedConv2DLayer( int 
YFrWUSnoOKzYyZzANuxg, int ZUTPCvgISoRdtnhGqXzM, int LHIWBuIwgwCuuNBzenxH, int 
MRnAxrRZGjgErnCjJcbo, const char* xHiBGayUfxIpXKkCTDNU, const char* 
gNROjwaqhxDPvBWUCUcQ) { MWTransposedConvolution2DLayer* deConvLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* ipTensor = 
deConvLayer->getInputTensor(0); MWTensor* opTensor = 
deConvLayer->getOutputTensor(0); wqggPBXZvtlxnxwngvAq = 
(float*)calloc(ipTensor->getChannels() / JxwPQNPACGfmGpNncpCY * 
opTensor->getChannels() * GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO, 
sizeof(float)); eUSuiwvLvXVXrpUkgBVu = (float*)calloc(opTensor->getChannels(), 
sizeof(float)); loadWeights(xHiBGayUfxIpXKkCTDNU); 
loadBias(gNROjwaqhxDPvBWUCUcQ); filt_weights.values = wqggPBXZvtlxnxwngvAq; 
filt_weights.count = ipTensor->getChannels() / JxwPQNPACGfmGpNncpCY * 
opTensor->getChannels() * GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO; 
filt_weights.type = DataType::kFLOAT; filt_bias.values = eUSuiwvLvXVXrpUkgBVu; 
filt_bias.count = opTensor->getChannels(); filt_bias.type = DataType::kFLOAT; 
ITensor* prevLayerTensor = ipTensor->getOwner()->getImpl()->getOpTensorPtr(); 
DeconvLayer = rIcMzXptfYweLArNRnBw->network->addDeconvolution( *prevLayerTensor, 
opTensor->getChannels(), DimsHW{GbdgxISzcqHOpzQEBrvP, 
JABfZsGuaCAmcRcqOYEO}, filt_weights, filt_bias); 
DeconvLayer->setStride(DimsHW{YFrWUSnoOKzYyZzANuxg, ZUTPCvgISoRdtnhGqXzM}); 
DeconvLayer->setPadding(DimsHW{LHIWBuIwgwCuuNBzenxH, MRnAxrRZGjgErnCjJcbo}); 
setOpTensorPtr(DeconvLayer->getOutput(0)); return; } void 
MWTransposedConvolution2DLayerImpl::cleanup() { free(wqggPBXZvtlxnxwngvAq); 
free(eUSuiwvLvXVXrpUkgBVu); } void 
MWTransposedConvolution2DLayerImpl::loadWeights(const char* 
leWFtIPrKkXLixGWBGJW) { MWTransposedConvolution2DLayer* convLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* opTensor = 
convLayer->getOutputTensor(0); MWTensor* ipTensor = 
convLayer->getInputTensor(0); FILE* nDsbARncmIrIaLubvLVZ = 
MWCNNLayer::openBinaryFile(leWFtIPrKkXLixGWBGJW); assert(nDsbARncmIrIaLubvLVZ); int 
rlQsibXJSWJVnUVpdNeL = ipTensor->getChannels() * opTensor->getChannels() * 
GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO;  fread(wqggPBXZvtlxnxwngvAq, 
sizeof(float), rlQsibXJSWJVnUVpdNeL, nDsbARncmIrIaLubvLVZ); if (GbdgxISzcqHOpzQEBrvP != 1 
&& JABfZsGuaCAmcRcqOYEO != 1) { float* hvqKUzPqCuUJRfoNlbwW = 
(float*)malloc(sizeof(float) * GbdgxISzcqHOpzQEBrvP * 
JABfZsGuaCAmcRcqOYEO); for (int k = 0; k < rlQsibXJSWJVnUVpdNeL / 
GbdgxISzcqHOpzQEBrvP / JABfZsGuaCAmcRcqOYEO; k++) { for (int i = 0; i < 
GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO; i++) { hvqKUzPqCuUJRfoNlbwW[i] 
= wqggPBXZvtlxnxwngvAq[k * GbdgxISzcqHOpzQEBrvP * JABfZsGuaCAmcRcqOYEO + i]; } for 
(int j = 0; j < GbdgxISzcqHOpzQEBrvP; j++) for (int i = 0; i < 
JABfZsGuaCAmcRcqOYEO; i++) { wqggPBXZvtlxnxwngvAq[k * GbdgxISzcqHOpzQEBrvP * 
JABfZsGuaCAmcRcqOYEO + j * JABfZsGuaCAmcRcqOYEO + i] = hvqKUzPqCuUJRfoNlbwW[j 
+ i * GbdgxISzcqHOpzQEBrvP]; } } free(hvqKUzPqCuUJRfoNlbwW); } 
printf("%s loaded. Size = %d. %f\n", leWFtIPrKkXLixGWBGJW, rlQsibXJSWJVnUVpdNeL, 
wqggPBXZvtlxnxwngvAq[0]); fclose(nDsbARncmIrIaLubvLVZ); return; } void 
MWTransposedConvolution2DLayerImpl::loadBias(const char* leWFtIPrKkXLixGWBGJW) { 
MWTransposedConvolution2DLayer* convLayer = 
static_cast<MWTransposedConvolution2DLayer*>(getLayer()); MWTensor* opTensor = 
convLayer->getOutputTensor(0); FILE* nDsbARncmIrIaLubvLVZ = 
MWCNNLayer::openBinaryFile(leWFtIPrKkXLixGWBGJW); assert(nDsbARncmIrIaLubvLVZ); int 
rlQsibXJSWJVnUVpdNeL = opTensor->getChannels();  fread(eUSuiwvLvXVXrpUkgBVu, sizeof(float), 
rlQsibXJSWJVnUVpdNeL, nDsbARncmIrIaLubvLVZ); fclose(nDsbARncmIrIaLubvLVZ); return; }