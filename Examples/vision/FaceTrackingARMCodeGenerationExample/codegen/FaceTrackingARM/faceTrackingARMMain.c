/*
*  Main function for 'Face Tracking on ARM Target using Code Generation' example
*/


#include "faceTrackingARMKernel_initialize.h"
#include "faceTrackingARMKernel.h"
#include "faceTrackingARMKernel_terminate.h"
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
	faceTrackingARMKernel_initialize();

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
		* Call MATLAB Coder generated kernel function.              *
		* This function detects and tracks a face in a video frame. *                                           *
		* MATLAB API: outRGB = faceTrackingARMKernel(inRGB)         *
		* MATLAB Coder generated C API:                             *
		*        void faceTrackingARMKernel(                        *
		*                      const unsigned char inRGB[921600],   *
		*                            unsigned char outRGB[921600])  *
		* **********************************************************/
		faceTrackingARMKernel(inRGB, outRGB);

		/* Display output image */
		opencvDisplayRGB(outRGB, frameHeight, frameWidth, winNameOut);
	}

	/* Call MATLAB Coder generated terminate function */
	faceTrackingARMKernel_terminate();

	/* 0 - success */
	return 0;
}
