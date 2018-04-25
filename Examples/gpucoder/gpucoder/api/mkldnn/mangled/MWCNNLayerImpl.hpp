/* Copyright 2017 The MathWorks, Inc. */

#ifndef CNN_API_IMPL
#define CNN_API_IMPL

#include <map>
class MWTensor;
class MWCNNLayer;
class MWTargetNetworkImpl;
/*If MW_LAYERS_TAP is enabled, it will tap layer wise output */
#define MW_LAYERS_TAP 0

#if MW_LAYERS_TAP
#define MW_INPUT_TAP 1
#define MW_CONV_TAP 1
#define MW_RELU_TAP 1
#define MW_NORM_TAP 1
#define MW_POOL_TAP 1
#define MW_FC_TAP   1
#define MW_SFMX_TAP 1
#else
#define MW_INPUT_TAP 0
#define MW_CONV_TAP 0
#define MW_RELU_TAP 0
#define MW_NORM_TAP 0
#define MW_POOL_TAP 0
#define MW_FC_TAP   0
#define MW_SFMX_TAP 0
#endif    

class MWCNNLayerImpl
{
  public :
    MWCNNLayerImpl(MWCNNLayer* layer);
    virtual ~MWCNNLayerImpl() {}
    virtual void predict() {}
    virtual void cleanup() {}
    void allocate(){}
    float* getData() { return atVCyzqXZAZxwlkRLBRA; }
    void   setData(float* data) ;

  public:
    MWCNNLayer* getLayer() { return kFQQPKSOkZeHlmrkAXuE; }
    
  protected:
    MWCNNLayer* kFQQPKSOkZeHlmrkAXuE;
    MWTargetNetworkImpl* lHtftnmGBvlSSoGOXVui;       

    float* atVCyzqXZAZxwlkRLBRA;    
  
};

class MWInputLayerImpl  : public MWCNNLayerImpl
{
  private:
    bool gsJtSpgIkTNvahoTFqow;
    float* UWAGLbDcvybdWBtshhsr;

  public:
    MWInputLayerImpl(MWCNNLayer* layer, int, int, int, int, bool,const char* avg_file_name, MWTargetNetworkImpl* ntwk_impl);
    ~MWInputLayerImpl();
    void predict();
    void cleanup();
    
  private:
    void createInputLayer(int, int, int, int, bool,const char* avg_file_name);
    void loadAvg(const char*, int);

         
};

//Convolution2DWCNNLayer
class MWConvLayerImpl : public MWCNNLayerImpl
{   
  private:   

    float* zzWugmJRYlNEuAzHMpeQ;
    float* tqZLvfMHdgZzbchUyDzd;
    float* XNZmftADYzuZnIYIpBaT;
    float* uOjfVTZSbCZATdZVDwrL;
    float* fXhhiexIRPLyKXApPmmy;
    float  gWETwFdWHfKuelmlKNCC;
    int CqtPRJvHlGJFssiPzsOm[2];         
    int ClEhcJFlvGCgiavziIag; 
    int BlRIQPyqJZORKENzSdYf; 
    int BuyZFXzwOMxcePIbCLfl; 
    int CDJtexcMbXMWAmnNZsNf; 
		
    float *wvufwFZlsnpjbxmTBVYE;
    float *YCSvyQZBWMDYQXHtyVai;
    float *fylVqSnTjNbHDtlPhzaj;
    float *muwRQxtWMMXAPxSuMYBw;

    bool NonAlignFlag;
		

  public:
    int CufLFODQDXTAPyRqYodN;           // Filter height for CONV and FC
    int DRzwhbNPpftRRIXXfHzd;            // Filter width for CONV and FC
    int FwLnexHgxHRquTKmNpoa;
    int FpguQZSermqZCMRiUfML;
    int FshVHIJMRAhtQirYPlZd;
		
  public:
        
    MWConvLayerImpl(MWCNNLayer*,int, int, int, int, int,  int, int, int, int, int, int, const char*, const char*, MWTargetNetworkImpl*);
    ~MWConvLayerImpl();

    void createConvLayer(int, int, int, int, int, int, const char*, const char*);
    void predict();
    void cleanup();
    
  private:
    void loadWeights(const char*);
    void loadBias(const char*);
};
    
//ReLULayer
class MWReLULayerImpl: public MWCNNLayerImpl
{
  public:
    
    MWReLULayerImpl(MWCNNLayer*, MWTargetNetworkImpl*, int);
    ~MWReLULayerImpl();

    void createReLULayer();
    void predict();
    void cleanup();
    
  private:
    int fSbUUBgjKRbNXrHrlOLo;
};


//CrossChannelNormalizationLayer
class MWNormLayerImpl: public MWCNNLayerImpl
{
  public:
    MWNormLayerImpl(MWCNNLayer*, unsigned, double, double, double,MWTargetNetworkImpl* );
    ~MWNormLayerImpl();

    double FLuSVNoPhAFKtLUchSvv;           
    double FeVcBgtQmTLtmnNcJGMY;            
    int EvebzoroiuKkIxwjkGnD;          

    void createNormLayer( unsigned, double, double);
    void predict();
    void cleanup();
};

class MWMaxPoolingLayerImpl: public MWCNNLayerImpl
{
  public:
    MWMaxPoolingLayerImpl(MWCNNLayer*, int, int, int, int, int, int, int, int, bool, MWTargetNetworkImpl*);
    ~MWMaxPoolingLayerImpl();

    int RVrPByQXdKmunRZHKWJD[2];         // Stride for MaxPool 
    int QhTWatiCfcWYsHdkcyhZ;          // Top Padding for MaxPool 
    int OzygUJRIZYnGLzSjgahB;          // Bottom Padding for MaxPool
    int PfisSEEWDaQFynnzlcin;          // Left Padding for MaxPool
    int PtRNGuserCxHAQfyEjFc;          // Right Padding for MaxPool
    int NmExSIssnXpisMKKatUq;             
    int THfVbcZJtANcLKxEriuV;              
		
    void createMaxPoolingLayer(int, int, int, int, int, int, int, int);
    void predict();
    void cleanup();
    float* getIndexData();
   

};

//FullyConnectedLayer
class MWFCLayerImpl: public MWCNNLayerImpl
{
  private:
    int CufLFODQDXTAPyRqYodN;
    int DRzwhbNPpftRRIXXfHzd;
    float* tqZLvfMHdgZzbchUyDzd;
    float* XNZmftADYzuZnIYIpBaT;

  public:
    MWFCLayerImpl(MWCNNLayer*, const char*, const char*, MWTargetNetworkImpl*);
    ~MWFCLayerImpl();
		
       
    void createFCLayer(const char*, const char*);
    void predict();
    void cleanup();
  private: 
    void loadWeights(const char*);
    void loadBias(const char*);

};

//SoftmaxLayer
class MWSoftmaxLayerImpl: public MWCNNLayerImpl
{
  public:
    MWSoftmaxLayerImpl(MWCNNLayer*, MWTargetNetworkImpl*);
    ~MWSoftmaxLayerImpl();

    void createSoftmaxLayer();
    void predict();
    void cleanup();

};
//AvgPooling2DLayer
class MWAvgPoolingLayerImpl: public MWCNNLayerImpl
{
  public:
    MWAvgPoolingLayerImpl(MWCNNLayer*, int, int, int, int, int, int, MWTargetNetworkImpl*);
    ~MWAvgPoolingLayerImpl();

    int RVrPByQXdKmunRZHKWJD[2];         // Stride for AvgPool 
    int OiVqrkNdXioJhALWMMvm[2];         // Padding for AvgPool
    int NmExSIssnXpisMKKatUq;             
    int THfVbcZJtANcLKxEriuV;              
		
    void createAvgPoolingLayer(int, int, int, int, int, int);
    void predict();
    void cleanup();
};
class MWOutputLayerImpl : public MWCNNLayerImpl {
  public:
    MWOutputLayerImpl(MWCNNLayer*, MWTargetNetworkImpl*);
    ~MWOutputLayerImpl();
    void predict();
    void cleanup();
    void createOutputLayer();
};

#endif
