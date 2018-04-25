%EVENT.LISTENER    Listener object
%    The EVENT.LISTENER class defines listener objects.  Listener objects
%    listen for a specific event and identify the callback function to 
%    invoke when the event is triggered.
%    
%    el = EVENT.LISTENER(hSource,EventName,@callbackFcn) creates a 
%    listener object for the event named EventName on the specified 
%    object and identifies a function handle to the callback function. 
%    EventName can be a string scalar or character vector.  If hSource is 
%    an array of objects, the listener responds to the named event on any 
%    handle in the array.
%
%    The listener callback function must be defined to accept at least two
%    input arguments, as in: 
%
%        function callbackFcn(hSource, eventData)
%           ...
%        end
%
%    where hSource is the object that is the source of the event and
%    eventData is an event.EventData instance.
%
%    EVENT.LISTENER does not bind the listener's lifecycle to the object 
%    that is the source of the event.  Calling delete(el) on the listener 
%    object deletes the listener, which means the event no longer causes
%    the callback function to execute.  Redefining or clearing the variable 
%    containing the listener object can delete the listener if no other 
%    references to it exist.  To define a listener that is tied 
%    to the event object, use addlistener.
%
%    All event listeners can also be created using listener or addlistener.  
%    In addition, property event listeners can also be created using 
%    event.proplistener.
%
%    See also ADDLISTENER, LISTENER, NOTIFY, EVENT.EVENTDATA, EVENT.PROPLISTENER

%   Copyright 2008-2017 The MathWorks, Inc. 
%   Built-in class.