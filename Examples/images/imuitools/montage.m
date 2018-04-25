function h = montage(varargin)
%MONTAGE Display multiple image frames as rectangular montage.
%   MONTAGE(FILENAMES) displays a montage of the images specified in
%   FILENAMES. FILENAMES is a N-by-1 or 1-by-N string or a cell array of
%   character vectors. If the files are not in the current directory or in
%   a directory on the MATLAB path, specify the full pathname. (See the
%   IMREAD command for more information.) MONTAGE converts any indexed
%   image into its corresponding RGB version using the internal colormap
%   present in the file. The images need not be of the same size and type.
%
%   MONTAGE(I) displays a montage of all the frames of a multiframe image
%   array I. I can be a sequence of binary, grayscale, or truecolor images.
%   A binary or grayscale image sequence must be an M-by-N-by-K or an
%   M-by-N-by-1-by-K array. A truecolor image sequence must be an
%   M-by-N-by-3-by-K array.
%
%   MONTAGE(IMAGELIST) displays a montage of the images specified in the
%   cell array IMAGESLIST. Elements of the cell array are either numeric
%   matrices of size MxN or MxNx3, or are filenames represented by a char
%   vector or a string. An empty cell element will be displayed as a blank
%   tile.
%
%   MONTAGE(IMDS) displays a montage of the images specified in the
%   imagedatastore object IMDS.
%
%   MONTAGE(X,MAP) treats all grayscale images in X as indexed images and
%   applies the specified colormap MAP. X can either be a grayscale image
%   (M-by-N-by-1-by-K), a string of filenames or a cell array of character
%   vectors with the filenames. If X represents filenames, MAP overrides
%   any internal colormap present in image files.
%
%   MONTAGE(..., NAME1, VALUE1, NAME2, VALUE2, ...) returns a customized
%   display of an image montage, depending on the values of the optional
%   parameter name/value pairs. See Parameters below. Parameter names can be
%   abbreviated, and case does not matter.
%
%   H = MONTAGE(...) returns the handle of the single image object which
%   contains all the frames displayed.
%
%   Parameters
%   ----------
%   'Size'          A 2-element vector, [NROWS NCOLS], specifying the number
%                   of rows and columns in the montage. Use NaNs to have
%                   MONTAGE calculate the size in a particular dimension in
%                   a way that includes all the images in the montage. For
%                   example, if 'Size' is [2 NaN], MONTAGE creates a
%                   montage with 2 rows and the number of columns necessary
%                   to include all of the images.  MONTAGE displays the
%                   images horizontally across columns.
%
%                   Default: MONTAGE calculates the rows and columns so the
%                   images in the montage roughly form a square.
%
%   'ThumbnailSize' A 2-element vector, [TROWS TCOLS], specifying the size
%                   of each individual thumbnail in pixels. The aspect
%                   ratio of the original image will be maintained by
%                   zero-padding the boundary. One element may be NaN, the
%                   corresponding value is computed automatically to
%                   preserve the aspect ratio of the first image.
%                   ThumbnailSize may be empty ([]), in which case the full
%                   size of the first image is used as the thumbnail size.
%
%                   Default: MONTAGE automatically computes a ThumbnailSize
%                   based on screen size and number of images.
%
%   'Parent'        Handle of an axes that specifies the parent of the
%                   image object created by MONTAGE. The final montage
%                   image is resized to fit in the extents available in the
%                   parent axes.
%
%   'Indices'       A numeric array that specifies which frames MONTAGE
%                   includes in the montage. MONTAGE interprets the values
%                   as indices into array I or cell array FILENAMES.  For
%                   example, to create a montage of the first four frames
%                   in I, use this syntax:
%
%                   montage(I,'Indices',1:4);
%
%                   Default: 1:K, where K is the total number of frames or
%                   image files.
%
%   'DisplayRange'  A 1-by-2 vector, [LOW HIGH], that adjusts the display
%                   range of the images in the image array. All images must
%                   be grayscale images. The value LOW (and any value less
%                   than LOW) displays as black, the value HIGH (and any
%                   value greater than HIGH) displays as white. If you
%                   specify an empty matrix ([]), MONTAGE uses the minimum
%                   and maximum values of the images to be displayed in the
%                   montage as specified by 'Indices'. For example, if
%                   'Indices' is 1:K and the 'Display Range' is set to [],
%                   MONTAGE displays the minimum value in of the image
%                   array (min(I(:)) as black, and displays the maximum
%                   value (max(I(:)) as white.
%
%                   Default: Range of the datatype of the image array.
%
%   'BackgroundColor' The background color, defined as a MATLAB ColorSpec.
%                     All blank spaces will be filled with this color
%                     including space specified by BorderSize. If a
%                     background color is specified, the output is rendered
%                     as an RGB image.
%
%                     Default: 'black'
%
%   'BorderSize'      A scalar or a 1-by-2 vector, [BROWS BCOLS] that
%                     specifies the amount of pixel padding required around
%                     each thumbnail image. The borders are padded with the
%                     background color.
%
%                     Default: [0 0]
%
%
%   Class Support
%   -------------
%   A grayscale image array can be uint8, logical, uint16, int16, single,
%   or double. An indexed image array can be logical, uint8, uint16,
%   single, or double. MAP must be double. A truecolor image array can be
%   uint8, uint16, single, or double. The output is a handle to the image
%   object produced by MONTAGE. If there is a datatype mismatch between
%   images, all images are rescaled to be double using the im2double
%   function.
%
%   Example 1
%   ---------
%     % Create a montage from workspace variables and files
%     imRGB = imread('peppers.png');
%     imGray = imread('coins.png');
%     figure
%     montage({imRGB, imGray, 'cameraman.tif'});
%
%   Example 2
%   ---------
%     % Customize the number of images in the montage.
%     load mri
%     montage(D, map)
%
%     % Create a new montage containing only the first 9 images.
%     figure
%     montage(D, map, 'Indices', 1:9);
%
%   Example 3
%   ---------
%     % Inspect the color planes of an RGB image
%     imRGB = imread('coloredChips.png');
%     figure
%     imshow(imRGB)
%     figure
%     montage(imRGB);
%
%   Example 4
%   ---------
%     % Create a montage from a series of images in ten files.
%     % The montage has two rows and five columns.  
%     fileFolder = fullfile(matlabroot,'toolbox','images','imdata');
%     imds = imageDatastore(fullfile(fileFolder,'AT3*'));
%     montage(imds, 'Size', [2 5]);
%
%     % Add a blue border
%     figure
%     montage(imds, 'Size', [2 5], 'BorderSize', 10, 'BackgroundColor', 'b');
%
%   See also IMAGEBROWSER, IMMOVIE, IMSHOW, IMPLAY.

%   Copyright 1993-2017 The MathWorks, Inc.

[Isrc,cmap,montageSize,displayRange,displayRangeSpecified,parent,...
    indices, thumbnailSize, borderSize, backgroundColor] = ...
    parse_inputs(varargin{:});

[bigImage, cmap] = images.internal.createMontage(Isrc, thumbnailSize,...
    montageSize, borderSize, backgroundColor, indices, cmap);

origWarning = warning();
warnCleaner = onCleanup(@() warning(origWarning));
warning('off', 'images:initSize:adjustingMag')
warning('off', 'MATLAB:images:imshow:ignoringDisplayRange')


if isempty(bigImage)
    hh = imshow([]);
    if nargout > 0
        h = hh;
    end
    return;
end

% Define parenting arguments as cell array so that we can use comma
% separated list to form appropriate syntax in calls to imshow.
if isempty(parent)
    parentArgs = {};
else
    parentArgs = {'Parent',parent};
end

if ~isempty(parent)
    bigImage = iptui.internal.resizeImageToFitWithinAxes(parent,bigImage);
end

if isempty(cmap)
    if displayRangeSpecified
        hh = imshow(bigImage, displayRange, parentArgs{:});
        if size(bigImage,3)==3
            % DisplayRange has no impact on RGB images.
            warning(message('images:montage:displayRangeForRGB'));
        end
    else
        hh = imshow(bigImage ,parentArgs{:});
    end
else
    % Pass cmap along to IMSHOW.
    hh = imshow(bigImage,cmap,parentArgs{:});
end

if nargout > 0
    h = hh;
end

end

function [I,cmap,montageSize,displayRange,displayRangeSpecified,parent,...
    idxs, thumbnailSize, borderSize, backgroundColor] = parse_inputs(varargin)

narginchk(1, 10);

% Initialize variables
thumbnailSize = "auto";
cmap          = [];
montageSize   = [];
parent        = [];
borderSize    = [0 0];
backgroundColor = [];

I = varargin{1};
if iscell(I) || isstring(I)
    nframes = numel(I);
elseif isa(I,'matlab.io.datastore.ImageDatastore')
    nframes = numel(I.Files);
else
    validateattributes(I, ...
        {'uint8' 'double' 'uint16' 'logical' 'single' 'int16'}, {}, ...
        mfilename, 'I, BW, or RGB', 1);
    if ndims(I)==4 % MxNx {1,3} x P        
        if size(I,3)~=1 && size(I,3)~=3
            error(message('images:montage:notVolume'));
        end
        nframes = size(I,4);
    else
        if ndims(I)>4
            error(message('images:montage:notVolume'));
        end
        nframes = size(I,3);
    end
end

varargin(2:end) = matlab.images.internal.stringToChar(varargin(2:end));
charStart = find(cellfun('isclass', varargin, 'char'),1,'first');

displayRange = [];
displayRangeSpecified = false;
idxs = [];

if isempty(charStart) && nargin==2 || isequal(charStart,3)
    %MONTAGE(X,MAP)
    %MONTAGE(X,MAP,Param1,Value1,...)
    cmap = varargin{2};
end

if isempty(charStart) && (nargin > 2)
    error(message('images:montage:nonCharParam'))
end


paramStrings = {'Size', 'Indices', 'DisplayRange','Parent',...
    'ThumbnailSize', 'BorderSize', 'BackgroundColor'};
for k = charStart:2:nargin
    param = lower(varargin{k});
    inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
    valueIdx = k + 1;
    if valueIdx > nargin
        error(message('images:montage:missingParameterValue', inputStr));
    end
    
    switch (inputStr)
        case 'Size'
            montageSize = varargin{valueIdx};
            validateattributes(montageSize,{'numeric'},...
                {'vector','positive','numel',2}, ...
                mfilename, 'Size', valueIdx);
            montageSize = double(montageSize);
            t = montageSize;
            t(isnan(t))=0;
            validateattributes(t,{'numeric'},...
                {'vector','integer','numel',2}, ...
                mfilename, 'Size', valueIdx);
            
        case 'ThumbnailSize'
            thumbnailSize = varargin{valueIdx};
            if ~isempty(thumbnailSize)
                validateattributes(thumbnailSize,{'numeric'},...
                    {'vector','positive','numel',2}, ...
                    mfilename, 'ThumbnailSize', valueIdx);
                if all(isnan(thumbnailSize))
                    error(message('images:montage:allNaN'));
                end
                thumbnailSize = double(thumbnailSize);
                t = thumbnailSize;
                t(isnan(t))=0;
                validateattributes(t,{'numeric'},...
                    {'vector','integer','numel',2}, ...
                    mfilename, 'ThumbnailSize', valueIdx);
            end
            
        case 'Indices'
            validateattributes(varargin{valueIdx}, {'numeric'},...
                {'integer','nonnan'}, ...
                mfilename, 'Indices', valueIdx);
            idxs = varargin{valueIdx};
            idxs = idxs(:);
            invalidIdxs = ~isempty(idxs) && ...
                any(idxs < 1) || ...
                any(idxs > nframes);
            if invalidIdxs
                error(message('images:montage:invalidIndices'));
            end
            idxs = double(idxs(:));
            if isempty(idxs)
                % Show nothing if idxs was explicitly set to []
                I = [];
            end
            
        case 'DisplayRange'
            displayRange = varargin{valueIdx};
            displayRange = images.internal.checkDisplayRange(displayRange, mfilename);
            displayRangeSpecified = true;
            
        case 'Parent'
            parent = varargin{valueIdx};
            if ~(isscalar(parent) && ishghandle(parent) && ...
                    strcmp(get(parent,'type'),'axes'))
                error(message('images:montage:invalidParent'));
            end
            
        case 'BorderSize'
            borderSize = varargin{valueIdx};
            if isscalar(borderSize)
                borderSize = [borderSize, borderSize]; %#ok<AGROW>
            end
            validateattributes(borderSize, {'numeric', 'logical'},...
                {'integer','finite','>=',0 , 'numel', 2}, ...
                mfilename, 'BorderSize', valueIdx);
            borderSize = double(borderSize);
            
        case 'BackgroundColor'
            backgroundColor = varargin{valueIdx};
            backgroundColor = convertColorSpec(images.internal.ColorSpecToRGBConverter,backgroundColor);
            backgroundColor = im2uint8(backgroundColor);
            backgroundColor = reshape(backgroundColor, [1 1 3]);
    end
end

end

