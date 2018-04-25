function [h, s, v] = rgb2hsv(varargin)
%RGB2HSV Convert red-green-blue colors to hue-saturation-value.
%   H = RGB2HSV(M) converts an RGB color map to an HSV color map.
%   Each map is a matrix with any number of rows, exactly three columns,
%   and elements in the interval 0 to 1.  The columns of the input matrix,
%   M, represent intensity of red, blue and green, respectively.  The
%   columns of the resulting output matrix, H, represent hue, saturation
%   and color value, respectively.
%
%   HSV = RGB2HSV(RGB) converts the RGB image RGB (3-D array) to the
%   equivalent HSV image HSV (3-D array).
%
%   CLASS SUPPORT
%   -------------
%   If the input is an RGB image, it can be of class uint8, uint16, single,
%   or double. The output image is single when the input is single. For all 
%   other input data types, the output image is double. If the input is a
%   colormap, the input and output colormaps are both of class double.
%
%   See also HSV2RGB, COLORMAP, RGBPLOT.

%   Undocumented syntaxes:
%   [H,S,V] = RGB2HSV(R,G,B) converts the RGB image R,G,B to the
%   equivalent HSV image H,S,V.
%
%   HSV = RGB2HSV(R,G,B) converts the RGB image R,G,B to the
%   equivalent HSV image stored in the 3-D array (HSV).
%
%   [H,S,V] = RGB2HSV(RGB) converts the RGB image RGB (3-D array) to
%   the equivalent HSV image H,S,V.
%
%   See Alvy Ray Smith, Color Gamut Transform Pairs, SIGGRAPH '78.

%   Copyright 1984-2015 The MathWorks, Inc.

[r, g, b, isColorMap, isEmptyInput, isThreeChannel] = parseInputs(varargin{:});

if(~isEmptyInput)

    if(isThreeChannel)
        imageIn(:,:,1) = r;
        imageIn(:,:,2) = g;
        imageIn(:,:,3) = b;
    elseif(isColorMap)
        imageIn = reshape(varargin{1},size(varargin{1},1),1,size(varargin{1},2));
    else
        imageIn = r;        
    end

    h = images.internal.rgb2hsvmex(imageIn);

    if(nargout == 3)
        s = h(:,:,2);
        v = h(:,:,3);
        h = h(:,:,1);        
    elseif(isColorMap)
        h = reshape(h,size(h,1), size(h,3));
    end
    
else
    if(isThreeChannel)
        h = r;
        s = g;
        v = b;
    else
        h = r;
    end
end

function [r, g, b, isColorMap, isEmptyInput, isThreeChannel] = parseInputs(varargin)

isColorMap = 0;
isEmptyInput = 0;
isThreeChannel = 0;

if (nargin == 1)
    r = varargin{1};
    g = [];
    b = [];
    if (ndims(r)==3)
        if isempty(r)
            isEmptyInput = 1;
            return
        end
        if(size(r,3) ~= 3)
            error(message('MATLAB:rgb2hsv:invalidInputSizeRGB'));
        end

        validateattributes(r, {'uint8', 'uint16', 'double', 'single'}, {'real'}, mfilename, 'RGB', 1);

    elseif ismatrix(r) %M x 3 matrix for M colors.
        
        isColorMap = 1;
        if(size(r,2) ~=3)
            error(message('MATLAB:rgb2hsv:invalidSizeForColormap'));
        end

        validateattributes(r, {'double'}, {'real','nonempty','nonsparse'}, mfilename, 'M');

        if((any(r(:) < 0) || any(r(:) > 1)))
            error(message('MATLAB:rgb2hsv:badMapValues'));
        end
        
    else
        error(message('MATLAB:rgb2hsv:invalidInputSize'));
    end

elseif (nargin == 3)
    isThreeChannel = 1;
    r = varargin{1};
    g = varargin{2};
    b = varargin{3};

    if isempty(r) || isempty(g) || isempty(b)
        isEmptyInput = 1;
        return
    end  
    
    validateattributes(r, {'uint8', 'uint16', 'double', 'single'}, {'real', '2d'}, mfilename, 'R', 1);
    validateattributes(g, {'uint8', 'uint16', 'double', 'single'}, {'real', '2d'}, mfilename, 'G', 2);
    validateattributes(b, {'uint8', 'uint16', 'double', 'single'}, {'real', '2d'}, mfilename, 'B', 3);

    if ~isa(r, class(g)) || ~isa(g, class(b)) || ~isa(r, class(b)) % mixed type inputs.
        r = im2double(r);
        g = im2double(g);
        b = im2double(b);
    end
    
    if ~isequal(size(r),size(g),size(b))
        error(message('MATLAB:rgb2hsv:InputSizeMismatch'));
    end
    
else
    error(message('MATLAB:rgb2hsv:WrongInputNum'));
end
