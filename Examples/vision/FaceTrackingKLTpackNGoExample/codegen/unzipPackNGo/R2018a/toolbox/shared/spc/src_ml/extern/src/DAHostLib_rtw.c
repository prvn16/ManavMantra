/**
 * @file DAHostLib_rtw.c
 * @brief Helper for C clients of the HostLib library.
 * Copyright 2007-2017 The MathWorks, Inc.
 */ 

#include <string.h>
#include <stdio.h>

#include "DAHostLib_rtw.h"

/* Open the library and initialize the function pointers */
void CreateHostLibrary(const char *libName, void *hl) 
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    *hostLib->errorMessage = '\0';
    memset(hostLib, 0, sizeof(HostLibrary));
#if defined(_WIN32)
    hostLib->library = LoadLibrary(libName);
    if(hostLib->library == NULL)
        sprintf(hostLib->errorMessage, "Could not open library: %s.\nTo run the generated code outside the MATLAB environment, use the packNGo function.\n", libName);
    else {
        hostLib->libCreate    = GetProcAddress(hostLib->library, "libCreate");
        hostLib->libStart     = GetProcAddress(hostLib->library, "libStart"); 
        hostLib->libReset     = GetProcAddress(hostLib->library, "libReset"); 
        hostLib->libUpdate    = GetProcAddress(hostLib->library, "libUpdate");
        hostLib->libOutputs   = GetProcAddress(hostLib->library, "libOutputs");
        hostLib->libTerminate = GetProcAddress(hostLib->library, "libTerminate");
        hostLib->libDestroy   = GetProcAddress(hostLib->library, "libDestroy");
    }
#elif defined(_VXWORKS_)
    hostLib->library = dlopen(libName, RTLD_NOW);
    if(hostLib->library == NULL) {
        sprintf(hostLib->errorMessage, "Could not open library: %s", libName);
    }
    else {
        hostLib->libCreate    = dlsym(hostLib->library, "libCreate");
        hostLib->libStart     = dlsym(hostLib->library, "libStart"); 
        hostLib->libReset     = dlsym(hostLib->library, "libReset"); 
        hostLib->libUpdate    = dlsym(hostLib->library, "libUpdate");
        hostLib->libOutputs   = dlsym(hostLib->library, "libOutputs");
        hostLib->libTerminate = dlsym(hostLib->library, "libTerminate");
        hostLib->libDestroy   = dlsym(hostLib->library, "libDestroy");
    }
#else
    hostLib->library = dlopen(libName, RTLD_NOW | RTLD_LOCAL);
    if(hostLib->library == NULL) {
        sprintf(hostLib->errorMessage, "Could not open library: %s", libName);
    }
    else {
        hostLib->libCreate    = dlsym(hostLib->library, "libCreate");
        hostLib->libStart     = dlsym(hostLib->library, "libStart"); 
        hostLib->libReset     = dlsym(hostLib->library, "libReset"); 
        hostLib->libUpdate    = dlsym(hostLib->library, "libUpdate");
        hostLib->libOutputs   = dlsym(hostLib->library, "libOutputs");
        hostLib->libTerminate = dlsym(hostLib->library, "libTerminate");
        hostLib->libDestroy   = dlsym(hostLib->library, "libDestroy");
    }
#endif
    if(!*hostLib->errorMessage && 
       (!hostLib->libCreate ||
        !hostLib->libStart ||
        !hostLib->libUpdate ||
        !hostLib->libOutputs ||
        !hostLib->libTerminate ||
        !hostLib->libDestroy)
        ) 
    {
        sprintf(hostLib->errorMessage, "Could not determine function entry points in %s", libName);
    }
    if(*hostLib->errorMessage) {
        if (hostLib->library) DestroyHostLibrary(hostLib);
        fprintf(stderr,"%s",hostLib->errorMessage);
    }
}

/* Close the library */
void DestroyHostLibrary(void *hl) 
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    if(hostLib->library) {
#if defined(_WIN32)
        FreeLibrary(hostLib->library);
#else
        dlclose(hostLib->library);
#endif
        /* Clear the structure (except for any possible error message). */
		memset(hostLib, 0, sizeof(HostLibrary) - MAX_ERR_MSG_LEN);
    }
}

void LibStart(void *hl)
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    if(hostLib->instance)
        (MAKE_FCN_PTR(pFnLibStart,hostLib->libStart))(hostLib->instance, hostLib->errorMessage);
}

void LibReset(void *hl) 
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    if(hostLib->instance && hostLib->libReset)
        (MAKE_FCN_PTR(pFnLibReset,hostLib->libReset))(hostLib->instance, hostLib->errorMessage);
}

void LibTerminate(void *hl) 
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    if(hostLib->instance)
        (MAKE_FCN_PTR(pFnLibTerminate,hostLib->libTerminate))(hostLib->instance, hostLib->errorMessage);
}

void LibDestroy(void *hl, int type)
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    if(hostLib->instance)
    {
        (MAKE_FCN_PTR(pFnLibDestroy,hostLib->libDestroy))(hostLib->instance, hostLib->errorMessage, type);
        hostLib->instance = NULL;
    }
}

int LibError(void *hl) 
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    return hostLib->errorMessage[0] != '\0';
}
void PrintError(char *message)
{
    /* Print, and then reset, the error message */
    printf("Error: %s\n", message);
    message[0] = '\0';
}
void PrintWarning(char *message)
{
    /* Print, and then reset, the warning message */
    printf("Warning: %s\n", message);
    message[0] = '\0';
}
char * GetErrorBuffer(void *hl) 
{
    HostLibrary *hostLib = (HostLibrary*)hl;
    return hostLib->errorMessage;
}
void * GetNullPointer(void) 
{
    return NULL;
}
