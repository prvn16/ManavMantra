function ycbcr = rgb2ycbcr(varargin)
%RGB2YCBCR Convert RGB color values to YCbCr color space.
%   YCBCRMAP = RGB2YCBCR(MAP) converts the RGB values in MAP to the YCBCR
%   color space. MAP must be a M-by-3 array. YCBCRMAP is a M-by-3 matrix
%   that contains the YCBCR luminance (Y) and chrominance (Cb and Cr) color
%   values as columns.  Each row represents the equivalent color to the
%   corresponding row in the RGB colormap.
%
%   YCBCR = RGB2YCBCR(RGB) converts the truecolor image RGB to the
%   equivalent image in the YCBCR color space. RGB must be a M-by-N-by-3
%   array.
%
%   If the input is uint8, then YCBCR is uint8 where Y is in the range [16
%   235], and Cb and Cr are in the range [16 240]. If the input is double
%   or single, then Y is in the range [16/255 235/255] and Cb and Cr are in
%   the range [16/255 240/255]. If the input is uint16, then Y is in the
%   range [4112 60395] and Cb and Cr are in the range [4112 61680].
%
%   Class Support
%   -------------
%   If the input is an RGB image, it can be uint8, uint16, single or
%   double. If the input is a colormap, then it must be single or double.
%   The output has the same class as the input.
%
%   Examples
%   --------
%   Convert RGB image to YCbCr.
%
%      RGB = imread('board.tif');
%      YCBCR = rgb2ycbcr(RGB);
%
%   Convert RGB color space to YCbCr.
%
%      map = jet(256);
%      newmap = rgb2ycbcr(map);
%
%   See also NTSC2RGB, RGB2NTSC, YCBCR2RGB.

%   Copyright 1993-2016 The MathWorks, Inc.

%   References:
%     C.A. Poynton, "A Technical Introduction to Digital Video", John Wiley
%     & Sons, Inc., 1996, p. 175
%
%     Rec. ITU-R BT.601-5, "STUDIO ENCODING PARAMETERS OF DIGITAL TELEVISION
%     FOR STANDARD 4:3 AND WIDE-SCREEN 16:9 ASPECT RATIOS",
%     (1982-1986-1990-1992-1994-1995), Section 3.5.

rgb = parse_inputs(varargin{:});

% Initialize variables
isColormap = false;

% Must reshape colormap to be m x n x 3 for transformation
if ismatrix(rgb)
    %colormap
    isColormap = true;
    colors = size(rgb,1);
    rgb = reshape(rgb, [colors 1 3]);
end

% This matrix comes from a formula in Poynton's, "Introduction to
% Digital Video" (p. 176, equations 9.6).

% T is from equation 9.6: ycbcr = origT * rgb + origOffset;
origT = [ ...
    65.481 128.553 24.966;...
    -37.797 -74.203 112; ...
    112 -93.786 -18.214];
origOffset = [16; 128; 128];

% The formula ycbcr = origT * rgb + origOffset, converts a RGB image in the
% range [0 1] to a YCbCr image where Y is in the range [16 235], and Cb and
% Cr are in that range [16 240]. For each class type, we must calculate
% scaling factors for origT and origOffset so that the input image is
% scaled between 0 and 1, and so that the output image is in the range of
% the respective class type.

scaleFactor.float.T = 1/255;      % scale output so in range [0 1].
scaleFactor.float.offset = 1/255; % scale output so in range [0 1].
scaleFactor.uint8.T = 1/255;      % scale input so in range [0 1].
scaleFactor.uint8.offset = 1;     % output is already in range [0 255].
scaleFactor.uint16.T = 257/65535; % scale input so it is in range [0 1]
% and scale output so it is in range
% [0 65535] (255*257 = 65535).
scaleFactor.uint16.offset = 257;   % scale output so it is in range [0 65535].

% The formula ycbcr = origT*rgb + origOffset is rewritten as
% ycbcr = scaleFactorForT * origT * rgb + scaleFactorForOffset*origOffset.
% To use imlincomb, we rewrite the formula as ycbcr = T * rgb + offset, where T and
% offset are defined below.
if isfloat(rgb)
    classIn = 'float';
else
    classIn = class(rgb);
end
T = scaleFactor.(classIn).T * origT;
offset = scaleFactor.(classIn).offset * origOffset;

% Initialize output
ycbcr = zeros(size(rgb), 'like', rgb);

for p = 1:3
    ycbcr(:,:,p) = imlincomb(T(p,1),rgb(:,:,1),T(p,2),rgb(:,:,2), ...
        T(p,3),rgb(:,:,3),offset(p));
end

if isColormap
    ycbcr = reshape(ycbcr, [colors 3 1]);
end

%%%
%Parse Inputs
%%%
function X = parse_inputs(varargin)

narginchk(1,1);
X = varargin{1};

if ismatrix(X)
    % For backward compatibility, this function handles uint8 and uint16
    % colormaps. This usage will be removed in a future release.
    
    validateattributes(X,{'uint8','uint16','single','double'}, ...
        {'nonempty','real'},mfilename,'MAP',1);
    if (size(X,2) ~= 3 || size(X,1) < 1)
        error(message('images:rgb2ycbcr:invalidSizeForColormap'));
    end
    if ~isfloat(X)
        warning(message('images:rgb2ycbcr:notAValidColormap'));
        X = im2double(X);
    end
elseif (ndims(X) == 3)
    validateattributes(X,{'uint8','uint16','single','double'},{'real'}, ...
        mfilename,'RGB',1);
    if (size(X,3) ~= 3)
        error(message('images:rgb2ycbcr:invalidTruecolorImage'));
    end
else
    error(message('images:rgb2ycbcr:invalidInputSize'))
end
