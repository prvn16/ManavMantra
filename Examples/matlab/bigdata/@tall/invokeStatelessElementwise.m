function varargout = invokeStatelessElementwise(fcnInfo, varargin)
%INVOKESTATELESSELEMENTWISE Invokes error-free stateless elementwise function

%   Copyright 2015-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
stack = createInvokeStack(fcnInfo{1});
markerFrame = matlab.bigdata.internal.InternalStackFrame(stack); %#ok<NASGU>

try
    args = invokeInputCheck(fcnInfo, varargin{:});
    fcn = str2func(fcnInfo{1});
    
    fcn = matlab.bigdata.internal.FunctionHandle(fcn, 'ErrorFree', true);
    [varargout{1:max(1, nargout)}] = elementfun(fcn, args{:});
    varargout = cellfun(@(out) invokeOutputInfo(fcnInfo{2}, out, args), varargout, 'UniformOutput', false);
catch E
    matlab.bigdata.internal.throw(E);
end
end


