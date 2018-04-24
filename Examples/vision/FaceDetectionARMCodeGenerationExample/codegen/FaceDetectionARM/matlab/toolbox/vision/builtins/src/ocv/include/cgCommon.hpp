/* 
 * Used by cgwrapper functions 
 *
 * Copyright 1995-2011 The MathWorks, Inc. 
 */

#ifndef CGCOMMON_HPP
#define CGCOMMON_HPP

#include "vision_defines.h"
#include "opencv2/opencv.hpp"

#ifdef PARALLEL
#define NUM_THREADS 4
#include <thread>
#include <vector>
#endif

using namespace std;
using namespace cv;

/////////////////////////////////////////////////////////////////////////////////
// cArrayToMat:
//  Fills up a given cv::Mat with the data from an array. 
//  The function transposes and interleaves column major array data into 
//  row major cv::Mat. 
//
//  Arguments:
//  ---------
//  in: Pointer to an array having column major data. data can
//      be n-channel matrices.
//      Supported data types are real_T (double), real32_T (single or float), 
//      uint8_T (uint8), uint16_T (uint16), uint32_T (uint32), int8_T (int8), 
//      int16_T (int16), int32_T (int32), or boolean_T (bool or logical).
//  out: Reference to OpenCV's cv::Mat with row major data.
//
//  Note:
//  ----
//  - The function reallocates memory for the cv::Mat if needed.
//  - This is a generic matrix conversion routine for any number of channels.
/////////////////////////////////////////////////////////////////////////////////

template <typename ImageDataType>
void copyToMat(ImageDataType *src, ImageDataType *dst, int startRowIdx, int numRowsInBlock, int numRows, int numCols)
{
// src: column major (MATLAB MEX or EXE)
// dst: row major (OpenCV)

	for (int i = startRowIdx; i < numRowsInBlock; ++i)
	{
		/* Copy each row from src (column major) to dst (row major) */
		for (int j = 0; j < numCols; ++j)
		{
			*dst++ = src[i + j*numRows];
		}
	}
}

template <typename ImageDataType>
void copyToMat_RowMaj(ImageDataType *src, ImageDataType *dst, int numRowsInBlock, int numCols)
{
	// src: row major (MATLAB MEX or EXE)
	// dst: row major (OpenCV)

	/* Copy each row from src (row major) to dst (row major) */
	memcpy(dst, src, numRowsInBlock*numCols*sizeof(ImageDataType));
}

template <typename ImageDataType>
void copyToMatBGR(ImageDataType *src, ImageDataType *dst, int startRowIdx, int numRowsInBlock, int numRows, int numCols, int channels)
{
	// src: column major r,g,b planar (MATLAB MEX or EXE)
	// dst: row major (OpenCV)

	int rc = numRows*numCols;

	for (int i = startRowIdx; i < numRowsInBlock; ++i)
	{
		/* Copy each row (with RGB from 3 planes) from src (column major) to dst (row major) as RGB triplet */
		for (int j = 0; j < numCols; ++j)
		{
			// OpenCV uses BGR ordering so we need to supply the data                                                                                                                                                
			// in the proper order, by counting backwards                                                                                                                                                            
			for (int k = (int)(channels - 1); k >= 0; --k)
			{
				*dst++ = src[i + j*numRows + k*rc];
			}
		}
	}
}

template <typename ImageDataType>
void copyToMatBGR_RowMaj(ImageDataType *src, ImageDataType *dst, int numRowsInBlock, int numCols, int channels)// remove channels from here
{
	// src: row major rgb triplet (MATLAB MEX or EXE)
	// dst: row major bgr triplet (OpenCV)

	//int planeLen = numRows*numCols;
	ImageDataType *rIm = src;
	ImageDataType *gIm = &src[1];
	ImageDataType *bIm = &src[2];

	for (int ij = 0; ij < numCols*numRowsInBlock * 3; ij += 3) //channels = 3
	{
		// OpenCV uses BGR ordering so we need to supply the data
		// in the proper order
		*dst++ = bIm[ij];
		*dst++ = gIm[ij];
		*dst++ = rIm[ij];
	}
}

template <typename ImageDataType>
void cArrayToMat(const ImageDataType *in, int numRows, int numCols, bool isRGB , cv::Mat &out)
{
	// in: column major (MATLAB MEX or EXE)
	// out: row major (OpenCV)

    ImageDataType *imgData = (ImageDataType *)in;

	// assert that mxArray is 2D or 3D
    const int nChannels(isRGB ? 3 : 1);       
    int type = CV_MAKETYPE(cv::DataType<ImageDataType>::type,          
                           (int) nChannels);

    // allocates new matrix data unless the matrix already 
    // has specified size and type.
    // previous data is unreferenced if needed.
    out.create(static_cast<int32_T>(numRows),
               static_cast<int32_T>(numCols),
               type);

    ImageDataType *dst = reinterpret_cast<ImageDataType *>(out.data);

#ifdef PARALLEL
    vector<thread> workers;
    int blocks = numRows / NUM_THREADS;
    int startRowIdx = 0, numRowsInBlock = blocks;
#endif

    // convert column-major to row-major and interleave pixel data. OpenCV
    // stores multi-channel data in the interleaved format.        
    if (nChannels == 1)        
    {
#ifdef PARALLEL
        for( int t = 1; t <= NUM_THREADS; t++ )
        {
            if( t == NUM_THREADS )
                numRowsInBlock += numRows % NUM_THREADS;

            workers.push_back( thread(copyToMat<ImageDataType>, imgData, &dst[startRowIdx*numCols], startRowIdx, numRowsInBlock, numRows, numCols) );
            startRowIdx = numRowsInBlock;
            numRowsInBlock = startRowIdx + blocks;
        }
#else
		copyToMat<ImageDataType>(imgData, dst, 0, numRows, numRows, numCols);
		/*
		// making columnMajor grayscale image to rowmajor grayscale image
        for (int i = 0; i < numRows; ++i)       
        {         
            for (int j = 0; j < numCols; ++j) 
            {
                *dst++ = imgData[i + j*numRows];
            }
        }
        */
#endif
    }
    else
    {
#ifdef PARALLEL
        // assert that there are 3 color planes                                                                                                                                                                    
        for( int t = 1; t <= NUM_THREADS; t++ )
        {
            if( t == NUM_THREADS )
                numRowsInBlock += numRows % NUM_THREADS;

            workers.push_back( thread(copyToMatBGR<ImageDataType>, imgData, &dst[startRowIdx*numCols*nChannels],  startRowIdx, numRowsInBlock, numRows, numCols, nChannels) );
            startRowIdx = numRowsInBlock;
            numRowsInBlock = startRowIdx + blocks;
        }
#else
		copyToMatBGR<ImageDataType>(imgData, dst, 0, numRows, numRows, numCols, nChannels);
        /*
        int rc = numRows*numCols; 
        for (int i = 0; i < numRows; ++i)                
        {
            for (int j = 0; j < numCols; ++j)
            {
                // OpenCV uses BGR ordering so we need to supply the data
                // in the proper order, by counting backwards
                for (int k = (int)(nChannels-1); k >= 0; --k)
                {
                    *dst++ = imgData[i + j*numRows + k*rc];
                }
            }
        }
        */
#endif
    } 

#ifdef PARALLEL
    for( thread &th : workers )
        th.join();
#endif
}

template <typename ImageDataType>
void cArrayToMat_RowMaj(const ImageDataType *in, int numRows, int numCols, bool isRGB, cv::Mat &out)
{
	// in: row major (MATLAB MEX or EXE)
	// out: row major (OpenCV)

	ImageDataType *imgData = (ImageDataType *)in;

	// assert that mxArray is 2D or 3D
	const int nChannels(isRGB ? 3 : 1);
	int type = CV_MAKETYPE(cv::DataType<ImageDataType>::type,
		(int)nChannels);

	// allocates new matrix data unless the matrix already 
	// has specified size and type.
	// previous data is unreferenced if needed.
	out.create(static_cast<int32_T>(numRows),
		static_cast<int32_T>(numCols),
		type);

	ImageDataType *dst = reinterpret_cast<ImageDataType *>(out.data);

#ifdef PARALLEL
	vector<thread> workers;
	int blocks = numRows / NUM_THREADS;
	int startRowIdx = 0, numRowsInBlock = blocks;
#endif

	// convert column-major to row-major and interleave pixel data. OpenCV
	// stores multi-channel data in the interleaved format.        
	if (nChannels == 1)
	{
#ifdef PARALLEL
		for (int t = 1; t <= NUM_THREADS; t++)
		{
			if (t == NUM_THREADS)
				numRowsInBlock += numRows % NUM_THREADS;

			workers.push_back(thread(copyToMat_RowMaj<ImageDataType>, &imgData[startRowIdx], &dst[startRowIdx], numRowsInBlock, numCols));
			startRowIdx = numRowsInBlock;
			numRowsInBlock = startRowIdx + blocks;
		}
#else
		// making rowMajor grayscale image to rowMajor grayscale image
		//memcpy(dst, imgData, numRows*numCols*sizeof(ImageDataType));
		copyToMat_RowMaj<ImageDataType>(imgData, dst, numRows, numCols);
#endif
	}
	else
	{
#ifdef PARALLEL
		// assert that there are 3 color planes                                                                                                                                                                    
		for (int t = 1; t <= NUM_THREADS; t++)
		{
			if (t == NUM_THREADS)
				numRowsInBlock += numRows % NUM_THREADS;

			workers.push_back(thread(copyToMatBGR_RowMaj<ImageDataType>, &imgData[startRowIdx*nChannels], &dst[startRowIdx*nChannels], numRowsInBlock, numCols, nChannels));
			startRowIdx = numRowsInBlock;
			numRowsInBlock = startRowIdx + blocks;
		}
#else
     	copyToMatBGR_RowMaj<ImageDataType>(imgData, dst, numRows, numCols, nChannels);
#endif
	}

#ifdef PARALLEL
	for (thread &th : workers)
		th.join();
#endif
}

template <typename ImageDataType>
void copyToArray(ImageDataType *src, ImageDataType *dst, int startRowIdx, int numRowsInBlock , int numRows, int numCols)
{
	// src: row major (OpenCV output)
	// dst: column major (MATLAB MEX or EXE)

    for( int i = startRowIdx; i < numRowsInBlock; i++ )
    {
        for( int j = 0; j < numCols; j++ )
        {
            dst[i+j*numRows] = *src++;
        }
    }
}


template <typename ImageDataType>
void copyToArray_RowMaj(ImageDataType *src, ImageDataType *dst, int numRowsInBlock, int numCols)
{
	// src: row major (OpenCV output)
	// dst: row major (MATLAB MEX or EXE)
	memcpy(dst, src, numRowsInBlock*numCols*sizeof(ImageDataType));
}

template <typename ImageDataType>
void copyToArrayBGR(ImageDataType *src, ImageDataType *dst, int startRowIdx, int numRowsInBlock , int numRows, int numCols, int channels)
{
    int rc = numRows*numCols;

    for (int i = startRowIdx; i < numRowsInBlock; ++i)
    {
        for (int j = 0; j < numCols; ++j)
          {
            // Count backwards since OpenCV uses BGR ordering of color data                                                                                                                                        
            for (int k = channels-1; k >= 0; --k)
            {
                dst[i + j*numRows + k*rc] = *src++;
            }
        }
    }
}

template <typename ImageDataType>
void copyToArrayBGR_RowMaj(ImageDataType *src, ImageDataType *dst, int numRowsInBlock, int numCols, int channels)
{
    // used in cArrayFromMat_RowMaj
	// src: row major bgr triplet (OpenCV)
	// dst: row major rgb triplet (MATLAB MEX or EXE)
    
    /*
	ImageDataType *rIm = dst;
	ImageDataType *gIm = &dst[0];
	ImageDataType *bIm = &dst[2];
    */
	for (int ij = 0; ij < numCols*numRowsInBlock; ++ij)
	{
		// OpenCV uses BGR ordering so we need to supply the data
		// in the proper order
        /*
		bIm[ij] = *src++;
		gIm[ij] = *src++;
		rIm[ij] = *src++;
        */

		for (int k = channels - 1; k >= 0; --k){
			dst[k] = *src++;
		}
		dst += channels;
	}
}

template <typename ImageDataType>
void cArrayFromMat(ImageDataType *outFeatures, const cv::Mat &in)
{
    //const int nDims = (in.channels() == 1 ? 2 : 3);
    int dims[3];
    dims[0] = in.size().height;
    dims[1] = in.size().width;
    dims[2] = 3;

    ImageDataType *imgData = (ImageDataType *)outFeatures;
    const int   numRows(dims[0]), numCols(dims[1]);    

    ImageDataType *src = reinterpret_cast<ImageDataType *>(in.data);

#ifdef PARALLEL
    vector<thread> workers;
    int blocks = numRows / NUM_THREADS;
    int startRowIdx = 0, numRowsInBlock = blocks;
#endif

    // convert column-major to row-major and interleave pixel data. OpenCV
    // stores multi-channel data in the interleaved format.        
    if (in.channels() == 1)        
    {
#if PARALLEL
        for( int t = 1; t <= NUM_THREADS; t++ )
        {
            if( t == NUM_THREADS )
                numRowsInBlock += numRows % NUM_THREADS;

            workers.push_back( thread(copyToArray<ImageDataType>, &src[startRowIdx*numCols], imgData, startRowIdx, numRowsInBlock, numRows, numCols) );
            startRowIdx = numRowsInBlock;
            numRowsInBlock = startRowIdx + blocks;
        }
#else
        // assert (nDims == 2);
        for (int i = 0; i < numRows; ++i)       
        {         
            for (int j = 0; j < numCols; ++j) 
            {
                imgData[i + j*numRows] = *src++;
            }
        }
#endif
    }
    else
    {
#if PARALLEL
        // assert that there are 3 color planes (i.e., dims[2] == 3); 
        for( int t = 1; t <= NUM_THREADS; t++ )
        {
            if( t == NUM_THREADS )
                numRowsInBlock += numRows % NUM_THREADS;

            workers.push_back( thread(copyToArrayBGR<ImageDataType>, &src[startRowIdx*numCols*in.channels()], imgData, startRowIdx, numRowsInBlock, numRows, numCols, in.channels()) );
            startRowIdx = numRowsInBlock;
            numRowsInBlock = startRowIdx + blocks;
        }
#else
        int rc = numRows*numCols; 
        for (int i = 0; i < numRows; ++i)                
        {
            for (int j = 0; j < numCols; ++j)
            {
                // Count backwards since OpenCV uses BGR ordering of color data
                for (int k = in.channels()-1; k >= 0; --k)
                {
                    imgData[i + j*numRows + k*rc] = *src++;
                }
            }
        }
#endif
    }    

#ifdef PARALLEL     
    for( thread &th : workers )
        th.join();
#endif
}

template <typename ImageDataType>
void cArrayFromMat_RowMaj(ImageDataType *outFeatures, const cv::Mat &in)
{
	// in: row major (OpenCV output)
	// out: row major (MATLAB MEX or EXE)

	//const int nDims = (in.channels() == 1 ? 2 : 3);
	int dims[3];
	dims[0] = in.size().height;
	dims[1] = in.size().width;
	dims[2] = 3;

	ImageDataType *imgData = (ImageDataType *)outFeatures;
	const int   numRows(dims[0]), numCols(dims[1]);

	ImageDataType *src = reinterpret_cast<ImageDataType *>(in.data);

#ifdef PARALLEL
	vector<thread> workers;
	int blocks = numRows / NUM_THREADS;
	int startRowIdx = 0, numRowsInBlock = blocks;
#endif

	// convert column-major to row-major and interleave pixel data. OpenCV
	// stores multi-channel data in the interleaved format.        
	if (in.channels() == 1)
	{
#if PARALLEL
		for (int t = 1; t <= NUM_THREADS; t++)
		{
			if (t == NUM_THREADS)
				numRowsInBlock += numRows % NUM_THREADS;

			workers.push_back(thread(copyToArray_RowMaj<ImageDataType>, &src[startRowIdx*numCols], &imgData[startRowIdx*numCols], numRowsInBlock, numCols));
			startRowIdx = numRowsInBlock;
			numRowsInBlock = startRowIdx + blocks;
		}
#else
		// making rowMajor grayscale image to rowMajor grayscale image
		copyToArray_RowMaj<ImageDataType>(src, imgData, numRows, numCols);
#endif
	}
	else
	{
#if PARALLEL
		// assert that there are 3 color planes (i.e., dims[2] == 3); 
		for (int t = 1; t <= NUM_THREADS; t++)
		{
			if (t == NUM_THREADS)
				numRowsInBlock += numRows % NUM_THREADS;

			workers.push_back(thread(copyToArrayBGR_RowMaj<ImageDataType>, &src[startRowIdx*in.channels()], &imgData[startRowIdx*in.channels()], numRowsInBlock, numCols, in.channels()));
			startRowIdx = numRowsInBlock;
			numRowsInBlock = startRowIdx + blocks;
		}
#else
		copyToArrayBGR_RowMaj<ImageDataType>(src, imgData, numRows, numCols, in.channels());
#endif
	}

#ifdef PARALLEL     
	for (thread &th : workers)
		th.join();
#endif
}

EXTERN_C LIBMWCVSTRT_API void cvRectToBoundingBox(const std::vector<cv::Rect> & rects, int32_T *boundingBoxes);
EXTERN_C LIBMWCVSTRT_API void cvRectToBoundingBoxRowMajor(const std::vector<cv::Rect> & rects, int32_T *boundingBoxes);


#endif //CGCOMMON_HPP

