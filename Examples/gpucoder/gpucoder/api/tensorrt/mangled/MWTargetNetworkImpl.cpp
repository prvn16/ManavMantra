#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp"
#include "MWCNNLayerImpl.hpp"
#include <iostream>
#include <cassert>
#if INT8_ENABLED 
#include <fstream>
#include <iterator>
#include "MWBatchStream.hpp"
#endif
 using namespace nvinfer1; using namespace nvcaffeparser1; void 
CHECK(cudaError_t status) { if (status != 0) { std::cout << "Cuda failure: " << 
status; abort(); } } class Logger : public ILogger { void log(Severity 
severity, const char* msg) override { if (severity != Severity::kINFO) { 
std::cout << msg << std::endl; } } } gLogger;
#if INT8_ENABLED 
 std::string gvalidDatapath;  void getValidDataPath(const char* fileName, char 
*validDatapath) { FILE* fp = fopen(fileName, "rb"); if (!fp) {
#if defined(_WIN32) || defined(_WIN64)
 char delim[] = "\\";
#else
 char delim[] = "/";
#endif
 std::string fileS(fileName); size_t pos = 0; while((pos = fileS.find(delim)) 
!= std::string::npos) { if (pos == (fileS.size() - 1)) { fileS = ""; break; } 
fileS = fileS.substr(pos+1); fp = fopen(fileS.c_str(), "rb");  if(fp != NULL)  
{ fclose(fp); strcpy(validDatapath, fileS.c_str()); gvalidDatapath = 
fileS.substr(0,fileS.find_last_of("/\\")); break; } else{ strcpy(validDatapath, 
fileName); } } } else { fclose(fp); strcpy(validDatapath, fileName); 
gvalidDatapath =validDatapath; gvalidDatapath = 
gvalidDatapath.substr(0,gvalidDatapath.find_last_of("/\\")); } }
#endif
 void doInference(IExecutionContext& context, float* input, float* output, int 
batchSize) { const ICudaEngine& engine = context.getEngine(); 
assert(engine.getNbBindings() == 2); void* buffers[2]; int inputIndex = 
engine.getBindingIndex("data"), outputIndex = engine.getBindingIndex("prob"); 
cudaStream_t stream; CHECK(cudaStreamCreate(&stream)); buffers[inputIndex] = 
input; buffers[outputIndex] = output; context.enqueue(batchSize, buffers, 
stream, nullptr); cudaStreamSynchronize(stream); cudaStreamDestroy(stream); } 
void MWTargetNetworkImpl::preSetup() { iFWfUCwhmxBsOTMvFHgz = new 
cudnnHandle_t; cudnnCreate(iFWfUCwhmxBsOTMvFHgz); builder = 
createInferBuilder(gLogger); network = builder->createNetwork(); } void 
MWTargetNetworkImpl::postSetup() {
#if INT8_ENABLED 
 int trainBatchCount=0;  while(1) { char filename[500]; char filename1[500];
#if defined(_WIN32) || defined(_WIN64)
 sprintf(filename,"|>targetdirwindows<|\\tensorrt\\batch%d",trainBatchCount++);
#else
 sprintf(filename,"|>targetdir<|/tensorrt/batch%d",trainBatchCount++);
#endif
 getValidDataPath(filename,filename1); FILE *fp = fopen(filename1,"rb"); 
if(fp==NULL) { trainBatchCount-=1; break; } fclose(fp); } BatchStream 
calibrationStream(batchSize, trainBatchCount);  Int8EntropyCalibrator 
calibrator(calibrationStream, 0); builder->setAverageFindIterations(1); 
builder->setMinFindIterations(1); builder->setDebugSync(true); 
builder->setInt8Mode(1); builder->setInt8Calibrator(&calibrator);
#endif
 builder->setMaxBatchSize(batchSize);  builder->setMaxWorkspaceSize(1 << 30); 
engine = builder->buildCudaEngine(*network); context = 
engine->createExecutionContext(); network->destroy(); builder->destroy(); } 
float* MWTargetNetworkImpl::getWorkSpace() { return yeRJnYjpvmkKjBpyWlaV; } 
cudnnHandle_t* MWTargetNetworkImpl::getCudnnHandle() { return 
iFWfUCwhmxBsOTMvFHgz; } void MWTargetNetworkImpl::predict(CnnMain* 
CnnMainClass) { float *input = 
CnnMainClass->layers[0]->getOutputTensor(0)->getData(); float *output = 
CnnMainClass->outputData; CnnMainClass->layers[0]->predict(); 
doInference(*context, input, output, batchSize); } void 
MWTargetNetworkImpl::cleanup() { if (yeRJnYjpvmkKjBpyWlaV) { 
cudaFree(yeRJnYjpvmkKjBpyWlaV); } if (iFWfUCwhmxBsOTMvFHgz) { 
cudnnDestroy(*iFWfUCwhmxBsOTMvFHgz); } context->destroy(); 
engine->destroy(); }