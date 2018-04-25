 function val = getParameterValue(this, param)
 %
 
 % Copyright 2015 The MathWorks, Inc
 
 [dSys, ~] = getDominantSystemForSetting(this, param);
 val = get_param(dSys.getFullName, param);
 