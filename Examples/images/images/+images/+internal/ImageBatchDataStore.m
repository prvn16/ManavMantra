classdef ImageBatchDataStore < handle
    
    %   Copyright 2014-2015 The MathWorks, Inc.
    
    properties (Hidden = true)
        % ImagePaths - Cell array containing paths to images relative to
        % ReadLocation.
        %
        ImagePaths = {};
        
        % SupportedExtensions
        %
        SupportedExtensions
        
        % Function handle to check for early termination request during
        % recursive loading
        CancellationRequested;
        
        % WriteFormat
        %
        % Setting this to empty implies output format of an Image will match
        % the corresponding input.
        %
        WriteFormat = '';       
    end
    
    %% API
    properties
        % ReadLocation
        %
        ReadLocation
        
        % NumberOfImages
        %
        NumberOfImages
        
        % WriteLocation
        %
        WriteLocation        
    end
         
    properties (SetAccess = private)
        IncludeSubdirectories = true;
    end
    
    methods
        %
        function this = ImageBatchDataStore(readLocation, includeSubdirectories, cancelCheckFcn)
            
            validateattributes(readLocation,...
                {'char'}, {'nonempty', 'vector'},...
                mfilename,'readLocation',1);                       
            validateattributes(includeSubdirectories,...
                {'logical'}, {'nonempty', 'scalar'},...
                mfilename,'includeSubdirectories',2);
            
            % Optional 3rd argument
            if(nargin==3)
                this.CancellationRequested = cancelCheckFcn;
            else
                % Default
                this.CancellationRequested = @()false;
            end
                            
            assert(isdir(readLocation));            
            assert(readLocation(1)~='.',...
                'readLocation should be an absolute path');
            
            % File extensions supported
            imreadFormats = imformats;
            this.SupportedExtensions = [imreadFormats.ext];
            % Add dicom extensions
            this.SupportedExtensions{end+1} = 'dcm';
            this.SupportedExtensions{end+1} = 'ima';
            % Allow the 'no extension' specification (treat as DICOM)
            this.SupportedExtensions{end+1} = '';
            
            
            this.ReadLocation = readLocation;
            % drop trailing '/' if present
            if(this.ReadLocation(end)==filesep)
                this.ReadLocation = this.ReadLocation(1:end-1);
            end
            
            
            this.IncludeSubdirectories = includeSubdirectories;
            
            this.loadPathsToAllImageFiles(); 
            
            this.NumberOfImages = numel(this.ImagePaths);
        end
        
        %
        function [absolutePath, relativePath] = getInputImageName(this, ind)
            relativePath = this.ImagePaths{ind};
            absolutePath = fullfile(this.ReadLocation, relativePath);
        end
        
        %
        function [absolutePath, relativePath] = getOutputImageName(this, ind)
            if(isempty(this.WriteFormat))
                relativePath = this.ImagePaths{ind};
            else
                [subDir, imageName] = ...
                    fileparts(this.ImagePaths{ind});
                relativePath = fullfile(subDir, ...
                    [imageName, '.', self.WriteFormat]);
            end
            
            absolutePath = fullfile(this.WriteLocation, relativePath);
        end
        
        %
        function img = read(this, ind)
            % Ignore all reader warnings
            warnstate = warning('off','all');
            resetWarningObj = onCleanup(@()warning(warnstate));
            
            absolutePath = this.getInputImageName(ind);
            if(isdicom(absolutePath))
                img = dicomread(absolutePath);
            else
                img = imread(absolutePath);
            end
        end
        
        %
        function img = readOutput(this, ind)
            absolutePath = this.getOutputImageName(ind);
            if(isdicom(absolutePath))
                img = dicomread(absolutePath);
            else
                img = imread(absolutePath);
            end
        end
        
        %
        function exists = outputExists(this, ind)            
            if(isempty(this.WriteLocation))
                exists = false;
            else
                outputfile = this.getOutputImageName(ind);
                exists = exist(outputfile,'file');
            end
        end
        
        %
        function write(this, ind, img)
            outputfile = this.getOutputImageName(ind);
            inputfile  = this.getInputImageName(ind);
            
            containingFolder = fileparts(outputfile);
            if(~isdir(containingFolder))
                % supress warning
                [~,~] = mkdir(containingFolder);
            end
            
            if(strcmp(this.WriteFormat,'dcm') || isdicom(inputfile))
                if(isdicom(inputfile))
                    dicommeta = dicominfo(inputfile);
                    dicomwrite(img, outputfile, dicommeta, 'CreateMode', 'copy');
                else
                    dicomwrite(img, outputfile);
                end
            else
                imwrite(img, outputfile);
            end
        end
        
    end
    
    
    methods
        function set.WriteLocation(this, writeLocation)
            validateattributes(writeLocation,...
                {'char'}, {'nonempty', 'vector'},...
                'thisDataStore','writeLocation');                        
            this.WriteLocation = writeLocation;
        end       
    end
    
    %% Helpers
    methods (Hidden = true)
        
        function loadPathsToAllImageFiles(this)
            this.ImagePaths = ...
                this.getImageFileNames(this.ReadLocation,...
                this.IncludeSubdirectories);
        end
        
        % Get relative file names of all files under a location
        function fileNames = getImageFileNames(this, dirname, recurse)
            fileNames = {};
            
            if(isdir(dirname))
                dirContent = dir(dirname);
                isdirFlags = [dirContent.isdir];
                % All 'not dirs' are considered files
                fileNames = {dirContent(~isdirFlags).name};
                
                if(recurse)
                    subDirNames = {dirContent(isdirFlags).name};
                    
                    % Exclude . and ..
                    dotDir = strcmp(subDirNames,'.');
                    subDirNames = subDirNames(~dotDir);
                    dotDotDir = strcmp(subDirNames,'..');
                    subDirNames = subDirNames(~dotDotDir);
                    
                    for ind = 1:numel(subDirNames)
                        if(this.CancellationRequested())
                            return;
                        end
                        subDirName = [dirname, filesep, subDirNames{ind}];
                        subDirFileNames =  this.getImageFileNames(...
                            subDirName, recurse);
                        % Prefix sublocation name to the files in it
                        subDirFileNames  = ...
                            cellfun(@(f)[subDirNames{ind}, filesep,f], subDirFileNames,...
                            'UniformOutput',false);
                        fileNames = [fileNames, subDirFileNames]; %#ok<AGROW>
                    end
                end
                
            end
            
            % Filter-in supported extensions only
            ImageNamesExts = cellfun(...
                @(fname) fname(find(fname=='.',1,'last')+1:end), ...
                fileNames ,'Uniform', false);
            isSupportedExt = cellfun(...
                @(ext)any(strcmpi(ext, this.SupportedExtensions)),...
                ImageNamesExts);
            fileNames = fileNames(isSupportedExt);
        end
        
    end
    
end
