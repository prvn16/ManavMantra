%% Code Generation for Face Tracking with PackNGo
% This example shows how to generate code from
% <matlab:web(fullfile(docroot,'vision','examples','face-detection-and-tracking-using-the-klt-algorithm.html'));
% Face Detection and Tracking Using the KLT Algorithm> example with packNGo
% function. The <matlab:doc('packNGo'); |packNGo|> function packages all
% relevant files in a compressed zip file so you can relocate, unpack, and
% rebuild your project in another development environment without MATLAB
% present. This example also shows how to create a makefile for the packNGo
% content, rebuild the source files and finally run the standalone
% executable outside MATLAB environment.
%
% This example requires a MATLAB(R) Coder(TM) license.
%
%   Copyright 2011-2017 The MathWorks, Inc.

%%
% This example is a function with the main body at the top and helper 
% routines in the form of 
% <matlab:helpview(fullfile(docroot,'toolbox','matlab','matlab_prog','matlab_prog.map'),'nested_functions') nested functions> 
% below.

function FaceTrackingKLTpackNGoExample()

%% Set Up Your C++ Compiler
% To run this example, you must have access to a C++ compiler and you must
% configure it using 'mex -setup c++' command. For more information, see
% <matlab:web(fullfile(docroot,'matlab','matlab_external','choose-c-or-c-compilers.html'));
% Choose a C++ Compiler>. If you deploy the application on MATLAB host,
% use a C++ compiler that is compatible with the compiler used to build
% OpenCV libraries. For more information, see
% <matlab:web(fullfile(docroot,'vision','ug','portable-c-code-generation-for-functions-that-use-opencv-library.html'));
% Compiler used to build OpenCV libraries>.

%% Break Out the Computational Part of the Algorithm into a Separate MATLAB Function
% MATLAB Coder requires MATLAB code to be in the form of a function in
% order to generate C code. The code for the main algorithm of this example
% resides in a function called
% <matlab:edit('FaceTrackingKLTpackNGo_kernel.m')
% FaceTrackingKLTpackNGo_kernel.m>. This file is derived from
% <matlab:web(fullfile(docroot,'vision','examples','face-detection-and-tracking-using-the-klt-algorithm.html'));
% Face Detection and Tracking Using the KLT Algorithm>. To learn how to
% modify the MATLAB code to make it compatible for code generation, you can
% look at example
% <matlab:web(fullfile(docroot,'vision','examples','introduction-to-code-generation-with-feature-matching-and-registration.html'));
% Introduction to Code Generation with Feature Matching and Registration>
fileName = 'FaceTrackingKLTpackNGo_kernel.m';
visiondemo_dir = pwd;  
currentDir = pwd; % Store the current directory
fileName = fullfile(visiondemo_dir, fileName);

%% Configure Code Generation Arguments for |packNGo|
% Create a code generation configuration object for EXE output with packNGo
% function call in post code generation stage.
codegenArgs = createCodegenArgs(visiondemo_dir);

%% Setup Code Generation Environment
% Change output directory name.
codegenOutDir = fullfile(visiondemo_dir, 'codegen');
mkdir(codegenOutDir);
%%
% Add path to the existing directory to have access to necessary files.
currentPath = addpath(visiondemo_dir); 
pathCleanup = onCleanup(@()path(currentPath)); 
cd(codegenOutDir); 
dirChange = onCleanup(@()cd(currentDir));

%% Create the Packaged Zip-file
% Invoke codegen command with packNGo function call.
fprintf('-> Generating Code (it may take a few minutes) ....\n');
codegen(codegenArgs{:}, fileName);
%%
% Note that, instead of using codegen command, you can open a dialog and launch a code
% generation project using <matlab:doc('coder'); |coder|>. Use the post
% code generation command with packNGo function to create a zip file.

%% Build Standalone Executable
% Unzip the zip file into a new folder. Note that the zip file contains
% source files, header files, libraries, MAT-file containing the build
% information object, data files. |unzipPackageContents| and other helper
% functions are included in the appendix.
zipFileLocation  = codegenOutDir;
fprintf('-> Unzipping files ....\n');
unzipFolderLocation       = unzipPackageContents(zipFileLocation);
%%
% Create platform dependent makefile from a template makefile. 
fprintf('-> Creating makefile ....\n');
makefileName = createMakeFile(visiondemo_dir, unzipFolderLocation);
%%
% Create the commands required to build the project and to run it.
[~, fname, ~] = fileparts(fileName);
fprintf('-> Creating ''Build Command'' and ''Run command'' ....\n');
[buildCommand, runCommand] = createBuildAndRunCommands(zipFileLocation,...
    unzipFolderLocation,makefileName,fname);
%%
% Build the project using build command.
fprintf('-> Building executable....\n');
buildExecutable(unzipFolderLocation, buildCommand);

%% Run the Executable and Deploy
% Run the executable and verify that it works.
cd(unzipFolderLocation); 
system(runCommand);
%% 
% The application can be deployed in another machine by copying the
% executable and the library files.
isPublishing = ~isempty(snapnow('get'));
if ~isPublishing % skip printing out directory to html page
  fprintf('Executable and library files are located in the following folder:\n%s\n', unzipFolderLocation);
  fprintf('To re-execute run the following commands:\n');
  fprintf('1. cd(''%s'')\n', unzipFolderLocation);
  fprintf('2. system(''%s'')\n', runCommand);
end

%% Appendix - Helper Functions 
    
    % Configure coder to create executable. Use packNGo at post code
    % generation stage.
    function codegenArgs = createCodegenArgs(folderForMainC)
        % Create arguments required for code generation.

        % For standalone executable a main C function is required. The main.c
        % created for this example is compatible with the content of the file
        % visionFaceTrackingKLTpackNGo_kernel.m
        mainCFile = fullfile(folderForMainC,'main.c');

        % Handle path with space
        if contains(mainCFile, ' ')
            mainCFile = ['"' mainCFile '"'];
        end
        
        cfg                               = coder.config('exe');
        cfg.PostCodeGenCommand            = 'packNGo(buildInfo,''packType'',''hierarchical'');';
        cfg.CustomSource                  = mainCFile;
        cfg.CustomInclude                 = folderForMainC;
        cfg.EnableOpenMP                  = false;

        codegenArgs = {'-config', cfg};

    end

    % Create a folder and unzip the packNGo content into it.
    function unzipFolderLocation   = unzipPackageContents(zipFileLocation)
        % Unzip the packaged zip file.

        unzipFolderLocationName = 'unzipPackNGo';
        mkdir(unzipFolderLocationName);

        % Get the name of the zip file generated by packNGo.
        zipFile = dir('*.zip');

        assert(numel(zipFile)==1);

        unzip(zipFile.name,unzipFolderLocationName);

        % Unzip internal zip files created in hierarchical packNGo.
        zipFileInternal = dir(fullfile(unzipFolderLocationName,'*.zip'));
        assert(numel(zipFileInternal)==3);
        
        for i=1:numel(zipFileInternal)
            unzip(fullfile(unzipFolderLocationName,zipFileInternal(i).name), ...
                unzipFolderLocationName);
        end
        
        unzipFolderLocation = fullfile(zipFileLocation,unzipFolderLocationName);
    end

    % Create platform dependent makefile from template makefile. Use
    % buildInfo to get info about toolchain.
    function makefileName = createMakeFile(visiondemo_dir, unzipFolderLocation)
        % Create Makefile from buildInfo.
        
        binfo = load('buildInfo.mat');
        
        lastDir    = cd(unzipFolderLocation);
        dirCleanup = onCleanup(@()cd(lastDir));
        
        % Get the root directory that contains toolbox/vision sub-directories
        matlabDirName = getRootDirName(unzipFolderLocation);
        
        % Get defines
        horzcat_with_space = @(cellval)sprintf('%s ',cellval{:});
        defs   = horzcat_with_space(getDefines(binfo.buildInfo));
        
        % Get source file list
        if ispc
            [~, cFiles] = system(['dir /s/b ' '*.c']);
            [~, cppFiles] = system(['dir /s/b ' '*.cpp']);
            
        else
            [~, cFiles] = system(['find ./ ' '-name ' '''*.c''']);
            [~, cppFiles] = system(['find ./ ' '-name ' '''*.cpp''']);
            
        end
        
        cIndx = strfind(cFiles, '.c');
        cppIndx = strfind(cppFiles, '.cpp');
        srcFilesC = [];
        srcFilesCPP = [];
        
        for i = 1:length(cIndx)
            if i == 1
                startIdx = 1;
                endIdx = cIndx(i);
            else
                startIdx = cIndx(i-1)+1;
                endIdx = cIndx(i);
            end
            
            [~, b, ~] = fileparts(cFiles(startIdx:endIdx));
            srcFilesC = [srcFilesC ' ' b '.c']; %#ok<AGROW>
        end
        
        for i = 1:length(cppIndx)
            if i == 1
                startIdx = 1;
                endIdx = cppIndx(i);
            else
                startIdx = cppIndx(i-1)+1;
                endIdx = cppIndx(i);
            end
            
            [~, b, ~] = fileparts(cppFiles(startIdx:endIdx));
            srcFilesCPP = [srcFilesCPP ' ' b '.cpp']; %#ok<AGROW>
        end
        
        srcFiles = [srcFilesC ' ' srcFilesCPP];
        
        % Get platform dependent names
        if isunix % both mac and linux
            tmf = 'TemplateMakefilePackNGo_unix';
            if ismac
                archDir = 'maci64';
                dllExt  = 'dylib';
            else
                archDir = 'glnxa64';
                dllExt  = 'so';
            end
        else
            tmf = 'TemplateMakefilePackNGo_win';
            archDir = 'win64';
            dllExt  = 'dll';
        end
        
        % Now that we have defines, lets create a platform dependent makefile
        % from template.
        fid = fopen(fullfile(visiondemo_dir,tmf));
        
        filecontent = char(fread(fid)');
        fclose(fid);
        
        newfilecontent = regexprep(filecontent,...
                {'PASTE_ARCH','PASTE_EXT','PASTE_DEFINES','PASTE_SRCFILES', 'PASTE_MATLAB'},...
                { archDir,     dllExt,      defs,           srcFiles,         matlabDirName});
            
        makefileName = 'Makefile';
        mk_name = fullfile(unzipFolderLocation,makefileName);

        if isunix
            if( ismac )
                [status,sysHeaderPath] = system( 'xcode-select -print-path' );
                assert(status==0, ['Could not obtain a path to the system ' ...
                           'header files using ''xcode-select -print-path''' '']);
                       
                [status,sdkPaths] = system( [ 'find ' deblank( sysHeaderPath ) ...
                                             ' -name ''MacOSX*.sdk''' ] );
                assert(status==0, 'Could not find MacOSX sdk' );
                
               % There might be multiple SDK's 
                sdkPathCell = strsplit(sdkPaths,'\n'); 
                for idx = 1:numel(sdkPathCell)
                   if ~isempty(sdkPathCell{idx})
                       % Pick the first one that's not empty.
                       sdkPath = sdkPathCell{idx}; 
                       fprintf('Choosing SDK in %s\n',sdkPath);
                       break;
                   end
                end
                assert(~isempty(sdkPath), ...
                  sprintf('There is no sdk available in %s. Please check system environment.\n',sysHeaderPath));
                
                ccCMD = [ 'xcrun clang -isysroot ' deblank( sdkPath ) ];
                cppCMD = [ 'xcrun clang++ -isysroot ' deblank( sdkPath ) ];
            else
                ccCMD  = 'gcc';
                cppCMD = 'g++';
            end
            
            newfilecontent = regexprep(newfilecontent,'PASTE_CC',ccCMD);
            newfilecontent = regexprep(newfilecontent,'PASTE_CPP',cppCMD);
        end
        
        fid = fopen(mk_name,'w+');
        fprintf(fid,'%s',newfilecontent);
        fclose(fid);
        
    end

    % Create platform specific commands needed to build the executable and
    % to run it.
    function [buildCommand, runCommand] = createBuildAndRunCommands( ...
        packageLocation,unzipFolderLocation,makefileName,fileName)
        % Create the build and run command.

        if ismac
            buildCommand = [' xcrun make -f ' makefileName];
            runCommand   = ['./' fileName ' "' fileName '"'];    
        elseif isunix
            buildCommand = [' make -f ' makefileName];
            runCommand   = ['./' fileName ' "' fileName '"'];
        else
            % On PC we use the generated BAT files (there should be 2) to help
            % build the generated code.  These files are copied to the
            % unzipFolderLocation where we can use them to build.
            batFilename       = [fileName '_rtw.bat'];
            batFilelocation   = fullfile(packageLocation,'codegen', ...
                                         filesep,'exe',filesep,fileName);
            batFileDestinaton = unzipFolderLocation;

            % Copy it to packNGo output directory.
            copyfile(fullfile(batFilelocation,batFilename),batFileDestinaton);

            % The Makefile we created is named 'Makefile', whereas the Batch
            % file refers to <filename>_rtw.mk. Hence we rename the file.
            newMakefileName = [fileName '_rtw.mk'];
            oldMakefilename = makefileName;
            copyfile(fullfile(batFileDestinaton,oldMakefilename),...
                fullfile(batFileDestinaton,newMakefileName));

            buildCommand = batFilename;
            runCommand   = [fileName '.exe' ' "' fileName '"'];
        end

    end

    % Build the executable with the build command.
    function buildExecutable(unzipFolderLocation, buildCommand)
        % Call system command to build the executable.

        lastDir    = cd(unzipFolderLocation);
        dirCleanup = onCleanup(@()cd(lastDir));

        [hadError, sysResults] = system(buildCommand);

        if hadError
            error (sysResults);
        end

    end

    % Get the root directory that contains toolbox/vision sub-directories
    function matlabDirName = getRootDirName(unzipFolderName)  
        dirLists = dir(unzipFolderName);
        dirLists = dirLists(~ismember({dirLists.name},{'.','..'}));

        matlabDirName='';
        for ij=1:length(dirLists)
            thisDirName = dirLists(ij).name;
            if (isdir(thisDirName))
                % subdirectory will have toolbox/vision
                [subDir1, hasSubDir1]  = hasSubdirectory(thisDirName, 'toolbox');
                if hasSubDir1
                    [~, hasSubDir2]  = hasSubdirectory(subDir1, 'vision');
                    if hasSubDir2
                        matlabDirName = thisDirName;
                        break;
                    end
                end
            end
        end
    end

    % Find the directory that contains the specified sub-directory
    function [subDir, hasSubDir]  = hasSubdirectory(dirName, subDirName)
        dirLists = dir(dirName);
        dirLists = dirLists(~ismember({dirLists.name},{'.','..'}));  
        
        subDir = '';
        hasSubDir = false;
        
        for ij=1:length(dirLists)
            thisDirName = dirLists(ij).name;
            thisDir = fullfile(dirName,thisDirName);
            
            if (isdir(thisDir) && strcmp(thisDirName, subDirName))
                hasSubDir = true;
                subDir = thisDir;
                break;
            end
        end
    end


end
