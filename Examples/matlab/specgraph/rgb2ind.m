function [X,map] = rgb2ind(varargin)
%RGB2IND Convert RGB image to indexed image.
%   RGB2IND converts RGB images to indexed images using one of three
%   different methods: uniform quantization, minimum variance quantization,
%   and colormap approximation. RGB2IND dithers the image unless you specify
%   'nodither' for DITHER_OPTION.
%
%   [X,MAP] = RGB2IND(RGB,N) converts the RGB image to an indexed image X
%   using minimum variance quantization. MAP contains at most N colors.  N
%   must be <= 65536.
%
%   X = RGB2IND(RGB,MAP) converts the RGB image to an indexed image X with
%   colormap MAP by matching colors in RGB with the nearest color in the
%   colormap MAP.  SIZE(MAP,1) must be <= 65536.
%
%   [X,MAP] = RGB2IND(RGB,TOL) converts the RGB image to an indexed image X
%   using uniform quantization. MAP contains at most (FLOOR(1/TOL)+1)^3
%   colors. TOL must be between 0.0 and 1.0.
%
%   [...] = RGB2IND(...,DITHER_OPTION) enables or disables
%   dithering. DITHER_OPTION is a string that can have one of these values:
%
%       'dither'   dithers, if necessary, to achieve better color
%                  resolution at the expense of spatial
%                  resolution (default)
%
%       'nodither' maps each color in the original image to the
%                  closest color in the new map. No dithering is
%                  performed.
%
%   Class Support
%   -------------
%   The input image can be uint8, uint16, single, or double. The output image is
%   uint8 if the length of MAP is less than or equal to 256, or uint16
%   otherwise.
%
%   Example
%   -------
%       RGB = imread('ngc6543a.jpg');
%       [X,map] = rgb2ind(RGB,128);
%       figure, image(X), colormap(map)
%       axis off
%       axis image
%
%   See also CMUNIQUE, DITHER, IMAPPROX, IND2RGB.

%   Copyright 1992-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[RGB,m,dith] = parse_inputs(varargin{:});

so = size(RGB);

% Converts depending on what is m:
if isempty(m) % Convert RGB image to an indexed image.
    X = reshape(1:(so(1)*so(2)),so(1),so(2));
    if so(1)*so(2) <= 256
        X = uint8(X-1);
    elseif so(1)*so(2) <= 65536
        X = uint16(X-1);
    end
    map = im2doubleLocal(reshape(RGB,so(1)*so(2),3));

elseif length(m)==1 % TOL or N is given
    if isa(RGB,'uint16') || isfloat(RGB)
        RGB = grayto8(RGB);
    end

    if (m < 1) % tol is given. Use uniform quantization
        max_colors = 65536;
        max_N = floor(max_colors^(1/3)) - 1;
        N = round(1/m);
        if (N > max_N)
            N = max_N;
            warning(message('MATLAB:rgb2ind:tooManyColors', sprintf( '%g', 1/N )));
        end
        
        [x,y,z] = meshgrid((0:N)/N);
        map = [x(:),y(:),z(:)];

        if dith(1) == 'n'
            RGB = round(im2doubleLocal(RGB)*N);
            X = RGB(:,:,3)*((N+1)^2)+RGB(:,:,1)*(N+1)+RGB(:,:,2)+1;
        else
            X = dither(RGB,map);
        end
        [X,map] = cmunique(X,map);

    else % N is given. Use variance minimization quantization
        [map,X] = cq(RGB,m);
        map = double(map) / 255;
        if (dith(1) == 'd') && (size(map,1) > 1)
            % Use standalone dither if map is an approximation.
            X = dither(RGB,map);
        end
    end

else % MAP is given
    if isa(RGB,'uint16') || isfloat(RGB)
        RGB = grayto8(RGB);
    end

    map = m;
    if dith(1)=='n' % 'nodither'
        X = dither(RGB,map,5,4); % Use dither to do inverse colormap mapping.
    else
        X = dither(RGB,map);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [RGB,m,dith] = parse_inputs(varargin)
% Outputs:  RGB     image
%           m       colormap
%           dith    dithering option
% Defaults:
dith = 'dither';

narginchk(1,3);

switch nargin
    case 1               % rgb2ind(RGB)
        error(message('MATLAB:rgb2ind:obsoleteSyntaxNeedMoreArgs'));
    case 2               % rgb2ind(RGB,x) where x = MAP | N | TOL
        RGB = varargin{1};
        m = varargin{2};
    case 3               % rgb2ind(RGB,x,DITHER_OPTION)
        RGB = varargin{1};  %              where x = MAP | N | TOL
        m = varargin{2};
        dith = varargin{3};
    otherwise
        error(message('MATLAB:rgb2ind:invalidInputArgs'));
end

% Check validity of the input parameters
if ndims(RGB)==3 && size(RGB,3) ~= 3 || ndims(RGB) > 3
    error(message('MATLAB:rgb2ind:rgbNotMbyNby3'));
end

% Check MAP
if any(m(:)<0)
    error(message('MATLAB:rgb2ind:negativeValuesInMap'));
    
elseif size(m,1)==1 & m~=round(m) & m > 1 %#ok<AND2>
    error(message('MATLAB:rgb2ind:invalidNumberOfColors'));
    
elseif (size(m,1) > 1 && size(m,2) > 1 && size(m,2) ~= 3) || ~ismatrix(m)
    error(message('MATLAB:rgb2ind:invalidMapSize'));
    
elseif size(m,1) > 1 && max(m(:)) > 1
    error(message('MATLAB:rgb2ind:invalidMapIntensities'));
end

validateattributes(m, {'numeric'}, {'finite'}, mfilename, 'MAP')

if ischar(dith)% dither option
    strings = {'dither','nodither'};
    idx = strmatch(lower(dith),strings);
    if isempty(idx)
        error(message('MATLAB:rgb2ind:unknownDitherOption', dith));
    elseif length(idx)>1
        error(message('MATLAB:rgb2ind:ambiguousDitherOption', dith));
    else
        dith = strings{idx};
    end
else
    error(message('MATLAB:rgb2ind:ditherOptionNotString'));
end

%-------------------------------
function d = im2doubleLocal(img)

imgClass = class(img);

switch imgClass
    case {'uint8','uint16'}
        d = double(img) / double(intmax(imgClass));
    case {'single'}
        d = double(img);
    case 'double'
        d = img;
end
