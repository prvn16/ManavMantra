function [X,map] = gray2ind(varargin)
%GRAY2IND Convert intensity image to indexed image.
%   GRAY2IND scales, then rounds, an intensity image to produce an equivalent
%   indexed image.
%
%   [X,MAP] = GRAY2IND(I,N) converts the intensity image I to an indexed image X
%   with colormap GRAY(N). If N is omitted, it defaults to 64.
%
%   [X,MAP] = GRAY2IND(BW,N) converts the binary image BW to an indexed image X
%   with colormap GRAY(N). If N is omitted, it defaults to 2.
%
%   N must be an integer between 1 and 65536.
% 
%   Class Support
%   -------------      
%   The input image I can be logical, uint8, uint16, int16, single, or double
%   and must be real and nonsparse.  I can have any dimension.  The class of the
%   output image X is uint8 if the colormap length is less than or equal to 256;
%   otherwise it is uint16.
%
%   Example
%   -------
%       I = imread('cameraman.tif');
%       [X, map] = gray2ind(I, 16);
%       figure, imshow(X, map);
%
%   See also GRAYSLICE, IND2GRAY, MAT2GRAY.

%   Copyright 1992-2006 The MathWorks, Inc.
  
[I,n] = parse_inputs(varargin{:});
    
if islogical(I)  % is it a binary image?
    X = bw2index(I,n);
else
    X = gray2index(I,n);
end

map = gray(n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X = bw2index(BW,n)

if n <= 256
    X = uint8(BW);
else
    X = uint16(BW);
end

X(BW) = n-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X = gray2index(I,n)

range = getrangefromclass(I);
sf = (n - 1) / range(2);

if n <= 256   
    % 256 or fewer colors, we can output uint8
    X = imlincomb(sf,I,'uint8');
else    
    X = imlincomb(sf,I,'uint16');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I,n] = parse_inputs(varargin)

default_grayscale_colormap_size = 64;
default_binary_colormap_size = 2;

narginchk(1,2);

I = varargin{1};

if nargin == 1
    if islogical(I)
        n = default_binary_colormap_size;
    else
        n = default_grayscale_colormap_size;
    end
else
    n = varargin{2};
    validateattributes(n,{'numeric'},{'real', 'integer'}, mfilename, 'N', 2);
    if n < 1 || n > 65536
        error(message('images:gray2ind:inputOutOfRange'));
    end
end

validateattributes(I,{'uint8','int16','uint16','double','logical','single'},...
              {'real','nonsparse'}, mfilename,'I',1);
% Convert int16 image to uint16.
if isa(I,'int16')
  I = int16touint16mex(I);
end
