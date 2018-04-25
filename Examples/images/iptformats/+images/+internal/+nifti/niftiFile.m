classdef niftiFile < handle
%NIFTIFILE nifti file parser class.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within other toolbox classes and
%   functions. Its behavior may change, or the feature itself may be
%   removed in a future release.
%
%   Copyright 2017 The MathWorks, Inc.

    properties
        % This class contains four public properties:
        HeaderFileName   % for getting file details in niftiinfo
        FileWithHeader   % can contain tempdir location too
        FileWithImage    % can be the same as FileWithHeader for .nii
        TempfileCleaners % has gzipped files if non-empty
        
    end
    
    properties (Access = private)
        possibleExtensions   % these are file extensions to look for, if not specified
    end
    
    methods
        function self = niftiFile(firstFile, secondFile)
        % niftiFile: create a niftiFile object from the file names passed
        % into any of the nifti* functions. It can either take in a single
        % filename, which has to be .nii, .img, or .hdr (and its gzipped
        % versions), or takes in two filenames, the second of which is the
        % .img or .img.gz file. If two filenames are specified, the first
        % has to be a .hdr or .hdr.gz file.
        
        %   Copyright 2017 The MathWorks, Inc.
            
            if nargin == 1
                % set extensions to look for to include all three types.
                self.possibleExtensions = {'.nii', '.nii.gz', '.hdr', '.hdr.gz', '.img', '.img.gz'};
                
                if ~ischar(firstFile)
                    error(message('images:nifti:filenameMustBeStringOrChar'))
                end
                
                if isNII(firstFile)
                    % extension is specified, and is .nii or .nii.gz
                    [filename, self.TempfileCleaners, ~] = self.getUncompressedFileName(firstFile);
                    self.FileWithHeader = filename;
                    self.FileWithImage = filename;
                else
                    % not .nii or .nii.gz. Extension may not have been
                    % specified too.
                    [filename, tempfileCleaner, ext] = self.getUncompressedFileName(firstFile);
                    switch lower(ext)
                        case '.hdr'
                            self.FileWithHeader = filename;
                            self.TempfileCleaners = tempfileCleaner;
                            
                            [voxelFile, cleaner] = findCorrespondingFile(firstFile, '.img');
                            self.FileWithImage = voxelFile;
                            if ~isempty(cleaner)
                                self.TempfileCleaners(end+1) = cleaner;
                            end
                        case '.img'
                            self.FileWithImage = filename;
                            self.TempfileCleaners = tempfileCleaner;
                            
                            [headerFile, cleaner] = findCorrespondingFile(firstFile, '.hdr');
                            self.FileWithHeader = headerFile;
                            self.HeaderFileName = getFullFilename(headerFile);
                            if ~isempty(cleaner)
                                self.TempfileCleaners(end+1) = cleaner;
                            end
                        case '.nii'
                            self.FileWithHeader = filename;
                            self.FileWithImage = filename;
                            self.TempfileCleaners = tempfileCleaner;
                        otherwise
                            error(message('images:nifti:filenameNotNIfTIFile', firstFile))
                    end
                            
                end
            elseif nargin == 2
                % firstFile has to be a valid .hdr file, secondFile has to
                % be a valid .img file. .nii files are not allowed.
                self.possibleExtensions = {'.hdr', '.hdr.gz'};
                if ~ischar(firstFile) || ~ischar(secondFile)
                    error(message('images:nifti:filenameMustBeStringOrChar'))
                end
                
                [headerFileName, tempFileCleanerHdr, ext] = self.getUncompressedFileName(firstFile);
                if ~strcmp(ext, '.hdr')
                   error(message('images:nifti:invalidHdrFileSpecified', 1))
                end
                
                self.possibleExtensions = {'.img', '.img.gz'};
                [imageFileName, tempFileCleanerImg, ext] = self.getUncompressedFileName(secondFile);
                if ~strcmp(ext, '.img')
                   error(message('images:nifti:invalidImgFileSpecified', 1))
                end
                
                self.TempfileCleaners = [tempFileCleanerHdr, tempFileCleanerImg];
                self.FileWithHeader = headerFileName;
                self.FileWithImage = imageFileName;
            else
                % Error: more than two input arguments.
                assert(false)
            end
        end
    end
    
    methods (Access = private)

        function [outFilename, tempfileCleaners, ext] = getUncompressedFileName(self, inFilename)
        % getUncompressedFileName: returns the path to the uncompressed
        % file. If already uncompressed, returns the same path as input.
        % Otherwise, returns a tempdir path, and an oncleanup object to
        % delete the temporary file once reading is complete. ext contains
        % the extension, irrespective of gzip status.
        
        %   Copyright 2017 The MathWorks, Inc.
        
            if isGzipped(inFilename)
                % filename includes extension, and is gzipped.
                try
                    tmpFilenameCell = gunzip(inFilename, tempdir);
                    outFilename = getFullFilename(tmpFilenameCell{1});

                    tempfileCleaners = onCleanup(@() delete(outFilename));
                    self.HeaderFileName = getFullFilename(inFilename);
                catch
                    error(message('images:nifti:cannotUnzipFile'))
                end

                ext = findExtension(outFilename);
            else
                % file may be uncompressed already, or extension may not be specified.
                ext = findExtension(inFilename);
                if ~isempty(ext)
                    % extension is specified.
                    switch lower(ext)
                        case self.possibleExtensions % check all valid
                            try
                                outFilename = getFullFilename(inFilename);
                            catch
                                % a known extension is specified, but the
                                % file does not exist.
                                error(message('images:nifti:filenameDoesNotExist', inFilename))
                            end
                        case {'.ntf', '.nsf', '.nitf'}
                            % check if the file is a nitf file
                            if isnitf(inFilename)
                                error(message('images:nifti:isNITF'))
                            else
                               error(message('images:nifti:filenameNotNIfTIFile', inFilename))
                            end
                        otherwise
                            error(message('images:nifti:filenameNotNIfTIFile', inFilename))
                    end
                else
                    % extension is not specified. Look in order.
                    outFilename = '';
                    for ext = self.possibleExtensions
                        possibleFilename = [inFilename char(ext)];
                        try
                            outFilename = getFullFilename(possibleFilename);
                            break
                        catch
                            continue
                        end
                    end

                    if isempty(outFilename)
                        error(message('images:nifti:filenameDoesNotExist', inFilename))
                    end

                    ext = char(ext); % convert from cell to char.
                end
                
                if isGzipped(ext)
                    % if the original file is gzipped, recurse.
                    [outFilename, tempfileCleaners, ext] = self.getUncompressedFileName(outFilename);
                else
                    self.HeaderFileName = outFilename;
                    tempfileCleaners = [];
                end
            end
        end
        
    end
end

function [outfilename, cleaner] = findCorrespondingFile(filename, expExt)
    % findCorrespondingFile: finds the corresponding hdr file for an img
    % file, and vice versa.
    if isGzipped(filename)
        [filepath, fname] = fileparts(filename);
        if ~isempty(filepath)
            filepath = [filepath filesep];
        end
        % ignore extension,
        [filepath, fname, ~] = fileparts([filepath, fname]);
    else
        [filepath, fname, ~] = fileparts(filename);
    end
    
    if ~isempty(filepath)
        filepath = [filepath filesep];
    end

    try
        % find an uncompressed corresponding file.
        outfilename = getFullFilename([filepath, fname, expExt]);
        % no cleaner needed here.
        cleaner = [];
    catch
        try
            % find a compressed corresponding file.
            outfilename = getFullFilename([filepath, fname, expExt, '.gz']);
            cleaner =  onCleanup(@() delete(outfilename));
        catch
            % Allow for cases where image file does not exist, but header
            % file is valid.
            outfilename = [];
            cleaner = [];
        end 
    end 
end

function fullFilename = getFullFilename(filename)
    % getFullFilename: finds files in current directory, as well as MATLAB
    % path.
    fid = fopen(filename);
    fullFilename = fopen(fid);
    fclose(fid);
end

function ext = findExtension(filename)
    if isGzipped(filename)
        [~,filename] = fileparts(filename);
    end

    [~,~,ext] = fileparts(filename);
end


function tf = isGzipped(filename)
    [~,~,ext] = fileparts(filename);
    switch lower(ext)
        case '.gz'
            tf = true;
        otherwise
            tf = false;
    end
end


function tf = isNII(filename)
    ext = findExtension(filename);
    switch lower(ext)
        case '.nii'
            tf = true;
        otherwise
            tf = false;
    end
end