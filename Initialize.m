addpath(genpath('.'))
% coder.checkGpuInstall('full')
% Set the missing paths in Windows by 
% control sysdm.cpl
% Platform	Variable Name	Default Value	Description
% Windows®	CUDA_PATH	C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0\	
% Path to the CUDA® toolkit installation.
% 
% NVIDIA_CUDNN	C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\cuDNN\	
% Path to the root folder of cuDNN installation. The root folder contains the bin, include, and lib subfolders.
% 
% OPENCV_DIR	C:\Program Files\opencv\build	
% Path to the build folder of OpenCV. This variable is required for building deep learning examples.
% 
% PATH	C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0\bin	
% Path to the CUDA executables and dynamic libraries. Generally, this value is set automatically by the CUDA installer.
% 
% C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\cuDNN\bin	
% Path to the cudnn.dll dynamic library. The name of this library may be different on your installation.
% 
% C:\Program Files\opencv\build\x64\vc12\bin	
% Path to the Dynamic-link libraries (DLL) of OpenCV. This variable is 