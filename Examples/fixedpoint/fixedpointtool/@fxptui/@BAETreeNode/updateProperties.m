function updateProperties(this, prop, propVal)
%SETPROPERTIES Set the Properties
%   OUT = SETPROPERTIES(ARGS) <long description>

%   Copyright 2010-2012 The MathWorks, Inc.

this.(prop) = propVal;
this.firepropertychange;
% [EOF]

% LocalWords:  fxptui BAE daobject cbo appliesto
