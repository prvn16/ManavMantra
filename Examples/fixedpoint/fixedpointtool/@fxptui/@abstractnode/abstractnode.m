function h = abstractnode
%NODE 
%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

[msg, id] = fxptui.message('errorAbstractClass', 'ABSTRACTNODE');
error(id, msg);

% [EOF]
