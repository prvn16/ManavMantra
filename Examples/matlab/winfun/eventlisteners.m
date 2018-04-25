function events = eventlisteners(h)
%EVENTLISTENERS Lists all event handler functions registered for a COM object.
%   EVENTLISTENERS(H) Lists all events that are registered, 
%   where H is the handle to the COM control. Result is a cell
%   array of events and its registered eventhandlers.
%
%      eventlisteners(h)
%   
%   See also REGISTEREVENT, UNREGISTEREVENT.

% Copyright 1984-2008 The MathWorks, Inc.

% first check number of arguments
narginchk(1,1);

if ~ (iscom(h) || isinterface(h))
    error(message('MATLAB:eventlisteners:invalidinputhandle'));
end

n = numel(h);
if (n > 1)
    error(message('MATLAB:eventlisteners:invalidinputhandle'));
end 

events = {};
p = findprop(h, 'MMListeners_Events');

if (isempty(p))
    return
end

p.AccessFlags.Publicget = 'on';
        
%dont proceed if no events are registered
 [row,col] = size(h.MMListeners_Events);
 if(row == 0)
    return
 end    

listn = h.MMListeners_Events;

for i=1:row
    events{i, 1} = listn(i).EventType;
    events{i, 2} = listn(i).Callback{2};
end    

p.AccessFlags.Publicget = 'off';
        
