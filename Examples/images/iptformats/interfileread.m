function X = interfileread (varargin)
%INTERFILEREAD Read images in Interfile 3.3 format.
%   A = INTERFILEREAD(FILENAME) reads the images in the first energy window
%   of FILENAME into A, where A is an M-by-N array for a single image and
%   an M-by-N-by-P array for multiple images.  The file must be in the
%   current directory or in a directory on the MATLAB path.
%
%   A = INTERFILEREAD(FILENAME,WINDOW) reads the images in energy window
%   WINDOW of FILENAME into A.
%
%   The images in the energy window must be of the same size.
%
%   Examples
%   --------
%
%       img  = interfileread('MyFile.hdr');
%
%   For more information on the Interfile format, go to this website:
%
%   http://www.medphys.ucl.ac.uk/interfile/
%
%   See also INTERFILEINFO.

%   Copyright 2005-2017 The MathWorks, Inc.

% check number of inputs
narginchk(1,2)
% get file parameters
varargin = matlab.images.internal.stringToChar(varargin);
[filename, window] = parse_inputs(varargin{:});
info = interfileinfo(filename);
params = get_params(info);
if (window > params.num_windows)
    error(message('images:interfileread:invalidInput'))
end

% open the image file for reading
fid = fopen(params.data_file, 'r', params.byte_order);
if (fid == -1)
    error(message('images:interfileread:invalidValue', 'name of data file'))
end

fseek(fid, params.offset, 'cof');

% read images according to data type
switch (lower(params.data_type))
    case {'static', 'roi'}
        X = get_stat(info, window, fid);
        
    case ('dynamic')
        X = get_dyna(info, window, fid);
        
    case ('gated')
        X = get_gated(info, window, fid);
        
    case ('tomographic')
        X = get_tomo(info, window, fid);
        
    case ('curve')
        X = get_curve(info, fid);
        
    case ('other')
        fclose(fid);
        error(message('images:interfileread:unsupportedDatatype'))
        
    otherwise
        fclose(fid);
        error(message('images:interfileread:invalidValue', 'type of data'))
end

fclose(fid);



%%%
%%% Function parse_inputs
%%%
function [filename, window] = parse_inputs(varargin)

filename = varargin{1};

if (nargin == 1)
    window = 1;
    
else
    window = varargin{2};
end

if window < 1
    error(message('images:interfileread:invalidInput'))
end



%%%
%%% Function get_params
%%%
function params = get_params(info)

% get version of keys
params.version = get_val(info, 'VersionOfKeys', 'version of keys', 1);
if (isempty(params.version))
    params.version = 3.3;
end

% get data offset
try
    offset = 2048*get_val(info, 'DataStartingBlock', 'data starting block', 1);
    
catch
    try
        offset = get_val(info, 'DataOffsetInBytes', 'data offset in bytes', 1);
        
    catch
        error(message('images:interfileread:missingKeyDataLocation'))
    end
end

if (isempty(offset))
    params.offset = 0;
else
    params.offset = offset;
end

% get image file name
params.data_file = get_val(info, 'NameOfDataFile', 'name of data file', 1);
if (isempty(params.data_file))
    error(message('images:interfileread:noDataFile'))
end

% get image type
params.data_type = get_val(info, 'TypeOfData', 'type of data', 1);
if (isempty(params.data_type))
    params.data_type = 'Other';
end

% get endianness
byte_order = get_val(info, 'ImagedataByteOrder', 'imagedata byte order', 0);
if strcmpi(byte_order, 'bigendian') || isempty(byte_order)
    params.byte_order = 'ieee-be';
    
elseif strcmpi(byte_order, 'littleendian')
    params.byte_order = 'ieee-le';

else
    error(message('images:interfileread:invalidValue', 'imagedata byte order'))
end

% get number of energy windows
params.num_windows = get_val(info, 'NumberOfEnergyWindows', 'number of energy windows', 0);
if (isempty(params.num_windows))
    params.num_windows = 1;
end



%%%
%%% Function get_stat
%%%
function X = get_stat(info, window, fid)

X = [];
i = 1;

while (i <= window)
    num_img = get_val(info, 'NumberOfImagesEnergyWindow', 'number of images/energy window', 0, fid, i);
    if (isempty(num_img))
        num_img = 1;
    end
    
    % go through images
    for j = 1:num_img
        num_cols = get_val(info, 'MatrixSize1', 'matrix size [1]', 2, fid, (i-1)*num_img+j);
        num_rows = get_val(info, 'MatrixSize2', 'matrix size [2]', 2, fid, (i-1)*num_img+j);
        num_bytes = get_val(info, 'NumberOfBytesPerPixel', 'number of bytes per pixel', 2, fid, (i-1)*num_img+j);
        if (i == window)
            num_format = get_val(info, 'NumberFormat', 'number format', 1, fid, (i-1)*num_img+j);
            if (isempty(num_format))
                num_format = 'unsigned integer';
            end
            
            % read the image
            img = read_img(fid, num_rows, num_cols, num_bytes, num_format);
            if isempty(X)
                X = img;
                
            % add image to image array
            else
                check_image_size(size(X), size(img));
                X(:,:,end+1) = img; %#ok<AGROW>
            end
            
        else
            fseek(fid, num_cols*num_rows*num_bytes, 'cof');
        end
    end
    
    i = i+1;
end



%%%
%%% Function get_dyna
%%%
function X = get_dyna(info, window, fid)

X = {};
i = 1;

while (i <= window)
    % get number of frame groups
    num_frames = get_val(info, 'NumberOfFrameGroups', 'number of frame groups', 1, fid, i);
    if (isempty(num_frames))
        num_frames = 1;
    end
    
    % read images in each frame group
    for j = 1:num_frames
        num_cols = get_val(info, 'MatrixSize1', 'matrix size [1]', 2, fid, (i-1)*num_frames+j);
        num_rows = get_val(info, 'MatrixSize2', 'matrix size [2]', 2, fid, (i-1)*num_frames+j);
        num_bytes = get_val(info, 'NumberOfBytesPerPixel', 'number of bytes per pixel', 2, fid, (i-1)*num_frames+j);
        num_img = get_val(info, 'NumberOfImagesThisFrameGroup', 'number of images this frame group', 2, fid, (i-1)*num_frames+j);
        % read images if input energy window
        if (i == window)
            num_format = get_val(info, 'NumberFormat', 'number format', 1, fid, (i-1)*num_frames+j);
            if (isempty(num_format))
                num_format = 'unsigned integer';
            end
            
            for k = 1:num_img
                % read the image
                img = read_img(fid, num_rows, num_cols, num_bytes, num_format);
                if isempty(X)
                    X = img;

                % add image to image array
                else
                    check_image_size(size(X), size(img));
                    X(:,:,end+1) = img; %#ok<AGROW>
                end
            end
            
        % otherwise increase offset
        else
            fseek(fid, num_img*num_cols*num_rows*num_bytes, 'cof');
        end
    end
    
    i = i+1;
end



%%%
%%% Function get_gated
%%%
function X = get_gated(info, window, fid)

X = {};
i = 1;

while (i<=window)
    num_cols = get_val(info, 'MatrixSize1', 'matrix size [1]', 2, fid, i);
    num_rows = get_val(info, 'MatrixSize2', 'matrix size [2]', 2, fid, i);
    num_bytes = get_val(info, 'NumberOfBytesPerPixel', 'number of bytes per pixel', 2, fid, i);
    num_format = get_val(info, 'NumberFormat', 'number format', 1, fid, i);
    if (isempty(num_format))
        num_format = 'unsigned integer';
    end
    
    num_time = get_val(info, 'NumberOfTimeWindows', 'number of time windows', 0, fid, i);
    if (isempty(num_time))
        num_time = 1;
    end

    % read images in time window or increase offset
    for j = 1:num_time
        num_img = get_val(info, 'NumberOfImagesInWindow', 'number of images in window', 2, fid, (i-1)*num_time+j);
        if (i == window)
            for k = 1:num_img
                % read the image
                img = read_img(fid, num_rows, num_cols, num_bytes, num_format);
                if isempty(X)
                    X = img;

                % add image to image array
                else
                    check_image_size(size(X), size(img));
                    X(:,:,end+1) = img; %#ok<AGROW>
                end
            end
            
        else
            fseek(fid, num_img*num_cols*num_rows*num_bytes, 'cof');
        end
    end
    
    i = i+1;
end



%%%
%%% Function get_tomo
%%%
function X = get_tomo(info, window, fid)

X = {};
i = 1;

while (i <= window)
    num_heads = get_val(info, 'NumberOfDetectorHeads', 'number of detector heads', 0, fid, i);
    if (isempty(num_heads))
        num_heads = 1;
    end

    % go through each detector head
    for j = 1:num_heads
        num_cols = get_val(info, 'MatrixSize1', 'matrix size [1]', 2, fid, (i-1)*num_heads+j);
        num_rows = get_val(info, 'MatrixSize2', 'matrix size [2]', 2, fid, (i-1)*num_heads+j);
        num_bytes = get_val(info, 'NumberOfBytesPerPixel', 'number of bytes per pixel', 2, fid, (i-1)*num_heads+j);
        % get process status
        status = get_val(info, 'ProcessStatus', 'process status', 1, fid, (i-1)*num_heads+j);
        if ((isempty(status)) || (strcmpi(status, 'reconstructed')))
            num_img = get_val(info, 'NumberOfSlices', 'number of slices', 2, fid, (i-1)*num_heads+j);
            
        elseif (strcmp(status, 'acquired'))
            num_img = get_val(info, 'NumberOfProjections', 'number of projections', 2, fid, (i-1)*num_heads+j);
            
        else
            fclose(fid);
            error(message('images:interfileread:invalidValue', 'process status'))
        end
        
        % read the images based on process status or increase offset
        if (i == window)
            num_format = get_val(info, 'NumberFormat', 'number format', 1, fid, (i-1)*num_heads+j);
            if (isempty(num_format))
                num_format = 'unsigned integer';
            end
        
            for k = 1:num_img
                % read the image
                img = read_img(fid, num_rows, num_cols, num_bytes, num_format);
                if isempty(X)
                    X = img;

                % add image to image array
                else
                    check_image_size(size(X), size(img));
                    X(:,:,end+1) = img; %#ok<AGROW>
                end
            end
            
        else
            fseek(fid, num_img*num_cols*num_rows*num_bytes, 'cof');
        end
    end
    
    i = i+1;
end



%%%
%%% Function get_curve
%%%
function X = get_curve(info, fid)

num_cols = get_val(info, 'MatrixSize1', 'matrix size [1]', 2, fid);
num_rows = get_val(info, 'MatrixSize2', 'matrix size [2]', 2, fid);
num_bytes = get_val(info, 'NumberOfBytesPerPixel', 'number of bytes per pixel', 2, fid);
num_format = get_val(info, 'NumberFormat', 'number format', 1, fid);
if (isempty(num_format))
    num_format = 'unsigned integer';
end

X = read_img(fid, num_rows, num_cols, num_bytes, num_format);



%%%
%%% Function read_img
%%%
function img = read_img(fid, num_rows, num_cols, num_bytes, num_format)

% convert from Interfile to MATLAB data type
switch (lower(num_format))
    case ('unsigned integer')
        switch (num_bytes)
            case (1)
                num_type = 'uint8';
                
            case (2)
                num_type = 'uint16';
                
            case (4)
                num_type = 'uint32';
                
            case (8)
                num_type = 'uint64';
                
            otherwise
                fclose(fid);
                error(message('images:interfileread:unsupportedformat', 'ubit'))
        end
        
    case ('signed integer')
        switch (num_bytes)
            case (1)
                num_type = 'int8';
                
            case (2)
                num_type = 'int16';
                
            case (4)
                num_type = 'int32';
                
            case (8)
                num_type = 'int64';
                
            otherwise
                fclose(fid);
                error(message('images:interfileread:unsupportedFeature', 'bit'))
        end
                
    case ('long float')
        num_type = 'float64';
        
    case ('short float')
        num_type = 'float32';
        
    case ('bit')
        num_type = 'ubit1';
        
    case ('ascii')
        num_type = 'char';
        
    otherwise
        fclose(fid);
        error(message('images:interfileread:invalidValue', 'number format'))
end

% read the image from file
img = reshape(fread(fid, num_rows*num_cols, num_type), num_cols, num_rows)';



%%%
%%% Function get_val
%%%
function val = get_val(varargin)

info = varargin{1};
key = varargin{2};
err_key = varargin{3};
required = varargin{4};
if (nargin >= 5)
    fid = varargin{5};
    if (nargin == 6)
        num = varargin{6};
    end

else
    num = [];
end

val = [];
err = 0;

% check to see if is a field
if (isfield(info,key))
    if (isempty(num))
        val = info.(key);
        
    else
        % check for over-indexing
        if (num > length(info.(key)))
            err = 2;
            
        else
            % read from cell
            if (iscell(info.(key)))
                val = info.(key){num};

            else
                % if string
                if (ischar(info.(key)))
                    if (num > 1)
                        err = 2;
                        
                    else
                        val = info.(key);
                    end
                    
                % if numeric
                else
                    val = info.(key)(num);
                end
            end
        end
    end
    
elseif (required)
    err = 1;
end

% set error if required but not specified
if ((required == 2) && (isempty(val)))
    err = 2;
end

if (err == 1)
    if (nargin >= 5)
        fclose(fid);
    end
    
    error(message('images:interfileread:missingKey', err_key))
    
elseif (err == 2)
    if (nargin >= 5)
        fclose(fid);
    end

    error(message('images:interfileread:invalidValue', err_key))
end



%%%
%%% Function check_image_sizes
%%%
function check_image_size (orig_size, new_size)

% error if images are different sizes
if ~isequal(new_size, orig_size(1:2))
    error(message('images:interfileread:diffImageSizes'))
end
