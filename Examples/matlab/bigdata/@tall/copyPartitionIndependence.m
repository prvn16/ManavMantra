function varargout = copyPartitionIndependence(varargin)
%COPYPARTITIONINDEPENDENCE Copy the partition independent flag from one
% tall array to another.
%
% [X1,X2,..,XN] = MARKPARTITIONINDEPENDENT(X1,X2,..,XN,Y) copies the
% partition independent flag from Y to all of X1,X2,..,XN.
%
% This is a convenience function around:
%
%  if isPartitionIndependent(Y)
%      [X1,X2,..,XN] = markPartitionIndependent(X1,X2,..,XN);
%  end

%   Copyright 2017 The MathWorks, Inc.

assert(nargout == nargin - 1, ...
    'Assertion failed: copyPartitionIndependence must capture all modified data arguments');

reference = varargin{end};
varargout = varargin(1 : end - 1);
if isPartitionIndependent(reference)
    [varargout{:}] = markPartitionIndependent(varargout{:});
end
end
