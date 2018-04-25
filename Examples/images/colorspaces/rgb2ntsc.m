function A = rgb2ntsc(A)
%RGB2NTSC Convert RGB color values to NTSC color space.
%   YIQMAP = RGB2NTSC(RGBMAP) converts the M-by-3 RGB values in RGBMAP to NTSC
%   colorspace. YIQMAP is an M-by-3 matrix that contains the NTSC luminance
%   (Y) and chrominance (I and Q) color components as columns that are
%   equivalent to the colors in the RGB colormap.
%
%   YIQ = RGB2NTSC(RGB) converts the truecolor image RGB to the equivalent
%   NTSC image YIQ.
%
%   Class Support
%   -------------
%   RGB can be uint8, uint16, int16, double, or single. RGBMAP can be double.
%   The output is double.
%
%   Examples
%   --------
%      I = imread('board.tif');
%      J = rgb2ntsc(I);
%
%      map = jet(256);
%      newmap = rgb2ntsc(map);
%
%   See also NTSC2RGB, RGB2IND, IND2RGB, IND2GRAY.

%   Copyright 1992-2015 The MathWorks, Inc.

A = parse_inputs(A);

T = [1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703].';
[so(1),so(2),thirdD] = size(A);
if (thirdD == 1) % A is RGBMAP, M-by-3 colormap
    A = A/T;
else % A is truecolor image RBG
    A = reshape(reshape(A,so(1)*so(2),thirdD)/T,so(1),so(2),thirdD);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%
function A = parse_inputs(A)

% YIQ = rgb2ntsc(RGB) or yiqmap = rgb2ntsc(rgbmap)

% Check validity of the input parameters. A is converted to double because 
% YIQ colorspace can contain negative values.

if ismatrix(A)
    % Check colormap
    if (size(A,2)~=3 || size(A,1) < 1)
        error(message('images:rgb2ntsc:invalidColormap'))
    end
    % Accept all numeric data types (although the doc says it must be double)
    % except uint64 and int64 because A will be cast to double
    validateattributes(A, ...
        {'single','double','uint8','uint16','uint32','int8','int16','int32'}, ...
        {'real'},mfilename,'RGBMAP')
    % Throw a warning if input is not double
    if ~isa(A,'double')
        warning(message('images:rgb2ntsc:colormapRange'))
        A = im2double(A);
    end
elseif ndims(A)==3
    % Check RGB
    if size(A,3)~=3
        error(message('images:rgb2ntsc:invalidTruecolorImage'))
    end
    % RGB can be of class uint8, uint16, int16, single or double
    validateattributes(A, ...
        {'single','double','uint8','uint16','int16'}, ...
        {'real'},mfilename,'RGB')
    % Convert to double because colorspace conversion is made in double
    A = im2double(A);
else
    error(message('images:rgb2ntsc:invalidSize'))
end
