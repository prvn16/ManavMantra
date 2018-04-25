%% Integrating GPU Coder(TM) into Simulink(R)
%
% This example shows how to integrate GPU Coder(TM) into Simulink(R). While GPU
% Coder is not supported for Simulink blocks, you can still leverage GPUs
% in Simulink by generating a dynamic linked library (dll) using GPU Coder
% and then integrating it into a Simulink block using
% <matlab:doc('coder.ExternalDependency') coder.ExternalDependency> APIs.
% Sobel edge detection is used as an
% example to demonstrate this concept.

%   Copyright 2017 The MathWorks, Inc.

%% Prerequisites
% * CUDA-enabled NVIDIA(R) GPU with compute capability 3.0 or higher.
% * NVIDIA CUDA toolkit.
% * Environment variables for the compilers and libraries. For more 
% information see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
% * Simulink to create the model in Simulink.
% * Computer Vision System Toolbox to use the video reader and viewer used
% in the example.

%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_in_simulink');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% Sobel edge detection
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_in_simulink','sobelEdge.m')) sobelEdge.m>
% function takes an image (represented as a single matrix) and returns an image with the edges detected.
type sobelEdge

%% Generate a DLL for the function
% To run this function on the GPU from Simulink, generate a shared
% library by using GPU Coder and call the generated code (library) from Simulink by using
% <matlab:doc('coder.ExternalDependency') coder.ExternalDependency> APIs.
% Copy the generated library to top level directory.
Isize = single(zeros(240, 320));
cfg = coder.gpuConfig('dll');
codegen -args {Isize} -config cfg sobelEdge
if ispc
    copyfile(fullfile(pwd, 'codegen','dll', 'sobelEdge','sobelEdge.dll'), pwd);
else
    copyfile(fullfile(pwd, 'codegen','dll', 'sobelEdge','sobelEdge.so'), pwd);
end

%%
% Before generating C/CUDA code, you should first test the MEX function in
% MATLAB(R) to ensure that it is functionally equivalent to the original 
% MATLAB code and that no run-time errors occur.

%% Define coder.ExternalDependency API to Invoke the Generated Code
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_in_simulink','SobelAPI.m')) SobelAPI.m>
% is a class that defines the API to invoke the generated DLL. Most of this
% function is a standard template. The method of interest is SobelAPI.sobelEdge,
% which is called to execute the DLL. This function simply invokes the
% sobelEdge DLL through a <matlab:doc('coder.ceval') coder.ceval> call.
type SobelAPI

%% Create a Simulink Model that Integrates the API to the DLL
% In Simulink, create a MATLAB function block that calls
% SobelAPI.sobelEdge. This is equivalent to executing the GPU coder generated
% DLL code. Thus, when the MATLAB function block executes, this DLL will
% run on your host machine's GPU. And similarly for code-generation from Simulink, the CUDA
% code will be invoked. The Simulink model uses a video reader and a video
% display to show the effect of the algorithm.
open_system('gpucoder_sobelEdge');
set_param('gpucoder_sobelEdge', 'SimulationCommand', 'update'); 


%% Run the Simulink Model (The Sobel Filter)
% Run simulation to see the effect of the Sobel algorithm.
sim('gpucoder_sobelEdge', 'timeout', 30);

%% Cleanup
% Remove files and return to the original folder
%% Run Command: Cleanup
close_system('gpucoder_sobelEdge');
cleanup

displayEndOfDemoMessage(mfilename)
