/*
 *  Main function for 'Face Detection on ARM Target using Code Generation' example
 */


#include "faceDetectionARMKernel_initialize.h"
#include "faceDetectionARMKernel.h"
#include "faceDetectionARMKernel_terminate.h"
#include "helperOpenCVWebcam.hpp"
#include "helperOpenCVVideoViewer.hpp"

#define FRAME_WIDTH  640
#define FRAME_HEIGHT 480 

int main()
{
    /* Allocate input and output image buffers */
    uint8_T inRGB[FRAME_WIDTH * FRAME_HEIGHT * 3],
            outRGB[FRAME_WIDTH * FRAME_HEIGHT * 3];

    /* Local variables */
    const char *winNameOut = "Output Video";
    const int frameWidth = FRAME_WIDTH, frameHeight = FRAME_HEIGHT;
    void* capture = 0;

    /* Initialize camera */
    capture = (void *)opencvInitCam(frameWidth, frameHeight);

    /* Initialize video viewer */
    opencvInitVideoViewer(winNameOut);

    /* Call MATLAB Coder generated initialize function */
    faceDetectionARMKernel_initialize();

    /* Exit while loop on Escape.
     *   - Make sure you press escape key while video viewer windows is on focus.
     *   - Program waits for only 10 ms for a pressed key. You may  need to 
     *     press Escape key multiple times before it gets  detected.
     */    
    while (!opencvIsEscKeyPressed())
    {
        /* Capture frame from camera */
        opencvCaptureRGBFrameAndCopy(capture, inRGB);

        /* **********************************************************
         * Call MATLAB Coder generated kernel function.             *
         * This function detects faces and inserts bounding boxes   *
         * around faces.                                            *
         * MATLAB API: outRGB = faceDetectionARMKernel(inRGB) *
         * MATLAB Coder generated C API:                            *
         *        void faceDetectionARMKernel(                *
         *                      const unsigned char inRGB[921600],  *
         *                            unsigned char outRGB[921600]) *
         * **********************************************************/
        faceDetectionARMKernel(inRGB, outRGB);

        /* Display output image */
        opencvDisplayRGB(outRGB, frameHeight, frameWidth, winNameOut);
    }

    /* Call MATLAB Coder generated terminate function */
    faceDetectionARMKernel_terminate();

    /* 0 - success */
    return 0;
}
