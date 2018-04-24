
/*
 * main function required to generate standalone executable.
 * This is used by FaceTrackingKLTpackNGoExample.m
 */

#include  "FaceTrackingKLTpackNGo_kernel.h"
#include  "FaceTrackingKLTpackNGo_kernel_initialize.h"
#include  "FaceTrackingKLTpackNGo_kernel_terminate.h"

int main()
{         
    FaceTrackingKLTpackNGo_kernel_initialize();
    
    FaceTrackingKLTpackNGo_kernel();
    
    FaceTrackingKLTpackNGo_kernel_terminate();
    
    /* 0 - success */
    return 0;
}