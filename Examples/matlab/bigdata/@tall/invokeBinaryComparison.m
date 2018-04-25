function out = invokeBinaryComparison(fcnInfo, varargin)
%invokeBinaryComparison Invokes GE, LT etc.

% Copyright 2016-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
stack = createInvokeStack(fcnInfo{1});
markerFrame = matlab.bigdata.internal.InternalStackFrame(stack); %#ok<NASGU>

try
    args = invokeInputCheck(fcnInfo, varargin{:});

    % If any input is datetime, duration, string, or categorical and the
    % other input might be a char array then we must treat the operation as
    % slicewise (each row of the char array counts as one element).
    clzs = cellfun(@tall.getClass, varargin, 'UniformOutput', false);
    mightHaveCharInput = any(cellfun(@isempty, clzs) | strcmp(clzs, "char"));
    treatAsSlicewise = mightHaveCharInput ...
        && any(ismember({'datetime', 'duration', 'string', 'categorical'}, clzs));
    
    primitiveArgs = {str2func(fcnInfo{1}), args{:}}; %#ok<CCAT> not applicable
    
    if treatAsSlicewise
        out = slicefun(primitiveArgs{:});
    else
        out = elementfun(primitiveArgs{:});
    end
    
    out = invokeOutputInfo(fcnInfo{2}, out, args);
catch E
    matlab.bigdata.internal.throw(E);
end
end
