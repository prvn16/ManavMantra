#ifndef POINT_TRACKER_OCV
#define POINT_TRACKER_OCV

#include "PointTrackerParams.hpp"
#include "PointBuffers.hpp"
#include "ImageBuffers.hpp"

#include "opencv2/video.hpp"

namespace pointTracker
{

class  PointTrackerOcv
{
public:
    PointTrackerOcv() {}

    void initialize(const PointTrackerParams &params, const cv::Mat &frame, 
                    int numPoints, const float *pointData)
    {
      mParams = params;
      mImageBuffers.setInitialFrame(frame);
      mPointBuffers.setPoints(numPoints, pointData,
                              mParams.useBidirectionalConstraint());
      mPointBuffers.initializeValidity();
      mImageBuffers.computePyramid1(mParams.getBlockSize(), 
	                            mParams.getNumPyramidLevels());
    }

	void initializeRM(const PointTrackerParams &params, const cv::Mat &frame,
		int numPoints, const float *pointData)
	{
		mParams = params;
		mImageBuffers.setInitialFrame(frame);
		mPointBuffers.setPointsRM(numPoints, pointData,
			mParams.useBidirectionalConstraint());
		mPointBuffers.initializeValidity();
		mImageBuffers.computePyramid1(mParams.getBlockSize(),
			mParams.getNumPyramidLevels());
	}

    void setPoints(int numPoints, const float *pointData, const uchar *validityData=NULL)
    {
      mPointBuffers.setPoints(numPoints, pointData, 
                              mParams.useBidirectionalConstraint());
      if(validityData)
	        mPointBuffers.setValidity(validityData);
    }

	void setPointsRM(int numPoints, const float *pointData, const uchar *validityData = NULL)
	{
		mPointBuffers.setPointsRM(numPoints, pointData,
			mParams.useBidirectionalConstraint());
		if (validityData)
			mPointBuffers.setValidity(validityData);
	}

    void step(const cv::Mat &frame)
    {
       mImageBuffers.setCurrentFrame(frame);
 
       mImageBuffers.computePyramid2(mParams.getBlockSize(), 
	  mParams.getNumPyramidLevels());

       calcOpticalFlowPyrLK(mImageBuffers.getPyramid1(),
                         mImageBuffers.getPyramid2(),
                         mPointBuffers.getPoints1(), 
                         mPointBuffers.getPoints2(),
                         mPointBuffers.getStatus2(), 
                         mPointBuffers.getErr(),
                         mParams.getBlockSize(), 
                         mParams.getNumPyramidLevels(), 
			 mParams.getTerminationCriteria()); 

       if(mParams.useBidirectionalConstraint())
       {
          applyBidirectionalConstraint();      
       }

       swapBuffers();
    } 

    int getNumPoints() const
    {
       return mPointBuffers.getNumPoints();
    }

    const std::vector<PointBuffers::Point> &getPoints() const
    {
       return mPointBuffers.getPoints1();
    }

    const std::vector<uchar> &getStatus() const
    {
       return mPointBuffers.getStatus1();
    }

    const std::vector<float> &getErr() const
    {
       return mPointBuffers.getErr();
    }

    const cv::Mat &getPreviousFrame() const
    {
       return mImageBuffers.getImage1();
    }

    unsigned int getImageHeight() const
    {
       return mImageBuffers.getImageHeight();
    }

    unsigned int getImageWidth() const
    {
       return mImageBuffers.getImageWidth();
    }
private:
    // swaps image and point buffers between calls to step()
    void swapBuffers()
    {
        mImageBuffers.swap();
        mPointBuffers.swap();
        mParams.setPyramid1Ready();
    }

    // computes the forward-backward error, and applies
    // a threshold on it.
    void applyBidirectionalConstraint()
    {
      // call OpenCV
      cv::calcOpticalFlowPyrLK(mImageBuffers.getPyramid2(),
                         mImageBuffers.getPyramid1(),
                         mPointBuffers.getPoints2(), 
                         mPointBuffers.getTmpPoints(),
                         mPointBuffers.getTmpStatus(), 
                         mPointBuffers.getErr(),
                         mParams.getBlockSize(), 
                         mParams.getNumPyramidLevels(), 
                	 mParams.getTerminationCriteria());

      mPointBuffers.updateValidityForwardBackward(
        mParams.getMaxBidirectionalErrorSq());
    }

 
    // KLT parameters
    PointTrackerParams mParams;

    // points, validity, scores
    PointBuffers mPointBuffers;

    // images and pyramids
    ImageBuffers mImageBuffers;

    // copying and assignment are disallowed
    PointTrackerOcv(const PointTrackerOcv &);
    PointTrackerOcv &operator=(const PointTrackerOcv &);

};

} // namespace pointTracker
#endif
