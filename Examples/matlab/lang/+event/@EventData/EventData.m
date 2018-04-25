%EVENT.EVENTDATA    Base class for event data 
%    The EVENT.EVENTDATA class is the base class for all data objects 
%    passed to event listeners.  It is used to encapsulate information 
%    about an event which can then be passed to event listeners via  
%    NOTIFY.   
%    
%    Subclass the EVENT.EVENTDATA class if you wish to pass additional
%    information to event listeners.
%
%    EVENT.EVENTDATA defines two read-only properties:
%        EventName - Name of the event described by this object.
%        Source    - The object that defines the event described by this
%                    object.
%
%    %Example: Creating an event data class
%    classdef engineData < event.EventData
%        properties
%            Temperature;
%            OilPressure;
%        end
%        methods
%            function obj = engineData(temp,pressure)
%                obj.Temperature = temp;
%                obj.OilPressure = pressure;
%            end
%        end
%    end
%    
%    See also EVENT.LISTENER, EVENT.PROPERTYEVENT, HANDLE

%   Copyright 2008 The MathWorks, Inc. 
%   Built-in class.