function paramVal = getsettingval(h, param)
%GETSETTINGVAL   get the parameter values of the selected subsysnode.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.

paramVal = get_param(h.daobject.getFullName,param);
% [EOF]
