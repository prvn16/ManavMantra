/* Copyright 2016 The MathWorks, Inc. */
/*
 * File: main.cu
 *
 * MATLAB Coder version            : 3.2
 * C/C++ source code generated on  : 11-Apr-2016 08:43:44
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/
/* Include Files */
#include "rt_nonfinite.h"
#include "reduction.h"
#include "main.h"
#include "reduction_initialize.h"

#include "xil_interface_lib.h"

/* Function Declarations */
static void argInit_1x4096_real_T(double result[4096]);
static double argInit_real_T(void);
static void main_reduction(void);

/* Function Definitions */

/*
 * Arguments    : double result[4096]
 * Return Type  : void
 */
static void argInit_1x4096_real_T(double result[4096])
{
  int idx1;

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < 4096; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx1] = argInit_real_T();
  }
}

/*
 * Arguments    : void
 * Return Type  : double
 */
static double argInit_real_T(void)
{
  return 0.0;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_reduction(void)
{
  double minout;
  double maxout;
  double meanout;
  double mulout;
  double vsumout;
  double sumout;
  float singleout;
  double b[4096];
  double c[4096];

  /* Initialize function 'reduction' input arguments. */
  /* Initialize function input argument 'input1'. */
  /* Initialize function input argument 'input2'. */
  /* Call the entry-point 'reduction'. */
  argInit_1x4096_real_T(b);
  argInit_1x4096_real_T(c);

  int idx = 0;
  for (idx = 0; idx < 4096; idx++) {
      b[idx] = idx+1;
      c[idx] = idx+2;
  }

  reduction(b, c, &minout, &maxout, &meanout, &mulout, &vsumout, &sumout,
            &singleout);

}

/*
 * Arguments    : int argc
 *                const char * const argv[]
 * Return Type  : int
 */
//int main(int argc, const char * const argv[])
//{
//  (void)argc;
//  (void)argv;
  /* Initialize the application.
     You do not need to do this more than one time. */
//  reduction_initialize();
  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
//  main_reduction();
  /* Terminate the application.
     You do not need to do this more than one time. */
//  return 0;

int main(void) {
    XIL_INTERFACE_LIB_ERROR_CODE errorCode = XIL_INTERFACE_LIB_SUCCESS;
    int errorOccurred = 0;
    /* avoid warnings about infinite loops */
    volatile int loop = 1;   
    int argc = 0;

    /* XIL initialization */
    void * argv = (void *) 0;
    errorCode = xilInit(argc, (void**)argv);
    errorOccurred = (errorCode != XIL_INTERFACE_LIB_SUCCESS);
 
    /* main XIL loop */
    while(loop && !errorOccurred) {
        errorCode = xilRun();
        if (errorCode != XIL_INTERFACE_LIB_SUCCESS) {
            if (errorCode == XIL_INTERFACE_LIB_TERMINATE) {
                /* orderly shutdown of rtiostream */
                errorOccurred = (xilTerminateComms() != XIL_INTERFACE_LIB_SUCCESS);
            } else {
                errorOccurred = 1;
            }
        }
    }
   
   /* trap error with infinite loop */
   if (errorOccurred)
       while (loop) { }
   
   return errorCode;
}

/*
 * File trailer for main.cu
 *
 * [EOF]
 */
