/**
 * @file HostLib_MMFile.h
 * @brief Helper for the To/FromMMFile block.
 * Copyright 2008-2016 The MathWorks, Inc.
 */ 

#ifndef HOSTLIB_MMFILE_H_
#define HOSTLIB_MMFILE_H_

/* Wrap everything in extern C */
#ifdef __cplusplus
extern "C" {
#endif 

extern const char *libName_FromMMFile;
extern const char *libName_ToMMFile;

#include "VideoDefs.hpp"
#include "AudioDefs.hpp"
  
/*******************************
 * Routines which are defined in the library in question
 *******************************/
typedef void* (*pFnLibCreate_FromMMFile)(char *err, char *warn, const void *fileName, unsigned int fromCG, const char *pluginPaths, const char* arConverterPath,
                                         MMAudioInfo* aInfo, MMVideoInfo* vInfo, 
                                         unsigned int numRepeats, unsigned char loopIndef, 
                                         FourCCType fourcc,
                                         unsigned char scaledDoubleAudio, unsigned char scaledDoubleVideo, unsigned char isHwAccel);

typedef void (*pFnLibOutputs_FromMMFile)(void *hostLib, char *err, unsigned char *bDone, void *audio, void *R, void *G, void *B);


typedef void* (*pFnLibCreate_ToMMFile)(char *err, char *warn, const void *fileName, unsigned int fromCG, MMFileType fileType,
                                        MMAudioInfo* aInfo, MMVideoInfo* vInfo,
                                        unsigned char scaledDoubleAudio, unsigned char scaledDoubleVideo,
                                        char* awPluginPath, char* awConverterPath, char* awFilterPath,
                                        unsigned int imageQuality, unsigned int mj2000CompFactor );
typedef void (*pFnLibUpdate_ToMMFile)(void *hostLib, char *err, const void *audio, const void *R, const void *G, const void *B);


/*******************************
 * Routines which we define to call the functions in the library 
 *******************************/
void LibCreate_FromMMFile(void *hostLib, char *warn, const void *fileName, unsigned int fromCG, const char *pluginPaths, const char* arConverterPath,
                          void* aInfo, void* vInfo, 
                          unsigned int numRepeats, unsigned char loopIndef, 
                          int fourcc,
                          unsigned char scaledDoubleAudio, unsigned char scaledDoubleVideo, unsigned char isHwAccel);
void LibOutputs_FromMMFile(void *hostLib, void *bDone, void *audio, void *R, void *G, void *B);


void LibCreate_ToMMFile(void *hostLib, char *warn, const void *fileName, unsigned int fromCG, int fileType,
                         void* aInfo, void* vInfo,
                         unsigned char scaledDoubleAudio, unsigned char scaledDoubleVideo,
                         char* awPluginPath, char* awConverterPath, char* awFilterPath, 
                         unsigned int imageQuality, unsigned int mj2000CompFactor );
void LibUpdate_ToMMFile(void *hostLib, const void *audio, const void *R, const void *G, const void *B);


/* Include for declarations of LibStart, LibTerminate, CreateHostLibrary, and DestroyHostLibrary. */
#include "HostLib_rtw.h"


#ifdef __cplusplus
} // extern "C"
#endif 

#endif 

