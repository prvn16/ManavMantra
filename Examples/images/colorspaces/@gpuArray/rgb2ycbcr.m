function ycbcr = rgb2ycbcr(varargin)
%RGB2YCBCR Convert RGB color values to YCbCr color space.
%   YCBCRMAP = RGB2YCBCR(MAP) converts the RGB values in MAP to the YCBCR
%   color space. MAP must be a M-by-3 gpuArray. YCBCRMAP is a M-by-3
%   gpuArray that contains the YCBCR luminance (Y) and chrominance
%   (Cb and Cr) color values as columns.  Each row represents the equivalent
%   color to the corresponding row in the RGB colormap.
%
%   YCBCR = RGB2YCBCR(RGB) converts the truecolor image RGB to the
%   equivalent image in the YCBCR color space. RGB must be a M-by-N-by-3
%   gpuArray.
%
%   If the input gpuArray contains uint8, then YCBCR contains uint8 where Y
%   is in the range [16 235], and Cb and Cr are in the range [16 240].  If 
%   the input gpuArray contains a double, then Y is in the range 
%   [16/255 235/255] and Cb and Cr are in the range [16/255 240/255].  If 
%   the input gpuArray contains uint16, then Y is in the range [4112
%   60395] and Cb and Cr are in the range [4112 61680].
%
%   Class Support
%   -------------
%   If the input gpuArray is an RGB image, it can contain uint8, uint16, 
%   single or double. If the input gpuArray is a colormap, then it must 
%   contain single or double. The output has the same class as the input.
%
%   Examples
%   --------
%   Convert RGB image to YCbCr.
%
%      RGB = imread('board.tif');
%      YCBCR = rgb2ycbcr(gpuArray(RGB));
%
%   Convert RGB color space to YCbCr.
%
%      map = jet(256);
%      newmap = rgb2ycbcr(gpuArray(map));
%
%   See also NTSC2RGB, RGB2NTSC, GPUARRAY/YCBCR2RGB.

%   Copyright 1993-2016 The MathWorks, Inc.

%   References:
%     C.A. Poynton, "A Technical Introduction to Digital Video", John Wiley
%     & Sons, Inc., 1996, p. 175
%
%     Rec. ITU-R BT.601-5, "STUDIO ENCODING PARAMETERS OF DIGITAL TELEVISION
%     FOR STANDARD 4:3 AND WIDE-SCREEN 16:9 ASPECT RATIOS",
%     (1982-1986-1990-1992-1994-1995), Section 3.5.

rgb = parseInputs(varargin{:});

% Initialize variables
isColormap = false;

% Reshape colormap to be m x n x 3 for transformation
if (ismatrix(rgb))
    % Colormap
    isColormap=true;
    colors = size(rgb,1);
    rgb = reshape(rgb, [colors 1 3]);
end

% This matrix comes from a formula in Poynton's, "Introduction to
% Digital Video" (p. 176, equations 9.6).

% T is from equation 9.6: ycbcr = origT * rgb + origOffset;
origT = [65.481 128.553 24.966;...
    -37.797 -74.203 112; ...
    112 -93.786 -18.214];
origOffset = [16;128;128];

% The formula ycbcr = origT * rgb + origOffset, converts a RGB image in the range
% [0 1] to a YCbCr image where Y is in the range [16 235], and Cb and Cr
% are in that range [16 240]. For each class type (double,uint8,
% uint16), we must calculate scaling factors for origT and origOffset so that
% the input image is scaled between 0 and 1, and so that the output image is
% in the range of the respective class type.

scaleFactor.double.T = 1/255;      % scale output so in range [0 1].
scaleFactor.double.offset = 1/255; % scale output so in range [0 1].
scaleFactor.uint8.T = 1/255;       % scale input so in range [0 1].
scaleFactor.uint8.offset = 1;      % output is already in range [0 255].
scaleFactor.uint16.T = 257/65535;  % scale input so it is in range [0 1]
                                   % and scale output so it is in range
                                   % [0 65535] (255*257 = 65535).
scaleFactor.uint16.offset = 257;   % scale output so it is in range [0 65535].
scaleFactor.single.T = single(1/255);      % scale output so in range [0 1].
scaleFactor.single.offset = single(1/255); % scale output so in range [0 1].

% The formula ycbcr = origT*rgb + origOffset is rewritten as
% ycbcr = scaleFactorForT * origT * rgb + scaleFactorForOffset*origOffset.
% To use imlincomb, we rewrite the formula as ycbcr = T * rgb + offset, where T and
% offset are defined below.
classIn = classUnderlying(rgb);
if strcmp(classIn,'single')
    origT = cast(origT,'single');
    origOffset = cast(origOffset,'single');
end
T = scaleFactor.(classIn).T * origT;
offset = scaleFactor.(classIn).offset * origOffset;

% Initialize output
ycbcr = gpuArray.zeros(size(rgb),classIn);

if strcmp(classIn,'uint8')
    ycbcr = images.internal.gpu.rgb2ycbcr(rgb);
else
    subR.type = '()';
    subR.subs = {':',':',1};
    
    subG.type = '()';
    subG.subs = {':',':',2};
    
    subB.type = '()';
    subB.subs = {':',':',3};
    
    r = subsref(rgb,subR);
    g = subsref(rgb,subG);
    b = subsref(rgb,subB);
    
    if ~strcmp(classIn,'single') ||...
            ~strcmp(classIn,'double')
        r = cast(r,'double');
        g = cast(g,'double');
        b = cast(b,'double');
    end
    
    for p = 1:3
        sycbcr.type = '()';
        sycbcr.subs = {':',':',p};
        
        TR = T(p,1);
        TG = T(p,2);
        TB = T(p,3);
        offsetp = offset(p);
        
        % Use private function lincomb to calculate YCbCr output
        ycbcr = subsasgn(ycbcr, sycbcr ,...
            arrayfun(@lincomb,r,g,b,TR,TG,TB,offsetp));
    end
end

if isColormap
    ycbcr = reshape(ycbcr, [colors 3 1]);
end

if ~strcmp(classIn,'single') ||...
        ~strcmp(classIn,'double')
    ycbcr = cast(ycbcr,classIn);
end

%%%
%Parse Inputs
%%%
function X = parseInputs(varargin)

narginchk(1,1);
X = varargin{1};

if ismatrix(X)
    hValidateAttributes(X,{'double','single'}, ...
        {'nonsparse','nonempty','real'},mfilename,'MAP',1);
    if (size(X,2) ~=3 || size(X,1) < 1)
        error(message('images:rgb2ycbcr:invalidSizeForColormap'))
    end
    
elseif ndims(X)==3
    hValidateAttributes(X,{'uint8','uint16','double','single'}, ...
        {'nonsparse','real'},mfilename,'RGB',1);
    if (size(X,3) ~=3)
        error(message('images:rgb2ycbcr:invalidTruecolorImage'))
    end
else
    error(message('images:rgb2ycbcr:invalidInputSize'))
end
