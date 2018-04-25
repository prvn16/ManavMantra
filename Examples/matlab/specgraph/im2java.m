function jimage = im2java(varargin)
%IM2JAVA Convert image to Java image.
%   JIMAGE = IM2JAVA(I) converts the intensity image I to an instance of
%   the Java image class, java.awt.Image.
%
%   JIMAGE = IM2JAVA(X,MAP) converts the indexed image X with colormap
%   MAP to an instance of the Java image class, java.awt.Image.
%
%   JIMAGE = IM2JAVA(RGB) converts the RGB image RGB to an instance of
%   the Java image class, java.awt.Image.
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, or double.
%
%   Note
%   ----  
%   Java requires uint8 data to create an instance of java.awt.Image.  If the
%   input image is of class uint8, JIMAGE contains the same uint8 data. If the
%   input image is of class double or uint16, im2java makes an equivalent
%   image of class uint8, rescaling or offsetting the data as necessary, and 
%   then converts this uint8 representation to an instance of java.awt.Image.
%
%   Example
%   -------
%   This example reads an image into the MATLAB workspace and then uses
%   im2java to convert it into an instance of the Java image class.
%
%   I = imread('moon.tif');
%   javaImage = im2java(I);
%   icon = javax.swing.ImageIcon(javaImage);
%   label = javax.swing.JLabel(icon);
%   pSize = label.getPreferredSize;
%   f = figure('visible','off');
%   fPos = f.Position;
%   fPos(3:4) = [pSize.width, pSize.height];
%   f.Position = fPos;
%   hLabel= javacomponent(label,[0 0 fPos(3:4)], f);
%   figure(f)

%   Copyright 1984-2015 MathWorks, Inc.  

%   Input-output specs
%   ------------------ 
%   I:    2-D, real, full matrix
%         uint8, uint16, or double
%         logical ok but ignored
%
%   RGB:  3-D, real, full matrix
%         size(RGB,3)==3
%         uint8, uint16, or double
%         logical ok but ignored
%
%   X:    2-D, real, full matrix
%         uint8 or double
%         if isa(X,'uint8'): X <= size(MAP,1)-1
%         if isa(X,'double'): 1 <= X <= size(MAP,1)
%         logical ok but ignored
%         
%   MAP:  2-D, real, full matrix
%         size(MAP,1) <= 256
%         size(MAP,2) == 3
%         double
%         logical ok but ignored
%
%   JIMAGE:  java.awt.Image

% Don't run on platforms with incomplete Java support
error(javachk('awt','IM2JAVA')); 
  
[img,map,method,msg,alpha] = ParseInputs(varargin{:});
if ~isempty(msg), error(msg); end 

% Assign function according to method
switch method
  case 'intensity'
    mis = im2mis_intensity(img);
  case 'rgb'
    mis = im2mis_rgb(img,alpha);
  case 'indexed'
    mis = im2mis_indexed(img,map);
end    

jimage = java.awt.Toolkit.getDefaultToolkit.createImage(mis);

%----------------------------------------------------
function mis = im2mis_intensity(I)

mis = im2mis_indexed(I,gray(256));


%----------------------------------------------------
function mis = im2mis_rgb(RGB,alpha)

mis = im2mis_packed(RGB(:,:,1),RGB(:,:,2),RGB(:,:,3),alpha);


%----------------------------------------------------
function mis = im2mis_packed(red,green,blue,alpha)

mrows = size(red,1);
ncols = size(red,2);
if isempty(alpha)
    alpha = 255*ones(mrows,ncols);
end
packed = bitshift(uint32(alpha),24);
packed = bitor(packed,bitshift(uint32(red),16));
packed = bitor(packed,bitshift(uint32(green),8));
packed = bitor(packed,uint32(blue));
pixels = packed';
mis = java.awt.image.MemoryImageSource(ncols,mrows,pixels(:),0,ncols);


%----------------------------------------------------
function mis = im2mis_indexed(x,map)

[mrows,ncols] = size(x);
map8 = uint8(round(map*255)); % convert color map to uint8
% Instantiate a ColorModel with 8 bits of depth
cm = java.awt.image.IndexColorModel(8,size(map8,1),map8(:,1),map8(:,2),map8(:,3));
xt = x';
mis = java.awt.image.MemoryImageSource(ncols,mrows,cm,xt(:),0,ncols);


%-------------------------------
% Function  ParseInputs
%
function [img, map, method, msg, alpha] = ParseInputs(varargin)
alpha = [];
% defaults
img = [];
map = [];
method = 'intensity'; 
msg = [];

try
    narginchk(1,2);
catch e
    msg = struct('message',e.message,'identifier',e.identifier);
    return
end

img = varargin{1};

if (~islogical(img) && ~isnumeric(img)) || ~isreal(img) || issparse(img) 
  msg = message('MATLAB:im2java:NonRealOrSparseImageData');
  return;
end


switch nargin
  case 1
    % figure out if intensity or RGB
    if ismatrix(img)
        method = 'intensity';
    elseif ndims(img)==3 && size(img,3)==3
        method = 'rgb';
        sz = size(img);
        alpha = 255*ones(sz(1),sz(2));
        if isa(img, 'double')
            % NaN values in a double rgb cdata represent alpha = 0;
            alpha(isnan(img(:,:,1))) = 0;
        end
    else
      msg = message('MATLAB:im2java:InvalidImageData');
      return;
    end
    
    % Convert to uint8.
    if isa(img,'double') || isa(img, 'logical')     
        img = uint8(img * 255 + 0.5);    
        
    elseif isa(img,'uint16')
        img = uint8(bitshift(img, -8));  
        
    elseif isa(img, 'uint8')
        % Nothing to do.
        
    else
       % 'MATLAB:im2java:InvalidImageClass' was used with two different
       % strings so using msg struct
      msg.identifier = 'MATLAB:im2java:InvalidImageClass';
      msg.message = getString(message('MATLAB:im2java:InvalidImageClassUint8Uint16Double'));
      return;
    end
    
  case 2
    
    % indexed image
    method = 'indexed';
    map = varargin{2};
    
    % validate map
    if ~isnumeric(map) || ~isreal(map) || issparse(map) || ~isa(map,'double') 
      msg = message('MATLAB:im2java:InvalidMapType');
      return;
    end

    if size(map,2) ~= 3
      msg = message('MATLAB:im2java:InvalidMapSize');
      return;
    end
    
    ncolors = size(map,1);
    if ncolors > 256
      msg = message('MATLAB:im2java:InvalidMapLength');
      return;
    end
    
    % validate img 
    if ~ismatrix(img)
      msg = message('MATLAB:im2java:InvalidImageDimensions');
      return;
    end

    index_out_msg = message('MATLAB:im2java:IndexOutOfRange');
    
    if isa(img,'uint8')
      if max(img(:)) > ncolors-1
        msg = index_out_msg;
        return;
      end            
    elseif isa(img,'double')
      if max(img(:)) > ncolors
        msg = index_out_msg;
        return;
      end            
      if min(img(:)) < 1
        msg = message('MATLAB:im2java:IndexLessThan1');
        return;
      end
      
      img = uint8(img - 1);
    else
      msg.identifier = 'MATLAB:im2java:InvalidImageClass';
      msg.message = getString(message('MATLAB:im2java:InvalidImageClassUint8Double'));
      return;
    end
    
  otherwise
   msg = message('MATLAB:im2java:TooManyInputs');
   return;
    
end


