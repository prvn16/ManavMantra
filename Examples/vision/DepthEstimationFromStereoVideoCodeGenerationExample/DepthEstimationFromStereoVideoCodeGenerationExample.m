%% Code Generation for Depth Estimation From Stereo Video 
% This example shows how to use the MATLAB(R) Coder(TM) to generate C code
% for a MATLAB function, which uses the |stereoParameters| object produced
% by Stereo Camera Calibrator app or the |estimateCameraParameters|
% function.  The example explains how to modify the MATLAB code in the
% <matlab:web(fullfile(docroot,'vision','examples','depth-estimation-from-stereo-video.html')); Depth Estimation From Stereo Video> example to support code
% generation.
%
% This example requires a MATLAB Coder license.

%   Copyright 2013-2014 The MathWorks, Inc.

%% Code Generation
% You can learn about the basics of code generation using the MATLAB(R) 
% Coder(TM) from the <matlab:web(fullfile(docroot,'vision','examples','introduction-to-code-generation-with-feature-matching-and-registration.html')); Introduction to Code Generation with Feature Matching and Registration>
% example.

%% Restructuring the MATLAB Code for C Code Generation
% MATLAB Coder requires MATLAB code to be in the form of a function in
% order to generate C code. Furthermore, the arguments of the function 
% cannot be MATLAB objects.
%
% This presents a problem for generating code from MATLAB code, which uses
% |cameraParameters| or |stereoParameters| objects, which are typically
% created in advance during camera calibration. To solve this problem, use
% the |toStruct()| method to convert the |cameraParameters| or the
% |stereoParameters| object into a struct. The struct can then be passed into
% the generated code.
%
% The restructured code for the main algorithm of <matlab:web(fullfile(docroot,'vision','examples','depth-estimation-from-stereo-video.html')); Depth Estimation From Stereo Video> example
% resides in a function called <matlab:edit('depthEstimationFromStereoVideo_kernel.m') 
% depthEstimationFromStereoVideo_kernel.m>.
% Note that |depthEstimationFromStereoVideo_kernel| is a function that
% takes a struct created from a |stereoParameters| object. Note also that
% it does not display the reconstructed 3-D point cloud, because the
% |showPointCloudFunction| does not support code generation.

%% Load the Parameters of the Stereo Camera
% Load the |stereoParameters| object, which is the result of calibrating
% the camera using either the |stereoCameraCalibrator| app or the
% |estimateCameraParameters| function.

% Load the stereoParameters object.
load('handshakeStereoParams.mat');

% Visualize camera extrinsics.
showExtrinsics(stereoParams);

% Convert the object into a struct, which can be passed into generated
% code.
stereoParamsStruct = toStruct(stereoParams);

%% Uncompress Video Files
% On Macintosh, vision.VideoFileReader does not support code generation for 
% reading compressed video. Uncompress the video files, and store them in
% the temporary directory.

if strcmp(computer(), 'MACI64')
    % Uncompress the left video.
    videoFileLeft = 'handshake_left.avi';
    reader = vision.VideoFileReader(videoFileLeft);
    writer = vision.VideoFileWriter(videoFileLeft);
    while ~isDone(reader)
        frame = step(reader);
        step(writer, frame);                
    end
    release(reader);
    release(writer);
    
    % Uncompress the right video.
    videoFileRight = 'handshake_right.avi';
    reader = vision.VideoFileReader(videoFileRight);
    writer = vision.VideoFileWriter(videoFileRight);
    while ~isDone(reader)
        frame = step(reader);
        step(writer, frame);                
    end    
    release(reader);
    release(writer);    
end

%% Compile the MATLAB Function Into a MEX File
% Use the codegen function to compile the |depthEstimationFromStereoVideo_kernel|
% function into a MEX-file. You can specify the '-report' option to generate
% a compilation report that shows the original MATLAB code and the associated
% files that were created during C code generation. You may want to create 
% a temporary directory where MATLAB Coder can store generated files. Note 
% that the generated MEX-file has the same name as the original MATLAB file
% with _mex appended, unless you use the -o option to specify the name of 
% the executable.
%
% MATLAB Coder requires that you specify the properties of all the input
% parameters. One easy way to do this is to define the input properties by
% example at the command-line using the -args option. For more information
% see
% <matlab:helpview(fullfile(docroot,'toolbox','coder','helptargets.map'),'define_by_example');
% Input Specification>.

% Define the properties of input struct.
compileTimeInputs  = {coder.typeof(stereoParamsStruct)};

% Generate code.
codegen depthEstimationFromStereoVideo_kernel -args compileTimeInputs;

%% Run the Generated Code

depthEstimationFromStereoVideo_kernel_mex(stereoParamsStruct);

%% Clean Up
% clear depthEstimationFromStereoVideo_kernel_mex;

%% Summary
% This example showed how to generate C code from MATLAB code that takes
% a |cameraParameters| or a |stereoParameters| object as input.
