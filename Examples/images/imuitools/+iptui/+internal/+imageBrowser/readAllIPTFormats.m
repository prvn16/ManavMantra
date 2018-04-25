function im = readAllIPTFormats(filename)

% An IPT specific ReadFcn for imageDatastore
%  - Caches last successfully used image read function
%  - Order of tries:
%       * Cached reader function handle
%       * IMREAD wrapper (handles conversion from indexed to RGB)
%       * DICOM
%       * NITF
%  - Issues whatever exception IMREAD issues on total failure
%

% Copyright 2016 The MathWorks, Inc.

persistent cachedReader;


allWarnsOff = warning('off');
restoreWarnObj = onCleanup(@()warning(allWarnsOff));

try
    im = cachedReader(filename);
catch ALL %#ok<NASGU>
    [im, cachedReader] = findReaderAndRead(filename);
end

if isempty(im)
    % DICOM returns empty on non dicom files
    [im, cachedReader] = findReaderAndRead(filename);
    if isempty(im)
        % Return placeholder for corrupt images
        im = imread(fullfile(matlabroot,'toolbox','images','icons','CorruptedImage_72.png'));
    end
end

if ndims(im)>3 || size(im,3)>3
    % Limit to 2D grayscale (MxN) or RGB (MxNx3)
    im = im(:,:,1);
end
end


function [im, cachedReader] = findReaderAndRead(filename)
[im, cachedReader] = tryIMREAD1st(filename);
end


function [im, cachedReader] = tryIMREAD1st(filename)
try
    im = imreadWrapper(filename);
    cachedReader = @imreadWrapper;
catch ALL %#ok<NASGU>
    try
        [im, cachedReader] = readIPTFormats(filename);
    catch ALL
        rethrow(ALL);
    end
end
end


function im = imreadWrapper(filename)
[im,x] = imread(filename);
if ~isempty(x)
    % Handle indexed images
    im = ind2rgb(im,x);
end
end


function [im, cachedReader] = readIPTFormats(filename)
if isdicom(filename)
    im = dicomread(filename);
    cachedReader = @dicomread;
elseif isnitf(filename)
    im = nitfread(filename);
    cachedReader = @nitfread;
else
    try
        im = dpxread(filename);
        cachedReader = @dpxread;
    catch ALL %#ok<NASGU>
        % Issue whatever exception IMREAD throws
        im = imread(filename);
        cachedReader = [];
    end
end
end