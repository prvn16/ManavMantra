function hPropDb = getPropertySet
%GETPROPERTYDB Get the propertySet.

% Copyright 2015 The MathWorks, Inc.

% Add properties for the zoom which are not set from the options dialog.
% These properties are set as the zoom object is used.  We store them in
% the property database so they can be saved in the instrumentation sets.
hPropDb = extmgr.PropertySet('FitToView', 'bool', false, ...
    'Magnification', 'double', 1);

% [EOF]