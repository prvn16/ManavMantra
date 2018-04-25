%% Multi-Platform Deep Learning Targeting
%
% This example shows how to deploy deep learning networks to Intel(R)
% processors, NVIDIA(R) GPUs, and ARM(R) processors. Depending on the
% target library selected, the generated code that takes advantage of the Intel
% Math Kernel Library for Deep Neural Networks (MKL-DNN), the CUDA(R) Deep
% Neural Network (cuDNN) and TensorRT(TM) libraries and ARM Compute library.
% Logo classification is used as an example to demonstrate this concept.
% The logo classification application uses the |LogoNet| series network to
% perform logo recognition from images.

% Copyright 2018 The MathWorks, Inc.


%% Prerequisites
% * OpenCV 3.1.0 libraries for video read and image display operations.
% * Environment variables for the compilers and libraries. More specifically,
% you must set the |INTEL_MKLDNN|, |NVIDIA_CUDNN|, |NVIDIA_TENSORRT|,
% |ARM_COMPUTELIB|, and |LD_LIBRARY_PATH| environment variables to the
% appropriate locations. For information on the supported versions of the
% compilers and libraries, see
% <matlab:web(fullfile(docroot,'gpucoder/gs/install-prerequisites.html'))
% Third-party Products>. For setting up the environment variables, see
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
% * Neural Network Toolbox(TM) for using SeriesNetwork objects.
% * Image Processing Toolbox(TM) for reading and displaying images.
% * This example is supported only on the Linux® platform.

%% Create a New Folder and Copy Relevant Files
% The following lines of code creates a folder in your current working
% folder (pwd), and copies all the relevant files into this folder. If you
% do not want to perform this operation or if you cannot generate files in
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_multitarget_cnncodegen');

%% Get the Pre-Trained SeriesNetwork
% Download the pre-trained |LogoNet| network and save it as |logonet.mat|,
% if it does not already exist. The network was developed in MATLAB(R) and
% its architecture is similar to that of AlexNet. This network is capable
% of recognizing 32 logos under various lighting conditions and camera
% angles.
net = getLogoNet();

%%
% The network contains 22 layers including convolution, fully connected,
% and the classification output layers.
disp(net.Layers);

%% Generate Code for Intel Targets
% For Intel targets, code generation and execution is performed on the host
% development computer. To run the generated code, your development computer
% must have an Intel processor that supports Intel Advanced Vector
% Extension 2 (Intel AVX2) instructions. Use the <matlab:doc('cnncodegen') cnncodegen>
% command to generate code for Intel platform by using |'mkldnn'| option.
cnncodegen(net,'targetlib','mkldnn');

%% 1. Description of the Generated Code
% The |SeriesNetwork| is generated as a C++ class containing an array of 22
% layer classes. The setup() method of the class sets up handles and
% allocates memory for each layer object. The predict() method invokes
% prediction for each of the 22 layers in the network. The files
% |cnn_CnnMain_Conv_*_w| and |cnn_CnnMain_Conv_*_b| in the |codegen| folder
% are the binary weights and bias files for the convolution layers in the
% network. The files |cnn_CnnMain_fc_*_w| and |cnn_CnnMain_fc_*_b| are the
% binary weights and bias files for the fully connected layers in the
% network. |cnnbuild_rtw.mk| is the generated Makefile and |cnnbuild| is
% obtained after building this Makefile.
%
%    class CnnMain
%    {
%      public:
%        int32_T batchSize;
%        int32_T numLayers;
%        real32_T *inputData;
%        real32_T *outputData;
%        MWCNNLayer *layers[22];
%      private:
%        MWTargetNetworkImpl *targetImpl;
%      public:
%        CnnMain();
%        void presetup();
%        void postsetup();
%        void setup();
%        void predict();
%        void cleanup();
%        ~CnnMain();
%   };
%
%
%% 2. Build and Execute
% Use |make| to build the |logo_recognition_exe| executable.
%
%   system(['make ','mkldnn']);
%%
% Run the executable with an input image file.
%
% <<gpucoderdemo_google.png>>
%
%   system(['./logo_recognition_exe ','test.png']);
%%
% The top five predictions for the input image file.
%
% <<gpucoderdemo_mkldnn_output.png>>
%

%% Generate Code for NVIDIA GPUs with TensorRT Support
% For NVIDIA targets with TensorRT, code generation and execution is
% performed on the host development computer. To run the generated code,
% your development computer must have an NVIDIA GPU with compute capability
% of at least 3.2. Use the <matlab:doc('cnncodegen') cnncodegen> command
% to generate code for NVIDIA platform by using |'tensorrt'| option. By
% default, the |cnncodegen| command generates code that uses 32-bit float
% precision for the tensor inputs to the network.
cnncodegen(net,'targetlib','tensorrt');

%% 1. Description of the Generated Code
% The generated code is similar to the code shown in previous section. The
% presetup() and postsetup() functions  perform additional configuration
% required for TensorRT. Layer classes in the generated code folder call
% into TensorRT libraries.

%% 2. Build and Execute
% Use |make| to build the |logo_recognition_exe| executable.
%
%   system(['make ','tensorrt']);
%%
% Run the executable with an input image file.
%
% <<gpucoderdemo_google.png>>
%
%   system(['./logo_recognition_exe ','test.png']);
%%
% The top five predictions for the input image file.
%
% <<gpucoderdemo_tensorrt_output.png>>
%

%% Generate |int8| Code for NVIDIA GPUs with TensorRT Support
% For NVIDIA targets with TensorRT, code generation and execution is
% performed on the host development computer. To run the generated code,
% your development computer must have an NVIDIA GPU (For example, Titan XP)
% with compute capability of at least 6.0 and support |int8| computations.
% Use the <matlab:doc('cnncodegen') cnncodegen> command to generate code
% for NVIDIA platform by using |'tensorrt'| option. To generate code that
% uses 8-bit integer precision for the tensor inputs to the network, pass
% an extra argument |targetparams| with the value |tensorrtParams|.
% |tensorrtParams| is a struct with fields |DataType|, |DataPath|, |NumCalibrationBatches|.
%
% * |DataType| refers to precision and can be either INT8 or FP32.
% * |DataPath| points to the location of image dataset that is used for
%   calibration.
% * |NumCalibrationBatches| specifies the number of batches used by tensorRT for calibrating
%   for int8 inference. This is used along with the 'batchsize' value supplied when calling cnncodegen.
%   Here batchsize is set to a default value of 1 and NumCalibrationBatches is set to 300.
 tensorrtParams = struct('DataType','INT8','DataPath','logos_dataset','NumCalibrationBatches', 300);
 disp(tensorrtParams);
%%
% Use the following lines of code to generate code for an NVIDIA GPU using
% TensorRT int8 precision. Provide an appropriate value for location of
% your image data.
%
  
   cnncodegen(net,'targetlib','tensorrt','targetparams',tensorrtParams);

%% 1. Calibration in TensorRT for |int8| Precision
% Calibration in TensorRT int8 refers to quantizing the floating point data to
% int8,TensorRT performs a calibration phase with a reduced set of
% calibration data.
%
%%
% |cnncodegen| expects the calibration data to be present in the image data
% location specified in DataPath field of tensorrtParams.The images should
% be in folders with the same name as the labels corresponding to the
% images.
%%
% Organization of calibration data into subfolders for logo classification.
%
   dir(tensorrtParams.DataPath)

%%
% During codegen,  this data is reformatted into multiple batches, as specified by the tensorRT documentation.
% Each batch contains data in the following format:
%%
%   [n c h w imagedata1 imagedata2 ... labelindexOfImagedata1 labelindexOfImagedata2...]
%   n - Batchsize in single precision
%   c - Number of channels in single precision
%   h - Height of the image in single precision
%   w - Width of the image in single precision
%   imagedata* - Image data in single precision
%   labelindexOfImagedata* - Index of the image class from the classification file that matches with given imagedata class. Data type is of single precision.

%%
% The generated batches are used for calibration and generation of the calibration
% table. The calibration table contains the scale factors for weights,
% bias, and outputs of each layer. The calibration table is used for
% TensorRT int8 inference.
%

%% 2. Description of the Generated Code
% The generated code is similar to the code shown in previous section. The
% presetup() and postsetup() functions  perform additional configuration
% required for TensorRT int8 inference. Calibration of inputs and weights happens
% during the postsetup phase.

%% 3. Build and Execute
% Use |make| to build the |logo_recognition_exe| executable.
%
%   system(['make ','tensorrt_int8']);
%%
% Run the executable with an input image file.
%
% <<gpucoderdemo_google.png>>
%
%   system(['./logo_recognition_exe ','test.png']);
%%
% The top five predictions for the input image file.
%
% <<gpucoderdemo_tensorrtint8_output.png>>

%% Generate Code for ARM Targets
% Code generation for ARM processors using ARM Compute Library is done on
% host development computer, but the build and execution is performed on
% the target platform by copying all the generated files to the platform. The
% target platform must support Neon instruction set architecture (ISA).
% Raspberry Pi3, Firefly, HiKey are some of the target platforms on which
% the generated code can be executed. Use the <matlab:doc('cnncodegen') cnncodegen>
% command to generate code for the ARM platform by using |'arm-compute'|
% option.
%
%   cnncodegen(net,'targetlib','arm-compute');

%% 1. Description of the Generated Code
% The generated code is the same as in previous section. The postsetup()
% function does the allocation of buffers for each layer. These buffers are
% used by ARM Compute Library during inference.

%% 2. Build and Execute
% Move the codegen folder and all the desired files from the host
% development computer to the target platform using the |scp| command of the
% format, |system('sshpass -p [password] scp (sourcefile) [username]@[hostname]:~/');|
%
% For example, to transfer the files to the Raspberry Pi
%
%   system('sshpass -p alarm scp main.cpp alarm@alarmpi:~/');
%   system('sshpass -p alarm scp test.png alarm@alarmpi:~/');
%   system('sshpass -p alarm scp Makefile alarm@alarmpi:~/');
%   system('sshpass -p alarm scp synsetWords.txt alarm@alarmpi:~/');
%   system('sshpass -p alarm scp -r codegen alarm@alarmpi:/home/alarm');
%%
% To build the lib on target platform use the command of the
% format, |system('sshpass -p [password] ssh [username]@[hostname] "make -C
% /home/$(username)/codegen -f cnnbuild_rtw.mk"');|
%
% For example, on the Raspberry Pi
%
%   system('sshpass -p alarm ssh alarm@alarmpi "make -C /home/alarm/codegen -f cnnbuild_rtw.mk"');
%%
% Set the ARM_COMPUTELIB environment variable on the target platform
% pointing to the armcompute library install path.
% Use the command of format, |export ARM_COMPUTELIB=${DESTINATION_PATH}|
%
% For example, on the Raspberry Pi
%
%   export ARM_COMPUTELIB=${HOME}/ComputeLibrary
%
% Similarly set the TARGET_OPENCV_DIR on the target platform.
%
%   export TARGET_OPENCV_DIR=/usr
%
% To build and run the exe on target platform use the command of the
% format, |make -C /home/$(username)| and |./execfile|
%
% For example, on the Raspberry Pi
%
%   make -C /home/alarm arm_neon
%
%%
% Run the executable with an input image file.
%
% <<gpucoderdemo_google.png>>
%
%   ./logo_recognition_exe test.png
%%
% The top five predictions for the input image file.
%
% <<gpucoderdemo_arm_neon_output.png>>
%

%% Cleanup
% Remove files and return to original folder.
% cleanup

displayEndOfDemoMessage(mfilename)
