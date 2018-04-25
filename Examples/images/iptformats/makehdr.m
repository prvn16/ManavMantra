function hdr = makehdr(filenames, varargin)
%MAKEHDR    Create high dynamic range image.
%   HDR = MAKEHDR(FILES) creates the single-precision high dynamic range
%   image HDR from the set of spatially registered low dynamic range images
%   listed in FILES. FILES is an array of strings, or a cell array of
%   character vectors.  These files must contain EXIF exposure metadata.
%   The "middle" exposure value between the brightest and darkest images is
%   used as the base exposure for the high dynamic range calculations.
%   (This value does not need to appear in any particular file.)
%
%   HDR = MAKEHDR(FILES, PARAM1, VALUE1, ...) creates a high dynamic range
%   image from the low dynamic range images in FILES, specifying
%   parameters and corresponding values that control various aspects of
%   the image creation.  Parameter names can be abbreviated and case does
%   not matter.
%
%   Parameters include:
%
%   'BaseFile'          Character array containing the name of the file to
%                       use as the base exposure.
%
%   'ExposureValues'    A vector of exposure values, with one element
%                       for each low dynamic range image in FILES.  An
%                       increase of one exposure value (EV) corresponds
%                       to a doubling of exposure, while a decrease in
%                       one EV corresponds to a halving of exposure.
%                       Any positive value is allowed.  This parameter
%                       overrides EXIF exposure metadata.
%
%   'RelativeExposure'  A vector of relative exposure values, with one
%                       element for each low dynamic range image in
%                       FILES.  An image with a relative exposure (RE)
%                       of 0.5 has half as much exposure as an image
%                       with an RE of 1.  An RE value of 3 has three
%                       times the exposure of an image with an RE of 1.
%                       This parameter overrides EXIF exposure metadata. 
%
%   'MinimumLimit'      A numeric scalar value that specifies the minimum
%                       "correctly exposed" value. For each low dynamic
%                       range image, pixels with smaller values are
%                       considered underexposed and will not contribute to
%                       the final high dynamic range image. If the value of
%                       this parameter is omitted, it is assumed to be 2%
%                       of the maximum intensity allowed by the data type
%                       of the images.
%
%   'MaximumLimit'      A numeric scalar value that specifies the maximum
%                       "correctly exposed" value. For each low dynamic
%                       range image, pixels with larger values are
%                       considered overexposed and will not contribute to
%                       the final high dynamic range image. If the value of
%                       this parameter is omitted, it is assumed to be 98%
%                       of the maximum intensity allowed by the data type
%                       of the images.
%
%   Notes
%   -----
%   [1] Only one of the 'BaseFile', 'ExposureValues', and
%       'RelativeExposure' parameters may be used at a time.
%   [2] The input images can be color or grayscale. They can have a bit
%       depth of 8 or 16.
%
%   Example
%   -------
%
%   Make a high dynamic range image from a series of six low dynamic
%   range images that share the same f/stop number and have different
%   exposure times.  Use TONEMAP to visualize the HDR image.
%
%      files = ["office_1.jpg", "office_2.jpg", "office_3.jpg", ...
%               "office_4.jpg", "office_5.jpg", "office_6.jpg"];
%      expTimes = [0.0333, 0.1000, 0.3333, 0.6250, 1.3000, 4.0000];
%
%      hdr = makehdr(files, "RelativeExposure", expTimes ./ expTimes(1));
%      rgb = tonemap(hdr);
%      figure; imshow(rgb)
%
%   Reference: Reinhard, et al. "High Dynamic Range Imaging." 2006. Ch. 4.
%
%   See also HDRREAD, HDRWRITE, LOCALTONEMAP, TONEMAP.

%   Copyright 2007-2017 The MathWorks, Inc.

% Parse and check inputs.

% Retrofit code to accept array of strings. Convert cellstr to allow rest
% of code to continue to work as designed with cellstr input.
if isstring(filenames)
   filenames = cellstr(filenames); 
end

validateattributes(filenames,{'cell'},{'nonempty'},mfilename,'files',1);
meta = getMetaData(filenames{1});

varargin = matlab.images.internal.stringToChar(varargin);
options = parseArgs(meta, varargin{:});
validateOptions(filenames, options);

% Get the minimum exposure image from the user or make a first pass through
% the images to find the lowest exposure image.
if ~isempty(options.BaseFile)
    [baseTime, baseFStop] = getExposure(options.BaseFile);
elseif (isempty(options.RelativeExposure) && isempty(options.ExposureValues))
    [baseTime, baseFStop] = getAverageExposure(filenames);
end

% Create output variables for an accumulator and the number of LDR images
% that contributed to each pixel.
[hdr, properlyExposedCount] = makeContainers(meta,filenames{1});

someUnderExposed = false(size(hdr));
someOverExposed = false(size(hdr));
someProperlyExposed = false(size(hdr));

% Construct the HDR image by iterating over the LDR images.
for p = 1:numel(filenames)
    fname = filenames{p};
    if ~isempty(options.ExposureValues)
        % Convert log2 EV equivalents to decimal values.
        relExposure = 2 .^ options.ExposureValues(p);
    elseif ~isempty(options.RelativeExposure)
        relExposure = options.RelativeExposure(p);
    else
		[this_ExposureTime, this_FNumber] = getExposure(fname);
        relExposure = computeRelativeExposure(baseFStop, ...
                                              baseTime, ...
                                              this_FNumber, ...
                                              this_ExposureTime);
    end

    % Read the LDR image
    ldr = loadImage(fname, meta);
    
    underExposed = ldr < options.MinimumLimit;
    someUnderExposed = someUnderExposed | underExposed;
    
    overExposed = ldr > options.MaximumLimit;
    someOverExposed = someOverExposed | overExposed;
    
    properlyExposed = ~(underExposed | overExposed);
    someProperlyExposed = someProperlyExposed | properlyExposed;
    
    properlyExposedCount(properlyExposed) = properlyExposedCount(properlyExposed) + 1;
    
    % Remove over- and under-exposed values.
    ldr(~properlyExposed) = 0;
    
    % Bring the intensity of the LDR image into a common HDR domain by
    % "normalizing" using the relative exposure, and then add it to the
    % accumulator.
    hdr = hdr + single(ldr) ./ relExposure;
end

% Average the values in the accumulator by the number of LDR images
% that contributed to each pixel to produce the HDR radiance map.
hdr = hdr ./ max(properlyExposedCount, 1);

% For pixels that were completely over-exposed, assign the maximum
% value computed for the properly exposed pixels.
maxVal = max(hdr(someProperlyExposed));
if ~isempty(maxVal)
    % If maxVal is empty, then none of the pixels are correctly exposed.
    % Don't bother with the rest; hdr will be all zeros.
    hdr(someOverExposed & ~someUnderExposed & ~someProperlyExposed) = maxVal;
end

% For pixels that were completely under-exposed, assign the
% minimum value computed for the properly exposed pixels.
minVal = min(hdr(someProperlyExposed));
if ~isempty(minVal)
    % If minVal is empty, then none of the pixels are correctly exposed.
    % Don't bother with the rest; hdr will be all zeros.
    hdr(someUnderExposed & ~someOverExposed & ~someProperlyExposed) = minVal;
end

% For pixels that were sometimes underexposed, sometimes
% overexposed, and never properly exposed, use regionfill.
fillMask = someUnderExposed & someOverExposed & ~someProperlyExposed;
if any(fillMask(:))
    hdr(:,:,1) = regionfill(hdr(:,:,1), fillMask(:,:,1));
    if ~ismatrix(hdr)
        hdr(:,:,2) = regionfill(hdr(:,:,2), fillMask(:,:,2));
        hdr(:,:,3) = regionfill(hdr(:,:,3), fillMask(:,:,3));
    end
end

%--------------------------------------------------------------------------
function [baseTime, baseFStop] = getExposure(filename)
% Extract the exposure values from a file containing EXIF metadata.

exif = getExposureDataFromFile(filename);
baseFStop = exif.FNumber;
baseTime = exif.ExposureTime;

%--------------------------------------------------------------------------
function [baseTime, baseFStop] = getAverageExposure(filenames)
% Extract the average exposure (assuming constant illumination) from a set
% of files containing EXIF metadata.  The average exposure may not actually
% correspond to the exposure of any particular image.

minTime = 0;
minFStop = 0;
maxTime = 0;
maxFStop = 0;

% Look through all of the files and keep track of the least and greatest
% exposure.
for p = 1:numel(filenames)
    exif = getExposureDataFromFile(filenames{p});
    if (p == 1)
        % First file.
        minFStop = exif.FNumber;
        minTime = exif.ExposureTime;
        maxFStop = exif.FNumber;
        maxTime = exif.ExposureTime;
    else
        % Nth file.
        if (computeRelativeExposure(minFStop, ...
                                    minTime, ...
                                    exif.FNumber, ...
                                    exif.ExposureTime) < 1)

            % Image has least exposure so far.
            minFStop = exif.FNumber;
            minTime = exif.ExposureTime;
            
        elseif (computeRelativeExposure(maxFStop, ...
                                        maxTime, ...
                                        exif.FNumber, ...
                                        exif.ExposureTime) > 1)
            
            % Image has most exposure so far.
            maxFStop = exif.FNumber;
            maxTime = exif.ExposureTime;
        end
    end
end

% Determine the "middle" exposure value.  It's easier to manipulate
% exposure time rather than f/stop.
re = computeRelativeExposure(minFStop, minTime, ...
                             maxFStop, maxTime);
baseFStop = minFStop;
baseTime  = minTime * log2(re);

%--------------------------------------------------------------------------
function exif = getExposureDataFromFile(filename)
% Extract exposure metadata from a file containing EXIF.

meta = getMetaData(filename);
if isfield(meta, 'DigitalCamera')
    exif = meta.DigitalCamera;
else
    error(message('images:makehdr:exifFormat', filename, ...
        ['Use the ''ExposureValues'' or ''RelativeExposure'' ' ...
        'parameter to provide exposure information.']));
end

if (isempty(exif) || ...
    ~isstruct(exif) || ...
    ~isfield(exif, 'FNumber') || ...
    ~isfield(exif, 'ExposureTime'))
    
    error(message('images:makehdr:noExposureMetadata', filename))
end

%--------------------------------------------------------------------------
function meta = getMetaData(filename)

try
    meta = imfinfo(filename);
catch ME
    if (isequal(ME.identifier, 'MATLAB:imagesci:imfinfo:fileOpen'))
        error(message('images:makehdr:fileNotFound', filename));
    else
        % Unexpected error
        rethrow(ME)
    end
end

% If there are several images in the file,
% use the meta data of the first one
if ~isscalar(meta)
    meta = meta(1);
end

%--------------------------------------------------------------------------
function relExposure = computeRelativeExposure(f1, t1, f2, t2)

% Exposure varies directly with the exposure time and inversely with the
% square of the F-stop number. 
relExposure = (f1 / f2)^2 * (t2 / t1);

%--------------------------------------------------------------------------
function options = parseArgs(meta, varargin)
% Parse the parameter-value pairs, getting default values.

parser = inputParser();
parser.FunctionName = mfilename;

% NameValue 'BaseFile'
defaultBaseFile = '';
validateBaseFile = @(x) validateattributes(x, ...
    {'char'}, ...
    {'vector'}, ...
    mfilename,'BaseFile');
parser.addParameter('BaseFile', ...
    defaultBaseFile, ...
    validateBaseFile);

% NameValue 'ExposureValues'
defaultExposureValues = [];
validateExposureValues = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'vector', 'real', 'finite', 'nonnan'}, ...
    mfilename,'ExposureValues');
parser.addParameter('ExposureValues', ...
    defaultExposureValues, ...
    validateExposureValues);

% NameValue 'RelativeExposure'
defaultRelativeExposure = [];
validateRelativeExposure = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'vector', 'real', 'finite', 'positive', 'nonzero'}, ...
    mfilename,'RelativeExposure');
parser.addParameter('RelativeExposure', ...
    defaultRelativeExposure, ...
    validateRelativeExposure);

% NameValue 'MinimumLimit'
defaultMinimumLimit = [];
validateMinimumLimit = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar', 'integer', 'real', 'nonnan', 'positive'}, ...
    mfilename,'MinimumLimit');
parser.addParameter('MinimumLimit', ...
    defaultMinimumLimit, ...
    validateMinimumLimit);

% NameValue 'MaximumLimit'
defaultMaximumLimit = [];
validateMaximumLimit = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar', 'integer', 'real', 'nonnan', 'positive'}, ...
    mfilename,'MaximumLimit');
parser.addParameter('MaximumLimit', ...
    defaultMaximumLimit, ...
    validateMaximumLimit);

parser.parse(varargin{:});
options = parser.Results;

% Determine the range of the first image
numSamples = 1;
if strcmp(meta.ColorType, 'truecolor')
    numSamples = 3;
end
bitsPerSample = meta.BitDepth / numSamples;
maxVal = 2^bitsPerSample-1;

if isempty(options.MinimumLimit)
    % Default is 2% of range
    options.MinimumLimit = round(0.02 * maxVal);
end

if isempty(options.MaximumLimit)
    % Default is 98% of range
    options.MaximumLimit = round((1-0.02) * maxVal);
end

%--------------------------------------------------------------------------
function validateOptions(filenames, options)

% Make sure that mutually exclusive options aren't provided.
fieldCount = 0;

if ~isempty(options.BaseFile)
    fieldCount = fieldCount + 1;
end
if ~isempty(options.ExposureValues)
    fieldCount = fieldCount + 1;
end
if ~isempty(options.RelativeExposure)
    fieldCount = fieldCount + 1;
end

if (fieldCount > 1)
    error(message('images:makehdr:tooManyExposureParameters'))
end

% Make sure that the correct number of exposure-related values are given.
if (~isempty(options.ExposureValues) ...
        && (numel(options.ExposureValues) ~= numel(filenames)))
    error(message('images:makehdr:wrongExposureValuesCount'))
elseif (~isempty(options.RelativeExposure) ...
        && (numel(options.RelativeExposure) ~= numel(filenames)))
    error(message('images:makehdr:wrongRelativeExposureCount'))
end

%--------------------------------------------------------------------------
function [hdr, counts] = makeContainers(meta,filename)
% Create a floating point accumulator for the final HDR image
% and a counter for the number of contributing images.

if ~(strcmp(meta.ColorType, 'truecolor') ...
        || strcmp(meta.ColorType, 'grayscale'))
    error(message('images:validate:invalidImageFormat',filename))
end

numPlanes = 1;
if strcmp(meta.ColorType, 'truecolor')
    numPlanes = 3;
end
hdr = zeros(meta.Height, meta.Width, numPlanes, 'single');
counts = zeros(meta.Height, meta.Width, numPlanes, 'single');

%--------------------------------------------------------------------------
function ldr = loadImage(fname, meta)

ldr = imread(fname);

if strcmp(meta.ColorType, 'truecolor')
    numPlanes = 3;
else
    numPlanes = 1;
end

if ~isequal(size(ldr,1),meta.Height) ...
        || ~isequal(size(ldr,2),meta.Width) ...
        || ~isequal(size(ldr,3),numPlanes)
    error(message('images:makehdr:imageDimensions', fname));
end
