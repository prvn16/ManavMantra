/* Copyright 2017 The MathWorks, Inc. */
#ifndef CNN_API_IMPL
#define CNN_API_IMPL

#include <map>
class MWTensor;
class MWCNNLayer;
class MWTargetNetworkImpl;

#include "arm_compute/runtime/NEON/NEFunctions.h"
#include "arm_compute/core/Types.h"
#include "arm_compute/runtime/SubTensor.h"
#include "arm_compute/core/SubTensorInfo.h"
using namespace arm_compute;

#define MW_LAYERS_TAP 0

#if MW_LAYERS_TAP
#define MW_INPUT_TAP 1
#define MW_CONV_TAP 1
#define MW_RELU_TAP 1
#define MW_NORM_TAP 1
#define MW_POOL_TAP 1
#define MW_FC_TAP 1
#define MW_SFMX_TAP 1
#else
#define MW_INPUT_TAP 0
#define MW_CONV_TAP 0
#define MW_RELU_TAP 0
#define MW_NORM_TAP 0
#define MW_POOL_TAP 0
#define MW_FC_TAP 0
#define MW_SFMX_TAP 0
#endif

class MWCNNLayerImpl {
  public:
    MWCNNLayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl* ntwk_impl);
    virtual ~MWCNNLayerImpl() {
    }
    virtual void predict() {
    }
    virtual void cleanup() {
    }
    virtual void allocate() {
    }
    float* getData() {
        return eqUIJyhXTwRqtPfXapcx;
    }
    void setData(float* data);
    Tensor armTensor; // Ouput of the current layer

    MWCNNLayer* getLayer() {
        return oKIvzXXMucEDsTGGpdpm;
    }
    Tensor* getprevLayerarmTensor(MWTensor*);

  protected:
    MWCNNLayer* oKIvzXXMucEDsTGGpdpm;
    MWTargetNetworkImpl* pvpNsgGssdTxeVoFIkXI;

    float* eqUIJyhXTwRqtPfXapcx;
};

class MWInputLayerImpl : public MWCNNLayerImpl {

  private:
    bool mtolGPkUMBYDlSSqrRzc;
    float* YNmJhGSUszJKxsodxiuV;
    float* inputImage;

    void createInputLayer(int, int, int, int, bool, const char* avg_file_name);
    void loadAvg(const char*, int);
    void allocate();
    void predict();
    void cleanup();

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
};

// Convolution2DWCNNLayer
class MWConvLayerImpl : public MWCNNLayerImpl {
  private:
    int CCKWXUFWgrbBMjwfpOBN;
    int CLOUhPjbgggWoXHTtmjC;
    int CTCbzQMDaLxINPbODdng;

    NEConvolutionLayer ConvLayer;            // used for Convolution/1st half of grouped conv
    NEConvolutionLayer ConvLayerSecondGroup; // used for 2nd half of grouped conv
    Tensor ConvLayerWgtTensor;
    Tensor ConvLayerBiasTensor;
    SubTensor* prevLayer1; // subtensor for current layer input (1st half in grp conv)
    SubTensor* prevLayer2; // subtensor for current layer input (2nd half in grp conv)
    SubTensor* curLayer1;  // subtensor for current layer output (1st half in grp conv)
    SubTensor* curLayer2;  // subtensor for current layer output (2nd half in grp conv)

    SubTensor* ConvLayerWgtMWTensor;  // subtensor for conv weights (1st half in grp conv)
    SubTensor* ConvLayerWgtTensor2;   // subtensor for conv weights (2nd half in grp conv)
    SubTensor* ConvLayerBiasMWTensor; // subtensor for conv bias (1st half in grp conv)
    SubTensor* ConvLayerBiasTensor2;  // subtensor for conv bias (2nd half in grp conv)
    void createConvLayer(int, int, int, int, int, int, const char*, const char*);

    void allocate();
    void predict();
    void cleanup();
    void loadWeights(const char*);
    void loadBias(const char*);

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
};

// ReLULayer
class MWReLULayerImpl : public MWCNNLayerImpl {
  private:
    NEActivationLayer ActLayer;

    void createReLULayer();
    void allocate();
    void predict();
    void cleanup();

  public:
    MWReLULayerImpl(MWCNNLayer*, MWTargetNetworkImpl*, int);
    ~MWReLULayerImpl();
};


// CrossChannelNormalizationLayer
class MWNormLayerImpl : public MWCNNLayerImpl {
  private:
    NENormalizationLayer NormLayer;

    void createNormLayer(unsigned, double, double, double);
    void allocate();
    void predict();
    void cleanup();

  public:
    MWNormLayerImpl(MWCNNLayer*, unsigned, double, double, double, MWTargetNetworkImpl*);
    ~MWNormLayerImpl();
};

// maxpoolingLayer
class MWMaxPoolingLayerImpl : public MWCNNLayerImpl {
  private:
    NEPoolingLayer MaxPoolLayer;

    void createMaxPoolingLayer(int, int, int, int, int, int, int, int);
    void allocate();
    void predict();
    void cleanup();

  public:
    MWMaxPoolingLayerImpl(MWCNNLayer* layer,
                          int,
                          int,
                          int,
                          int,
                          int,
                          int,
                          int,
                          int,
                          bool,
                          MWTargetNetworkImpl*);
    ~MWMaxPoolingLayerImpl();
    float* getIndexData();
};

// FullyConnectedLayer
class MWFCLayerImpl : public MWCNNLayerImpl {
  private:
    NEFullyConnectedLayer FcLayer;
    Tensor FcLayerWgtTensor;
    Tensor FcLayerBiasTensor;

    void createFCLayer(const char*, const char*);
    void loadWeights(const char*);
    void loadBias(const char*);
    void allocate();
    void predict();
    void cleanup();

  public:
    MWFCLayerImpl(MWCNNLayer*, const char*, const char*, MWTargetNetworkImpl*);
    ~MWFCLayerImpl();
};

// SoftmaxLayer
class MWSoftmaxLayerImpl : public MWCNNLayerImpl {
  private:
    NESoftmaxLayer SoftmaxLayer;

    void createSoftmaxLayer();
    void allocate();
    void predict();
    void cleanup();

  public:
    MWSoftmaxLayerImpl(MWCNNLayer*, MWTargetNetworkImpl*);
    ~MWSoftmaxLayerImpl();
};

// AvgPoolingLayer
class MWAvgPoolingLayerImpl : public MWCNNLayerImpl {
  private:
    void createAvgPoolingLayer(int, int, int, int, int, int);
    void allocate();
    void predict();
    void cleanup();

  public:
    MWAvgPoolingLayerImpl(MWCNNLayer* layer, int, int, int, int, int, int, MWTargetNetworkImpl*);
    ~MWAvgPoolingLayerImpl();
};

class MWOutputLayerImpl : public MWCNNLayerImpl {
  private:
    float* outputData;
    Tensor* outputArmTensor;

    void createOutputLayer();
    void allocate();
    void predict();
    void cleanup();

  public:
    MWOutputLayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl*);
    ~MWOutputLayerImpl();
};

#endif
