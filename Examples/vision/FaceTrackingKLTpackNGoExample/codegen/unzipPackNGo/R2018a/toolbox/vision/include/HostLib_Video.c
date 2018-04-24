/**
 * @file HostLib_Video.c
 * @brief Helper for C clients of the HostLib library.
 * Copyright 2007-2008 The MathWorks, Inc.
 */ 

#include "HostLib_Video.h"
#include <string.h>
#include <stdio.h>

#if defined(_WIN32)
   const char *libName_Video = "tovideodevice.dll";
#elif defined(__APPLE__)
   const char *libName_Video = "libmwtovideodevice.dylib";
#else 
   const char *libName_Video = "libmwtovideodevice.so";
#endif

void LibCreate_Video(void *hl, char *warning, const char *id, const char *windowCaption,
                     unsigned char bFullscreen, 
                     void *vInfo, unsigned char openAtMdlStart, 
                     int x, int y, unsigned char setSize, int windowWidth, int windowHeight,
                     int scaledDoubleIndex, unsigned char variableSizeVideo, unsigned char isMacCG)
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    hostLib->errorMessage[0] = '\0';
    if(warning)
        warning[0] = '\0';
    hostLib->instance = (MAKE_FCN_PTR(pFnLibCreate_Video,hostLib->libCreate))(hostLib->errorMessage, warning, id, windowCaption,
                                                                              bFullscreen, 
                                                                              (MMVideoInfo*) vInfo, openAtMdlStart, 
                                                                              x, y, setSize, windowWidth, windowHeight,
                                                                              scaledDoubleIndex, variableSizeVideo, isMacCG);
}

void LibUpdate_Video(void *hl, const void *R, const void *G, const void *B,
                     int curWidth, int curHeight)
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    if(hostLib->instance)
        (MAKE_FCN_PTR(pFnLibUpdate_Video,hostLib->libUpdate))(hostLib->instance, hostLib->errorMessage, R, G, B, 
                                                              curWidth, curHeight);
}
