function  varargout = checkeventname(h, eventname)

% Helper function to validate event name
% Copyright 1984-2003 The MathWorks, Inc.

nout = 2;
varargout{1} = 0;
[m,n] = size(h.classhandle.Events);

if (isnumeric(eventname))
    eventname = num2str(eventname);
else if (~ischar(eventname)) %input is eventID
     %could not find event
    varargout{1} = 0;
    varargout{2} = '';   
    return;
    end
end

eventfound = 0;

for i=1:m
    event = h.classhandle.Event(i).Name;
   %eventdesc is eventID
    eventdesc = h.classhandle.Event(i).EventDataDescription;
    
    if strcmpi(eventname, event)
        varargout{1} = 1;
        varargout{2} = eventname;
        eventfound = 1;
        break;
    end    
    
    %input could be eventID
    if strcmpi(eventname, eventdesc)
        varargout{1} = 1;
        varargout{2} = event;
        eventfound = 1;
        break;
    end
end

if ~eventfound
    %could not find event
    varargout{1} = 0;
    varargout{2} = '';   
end
