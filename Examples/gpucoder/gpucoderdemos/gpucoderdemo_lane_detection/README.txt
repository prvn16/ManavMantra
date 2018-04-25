README
______________________________

Example to demonstrate code generation from a lane detection network.

This network takes video captured from a camera mounted on a vehicle and
outputs 2 lane boundaries that correspond to the vehicle's left and right lanes.
Each lane boundary is given by a parabolic equation : 
	 y = ax^2 + bx + c
where y is the lateral offset and x is the longitudinal distance from the vehicle.
The network predicts the 3 parameters a,b,c per lane.

The script lanenet_codegen_host_demo.m 
 - Loads a SeriesNetwork alexnet.mat and
   generates CUDA code from the Series Network targeting to a host GPU. 
 - Code generation generates a static library cnnbuild.a that is compiled 
   with a custom main file. 
 - Additional post processing is done in MATLAB to convert the
   network outputs to lane boundaries in the image,
   which is also code generated to CUDA.   
 - Run the generated lanenet executable to see lane boundaries detected in the 
   video captured from ego vehicle's camera.
________________________________

Pre-requisites:
 
1. Neural network toolbox to generate the Series Network object
2. CUDA®-enabled NVIDIA® GPU with compute capability 3.0 or higher.
3. CUDNN 5.0 and NVIDIA_CUDNN environment variable pointing to 
   CUDNN installation path. 
4. OpenCV 2.4.9 libraries for video read and image display operations. 
   Opencv header and library files should be in nvcc compiler search path.
_________________________________
