# Copyright 2017-2018 The MathWorks, Inc.
ifeq ($(OS),Windows_NT)
    CODEGEN_LIB := cnnbuild.lib    
    CUDNN_LIB_PATH := $(NVIDIA_CUDNN)\lib\x64
    OPENCV_LIB_PATH := $(OPENCV_DIR)\lib 
    OPENCV_FLAG :=  -I"$(OPENCV_DIR)\include" \
                    -L"$(OPENCV_LIB_PATH)" \
                    -lopencv_imgproc310 -lopencv_core310 -lopencv_highgui310 \
                    -lopencv_video310 -lopencv_videoio310 -lopencv_objdetect310   
    COMPILER_FLAG :=  -Xcompiler "/MD"
else
    CODEGEN_LIB := cnnbuild.a    
    CUDNN_LIB_PATH := $(NVIDIA_CUDNN)/lib64
    OPENCV_FLAG :=  -I"$(OPENCV_DIR)/include" \
                    -L"$(OPENCV_DIR)/lib" \
                    -lopencv_imgproc -lopencv_core -lopencv_highgui \
                    -lopencv_video -lopencv_videoio -lopencv_objdetect    
   COMPILER_FLAG := 
endif

all:	
	nvcc -o object_detection_exe main.cu \
         -Icodegen codegen/${CODEGEN_LIB} \
         -lcublas \
         -I"$(NVIDIA_CUDNN)/include" -L"$(CUDNN_LIB_PATH)" -lcudnn \
         $(OPENCV_FLAG) $(COMPILER_FLAG) \
         -Wno-deprecated-gpu-targets