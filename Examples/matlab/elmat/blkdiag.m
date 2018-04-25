function y = blkdiag(varargin)
%BLKDIAG  Block diagonal concatenation of matrix input arguments.
%
%                                   |A 0 .. 0|
%   Y = BLKDIAG(A,B,...)  produces  |0 B .. 0|
%                                   |0 0 ..  |
%
%   Class support for inputs:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      char, logical
%
%   See also DIAG, HORZCAT, VERTCAT

% Copyright 1984-2013 The MathWorks, Inc.

if nargin > 0
    outclass = class(varargin{1});
    if isobject(varargin{1}) || ~isnumeric(varargin{1}) || ...
            any(~cellfun('isclass',varargin,outclass))
        y = [];
        for k=1:nargin
            x = varargin{k};
            [p1,m1] = size(y); 
            [p2,m2] = size(x);
            y = [y zeros(p1,m2); zeros(p2,m1) x]; %#ok
        end
        return
    end
else
   outclass = 'double';  
end

if any(cellfun(@issparse,varargin));
    % optimized MEX implementation for sparse double
    y = blkdiagmex(varargin{:});
else
    [p2,m2] = cellfun(@size,varargin);
    %Precompute cumulative matrix sizes
    p1 = [0, cumsum(p2)];
    m1 = [0, cumsum(m2)];
    
    y = zeros(p1(end),m1(end),outclass); %Preallocate
    for k=1:nargin
        y(p1(k)+1:p1(k+1),m1(k)+1:m1(k+1)) = varargin{k};
    end
end
