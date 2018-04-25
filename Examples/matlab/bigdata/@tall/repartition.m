function [varargout] = repartition(partitionMetadata, tPartitionIndices, varargin)
%REPARTITION Helper that calls the underlying repartition

%   Copyright 2016-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@repartition, {partitionMetadata}, tPartitionIndices, varargin{:});

% Fix up the adaptor(s)
for ii=1:numel(varargout)
    varargout{ii}.Adaptor = matlab.bigdata.internal.adaptors.getAdaptor(varargin{ii});
end
end
