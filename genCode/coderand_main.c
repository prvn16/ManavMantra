/*
** main.c
*/
#include <stdio.h>
#include <stdlib.h>
#include "coderand.h"
#include "coderand_initialize.h"
#include "coderand_terminate.h"
int main()
{
    coderand_initialize();
    
    printf("coderand=%g\n", coderand());
    
    coderand_terminate();
    
    return 0;
}