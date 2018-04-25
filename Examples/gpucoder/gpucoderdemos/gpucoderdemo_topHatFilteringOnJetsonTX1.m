%% Top Hat Filtering to Remove Uneven Background Illumination on Jetson TX1
% This example shows how to deploy Image Processing Toolbox(TM) algorithms 
% to a NVIDIA(R) Jetson TX1 board. The <matlab:doc('imtophat') imtophat> 
% function that performs morphological top-hat filtering on a grayscale 
% image is used as an example to demonstrate this concept. Top-hat 
% filtering computes the morphological opening of the image (using 
% <matlab:doc('imopen') imopen>) and then subtracts the result from the 
% original image. This examples uses the |codegen| command to generate C++ 
% code for the ARM(R) CPU and CUDA(r) code for the NVIDIA Tegra(R) GPU on 
% the TX1. The generated CUDA code uses shared memory to speedup the 
% operations on the GPU. The generated files are then transferred to the
% TX1 where they are built and executed.

%% Prerequisites
% * CUDA(R) enabled NVIDIA(R) GPU with compute capability 3.2 or higher.
% * NVIDIA(R) CUDA toolkit and driver.
% * OpenCV 3.1.0 libraries for video read and image display operations.
% * Environment variables for the compilers and libraries. For information 
% on the supported versions of the compilers and libraries, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/install-prerequisites.html'))
% Third-party Products>. For setting up the environment variables, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
% * Image Processing Toolbox(TM) for reading and displaying images.
% * This example is supported only on the Linux® platform.

%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_topHatFilteringOnJetsonTX1');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('tx1','quiet');

%% About the 'imtophat' Function
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_topHatFilteringOnJetsonTX1','imtophatDemo_gpu.m')) imtophatDemo_gpu>
% calls |imtophat| internally. The |imtophat| function performs
% morphological opening on the image using the <matlab:doc('imopen') imopen>
% function. The result of the image is subtracted from the original image.
% The |imopen| operation is basically <matlab:doc('imerode') imerode> operation followed by
% <matlab:doc('imdilate') imdilate>.
type imtophatDemo_gpu

%% Read and Display Input Image
%
% Read a grayscale image and create a disc-shaped structuring element with a radius of 12.
original = imread('rice.png');
se = strel('disk',12);
Nhood = se.Neighborhood;

%% Input to the *imtophat* function
% <<gpucoderdemo_topHatFilteringOnJetsonTX1_input.png>>

%% GPU Codegen for Source Files
% Since Jetson TX1 is an ARM platform, we generate a standalone code using
% |'lib'| option. Also, we explicitly specify the target hardware
% implementation & toolchain to generate the code for Jetson TX1 target.
cfg = coder.gpuConfig('lib');
cfg.GenCodeOnly = true;
cfg.HardwareImplementation.ProdHWDeviceType = 'ARM Compatible->ARM Cortex';
cfg.HardwareImplementation.TargetHWDeviceType='ARM Compatible->ARM Cortex';
cfg.Toolchain = 'NVIDIA CUDA for Jetson Tegra X1 | gmake (64-bit Linux)';
codegen -args {original,coder.Constant(Nhood)} -config cfg imtophatDemo_gpu

%% Main File
% A custom main file contains the entry-point function, which internally
% calls the generated library function. This entry-point function uses
% OpenCV API calls to read an image, convert it from a row-major to
% column-major data, and calls the |imtophat| function.

%% Copy Files to the Codegen Directory
% Copy the files required for the executable.
copyfile('create_exe.mk', fullfile('codegen', 'create_exe.mk'));
copyfile('main.cpp', fullfile('codegen', 'main.cpp'));
copyfile('rice.png', fullfile('codegen', 'rice.png'));

% Copy header to main directory since, the compilation include path points
% to this directory.
copyfile(('codegen/lib/imtophatDemo_gpu/examples/main.h'), ('codegen/lib/imtophatDemo_gpu/main.h'));

%% Build and Run
% Copy the codegen folder to a directory in the TX1.
%
%  scp -r codegen username@jetson-tx1-name:/path/to/desired/location
%  
%  Example:
%  scp -r codegen/ ubuntu@172.18.226.150:
%
% On the TX1, navigate to the copied codegen directory and execute the
% following commands.
%
%  make -f create_exe.mk
% 
% Run the executable on the TX1 platform with the following command.
%
%  ./topHatFiltering_exe rice.png
%
% The imtophat operation is run on the same image iteratively. This
% speed of each iteration is computed as FPS.
% This displays input image accompanied by the output image, with FPS
% numbers on output image. To toggle between CPU and GPU versions of the
% code, press 't' on Keyboard.  Press escape at any time to quit.

%% Top-Hat Filtered Image on Jetson TX1
% <<gpucoderdemo_topHatFilteringOnJetsonTX1_output.png>>

%% Cleanup
% Run |cleanup| function to remove the generated files and return to the original folder.

%cleanup

displayEndOfDemoMessage(mfilename)
