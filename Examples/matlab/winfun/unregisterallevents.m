function unregisterallevents(h)
%UNREGISTERALLEVENTS Unregister all event handlers for a specified COM object at runtime.
%   UNREGISTERALLEVENTS(H) unregisters all events from a control, where H is
%   the handle to the COM control. 
%
%      unregisterallevents(h)
%   
%   See also REGISTEREVENT, UNREGISTEREVENT, EVENTLISTENERS.

% Copyright 1984-2008 The MathWorks, Inc.

% first check number of arguments
narginchk(1,1);

if ~ (iscom(h) || isinterface(h))
    error(message('MATLAB:COM:invalidinputhandle'));
end

events = eventlisteners(h);

if (isempty(events))
    error(message('MATLAB:COM:noeventstounregister'))
end    

p = findprop(h, 'MMListeners_Events');
if (isempty(p))
    return;
end

[m,n] = size(events);

for i = 1:m
    eventname = events{i, 1};
    eventhandler = events{i, 2};
    removeevent(h, eventname, eventhandler);
end    

