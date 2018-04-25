function [dSys, dParam] = getdominantsystem(h, param)
%GETDOMINANTSYSTEM   get the dominant system for H.

%   Author(s): G. Taillefer
%   Copyright 2006-2011 The MathWorks, Inc.

dSys = [];
dParam = '';
if(~isa(h, 'DAStudio.Object'))
	return;
end


%throw an error if an invalid param is passed in
%report output args with the current system and param value
dSys = get_param(h.daobject.ModelName, 'Object');
dParam = dSys.(param);

% [EOF]
