#include "MWCNNLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"
#include <cassert>
#include <cstring>
#include <stdio.h>
#include "arm_compute/runtime/NEON/NEFunctions.h"
#include "arm_compute/core/Types.h"
 using namespace arm_compute; MWCNNLayerImpl::MWCNNLayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl) : oKIvzXXMucEDsTGGpdpm(layer) , 
pvpNsgGssdTxeVoFIkXI(ntwk_impl) { } void MWCNNLayerImpl::setData(float* data) { 
eqUIJyhXTwRqtPfXapcx = data; } Tensor* 
MWCNNLayerImpl::getprevLayerarmTensor(MWTensor* ipTensor) { Tensor* 
prevLayerarmTensor; if (ipTensor->getOwner()->getImpl() == NULL) { 
prevLayerarmTensor = 
&ipTensor->getOwner()->getInputTensor()->getOwner()->getImpl()->armTensor; } 
else { prevLayerarmTensor = &ipTensor->getOwner()->getImpl()->armTensor; } } 
MWInputLayerImpl::MWInputLayerImpl(MWCNNLayer* layer, int pFoPPXxxFRbjXXxQWItv, int 
mMUSFIVwpGpGcZkFsLbd, int rMMjgjGRAiLVlTlRSByU, int dkLDkRwCBjeybwDHbKiE, bool unSXtdjDjpysqxmbIiPv, 
const char* avg_file_name, MWTargetNetworkImpl* ntwk_impl) : 
MWCNNLayerImpl(layer, ntwk_impl) { createInputLayer(pFoPPXxxFRbjXXxQWItv, mMUSFIVwpGpGcZkFsLbd, 
rMMjgjGRAiLVlTlRSByU, dkLDkRwCBjeybwDHbKiE, unSXtdjDjpysqxmbIiPv, avg_file_name); } 
MWInputLayerImpl::~MWInputLayerImpl() { } int tap_count = 0; void 
mw_interm_tap(float* inp, int size, int count) { FILE* fp; int i; char str[500];
#define TXT_FILE 1
#if TXT_FILE
 sprintf(str, "taps/mw_interm_tap_%d.txt", count); fp = fopen(str, "w"); for (i 
= 0; i < size; i++) { fprintf(fp, "%f\n", inp[i]); }
#else
 sprintf(str, "taps/mw_interm_tap_%d.bin", count); fp = fopen(str, "wb"); 
fwrite(inp, 4, size, fp);
#endif
 fclose(fp); } void MWInputLayerImpl::createInputLayer(int pFoPPXxxFRbjXXxQWItv, int 
mMUSFIVwpGpGcZkFsLbd, int rMMjgjGRAiLVlTlRSByU, int dkLDkRwCBjeybwDHbKiE, bool unSXtdjDjpysqxmbIiPv, 
const char* avg_file_name) { MWInputLayer* inpLayer = 
static_cast<MWInputLayer*>(getLayer()); mtolGPkUMBYDlSSqrRzc = 
unSXtdjDjpysqxmbIiPv; inputImage = (float*)calloc(pFoPPXxxFRbjXXxQWItv * dkLDkRwCBjeybwDHbKiE * 
mMUSFIVwpGpGcZkFsLbd * rMMjgjGRAiLVlTlRSByU, sizeof(float)); setData(inputImage); 
armTensor.allocator()->init( TensorInfo(TensorShape((long unsigned 
int)rMMjgjGRAiLVlTlRSByU, (long unsigned int)mMUSFIVwpGpGcZkFsLbd, (long unsigned 
int)dkLDkRwCBjeybwDHbKiE), 1, DataType::F32, 4)); int rISNTTiSXOTdHqHTtNiB = dkLDkRwCBjeybwDHbKiE * 
mMUSFIVwpGpGcZkFsLbd * rMMjgjGRAiLVlTlRSByU; loadAvg(avg_file_name, rISNTTiSXOTdHqHTtNiB); return; } 
void MWInputLayerImpl::loadAvg(const char* fDqxEdcpBDmVQxZEmQxm, int 
rISNTTiSXOTdHqHTtNiB) { FILE* hKyfKjPACkOBDvLdESxH; size_t retVal; char filename[500]; 
sprintf(filename, "%s", fDqxEdcpBDmVQxZEmQxm); hKyfKjPACkOBDvLdESxH = fopen(filename, 
"r"); if (hKyfKjPACkOBDvLdESxH == NULL) { printf("Unabel to open file\n"); } 
YNmJhGSUszJKxsodxiuV = (float*)calloc(rISNTTiSXOTdHqHTtNiB, sizeof(float)); retVal = 
fread(YNmJhGSUszJKxsodxiuV, sizeof(float), rISNTTiSXOTdHqHTtNiB, hKyfKjPACkOBDvLdESxH); if (retVal 
!= (size_t)rISNTTiSXOTdHqHTtNiB) { 
printf("MWInputLayer::loadAvg - File read Failed\n"); } fclose(hKyfKjPACkOBDvLdESxH); 
return; } void MWInputLayerImpl::allocate() { MWInputLayer* inpLayer = 
static_cast<MWInputLayer*>(getLayer()); MWTensor* opTensor = 
inpLayer->getOutputTensor(0); armTensor.allocator()->allocate(); if 
((armTensor.info()->total_size() / 4) == (opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth())) { 
setData((float*)armTensor.buffer()); } else { setData(inputImage); } 
inpLayer->getOutputTensor()->setData(getData()); } void fillIpToTensor(unsigned 
char* in_buffer, arm_compute::ITensor& tensor) { uint width = 
tensor.info()->dimension(0); uint height = tensor.info()->dimension(1); int 
data_size_in_bytes = 4;  int collapsed_upper = 
tensor.info()->tensor_shape().total_size_upper(2); uint8_t* ptr_out = 
tensor.buffer() + tensor.info()->offset_first_element_in_bytes(); const 
arm_compute::Strides& strides_in_bytes = tensor.info()->strides_in_bytes(); for 
(int i = 0; i < collapsed_upper; ++i) { size_t slice_offset = i * 
strides_in_bytes.z(); for (unsigned int y = 0; y < height; ++y) { size_t 
row_offset = y * strides_in_bytes.y(); memcpy(ptr_out + slice_offset + 
row_offset, in_buffer + i * width * height * data_size_in_bytes + y * width * 
data_size_in_bytes, width * data_size_in_bytes); } } } void 
fillTensorToIp(unsigned char* out_buffer, arm_compute::ITensor& tensor) { uint 
width = tensor.info()->dimension(0); uint height = tensor.info()->dimension(1); 
int data_size_in_bytes = 4;  int collapsed_upper = 
tensor.info()->tensor_shape().total_size_upper(2); uint8_t* ptr_out = 
tensor.buffer() + tensor.info()->offset_first_element_in_bytes(); const 
arm_compute::Strides& strides_in_bytes = tensor.info()->strides_in_bytes(); for 
(int i = 0; i < collapsed_upper; ++i) { size_t slice_offset = i * 
strides_in_bytes.z(); for (unsigned int y = 0; y < height; ++y) { size_t 
row_offset = y * strides_in_bytes.y(); memcpy(out_buffer + i * width * height * 
data_size_in_bytes + y * width * data_size_in_bytes, ptr_out + slice_offset + 
row_offset, width * data_size_in_bytes); } } } void MWInputLayerImpl::predict() 
{ float* inp = inputImage; int i, btch; MWInputLayer* inpLayer = 
static_cast<MWInputLayer*>(getLayer()); MWTensor* opTensor = 
inpLayer->getOutputTensor(0); float* out = inputImage; if 
((armTensor.info()->total_size() / 4) == (opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth())) { inp 
= (float*)armTensor.buffer(); out = (float*)armTensor.buffer(); } else { inp = 
inputImage; out = inputImage; } if (mtolGPkUMBYDlSSqrRzc) { for (btch = 0; btch 
< opTensor->getBatchSize(); btch++) { for (i = 0; i < opTensor->getChannels() * 
opTensor->getHeight() * opTensor->getWidth(); i++) { out[i] = inp[i] - 
YNmJhGSUszJKxsodxiuV[i]; } inp += opTensor->getChannels() * opTensor->getHeight() * 
opTensor->getWidth(); out += opTensor->getChannels() * opTensor->getHeight() * 
opTensor->getWidth(); } if ((armTensor.info()->total_size() / 4) != 
(opTensor->getBatchSize() * opTensor->getChannels() * opTensor->getHeight() * 
opTensor->getWidth())) { fillIpToTensor((unsigned char*)inputImage, armTensor); }
#if MW_INPUT_TAP
 mw_interm_tap((float*)armTensor.buffer(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 } return; } void MWInputLayerImpl::cleanup() { for (int idx = 0; idx < 
oKIvzXXMucEDsTGGpdpm->getNumOutputs(); idx++) { float* data = 
oKIvzXXMucEDsTGGpdpm->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
if (mtolGPkUMBYDlSSqrRzc) { if (YNmJhGSUszJKxsodxiuV) { free(YNmJhGSUszJKxsodxiuV); } } return; 
} MWConvLayerImpl::MWConvLayerImpl(MWCNNLayer* layer, int filt_H, int filt_W, 
int numGrps, int numChnls, int numFilts, int WerBmCOBWhvoFbdqfitc, int 
WmXADZOqdcQvtBUvFerh, int HgeIbZCtKXtKFOEtSlPZ, int GIbahSoBBDrvvZduPEqU, int 
GLpnVFeGjOSrhNqnkdCu, int HUdjvMUbhwNBNiIGaMZg, const char* 
tCfVGVGaqfGdJypAKQqq, const char* dAGMlbhOYuZqhuDGCqih, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) , CCKWXUFWgrbBMjwfpOBN(filt_H) 
, CLOUhPjbgggWoXHTtmjC(filt_W) , CTCbzQMDaLxINPbODdng(numGrps) { 
createConvLayer(WerBmCOBWhvoFbdqfitc, WmXADZOqdcQvtBUvFerh, HgeIbZCtKXtKFOEtSlPZ, 
GIbahSoBBDrvvZduPEqU, GLpnVFeGjOSrhNqnkdCu, HUdjvMUbhwNBNiIGaMZg, 
tCfVGVGaqfGdJypAKQqq, dAGMlbhOYuZqhuDGCqih); } 
MWConvLayerImpl::~MWConvLayerImpl() { } void 
MWConvLayerImpl::createConvLayer(int WerBmCOBWhvoFbdqfitc, int 
WmXADZOqdcQvtBUvFerh, int HgeIbZCtKXtKFOEtSlPZ, int GIbahSoBBDrvvZduPEqU, int 
GLpnVFeGjOSrhNqnkdCu, int HUdjvMUbhwNBNiIGaMZg, const char* 
tCfVGVGaqfGdJypAKQqq, const char* dAGMlbhOYuZqhuDGCqih) { int 
asymmetricPadding; asymmetricPadding = 
HgeIbZCtKXtKFOEtSlPZ==GIbahSoBBDrvvZduPEqU?(HgeIbZCtKXtKFOEtSlPZ==GLpnVFeGjOSrhNqnkdCu? 
(HgeIbZCtKXtKFOEtSlPZ==HUdjvMUbhwNBNiIGaMZg?1:0):0):0; 
if(asymmetricPadding==0){ 
printf("Asymmetric Padding not supported for arm-compute platform"); throw 
std::runtime_error("Unsupported Padding"); } int BkwhtPQUCQKchmmimoXs[2]; 
MWConvLayer* convLayer = static_cast<MWConvLayer*>(getLayer()); MWTensor* 
ipTensor = convLayer->getInputTensor(0); MWTensor* opTensor = 
convLayer->getOutputTensor(0); BkwhtPQUCQKchmmimoXs[0] = 
(HgeIbZCtKXtKFOEtSlPZ + GIbahSoBBDrvvZduPEqU) / 2; BkwhtPQUCQKchmmimoXs[1] = 
(GLpnVFeGjOSrhNqnkdCu + HUdjvMUbhwNBNiIGaMZg) / 2; Tensor* prevLayerarmTensor = 
getprevLayerarmTensor(ipTensor); ConvLayerWgtTensor.allocator()->init( 
TensorInfo(TensorShape((long unsigned int)CLOUhPjbgggWoXHTtmjC, (long 
unsigned int)CCKWXUFWgrbBMjwfpOBN, (long unsigned 
int)ipTensor->getChannels() / CTCbzQMDaLxINPbODdng, (long unsigned 
int)opTensor->getChannels()), 1, DataType::F32, 4)); 
ConvLayerBiasTensor.allocator()->init( TensorInfo(TensorShape((long unsigned 
int)opTensor->getChannels()), 1, DataType::F32, 4)); 
armTensor.allocator()->init(TensorInfo(TensorShape((long unsigned 
int)opTensor->getWidth(), (long unsigned int)opTensor->getHeight(), (long 
unsigned int)opTensor->getChannels()), 1, DataType::F32, 4)); if 
(CTCbzQMDaLxINPbODdng != 1) { prevLayer1 = new SubTensor( prevLayerarmTensor, 
TensorShape((long unsigned int)ipTensor->getHeight(), (long unsigned 
int)ipTensor->getWidth(), (long unsigned int)(ipTensor->getChannels() / 
CTCbzQMDaLxINPbODdng), (long unsigned int)ipTensor->getBatchSize()), 
Coordinates()); prevLayer2 = new SubTensor( prevLayerarmTensor, 
TensorShape((long unsigned int)ipTensor->getHeight(), (long unsigned 
int)ipTensor->getWidth(), (long unsigned int)(ipTensor->getChannels() / 
CTCbzQMDaLxINPbODdng), (long unsigned int)ipTensor->getBatchSize()), 
Coordinates(0, 0, ipTensor->getChannels() / CTCbzQMDaLxINPbODdng)); curLayer1 = 
new SubTensor( &armTensor, TensorShape((long unsigned int)opTensor->getWidth(), 
(long unsigned int)opTensor->getHeight(), (long unsigned 
int)(opTensor->getChannels() / CTCbzQMDaLxINPbODdng), (long unsigned 
int)opTensor->getBatchSize()), Coordinates()); curLayer2 = new SubTensor( 
&armTensor, TensorShape((long unsigned int)opTensor->getWidth(), (long unsigned 
int)opTensor->getHeight(), (long unsigned int)(opTensor->getChannels() / 
CTCbzQMDaLxINPbODdng), (long unsigned int)opTensor->getBatchSize()), 
Coordinates(0, 0, opTensor->getChannels() / CTCbzQMDaLxINPbODdng)); 
ConvLayerWgtMWTensor = new SubTensor( &ConvLayerWgtTensor, TensorShape((long 
unsigned int)CCKWXUFWgrbBMjwfpOBN, (long unsigned 
int)CLOUhPjbgggWoXHTtmjC, (long unsigned int)(ipTensor->getChannels() / 
CTCbzQMDaLxINPbODdng), (long unsigned int)(opTensor->getChannels() / 
CTCbzQMDaLxINPbODdng)), Coordinates()); ConvLayerWgtTensor2 = new SubTensor( 
&ConvLayerWgtTensor, TensorShape((long unsigned int)CCKWXUFWgrbBMjwfpOBN, 
(long unsigned int)CLOUhPjbgggWoXHTtmjC, (long unsigned 
int)(ipTensor->getChannels() / CTCbzQMDaLxINPbODdng), (long unsigned 
int)(opTensor->getChannels() / CTCbzQMDaLxINPbODdng)), Coordinates(0, 0, 0, 
opTensor->getChannels() / CTCbzQMDaLxINPbODdng)); ConvLayerBiasMWTensor = new 
SubTensor( &ConvLayerBiasTensor, TensorShape((long unsigned 
int)(opTensor->getChannels() / CTCbzQMDaLxINPbODdng)), Coordinates()); 
ConvLayerBiasTensor2 = new SubTensor( &ConvLayerBiasTensor, TensorShape((long 
unsigned int)(opTensor->getChannels() / CTCbzQMDaLxINPbODdng)), 
Coordinates(opTensor->getChannels() / CTCbzQMDaLxINPbODdng)); 
ConvLayer.configure(prevLayer1, ConvLayerWgtMWTensor, ConvLayerBiasMWTensor, 
curLayer1, PadStrideInfo(WmXADZOqdcQvtBUvFerh, WerBmCOBWhvoFbdqfitc, 
BkwhtPQUCQKchmmimoXs[1], BkwhtPQUCQKchmmimoXs[0]), WeightsInfo(false, (long 
unsigned int)CLOUhPjbgggWoXHTtmjC,(long unsigned 
int)CCKWXUFWgrbBMjwfpOBN,(long unsigned int)opTensor->getChannels())); 
ConvLayerSecondGroup.configure( prevLayer2, ConvLayerWgtTensor2, 
ConvLayerBiasTensor2, curLayer2, PadStrideInfo(WmXADZOqdcQvtBUvFerh, 
WerBmCOBWhvoFbdqfitc, BkwhtPQUCQKchmmimoXs[1], BkwhtPQUCQKchmmimoXs[0]), 
WeightsInfo(false, (long unsigned int)CLOUhPjbgggWoXHTtmjC,(long unsigned 
int)CCKWXUFWgrbBMjwfpOBN,(long unsigned int)opTensor->getChannels())); } 
else { ConvLayer.configure(prevLayerarmTensor, &ConvLayerWgtTensor, 
&ConvLayerBiasTensor, &armTensor, PadStrideInfo(WmXADZOqdcQvtBUvFerh, 
WerBmCOBWhvoFbdqfitc, BkwhtPQUCQKchmmimoXs[1], BkwhtPQUCQKchmmimoXs[0]), 
WeightsInfo(false, (long unsigned int)CLOUhPjbgggWoXHTtmjC,(long unsigned 
int)CCKWXUFWgrbBMjwfpOBN,(long unsigned int)opTensor->getChannels())); } 
loadWeights(tCfVGVGaqfGdJypAKQqq); loadBias(dAGMlbhOYuZqhuDGCqih); return; } 
void MWConvLayerImpl::allocate() { armTensor.allocator()->allocate(); 
setData((float*)armTensor.buffer()); MWConvLayer* convLayer = 
static_cast<MWConvLayer*>(getLayer()); 
convLayer->getOutputTensor()->setData((float*)armTensor.buffer()); } void 
MWConvLayerImpl::predict() { MWConvLayer* convLayer = 
static_cast<MWConvLayer*>(getLayer()); MWTensor* opTensor = 
convLayer->getOutputTensor(0); if (CTCbzQMDaLxINPbODdng == 1) { 
ConvLayer.run(); } else { ConvLayer.run(); ConvLayerSecondGroup.run(); }
#if MW_CONV_TAP
 mw_interm_tap((float*)armTensor.buffer(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWConvLayerImpl::cleanup() { if (CTCbzQMDaLxINPbODdng != 1) { 
delete prevLayer1; delete prevLayer2; delete curLayer1; delete curLayer2; 
delete ConvLayerWgtMWTensor; delete ConvLayerWgtTensor2; delete 
ConvLayerBiasMWTensor; delete ConvLayerBiasTensor2; } for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } void MWConvLayerImpl::loadWeights(const char* fDqxEdcpBDmVQxZEmQxm) { 
MWConvLayer* convLayer = static_cast<MWConvLayer*>(getLayer()); MWTensor* 
ipTensor = convLayer->getInputTensor(); MWTensor* opTensor = 
convLayer->getOutputTensor(); FILE* hKyfKjPACkOBDvLdESxH; float* sFIUeCwGDlfadqOrGZHC = 
(float*)calloc(ipTensor->getChannels() / CTCbzQMDaLxINPbODdng * 
opTensor->getChannels() * CCKWXUFWgrbBMjwfpOBN * CLOUhPjbgggWoXHTtmjC, 
sizeof(float)); size_t retVal; char filename[500]; sprintf(filename, "%s", 
fDqxEdcpBDmVQxZEmQxm); hKyfKjPACkOBDvLdESxH = fopen(filename, "r"); int rISNTTiSXOTdHqHTtNiB 
= ipTensor->getChannels() / CTCbzQMDaLxINPbODdng * opTensor->getChannels() * 
CCKWXUFWgrbBMjwfpOBN * CLOUhPjbgggWoXHTtmjC;  retVal = 
fread(sFIUeCwGDlfadqOrGZHC, sizeof(float), rISNTTiSXOTdHqHTtNiB, hKyfKjPACkOBDvLdESxH); if (retVal 
!= (size_t)rISNTTiSXOTdHqHTtNiB) { 
printf("MWConvLayer::loadWeights - File read Failed\n"); } if 
(CCKWXUFWgrbBMjwfpOBN != 1 && CLOUhPjbgggWoXHTtmjC != 1) { float* 
rSiiAFiHROnqjxqoWutE = (float*)malloc(sizeof(float) * CCKWXUFWgrbBMjwfpOBN * 
CLOUhPjbgggWoXHTtmjC); for (int k = 0; k < rISNTTiSXOTdHqHTtNiB / 
CCKWXUFWgrbBMjwfpOBN / CLOUhPjbgggWoXHTtmjC; k++) { for (int i = 0; i < 
CCKWXUFWgrbBMjwfpOBN * CLOUhPjbgggWoXHTtmjC; i++) { rSiiAFiHROnqjxqoWutE[i] = 
sFIUeCwGDlfadqOrGZHC[k * CCKWXUFWgrbBMjwfpOBN * CLOUhPjbgggWoXHTtmjC + i]; } for 
(int j = 0; j < CCKWXUFWgrbBMjwfpOBN; j++) for (int i = 0; i < 
CLOUhPjbgggWoXHTtmjC; i++) { sFIUeCwGDlfadqOrGZHC[k * CCKWXUFWgrbBMjwfpOBN * 
CLOUhPjbgggWoXHTtmjC + j * CLOUhPjbgggWoXHTtmjC + i] = rSiiAFiHROnqjxqoWutE[j + i 
* CCKWXUFWgrbBMjwfpOBN]; } } free(rSiiAFiHROnqjxqoWutE); } 
ConvLayerWgtTensor.allocator()->allocate(); std::copy_n((unsigned 
char*)sFIUeCwGDlfadqOrGZHC, rISNTTiSXOTdHqHTtNiB * sizeof(float), (unsigned 
char*)ConvLayerWgtTensor.buffer()); fclose(hKyfKjPACkOBDvLdESxH); free(sFIUeCwGDlfadqOrGZHC); 
return; } void MWConvLayerImpl::loadBias(const char* fDqxEdcpBDmVQxZEmQxm) { 
FILE* hKyfKjPACkOBDvLdESxH; size_t retVal; MWConvLayer* convLayer = 
static_cast<MWConvLayer*>(getLayer()); MWTensor* opTensor = 
convLayer->getOutputTensor(); float* cnEykmOGhLuyKuadExWe = 
(float*)calloc(opTensor->getChannels(), sizeof(float)); char filename[500]; 
sprintf(filename, "%s", fDqxEdcpBDmVQxZEmQxm); hKyfKjPACkOBDvLdESxH = fopen(filename, 
"r"); int rISNTTiSXOTdHqHTtNiB = opTensor->getChannels();  retVal = 
fread(cnEykmOGhLuyKuadExWe, sizeof(float), rISNTTiSXOTdHqHTtNiB, hKyfKjPACkOBDvLdESxH); if 
(retVal != (size_t)rISNTTiSXOTdHqHTtNiB) { 
printf("MWConvLayer::loadBias - File read Failed\n"); } 
ConvLayerBiasTensor.allocator()->allocate(); std::copy_n((unsigned 
char*)cnEykmOGhLuyKuadExWe, rISNTTiSXOTdHqHTtNiB * sizeof(float), (unsigned 
char*)ConvLayerBiasTensor.buffer()); free(cnEykmOGhLuyKuadExWe); 
fclose(hKyfKjPACkOBDvLdESxH); return; } MWReLULayerImpl::MWReLULayerImpl(MWCNNLayer* 
layer, MWTargetNetworkImpl* ntwk_impl, int inPlace) : MWCNNLayerImpl(layer, 
ntwk_impl) { createReLULayer(); } MWReLULayerImpl::~MWReLULayerImpl() { } void 
MWReLULayerImpl::createReLULayer() { MWReLULayer* reluLayer = 
static_cast<MWReLULayer*>(getLayer()); MWTensor* ipTensor = 
reluLayer->getInputTensor(); MWTensor* opTensor = reluLayer->getOutputTensor(); 
Tensor* prevLayerarmTensor = getprevLayerarmTensor(ipTensor); if 
(ipTensor->getWidth() == 1 && ipTensor->getHeight() == 1) { 
armTensor.allocator()->init(TensorInfo( TensorShape((long unsigned 
int)opTensor->getChannels()), 1, DataType::F32, 4)); } else { 
armTensor.allocator()->init( TensorInfo(TensorShape((long unsigned 
int)ipTensor->getWidth(), (long unsigned int)ipTensor->getHeight(), (long 
unsigned int)opTensor->getChannels()), 1, DataType::F32, 4)); } 
ActLayer.configure(prevLayerarmTensor, &armTensor, 
ActivationLayerInfo(ActivationLayerInfo::ActivationFunction::RELU)); return; } 
void MWReLULayerImpl::allocate() { armTensor.allocator()->allocate(); 
setData((float*)armTensor.buffer()); MWReLULayer* reluLayer = 
static_cast<MWReLULayer*>(getLayer()); 
reluLayer->getOutputTensor()->setData((float*)armTensor.buffer()); } void 
MWReLULayerImpl::predict() { MWReLULayer* reluLayer = 
static_cast<MWReLULayer*>(getLayer()); MWTensor* opTensor = 
reluLayer->getOutputTensor(); ActLayer.run();
#if MW_RELU_TAP
 mw_interm_tap((float*)armTensor.buffer(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWReLULayerImpl::cleanup() { } 
MWNormLayerImpl::MWNormLayerImpl(MWCNNLayer* layer, unsigned 
XhAYHFyEVtlwoxGBuTpu, double AVeZfqOFypgpiqfRYlKc, double AdmgfUbRAfzFeYHxSnQr, 
double npaEYSaGsfCvAUhwdtLe, MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, 
ntwk_impl) { createNormLayer(XhAYHFyEVtlwoxGBuTpu, AVeZfqOFypgpiqfRYlKc, 
AdmgfUbRAfzFeYHxSnQr, npaEYSaGsfCvAUhwdtLe); } MWNormLayerImpl::~MWNormLayerImpl() { } void 
MWNormLayerImpl::createNormLayer(unsigned XhAYHFyEVtlwoxGBuTpu, double 
AVeZfqOFypgpiqfRYlKc, double AdmgfUbRAfzFeYHxSnQr, double npaEYSaGsfCvAUhwdtLe) { MWNormLayer* 
normLayer = static_cast<MWNormLayer*>(getLayer()); MWTensor* ipTensor = 
normLayer->getInputTensor(); Tensor* prevLayerarmTensor = 
getprevLayerarmTensor(ipTensor); if (ipTensor->getWidth() == 1 && 
ipTensor->getHeight() == 1) { armTensor.allocator()->init(TensorInfo( 
TensorShape((long unsigned int)ipTensor->getChannels()), 1, DataType::F32, 4)); 
} else { armTensor.allocator()->init( TensorInfo(TensorShape((long unsigned 
int)ipTensor->getWidth(), (long unsigned int)ipTensor->getHeight(), (long 
unsigned int)ipTensor->getChannels()), 1, DataType::F32, 4)); } 
NormLayer.configure(prevLayerarmTensor, &armTensor, 
NormalizationLayerInfo(NormType::CROSS_MAP, XhAYHFyEVtlwoxGBuTpu, 
AVeZfqOFypgpiqfRYlKc, AdmgfUbRAfzFeYHxSnQr, npaEYSaGsfCvAUhwdtLe)); return; } void 
MWNormLayerImpl::allocate() { armTensor.allocator()->allocate(); 
setData((float*)armTensor.buffer()); MWNormLayer* normLayer = 
static_cast<MWNormLayer*>(getLayer()); 
normLayer->getOutputTensor()->setData((float*)armTensor.buffer()); } void 
MWNormLayerImpl::predict() { MWNormLayer* normLayer = 
static_cast<MWNormLayer*>(getLayer()); MWTensor* opTensor = 
normLayer->getOutputTensor(); NormLayer.run();
#if MW_NORM_TAP
 mw_interm_tap((float*)armTensor.buffer(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWNormLayerImpl::cleanup() { for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } MWMaxPoolingLayerImpl::MWMaxPoolingLayerImpl(MWCNNLayer* layer, int 
PoolH, int PoolW, int SAaVvMhQVONvKDErKiaD, int SLkitSJGheTvzxAomUVF, int 
PVBPDNaynqYkBlDZgXgj, int NzudlCvUcxBgCSkidIap, int 
OwortPcLToImGdYFtbSF, int PQjbchiGbyJfmpiqPpOC, bool 
bERCRkGjpaKXMNComoYl, MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, 
ntwk_impl) { assert(!bERCRkGjpaKXMNComoYl); createMaxPoolingLayer(PoolH, 
PoolW, SAaVvMhQVONvKDErKiaD, SLkitSJGheTvzxAomUVF, 
PVBPDNaynqYkBlDZgXgj, NzudlCvUcxBgCSkidIap, OwortPcLToImGdYFtbSF, 
PQjbchiGbyJfmpiqPpOC); } MWMaxPoolingLayerImpl::~MWMaxPoolingLayerImpl() { 
} float* MWMaxPoolingLayerImpl::getIndexData() { assert(false); } void 
MWMaxPoolingLayerImpl::createMaxPoolingLayer(int PoolH, int PoolW, int 
WerBmCOBWhvoFbdqfitc, int WmXADZOqdcQvtBUvFerh, int HgeIbZCtKXtKFOEtSlPZ, int 
GIbahSoBBDrvvZduPEqU, int GLpnVFeGjOSrhNqnkdCu, int HUdjvMUbhwNBNiIGaMZg) { int 
KHjdvykTFbUxdfZTFbqy[2];  MWMaxPoolingLayer* maxPoolLayer = 
static_cast<MWMaxPoolingLayer*>(getLayer()); MWTensor* ipTensor = 
maxPoolLayer->getInputTensor(); MWTensor* opTensor = 
maxPoolLayer->getOutputTensor(); Tensor* prevLayerarmTensor = 
getprevLayerarmTensor(ipTensor); KHjdvykTFbUxdfZTFbqy[0] = 
(HgeIbZCtKXtKFOEtSlPZ + GIbahSoBBDrvvZduPEqU) / 2; KHjdvykTFbUxdfZTFbqy[1] = 
(GLpnVFeGjOSrhNqnkdCu + HUdjvMUbhwNBNiIGaMZg) / 2; 
armTensor.allocator()->init(TensorInfo(TensorShape((long unsigned 
int)opTensor->getWidth(), (long unsigned int)opTensor->getHeight(), (long 
unsigned int)opTensor->getChannels()), 1, DataType::F32, 4)); 
MaxPoolLayer.configure( prevLayerarmTensor, &armTensor, PoolingLayerInfo( 
PoolingType::MAX, PoolH, PadStrideInfo(WmXADZOqdcQvtBUvFerh, WerBmCOBWhvoFbdqfitc, 
KHjdvykTFbUxdfZTFbqy[1], KHjdvykTFbUxdfZTFbqy[0], 
DimensionRoundingType::FLOOR))); return; } void 
MWMaxPoolingLayerImpl::allocate() { armTensor.allocator()->allocate(); 
setData((float*)armTensor.buffer()); MWMaxPoolingLayer* maxPoolLayer = 
static_cast<MWMaxPoolingLayer*>(getLayer()); 
maxPoolLayer->getOutputTensor()->setData((float*)armTensor.buffer()); } void 
MWMaxPoolingLayerImpl::predict() { MWMaxPoolingLayer* maxPoolLayer = 
static_cast<MWMaxPoolingLayer*>(getLayer()); MWTensor* opTensor = 
maxPoolLayer->getOutputTensor(); MaxPoolLayer.run();
#if MW_POOL_TAP
 mw_interm_tap((float*)armTensor.buffer(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWMaxPoolingLayerImpl::cleanup() { for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } MWFCLayerImpl::MWFCLayerImpl(MWCNNLayer* layer, const char* 
tCfVGVGaqfGdJypAKQqq, const char* dAGMlbhOYuZqhuDGCqih, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
createFCLayer(tCfVGVGaqfGdJypAKQqq, dAGMlbhOYuZqhuDGCqih); } 
MWFCLayerImpl::~MWFCLayerImpl() { } void MWFCLayerImpl::createFCLayer(const 
char* tCfVGVGaqfGdJypAKQqq, const char* dAGMlbhOYuZqhuDGCqih) { MWFCLayer* 
fcLayer = static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(); MWTensor* opTensor = fcLayer->getOutputTensor(); 
Tensor* prevLayerarmTensor = getprevLayerarmTensor(ipTensor); 
FcLayerWgtTensor.allocator()->init( TensorInfo(TensorShape((long unsigned 
int)(ipTensor->getHeight() * ipTensor->getWidth() * ipTensor->getChannels()), 
(long unsigned int)(opTensor->getHeight() * opTensor->getWidth() * 
opTensor->getChannels())), 1, DataType::F32, 4)); 
FcLayerBiasTensor.allocator()->init( TensorInfo(TensorShape((long unsigned 
int)(opTensor->getHeight() * opTensor->getWidth() * opTensor->getChannels())), 
1, DataType::F32, 4)); armTensor.allocator()->init(TensorInfo( 
TensorShape((long unsigned int)(opTensor->getHeight() * opTensor->getWidth() * 
opTensor->getChannels() * opTensor->getBatchSize())), 1, DataType::F32, 4)); 
FcLayer.configure(prevLayerarmTensor, &FcLayerWgtTensor, &FcLayerBiasTensor, 
&armTensor); FcLayerWgtTensor.allocator()->allocate(); 
FcLayerBiasTensor.allocator()->allocate(); 
loadWeights(tCfVGVGaqfGdJypAKQqq); loadBias(dAGMlbhOYuZqhuDGCqih); return; } 
void MWFCLayerImpl::loadWeights(const char* fDqxEdcpBDmVQxZEmQxm) { FILE* 
hKyfKjPACkOBDvLdESxH; size_t retVal; MWFCLayer* fcLayer = 
static_cast<MWFCLayer*>(getLayer()); MWTensor* ipTensor = 
fcLayer->getInputTensor(); MWTensor* opTensor = fcLayer->getOutputTensor(); int 
getNumInputFeatures = ipTensor->getHeight() * ipTensor->getWidth() * 
ipTensor->getChannels(); int getNumOutputFeatures = opTensor->getHeight() * 
opTensor->getWidth() * opTensor->getChannels(); float* rMMjgjGRAiLVlTlRSByU = 
(float*)calloc(getNumInputFeatures * getNumOutputFeatures, sizeof(float)); char 
filename[500]; sprintf(filename, "%s", fDqxEdcpBDmVQxZEmQxm); hKyfKjPACkOBDvLdESxH = 
fopen(filename, "r"); int rISNTTiSXOTdHqHTtNiB = getNumInputFeatures * 
getNumOutputFeatures;  retVal = fread(rMMjgjGRAiLVlTlRSByU, sizeof(float), 
rISNTTiSXOTdHqHTtNiB, hKyfKjPACkOBDvLdESxH); if (retVal != (size_t)rISNTTiSXOTdHqHTtNiB) { 
printf("MWFCLayer::loadWeights - File read Failed\n"); } if 
(ipTensor->getHeight() != 1 && ipTensor->getWidth() != 1) { float* 
rSiiAFiHROnqjxqoWutE = (float*)malloc(sizeof(float) * ipTensor->getHeight() * 
ipTensor->getWidth()); for (int k = 0; k < rISNTTiSXOTdHqHTtNiB / 
ipTensor->getHeight() / ipTensor->getWidth(); k++) { for (int i = 0; i < 
ipTensor->getHeight() * ipTensor->getWidth(); i++) rSiiAFiHROnqjxqoWutE[i] = 
rMMjgjGRAiLVlTlRSByU[k * ipTensor->getHeight() * ipTensor->getWidth() + i]; for (int j 
= 0; j < ipTensor->getHeight(); j++) for (int i = 0; i < ipTensor->getWidth(); 
i++) rMMjgjGRAiLVlTlRSByU[k * ipTensor->getHeight() * ipTensor->getWidth() + j * 
ipTensor->getWidth() + i] = rSiiAFiHROnqjxqoWutE[j + i * ipTensor->getHeight()]; } 
free(rSiiAFiHROnqjxqoWutE); } std::copy_n((unsigned char*)rMMjgjGRAiLVlTlRSByU, rISNTTiSXOTdHqHTtNiB 
* sizeof(float), (unsigned char*)FcLayerWgtTensor.buffer()); 
free(rMMjgjGRAiLVlTlRSByU); fclose(hKyfKjPACkOBDvLdESxH); return; } void 
MWFCLayerImpl::loadBias(const char* fDqxEdcpBDmVQxZEmQxm) { FILE* hKyfKjPACkOBDvLdESxH; 
size_t retVal; MWFCLayer* fcLayer = static_cast<MWFCLayer*>(getLayer()); 
MWTensor* opTensor = fcLayer->getOutputTensor(); int getNumOutputFeatures = 
opTensor->getHeight() * opTensor->getWidth() * opTensor->getChannels(); float* 
cAUupmktEnGPfLHyWfFm = (float*)calloc(getNumOutputFeatures, sizeof(float)); char 
filename[500]; sprintf(filename, "%s", fDqxEdcpBDmVQxZEmQxm); hKyfKjPACkOBDvLdESxH = 
fopen(filename, "r"); int rISNTTiSXOTdHqHTtNiB = getNumOutputFeatures;  retVal = 
fread(cAUupmktEnGPfLHyWfFm, sizeof(float), rISNTTiSXOTdHqHTtNiB, hKyfKjPACkOBDvLdESxH); if (retVal 
!= (size_t)rISNTTiSXOTdHqHTtNiB) { 
printf("MWFCLayer::loadBias - File read Failed\n"); } std::copy_n((unsigned 
char*)cAUupmktEnGPfLHyWfFm, rISNTTiSXOTdHqHTtNiB * sizeof(float), (unsigned 
char*)FcLayerBiasTensor.buffer()); free(cAUupmktEnGPfLHyWfFm); fclose(hKyfKjPACkOBDvLdESxH); 
return; } void MWFCLayerImpl::allocate() { armTensor.allocator()->allocate(); 
setData((float*)armTensor.buffer()); MWFCLayer* fcLayer = 
static_cast<MWFCLayer*>(getLayer()); 
fcLayer->getOutputTensor()->setData((float*)armTensor.buffer()); } void 
MWFCLayerImpl::predict() { MWFCLayer* fcLayer = 
static_cast<MWFCLayer*>(getLayer()); MWTensor* opTensor = 
fcLayer->getOutputTensor(); FcLayer.run();
#if MW_FC_TAP
 mw_interm_tap((float*)armTensor.buffer(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWFCLayerImpl::cleanup() { for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } MWSoftmaxLayerImpl::MWSoftmaxLayerImpl(MWCNNLayer* layer, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
createSoftmaxLayer(); } MWSoftmaxLayerImpl::~MWSoftmaxLayerImpl() { } void 
MWSoftmaxLayerImpl::createSoftmaxLayer() { MWSoftmaxLayer* sfmxLayer = 
static_cast<MWSoftmaxLayer*>(getLayer()); MWTensor* ipTensor = 
sfmxLayer->getInputTensor(); MWTensor* opTensor = sfmxLayer->getOutputTensor(); 
Tensor* prevLayerarmTensor = getprevLayerarmTensor(ipTensor); 
armTensor.allocator()->init(TensorInfo(TensorShape((long unsigned 
int)opTensor->getWidth() * (long unsigned int)opTensor->getHeight() * (long 
unsigned int)opTensor->getChannels()), 1, DataType::F32, 4)); 
SoftmaxLayer.configure(prevLayerarmTensor, &armTensor); return; } void 
MWSoftmaxLayerImpl::allocate() { armTensor.allocator()->allocate(); 
setData((float*)armTensor.buffer()); MWSoftmaxLayer* sfmxLayer = 
static_cast<MWSoftmaxLayer*>(getLayer()); 
sfmxLayer->getOutputTensor()->setData((float*)armTensor.buffer()); } void 
MWSoftmaxLayerImpl::predict() { MWSoftmaxLayer* sfmxLayer = 
static_cast<MWSoftmaxLayer*>(getLayer()); MWTensor* opTensor = 
sfmxLayer->getOutputTensor(); SoftmaxLayer.run();
#if MW_SFMX_TAP
 mw_interm_tap(opTensor->getData(), opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth(), tap_count++);
#endif
 return; } void MWSoftmaxLayerImpl::cleanup() { for (int idx = 0; idx < 
getLayer()->getNumOutputs(); idx++) { float* data = 
getLayer()->getOutputTensor(idx)->getData(); if (data) { free(data); } } 
return; } MWAvgPoolingLayerImpl::MWAvgPoolingLayerImpl(MWCNNLayer* layer, int 
IpFhwalnAlrMvcuyQpQD, int VenwEUlYwOBrwLVUhgUH, int WerBmCOBWhvoFbdqfitc, int 
WmXADZOqdcQvtBUvFerh, int DCdZnqpcBnvXVgEsLBnz, int FOcStuqCptsGIZXskVpC, 
MWTargetNetworkImpl* ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { 
createAvgPoolingLayer(IpFhwalnAlrMvcuyQpQD, VenwEUlYwOBrwLVUhgUH, WerBmCOBWhvoFbdqfitc, 
WmXADZOqdcQvtBUvFerh, DCdZnqpcBnvXVgEsLBnz, FOcStuqCptsGIZXskVpC); } 
MWAvgPoolingLayerImpl::~MWAvgPoolingLayerImpl() { } void 
MWAvgPoolingLayerImpl::createAvgPoolingLayer(int IpFhwalnAlrMvcuyQpQD, int 
VenwEUlYwOBrwLVUhgUH, int WerBmCOBWhvoFbdqfitc, int WmXADZOqdcQvtBUvFerh, int 
DCdZnqpcBnvXVgEsLBnz, int FOcStuqCptsGIZXskVpC) { } void 
MWAvgPoolingLayerImpl::allocate() { } void MWAvgPoolingLayerImpl::predict() { 
return; } void MWAvgPoolingLayerImpl::cleanup() { } 
MWOutputLayerImpl::MWOutputLayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl* 
ntwk_impl) : MWCNNLayerImpl(layer, ntwk_impl) { createOutputLayer(); } 
MWOutputLayerImpl::~MWOutputLayerImpl() { } void 
MWOutputLayerImpl::createOutputLayer() { MWOutputLayer* opLayer = 
static_cast<MWOutputLayer*>(getLayer()); MWTensor* ipTensor = 
opLayer->getInputTensor(0); MWTensor* opTensor = opLayer->getOutputTensor(0); 
outputData = (float*)calloc(opTensor->getBatchSize() * opTensor->getChannels() 
* opTensor->getHeight() * opTensor->getWidth(), sizeof(float)); 
setData(outputData); outputArmTensor = 
&ipTensor->getOwner()->getImpl()->armTensor; } void 
MWOutputLayerImpl::allocate() { MWOutputLayer* opLayer = 
static_cast<MWOutputLayer*>(getLayer()); MWTensor* ipTensor = 
opLayer->getInputTensor(0); MWTensor* opTensor = opLayer->getOutputTensor(0); 
if ((outputArmTensor->info()->total_size() / 4) == (opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth())) { 
setData((float*)outputArmTensor->buffer()); } 
opLayer->getOutputTensor()->setData(getData()); } void 
MWOutputLayerImpl::predict() { MWOutputLayer* opLayer = 
static_cast<MWOutputLayer*>(getLayer()); MWTensor* ipTensor = 
opLayer->getInputTensor(0); MWTensor* opTensor = opLayer->getOutputTensor(0); 
if ((outputArmTensor->info()->total_size() / 4) != (opTensor->getBatchSize() * 
opTensor->getChannels() * opTensor->getHeight() * opTensor->getWidth())) { 
fillTensorToIp((unsigned char*)opTensor->getData(), *outputArmTensor); } 
return; } void MWOutputLayerImpl::cleanup() { free(outputData); }