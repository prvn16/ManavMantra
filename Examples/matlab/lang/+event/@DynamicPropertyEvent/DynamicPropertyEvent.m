%event.DynamicPropertyEvent    Event data for dynamic property events
%    The event.DynamicPropertyEvent class defines the data objects passed to
%    listeners of the meta.DynamicProperty events, PropertyAdded and 
%    PropertyRemoved.  
%
%    event.DynamicPropertyEvent is a subclass of event.EventData.  It is a 
%    SEALED class, which means that it cannot be subclassed.  It
%    defines the following read-only properties:
%
%       EventName    - Name of the event described by this object.
%       Source       - The object to which the dynamic property is added
%       PropertyName - Name of the dynamic property added
%
%   event.DynamicPropertyEvent inherits EventName and Source from event.EventData.
%
%   See also event.EventData, event.PropertyEvent, meta.DynamicProperty

%   Copyright 2015 The MathWorks, Inc. 
%   Built-in class.