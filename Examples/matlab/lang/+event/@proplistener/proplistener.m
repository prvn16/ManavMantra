%EVENT.PROPLISTENER    Listener object for property events
%    The EVENT.PROPLISTENER class is a subclass of event.listener and
%    defines listener objects for property events.  Property listener 
%    objects listen for an event on a specific property and identify the 
%    callback function to invoke when the event is triggered.
%    
%    EL = EVENT.PROPLISTENER(obj,Properties,PropEvent,@callbackFcn)
%    creates a listener object for one or more properties on the 
%    specified object.  The input parameter Properties must be an object 
%    array or cell array of meta.property handles.  PropEvent can be a 
%    string scalar or character vector and must be one of 'PreSet', 
%    'PostSet', 'PreGet', or 'PostGet'.  The fourth argument is a function 
%    handle to the event callback function.  If obj is an array of handle 
%    objects, the listener responds to the named event on any object in 
%    the array.
%
%    Property event listeners can also be created using addlistener and 
%    listener.
%
%    See also ADDLISTENER, LISTENER, NOTIFY, EVENT.LISTENER, EVENT.EVENTDATA

%   Copyright 2008-2017 The MathWorks, Inc. 
%   Built-in class.