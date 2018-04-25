function varargout = reducebykeyfun(opts, reduceFcn, varargin)
%REDUCEBYKEYFUN Helper that calls the underlying reducebykeyfun
%
%   REDUCEBYKEYFUN(reduceFcn, key, arg1, ...)
%   REDUCEBYKEYFUN(opts, reduceFcn, key, arg1, ...)

%   Copyright 2015-2017 The MathWorks, Inc.

% Strip out opts and fcn
[opts, reduceFcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, reduceFcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@reducebykeyfun, opts, {reduceFcn}, varargin{:});

% The output keys (varargout{1}) always have the same type and small size as
% the input keys (varargin{1}).
if nargout
    varargout{1}.Adaptor = resetTallSize(varargin{1}.Adaptor);
end

end
