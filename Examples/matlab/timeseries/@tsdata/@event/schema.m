function schema
%SCHEMA Defines properties for the @event class.

%   Author(s): James G. Owen
%   Copyright 1986-2014 The MathWorks, Inc.
 
% Register class 
p = findpackage('tsdata');
c = schema.class(p,'event');

% Value object
c.Handle = 'off';

% Public properties

% User-assigned detailed information for this event
schema.prop(c,'EventData','MATLAB array');

% User-assigned the name of events. Note: events with the same “name” can
% occur many times 
schema.prop(c,'Name','ustring');

% "Time defines" the position of the event in time relative
% to the "StartDate" (if defined) and expressed in the units specified in
% the "Units" property.  
schema.prop(c,'Time','double');
schema.prop(c,'Units','string'); %#OK_UDDSTRING
schema.prop(c,'StartDate','ustring');

