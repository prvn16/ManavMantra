function paramVal = getsettingval(h, param)
%GETSETTINGVAL   get the parameter values of the selected subsysnode.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.

[dSys, ~] = getdominantsystem(h, param);
paramVal = get_param(dSys.getFullName, param);

% [EOF]
