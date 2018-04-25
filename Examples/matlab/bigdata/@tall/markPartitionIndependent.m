function varargout = markPartitionIndependent(varargin)
%MARKPARTITIONINDEPENDENT Mark that the data underlying the tall array is
% independent of the partitioning of the tall array.
%
% [X1,X2,..] = MARKPARTITIONINDEPENDENT(X1,X2,..) marks each of X1, X2, ...
% as well defined in the presence of changes to the underlying partitioning.
% This must be used if an algorithm wishes to use the advanced primitive
% partitionfun or generalpartitionfun.
%

%   Copyright 2017 The MathWorks, Inc.

assert(nargin == nargout, ...
    'Assertion failed: All outputs of markPartitionIndependent must be captured.');

for ii = 1 : numel(varargin)
    if istall(varargin{ii})
        varargin{ii} = tall(...
            markPartitionIndependent(hGetValueImpl(varargin{ii})), ...
            varargin{ii}.Adaptor);
    end
end
varargout = varargin;
end
