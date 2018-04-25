function registerevent(h, userInput)
%REGISTEREVENT Registers event handler for a specified COM object event at runtime.
%   REGISTEREVENT(H, USERINPUT) registers events, where H is
%   the handle to the COM object and USERINPUT is either a
%   1xn char array or an mx2 cell array of strings. 
%
%   When USERINPUT is a char array it specifies the event handler
%   for all events that can be registered by the COM object. For example,
%
%      registerevent(h, 'allevents')
%
%   When USERINPUT is a cell array of strings, an event name 
%   and event handler pair specify the event to be registered. 
%   For example, 
%
%      registerevent(h, {'Click' 'sampev'; 'Mousedown' 'sampev'})
%   
%   See also UNREGISTEREVENT, EVENTLISTENERS, ACTXCONTROL, ACTXSERVER.

% Copyright 1984-2008 The MathWorks, Inc.


% first check number of arguments
narginchk(2,inf)

if ~ (iscom(h) || isinterface(h))
    error(message('MATLAB:registerevent:invalidinputhandle'));
end

n = numel(h);
if (n > 1)
    error(message('MATLAB:registerevent:invalidinputhandle'));
end 

%check to see if input is in cell array form
if (iscell(userInput))
    count = numel(userInput);
    
    if (rem(count,2) ~= 0)
        error(message('MATLAB:registerevent:InvalidNumEventArgs'));
    end
        
    [m,n] = size(userInput);
    
    if(m ~= 1) && (n ~= 2)
       error('MATLAB:registerevent:InvalidNumEventArgs','%s', ...
             getString(message('MATLAB:registerevent:InvalidNumEventArgsSize')));
    end
    
    if (m == 1) && (n ~= 2)
        m = count/2;
        n = 2;
        userInput = reshape(userInput,n,m)'; 
    end
    
    eventexist = cell(m, 1);
    newevent = cell(m, 1);
            
    for i=1:m
        event = userInput{i,1};
           
         %check to see if event name is valid
        [eventexist{i}, newevent{i}] = checkeventname(h, event);
        
        if (eventexist{i} ~= 1)
            
            if(~ischar(event) && ~isnumeric(event))
                error(message('MATLAB:registerevent:InvalidEventname'));
            else
                error('MATLAB:registerevent:InvalidEventname','%s', ...
                      getString(message('MATLAB:registerevent:InvalidEventname2',event)));
            end
        end   
    end  
    
    % no error proceed with registering
    for i=1:m
        %we need to get eventname because input event ids are converted
        %here
        event = newevent{i};
        eventhandler = userInput{i,2};
        
    
        if (isempty(eventhandler))
            warning(message('MATLAB:registerevent:EmptyEventHandler'));
            continue;
        elseif (~ischar(eventhandler) && ~isa(eventhandler, 'function_handle'))
            warning(message('MATLAB:registerevent:InvalidEventHandler'));    
            continue;
        end
    
        %add event to the list
        addevent(h, event, eventhandler);            
    end    
else
    if (isempty(userInput))
        error(message('MATLAB:registerevent:EmptyEventHandler'));
    elseif (~ischar(userInput) && ~isa(userInput, 'function_handle'))
        error(message('MATLAB:registerevent:InvalidEventHandler'));    
    end
         
    %register all events to userinput
    [m,n] = size(h.classhandle.Events);
     
    for i=1:m
        event = h.classhandle.Event(i).Name;
        addevent(h, event, userInput);
    end  
end    

function addevent(h, eventname, eventhandler)

%find out if the property is already created for events
p= h.findprop('MMListeners_Events');

if (isempty(p))
    p=schema.prop(h, 'MMListeners_Events', 'handle vector');
end

%turn the property on so that we can set and get
p.AccessFlags.Publicget = 'on';
p.AccessFlags.Publicset = 'on';

[m,n] = size(h.MMListeners_Events);

%we need to get the list from listener if it already exists
if(m > 0)
    list = h.MMListeners_Events;

    [row, col] = size(list);

    for i=1:row
        tempevent = list(i).EventType;
        tempcallback = list(i).Callback(2);

        if (strcmpi(eventname, tempevent))
            if (isa(eventhandler, 'function_handle') && isequal(eventhandler, tempcallback{1})) || ...
                    (ischar(eventhandler) && strcmpi(eventhandler, tempcallback))

                return;
            end
        end
    end
end

%new event/handler pair, so add it to the list
list(m+1) = handle.listener(h, eventname, {@comeventcallback, eventhandler});
set(h, 'MMListeners_Events', list);

%hide the event listener property from the user
p.AccessFlags.Publicget = 'off';
p.AccessFlags.Publicset = 'off';
p.AccessFlags.Serialize = 'off';


    
