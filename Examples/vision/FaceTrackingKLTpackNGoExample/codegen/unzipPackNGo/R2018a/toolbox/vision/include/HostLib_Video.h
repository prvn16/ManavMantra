/**
 * @file HostLib_Video.h
 * @brief Helper for the ToVideoDevice block
 * Copyright 2007-2010 The MathWorks, Inc.
 */ 

#include "VideoDefs.hpp"

/* Wrap everything in extern C */
#ifdef __cplusplus
extern "C" {
#endif 

extern const char *libName_Video;

/*******************************
 * Routines which are defined in the library in question
 *******************************/
typedef void* (*pFnLibCreate_Video)(char *err, char *warning, const char *id, const char *windowCaption,
                                    unsigned char bFullscreen, 
                                    MMVideoInfo *vInfo, unsigned char openAtMdlStart,
                                    int x, int y, unsigned char setSize, int windowWidth, int windowHeight,
                                    int scaledDoubleIndex, unsigned char variableSizeVideo, unsigned char isMacCG);
typedef void (*pFnLibUpdate_Video)(void *obj, char *err, const void *R, const void *G, const void *B,
                                   int curWidth, int curHeight);
typedef void (*pFnLibOutputs_Video)(void);

/*******************************
 * Routines which we define to call the functions in the library 
 *******************************/
void LibCreate_Video(void *hostLib, char *warning, const char *id, const char *windowCaption,
                     unsigned char bFullscreen, 
                     void *vInfo, unsigned char openAtMdlStart,
                     int x, int y, unsigned char setSize, int windowWidth, int windowHeight,
                     int scaledDoubleIndex, unsigned char variableSizeVideo, unsigned char isMacCG);
void LibUpdate_Video(void *hostLib, const void *R, const void *G, const void *B,
                     int curWidth, int curHeight);

/* Include HostLib for declarations of LibStart, LibTerminate, CreateHostLibrary, and DestroyHostLibrary. */
#include "HostLib_rtw.h"

#ifdef __cplusplus
} // extern "C"
#endif 

