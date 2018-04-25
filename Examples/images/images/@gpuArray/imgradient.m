function [Gmag, Gdir] = imgradient(varargin)
%IMGRADIENT Find the gradient magnitude and direction of an image.
%   [Gmag, Gdir] = IMGRADIENT(I) takes a grayscale or binary gpuArray image
%   I as input and returns the gradient magnitude, Gmag, and the gradient
%   direction, Gdir as gpuArray's. Gmag and Gdir are the same size as the
%   input image I. Gdir contains angles in degrees within the range [-180
%   180] measured counterclockwise from the positive X axis (X axis points
%   in the direction of increasing column subscripts).
%
%   [Gmag, Gdir] = IMGRADIENT(I, METHOD) calculates the gradient magnitude
%   and direction using the specified METHOD. Supported METHODs are:
%
%       'Sobel'                 : Sobel gradient operator (default)
%
%       'Prewitt'               : Prewitt gradient operator
%
%       'CentralDifference'     : Central difference gradient dI/dx = (I(x+1)- I(x-1))/ 2
%
%       'IntermediateDifference': Intermediate difference gradient dI/dx = I(x+1) - I(x)
%
%       'Roberts'               : Roberts gradient operator
%
%   [Gmag, Gdir] = IMGRADIENT(Gx, Gy) calculates the gradient magnitude and
%   direction from the directional gradients along the X axis, Gx, and
%   Y axis, Gy, such as that returned by IMGRADIENTXY. X axis points in the
%   direction of increasing column subscripts and Y axis points in the
%   direction of increasing row subscripts.
%
%   Class Support
%   -------------
%   The input gpuArray image I and the input directional gradients Gx and
%   Gy can be numeric or logical two-dimensional matrices. Both Gmag and
%   Gdir are of underlying class double in all cases, except when the input
%   gpuArray image I or either one or both of the directional gradients Gx
%   and Gy is of underlying class single. In that case Gmag and Gdir will
%   be of class single.
%
%   Notes
%   -----
%   1. When applying the gradient operator at the boundaries of the image,
%      values outside the bounds of the image are assumed to equal the
%      nearest image border value. This is similar to the 'replicate'
%      boundary option in IMFILTER.
%
%   Example 1
%   ---------
%   This example computes and displays the gradient magnitude and direction
%   of the image coins.png using Prewitt's gradient operator.
%
%   I = gpuArray(imread('coins.png'));
%   imshow(I)
%
%   [Gmag, Gdir] = imgradient(I,'prewitt');
%
%   figure, imshow(Gmag, []), title('Gradient magnitude')
%   figure, imshow(Gdir, []), title('Gradient direction')
%
%   Example 2
%   ---------
%   This example computes and displays both the directional gradients and the
%   gradient magnitude and gradient direction for the image coins.png.
%
%   I = gpuArray(imread('coins.png'));
%   imshow(I)
%
%   [Gx, Gy] = imgradientxy(I);
%   [Gmag, Gdir] = imgradient(Gx, Gy);
%
%   figure, imshow(Gmag, []), title('Gradient magnitude')
%   figure, imshow(Gdir, []), title('Gradient direction')
%   figure, imshow(Gx, []), title('Directional gradient: X axis')
%   figure, imshow(Gy, []), title('Directional gradient: Y axis')
%
%   See also GPUARRAY/EDGE, FSPECIAL, GPUARRAY/IMGRADIENTXY, GPUARRAY.

% Copyright 2013-2016 The MathWorks, Inc.


narginchk(1,2);

[I, Gx, Gy, method] = parse_inputs(varargin{:});

% Compute directional gradients
if (isempty(I))
    % Gx, Gy are given as inputs
    if ~isfloat(Gx)
        Gx = double(Gx);
    end
    if ~isfloat(Gy)
        Gy = double(Gy);
    end
    
else
    % If Gx, Gy not given, compute them. For all others except Roberts
    % method, use IMGRADIENTXY to compute Gx and Gy.
    if (strcmpi(method,'roberts'))
        if ~isfloat(I)
            I = double(I);
        end
        Gx = imfilter(I,[1 0; 0 -1],'replicate');
        Gy = imfilter(I,[0 1; -1 0],'replicate');
        
    else
        [Gx, Gy] = imgradientxy(I,method);
        
    end
end

% Compute gradient direction and magnitude
if (nargout <= 1)
    Gmag = hypot(Gx,Gy);
else
    toradian = 180/pi; % up-level indexing
    if (strcmpi(method,'roberts'))
        % For pixels with zero gradient (both Gx and Gy zero), Gdir is set
        % to 0. Compute direction only for pixels with non-zero gradient.
        % arrayfun is used to leverage element-wise computation speed-up.
        
        % up-level indexing
        pibyfour = pi/4;
        twopi    = 2*pi;
        pii      = pi;
        
        [Gmag,Gdir] = arrayfun(@computeDirectionAndMagnitudeGradientRoberts,Gx,Gy);
    else
        [Gmag,Gdir] = arrayfun(@computeDirectionAndMagnitudeGradient,Gx,Gy);
    end
end

    % Nested function to compute gradient magnitude and direction for
    % 'roberts'.
    function [gmag,gdir] = computeDirectionAndMagnitudeGradientRoberts(gx,gy)
        if gx==0 && gy==0
            gdir = 0;
        else
            gdir = atan2(gy,-gx) - pibyfour;
            if gdir < -pii
                gdir = gdir + twopi;
            end
            gdir = gdir*toradian;
        end
        gmag = hypot(gx,gy);
    end

    % Nested function to compute gradient magnitude and direction for
    % 'sobel' and 'prewitt'.
    function [gmag,gdir] = computeDirectionAndMagnitudeGradient(gx,gy)
        gdir = atan2(-gy,gx)*toradian;
        gmag = hypot(gx,gy);
    end
end
%======================================================================
function [I, Gx, Gy, method] = parse_inputs(varargin)

methodstrings = {'sobel','prewitt','roberts','centraldifference', ...
    'intermediatedifference'};
I = [];
Gx = [];
Gy = [];
method = 'sobel'; % Default method

if (nargin == 1)
    I = gpuArray( varargin{1} );
    hValidateAttributes(I,...
        {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'}, ...
        {'2d','real','nonsparse'},mfilename,'I',1);
    
else % (nargin == 2)
    if ischar(varargin{2}) || isstring(varargin{2})
        I = gpuArray( varargin{1} );
        hValidateAttributes(I,...
            {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'}, ...
            {'2d','real','nonsparse'},mfilename,'I',1);
        validateattributes(varargin{2},{'char','string'}, ...
            {'scalartext'},mfilename,'METHOD',2);
        method = validatestring(varargin{2}, methodstrings, ...
            mfilename, 'METHOD', 2);
    else
        Gx = gpuArray( varargin{1} );
        Gy = gpuArray( varargin{2} );
        hValidateAttributes(Gx,...
            {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'}, ...
            {'2d','real','nonsparse'},mfilename,'Gx',1);
        hValidateAttributes(Gy,...
            {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'}, ...
            {'2d','real','nonsparse'},mfilename,'Gy',2);
        
        
        if (~isequal(size(Gx),size(Gy)))
            error(message('images:validate:unequalSizeMatrices','Gx','Gy'));
        end
    end
    
end

end
%----------------------------------------------------------------------