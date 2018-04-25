function [niifilename, imgfilename, headerfilename, gzipCode] = niftiParseFileName(varargin)
% niftiParseFileName: parses filenames for all the nifti* functions
%   [NIIFILENAME, IMGFILENAME, HEADERFILENAME, GZIPCODE] =
%   NIFTIPARSEFILENAME(varargin) is a helper function to validate NIfTI
%   file names, and separate out the cases when it is a .NII file versus
%   .HDR/.IMG pair. It can take one or two input strings or character
%   vectors and returns appropriate filenames and type (.nii/.hdr/.img)
%   information.
% 
%   niifilename: is a string or character vector specifying the .nii or
%   .nii.gz file in the input. If the input refers to .hdr/.img files, this
%   is returned as an empty element.
% 
%   imgfilename: is a string or character vector specifying the .img or
%   .img.gz file in the input. If the input refers to .nii or .hdr files,
%   this is returned as an empty element.
%
%   headerfilename: is a string or character vector specifying the .hdr or
%   .hdr.gz file in the input. If the input refers to .nii or .img files,
%   this is returned as an empty element.
%
%   gZipCode is:
% 
%   0 if no files are zipped, 
%   1 if .nii file is zipped, 
%   2 if hdr file is zipped (but not img file), 
%   3 if img file is zipped, but not hdr file, and 
%   4 if both img and hdr files are zipped.

%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within other toolbox classes and
%   functions. Its behavior may change, or the feature itself may be
%   removed in a future release.

%   Copyright 2017 The MathWorks, Inc.

    narginchk(1,2);
    
    niifilename = [];
    imgfilename = [];
    headerfilename = [];
    gzipCode = 0;
    
    if nargin == 1
        if ~ischar(varargin{1})
            error(message('images:nifti:filenameMustBeStringOrChar'));
        end
        
        niiFileInput = varargin{1};
        
        [path, filename, fileext] = fileparts(niiFileInput);
        
        [~, filename, fileExtIn] = fileparts(filename);
        if ~isempty(fileExtIn)
            fileext = [fileExtIn fileext];
        end
        
        [niifilename, isgzipped] = getFileName(path, filename, fileext, '.nii');
        
        if isgzipped 
            gzipCode = 1;
        end
        
        if isempty(niifilename)
            [headerfilename, isgzipped] = getFileName(path, filename, fileext, '.hdr');
            if isgzipped 
                gzipCode = 2;
            end
            if isempty(headerfilename)
                [imgfilename, isgzipped] = getFileName(path, filename, fileext, '.img');
                if isgzipped 
                    gzipCode = 3;
                end
                if isempty(imgfilename)
                    isNITFfile = false;
                    try
                        isNITFfile = isnitf(niiFileInput);
                    catch % do nothing if isnitf fails.
                    end
                    if isNITFfile
                        error(message('images:nifti:isNITF'));
                    end
                end
            end
        end
        
        if isempty(niifilename) && isempty(headerfilename) && isempty(imgfilename)
            error(message('images:nifti:filenameDoesNotExist',varargin{1})); 
        end
        
    elseif nargin == 2
        if ~ischar(varargin{1}) || ~ischar(varargin{2})
            error(message('images:nifti:filenameMustBeStringOrChar'));
        end
        
        hdrFileInput = varargin{1};
        imgFileInput = varargin{2};
        
        [headerpath, headerFilename, headerfileext] = fileparts(hdrFileInput);
        [~, headerFilename, headerfileextIn] = fileparts(headerFilename);
        if ~isempty(headerfileextIn)
            headerfileext = [headerfileextIn headerfileext];
        end
        
        [headerfilename, isgzippedHDR] = getFileName(headerpath, headerFilename, headerfileext, '.hdr');
        if isgzippedHDR 
            gzipCode = 2;
        end
        
        if isempty(headerfilename)
            error(message('images:nifti:filenameDoesNotExist',varargin{1})); 
        end        
        
        [imgpath, imgFilename, imgfileext] = fileparts(imgFileInput);
        [~, imgFilename, imgfileextIn] = fileparts(imgFilename);
        if ~isempty(imgfileextIn)
            imgfileext = [imgfileextIn imgfileext];
        end
        
        [imgfilename, isgzippedIMG] = getFileName(imgpath, imgFilename, imgfileext, '.img');
        if isgzippedIMG 
            if isgzippedHDR
                gzipCode = 4;
            else
                gzipCode = 3;
            end
        end
        
        if isempty(imgfilename)
            error(message('images:nifti:filenameDoesNotExist',varargin{2})); 
        end
    end
end

function [outFileName, isgzipped] = getFileName(inPath, inFileName, inFileExt, expExt)
    
    isgzipped = false;
    
    if ~isempty(inPath)
        inPath = [inPath filesep];
    end
    
    if strcmp(inFileExt, expExt)
        [fid, ~] = fopen([inPath inFileName inFileExt], 'r');
        if (fid > 0)
            outFileName = fopen(fid);
            fclose(fid);
        else
            outFileName = '';
        end
    elseif strcmp(inFileExt,[expExt '.gz'])
            [fid, ~] = fopen([inPath inFileName inFileExt], 'r');
            if (fid > 0)
                isgzipped = true;
                outFileName = fopen(fid);
                fclose(fid);
            else
                outFileName = '';
            end
    elseif isempty(inFileExt)
        [fid, ~] = fopen([inPath inFileName expExt], 'r');
        if (fid > 0)
            outFileName = fopen(fid);
            fclose(fid);
        else
            [fidGZ, ~] = fopen([inPath inFileName [expExt '.gz']], 'r');
            if (fidGZ > 0)
                outFileName = fopen(fidGZ);
                isgzipped = true;
                fclose(fidGZ);
            else
                outFileName = '';
            end
        end
    else
        outFileName = '';
    end

end