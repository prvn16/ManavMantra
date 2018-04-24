%% Track Face (Raspberry Pi2)
% This example shows how to use the MATLAB(R) Coder(TM) to generate C code
% from a MATLAB file and deploy the application on ARM target. 
%
% The example reads video frames from a webcam. It detects a face using
% Viola-Jones face detection algorithm and tracks the face in a live video
% stream using the KLT algorithm. It finally displays the frame with a
% bounding box and a set of markers around the face being tracked. The webcam
% function, from 'MATLAB Support Package for USB Webcams', and the
% DeployableVideoPlayer object, from the Computer Vision System toolbox(TM),
% are used for the simulation on the MATLAB host. The two functions do not
% support the ARM target, so OpenCV-based webcam reader and video viewer
% functions are used for deployment.
%
% The target must have OpenCV version 3.1.0 libraries (built with GTK) and
% a standard C++ compiler. A Raspberry Pi 2 with Raspbian Wheezy operating
% system was used for deployment. The example should work on any ARM
% target.
%
% This example requires a MATLAB Coder license.
%
%   Copyright 2011-2017 The MathWorks, Inc.

%%
% This example is a function with the main body at the top and helper 
% routines in the form of 
% <matlab:helpview(fullfile(docroot,'toolbox','matlab','matlab_prog','matlab_prog.map'),'nested_functions') nested functions> 
% below.

function FaceTrackingARMCodeGenerationExample()

%% Set Up Your C++ Compiler
% To run this example, you must have access to a C++ compiler and you must
% configure it using 'mex -setup c++' command. For more information, see
% <matlab:web(fullfile(docroot,'matlab','matlab_external','choose-c-or-c-compilers.html'));
% Choose a C++ Compiler>.

%% Break Out the Computational Part of the Algorithm into a Separate MATLAB Function
% MATLAB Coder requires MATLAB code to be in the form of a function in
% order to generate C code. The code for the main algorithm of this example
% resides in a function called <matlab:edit('faceTrackingARMKernel.m')
% faceTrackingARMKernel.m>. The function takes an image from a webcam, as
% the input. The function outputs the image with a bounding box and a set
% of markers around the face. The output image will be displayed on video
% viewer window. To learn how to modify the MATLAB code to make it
% compatible for code generation, you can look at example
% <matlab:web(fullfile(docroot,'vision','examples','introduction-to-code-generation-with-feature-matching-and-registration.html'));
% Introduction to Code Generation with Feature Matching and Registration>
fileName = 'faceTrackingARMKernel.m';
visiondemoDir = pwd;
helperFilePath = pwd;
fileName = fullfile(helperFilePath, fileName);  

%% Create Main Function with I/O Functionality
% For a standalone executable target, MATLAB Coder requires that you create
% a C file containing a function named "main". This example uses
% faceTrackingARMMain.c file. This main function in this file performs the
% following tasks:
% 
% * Reads video frames from the webcam
% * Sends video frames to the face tracking algorithm
% * Displays output frames containing bounding box and markers around the face
%
% For simulation on MATLAB host, the tasks performed in
% faceTrackingARMMain.c file is implemented in faceTrackingARMMain.m

%% Webcam Reader and Video Viewer
% For deployment on ARM, this example implements webcam reader
% functionality using OpenCV functions. It also implements a video viewer
% using OpenCV functions. These OpenCV based utility functions are
% implemented in the following files:
%
% * helperOpenCVWebcam.hpp
% * helperOpenCVWebcam.cpp
% * helperOpenCVVideoViewer.cpp 
% * helperOpenCVVideoViewer.hpp 
%
% For simulation on MATLAB host, the example uses the webcam function from
% the 'MATLAB Support Package for USB Webcams' and the
% DeployableVideoPlayer object from the Computer Vision System toolbox. Run
% the simulation on the MATLAB host by typing faceTrackingARMMain at the
% MATLAB(R) command line.

%% OpenCV for ARM Target
% This example requires that you install OpenCV 3.1.0 libraries on your ARM
% target. The video viewer requires that you build the highqui library in
% OpenCV with GTK for the ARM target. 
%
% Follow the steps to download and build OpenCV 3.1.0 on Raspberry Pi 2
% with preinstalled Raspbian Wheezy. You must update your system firmware
% or install other developer tools and packages as needed for your system
% configuration before you start building OpenCV.
% Turn off INSTALL_C_EXAMPLES due to:
% https://github.com/opencv/opencv/issues/5851
%
% * $ wget -O opencv-3.1.0.zip https://github.com/opencv/opencv/archive/3.1.0.zip
% * $ unzip opencv-3.1.0.zip
% * $ cd opencv-3.1.0
% * $ mkdir build
% * $ cd build
% * $ cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=OFF -D BUILD_EXAMPLES=ON -D WITH_GTK=ON -D WITH_FFMPEG=OFF ..
%
% These steps are followed to compile and install OpenCV:
%
% * $ make
% * $ sudo make install
%
% For official deployment of the example, OpenCV libraries were installed
% in the following directory on Raspberry Pi 2:
% /home/pi/opencv-3.1.0/build/lib
%

%% Configure Code Generation Arguments
% Create a code generation configuration object for EXE output.
codegenArgs = createCodegenArgs(helperFilePath);

%% Setup Code Generation Environment
% Change output directory name.
codegenOutDir = fullfile(visiondemoDir, 'codegen');
mkdir(codegenOutDir);
cd(codegenOutDir); 

%% Generate Code
% Invoke codegen command.
fprintf('-> Generating Code (it may take a few minutes) ....\n');
codegen(codegenArgs{:}, fileName);
% During code generation, all dependent file information is stored in a mat
% file named buildInfo.mat.

%% Create the Packaged Zip-file
% Use build information stored in buildInfo.mat to create a zip folder
% using packNGo. 
fprintf('-> Creating zip folder (it may take a few minutes) ....\n');
bInfo = load(fullfile(codegenOutDir,'codegen','exe','faceTrackingARMKernel','buildInfo.mat'));
packNGo(bInfo.buildInfo, {'packType', 'hierarchical', ...
                          'fileName', 'faceTrackingARMKernel'}); 
% The generated zip folder is faceTrackingARMKernel.zip

%% Create Project Folder
% Unzip faceTrackingARMKernel.zip into a folder named FaceTrackingARM.
% Unzip all files and remove the .zip files.
packngoDir = hUnzipPackageContents(codegenOutDir);

%% Update Makefile and Copy to Project Folder
% The Makefile, faceTrackingARMMakefile, provided in this example is
% written for Raspberry PI 2 with specific optimization flags. The Makefile
% was written to work with a gcc compiler in a Linux environment and with
% your OpenCV libraries located in /home/pi/opencv-3.1.0/build/lib. You can
% update the Makefile based on your target configuration. Copy the Makefile
% to the project folder.
copyfile(fullfile(helperFilePath, 'faceTrackingARMMakefile'), packngoDir);
% Also move the file containing the main function in the top level folder.
copyfile(fullfile(helperFilePath, 'faceTrackingARMMain.c'), packngoDir);
% For simplicity, make sure the root directory name is matlab. 
setRootDirectory();

%% Deployment on ARM
% Deploy your project on ARM:
disp('Follow these steps to deploy your project on ARM');

%% Transfer Code to ARM Target
% Transfer your project folder named FaceTrackingARM to your ARM target
% using your preferred file transfer tool. Since the Raspberry Pi 2 (with
% Raspbian Wheezy) already has an SSH server, you can use SFTP to transfer
% files from host to target.
%
% For official deployment of this example, the FileZilla SFTP Client was
% installed on the host machine and the project folder was transferred from
% the host to the _/home/pi/<user_name>/FaceTrackingARM_ folder on
% Raspberry Pi.
disp('Step-1: Transfer the folder ''FaceTrackingARM'' to your ARM target');

%% Build the Executable on ARM
% Run the makefile to build the executable on ARM. For Raspberry Pi 2,
% (with Raspbian Wheezy), open a linux shell and cd to
% /home/pi/<user_name>/FaceTrackingARM. Build the executable using the
% following command: 
%
% _make -f faceTrackingARMMakefile_  
%
% The command creates an executable, faceTrackingARMKernel.
disp('Step-2: Build the executable on ARM using the shell command: make -f faceTrackingARMMakefile');

%% Run the Executable on ARM
% Run the executable generated in the above step. For Raspberry Pi 2,
% (with Raspbian Wheezy), use the following command in the shell window:
%
% _./faceTrackingARMKernel_
%
disp('Step-3: Run the executable on ARM using the shell command: ./faceTrackingARMKernel');
% To close the video viewer while the executable is running on Raspberry Pi2,
% click on the video viewer and press Escape button.

%% Appendix - Helper Functions 
    
    % Configure coder to create executable. Use packNGo at post code
    % generation stage.
    function codegenArgs = createCodegenArgs(folderForMainC)
        % Create arguments required for code generation.

        % First - create configuration object
        %
        % For standalone executable a main C function is required. The
        % faceTrackingARMMain.c created for this example is compatible
        % with the content of the file faceTrackingARMKernel.m
        mainCFile = fullfile(folderForMainC,'faceTrackingARMMain.c');

        % Include helper functions
        camCPPFile = fullfile(folderForMainC,'helperOpenCVWebcam.cpp');
        viewerCPPFile = fullfile(folderForMainC,'helperOpenCVVideoViewer.cpp');
        
        % Handle path with space
        if contains(mainCFile, ' ')
            mainCFile     = ['"' mainCFile '"'];
            camCPPFile    = ['"' camCPPFile '"'];
            viewerCPPFile = ['"' viewerCPPFile '"'];
        end
        
        % Create configuration object
        cfg = coder.config('exe');
        cfg.CustomSource       = sprintf('%s\n%s\n%s',mainCFile,camCPPFile,viewerCPPFile);
        cfg.CustomInclude      = folderForMainC;
        % Set production hardware to ARM to generate ARM compatible portable code 
        cfg.HardwareImplementation.ProdHWDeviceType = 'ARM Compatible->ARM Cortex';
        cfg.EnableOpenMP       = false;

        % Create input arguments
        inRGB_type = coder.typeof(uint8(0),[480 640 3]);
        % Use '-c' option to generate C code without calling C++ compiler.
        codegenArgs = {'-config', cfg, '-c', '-args', {inRGB_type}};

    end

    % Unzip the packaged zip file
    function packngoDir   = hUnzipPackageContents(packageLocation)

        lastDir        = cd(packageLocation);
        dirCleanup     = onCleanup(@()cd(lastDir));
        packngoDirName = 'FaceTrackingARM';

        % create packngo directory
        mkdir(packngoDirName);

        % get the name of the single zip file generated by packngo
        zipFile = dir('*.zip');
        assert(numel(zipFile)==1);

        unzip(zipFile.name,packngoDirName);

        % unzip internal zip files created in hierarchical packNGo
        zipFileInternal = dir(fullfile(packngoDirName,'*.zip'));

        for i=1:numel(zipFileInternal)
            unzip(fullfile(packngoDirName,zipFileInternal(i).name), ...
                packngoDirName);
        end
        % delete internal zip files
        delete(fullfile(packngoDirName,'*.zip'));
        packngoDir = fullfile(packageLocation,packngoDirName);
    end

    % Set root directory as matlab
    function setRootDirectory()
        dirList = dir(packngoDir);
        if isempty(find(ismember({dirList.name},'matlab'), 1))
            % root directory is not matlab. Change it to matlab
            for i=1:length(dirList)
                thisDir = fullfile(packngoDir,dirList(i).name, 'toolbox', 'vision');
                if isdir(thisDir)
                    % rename the dir
                    movefile(fullfile(packngoDir,dirList(i).name), ...
                             fullfile(packngoDir,'matlab'));
                    break;
                end
            end
        end
    end
end
