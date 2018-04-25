function B = medfilt3(varargin)
%MEDFILT3 3-D median filtering
%
%   B = MEDFILT3(A) filters 3-D image A with a 3-by-3-by-3 median filter.
%
%   B = MEDFILT3(A,[M N P]) performs median filtering of the 3-D image A
%   in three dimensions. Each output voxel in B contains the median value
%   in the M-by-N-by-P neighborhood around the corresponding voxel in A.
%   M, N and P must be odd integers. The default neighborhood size is
%   [3 3 3]. A is padded by mirroring border elements.
%
%   B = MEDFILT3(...,PADOPT) controls how the array boundaries are padded.
%   Possible values of PADOPT are:
%
%       'symmetric': Pad array with mirror reflections of itself (default)
%       'replicate': Pad array by repeating border elements
%       'zeros'    : Pad array with 0s
%
%   Class Support
%   -------------
%   A must be a real, non-sparse 3-D array of class logical or numeric.
%   B is of the same class and has the same size as A. The neighborhood
%   size [M N P] must be a vector of positive, integral, odd, numeric
%   values.
%
%   Notes
%   -----
%   If the input image A is of integer class, all of the output values are
%   returned as integers.
%
%   Example
%   -------
%   Use median filtering to remove outliers in 3-D data
%
%     % Create a noisy 3-D surface
%     [x,y,z,V] = flow(50);
%     noisyV = V + 0.1*double(rand(size(V))>0.95) - 0.1*double(rand(size(V))<0.05);
%     
%     % Apply median filtering
%     filteredV = medfilt3(noisyV);
%     
%     % Display the noisy and filtered surfaces together
%     subplot(1,2,1)
%     hpatch1 = patch(isosurface(x,y,z,noisyV,0));
%     isonormals(x,y,z,noisyV,hpatch1)
%     set(hpatch1,'FaceColor','red','EdgeColor','none')
%     daspect([1,4,4])
%     view([-65,20])
%     axis tight off
%     camlight left
%     lighting phong
%
%     subplot(1,2,2)
%     hpatch2 = patch(isosurface(x,y,z,filteredV,0));
%     isonormals(x,y,z,filteredV,hpatch2)
%     set(hpatch2,'FaceColor','red','EdgeColor','none')
%     daspect([1,4,4])
%     view([-65,20])
%     axis tight off
%     camlight left
%     lighting phong
%
%   See also MEDFILT2.

%   Copyright 2016-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);

[A, filterSize, padopt] = parse_inputs(args{:});

if isempty(A)
    B = A;
    return
end

padMap = containers.Map( ...
    {'zeros', 'indexed', 'replicate', 'symmetric'}, ...
    {0, 1, 2, 3});

radius = (filterSize - 1) / 2;

if ismatrix(A)
    B = medfilt2(A, filterSize(1:2), padopt);
else
    is_k_unit = all(filterSize == [3 3 3]);
    use_cst_algorithm = ~is_k_unit && (isa(A, 'uint8') || isa(A, 'int8') || isa(A, 'logical'));
    B = medianfilter3dmex(A, radius, padMap(padopt), use_cst_algorithm);
end

% -------------------------------------------------------------------------
function [A, filterSize, padopt] = parse_inputs(varargin)

% Any syntax in which 'indexed' is followed by other arguments is discouraged.
%
% We have to catch and parse this successfully, so we're going to use a strategy
% that's a little different that usual.
%
% First, scan the input argument list for strings.  The
% string 'indexed', 'zeros', or 'symmetric' can appear basically
% anywhere after the first argument.
%
% Second, delete the strings from the argument list.
%
% The remaining argument list can be one of the following:
% MEDFILT3(A)
% MEDFILT3(A,[M N O])

narginchk(1,3);

A = varargin{1};
% validate that the input is a 2D-3D, real, numeric or logical matrix.
validateattributes(A, ...
    {'numeric','logical'}, ...
    {'3d','real','nonsparse'}, ...
    mfilename, 'A', 1);

% default values
padopt = 'symmetric';
filterSize = [3 3 3];

for k = 2:numel(varargin)
    if ischar(varargin{k})
        validStrings = {'replicate','symmetric','zeros'};
        padopt = validatestring(varargin{k}, ...
            validStrings, ...
            mfilename, ...
            'padopt');
    else
        filterSize = varargin{k};
        validateattributes(filterSize, ...
            {'numeric'}, ...
            {'real','positive','odd','integer','vector','numel',3}, ...
            mfilename, ...
            '[m n p]');
        % make it a row vector of type double
        filterSize = reshape(double(filterSize), [1,numel(filterSize)]);
    end
end
