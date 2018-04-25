function BW = imregionalmax(varargin)
%IMREGIONALMAX Regional maxima.
%   BW = IMREGIONALMAX(I) computes the regional maxima of 2D gpuArray I.
%   IMREGIONALMAX returns a binary gpuArray image, BW, the same size as I,
%   that identifies the locations of the regional maxima in I.  In BW,
%   pixels that are set to 1 identify regional maxima; all other pixels are
%   set to 0.
%
%   Regional maxima are connected components of pixels with the same
%   intensity value, t, whose external boundary pixels all have a value
%   less than t.
%
%   By default, IMREGIONALMAX uses 8-connected neighborhoods.
%
%   BW = IMREGIONALMAX(I,CONN) computes the regional maxima of I using
%   the specified connectivity.  CONN may have the following scalar
%   values:
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
%       A = 10*gpuArray.ones(10,10);
%       A(2:4,2:4) = 22;    % maxima 12 higher than surrounding pixels
%       A(6:8,6:8) = 33;    % maxima 23 higher than surrounding pixels
%       A(2,7) = 44;
%       A(3,8) = 45;
%       A(4,9) = 44
%       regmax = imregionalmax(A)
%
%   See also GPUARRAY/IMRECONSTRUCT, GPUARRAY/IMREGIONALMIN

%   Copyright 2014-2016 The MathWorks, Inc.

narginchk(1,2);
hValidateAttributes(varargin{1},...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','2d', 'nonnan','nonsparse'},...
    mfilename,'I',1);

I = varargin{1};

if nargin>1
    conn  = double(gather(varargin{2}));
    if(isequal(conn,conndef(2,'min')))
        conn = 4;
    elseif(isequal(conn,conndef(2,'max')))
        conn = 8;
    end
    if(~isscalar(conn) || (conn~=4 && conn~=8))
        error(message('images:validate:unsupportedConnForGPU'));
    end
else
    % Default to maximal 2D connectivity
    conn  = 8;
end

if(isempty(I))
    BW = gpuArray(logical([]));
else
    BW = images.internal.gpu.imregionalmax(I,conn);
end
