function im = imreconstruct(varargin)
%IMRECONSTRUCT Morphological reconstruction.
%   IM = IMRECONSTRUCT(MARKER,MASK) performs morphological reconstruction
%   of the 2D gpuArray image MARKER under the 2D gpuArray image MASK.
%   MARKER and MASK can be two intensity images or two binary images with
%   the same size; IM is an intensity or binary image, respectively.
%   MARKER must be the same size as MASK, and its elements must be less
%   than or equal to the corresponding elements of MASK. Values greater
%   than corresponding elements in MASK will be clipped to the MASK level.
%
%   By default, IMRECONSTRUCT uses 8-connected neighborhoods.
%
%   IM = IMRECONSTRUCT(MARKER,MASK,CONN) performs morphological
%   reconstruction with the specified connectivity.  CONN may have the
%   following scalar values:
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%
%   Class support
%   -------------
%   MARKER and MASK must be nonsparse numeric (excluding uint64 or int64)
%   or logical arrays with the same underlying class and any dimension.  IM
%   is of the same class as MARKER and MASK.
%
%   Example 1
%   ---------
%   Segment the letter "w" from text.png.
%
%       mask          = gpuArray(imread('text.png'));
%       marker        = gpuArray.false(size(mask));
%       marker(13,94) = true;
%       im            = imreconstruct(marker,mask);
%       figure, imshow(mask), figure, imshow(im)
%
%   See also IMCLEARBORDER, IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX,
%            IMHMIN, IMIMPOSEMIN.

%   Copyright 2013-2016 The MathWorks, Inc.

narginchk(2,3);
marker = varargin{1};
mask   = varargin{2};

% CPU dispatch if needed
if(~isa(marker,'gpuArray') && ~isa(mask,'gpuArray'))
    % Three input argument with conn on the GPU.
    conn = gather(varargin{3});
    % Call CPU code path
    im   = imreconstruct(marker, mask, conn);
    return;
end

marker = gpuArray(varargin{1});
mask   = gpuArray(varargin{2});

%% Validation
hValidateAttributes(marker,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','2d', 'nonnan','nonsparse'},mfilename,'MARKER',1);
hValidateAttributes(mask,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','2d','nonnan','nonsparse'},mfilename,'MASK',2);

% marker and mask must be of the same numeric class
if(~strcmp(classUnderlying(marker), classUnderlying(mask)))
    error(message('images:imreconstruct:notSameClass'));
end
% marker and mask must have the same size
if(~isequal(size(marker), size(mask)))
    error(message('images:imreconstruct:notSameSize'));
end

%% Handle empty
if(isempty(marker))
    im = marker;
    return;
end

%% Preprocess conn
if nargin==3
    conn  = double(gather(varargin{3}));
    if(isequal(conn,conndef(2,'min')))
        conn = 4;
    elseif(isequal(conn,conndef(2,'max')))
        conn = 8;
    end
    if(~isscalar(conn) || (conn~=4 && conn~=8))
        error(message('images:imreconstruct:unSupportedConnForGPU'));
    end
else
    % Default to maximal 2D connectivity
    conn  = 8;
end


%% Dispatch to builtin
im = images.internal.gpu.imreconstruct(marker, mask, conn);
