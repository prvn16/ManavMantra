function out = invokeReduceInDim(fcnInfo, varargin)
%INVOKEREDUCEINDIM Invokes reduceInDim

%   Copyright 2015-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
stack = createInvokeStack(fcnInfo{1});
markerFrame = matlab.bigdata.internal.InternalStackFrame(stack); %#ok<NASGU>

try
    % Separate flags from data, then check the type of all data args
    [args, flags] = splitArgsAndFlags(varargin{:});
    args = invokeInputCheck(fcnInfo, args{:});
    % Call the reduction function
    [out, dimUsed] = reduceInDim(str2func(fcnInfo{1}), args{:}, flags{:});
    out = invokeOutputInfo(fcnInfo{2}, out, args);
    % Now try and update the reduced dimension
    allowEmpty = false;
    out.Adaptor = computeReducedSize(out.Adaptor, args{1}.Adaptor, dimUsed, allowEmpty);
catch E
    matlab.bigdata.internal.throw(E);
end
end
