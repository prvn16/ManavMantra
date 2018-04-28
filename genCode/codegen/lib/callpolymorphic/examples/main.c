/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 27-Apr-2018 21:18:23
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
#include "callpolymorphic.h"
#include "main.h"
#include "callpolymorphic_terminate.h"
#include "callpolymorphic_initialize.h"

/* Function Declarations */
static void argInit_1x10_sfix16_En11(short result[10]);
static void argInit_1x2_char_T(char result[2]);
static void argInit_1x3_char_T(char result[3]);
static MakePolymorphic argInit_MakePolymorphic(void);
static char argInit_char_T(void);
static double argInit_real_T(void);
static short argInit_sfix16_En11(void);
static void main_callpolymorphic(void);

/* Function Definitions */

/*
 * Arguments    : short result[10]
 * Return Type  : void
 */
static void argInit_1x10_sfix16_En11(short result[10])
{
  int idx1;

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < 10; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx1] = argInit_sfix16_En11();
  }
}

/*
 * Arguments    : char result[2]
 * Return Type  : void
 */
static void argInit_1x2_char_T(char result[2])
{
  int idx1;

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < 2; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx1] = argInit_char_T();
  }
}

/*
 * Arguments    : char result[3]
 * Return Type  : void
 */
static void argInit_1x3_char_T(char result[3])
{
  int idx1;

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < 3; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx1] = argInit_char_T();
  }
}

/*
 * Arguments    : void
 * Return Type  : MakePolymorphic
 */
static MakePolymorphic argInit_MakePolymorphic(void)
{
  MakePolymorphic result;

  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result.Property1 = argInit_real_T();
  argInit_1x2_char_T(result.fn);
  argInit_1x3_char_T(result.gentype);
  argInit_1x10_sfix16_En11(result.u);
  return result;
}

/*
 * Arguments    : void
 * Return Type  : char
 */
static char argInit_char_T(void)
{
  return '?';
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
 * Return Type  : short
 */
static short argInit_sfix16_En11(void)
{
  return 0;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_callpolymorphic(void)
{
  int y;

  /* Initialize function 'callpolymorphic' input arguments. */
  /* Initialize function input argument 'mp'. */
  /* Call the entry-point 'callpolymorphic'. */
  y = callpolymorphic(argInit_MakePolymorphic());
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
  callpolymorphic_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_callpolymorphic();

  /* Terminate the application.
     You do not need to do this more than one time. */
  callpolymorphic_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
