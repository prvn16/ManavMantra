function J = imhmax(I, H, varargin) %#codegen
%IMHMAX H-maxima transform.
%   I2 = IMHMAX(I,H) suppresses all maxima in I whose height is less than 
%   H.  I is an intensity image and H is a nonnegative scalar.
%
%   Regional maxima are connected components of pixels with the same
%   intensity value, t, whose external boundary pixels all have a value
%   less than t.
%
%   By default, IMHMAX uses 8-connected neighborhoods for 2-D images and
%   26-connected neighborhoods for 3-D images.  For higher dimensions,
%   IMHMAX uses CONNDEF(NDIMS(I),'maximal').  
%
%   I2 = IMHMAX(I,H,CONN) computes the H-maxima transform, where CONN
%   specifies the connectivity.  CONN may have the following scalar values:
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
%       a = zeros(10,10);
%       a(2:4,2:4) = 3;  % maxima 3 higher than surround
%       a(6:8,6:8) = 8;  % maxima 8 higher than surround
%       b = imhmax(a,4); % only the maxima higher than 4 survive.
%
%   See also CONNDEF, IMEXTENDEDMAX, IMHMIN, IMRECONSTRUCT,
%   IMREGIONALMAX. 

%   Copyright 1993-2015 The MathWorks, Inc.

% Testing notes
% -------------
% I       - N-D, real, full
%         - empty ok
%         - Inf ok
%         - NaNs not allowed
%
% h       - Numeric scalar; nonnegative; real
%         - Inf ok (doesn't make much sense, though)
%         - NaNs not allowed
%
% conn    - valid connectivity specifier

%#ok<*EMCA>

validateattributes(I, {'numeric'}, {'real' 'nonsparse'}, mfilename, 'I', 1); 

validateattributes(H, {'numeric'}, {'real' 'scalar' 'nonnegative'}, ...
              mfilename, 'H', 2);
          
H = double(H);
J = imreconstruct((I-H), I, varargin{:});
