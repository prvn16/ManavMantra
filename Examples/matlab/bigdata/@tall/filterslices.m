function varargout = filterslices(subs, varargin)
%FILTERSLICES Helper that calls the underlying filterslices

%   Copyright 2015-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:numel(varargin)}] = wrapUnderlyingMethod(@filterslices, ...
    {}, subs, varargin{:});

for ii = 1:numel(varargin)
    varargout{ii}.Adaptor = resetTallSize(varargin{ii}.Adaptor);
end
end
