function [X,map] = readgif(filename, varargin)
%READGIF Read an image from a GIF file.
%   [X,MAP] = READGIF(FILENAME) reads the first image from the
%   specified file.
%
%   [X,MAP] = READGIF(FILENAME, F, ...) reads just the frames in
%   FILENAME specified by the integer vector F.
%
%   [X,MAP] = READGIF(..., 'Frames', F) reads just the specified
%   frames from the file.  F can be an integer scalar, a vector of
%   integers, or 'all'.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2014 The MathWorks, Inc.

% Check if JVM is available
if (~usejava('jvm'))
    error(message('MATLAB:imagesci:readgif:noJava'));
end

assert(nargin>=1,message('MATLAB:imagesci:validate:wrongNumberOfInputs'));

% Get frames of interest to be read in
if (nargin > 1)
    params = parse_parameters(varargin{:});
elseif (nargin == 1)    
    params.Frames = 'all';
end

% Read multiframe GIF image
[X,map] = read_multiframe_gif(filename);

% Remove unwanted frames.
if (~isequal(params.Frames, 'all'))
    if ((any(params.Frames < 1)) || (any(params.Frames > size(X, 4))))            
        error(message('MATLAB:imagesci:readgif:frameCount', size( X, 4 )));            
    end
    X = X(:, :, :, params.Frames);
end


%--------------------------------------------------------------------------
% Function to read Multiframe GIF files by decoding the transparency and 
% disposal methods of the following images in relation to the base image.
function [X,map] = read_multiframe_gif(filename)
import java.awt.image.BufferedImage
import java.io.*
import java.util.Iterator
import javax.imageio.*
import javax.imageio.stream.*

info = imgifinfo(filename);

% Set up Java stream to acquire image data
f = java.io.File(java.lang.String(filename));
stream = javax.imageio.ImageIO.createImageInputStream(f);
readers = javax.imageio.ImageIO.getImageReaders(stream);
reader = readers.next();
reader.setInput(stream);

% Acquire GIF data from stream
n = reader.getNumImages(true);
if n == 0
    error(message('MATLAB:imagesci:readgif:corruptFirstImageData'));
end

data = cell(n,1);
for j = 0:n-1
	rasterJ = reader.read(j).getData();
	h = rasterJ.getHeight();
	w = rasterJ.getWidth();
    buffer = reader.read(j).getData().getPixels(0,0,w,h,[]);
    buffer = uint8(reshape(buffer,[w h])');
	data{j+1} = buffer;
end
stream.close();

anyValidInfoStructs = true;

% If the number of frames present in the image reported by enquiring for
% information does not match the number of frames determined by reading
% data, compensate by eliminating the corrupt info struct as best as
% possible
if numel(data) ~= numel(info)
    isInfoValid = true(1, numel(info));
    for cntInfo = 1:numel(info)
        for cntData = 1:numel(data)
            % If the Height and Width of an info struct do not match the
            % size of the data, then it is corrupt.
            if size(data{cntData}) == double([info(cntInfo).Height info(cntInfo).Width])
                isInfoValid(cntInfo) = true;
                break;
            end
            isInfoValid(cntInfo) = false;
        end
    end
    % If there is at least one valid info struct, remove any corrupt
    % structs. Otherwise keep the corrupt info structs and mark them so
    % that they will not be used for post processing. (g1080601)
    if any(isInfoValid)
        info(~isInfoValid) = [];       
    else
        anyValidInfoStructs = false;
    end
end

% This only returns the color table for the first frame in the GIF file.
% There is an enhancement (g1055265) to make this return all color tables.
map = info.ColorTable;

if ~anyValidInfoStructs
    % Since our info structs are all corrupt, we don't have valid metadata
    % to use for postprocessing. Return the raw data.
    X = data{:};
    return;
end

% Postprocess the obtained data

% Identify the extents of the image and create a bounding box to enclose
% the image
maxTopVal = max([info.Top] + [info.Height]);
maxLeftVal = max([info.Left] + [info.Width]);
sz = [maxTopVal-1 maxLeftVal-1];
X = zeros([sz(1) sz(2) 1 n],'uint8');

% Base image does not require Postprocessing
X(info(1).Top:info(1).Top+info(1).Height-1, ...
    info(1).Left:info(1).Left+info(1).Width-1, :, 1) = data{1};

undisposed_index = 1;

% Determine appearance of all frames using disposal method and transparency

% Disposal Methods:
% Pixels which are outside of the frame's region are not affected.
%
% 0 - Unspecified: Replace previous frame's region with this frame's
%     region. Typically used for non transparent frames.
%
% 1 - Do Not Dispose: This frame shows through transparent
%     pixels of subsequent frames.
%
% 2 - Restore to Background: Background color shows through
%     transparent pixels of this frame.
%
% 3 - Restore to Previous: Revert to last "Do Not Dispose" or
%     "Unspecified" then apply new frame, displaying "previous"
%     through transparent pixels of new frame.

% Transparency Settings:
% Specify which of the pixels in the GIF frames are transparent.
%
% No: No transparency. The disposal method settings do not matter.
%
% White: White pixels are transparent.
%
% First Pixel: All pixels in the frame having the color of the first
% pixel are considered transparent.
%
% Other: Brings up color picker to select color for transparency.

% Decode the current frame in relation to previous frame
for j = 2:n
    % Obtain the composited image
    [tempImage, undisposed_index] = ...
        handle_positive_base_frame(data{j}, info(j), X(:,:,:,undisposed_index), ...
                                   X(:,:,:,j-1), undisposed_index, j);
    % Place the composited image in the appropriate location
    X(1:size(tempImage, 1), 1:size(tempImage, 2),:,j) = tempImage;
end

%--------------------------------------------------------------------------
% Function to return the decoded GIF image based on the current frame, 
% previous frame, transparent color and disposal method.
function [imdata, undisposed_index] = handle_positive_base_frame(current_frame,...
                                                                 current_info,...
                                                                 undisposed_frame,...
                                                                 previous_frame,...
                                                                 undisposed_index,...
                                                                 current_index)

% Get region's row and column indices.
region.left   = current_info.Left;
region.top    = current_info.Top;
region.width  = current_info.Width;
region.height = current_info.Height;
region.right  = region.left + region.width - 1;
region.bottom = region.top + region.height - 1;

% Get the Disposal Method
disposalMethod = current_info.DisposalMethod;
switch (lower(disposalMethod))
    case lower('DoNotspecify')
        disposalNum = 0;
    case lower('LeaveInPlace')
        disposalNum = 1;
    case lower('RestoreBG')
        disposalNum = 2;
    case lower('RestorePrevious')
        disposalNum = 3;
    otherwise % Default Restore Previous
        disposalNum = 3;
end

% Get Transparent color
if isfield(current_info,'TransparentColor')
    % Frames have zero based indexing
    % TransparentColor has one based indexing
    transparent_color = current_info.TransparentColor-1;
else
    transparent_color = 0;
end

% Get Background color
if isfield(current_info,'BackgroundColor')
    % Frames have zero based indexing
    % BackgroundColor has one based indexing
    background_color = current_info.BackgroundColor-1;
else
    background_color = 0;
end

% Pad the current frame if necessary.
temp_frame = current_frame;
current_frame = zeros(size(previous_frame),'uint8');
current_frame(region.top:region.bottom, region.left:region.right) = temp_frame;

% Decode as per the disposal method
switch (disposalNum)
    
    case 0 % Do not Specify
        % Replace the previous frame's region with the new region.
        previous_frame(region.top:region.bottom, region.left:region.right) = ...
            current_frame(region.top:region.bottom, region.left:region.right);
        imdata = previous_frame;
        undisposed_index = current_index;
        
    case 1 % Do not Dispose
        % Replace the transparent pixels with the previous frame
        if isfield(current_info, 'TransparentColor')
            transparent_pixels = current_frame == transparent_color;
            current_frame(transparent_pixels) = previous_frame(transparent_pixels);
        end

        previous_frame(region.top:region.bottom, region.left:region.right) = ...
            current_frame(region.top:region.bottom, region.left:region.right);
        imdata = previous_frame;
        undisposed_index = current_index;        
    
    case 2 % Restore to Background
        % Replace transparent pixels with background color
        if isfield(current_info, 'TransparentColor')
            transparent_pixels = current_frame == transparent_color;
            current_frame(transparent_pixels) = background_color;
        end
        
        % Copy the obtained frame into the corresponding region in old frame
        previous_frame(region.top:region.bottom, region.left:region.right) = ...
            current_frame(region.top:region.bottom, region.left:region.right);
        imdata = previous_frame;
        
    case 3 % Restore to Previous
        % Replace transparent pixels with previous undisposed frame pixels
        if isfield(current_info, 'TransparentColor')
            transparent_pixels = find(current_frame == transparent_color);
            current_frame(transparent_pixels) = undisposed_frame(transparent_pixels);
        end
        
        % Copy the obtained frame into the corresponding region in old frame
        previous_frame(region.top:region.bottom, region.left:region.right) = ...
            current_frame(region.top:region.bottom, region.left:region.right);
        imdata = previous_frame;
       
    otherwise
        error(message('MATLAB:imagesci:readgif:corruptGIFfile')); 
end


%--------------------------------------------------------------------------
% Parse parameters to validate optional parameters.
function param_str = parse_parameters(varargin)
param_str = struct([]);

% Handle possibility of numeric index as first argument.
if (isnumeric(varargin{1}))
    % Force into param/value pairs.
    varargin = {'Frames', varargin{1:end}};
elseif ischar(varargin{1}) && ~isempty(strfind('frames',lower(varargin{1})))
    % Partial match.
    varargin{1} = 'Frames';
end


p = inputParser;
p.addParamValue('Frames',[], ...
    @(x)validateattributes(x,{'numeric','char'},{'nonempty','vector'},'','FRAMES'));
p.parse(varargin{:});

frames = p.Results.Frames;
if ischar(frames)
    frames = validatestring(frames,{'all'});
else
    validateattributes(frames,{'numeric'},{'nonempty','vector'},'','FRAMES');
end

param_str(1).Frames = frames;
