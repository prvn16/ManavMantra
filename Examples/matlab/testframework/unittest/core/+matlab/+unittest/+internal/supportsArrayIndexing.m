function bool = supportsArrayIndexing(value)
% This function is undocumented.

%  Copyright 2015 The MathWorks, Inc.

if isa(value,'function_handle')
    bool = false;
elseif ~isobject(value) && ~isa(value,'handle.handle')
    bool = true;
else
    mc = metaclass(value);
    if ~isempty(mc)
        actualMethods = {mc.MethodList.Name};
    else %UDD/OOPS
        actualMethods = methods(value);
    end
    bool = isempty(actualMethods) || ~ismember('subsref',actualMethods);
end
end