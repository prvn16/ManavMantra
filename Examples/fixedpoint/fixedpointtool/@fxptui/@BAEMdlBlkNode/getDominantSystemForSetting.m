function [dSys, dParam] = getDominantSystemForSetting(this, param)
% 

% Copyright 2015 The MathWorks, Inc.

dSys = [];
dParam = '';
if ~this.isValid
    return;
end
dSys = get_param(this.daobject.ModelName,'Object');
dParam = dSys.(param);
end
        