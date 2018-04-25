function varargout = bwdist(varargin)
%BWDIST Distance transform of binary image.
%   D = BWDIST(BW) computes the Euclidean distance transform of the binary
%   gpuArray image BW. For each pixel in BW, the distance transform assigns
%   a number that is the distance between that pixel and the nearest
%   nonzero pixel of BW. D is a gpuArray with the same size as BW and of
%   underlying class single.
%
%   [D,IDX] = BWDIST(BW) also computes the closest-pixel map in the form of
%   an index array, IDX. (The closest-pixel map is also called the feature
%   map, feature transform, or nearest-neighbor transform.) Each element of
%   IDX contains the linear index of the nearest nonzero pixel of BW. IDX
%   has the same size as BW and is of underlying class uint32.
%
%   Notes
%   -----
%   1. The GPU implementation of this function only supports the Euclidean
%      distance metric.
%   2. The GPU implementation only supports 2-D gpuArray images. Only
%      images with less than 2^32-1 elements are supported.
%
%   Class support
%   -------------
%   BW can be a 2-D gpuArray of type uint8, uint16, uint32, int8, int16, 
%   int32, single, double or logical. D is a gpuArray with the same size as
%   BW and underlying class single. IDX is a gpuArray with the same size as
%   BW and underlying class uint32.
%
%   Examples
%   --------
%   Here is a simple example of the Euclidean distance transform:
%
%       bw = gpuArray.zeros(5,5); bw(2,2) = 1; bw(4,4) = 1;
%       [D,IDX] = bwdist(bw)
%
%   See also BWDIST, BWULTERODE, WATERSHED.

%   Copyright 2013-2017 The MathWorks, Inc.

%   [D,IDX] = BWDIST(BW,METHOD) lets you compute the distance transform
%   using the distance metric specified in METHOD.  METHOD can only be
%   'euclidean' on the GPU.

args = matlab.images.internal.stringToChar(varargin);
switch nargout
    case {0,1}
        varargout{1} = images.internal.gpu.bwdist(args{:});
    case 2
        [varargout{1},varargout{2}] = images.internal.gpu.bwdist(args{:});
    otherwise
        error(message('images:bwdistgpu:tooManyOutputs'));
end
