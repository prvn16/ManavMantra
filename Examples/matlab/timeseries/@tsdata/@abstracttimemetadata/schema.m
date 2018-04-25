function schema
%SCHEMA Defines properties for various @timemetadata sub-classes (data set
%variable). 

%   Copyright 2005-2008 The MathWorks, Inc.

% This abstract parent class implements (1) the timemerge method for
% converting time vectors onto a common basis, (2) the timeunits enumerated
% strings, and (3) the basic time vector descriptor properties. The scope of
% this abstract class excludes declaration of the sub-class properties (such
% as Start, End). 
%
% Sub-class properties must be declared separately in each derived class
% because the derived classes, e.g. tsdata.timemetadata,
% Simulink.Timemetdata, Simulink.Framemetadata, access these properties
% differently. 

% Register class
p = findpackage('tsdata');
c = schema.class(p,'abstracttimemetadata');
% Value object
c.Handle = 'off'; 

% Public properties
% R.C. define EnumType for the Unit property based on LEGO suggestions
if isempty(findtype('TimeUnits'))
    schema.EnumType('TimeUnits', {'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'});
end
p = schema.prop(c,'Units','TimeUnits');
p.FactoryValue = 'seconds';
schema.prop(c,'UserData','MATLAB array'); 

