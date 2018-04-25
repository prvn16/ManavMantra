function bw = imregionalmin(I, varargin) %#codegen
%IMREGIONALMIN Regional minima.
%   BW = IMREGIONALMIN(I) computes the regional minima of I.  The output
%   binary image BW has value 1 corresponding to the pixels of I that belong
%   to regional minima and 0 otherwise.  BW is the same size as I.
%
%   Regional minima are connected components of pixels with the same
%   intensity value, t, whose external boundary pixels all have a value
%   greater than t.
%
%   By default, IMREGIONALMIN uses 8-connected neighborhoods for 2-D
%   images and 26-connected neighborhoods for 3-D images.  For higher
%   dimensions, IMREGIONALMIN uses CONNDEF(NDIMS(I),'maximal').
%
%   BW = IMREGIONALMIN(I,CONN) computes the regional minima of I using
%   the specified connectivity.  CONN may have the following scalar
%   values:
%
%   BW = IMREGIONALMIN(I,CONN) computes the regional minima using the
%   specified connectivity.  CONN may have the following scalar values:
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
%   I can be of any nonsparse numeric class and any dimension.  BW is
%   always logical.
%
%   Example
%   -------
%       A = 10*ones(10,10);
%       A(2:4,2:4) = 3;       % minima 3 lower than surround
%       A(6:8,6:8) = 8        % minima 8 lower than surround
%       regmin = imregionalmin(A)
%
%   See also CONNDEF, IMEXTENDEDMIN, IMHMIN, IMIMPOSEMIN, IMRECONSTRUCT,
%   IMREGIONALMAX.

%   Copyright 1993-2012 The MathWorks, Inc.

% Input and output specs
% ----------------------
% I:     N-D, full, real matrix
%        uint8, uint16, or double
%        logical ok, but ignored
%        Empty ok
%        Infs ok
%        NaNs not allowed.
% 
% CONN:  connectivity
% 
% BW:    logical uint8, same size as I
%        contains only 0s and 1s.

validateattributes(I,...
    {'numeric' 'logical'},...
    {'real' 'nonsparse' 'nonnan'}, ...
    'imregionalmin', 'I', 1);

% Pass +I to imcomplement instead of I to strip off the logical flag.
% We want imregionalmin to ignore the logical flag of I, but imcomplement
% doesn't ignore it.
bw = imregionalmax(imcomplement(+I),varargin{:});
