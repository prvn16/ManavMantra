function unregisterevent(h, userInput)
%UNREGISTEREVENT Unregister event handler for a specified COM object event at runtime.
%   UNREGISTEREVENT(H, USERINPUT) unregisters events, where H is
%   the handle to the COM control and USERINPUT is either a
%   char array or a cell array of strings.
%
%   When USERINPUT is a char array all events are removed from the
%    specified file.
%      unregisterevent(h, 'sampev')
%        - Removes all events of h from sampev.m file
%
%   When USERINPUT is a cell array of strings, it must contain valid 
%   event names and eventhandlers that are to be unregistered. For example,
%
%      unregisterevent(h, {'Click' 'sampev'; 'dblclick' 'sampev'})
%   
%   See also REGISTEREVENT, EVENTLISTENERS.

% Copyright 1984-2008 The MathWorks, Inc.

% first check number of arguments
narginchk(2,2);

if ~ (iscom(h) || isinterface(h))
    error(message('MATLAB:COM:invalidinputhandle'));
end

if (iscell(userInput))
    [m,n] = size(userInput);
    for i=1:m
        eventname =userInput{i, 1};
        eventhandler = userInput{i, 2};
        errstatus = removeevent(h, eventname, eventhandler);
        
        if (errstatus == 1)
            warning('MATLAB:unregisterevent:InvalidEvent', '%s', ...
                    getString(message('MATLAB:unregisterevent:InvalidEvent2',eventname)));
        end
    end
elseif (ischar(userInput) || isa(userInput, 'function_handle'))
    if (isempty(userInput))
        error('MATLAB:COM:invalideventhandler', '%s', getString(message('MATLAB:COM:invalideventhandlerEmpty')));
    end

    errstatus = 0;
    [m,n] = size(h.classhandle.Events);
    for i=1:m
        eventname = h.classhandle.Event(i).Name;
        stat = removeevent(h, eventname, userInput);
        
        if(stat == 1)
            errstatus = errstatus + 1;
        end
    end
    
    if (errstatus == m)
        error(message('MATLAB:unregisterevent:InvalidEvent'));
    end
        
else
    error(message('MATLAB:COM:invalideventhandler'));
end    


