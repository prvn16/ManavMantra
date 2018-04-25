function jimage = im2java2d(varargin)
%IM2JAVA2D Convert image to Java BufferedImage.
%   JIMAGE = IM2JAVA2D(I) converts the image I to an instance of the Java image
%   class, java.awt.image.BufferedImage. The image I can be an intensity
%   (grayscale), RGB, or binary image.
%
%   JIMAGE = IM2JAVA2D(X,MAP) converts the indexed image X with colormap MAP to
%   an instance of the Java class, java.awt.image.BufferedImage.
%
%   Class Support
%   -------------
%   Intensity, Indexed, and RGB input images can be of class uint8, uint16, or
%   double. Binary input images must be of class logical.
%
%   Example
%   -------
%   This example reads an image into the MATLAB workspace and then uses
%   im2java2d to convert it into an instance of the Java class,
%   java.awt.image.BufferedImage.
%
%   I = imread('cameraman.tif');
%   javaImage = im2java2d(I);
%   icon = javax.swing.ImageIcon(javaImage);
%   label = javax.swing.JLabel(icon);
%   pSize = label.getPreferredSize;
%   f = figure('visible','off');
%   fPos = get(f,'Position');
%   fPos(3:4) = [pSize.width, pSize.height];
%   set(f,'Position',fPos);
%   hLabel = javacomponent(label,[0 0 fPos(3:4)], f);
%   figure(f)

%   Copyright 1993-2011 The MathWorks, Inc.

%   Input-output specs
%   ------------------
%   I:    2-D, real, full matrix
%         logical, uint8, uint16, or double
%
%   RGB:  3-D, real, full matrix
%         size(RGB,3)==3
%         uint8, uint16, or double
%
%   X:    2-D, real, full matrix
%         uint8, uint16, or double
%         if isa(X,'uint8'): X <= size(MAP,1)-1
%         if isa(X,'uint16'): X <= size(MAP,1)-1
%         if isa(X,'double'): 1 <= X <= size(MAP,1)
%
%   MAP:  2-D, real, full matrix
%         size(MAP,1) <= 65536 (when X is double or uint16)
%         size(MAP,1) <= 256 (when X is uint8)
%         size(MAP,2) == 3
%         double
%
%   JIMAGE:  java.awt.image.BufferedImage

%   Note
%   ----
%   This function uses com.mathworks.toolbox.images.util.ImageFactory which
%   casts double intensity and RGB images to uint8.
%
%   Indexed images work for uint8, uint16, and double. Double indexed images
%   are treated as uint8 or uint16 indexed images depending on the length
%   of the colormap.
%
%   Binary images are cast to uint8 and treated as indexed images with 2 colors.
%
%   Intensity images are actually treated as indexed images because the Color
%   management for grayscale images using
%   ColorSpace.getInstance(ColorSpace.CS_GRAY) gives a washed out result for
%   grayscale images. Eventually we should create our own color model so that
%   the data can be passed straight to Java in the DataBuffer and interpretted
%   appropriately.


% Don't run on platforms with incomplete Java support
if ~IsJavaAvailable
    error(message('images:im2java2d:im2java2dNotAvailableOnThisPlatform'));
end

[img,map,method] = ParseInputs(varargin{:});

width  = size(img,2);
height = size(img,1);

import com.mathworks.toolbox.images.util.ImageFactory;

% Assign function according to method
switch method
    case 'binary'
        map = gray(2);
        jimage = create_indexed_image(width,height,img,map);
        
    case 'intensity'
        
        % treat intensity as indexed to avoid washed out colorspace, see note above.
        if isa(img,'uint16')
            map = gray(65536);
        else
            map = gray(256);
        end
        jimage = create_indexed_image(width,height,img,map);
        
    case 'rgb'
        img = permute(img,[3 2 1]);
        jimage = ImageFactory.createInterleavedRGBImage(width,height,img(:));
        
    case 'indexed'
        jimage = create_indexed_image(width,height,img,map);
        
end

%-------------------------------
function jimage = create_indexed_image(width,height,img,map)

import com.mathworks.toolbox.images.util.ImageFactory;

mapLength = size(map,1);
map = uint8(map*256 - 1); % convert to uint8 map for Java
img = img';
map = map';
jimage = ImageFactory.createIndexedImage(width,height,img(:),...
    mapLength,map(:));


%-------------------------------
% Function  ParseInputs
%-------------------------------
function [img, map, method] = ParseInputs(varargin)

% defaults
map = [];

narginchk(1,2);
validateattributes(varargin{1},{'uint8','uint16','double','logical'},...
    {'real','nonsparse'},...
    mfilename,'Image',1)

img = varargin{1};

switch nargin
    case 1
        
        method = get_image_type(img);
        
        % Convert to uint8 only if double or binary.
        if isa(img,'double')
            img = uint8(img * 255 + 0.5);
        elseif strmatch(method,'binary')
            img = uint8(img);
        end
        
    case 2
        
        method = 'indexed';
        map = varargin{2};
        ncolors = validate_map(img,map);
        img     = validate_X(img,ncolors);
        
    otherwise
        error(message('images:im2java2d:tooManyInputs'));
        
end


%-------------------------------
function method = get_image_type(img)

if ndims(img) == 2
    if islogical(img)
        method = 'binary';
    else
        method = 'intensity';
    end
    
elseif ndims(img)==3 && size(img,3)==3
    method = 'rgb';
    
else
    error(message('images:im2java2d:invalidImage'))
    
end


%-------------------------------
function ncolors = validate_map(img,map)

iptcheckmap(map, mfilename, 'MAP', 2);

if isa(img,'uint8')
    MAX_COLORS = 256;
else
    MAX_COLORS = 65536;
end

ncolors = size(map,1);
if ncolors > MAX_COLORS
    error(message('images:im2java2d:invalidMapLength'))
end


%-------------------------------
function img = validate_X(img,ncolors)

validateattributes(img,{'uint8','uint16','double'},{'2d'},mfilename,'X',1)

if isa(img,'double')
    validateattributes(img,{'double'},{'positive'},mfilename,'X',1)
    if ncolors <= 256
        img = uint8(img - 1);
    else
        img = uint16(img - 1);
    end
end

if max(img(:)) > ncolors-1
    error(message('images:im2java2d:indexOutsideColormap'))
end

%-------------------------------
function java_available = IsJavaAvailable

java_available = false;

if isempty(javachk('swing'))
    java_available = true;
end
