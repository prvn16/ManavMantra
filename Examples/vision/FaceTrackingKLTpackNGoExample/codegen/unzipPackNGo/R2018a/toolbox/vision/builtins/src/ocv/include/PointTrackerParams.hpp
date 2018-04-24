//////////////////////////////////////////////////////////////////////////////
// Class for managing PointTracker parameters.
//
// Copyright 2012 The MathWorks, Inc.
//  
//////////////////////////////////////////////////////////////////////////////
#ifndef POINT_TRACKER_PARAMS
#define POINT_TRACKER_PARAMS

#include "opencv/cv.h"
#include "opencv2/core/core.hpp"

namespace pointTracker
{

// This class encapsulates parameters for
// the PointTracker
class  PointTrackerParams
{
  public:
    // copy ctor, operator=, destructor ok

    PointTrackerParams() : mFlags(0) {}

    PointTrackerParams(const cv::Size &blockSize, int numPyramidLevels,
      cv::TermCriteria terminationCriteria, double maxBidirectionalErrorSq) 
      : mBlockSize(blockSize), mNPyramidLevels(numPyramidLevels), 
        mTerminationCriteria(terminationCriteria), mFlags(0),
        mMaxBidirectionalErrorSq(maxBidirectionalErrorSq)
     {}

    // returns true if forward-backward error should be used.
    inline bool useBidirectionalConstraint() const
    {
        return mMaxBidirectionalErrorSq >= 0;
    }
 
    // sets the flags to show that the first pyramid is 
    // already computed
    inline void setPyramid1Ready()
    {
        mFlags = CV_LKFLOW_PYR_A_READY;
    }

    // returns the flags showing that both pyramids have
    // already been computed
    inline int getFlagsBothPyramidsReady() const
    {
        return CV_LKFLOW_PYR_A_READY | CV_LKFLOW_PYR_B_READY;
    }

    // returns the half-window size
    const cv::Size &getBlockSize() const {return mBlockSize;}
    
    // returns the number of pyramid levels
    int getNumPyramidLevels() const {return mNPyramidLevels;}

    // returns max number of iterations and esplion
    inline const cv::TermCriteria &getTerminationCriteria() const
    {
        return mTerminationCriteria;
    }
    
    // returns the flags, which may either be "both pyramids 
    // are not ready" or "pyramid 1 is ready"
    int getPyramidStatus() const {return mFlags;}

    // returns the forward-backward error threshold
    inline double getMaxBidirectionalErrorSq() const 
    {
        return mMaxBidirectionalErrorSq;
    }

  private:
    // this is actually half of the window size
    // OpenCV multiplies it by 2 and adds 1.
    cv::Size mBlockSize;

    // number of levels in the pyramids
    int mNPyramidLevels;

    // maximum number of iterations and epsilon
    cv::TermCriteria mTerminationCriteria;

    // specifies whether one or both pyramids have 
    // been pre-computed.
    // CV_LKFLOW_PYR_A_READY | CV_LKFLOW_PYR_B_READY
    int mFlags;

    // threshold on forward-backward error
    double mMaxBidirectionalErrorSq;
};

} // namespace pointTracker
#endif
