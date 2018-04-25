/* Copyright 2017 The MathWorks, Inc. */

#ifndef CNN_API_IMPL
#define CNN_API_IMPL

#include <cudnn.h>
#include <cublas_v2.h>
#include <map>
class MWTensor;
class MWCNNLayer;
class MWTargetNetworkImpl;

#define CUDA_CALL(status) cuda_call_line_file(status,__LINE__,__FILE__)
#define MALLOC_CALL(msize) malloc_call_line_file(msize,__LINE__,__FILE__)
#define CUDNN_CALL(status) cudnn_call_line_file(status,__LINE__,__FILE__)
#define CUBLAS_CALL(status) cublas_call_line_file(status,__LINE__,__FILE__)

//#define RANDOM
#ifdef RANDOM
#include <curand.h>
#define CURAND_CALL(status) curand_call_line_file(status,__LINE__,__FILE__)
#endif

void cuda_call_line_file(cudaError_t, const int, const char *);
void cudnn_call_line_file(cudnnStatus_t, const int, const char *);
float* malloc_call_line_file(size_t, const int, const char *);
const char* cublasGetErrorString(cublasStatus_t);
void cublas_call_line_file(cublasStatus_t, const int, const char *);
void call_cuda_free(float* mem);
void call_malloc(float* mem);

#ifdef RANDOM
void curand_call_line_file(curandStatus_t, const int, const char *);
#endif


class MWCNNLayerImpl
{
  public :
    
    MWCNNLayerImpl(MWCNNLayer* layer, MWTargetNetworkImpl* ntwk_impl);        
    virtual ~MWCNNLayerImpl() {}
    virtual void predict() = 0;
    virtual void cleanup() = 0;
    void allocate(){}
    float* getData() { return REXdEoRjxuQJkqgIDihy; }
    MWCNNLayer* getLayer() { return eybNKlJCSDUvsznWynwK; }    
    
  protected:
    
    MWCNNLayer* eybNKlJCSDUvsznWynwK;
    std::map<int, cudnnTensorDescriptor_t*> lWJYwWaFPmWNQDPrlqER; // output descriptor
    MWTargetNetworkImpl* gzSTokDHvkXefhiGDcWL;       

    float TxNFOfYScyqGlEFFxbAv;
    float SGsAudmgjmvcUXzzrUtf;
    float SDWKEQTZaTFZByPlzUDR;
    float* REXdEoRjxuQJkqgIDihy;      

    float* getZeroPtr();            // Get the pointer to a zero value parameter
    float* getOnePtr();             // Get the pointer to a one value parameter
    float* getNegOnePtr();          // Get the pointer to a negative one value parameter

    // Get the cuDNN  descriptor for the output 
    cudnnTensorDescriptor_t* getOutputDescriptor(int index = 0);
    bool hasOutputDescriptor(int index = 0) const;
    
    // get Descriptor from a tensor
    cudnnTensorDescriptor_t* getCuDNNDescriptor(MWTensor* tensor);
        
    void setData(float* data) {
        REXdEoRjxuQJkqgIDihy = data;
    }    
};

class MWInputLayerImpl  : public MWCNNLayerImpl
{
  private:
    bool   euppfEoiaoCTcVgRPVhA;
    float* JwxFdqOKggeawILBfGgg;

  public:
    MWInputLayerImpl(MWCNNLayer* layer, int, int, int, int, bool, const char* avg_file_name, MWTargetNetworkImpl* ntwk_impl);
    ~MWInputLayerImpl();
    void predict();
    void cleanup();
    
  private:
    void createInputLayer(int, int, int, int, bool, const char* avg_file_name);
    void loadAvg(const char*, int);

  private:
    cudnnTensorDescriptor_t       MdSWZSOAjugbWppryHbR;
         
};

//Convolution2DWCNNLayer
class MWConvLayerImpl : public MWCNNLayerImpl
{   
  public:
    int AwZQzUhuWVLGrWgLHRuM;           //Filter height for CONV and FC
    int AzTsxYcYjIEJsGQbeYHm;            //Filter width for CONV and FC

    int DSsxcjIrUgZCKZovyNQf;
    int CZNYmBcNFSZWvaCklqeM;
    int CpMjJjtGOeWOzwxpAAQP;

  private:   

    float* xkUNToJIgvoLoUQuzKRF;
    float* vIWQzNvYZSuxmOTVDFhU;
    float* NDjzAZSYJuWymuKDNZYB;
    float* veFyKKHbdqBIvQLYBqfF;
    MWTensor* ZDWLzHUkuZuIUZHfbGDY; // for pre-padded input
    float* dJcdBfQQLhIAYHPxwQeg;
    float  eqOmMKQRpqBqRQCnJmxt;
    int fSKMHAqIghbYYgyIpNDw;
    int fhikqqlnUKCjleVKDqiG;

  public:
    
    MWConvLayerImpl(MWCNNLayer*, int, int, int, int, int,  int, int, int, int, int, int, const char*, const char*, MWTargetNetworkImpl*);
    ~MWConvLayerImpl();

    void createConvLayer(int, int, int, int, int, int, const char*, const char*);
    void predict();
    void cleanup();
    void setOutput2(float*); // Set the pointer to the second half of the output for grouped convolution
    float* getOutput2();     // Get the pointer to the second half of the output for grouped convolution
    cudnnTensorDescriptor_t* getGroupDescriptor(); // Get the cuDNN descriptor of the output for grouped convolution

    // xxx tbd
    float  getIsGrouped();          // Get the isGrouped parameter
    void   setIsGrouped(float);     // Set the isGrouped parameter
    
  private:
    void loadWeights(const char*);
    void loadBias(const char*);
    void getConvAlgoWithWorkSpace();
    void getConvAlgoNoWorkSpace();
		
  private:
    cudnnConvolutionDescriptor_t  QMgBqCuvjnbWHWiVPEwn;
    cudnnConvolutionFwdAlgo_t     PmFfARVzoHVAYkfpuvqK;

    cudnnFilterDescriptor_t       VCbcPxtPsBLTrHYdEvqn;
    cudnnTensorDescriptor_t       NZjOkZPwLzQsdEVkwMcX;

    cudnnTensorDescriptor_t       enPbWLzEmxYCBmzGJutZ;
    cudnnTensorDescriptor_t       XVcMnvCXvZpKICKIjgZi;

    cudnnTensorDescriptor_t      eFaDPmxDdzHlRYSAoMmX;

};
    
//ReLULayer
class MWReLULayerImpl: public MWCNNLayerImpl
{
    public:
        MWReLULayerImpl(MWCNNLayer* , MWTargetNetworkImpl*, int );
        ~MWReLULayerImpl();

        void createReLULayer();
        void predict();
        void cleanup();

    private:
        cudnnActivationDescriptor_t   npGnQZLrEfVTQnEbwqij;
        int aLsOwwcceEmRSYzllBNs;
};
    
class MWNormLayerImpl: public MWCNNLayerImpl
{
  public:
    MWNormLayerImpl(MWCNNLayer* , unsigned, double, double, double, MWTargetNetworkImpl*);
    ~MWNormLayerImpl();

    void createNormLayer(unsigned, double, double, double );
    void predict();
    void cleanup();

   
  private:        
    cudnnLRNDescriptor_t          gTcJMwtYuwiqqUmqvKhT;
};

//MaxPooling2DLayer
class MWMaxPoolingLayerImpl: public MWCNNLayerImpl
{
  public:
    //Create MaxPooling2DLayer with PoolSize = [ PoolH PoolW ]
    //                                Stride = [ StrideH StrideW ]
    //                               Padding = [ PaddingH_T PaddingH_B PaddingW_L PaddingW_R ]
    MWMaxPoolingLayerImpl(MWCNNLayer *, int, int, int, int, int, int, int, int, bool, MWTargetNetworkImpl*);
    ~MWMaxPoolingLayerImpl();
  
    void predict();
    void cleanup();
    float* getIndexData();
    
  private:

    void createMaxPoolingLayer(int, int, int, int, int, int, int, int );
    
  private:
    
    bool BLjrjqvCcCommiXWQLjs;
    float* cQBKlCKXxecGPJrXBXdk;
    float* SIBpKtDURUWQaaenbwrC;
    float* cCXqPFPPcoHzYMDpnUxQ;
    cudnnPoolingDescriptor_t lteHjcLsItGbVPMQtGDB;    
    int fYaOQTeunPwVjnhhTECh;
    int fjfzkUfcCOqjrkAVGfuc;
};

//FullyConnectedLayer
class MWFCLayerImpl: public MWCNNLayerImpl
{
    private:
        int AwZQzUhuWVLGrWgLHRuM;
        int AzTsxYcYjIEJsGQbeYHm;
        int DqxLTLaJwwgQqmrtCDuu;
        float* vIWQzNvYZSuxmOTVDFhU;
        float* NDjzAZSYJuWymuKDNZYB;

    public:
        MWFCLayerImpl(MWCNNLayer*, const char*, const char*, MWTargetNetworkImpl*);
        ~MWFCLayerImpl();
		
        void createFCLayer(const char*, const char*);
        void predict();
        void cleanup();

    private:
    
        void loadWeights(const char*);
        void loadBias(const char*);

    private:
        cudnnTensorDescriptor_t       NZjOkZPwLzQsdEVkwMcX;
};

//SoftmaxLayer
class MWSoftmaxLayerImpl: public MWCNNLayerImpl
{
    public:
        MWSoftmaxLayerImpl(MWCNNLayer* , MWTargetNetworkImpl*);
        ~MWSoftmaxLayerImpl();

        void createSoftmaxLayer();
        void predict();
        void cleanup();

    private:
        cudnnLRNDescriptor_t          gTcJMwtYuwiqqUmqvKhT;
};

//AvgPooling2DLayer
class MWAvgPoolingLayerImpl : public MWCNNLayerImpl
{
    public:
        MWAvgPoolingLayerImpl(MWCNNLayer* ,int, int, int, int, int, int, MWTargetNetworkImpl*);
        ~MWAvgPoolingLayerImpl();

        void createAvgPoolingLayer(int, int, int, int, int, int);
        void predict();
        void cleanup();

    private:
        cudnnPoolingDescriptor_t      lteHjcLsItGbVPMQtGDB;
};

class MWOutputLayerImpl : public MWCNNLayerImpl {
  public:
    MWOutputLayerImpl(MWCNNLayer*, MWTargetNetworkImpl*);
    ~MWOutputLayerImpl();
    void createOutputLayer();
    void predict();
    void cleanup();
};
#endif
