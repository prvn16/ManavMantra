function varargout = max(varargin)
%MAX Largest component
%   Y = max(A)
%   Y = max(A,[],DIM)
%   Y = max(A,B)
%   Y = max(...,NANFLAG)

%   Copyright 2015 The MathWorks, Inc.

try
    [varargout{1:max(nargout,1)}] = minmaxop(@max, varargin{:});
catch E
    throw(E);
end
end
