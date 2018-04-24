
#include "opencv2/opencv.hpp"
#include "helperOpenCVVideoViewer.hpp"

#include "cgCommon.hpp"

using namespace cv;
using namespace std;

// Detects if Escape key is pressed while the video viewer window is on focus
boolean_T opencvIsEscKeyPressed(void)
{
    // ascii value of ESC is 27 
    return (boolean_T)(cvWaitKey(10) == 27);
}

// Initializes video viewer window
void opencvInitVideoViewer(const char *winName)
{
    namedWindow(winName, CV_WINDOW_AUTOSIZE);
}

// Displays RGB video frame
void opencvDisplayRGB(uint8_T *rgbU8, int numRow, int numCols, const char *winName)
{
    cv::Mat rgbMat(numRow, numCols, CV_8UC3, Scalar(0, 0, 0));

    cArrayToMat<uint8_T>(rgbU8, numRow, numCols, true, rgbMat);

    imshow(winName, rgbMat); waitKey(30); // wait to draw now
}


