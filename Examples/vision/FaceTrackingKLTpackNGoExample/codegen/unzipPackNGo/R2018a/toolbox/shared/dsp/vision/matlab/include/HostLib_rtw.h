/**
 * @file HostLib_rtw.h
 * @brief Helper for C clients of the HostLib library.
 * Copyright 2007-2017 The MathWorks, Inc.
 */ 

/* ************************************************
   ************************************************
   THIS IS A COPY OF FILE DAHostLib_rtw.h
   THIS FILE SHOULD BE REMOVED AND DAHostLib_rtw.h
   SHOULD INSTEAD BE USED IF AT ALL POSSIBLE
   ************************************************
   ************************************************
*/

#ifndef DAHOSTLIB_RTW_H
#define DAHOSTLIB_RTW_H

/* include headers that we need for opening dynamic libraries */
#ifdef _WIN32
#  include <windows.h>
#  define FCNPTR FARPROC
#else 
#  include <dlfcn.h>
#  define FCNPTR void*
#endif

/* define DllExport */
#if defined(_WIN32) && !defined(__LCC__)
#  if !defined(DllExport)
#    define DllExport __declspec(dllexport)
#  endif
#else
#  define DllExport
#endif

/* Wrap everything in extern C */
#ifdef __cplusplus
extern "C" {
#endif 

#define MAX_ERR_MSG_LEN 1024

/*******************************
 * Routines which are defined in the library in question.
 * Also defined are update, outputs, and create, but those are custom to each HostLib
 *******************************/
typedef void (*pFnLibStart)(void *device, char *err);
typedef void (*pFnLibReset)(void *device, char *err);
typedef void (*pFnLibTerminate)(void *device, char *err);
typedef void (*pFnLibDestroy)(void *device, char *err, int type);
        
/* Define a table of function pointers, the library handle, and a buffer for any error messages  */
typedef struct {
#ifdef _WIN32
    HMODULE library;
#else
    void *library;
#endif
    void *instance;

    FCNPTR libCreate;
    FCNPTR libStart;
    FCNPTR libReset;
    FCNPTR libUpdate;
    FCNPTR libOutputs;
    FCNPTR libTerminate;
    FCNPTR libDestroy;

    char errorMessage[MAX_ERR_MSG_LEN];
} HostLibrary;

#define MAKE_FCN_PTR(a,b) *((a*)&b)

/*******************************
 * Routines which open/close the library and initialize the function pointers,
 * routines which we define to call the functions in the library,
 * and utility routines.
 *******************************/
void CreateHostLibrary(const char *libname, void *adl);
void DestroyHostLibrary(void *adl);

void LibStart(void *hostLib);
void LibReset(void *hostLib);
void LibTerminate(void *hostLib);
void LibDestroy(void *hostLib, int type);

int LibError(void *hostLib);
void PrintError(char *message);
void PrintWarning(char *message);
char * GetErrorBuffer(void *hostLib);
void * GetNullPointer(void);


#ifdef __cplusplus
} // extern "C"
#endif 


#endif /* DAHOSTLIB_RTW_H */
