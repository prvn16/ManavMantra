function schema
%SCHEMA  Define properties for @tsHandleWrapper class.

%   Copyright 2004-2014 The MathWorks, Inc.

c = schema.class(findpackage('tsdata'),'timeseries');

% Public properties
p = schema.prop(c, 'tsValue', 'MATLAB array');
p.AccessFlags.AbortSet = 'off'; % Work around g311250 
p.AccessFlags.Init = 'off';
p = schema.prop(c, 'UserData', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'UserData');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'UserData');

%% Flag to control the triggering of datachange event
p = schema.prop(c, 'DataChangeEventsEnabled', 'bool');
p.FactoryValue = true;
p = schema.prop(c, 'Name', 'ustring');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'Name');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'Name');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
schema.prop(c, 'Version', 'double');
p = schema.prop(c, 'Data', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'Data');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'Data');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'DataInfo', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'DataInfo');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'DataInfo');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'Time', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'Time');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'Time');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'TimeInfo', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'TimeInfo');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'TimeInfo');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'Quality', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'Quality');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'Quality');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'QualityInfo', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'QualityInfo');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'QualityInfo');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'IsTimeFirst', 'bool');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'IsTimeFirst');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'IsTimeFirst');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'Events', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'Events');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'Events');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'TreatNaNasMissing', 'bool');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'TreatNaNasMissing');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'TreatNaNasMissing');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'Length', 'MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'Length');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'Length');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
% define events
schema.event(c,'datachange'); 

% Numeric operations on numbers
m = schema.method(c, 'mtimes');
m.FirstArgDispatch = 'off';
m = schema.method(c, 'ldivide');
m.FirstArgDispatch = 'off';
m = schema.method(c, 'minus');
m.FirstArgDispatch = 'off';
m = schema.method(c, 'mldivide');
m.FirstArgDispatch = 'off';
m = schema.method(c, 'mrdivide');
m.FirstArgDispatch = 'off';
m = schema.method(c, 'plus');
m.FirstArgDispatch = 'off';
m = schema.method(c, 'rdivide');
m.FirstArgDispatch = 'off';
m = schema.method(c, 'times');
m.FirstArgDispatch = 'off';


