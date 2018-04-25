function rgb = ycbcr2rgb(varargin)
%YCBCR2RGB Convert YCbCr color values to RGB color space.
%   RGBMAP = YCBCR2RGB(YCBCRMAP) converts the YCbCr values in the colormap
%   YCBCRMAP to the RGB color space. If YCBCRMAP is an M-by-3 gpuArray and
%   contains the YCbCr luminance (Y) and chrominance (Cb and Cr) color
%   values as columns, then RGBMAP is an M-by-3 gpuArray that contains the
%   red, green, and blue values equivalent to those colors.
%
%   RGB = YCBCR2RGB(YCBCR) converts the YCbCr gpuArray image to the 
%   equivalent truecolor gpuArray image RGB.
%
%   Class Support
%   -------------
%   If the input is a YCbCr gpuArray image, it can contain uint8, uint16,
%   single or double; the output image contains the same class as the input
%   image. If the input is a colormap, the input and output gpuArray
%   colormaps can contain single or double.
%
%   Example
%   -------
%   Convert a gpuArray image from RGB space to YCbCr space and back.
%
%       rgb = gpuArray(imread('board.tif'));
%       ycbcr = rgb2ycbcr(rgb);
%       rgb2 = ycbcr2rgb(ycbcr);
%
%   See also NTSC2RGB, RGB2NTSC, GPUARRAY/RGB2YCBCR.

%   Copyright 1993-2016 The MathWorks, Inc.

%   References:
%     Charles A. Poynton, "A Technical Introduction to Digital Video",
%     John Wiley & Sons, Inc., 1996, p. 175-176
%
%     Rec. ITU-R BT.601-5, "STUDIO ENCODING PARAMETERS OF DIGITAL TELEVISION
%     FOR STANDARD 4:3 AND WIDE-SCREEN 16:9 ASPECT RATIOS",
%     (1982-1986-1990-1992-1994-1995), Section 3.5.

ycbcr = parseInputs(varargin{:});

classIn = classUnderlying(ycbcr);

if strcmp(classIn,'uint8')
    rgb = images.internal.gpu.ycbcr2rgb(ycbcr);
else
    isColormap = false;
    
    %must reshape colormap to be m x n x 3 for transformation
    if ismatrix(ycbcr)
        isColormap = true;
        colors = size(ycbcr,1);
        ycbcr = reshape(ycbcr, [colors 1 3]);
    end
    
    % This matrix comes from a formula in Poynton's, "Introduction to
    % Digital Video" (p. 176, equations 9.6 and 9.7).
    
    % T is from equation 9.6: ycbcr = T * rgb + offset;
    T = [65.481 128.553 24.966;...
        -37.797 -74.203 112; ...
        112 -93.786 -18.214];
    
    % We can rewrite the equation in terms of ycbcr which is
    % T ^-1 * (ycbcr - offset) = rgb.  This is equation 9.7 in the book.
    
    Tinv = T^-1;
    % Tinv = [0.00456621  0.          0.00625893;...
    %          0.00456621 -0.00153632 -0.00318811;...
    %          0.00456621  0.00791071  0.]
    offset = [16;128;128];
    
    % The formula Tinv * (ycbcr - offset) = rgb converts 8-bit YCbCr data to a RGB
    % image that is scaled between 0 and one. For each class type (double,single,
    % uint8,uint16), we must calculate scaling factors for Tinv and offset so that
    % the input image is scaled between 0 and 255, and so that the output image is
    % in the range of the respective class type.
    
    scaleFactor.double.T = 255;       % scale input so it is in range [0 255].
    scaleFactor.double.offset = 1;    % output already in range [0 1].
    scaleFactor.uint8.T = 255;        % scale output so it is in range [0 255].
    scaleFactor.uint8.offset = 255;   % scale output so it is in range [0 255].
    scaleFactor.uint16.T = 65535/257; % scale input so it is in range [0 255]
                                      % (65535/257 = 255),
                                      % and scale output so it is in range
                                      % [0 65535].
    scaleFactor.uint16.offset = 65535; % scale output so it is in range [0 65535].
    scaleFactor.single.T = single(255);      % scale output so in range [0 1].
    scaleFactor.single.offset = single(1); % scale output so in range [0 1].
    
    % The formula Tinv * (ycbcr - offset) = rgb is rewritten as
    % scaleFactorForT*Tinv*ycbcr - scaleFactorForOffset*Tinv*offset = rgb.
    % To use lincomb, we rewrite the formula as T * ycbcr - offset, where
    % T and offset are defined below.
    
    if strcmp(classIn,'single')
        Tinv = cast(Tinv,'single');
        offset = cast(offset,'single');
    end
    T = scaleFactor.(classIn).T * Tinv;
    offset = scaleFactor.(classIn).offset * Tinv * offset;
    
    rgb = gpuArray.zeros(size(ycbcr),classIn);
    
    subY.type = '()';
    subY.subs = {':',':',1};
    
    subCb.type = '()';
    subCb.subs = {':',':',2};
    
    subCr.type = '()';
    subCr.subs = {':',':',3};
    
    y = subsref(ycbcr,subY);
    cb = subsref(ycbcr,subCb);
    cr = subsref(ycbcr,subCr);
    
    for p = 1:3
        srgb.type = '()';
        srgb.subs = {':',':',p};
        
        TY = T(p,1);
        TCb = T(p,2);
        TCr = T(p,3);
        offsetp = -offset(p);
        
        if strcmp(classIn,'uint16')
            % Use private function lincombuint16 to calculate RGB output
            % for uint16 input
            rgb = subsasgn(rgb, srgb ,...
                arrayfun(@lincombuint16,y,cb,cr,TY,TCb,TCr,offsetp));
        else
            % Use private function lincomb to calculate RGB output
            rgb = subsasgn(rgb, srgb ,...
                arrayfun(@lincomb,y,cb,cr,TY,TCb,TCr,offsetp));
        end
    end
    
    if isColormap
        rgb = reshape(rgb, [colors 3 1]);
    end
    
    if strcmp(classIn,'double') || ...
            strcmp(classIn,'single')
        rgb = min(max(rgb,0.0),1.0);
    end
end

%%%
%Parse Inputs
%%%
function X = parseInputs(varargin)

narginchk(1,1);
X = varargin{1};

if ismatrix(X)
    hValidateAttributes(X,{'double','single'},{'real','nonempty','nonsparse'},mfilename,'MAP',1);
       
    if (size(X,2) ~=3 || size(X,1) < 1)
        error(message('images:ycbcr2rgb:invalidSizeForColormap'))
    end
    
elseif ndims(X) == 3
    hValidateAttributes(X,{'uint8','uint16','double','single'},{'real','nonsparse'},mfilename,'YCBCR',1);
    
    if (size(X,3) ~=3)
        error(message('images:ycbcr2rgb:invalidTruecolorImage'))
    end
    
else
    error(message('images:ycbcr2rgb:invalidInputSize'))
end
