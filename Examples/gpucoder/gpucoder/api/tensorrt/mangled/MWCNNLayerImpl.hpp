/* Copyright 2017 The MathWorks, Inc. */

#ifndef CNN_API_IMPL
#define CNN_API_IMPL

#include <cudnn.h>
#include <map>

/* TensorRT related header files */
#include "NvInfer.h"
#include "NvCaffeParser.h"
#include "cuda_runtime_api.h"

using namespace nvinfer1;
using namespace nvcaffeparser1;

class MWTensor;
class MWCNNLayer;
class MWTargetNetworkImpl;

#define CUDA_CALL(status) cuda_call_line_file(status, __LINE__, __FILE__)
#define CUDNN_CALL(status) cudnn_call_line_file(status, __LINE__, __FILE__)

//#define RANDOM
#ifdef RANDOM
#include <curand.h>
#define CURAND_CALL(status) curand_call_line_file(status, __LINE__, __FILE__)
#endif

void cuda_call_line_file(cudaError_t, const int, const char*);
void cudnn_call_line_file(cudnnStatus_t, const int, const char*);
void call_cuda_free(float* mem);
#ifdef RANDOM
void curand_call_line_file(curandStatus_t, const int, const char*);
#endif


class MWCNNLayerImpl {
  public:
    MWCNNLayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl*);
    virtual ~MWCNNLayerImpl() {
    }
    virtual void predict();
    virtual void cleanup();
    void allocate(){}
    float* getData() {
        return iMyHYqdPsEjdhQptHQNt;
    }
    MWCNNLayer* getLayer() {
        return pdleXafalaHAmketaFyq;
    }

    ITensor* getOpTensorPtr();     // Get the previous layer output pointer
  protected: 
    MWCNNLayer* pdleXafalaHAmketaFyq;
    std::map<int, cudnnTensorDescriptor_t*> rrWNoFNRUEdlTvIOmCla; // output descriptor
    MWTargetNetworkImpl* rIcMzXptfYweLArNRnBw;
    ITensor* KZWeXiYFmdpQdsgidKeG;

    float jfkhqXBmwICFStMidrQt;
    float jHzoRQWaHafftmrmuvHO;
    float jHaoHEqZgMiwRsdCogKz;
    float* iMyHYqdPsEjdhQptHQNt;

    cudnnTensorDescriptor_t* getOutputDescriptor(
        int index = 0); // Get the cuDNN tensor descriptor for the output
    cudnnTensorDescriptor_t* getCuDNNDescriptor(MWTensor* tensor); // get Descriptor from a tensor

    float* getZeroPtr();   // Get the pointer to a zero value parameter
    float* getOnePtr();    // Get the pointer to a one value parameter
    float* getNegOnePtr(); // Get the pointer to a negative one value parameter

    void setOpTensorPtr(ITensor*); // Set the Output tensor pointer
	ITensor* getprevLayerTensor(MWTensor*);//Get the previous layer tensor
};

class MWInputLayerImpl : public MWCNNLayerImpl {

  public:
    MWInputLayerImpl(MWCNNLayer* layer,
                     int,
                     int,
                     int,
                     int,
                     bool,
                     const char* avg_file_name,
                     MWTargetNetworkImpl* ntwk_impl);
    ~MWInputLayerImpl();

  private:
    void predict();
    void cleanup();

    void createInputLayer(int, int, int, int, bool, const char* avg_file_name);
    void loadAvg(const char*, int);

    cudnnTensorDescriptor_t cwCXkgHfZmFQRzNVUlCO;
    bool pbePKOGQbvmzToFbiRkR;
    float* bLhHPDtQpqOAnMiVledO;
    ITensor* InputLayerITensor;
};

// Convolution2DWCNNLayer
class MWConvLayerImpl : public MWCNNLayerImpl {
  public:




    MWConvLayerImpl(MWCNNLayer*,
                    int,
                    int,
                    int,
                    int,
                    int,
                    int,
                    int,
                    int,
                    int,
                    int,
                    int,
                    const char*,
                    const char*,
                    MWTargetNetworkImpl*);
    ~MWConvLayerImpl();

  private:
    int GbdgxISzcqHOpzQEBrvP; // Filter height for CONV and FC
    int JABfZsGuaCAmcRcqOYEO;  // Filter width for CONV and FC
    int JxwPQNPACGfmGpNncpCY;
    void createConvLayer(int, int, int, int, int, int,const char*, const char*);
    void cleanup();

    float* wqggPBXZvtlxnxwngvAq;
    float* eUSuiwvLvXVXrpUkgBVu;
    void loadWeights(const char*);
    void loadBias(const char*);
    IConvolutionLayer* ConvLayerT;
    Weights filt_weights;
    Weights filt_bias;
};

// ReLULayer
class MWReLULayerImpl : public MWCNNLayerImpl {
  public:
    MWReLULayerImpl(MWCNNLayer*, MWTargetNetworkImpl*, int);
    ~MWReLULayerImpl();

  private:
    IActivationLayer* ReLULayer;
    void createReLULayer();
};

class MWNormLayerImpl : public MWCNNLayerImpl {
  public:
    MWNormLayerImpl(MWCNNLayer*, unsigned, double, double, double, MWTargetNetworkImpl*);
    ~MWNormLayerImpl();

  private:
    ILRNLayer* NormLayer;
    void createNormLayer(unsigned, double, double, double);
};

// MaxPooling2DLayer
class MWMaxPoolingLayerImpl : public MWCNNLayerImpl {
  public:
    MWMaxPoolingLayerImpl(MWCNNLayer*, int, int, int, int, int, int, int, int, bool, MWTargetNetworkImpl*);
    ~MWMaxPoolingLayerImpl();

    float* getIndexData();
  private:
    IPoolingLayer* MaxPoolingLayer;
    void createMaxPoolingLayer(int, int, int, int, int, int, int, int);
};

// FullyConnectedLayer
class MWFCLayerImpl : public MWCNNLayerImpl {
  public:
    MWFCLayerImpl(MWCNNLayer*, const char*, const char*, MWTargetNetworkImpl*);
    ~MWFCLayerImpl();
  private:
    float* wqggPBXZvtlxnxwngvAq;
    float* eUSuiwvLvXVXrpUkgBVu;

    IFullyConnectedLayer* FCLayer;
    Weights filt_weights;
    Weights filt_bias;

    void loadWeights(const char*);
    void loadBias(const char*);
    void createFCLayer(const char*, const char*);
    void cleanup();

};

// SoftmaxLayer
class MWSoftmaxLayerImpl : public MWCNNLayerImpl {
  public:
    MWSoftmaxLayerImpl(MWCNNLayer*, MWTargetNetworkImpl*);
    ~MWSoftmaxLayerImpl();

  private:
    ISoftMaxLayer* SoftmaxLayer;
    void createSoftmaxLayer();
};

// SoftmaxLayer
class MWOutputLayerImpl : public MWCNNLayerImpl {
  public:
    MWOutputLayerImpl(MWCNNLayer*, MWTargetNetworkImpl*);
    ~MWOutputLayerImpl();

  private:
    void createOutputLayer();
    void cleanup();
};

// AvgPooling2DLayer
class MWAvgPoolingLayerImpl : public MWCNNLayerImpl {
  public:
    MWAvgPoolingLayerImpl(MWCNNLayer*, int, int, int, int, int, int, MWTargetNetworkImpl*);
    ~MWAvgPoolingLayerImpl();

  private:
    IPoolingLayer* AvgPoolingLayer;
    void createAvgPoolingLayer(int, int, int, int, int, int);
};

#endif
