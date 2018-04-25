function val = getParameterValue(this, param)
% Get the parameter value of the selected subsysnode.

%Copyright 2015 The MathWorks,Inc


val = get_param(this.daobject.getFullName,param);
