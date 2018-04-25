function hPropDb = getPropertySet
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2008-2016 The MathWorks, Inc.

hPropDb = matlabshared.scopes.visual.Visual.getPropertySet(...
    'AxesProperties','mxArray',[],...
    'ColorMapExpression','string','gray(256)',...
    'UseDataRange','bool',false,...
    'DataRangeMin','double',0,...
    'DataRangeMax','double',255);
    
% hPropDb = uiscopes.AbstractAxesVisual.getPropertyDb;
% hPropDb.add('ColorMapExpression', 'string', 'gray(256)');
% hPropDb.add('UseDataRange', 'bool', false);
% hPropDb.add('DataRangeMin', 'double', 0);
% hPropDb.add('DataRangeMax', 'double', 255);
% 
% hPropDb = convertToNewFormat(hPropDb);

% [EOF]
