/**
 * @file HostLib_Multimedia.c
 * @brief Helper for Multimedia blocks
 * Copyright 2009-2012 The MathWorks, Inc.
 */ 

#include "HostLib_Multimedia.h"

void createAudioInfo(void *audioInfo, unsigned char isValid,
                     unsigned char isFloat,
                     double sampleRate, int numBits,
                     int numChannels, int frameSize,
                     int dataType, void* audioCompressor)
{
    MMAudioInfo *pAudioInfo = (MMAudioInfo *) audioInfo;
    pAudioInfo->isValid         = isValid;
    pAudioInfo->isFloat         = isFloat;
    pAudioInfo->sampleRate      = sampleRate;
    pAudioInfo->numBits         = numBits;
    pAudioInfo->numChannels     = numChannels;
    pAudioInfo->frameSize       = frameSize;
    pAudioInfo->dataType        = (AudioDataType) dataType;
    pAudioInfo->audioCompressor = (char *)audioCompressor;
}

void createVideoInfo(void *videoInfo, unsigned char isValid,
                     double frameRate, double frameRateComputed,
                     const char *fourcc, int numPorts, int numBands,
                     int bandWidth, int bandHeight, unsigned char useMMReader,
                     int dataType, int orientation,
                     void* videoCompressor)
{
    int i=0;
    MMVideoInfo *pVideoInfo = (MMVideoInfo *) videoInfo;
    pVideoInfo->isValid           = isValid;
    pVideoInfo->frameRate         = frameRate;
    pVideoInfo->frameRateComputed = frameRateComputed;
    for(i=0; i<4; i++)
        pVideoInfo->fourcc[i] = fourcc[i];
    pVideoInfo->numPorts = numPorts;
    pVideoInfo->numBands = numBands;
    pVideoInfo->bandWidth[0]  = bandWidth;
    pVideoInfo->bandHeight[0] = bandHeight;
    if(fourcc[0] == 'Y') { /* "YUY2" */
        pVideoInfo->bandWidth[1]  = bandWidth/2;
        pVideoInfo->bandWidth[2]  = bandWidth/2;
        pVideoInfo->bandHeight[1] = bandHeight;
        pVideoInfo->bandHeight[2] = bandHeight;
    }
    else { /* " RGB" */
        pVideoInfo->bandWidth[1]  = bandWidth;
        pVideoInfo->bandWidth[2]  = bandWidth;
        pVideoInfo->bandHeight[1] = bandHeight;
        pVideoInfo->bandHeight[2] = bandHeight;
    }
    pVideoInfo->useMMReader = useMMReader;
    pVideoInfo->dataType          = (VideoDataType) dataType;
    pVideoInfo->orientation       = (VideoFrameOrientation) orientation;
    pVideoInfo->videoCompressor   = (char *)videoCompressor;
}
