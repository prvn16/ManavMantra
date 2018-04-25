function [Gmag, Gazimuth, Gelevation] = imgradient3(varargin)
%IMGRADIENT3 Find the 3-D gradient magnitude and direction of a volume.
%   [Gmag, Gazimuth, Gelevation] = IMGRADIENT3(V) takes a grayscale or
%   binary volume V as input and returns the gradient magnitude, Gmag,
%   and the gradient direction, Gazimuth and Gelevation. Gmag, Gazimuth and
%   Gelevation are the same size as the input volume V. Gazimuth contains
%   angles in degrees within the range [-180 180] measured between positive
%   X-axis and the projection of the point on the X-Y plane. Gelevation
%   contains angles in degrees within the range [-90 90] measured between
%   the Z-axis and the radial line.
%
%   [Gmag, Gazimuth, Gelevation] = IMGRADIENT3(V, METHOD) calculates the
%   gradient magnitude and direction using the specified METHOD.
%   Supported METHODs are:
%
%       'sobel'                 : Sobel gradient operator (default)
%
%       'prewitt'               : Prewitt gradient operator
%
%       'central'               : Central difference gradient dV/dx = (V(x+1)- V(x-1))/ 2
%
%       'intermediate'          : Intermediate difference gradient dV/dx = V(x+1) - V(x)
%
%
%   [Gmag, Gazimuth, Gelevation] = IMGRADIENT3(Gx, Gy, Gz) calculates the
%   gradient magnitude and direction from the directional gradients along
%   the X axis, Gx, Y axis, Gy and Z axis, Gz such as that returned by
%   IMGRADIENTXYZ. X axis points in the direction of increasing column
%   subscripts and Y axis points in the direction of increasing row
%   subscripts.
%
%   Class Support
%   -------------
%   The input volume V and the input directional gradients Gx, Gy and Gz can
%   be numeric or logical three-dimensional matrices, and they must be
%   nonsparse. Gmag Gazimuth and Gelevation are of class double in all
%   cases, except when the input volume V, or either one or all of the
%   directional gradients Gx, Gy and Gz are of class single. In that case
%   Gmag, Gazimuth and Gelevation will be of class single.
%
%   Notes
%   -----
%   1. When applying the gradient operator at the boundaries of the volume,
%      values outside the bounds of the volume are assumed to equal the
%      nearest volume border value. This is similar to the 'replicate'
%      boundary option in IMFILTER.
%
%   Example 1
%   ---------
%   This example computes 3-D gradient magnitude and direction using
%   Sobel's gradient operator.
%
%   volData = load('mri');
%   sz = volData.siz;
%   vol = squeeze(volData.D);
%
%   [Gmag, Gaz, Gelev] = imgradient3(vol);
%
%   % Visualize gradient magnitude as a montage.
%   figure, montage(reshape(Gmag,sz(1),sz(2),1,sz(3)),'DisplayRange',[])
%   title('Gradient magnitude')
%
%   See also imgradientxyz, imgradient, imgradientxy.

% Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,3);

[I,Gx, Gy, Gz, method] = parse_inputs(varargin{:});

if (isempty(I))
    [Gmag, Gazimuth, Gelevation] = calculateGradientMaginitudes(Gx,Gy,Gz);
    
else
    if(nargout<2)
        Gmag = imgradient3mex(I,method);
    else
        [Gmag, Gazimuth, Gelevation] = imgradient3mex(I,method);            
    end
end
        

end

function [Gmag, Gazimuth, Gelevation] = calculateGradientMaginitudes(Gx,Gy,Gz)
    
    Gmag = hypot(hypot(Gx, Gy), Gz);
    if (nargout > 1)
        Gazimuth = atan2(-Gy,Gx)*180/pi; % Radians to degrees
        Gelevation = atan2(Gz, hypot(Gx, Gy))*180/pi;
    end
end
%======================================================================
function [I, Gx, Gy, Gz, method] = parse_inputs(varargin)
    methodstrings = {'sobel','prewitt','central','intermediate'};
    I = [];
    Gx = [];
    Gy = [];
    Gz = [];

    method = 'sobel'; % Default method

    if (nargin == 1)
        I = varargin{1};
        validateattributes(I,{'numeric','logical'},{'3d','nonsparse','real'}, ...
            mfilename,'I',1);

    else % (nargin >= 2)
        if ischar(varargin{2}) || isstring(varargin{2})
            I = varargin{1};
            validateattributes(I,{'numeric','logical'},{'3d','nonsparse', ...
                'real'},mfilename,'I',1);
            validateattributes(varargin{2},{'char','string'}, ...
                {'scalartext'},mfilename,'METHOD',2);
            method = validatestring(varargin{2}, methodstrings, ...
                mfilename, 'METHOD', 2);
        else
            Gx = varargin{1};
            Gy = varargin{2};
            if nargin > 2
                Gz = varargin{3};
            end
            validateattributes(Gx,{'numeric','logical'},{'3d','nonsparse', ...
                'real'},mfilename,'Gx',1);
            validateattributes(Gy,{'numeric','logical'},{'3d','nonsparse', ...
                'real'},mfilename,'Gy',2);
            if nargin > 2
                validateattributes(Gz,{'numeric','logical'},{'3d','nonsparse', ...
                    'real'},mfilename,'Gz',3);
            end
            if (~isequal(size(Gx),size(Gy),size(Gz)))
                error(message('images:validate:unequalSizeMatrices3','Gx','Gy','Gz'));
            end
        end

    end
    
    if (isempty(I))
        % Gx, Gy and Gz are given as inputs
        if ~isfloat(Gx)
            Gx = double(Gx);
        end
        if ~isfloat(Gy)
            Gy = double(Gy);
        end
        if ~isfloat(Gz)
            Gz = double(Gz);
        end
    end

end