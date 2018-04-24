/* 
 * Used by cgwrapper functions 
 *
 * Copyright 1995-2016 The MathWorks, Inc. 
 */

#include "cgCommon.hpp"

using namespace std;
using namespace cv;

///////////////////////////////////////////////////////////////////////////////
// cvRectToBoundingBox:
//  Converts vector<cv::Rect> to M-by-4 array of bounding boxes
//
//  Arguments:
//  ---------
//  rects: Reference to OpenCV's vector<cv::Rect> 
//
//  Returns:
//  -------
//  Pointer to an array having M-by-4 elements. 
///////////////////////////////////////////////////////////////////////////////

void cvRectToBoundingBox(const std::vector<cv::Rect> & rects, int32_T *boundingBoxes)
{
    // input rects: row major (OpenCV)
	// output boundingBoxes: column major (MATLAB MEX or EXE)

    uint32_T numRects(static_cast<uint32_T>(rects.size()));
    
    // Indices used to copy rectangle coordinates into M 1-by-4 rows
    // Each row defines a box using [x y width height] convention
    uint32_T x_idx      = 0;
    uint32_T y_idx      = numRects;
    uint32_T width_idx  = numRects * 2;
    uint32_T height_idx = numRects * 3;
    
    // Copy rectangle data into array
    std::vector<cv::Rect>::const_iterator rect_iter(rects.begin());
    for( ; rect_iter != rects.end(); ++rect_iter)
    {             
        boundingBoxes[x_idx++] = rect_iter->x + 1; // use 1-based coordinates
        boundingBoxes[y_idx++] = rect_iter->y + 1;
        boundingBoxes[width_idx++]  = rect_iter->width;
        boundingBoxes[height_idx++] = rect_iter->height;
    }
}

void cvRectToBoundingBoxRowMajor(const std::vector<cv::Rect> & rects, int32_T *boundingBoxes)
{
	// Indices used to copy rectangle coordinates into M 1-by-4 rows
	// Each row defines a box using [x y width height] convention
	uint32_T idx = 0;

	// Copy rectangle data into array
	std::vector<cv::Rect>::const_iterator rect_iter(rects.begin());
	for (; rect_iter != rects.end(); ++rect_iter)
	{
		boundingBoxes[idx++] = rect_iter->x + 1; // use 1-based coordinates
		boundingBoxes[idx++] = rect_iter->y + 1;
		boundingBoxes[idx++] = rect_iter->width;
		boundingBoxes[idx++] = rect_iter->height;
	}
}

