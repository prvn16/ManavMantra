function J = imimposemin(varargin)
%IMIMPOSEMIN Impose minima.
%   I2 = IMIMPOSEMIN(I,BW) modifies the intensity image I using
%   morphological reconstruction so it only has regional minima wherever BW
%   is nonzero.  BW is a binary image the same size as I.
%
%   By default, IMIMPOSEMIN uses 8-connected neighborhoods for 2-D images
%   and 26-connected neighborhoods for 3-D images.  For higher
%   dimensions, IMIMPOSEMIN uses CONNDEF(NDIMS(I),'maximal').  
%
%   The syntax I2 = IMIMPOSEMIN(I,BW,CONN) overrides the default
%   connectivity.  CONN may have the following scalar values:
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%   
%   Class support
%   -------------
%   I can be of any nonsparse numeric class and any dimension.  BW must
%   be a nonsparse numeric array with the same size as I.  I2 has the
%   same size and class as I. 
%
%   Example
%   -------
%   Modify the image in glass.png so that it has a regional minimum in only
%   one location.
%
%       I = imread('glass.png');
%       figure, imshow(I) % Original image
%       BW = imregionalmin(I);
%       figure, imshow(BW) % Locations of all Regional Minima
%
%       %Mark a location to impose the new minima.
%       BW2 = false(size(I));
%       BW2(65:70,65:70) = true;
%
%       %Display the original image with the new minima location superimposed
%       %in white.
%       J = I;
%       J(BW2) = 255;
%       figure, imshow(J) % Image with desired minima location superimposed
%       
%       %Impose the new minima.
%       K = imimposemin(I,BW2);
%       figure, imshow(K) % Modified image with new minima
%
%       %Display the regional minima locations in the modified image.
%       BW3 = imregionalmin(K);
%       figure, imshow(BW3) % Regional minima of modified image
%
%   See also CONNDEF, IMRECONSTRUCT, IMREGIONALMIN.

%   Copyright 1993-2012 The MathWorks, Inc.

% Testing notes
% -------------
% imregionalmin(J,conn) should be nonzero only where BW is nonzero.
%
% I     - real, full, nonsparse, numeric array, any dimension.  Required.
%       - Infs OK, NaNs not allowed.
%       - empty OK
%
% BW    - binary image, same size as I.  Required.
%
% CONN  - valid connectivity specifier.  Optional.

[I,BW,conn] = ParseInputs(varargin{:});

if isempty(I)
    J = I;
    return;
end

fm = I;
fm(BW) = -Inf;
fm(~BW) = Inf;

if isa(I,'double') || isa(I,'single')
    range = double(max(I(:))) - double(min(I(:)));
    if range == 0
        h = 0.1;
    else
        h = range * 0.001;
    end
else
    % Add 1 to integer images.
    h = 1;
end

fp1 = I + h;

g = min(fp1,fm);

J = imreconstruct(imcomplement(fm),imcomplement(g),conn);
J = imcomplement(J);

%%%
%%% ParseInputs
%%%
function [I,BW,conn] = ParseInputs(varargin)

narginchk(2,3);

I = varargin{1};
validateattributes(I, {'numeric'}, {'real' 'nonsparse'}, mfilename, 'I', 1);

BW = varargin{2};
validateattributes(BW, {'numeric' 'logical'}, {'real' 'nonsparse'}, ...
              mfilename, 'BW', 2);
if ~islogical(BW)
    BW = BW ~= 0;
end
              
if nargin < 3
    conn = conndef(ndims(I),'maximal');
else
    conn = varargin{3};
    iptcheckconn(conn, mfilename, 'CONN', 3);
end

if ~isequal(size(BW), size(I))
    error(message('images:imimposemin:sizeMismatch'))
end
