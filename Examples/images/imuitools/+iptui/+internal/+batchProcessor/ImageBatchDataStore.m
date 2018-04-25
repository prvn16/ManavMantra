classdef ImageBatchDataStore < handle
    
    %   Copyright 2014-2016 The MathWorks, Inc.
    
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
    
    properties (Constant = true)
        THUMBNAILSIZE = 72; %px
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
        function fullPath = getResultFileName(this, ind)
            fullPath = fullfile(this.WriteLocation, [num2str(ind) '_result.mat']);
        end
        
        %
        function fullPath = getResultSummaryFileName(this, ind)
            fullPath = fullfile(this.WriteLocation, [num2str(ind) '_summary.mat']);
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
        function write(this, ind, results_)
            if(~isstruct(results_))
                % Support for image in - image out workflow.
                results.output = results_;
            else
                results = results_;
            end
            outputfile = this.getResultFileName(ind);
            save(outputfile,...
                '-struct','results',...
                '-v7.3');
            
            % Compute and save thumbnails/truncated textual display
            summary = struct();
            for field = fieldnames(results)'
                im = results.(field{1});
                if(iptui.internal.batchProcessor.isImage(im))
                    % create thumbnail
                    if(size(im,1)>size(im,2))
                        thumb = imresize(im,[this.THUMBNAILSIZE, NaN],'nearest');
                    else
                        thumb = imresize(im,[NaN, this.THUMBNAILSIZE],'nearest');
                    end
                    if(~isa(thumb,'uint8'))
                        %  Scale down to uint8
                        minPix = min(thumb(:));
                        thumb = thumb - minPix;
                        maxPix = max(thumb(:));
                        thumb = uint8(double(thumb)/double(maxPix) *255);
                    end
                    summary.(field{1}) = thumb;
                else
                    if( (isnumeric(im)||islogical(im)) && numel(im)>20)
                        % Show size and data type
                        imageInfo = whos('im');
                        imageSize = sprintf('%dx',imageInfo.size);
                        imageSize(end) = [];
                        summary.(field{1}) = [imageSize, ' ', imageInfo.class];
                    else
                        % Use DISP. Links look bad on uicontrol, turn it
                        % off.
                        dispText = evalc('feature(''hotlinks'',''off''); disp(im); feature(''hotlinks'',''on'')');
                        summary.(field{1}) = deblank(dispText);
                    end
                end
            end
            outputfile = this.getResultSummaryFileName(ind);
            save(outputfile,...
                '-struct','summary',...
                '-v7.3');
        end
        
        % 
        function clearPreviousResults(this, ind)
            % If function invocation failed, ensure that previous results
            % are deleted
            
            outputfile = this.getResultFileName(ind);
            if exist(outputfile, 'file')
                delete(outputfile);
            end
            
            outputfile = this.getResultSummaryFileName(ind);
            if exist(outputfile, 'file')
                delete(outputfile);
            end            
        end
                                
        %
        function summary = resultSummary(this, ind)
            outputfile = this.getResultSummaryFileName(ind);
            summary = load(outputfile);
        end
        
        %
        function result = loadOneResultField(this, ind, varname)
            outputfile   = this.getResultFileName(ind);
            pState = warning('off','MATLAB:load:variableNotFound');
            resetWarningObj = onCleanup(@()warning(pState));
            resultStruct = load(outputfile,varname);
            result       = resultStruct.(varname);
        end
        
        %
        function allResultStructArray = loadAllResults(this, varnames, includeInputFileName)
            allResultFiles = dir(fullfile(this.WriteLocation,'*_result.mat'));
            
            % All fields need not be present in all output if function
            % changed between calls
            pState = warning('off','MATLAB:load:variableNotFound');
            resetWarningObj = onCleanup(@()warning(pState));
            
            % Initialize struct array
            allResultStructArray(numel(allResultFiles)) = struct();
            
            % Initialize fields
            for ind =1:numel(varnames)
                [allResultStructArray.(varnames{ind})] = deal([]);
            end
            
            for outInd = 1:numel(allResultFiles)
                outputfile = fullfile(this.WriteLocation,allResultFiles(outInd).name);
                resultStruct = struct();
                if(~isempty(varnames))
                    resultStruct = load(outputfile,varnames{:});
                end
                
                % Copy fields actually found in the output
                foundFields = fieldnames(resultStruct);
                for ind = 1:numel(foundFields)
                    fieldName = foundFields{ind};
                    allResultStructArray(outInd).(fieldName) = ...
                        resultStruct.(fieldName);
                end
                
                % Include fileName
                if(includeInputFileName)
                    imageIndex = str2double(...
                        strrep(allResultFiles(outInd).name,'_result.mat',''));
                    allResultStructArray(outInd).fileName = ...
                        this.getInputImageName(imageIndex);
                end
            end
        end
        
        %
        function failed = copyAllResultsToFiles(this, outputDir, fieldAndFormat, useParallel)
            
            % Create output directory if required
            [sucess, failMessage] = mkdir(outputDir);
            if(~sucess)
                warning(['mkdir(' outputDir,') : ' failMessage]);
                failed = true;
                return;
            end
            
            % If dir already existed, ensure we have write permissions
            [~, dirPerms] = fileattrib(outputDir);
            if(~dirPerms.UserWrite)
                warning(getString(message('images:imageBatchProcessor:unableToWriteToOutput', outputDir)));
                failed = true;
                return;
            end            
            
            allResultFiles = dir(fullfile(this.WriteLocation,'*_result.mat'));
            
            % All fields need not be present in all output of function
            % changed between calls
            pState = warning('off','MATLAB:load:variableNotFound');
            resetWarningObj = onCleanup(@()warning(pState));
            
            failed = false;
            
            hwb = waitbar(0,...
                getString(message('images:imageBatchProcessor:exportingToFiles',...
                0, numel(allResultFiles))));
            cleanUpWaitBar = onCleanup(@()delete(hwb));
            
            for outInd = 1:numel(allResultFiles)
                waitbar(outInd/numel(allResultFiles),hwb,...
                    getString(message('images:imageBatchProcessor:exportingToFiles',...
                    outInd, numel(allResultFiles))));
                
                
                resultFileName = fullfile(this.WriteLocation,allResultFiles(outInd).name);
                for fieldInd = 1:numel(fieldAndFormat)
                    fieldName = fieldAndFormat{fieldInd}{1};
                    format    = fieldAndFormat{fieldInd}{2};
                    
                    % Output file name = outputdir + relative input file
                    % name - old format + new format
                    imageIndex = str2double(...
                        strrep(allResultFiles(outInd).name,'_result.mat',''));
                    [~, relativePath] = this.getInputImageName(imageIndex);
                    outImageFileName = fullfile(outputDir,relativePath);
                    outImageFileName = regexprep(outImageFileName,...
                        '.[^.]*$',['_', fieldName, '.', format]);
                    
                    imout = load(resultFileName,fieldName);
                    imout = imout.(fieldName);
                    if(~isempty(imout))
                        try
                            dirName = fileparts(outImageFileName);
                            if ~isdir(dirName)
                                mkdir(dirName);
                            end
                            if(strcmp(format,'dcm'))
                                dicomwrite(imout, outImageFileName);
                            else
                                imwrite(imout, outImageFileName);
                            end
                        catch ALL
                            % Issue to command window
                            headerString = getString(message('images:imageBatchProcessor:failedToExportThisFile',...
                                fieldName,outImageFileName));
                            warnMessage = [headerString, sprintf('\n'), ALL.message];
                            warning(warnMessage);
                            failed = true;
                        end
                    end
                end
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
