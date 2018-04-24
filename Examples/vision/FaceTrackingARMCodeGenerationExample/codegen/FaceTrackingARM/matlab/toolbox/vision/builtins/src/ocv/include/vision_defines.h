#ifndef vision_defines_h
#define vision_defines_h

/* All symbols in this module are intentionally exported. */
#ifdef _MSC_VER
#define LIBMWCVSTRT_API __declspec(dllexport)
#else
#define LIBMWCVSTRT_API
#endif

#ifndef EXTERN_C
#  ifdef __cplusplus
#    define EXTERN_C extern "C"
#  else
#    define EXTERN_C extern
#  endif
#endif

#ifdef MATLAB_MEX_FILE
    #include "tmwtypes.h" /* mwSize is defined here */
#else
#include "stddef.h"
#ifndef __TMWTYPES__
typedef size_t mwSize;  /* unsigned pointer-width integer */
#endif
#include "rtwtypes.h"
#endif

#endif
