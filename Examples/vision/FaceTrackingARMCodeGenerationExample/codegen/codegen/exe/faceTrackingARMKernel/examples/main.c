/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
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
#include "faceTrackingARMKernel.h"
#include "main.h"
#include "faceTrackingARMKernel_terminate.h"
#include "faceTrackingARMKernel_initialize.h"

/* Function Declarations */
static void argInit_480x640x3_uint8_T(unsigned char result[921600]);
static unsigned char argInit_uint8_T(void);
static void main_faceTrackingARMKernel(void);

/* Function Definitions */

/*
 * Arguments    : unsigned char result[921600]
 * Return Type  : void
 */
static void argInit_480x640x3_uint8_T(unsigned char result[921600])
{
  int idx0;
  int idx1;
  int idx2;

  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 480; idx0++) {
    for (idx1 = 0; idx1 < 640; idx1++) {
      for (idx2 = 0; idx2 < 3; idx2++) {
        /* Set the value of the array element.
           Change this value to the value that the application requires. */
        result[(idx0 + 480 * idx1) + 307200 * idx2] = argInit_uint8_T();
      }
    }
  }
}

/*
 * Arguments    : void
 * Return Type  : unsigned char
 */
static unsigned char argInit_uint8_T(void)
{
  return 0U;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_faceTrackingARMKernel(void)
{
  static unsigned char uv7[921600];
  static unsigned char videoFrameOut[921600];

  /* Initialize function 'faceTrackingARMKernel' input arguments. */
  /* Initialize function input argument 'videoFrame'. */
  /* Call the entry-point 'faceTrackingARMKernel'. */
  argInit_480x640x3_uint8_T(uv7);
  faceTrackingARMKernel(uv7, videoFrameOut);
}

/*
 * Arguments    : int argc
 *                const char * const argv[]
 * Return Type  : int
 */
int main(int argc, const char * const argv[])
{
  (void)argc;
  (void)argv;

  /* Initialize the application.
     You do not need to do this more than one time. */
  faceTrackingARMKernel_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_faceTrackingARMKernel();

  /* Terminate the application.
     You do not need to do this more than one time. */
  faceTrackingARMKernel_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
