all:	
	nvcc -o "codegen/lib/detect_lane/lanenet.exe" main_lanenet.cpp \
   -L"codegen/lib/detect_lane" detect_lane.lib \
   -I"$(OPENCV_DIR)\include" -I"codegen/lib/detect_lane" -I"$(MATLAB_ROOT)/extern/include" \
   -I"$(NVIDIA_CUDNN)\include" \
   -Xcompiler "/MD" \
   "$(NVIDIA_CUDNN)\lib\x64\cudnn.lib" -lcublas \
   -lcudart -lcusolver  -L"$(OPENCV_DIR)\lib" \
   -lopencv_imgproc310 -lopencv_core310 -lopencv_highgui310 -lopencv_video310 -lopencv_videoio310 