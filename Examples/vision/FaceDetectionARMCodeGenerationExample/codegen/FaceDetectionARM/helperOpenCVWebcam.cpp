
#include "opencv2/opencv.hpp"
#include "helperOpenCVWebcam.hpp"

#include "cgCommon.hpp"

using namespace cv;
using namespace std;

// Initializes webcam
void* opencvInitCam(const int frameW, const int frameH)
{
    VideoCapture *capture = new VideoCapture(0);
    capture->set(CV_CAP_PROP_FRAME_WIDTH, frameW);
    capture->set(CV_CAP_PROP_FRAME_HEIGHT, frameH);

    if (!capture->isOpened())  // check if we succeeded
        return 0;

    return (void *)capture;
}

// Reads RGB frame from webcam and copies it to a buffer
void opencvCaptureRGBFrameAndCopy(void *captureV, uint8_T *rgbU8)
{

    VideoCapture* capture = (VideoCapture*)captureV;

    Mat frameRGBMat;
    (*capture) >> frameRGBMat;

    cArrayFromMat<uint8_T>(rgbU8, frameRGBMat);
}
