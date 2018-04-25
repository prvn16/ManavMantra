%LISTENER  Add listener for event without binding the listener to the source object.
%   el = LISTENER(hSource, Eventname, callbackFcn) creates a listener
%   for the event named Eventname.  The source of the event is the handle  
%   object hSource.  If hSource is an array of source handles, the listener
%   responds to the named event on any handle in the array.  callbackFcn
%   is a function handle that is invoked when the event is triggered.
%
%   el = LISTENER(hSource, PropName, Eventname, callback) adds a 
%   listener for a property event.  Eventname must be one of  
%   'PreGet', 'PostGet', 'PreSet', or 'PostSet'. Eventname can be a 
%   string sclar or character vector.  PropName must be either a single 
%   property name specified as a string scalar or character vector, or 
%   a collection of property names specified as a cell array of character 
%   vectors or a string array, or as an array of one ore more 
%   meta.property objects. The properties must belong to the class of 
%   hSource.  If hSource is scalar, PropName can include dynamic 
%   properties.
%   
%   For all forms, listener returns an event.listener.  To remove a
%   listener, delete the object returned by listener.  For example,
%   delete(el) calls the handle class delete method to remove the listener
%   and delete it from the workspace.  Calling delete(el) on the listener
%   object deletes the listener, which means the event no longer causes
%   the callback function to execute. 
%
%   LISTENER does not bind the listener's lifecycle to the object that is
%   the source of the event.  Destroying the source object does not impact
%   the lifecycle of the listener object.  A listener created with LISTENER
%   must be destroyed independently of the source object.  Calling 
%   delete(el) explicitly destroys the listener. Redefining or clearing 
%   the variable containing the listener can delete the listener if no 
%   other references to it exist.  To tie the lifecycle of the listener to 
%   the lifecycle of the source object, use addlistener.
%
%   See also ADDLISTENER, EVENT.LISTENER, HANDLE, NOTIFY, DELETE, META.PROPERTY, EVENTS
 
%   Copyright 2008-2017 The MathWorks, Inc.
%   Built-in class method.



