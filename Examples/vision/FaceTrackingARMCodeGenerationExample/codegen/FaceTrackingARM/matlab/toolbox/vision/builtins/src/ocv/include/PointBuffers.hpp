//////////////////////////////////////////////////////////////////////////////
// Class for managing points, validity and scores.
//
// Copyright 2012 The MathWorks, Inc.
//  
//////////////////////////////////////////////////////////////////////////////
#ifndef POINT_TRACKER_POINT_BUFFERS
#define POINT_TRACKER_POINT_BUFFERS

#include <vector>

namespace pointTracker
{

// This class manages the buffers for
// points, validity, and scores in PointTracker
class  PointBuffers
{
  public:
    // copy ctor, operator=, destructor ok

    // point struct used by cvCalcOpticalFlowPyrLK
    typedef cv::Point2f Point;

    // allocates all point buffers and copies points 
    void setPoints(int numPoints, const float *pointData,
                   bool useBidirectionalConstraint);

	void setPointsRM(int numPoints, const float *pointData,
		bool useBidirectionalConstraint);

    // copies validity flags from mxLogicalArray
    void setValidity(const uchar *validityData);

    void swap()
    {
        updateValidity();
        mPoints1.swap(mPoints2);
        mStatus1.swap(mStatus2);
    }

    // get pointers for OpenCV
    int getNumPoints() const {return mNPoints;}
    const std::vector<Point> &getPoints1() const {return mPoints1;}
    std::vector<Point> &getPoints2() {return mPoints2;}
    const std::vector<uchar> &getStatus1() const {return mStatus1;}
    std::vector<uchar> &getStatus2() {return mStatus2;}
    const std::vector<float> &getErr() const {return mErr;}

    // these functions are used for forward-backward error constraint
    std::vector<Point> &getTmpPoints() {return mTmpPoints;}
    std::vector<uchar> &getTmpStatus() {return mTmpStatus;}
    std::vector<float> &getTmpErr() {return mTmpErr;}
    void updateValidityForwardBackward(double maxBidirectionalErrorSq);
    void initializeValidity();
   
  private:
    void updateValidity();
    
    // allocates buffers for point, validity, and scores
    void allocatePointBuffers(bool useBidirectionalConstraint);

    // computes the squared Euclidean distance between
    // two 2D points.
    inline static double distSq(const Point &p1, const Point &p2)
    {
        double dx = p1.x - p2.x;
        double dy = p1.y - p2.y;
        double d = dx * dx + dy * dy;
        return d;
    }

    int mNPoints;

    // point buffers
    std::vector<Point> mPoints1, mPoints2, mTmpPoints;
    std::vector<uchar> mStatus1, mStatus2, mTmpStatus;
    std::vector<float> mErr, mTmpErr;
};

///////////////////////////////////////////////////////////////////////////////
inline void PointBuffers::setPoints(int numPoints, const float *pointData,
                             bool useBidirectionalConstraint)
{
    mNPoints = numPoints;
    allocatePointBuffers(useBidirectionalConstraint);
    for(int i = 0; i < mNPoints; ++i)
    {
        // pointData is assumed to come from Matlab, which is 1-based.
        // Converting to 0-based coordinates.
        float x = pointData[i] - 1;
        float y = pointData[i + mNPoints] - 1;
        mPoints1[i].x = x;
        mPoints1[i].y = y;
    }
}

inline void PointBuffers::setPointsRM(int numPoints, const float *pointData,
	bool useBidirectionalConstraint)
{
	mNPoints = numPoints;
	allocatePointBuffers(useBidirectionalConstraint);

	int k = 0;
	for (int i = 0; i < mNPoints; ++i)
	{
		// pointData is assumed to come from Matlab, which is 1-based.
		// Converting to 0-based coordinates.
		float x = pointData[k++] - 1;
		float y = pointData[k++] - 1;
		mPoints1[i].x = x;
		mPoints1[i].y = y;
	}
}

///////////////////////////////////////////////////////////////////////////////
inline void PointBuffers::allocatePointBuffers(bool useBidirectionalConstraint)
{
    mPoints1.resize(mNPoints);
    mPoints2.resize(mNPoints);
    mStatus1.resize(mNPoints, (uchar)1);
    mStatus2.resize(mNPoints, (uchar)1);
    mErr.resize(mNPoints);
    
    if(useBidirectionalConstraint)
    {
        mTmpPoints.resize(mNPoints);
        mTmpStatus.resize(mNPoints, (uchar)1);
        mTmpErr.resize(mNPoints);
    }
}

///////////////////////////////////////////////////////////////////////////////
inline void PointBuffers::initializeValidity()
{
  std::fill(mStatus1.begin(), mStatus1.end(), (uchar)1);
}

///////////////////////////////////////////////////////////////////////////////
inline void PointBuffers::setValidity(const uchar *validityData)
{    
    std::copy(validityData, validityData + mNPoints, mStatus1.begin());
}

///////////////////////////////////////////////////////////////////////////////
inline void PointBuffers::updateValidity()
{
    // update status: once a point is invalid, it stays invalid.
    // invalid points stay at their last valid location.
    for(int i = 0; i < mNPoints; ++i)
    {
        mStatus2[i] = mStatus1[i] && mStatus2[i];
        if(mStatus2[i] == 0)
            mPoints2[i] = mPoints1[i];
    }
}

///////////////////////////////////////////////////////////////////////////////
inline void PointBuffers::updateValidityForwardBackward(double maxBidirectionalErrorSq)
{
    // mark points that were lost during backward tracking,
    // or which did not pass the bidirectional constraint as
    // invalid.
    for(int i = 0; i < mNPoints; ++i)
    {
        mStatus2[i] = mStatus2[i] && mTmpStatus[i] && 
            (distSq(mPoints1[i], mTmpPoints[i]) < 
             maxBidirectionalErrorSq);
    }
}

} // namespace pointTracker

#endif

