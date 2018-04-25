classdef FileReader < handle
    %FILEREADER Create a file reader for AppDesigner files
    %   
    %   obj = FileReader(FILENAME) constructs a FileReader object to read
    %   AppDesigner specific files.  
    %
    % Methods:
    %   readMATLABCodeText     - Reads the MATLAB code in the file
    %   code to the file
    %   readAppDesignerData    - Reads the AppDesigner specific information,
    %                            AppWindow and MetaData
    %   readAppMetadata        - Reads metadata about the app (Name,
    %                             Summary, Description, ScreenshotMode,
    %                             MLAPPVersion, MATLABRelease, 
    %                             MinimumSupportedMATLABRelease)
    %   readAppScreenshot      - Reads the app screenshot
    %
    % Properties:
    %   FileName            - String specifying path and name of file 
    %   DefaultExtension    - Extension of AppDesigner files
    %
    % Example:
    %
    %   % Create FileReader object
    %   fileReader = FileReader('myApp.mlapp');
    %
    %   % Get MATLAB code from file
    %   matlabCode = readMATLABCodeText(fileReader);
    %
    %   % Get AppDesigner specific data from file
    %   appData = readAppDesignerData(fileReader)

    % Copyright 2013-2017 The MathWorks, Inc.

    
    properties (Access = private)
        DefaultExtension = '.mlapp';
    end
    
    properties
        FileName;
    end
    
    methods
        
        function obj = FileReader(fileName)
            narginchk(1, 1);
            validateattributes(fileName, ...
                {'char'}, ...
                {});
            obj.FileName = fileName;
            
            obj.validateFileExtensionForRead();
            
            % verify the file exists.
            if exist(fileName, 'file') ~= 2
                % Error Message
                error(message('MATLAB:appdesigner:appdesigner:InvalidFileName', fileName));               
            end
        end
        
        function matlabCode = readMATLABCodeText(obj)
            % READMATLABCODETEXT reads the MATLAB code stored in the
            % AppDesigner file and outputs the MATLAB code as a string.
            % matlabcode - MATLAB code readable from AppDesigner file
            
            [~, name, ext] = fileparts(obj.FileName);
            
            % Validate basic features of file location
            obj.validateFileExtensionForRead();
            obj.validateFileForRead();
            obj.validateFolderForRead();
            
            try
                matlabCode = appdesigner.internal.serialization.mexMLAPPReading(...
                    'readCode', obj.FileName);
            catch me
                error(message('MATLAB:appdesigner:appdesigner:LoadFailed', [name, ext]));
            end
        end
                
        function appData = readAppDesignerData(obj)                        
            % READAPPDESIGNERDATA extracts the AppDesigner specific data
            % from the AppDesigner
            % appData - the serialized app data
            
            [~, name, ext] = fileparts(obj.FileName);
            
            % Data from the MLAPP file will be copied to a local
            % .mat file in a temporary directory
            tempFileLocation = [tempname, '.mat'];

            % Validate basic features of file location
            obj.validateFileExtensionForRead();
            obj.validateFileForRead();
            obj.validateFolderForRead();
            
            % Copy data from file to the temporary location
            try
                appdesigner.internal.serialization.mexMLAPPReading(...
                    'getAppDesignerData', obj.FileName, tempFileLocation );
            catch me
                error(message('MATLAB:appdesigner:appdesigner:LoadFailed', [name, ext]));
            end
            tic
            while (exist(tempFileLocation, 'file')~=2 && toc < 10)
            end
            
            % EXIST returns 2 for files.
            if exist(tempFileLocation, 'file')~=2
                error(message('MATLAB:appdesigner:appdesigner:TransferOfDataFailed', obj.FileName));
            end
            
            % The temporary file will need to be deleted after read
            c = onCleanup(@()delete(tempFileLocation));

            % Disable load warning and capture current lastwarn state
            previousWarning = warning('off','MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality');
            % Loading 16a app will throw classNotFound and classError
            % warnings:
            % ClassNotFound happens on two cases:
            % 1) AppWindow is removed in 16b/17a, but AppWindow is 
            % serialized as a PrivateParent property in the VC component 
            % ParentingComponent, and is not used.
            % 2) UIAxes is serialized with HTMLCanvas object as its 
            % property in 16a, but HTMLCanvas is removed from 17a.
            %
            % ClassError is thrown because of InnerPosition property 
            % confliction in uifigure which is added as a dynamic property 
            % in 16a app.
            %
            % In 17a, with CPP Connector being enabled, the warning is
            % exposed to the MATLAB command line, and needed to be turned
            % off
            previousWarning(end+1) = warning('off', 'MATLAB:load:classNotFound');
            previousWarning(end+1) = warning('off', 'MATLAB:load:classError');
            
            % Suppress the SizeChangedFcnDisabledWhenAutoResizeOn warning
            % during load. The warning will be thrown if the loaded 
            % container has AutoResizeChildren set to 'on' and SizeChanged 
            % set to a non-empty value. 
            previousWarning(end+1) = warning('off', 'MATLAB:ui:containers:SizeChangedFcnDisabledWhenAutoResizeOn');  
            
            % Suppress the DefaultObjectSubstitution during load.  This
            % warning will be thrown if an unknown component is loaded
            previousWarning(end+1) = warning('off', 'MATLAB:class:DefaultObjectSubstitution');
            
            [lastWarnStr, lastWarnId] = lastwarn;  
                     
            % Attach a listener for figure creation to apply default
            % settings during loading. It will set the default values for
            % some properties of the component under this figure, like
            % FontName, and should happen just at the point figure object
            % is instantiated.
            % - g1573715
            cleanupObj = appdesigner.internal.serialization.util.listenAndConfigureUIFigure();
            
            % Load data from .mat file using MATLAB
            appData = load(tempFileLocation);            
            
            % Restore previous warning state
            warning(previousWarning);
            lastwarn(lastWarnStr, lastWarnId);
        end        
        
        function appMetadata = readAppMetadata(obj)
            % READAPPMETADATA extracts the metadata about the app
            %   appMetadata - struct with fields for the metadata (Name,
            %       Summary, Description, ScreenshotMode, MLAPPVersion,
            %       MATLABRelease, MinimumSupportedMATLABRelease)
            
            [~, name, ext] = fileparts(obj.FileName);
            
            % Validate basic features of file location
            obj.validateFileExtensionForRead();
            obj.validateFileForRead();
            obj.validateFolderForRead();
            
            try
                % Call to builtin function
                appMetadata = appdesigner.internal.serialization.getAppMetadata(obj.FileName);
            catch me
                error(message('MATLAB:appdesigner:appdesigner:LoadFailed', [name, ext]));
            end
        end
        
        function screenshot = readAppScreenshot(obj, outputType)
            % READAPPSCREENSHOT extracts the app's screenshot
            %   outputType - 'uri' (default if none specified) | 'file'
            %                Format in which the screenshot should be
            %                returned. 
            %
            %                'uri' = base64 encoded data string
            %                'file' = full filepath to image save as a file
            %                   in a temporary directory.
            %
            %   screenshot - screenshot data as defined by outputType. 
            %                Returns empty ([]) if app has no screenshot.
            
            
            [~, name, ext] = fileparts(obj.FileName);
            
            % Validate basic features of file location
            obj.validateFileExtensionForRead();
            obj.validateFileForRead();
            obj.validateFolderForRead();
            
            try
                % Call to builtin function
                [screenshotBytes, screenshotFormat] = appdesigner.internal.serialization.getAppScreenshot(obj.FileName);
            catch me
                error(message('MATLAB:appdesigner:appdesigner:LoadFailed', [name, ext]));
            end
            
            if isempty(screenshotBytes)
                screenshot = [];
                return;
            end
            
            if strcmp(outputType, 'file')
                % For now, the screenshot will always be saved as a PNG file.
                % TODO: enhance this to return whatever image type the
                % screenshot is actually saved as
                screenshot = [tempname, '.', screenshotFormat];
                appdesigner.internal.application.ImageUtils.createImageFileFromBytes(screenshot, screenshotBytes);
            else % outputType = 'uri'
                screenshot = appdesigner.internal.application.ImageUtils.getImageDataURIFromBytes(screenshotBytes, screenshotFormat);
            end          
        end
    end  
    
     methods (Access = private)
                   
        function obj = validateFileExtensionForRead(obj)
            % This function confirms that the file extension is consistent
            % with the default
            [path, name, ext] = fileparts(obj.FileName);
            if ~(isempty(ext) || strcmp(ext, obj.DefaultExtension))
            
                error(message('MATLAB:appdesigner:appdesigner:InvalidExtension', obj.DefaultExtension));
            end
            
            if isempty(ext) || ~strcmp(ext, obj.DefaultExtension)
                ext = obj.DefaultExtension;
            end

            obj.FileName = fullfile(path, [name, ext]);
                        
        end
        
        function obj = validateFileForRead(obj)
            % VALIDATEFILEFORREAD - Confirm that the file is valid by
            % verifying it has the correct parts
            [~, name, ext] = fileparts(obj.FileName);
            
            part = '/appdesigner/appModel.mat';
            hasPart = false;
            
            try
                hasPart = appdesigner.internal.serialization.mexMLAPPReading(...
                    'hasPart', obj.FileName, part);
            catch me
                error(message('MATLAB:appdesigner:appdesigner:LoadFailed', [name, ext]));
            end
            
            assert(hasPart, message('MATLAB:appdesigner:appdesigner:LoadFailed', [name, ext]));
        end
        
        function obj = validateFolderForRead(obj)
            % VALIDATEFOLDERFORREAD - Confirm that the directory is
            % readable and that the attributes can be obtained without
            % error
            
            [filePath, ~] = fileparts(obj.FileName);
            % Check basic attributes of the file location
            [stat,struc]=fileattrib(filePath);
            % if stat == 0, struc will contain the error message
            if stat == 0
                error(message('MATLAB:appdesigner:appdesigner:InvalidFolder',filePath, struc))
            end 
            
            if ~struc.UserRead
                error(message('MATLAB:appdesigner:appdesigner:NotReadableLocation', filePath));
            end
    
        end
    end
end

