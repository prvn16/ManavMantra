function varargout = min(varargin)
%MIN Smallest component
%   Y = min(A)
%   Y = min(A,[],DIM)
%   Y = min(A,B)
%   Y = min(...,NANFLAG)
%
%   See also: MIN, TALL.

%   Copyright 2015 The MathWorks, Inc.

try
    [varargout{1:max(nargout,1)}] = minmaxop(@min, varargin{:});
catch E
    throw(E);
end
end
