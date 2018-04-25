function [L,numComponents] = bwlabel(varargin)
%BWLABEL Label connected components in 2-D binary image.
%   L = BWLABEL(BW,N) returns a gpuArray L, of the same size as BW,
%   containing labels for the connected components in gpuArray BW. N can
%   have a value of either 4 or 8, where 4 specifies 4-connected objects
%   and 8 specifies 8-connected objects; if the argument is omitted, it
%   defaults to 8.
%
%   The elements of L are integer values greater than or equal to 0.  The
%   pixels labeled 0 are the background.  The pixels labeled 1 make up one
%   object, the pixels labeled 2 make up a second object, and so on.
%
%   [L,NUM] = BWLABEL(BW,N) returns in NUM the number of connected objects
%   found in BW.
%
%   Class Support
%   -------------
%   BW can be real, 2D gpuArray of logical or numeric underlying class. L
%   is a gpuArray of underlying class double.
%
%   Example
%   -------
%       BW = gpuArray(logical([1 1 1 0 0 0 0 0
%                     1 1 1 0 1 1 0 0
%                     1 1 1 0 1 1 0 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 1 1 0
%                     1 1 1 0 0 0 0 0]));
%       L = bwlabel(BW,4)
%       [r,c] = find(L == 2)
%
%   See also BWCONNCOMP,BWLABELN,BWSELECT,LABELMATRIX,LABEL2RGB,REGIONPROPS.

%   Copyright 2013-2016 The MathWorks, Inc.

narginchk(1,2);

% Dispatch to CPU not needed since second input cannot be a gpuArray. Input
% validation done in C++.
switch nargout
    case {0,1}
        L = images.internal.gpu.bwlabel(varargin{:});
    case 2
        [L,numComponents] = images.internal.gpu.bwlabel(varargin{:});
end
end
