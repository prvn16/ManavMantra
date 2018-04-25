all:	
	 nvcc -o codegen/lib/detect_lane/lanenet main_lanenet.cpp codegen/lib/detect_lane/detect_lane.a \
    -I"codegen/lib/detect_lane" -I"$(NVIDIA_CUDNN)/include" -I"$(OPENCV_DIR)/include" -I"$(MATLAB_ROOT)/extern/include" \
    -L"$(NVIDIA_CUDNN)/lib64" -lcudnn -lcublas -lcudart \
    -L"$(OPENCV_DIR)/lib" \
    -lopencv_imgproc -lopencv_core -lopencv_highgui \
    -lopencv_video -lopencv_objdetect  -lopencv_videoio