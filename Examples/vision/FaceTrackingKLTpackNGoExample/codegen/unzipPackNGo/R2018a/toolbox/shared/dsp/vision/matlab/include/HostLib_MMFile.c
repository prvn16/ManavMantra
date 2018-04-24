/**
 * @file HostLib_MMFile.c
 * @brief Helper for To/FromMMFile block
 * Copyright 2007-2015 The MathWorks, Inc.
 */ 

#include "HostLib_MMFile.h"
#include <string.h>
#include <stdio.h>


#if defined(_WIN32)
const char *libName_FromMMFile = "frommmfile.dll";
const char *libName_ToMMFile   = "tommfile.dll";
#elif defined(__APPLE__)
const char *libName_FromMMFile = "libmwfrommmfile.dylib";
const char *libName_ToMMFile   = "libmwtommfile.dylib";
#else
const char *libName_FromMMFile = "libmwfrommmfile.so";
const char *libName_ToMMFile   = "libmwtommfile.so";
#endif


void LibCreate_FromMMFile(void *hl, char *warn, const void *fileName, unsigned int fromCG, const char *pluginPaths, const char* arConverterPath,
                          void *aInfo, void *vInfo, 
                          unsigned int numRepeats, unsigned char loopIndef, 
                          int fourcc,
                          unsigned char scaledDoubleAudio, unsigned char scaledDoubleVideo, unsigned char isHwAccel) 
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    *hostLib->errorMessage  = '\0';
    if(warn)
        *warn = '\0';
    hostLib->instance = (MAKE_FCN_PTR(pFnLibCreate_FromMMFile,hostLib->libCreate))(hostLib->errorMessage, warn, fileName, fromCG, pluginPaths, arConverterPath,
                                                                                   (MMAudioInfo*) aInfo, (MMVideoInfo*) vInfo,
                                                                                   numRepeats, loopIndef, (FourCCType)fourcc, scaledDoubleAudio, scaledDoubleVideo, isHwAccel);
}

void LibOutputs_FromMMFile(void *hl, void *bDone, void *audio, void *R, void *G, void *B)
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    if(hostLib->instance)
        (MAKE_FCN_PTR(pFnLibOutputs_FromMMFile,hostLib->libOutputs))(hostLib->instance, hostLib->errorMessage, (unsigned char *) bDone, audio, R, G, B);
}

void LibCreate_ToMMFile(void *hl, char *warn, const void *fileName, unsigned int fromCG, int fileType,
                         void *aInfo, void *vInfo,
                         unsigned char scaledDoubleAudio, unsigned char scaledDoubleVideo,
                         char* awPluginPath, char* awConverterPath, char* awFilterPath, 
                         unsigned int imageQuality, unsigned int mj2000CompFactor )
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    *hostLib->errorMessage  = '\0';
    if(warn)
        *warn = '\0';
    hostLib->instance = (MAKE_FCN_PTR(pFnLibCreate_ToMMFile,hostLib->libCreate))( hostLib->errorMessage, warn, fileName, fromCG, (MMFileType) fileType,
                                                                                  (MMAudioInfo*) aInfo, (MMVideoInfo*) vInfo,
                                                                                  scaledDoubleAudio, scaledDoubleVideo,
                                                                                  awPluginPath, awConverterPath, awFilterPath,
                                                                                  imageQuality, mj2000CompFactor );
}

void LibUpdate_ToMMFile(void *hl, const void *audio, const void *R, const void *G, const void *B)
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    if(hostLib->instance)
        (MAKE_FCN_PTR(pFnLibUpdate_ToMMFile,hostLib->libUpdate))(hostLib->instance, hostLib->errorMessage, audio, R, G, B);
}

