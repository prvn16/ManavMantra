function out = invokeUnaryCast(fcnInfo, in)
%invokeUnaryCast Invokes unary cast methods like DOUBLE, UINT8 etc.

% Copyright 2016-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
stack = createInvokeStack(fcnInfo{1});
markerFrame = matlab.bigdata.internal.InternalStackFrame(stack); %#ok<NASGU>

try
    args = invokeInputCheck(fcnInfo, in);
    fcn = str2func(fcnInfo{1});
    
    % The cast 'logical' can throw errors if the underlying type is double. All
    % others are error free.
    errorFree = ~strcmp(fcnInfo{1}, 'logical');
    
    fcn = matlab.bigdata.internal.FunctionHandle(fcn, 'ErrorFree', errorFree);
    out = elementfun(fcn, args{:});
    out = setKnownType(out, fcnInfo{1});
catch E
    matlab.bigdata.internal.throw(E);
end
end
