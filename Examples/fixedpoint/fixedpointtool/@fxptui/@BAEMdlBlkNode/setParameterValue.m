function setParameterValue(this, param, paramVal)
%

% Copyright 2015 The MathWorks, Inc.

[dSys, ~] = this.getDominantSystemForSetting(param);
strVal = fxptui.convertEnumToParamValue(param, paramVal);
set_param(dSys.getFullName, param, strVal);
