# Copyright 2017-2018 The MathWorks, Inc.

CODEGEN_LIB := cnnbuild.a
CUDNN_LIB_PATH := $(NVIDIA_CUDNN)/lib64
TENSORRT_LIB_PATH :=  $(NVIDIA_TENSORRT)/lib
MKLDNN_LIB_PATH :=  $(INTEL_MKLDNN)/lib
OPENCV_FLAGS :=  -I"$(OPENCV_DIR)/include" \
                -L"$(OPENCV_DIR)/lib" \
                -lopencv_imgproc -lopencv_core -lopencv_highgui \
                -lopencv_video -lopencv_videoio -lopencv_objdetect -lopencv_imgcodecs
COMPILER_FLAG :=
TARGET_OPENCV_FLAGS :=  -I"$(TARGET_OPENCV_DIR)/include" \
                 -L"$(TARGET_OPENCV_DIR)/lib" \
                 -lopencv_imgproc -lopencv_core -lopencv_highgui \
                 -lopencv_video -lopencv_videoio -lopencv_objdetect -lopencv_imgcodecs
cudnn:
	nvcc -o logo_recognition_exe main_gpu.cpp \
         -Icodegen codegen/${CODEGEN_LIB} \
         -lcublas \
         -I"$(NVIDIA_CUDNN)/include" -L"$(CUDNN_LIB_PATH)" -lcudnn \
         $(OPENCV_FLAGS) $(COMPILER_FLAG) \
         -Wno-deprecated-gpu-targets
mkldnn:
	g++ -std=c++11 -o logo_recognition_exe main.cpp \
         -Icodegen codegen/${CODEGEN_LIB} \
         -I"$(INTEL_MKLDNN)/include" -L"$(MKLDNN_LIB_PATH)" -lmkldnn -liomp5 \
         $(OPENCV_FLAGS) $(COMPILER_FLAG)
tensorrt:
	nvcc -o logo_recognition_exe main_gpu.cpp \
         -Icodegen codegen/${CODEGEN_LIB} \
         -lcublas -lcudart -lcusolver \
         -I"$(NVIDIA_CUDNN)/include" -L"$(CUDNN_LIB_PATH)" -lcudnn \
         -I"$(NVIDIA_TENSORRT)/include" -L"$(TENSORRT_LIB_PATH)" -lnvinfer -lnvinfer_plugin -lnvcaffe_parser\
         $(OPENCV_FLAGS) $(COMPILER_FLAG) \
         -Wno-deprecated-gpu-targets
tensorrt_int8:
	nvcc -DINT8_ENABLED -o logo_recognition_exe main_gpu.cpp \
         -Icodegen codegen/${CODEGEN_LIB} \
         -lcublas -lcudart -lcusolver \
         -I"$(NVIDIA_CUDNN)/include" -L"$(CUDNN_LIB_PATH)" -lcudnn \
         -I"$(NVIDIA_TENSORRT)/include" -L"$(TENSORRT_LIB_PATH)" -lnvinfer -lnvinfer_plugin -lnvcaffe_parser\
         $(OPENCV_FLAGS) $(COMPILER_FLAG) \
         -Wno-deprecated-gpu-targets
arm_neon:
	g++ -march=armv7-a -std=gnu++11 -o logo_recognition_exe main.cpp \
         -Icodegen ${CODEGEN_LIB} \
         -I"$(ARM_COMPUTELIB)/include" -I"$(ARM_COMPUTELIB)" -rdynamic  -L"$(ARM_COMPUTELIB)/lib" -rdynamic -Wl,-rpath,$(ARM_COMPUTELIB)/lib:-larm_compute \
         $(TARGET_OPENCV_FLAGS) $(COMPILER_FLAG)
