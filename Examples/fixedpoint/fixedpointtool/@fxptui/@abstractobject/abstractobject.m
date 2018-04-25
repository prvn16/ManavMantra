function h = abstractobject
%ABSTRACTOBJECT

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

[msg, id] = fxptui.message('errorAbstractClass', 'ABSTRACTOBJECT');
error(id, msg);

% [EOF]
