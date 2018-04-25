function this = AbstractBAETreeNode %#ok
%ABSTRACTBAETREENODE Abstract constructor produces an error
%   OUT = ABSTRACTBAETREENODE(ARGS) <long description>

%   Copyright 2011 The MathWorks, Inc.


[msg, id] = fxptui.message('errorAbstractClass', 'ABSTRACTBAETREENODE');
error(id, msg);


% [EOF]
