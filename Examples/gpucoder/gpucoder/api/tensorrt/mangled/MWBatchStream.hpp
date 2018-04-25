#ifndef MWBATCH_STREAM_HPP
#define MWBATCH_STREAM_HPP

#include <vector>
#include <assert.h>
#include <algorithm>
#include "NvInfer.h"

/* This file contains the classes ,used to parse the claibration data set .
 * Parsed data is used by TensorRT for creating the Calibration Table 
 * which is then used for int8 execution*/

extern void getValidDataPath(const char* fileName, char *validDatapath);
extern std::string gvalidDatapath;

class BatchStream {
public:
    BatchStream(int batchSize, int maxBatches)
        : mBatchSize(batchSize)
        , mMaxBatches(maxBatches) {
		char filename[500],filename1[500];
#if defined(_WIN32) || defined(_WIN64)
        sprintf(filename," |>targetdirwindows<|\\tensorrt\\batch0");
#else
        sprintf(filename," |>targetdir<|/tensorrt/batch0");
#endif
	    getValidDataPath(filename,filename1);
        FILE *file = fopen(filename1,"rb");
        if (file == NULL) {
                     printf("Unable to open file\n");
                     exit(1);
                }   
		int d[4];
		fread(d, sizeof(int), 4, file);
		mDims = nvinfer1::DimsNCHW{ d[0], d[1], d[2], d[3] };
		fclose(file);
		mImageSize = mDims.c()*mDims.h()*mDims.w();
		mBatch.resize(mBatchSize*mImageSize, 0);
		mLabels.resize(mBatchSize, 0);
		mFileBatch.resize(mDims.n()*mImageSize, 0);
		mFileLabels.resize(mDims.n(), 0);
		reset(0);
	}

    void reset(int firstBatch) {
		mBatchCount = 0;
		mFileCount = 0;
		mFileBatchPos = mDims.n();
		skip(firstBatch);
	}

    bool next() {
        if (mBatchCount == mMaxBatches) {
			return false;
        }

        for (int csize = 1, batchPos = 0; batchPos < mBatchSize;
             batchPos += csize, mFileBatchPos += csize) {
			assert(mFileBatchPos > 0 && mFileBatchPos <= mDims.n());
            if (mFileBatchPos == mDims.n() && !update()) {
				return false;
            }

			// copy the smaller of: elements left to fulfill the request, or elements left in the file buffer.
			csize = std::min(mBatchSize - batchPos, mDims.n() - mFileBatchPos);
            std::copy_n(getFileBatch() + mFileBatchPos * mImageSize, csize * mImageSize,
                        getBatch() + batchPos * mImageSize);
			std::copy_n(getFileLabels() + mFileBatchPos, csize, getLabels() + batchPos);
		}
		mBatchCount++;
		return true;
	}

    void skip(int skipCount) {
        if (mBatchSize >= mDims.n() && mBatchSize % mDims.n() == 0 && mFileBatchPos == mDims.n()) {
			mFileCount += skipCount * mBatchSize / mDims.n();
			return;
		}

		int x = mBatchCount;
        for (int i = 0; i < skipCount; i++) {
			next();
        }
		mBatchCount = x;
	}

    float* getBatch() {
        return &mBatch[0];
    }
    float* getLabels() {
        return &mLabels[0];
    }
    int getBatchesRead() const {
        return mBatchCount;
    }
    int getBatchSize() const {
        return mBatchSize;
    }
    nvinfer1::DimsNCHW getDims() const {
        return mDims;
    }
private:
    float* getFileBatch() {
        return &mFileBatch[0];
    }
    float* getFileLabels() {
        return &mFileLabels[0];
    }

    bool update() {
		char filename[500],filename1[500];
#if defined(_WIN32) || defined(_WIN64)
        sprintf(filename," |>targetdirwindows<|\\tensorrt\\batch");
#else
        sprintf(filename," |>targetdir<|/tensorrt/batch");
#endif
        std::string inputFileName = filename + std::to_string(mFileCount++);
        getValidDataPath(inputFileName.c_str(),filename1);
        FILE *file = fopen(filename1,"rb");
        if (!file) {
			return false;
        }

		int d[4];
		fread(d, sizeof(int), 4, file);
		assert(mDims.n() == d[0] && mDims.c() == d[1] && mDims.h() == d[2] && mDims.w() == d[3]);

		size_t readInputCount = fread(getFileBatch(), sizeof(float), mDims.n()*mImageSize, file);
        size_t readLabelCount = fread(getFileLabels(), sizeof(float), mDims.n(), file);
        ;
        assert(readInputCount == size_t(mDims.n() * mImageSize) &&
               readLabelCount == size_t(mDims.n()));

		fclose(file);
		mFileBatchPos = 0;
		return true;
	}

	int mBatchSize{ 0 };
	int mMaxBatches{ 0 };
	int mBatchCount{ 0 };

	int mFileCount{ 0 }, mFileBatchPos{ 0 };
	int mImageSize{ 0 };

	nvinfer1::DimsNCHW mDims;
	std::vector<float> mBatch;
	std::vector<float> mLabels;
	std::vector<float> mFileBatch;
	std::vector<float> mFileLabels;
};

extern void CHECK(cudaError_t status);

using namespace nvinfer1;
using namespace nvcaffeparser1;

class Int8EntropyCalibrator : public IInt8EntropyCalibrator {
public:
	Int8EntropyCalibrator(BatchStream& stream, int firstBatch, bool readCache = true)
        : mStream(stream)
        , mReadCache(readCache) {
		DimsNCHW dims = mStream.getDims();
		mInputCount = mStream.getBatchSize() * dims.c() * dims.h() * dims.w();
		CHECK(cudaMalloc(&mDeviceInput, mInputCount * sizeof(float)));
		mStream.reset(firstBatch);
	}

    virtual ~Int8EntropyCalibrator() {
		CHECK(cudaFree(mDeviceInput));
	}

    int getBatchSize() const override {
        return mStream.getBatchSize();
    }

    bool getBatch(void* bindings[], const char* names[], int nbBindings) override {
        if (!mStream.next()) {
			return false;
        }

        CHECK(cudaMemcpy(mDeviceInput, mStream.getBatch(), mInputCount * sizeof(float),
                         cudaMemcpyHostToDevice));
		assert(!strcmp(names[0], "data"));
		bindings[0] = mDeviceInput;
		return true;
	}

    const void* readCalibrationCache(size_t& length) override {
		mCalibrationCache.clear();
#if defined(_WIN32) || defined(_WIN64)
		gvalidDatapath.append("\\");
#else
		gvalidDatapath.append("/");
#endif
        gvalidDatapath.append("CalibrationTable");
        std::ifstream input(gvalidDatapath.c_str(), std::ios::binary);
		input >> std::noskipws;
        if (mReadCache && input.good()) {
            std::copy(std::istream_iterator<char>(input), std::istream_iterator<char>(),
                      std::back_inserter(mCalibrationCache));
        }

		length = mCalibrationCache.size();
		return length ? &mCalibrationCache[0] : nullptr;
	}

    void writeCalibrationCache(const void* cache, size_t length) override {
#if defined(_WIN32) || defined(_WIN64)
		gvalidDatapath.append("\\");
#else
		gvalidDatapath.append("/");
#endif
        gvalidDatapath.append("CalibrationTable");
		std::ofstream output(gvalidDatapath.c_str(), std::ios::binary);
		output.write(reinterpret_cast<const char*>(cache), length);
	}

private:
	BatchStream mStream;
	bool mReadCache{ true };

	size_t mInputCount;
	void* mDeviceInput{ nullptr };
	std::vector<char> mCalibrationCache;
};
#endif
