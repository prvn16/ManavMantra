function tf = isPartitionIndependent(varargin)
%ISPARTITIONINDEPENDENT Check if the data underlying one or more tall arrays
% is independent of the partitioning used.
%
% TF = ISPARTITIONINDEPENDENT(X1,X2,..) returns true if and only if the
% underlying data of all of X1,X2,.. is independent of partitioning.

%   Copyright 2017 The MathWorks, Inc.

tf = true;
for ii = 1 : numel(varargin)
    if istall(varargin{ii})
        tf = tf && isPartitionIndependent(hGetValueImpl(varargin{ii}));
    end
end
end
