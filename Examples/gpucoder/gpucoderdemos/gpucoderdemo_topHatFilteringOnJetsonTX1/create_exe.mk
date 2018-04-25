all:
	nvcc -std=c++11 --relocatable-device-code=true -Wno-deprecated-gpu-targets -O3 -o topHatFiltering_exe *.cpp lib/imtophatDemo_gpu/*.cu -Ilib/imtophatDemo_gpu/ -lopencv_core -lopencv_highgui -lopencv_video -lopencv_imgproc
