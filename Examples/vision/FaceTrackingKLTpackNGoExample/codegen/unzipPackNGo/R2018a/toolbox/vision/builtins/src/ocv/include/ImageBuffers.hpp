//////////////////////////////////////////////////////////////////////////////
// Class for managing images and pyramids.
//
// Copyright 2012 The MathWorks, Inc.
//  
//////////////////////////////////////////////////////////////////////////////
#ifndef POINT_TRACKER_IMAGE_BUFFERS
#define POINT_TRACKER_IMAGE_BUFFERS

#include "opencv/cv.h"
#include "opencv2/video.hpp"

namespace pointTracker
{

// This class manages the images and the pyramids
// for the PointTracker
class  ImageBuffers
{
  public:
    typedef std::vector<cv::Mat> Pyramid;
    ImageBuffers() : mIndex1(0), mIndex2(1) {}

    // copy ctor, operator=, default destructor ok

    // sets the first frame and the second buffer. 
    // must only be called once during initialize.
    inline void setInitialFrame(const cv::Mat &frame)
    {
        mImages[mIndex1] = frame;
        allocateImage2();
    }
    
    // copies the current frame into mImage2.
    // must be called during step.
    inline void setCurrentFrame(const cv::Mat &frame)
    {
        mImages[mIndex2] = frame;
    }
    
    inline void swap()
    {
        std::swap(mIndex1, mIndex2);
    }

    inline const Pyramid &getPyramid1() const {return mPyramids[mIndex1];}
    inline const Pyramid &getPyramid2() const {return mPyramids[mIndex2];}

    inline const cv::Mat &getImage1() const
    {
      return mImages[mIndex1];
    }
    
    inline unsigned int getImageHeight() const
    {
        return mImages[mIndex1].size().height;
    }

    inline unsigned int getImageWidth() const
    {
        return mImages[mIndex1].size().width;
    }

    inline void computePyramid1(const cv::Size &blockSize, int numLevels)
    {
        computePyramid(mIndex1, blockSize, numLevels);
    }

    inline void computePyramid2(const cv::Size &blockSize, int numLevels)
    {
        computePyramid(mIndex2, blockSize, numLevels);
    }

  private:
    // allocates the images and the pyramids
    void allocateImage2()
    {
        const cv::Size size = mImages[mIndex1].size();
        const int type = mImages[mIndex1].type();
        mImages[mIndex2].create(size, type);
    }

    void computePyramid(int idx, const cv::Size &blockSize, int numLevels)
    {
        cv::buildOpticalFlowPyramid(mImages[idx], mPyramids[idx], blockSize, 
	   numLevels, true, cv::BORDER_REFLECT_101, cv::BORDER_CONSTANT, false);
    }

    // indices of previous and next image or pyramid
    int mIndex1, mIndex2;

    // actual image and pyramid buffers
    cv::Mat mImages[2];
    Pyramid mPyramids[2];
};

} // namespace pointTracker

#endif
