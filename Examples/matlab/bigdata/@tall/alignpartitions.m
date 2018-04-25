function [varargout] = alignpartitions(varargin)
%ALIGNPARTITIONS Helper that calls the underlying alignpartitions

%   Copyright 2016-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargin}] = wrapUnderlyingMethod(@alignpartitions, ...
    {}, varargin{:});
for ii = 1:numel(varargin)
    % TODO(g1473104): Need to revisit this once partition sizes are
    % cached. Can we assume the adaptor is exactly the same?
    varargout{ii}.Adaptor = varargin{ii}.Adaptor;
end
end
