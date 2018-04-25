/* Copyright 2017 The MathWorks, Inc. */
#ifndef GPUCODER_TRANSPOSEDCONVOLUTIONIMPL_HPP
#define GPUCODER_TRANSPOSEDCONVOLUTIONIMPL_HPP


#include "MWTransposedConvolution2DLayer.hpp"
#include "MWTransposedConvolution2DLayerImpl.hpp"
#include "MWCNNLayerImpl.hpp"
#include "MWTargetNetworkImpl.hpp"
#include "cnn_api.hpp" 

class MWTransposedConvolution2DLayerImpl : public MWCNNLayerImpl
{
  public : 
    MWTransposedConvolution2DLayerImpl(MWCNNLayer*,
                                       int ,
                                       int ,
                                       int ,
                                       int ,
                                       int ,
                                       int ,
                                       int ,
                                       int ,                                
                                       const char* ,
                                       const char* ,
                                       MWTargetNetworkImpl* ); 
										
	
    ~MWTransposedConvolution2DLayerImpl();
    //void createTransposedConvLayer(MWTensor*, int, int, int, int, int, int, int, int, const char*, const char*,, MWTargetNetworkImpl*);
    void createTransposedConv2DLayer(int , int , int , int , const char* , const char* );
	  
    void predict();
    void cleanup();
	
	
	
  private:
    void loadWeights(const char*);
    void loadBias(const char*);
	
    int AwZQzUhuWVLGrWgLHRuM;           //Filter height for CONV and FC
    int AzTsxYcYjIEJsGQbeYHm;            //Filter width for CONV and FC

    int DSsxcjIrUgZCKZovyNQf;
    int CZNYmBcNFSZWvaCklqeM;
    int CpMjJjtGOeWOzwxpAAQP;
    int DqxLTLaJwwgQqmrtCDuu;
	
	
  private:
    cudnnConvolutionDescriptor_t      RqCYCrGsNvzKYrRMXbsI;
    cudnnConvolutionBwdDataAlgo_t     PtkeOkuClHzhOfpmBevf;

    cudnnFilterDescriptor_t           VCbcPxtPsBLTrHYdEvqn;
    cudnnTensorDescriptor_t           NZjOkZPwLzQsdEVkwMcX;

    float* vIWQzNvYZSuxmOTVDFhU;
    float* NDjzAZSYJuWymuKDNZYB;
	
	
};
#endif
