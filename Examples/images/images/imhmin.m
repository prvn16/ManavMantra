function I = imhmin(I, H, varargin) 
%IMHMIN H-minima transform.
%   I2 = IMHMIN(I,H) suppresses all minima in I whose depth is less than
%   H.  I is an intensity image and H is a nonnegative scalar.
%
%   Regional minima are connected components of pixels with the same
%   intensity value, t, whose external boundary pixels all have a value
%   greater than t.
%
%   By default, IMHMIN uses 8-connected neighborhoods for 2-D images and
%   26-connected neighborhoods for 3-D images.  For higher dimensions,
%   IMHMIN uses CONNDEF(NDIMS(I),'maximal').
%
%   I2 = IMHMIN(I,H,CONN) computes the H-minima transform, where CONN
%   specifies the connectivity.  CONN may have the following scalar
%   values:
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
%   I can be of any nonsparse numeric class and any dimension.  I2 has
%   the same size and class as I.
%
%   Example
%   -------
%       a = 10*ones(10,10);
%       a(2:4,2:4) = 7;  % minima 3 lower than surround
%       a(6:8,6:8) = 2;  % minima 8 lower than surround
%       b = imhmin(a,4); % only the deeper minima survive
%
%   See also CONNDEF, IMEXTENDEDMIN, IMHMAX, IMRECONSTRUCT,
%   IMREGIONALMIN.

%   Copyright 1993-2012 The MathWorks, Inc.

% Testing notes
% -------------
% I       - N-D, real, full
%         - empty ok
%         - Inf ok
%         - NaNs not allowed
%         - logical flag ignored if present
%
% h       - Numeric scalar; nonnegative; real
%         - Inf ok (doesn't make much sense, though)
%         - NaNs not allowed
%
% conn    - valid connectivity specifier
%
% I2      - same class and size as I

validateattributes(I, {'numeric'}, {'real' 'nonsparse'},...
    'imhmin', 'I', 1);
validateattributes(H, {'numeric'}, {'real' 'scalar' 'nonnegative'}, ...
    'imhmin', 'H', 2);

I  = imcomplement(I);
I  = imhmax(I, H, varargin{:});
I  = imcomplement(I);
