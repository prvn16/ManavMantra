%% Object Detection
%
% This example shows how to generate CUDA(R) code from a SeriesNetwork object
% created for YOLO architecture trained for classifying the PASCAL dataset.
% YOLO is an object detection network that can classify objects in an image frame
% as well as the position of these objects. 
% Reference : 
% You Only Look Once: Unified, Real-Time Object Detection
% (Joseph Redmon, Santosh Divala and others).
%
%   Copyright 2017-2018 The MathWorks, Inc.
%% Prerequisites
% * CUDA(R) enabled NVIDIA(R) GPU with compute capability 3.2 or higher.
% * NVIDIA CUDA toolkit and driver.
% * NVIDIA cuDNN library (v7).
% * OpenCV 3.1.0 libraries for video read and image display operations.
% * Environment variables for the compilers and libraries. For information 
% on the supported versions of the compilers and libraries, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/install-prerequisites.html'))
% Third-party Products>. For setting up the environment variables, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
% * Neural Network Toolbox(TM) for using SeriesNetwork objects.
%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','cudnn','quiet');
%% Create a New Folder and Copy Relevant Files
% The following code will create a folder in your current
% working folder (pwd). The new folder will only contain the files
% that are relevant for this example. If you do not want to affect the
% current folder (or if you cannot generate files in this folder),
% you should change your working folder.
%% Run Command: Create a New Folder and Copy Relevant Files
gpucoderdemo_setup('gpucoderdemo_object_detection');
%% Get the Pre-trained SeriesNetwork

net = getYolo();

%%
% It contains 58 layers. These are convolution layers followed by leaky
% ReLU, and fully connected layers in the end.

disp(net.Layers);

%% Generate Code from SeriesNetwork
%%
% Generate code for the host platform.

cnncodegen(net);

%% Generated Code Description
% This generates the .cu and header files within the 'codegen'
% directory of the current folder. The files are compiled into a
% static library 'cnnbuild.a'.

%% 
% The SeriesNetwork is generated as a C++ class containing an array of 58 layer
% classes and 3 public functions.
%
%     class CnnMain
%     {
%       ....   
%       public:
%         CnnMain();
%         void setup();
%         void predict();
%         void cleanup();
%         ~CnnMain();
%     };
%
% The setup() method of the class sets up handles and allocates memory for
% each layer object.
% The predict() method invokes prediction for each of the 58 layers in the network.
%
% The files cnn_CnnMain_Convolution2DLayer*_w and cnn_CnnMain_Convolution2DLayer*_w are the
% binary weights and bias file for convolution layer in the network.
% The files cnn_CnnMain_FullyConnectedLayer*_w and cnn_CnnMain_FullyConnectedLayer*_b are the
% binary weights and bias file for fully connected layer in the network.

dir('codegen')

%% Main File 
% The main file creates and sets up the CnnMain network object with 
% layers and weights. It use the OpenCV VideoCapture method to 
% read frames from input video. It runs prediction for each frame
% fetching the output from the final fully connected layer.
%
% The class probabilities and bounding box values is read from the output 
% array and displayed. 
%
%     int main(int argc, char* argv[])
%     {    
% 
%         float *inputBuffer = (float*)calloc(sizeof(float),448*448*3);
%         float *outputBuffer = (float*)calloc(sizeof(float),1470);
% 
%         if ((inputBuffer == NULL) || (outputBuffer == NULL)) {
%             printf("ERROR: Input/Output buffers could not be allocated!\n");
%             exit(-1);
%         }
% 
%         CnnMain* net = new CnnMain;
% 
%         net->batchSize = 1;
%         net->setup();
% 
%         if (argc < 2)
%         {
%             printf("Pass in input video file name as argument\n");
%             return -1;
%         }
% 
%         VideoCapture cap(argv[1]); 
%         if (!cap.isOpened()) {
%             printf("Could not open the video capture device.\n");
%             return -1;
%         }
% 
%         namedWindow("Yolo Demo",CV_WINDOW_NORMAL);
%         cvMoveWindow("Yolo Demo", 0, 0);
%         resizeWindow("Yolo Demo", 1352,1013);    
% 
%         float fps = 0;
% 
%         cudaEvent_t start, stop;
%         cudaEventCreate(&start);
%         cudaEventCreate(&stop);        
% 
%         for(;;)
%         {      
% 
%             Mat orig;
%             cap >> orig;
%             if (orig.empty()) break;
% 
%             Mat im;
%             readData(inputBuffer, orig, im);
% 
%             cudaEventRecord(start);
%             cudaMemcpy(net->inputData, 
%                        inputBuffer, 
%                        sizeof(float)*448*448*3, 
%                        cudaMemcpyHostToDevice);
%             net->predict();
% 
%             cudaMemcpy(outputBuffer,
%                        net->layers[55]->getData(),
%                        sizeof(float)*1470,
%                        cudaMemcpyDeviceToHost);
% 
%             cudaEventRecord(stop);
%             cudaEventSynchronize(stop);
% 
%             float milliseconds = -1.0; 
%             cudaEventElapsedTime(&milliseconds, start, stop);
%             fps = fps*.9+1000.0/milliseconds*.1;	
% 
%             Mat resized;
%             resize(orig, resized, Size(1352,1013));
% 
%             writeData(outputBuffer, resized, fps);
%             imshow("Yolo Demo", resized);
%             if( waitKey(50)%256 == 27 ) break; // stop capturing by pressing ESC
%         }
%         destroyWindow("Yolo Demo");
% 
%         delete net;
% 
%         free(inputBuffer);
%         free(outputBuffer);
% 
%         return 0;
%     }
%% Build and Run Executable
%
% Run executable with an input video file.
% 
% 
%   video_input = fullfile(matlabroot, ...
%         'toolbox', 'vision', 'visiondata', 'viptrain.avi');
%     if ispc
%         system('make_win.bat');
%         system(['object_detection_exe.exe ', video_input]);
%     else
%         system('make');         
%         system(['./object_detection_exe ', video_input]);
%     end

%%
% Press escape to stop capturing at any time.
%
%% Input Screenshot
% <<object_detection_input.png>>
%% Output Screenshot 
% <<object_detection_output.png>>
%% Cleanup
% Remove the files and return to the original folder.
%% Run Command: Cleanup
cleanup
displayEndOfDemoMessage(mfilename)