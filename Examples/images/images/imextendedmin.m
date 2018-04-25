function BW = imextendedmin(varargin) %#codegen
%IMEXTENDEDMIN Extended-minima transform.
%   BW = IMEXTENDEDMIN(I,H) computes the extended-minima transform, which
%   is the regional minima of the H-minima transform.  H is a nonnegative
%   scalar.
%
%   Regional minima are connected components of pixels with the same
%   intensity value, t, whose external boundary pixels all have a value
%   greater than t.
%
%   By default, IMEXTENDEDMIN uses 8-connected neighborhoods for 2-D
%   images and 26-connected neighborhoods for 3-D images.  For higher
%   dimensions, IMEXTENDEDMIN uses CONNDEF(NUMEL(SIZE(I)),'maximal').  
%
%   BW = IMEXTENDEDMIN(I,H,CONN) computes the extended-minima transform,
%   where CONN specifies the connectivity.  CONN may have the following
%   scalar values:   
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
%   I can be of any nonsparse numeric class and any dimension.  BW has
%   the same size as I and is always logical.
%
%   Example
%   -------
%       I = imread('glass.png');
%       BW = imextendedmin(I,50);
%       figure, imshow(I), figure, imshow(BW)
%   
%   See also CONNDEF, IMEXTENDEDMAX, IMHMIN, IMRECONSTRUCT,
%   IMREGIONALMIN.

%   Copyright 1993-2013 The MathWorks, Inc.

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

[I,h,conn] = ParseInputs(varargin{:});

BW = imregionalmin(imhmin(I,h,conn),conn);

%%%
%%% ParseInputs
%%%
function [I,h,conn] = ParseInputs(varargin)

narginchk(2,3);

I = varargin{1};
validateattributes(I, {'numeric'}, {'real' 'nonsparse'}, mfilename, 'I', 1);

h = varargin{2};
validateattributes(h, {'numeric'}, {'real' 'scalar' 'nonnegative'}, mfilename, 'H', 2); 
h = double(h);

if nargin < 3
    conn = conndef(numel(size(I)),'maximal');
else
    conn = varargin{3};
    iptcheckconn(conn, mfilename, 'CONN', 3);
end
