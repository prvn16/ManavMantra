/**
 * @file HostLib_Multimedia.h
 * @brief Helper for Multimedia blocks
 * Copyright 2009-2012 The MathWorks, Inc.
 */ 


/* Wrap everything in extern C */
#ifdef __cplusplus
extern "C" {
#endif 

#include "VideoDefs.hpp"
#include "AudioDefs.hpp"


/*******************************
 * Routines used to initialize MMAudioInfo and MMVideoInfo structures.
 *******************************/
    void createAudioInfo(void *audioInfo, unsigned char isValid, unsigned char isFloat,
                         double sampleRate, int numBits,
                         int numChannels, int frameSize,
                         int dataType, void* audioCompressor);

void createVideoInfo(void *videoInfo, unsigned char isValid, double frameRate, double frameRateComputed,
                     const char* fourcc, int numPorts, int numBands,
                     int bandWidth, int bandHeight, unsigned char useMMReader,
                     int dataType, int orientation,
                     void* videoCompressor);


#ifdef __cplusplus
} // extern "C"
#endif 

