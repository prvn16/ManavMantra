function bw = imregionalmin(I, varargin) 
%IMREGIONALMIN Regional minima.
%   BW = IMREGIONALMIN(I) computes the regional minima of gpuArray I.  The
%   output binary gpuArray image BW has value 1 corresponding to the pixels
%   of I that belong to regional minima and 0 otherwise.  BW is the same
%   size as I.
%
%   Regional minima are connected components of pixels with the same
%   intensity value, t, whose external boundary pixels all have a value
%   greater than t.
%
%   By default, IMREGIONALMIN uses 8-connected neighborhoods.
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
%
%   Class support
%   -------------
%   I can be a gpuArray of any numeric class (excluding uint64 or
%   int64). BW is a gpuArray with underlying class of logical.
%
%   Example
%   -------
%       A = 10*ones(10,10);
%       A(2:4,2:4) = 3;       % minima 3 lower than surround
%       A(6:8,6:8) = 8        % minima 8 lower than surround
%       regmin = imregionalmin(A)
%
%   See also GPUARRAY/IMRECONSTRUCT, GPUARRAY/IMREGIONALMAX.

%   Copyright 2014 The MathWorks, Inc.

bw = imregionalmax(imcomplement(I),varargin{:});
