classdef FileWriter < handle
    %FILEWRITER Create a file writer for AppDesigner files
    %
    %   obj = FileWriter(FILENAME) constructs a FileWriter object to write
    %   AppDesigner specific files.
    %
    % Methods:
    %   writeMATLABCodeText     - Creates the file and writes the MATLAB
    %   code to the file
    %   writeAppDesignerData    - Appends the file with the AppDesigner
    %                             specific information
    %   writeAppMetadata        - Appends the file with metadata for the
    %                             app (Name, Summary, Description,
    %                             ScreenshotMode, MLAPPVersion,
    %                             MATLABRelease, MinimumSupportedMATLABRelease)
    %   writeAppScreenshot      - Appends the file with app screenshot
    %   copAppFromFile          - Copies the the specified app file
    %
    % Properties:
    %   FileName            - String specifying path and name of file
    %   DefaultExtension   - Extension of AppDesigner files
    %
    % Example:
    %
    %   % Create FileWriter object
    %   fileWriter = FileWriter('myApp.mlapp');
    %
    %   % Write MATLAB code from file
    %   matlabCode = 'function myfunction()';
    %   writeMATLABCodeText(fileWriter, matlabCode);
    %
    %   % Get AppDesigner specific data from file
    %   writeAppDesignerData(fileWriter, appData)

    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Access = private)
        DefaultExtension = '.mlapp';
    end
    
    properties
        FileName;
    end
    
    methods
        
        function obj = FileWriter(fileName)
            narginchk(1, 1);
            validateattributes(fileName, ...
                {'char'}, ...
                {});
            obj.FileName = fileName;
            obj.validateFileExtensionForWrite();
            obj.validateFileName();            
        end
        
        function  writeMATLABCodeText(obj, matlabCode)
            % WRITEMATLABCODETEXT writes MATLAB code and stores it in the
            % AppDesigner file as a string
            % matlabcode - MATLAB code to write to the AppDesigner file
            
            [~, name, ext] = fileparts(obj.FileName);
            
            % Validate basic features of file location
            obj.validateFileExtensionForWrite();
            obj.validateFileForWrite();
            obj.validateFolderForWrite();
            
            % Create file and write MATLAB code to file
            try
                appdesigner.internal.serialization.mexMLAPPWriting(...
                    'writeCode', obj.FileName, matlabCode);

                % TODO (chiragg): Notify Path Manager of new file. Proper
                % call site to be determined by Chirag Gupta and iJab Zhan.
                % See RB: http://reviewboard.mathworks.com/r/212406/
                if 0
                    fschange(obj.FileName);
                    rehash;
                end
            catch me
                error(message('MATLAB:appdesigner:appdesigner:SaveFailed', [name, ext]));
            end
            
            % Check if file was created
            if exist(obj.FileName, 'file') ~= 2, ...
                error(message('MATLAB:appdesigner:appdesigner:SaveFailed', [name, ext]));
            end

        end
        
        function writeAppDesignerDataVersion1(obj, appData)
            % WRITEAPPDESIGNERDATAVERSION1 This function writes the
            % version 1 format of one AppData object to the mat file.
            % appData - the App Designer data to serialize
            
            [~, name, ext] = fileparts(obj.FileName);
            
            % Data will be saved using MATLAB to a temporary file, then
            % written to the AppDesigner from that file
            
            tempFileLocation = [tempname, '.mat'];
            
            % Disable save warning and capture current lastwarn state
            previousWarning = warning('off','MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality');
            [lastWarnStr, lastWarnId] = lastwarn;
        
            % Save the data to a temporary .mat file
            save(tempFileLocation,'appData');
            
            % The temporary file will need to be deleted after read
            c = onCleanup(@()delete(tempFileLocation));
            
            % Restore previous warning state
            warning(previousWarning);
            lastwarn(lastWarnStr, lastWarnId);
            
            % Check basic features of file location
            obj.validateFileExtensionForWrite();
            obj.validateFileForWrite();
            obj.validateFolderForWrite();
                        
            % write contents of mat file into MLAPP file
            try
                appdesigner.internal.serialization.mexMLAPPWriting(...
                    'setAppDesignerData', obj.FileName, tempFileLocation);
            catch me
                error(message('MATLAB:appdesigner:appdesigner:SaveFailed', [name, ext]));
            end
        end
        
        function writeAppDesignerData(obj, components,code,appData)
            % WRITEAPPDESIGNERDATA writes the AppDesigner specific data
            % from  AppDesigner
            % components - a structure with the following fields: UIFigure, Groups
            % code - a structure of code related data with the following
            % fields: ClassName, Callbacks, StartupCallback,
            % EditableSectionCode
            % appData - the legacy App Designer data to serialize.  This
            % must be called appData for forwards compatibility
            
            [~, name, ext] = fileparts(obj.FileName);
            
            % Data will be saved using MATLAB to a temporary file, then
            % written to the AppDesigner from that file
            
            tempFileLocation = [tempname, '.mat'];
            
            % Disable save warning and capture current lastwarn state
            previousWarning = warning('off','MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality');
            [lastWarnStr, lastWarnId] = lastwarn;
        
            % Save the data to a temporary .mat file
            save(tempFileLocation,'components','code','appData');
            
            % The temporary file will need to be deleted after read
            c = onCleanup(@()delete(tempFileLocation));
            
            % Restore previous warning state
            warning(previousWarning);
            lastwarn(lastWarnStr, lastWarnId);
            
            % Check basic features of file location
            obj.validateFileExtensionForWrite();
            obj.validateFileForWrite();
            obj.validateFolderForWrite();
                        
            % write contents of mat file into MLAPP file
            try
                appdesigner.internal.serialization.mexMLAPPWriting(...
                    'setAppDesignerData', obj.FileName, tempFileLocation);
            catch me
                error(message('MATLAB:appdesigner:appdesigner:SaveFailed', [name, ext]));
            end
        end
        
        function  writeAppMetadata(obj, metadata)
            % WRITEAPPMETADATA writes the metadata about the app
            %   metadata - struct with metadata to write to the app. Fields
            %              include:
            %                Name - char vector name of the app
            %                Summary - char vector summary of the app
            %                Description - char vector description of app
            %                ScreenshotMode - 'auto' | 'manual' - signifies
            %                   if the user has manually selected screenshot
            %                MLAPPVersion - '1' (for 16a-17b), '2' (for 18a+)
            %                MATLABRelease - Rxxxx(a|b) release of MATLAB
            %                MinimumSupportedMATLABRelease - 'R2016a'
            %                  (for 16a-17b), 'R2018a' (for 18a+)
            %
            %               All fields are optional. Only writes/overrrides
            %               the app metadata of the fields specified.    
    
            [~, name, ext] = fileparts(obj.FileName);
            
            % Validate basic features of file location
            obj.validateFileExtensionForWrite();
            obj.validateFileForWrite();
            obj.validateFolderForWrite();
            
            try
                % Call to builtin function
                appdesigner.internal.serialization.setAppMetadata(obj.FileName, metadata);
            catch me
                error(message('MATLAB:appdesigner:appdesigner:SaveFailed', [name, ext]));
            end
        end
        
        function  writeAppScreenshot(obj, screenshot)
            % WRITEAPPSCREENSHOT writes the app's screenshot
            %   screenshot - cdata (3D RGB) matrix | file path to image
            %                of format: 'png', 'jpg', 'jpeg', or 'gif'

            [~, name, ext] = fileparts(obj.FileName);
            
            % Validate basic features of file location
            obj.validateFileExtensionForWrite();
            obj.validateFileForWrite();
            obj.validateFolderForWrite();
            
            imageFormat = 'png';
            try
                % Convert to uint8 byte array
                if ischar(screenshot)
                    % screenshot is full file path to image
                    [bytes, imageFormat] = appdesigner.internal.application.ImageUtils.getBytesFromImageFile(screenshot);
                else
                    % screenshot is cdata (3d RGB) matrix
                    bytes = appdesigner.internal.application.ImageUtils.getBytesFromCDataRGB(screenshot, imageFormat);
                end

                % Try to write screenshot to file.
                % Call to builtin function.
                appdesigner.internal.serialization.setAppScreenshot(obj.FileName, bytes, imageFormat);
            catch me
                error(message('MATLAB:appdesigner:appdesigner:SaveFailed', [name, ext]));
            end
        end
        
        function copyAppFromFile(obj, copyFromFullFileName)
            % COPYAPPFROMFILE - copies the app file from the specified file
            %
            % Note that this does NOT update the class name in the code for
            % the new file to match the copy to filename. It performs a
            % naive, straight copy. Also, the copy will be writable even if
            % the original is not so that a save can be performed on top of
            % the copy.
            
            obj.validateFileForWrite();
            obj.validateFolderForWrite();
            
            try
                copyfile(copyFromFullFileName, obj.FileName);
                
                % Make file writable after performing the copy so that it
                % can be saved on top of if necssary.
                fileattrib(obj.FileName,'+w')
            catch exception
                throwAsCaller(exception);
            end
        end

    end
    
    methods (Access = private)
        
        function obj = validateFileName(obj)
            % this function validates the file name is a valid variable
            % name
            [~, appName] = fileparts(obj.FileName);
            
            if ~isvarname(appName)
                error(message('MATLAB:appdesigner:appdesigner:FileNameFailsIsVarName', appName));
            end
        end
        
        function obj = validateFileExtensionForWrite(obj)
            % This function confirms that the file extension is consistent
            % with the default
            [path, name, ext] = fileparts(obj.FileName);
            
            if isempty(ext)
                ext = obj.DefaultExtension;
            end
            
            % Check if file has correct extension
            if ~strcmp(ext, obj.DefaultExtension)
                error(message('MATLAB:appdesigner:appdesigner:InvalidExtension', obj.DefaultExtension));
            end            
            
            obj.FileName = fullfile(path, [name, ext]);
        end
        
        function obj = validateFileForWrite(obj)
            [~, name, ext] = fileparts(obj.FileName);
        
            % Check if file already exists and is readonly
            % Using fileattrib instead of exists because exists has issues
            % with case sensitivity on linux (see g1527720)
            [success, fileAttributes] = fileattrib(obj.FileName);
            if success
                if ~fileAttributes.UserWrite
                    error(message('MATLAB:appdesigner:appdesigner:ReadOnlyFile', [name, ext]));
                end
            end
        end
        
        function obj = validateFolderForWrite(obj)
            path = fileparts(obj.FileName);
            
            % Assert that the path exists
            [success, ~] = fileattrib(path);
            if ~success
                error(message('MATLAB:appdesigner:appdesigner:NotWritableLocation', obj.FileName));
            end
            
            
            % create a random folder name so no existing folders are affected
            randomNumber = floor(rand*1e12);
            testDirPrefix = 'appDesignerTempData_';
            testDir = [testDirPrefix, num2str(randomNumber)];
            while exist(testDir, 'dir')
                % The folder name should not match an existing folder
                % in the directory
                randomNumber = randomNumber + 1;
                testDir = [testDirPrefix, num2str(randomNumber)];
            end
            
            % Attempt to write a folder in the save location
            [isWritable,~,~] = mkdir(path, testDir);
            if ~isWritable
                error(message('MATLAB:appdesigner:appdesigner:NotWritableLocation', obj.FileName));
            end
            
            [status,~,~] = rmdir(fullfile(path, testDir));
            if status ~=1
                warning(['Temporary folder %s could not be ', ...
                    'deleted.  Please delete manually.'], ...
                    fullfile(path, testDir) )
            end
        end
    end
end


