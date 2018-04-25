function newFcn = odefcncleanup(FcnHandleUsed,oldFcn,inputArgs)
% This helper function incorporates any input arguments for an ode function 
% and creates a function handle from char inputs

%   Copyright 2017 The MathWorks, Inc.

if FcnHandleUsed
    if isempty(inputArgs)
        newFcn = oldFcn;
    else
        newFcn = @(t,y) oldFcn(t,y,inputArgs{:});
    end
else
    % Turn oldFcn string into function handle to avoid fevals
    [~,oldFcnFun] = evalc(['@' oldFcn]);
    if isempty(inputArgs)
        newFcn = @(t,y) oldFcnFun(t,y);
    else
        newFcn = @(t,y) oldFcnFun(t,y,inputArgs{:});
    end
end
