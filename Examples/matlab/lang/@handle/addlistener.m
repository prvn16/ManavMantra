%ADDLISTENER  Add listener for event.
%   el = ADDLISTENER(hSource, Eventname, callbackFcn) creates a listener
%   for the event named Eventname.  The source of the event is the handle 
%   object hSource.  If hSource is an array of source handles, the listener
%   responds to the named event on any handle in the array.  callbackFcn
%   is a function handle that is invoked when the event is triggered.
%
%   el = ADDLISTENER(hSource, PropName, Eventname, Callback) adds a 
%   listener for a property event.  Eventname must be one of
%   'PreGet', 'PostGet', 'PreSet', or 'PostSet'. Eventname can be
%   a string scalar or character vector.  PropName must be a single 
%   property name specified as string scalar or character vector, or a 
%   collection of property names specified as a cell array of character 
%   vectors or a string array, or as an array of one or more 
%   meta.property objects.  The properties must belong to the class of 
%   hSource.  If hSource is scalar, PropName can include dynamic 
%   properties.
%   
%   For all forms, addlistener returns an event.listener.  To remove a
%   listener, delete the object returned by addlistener.  For example,
%   delete(el) calls the handle class delete method to remove the listener
%   and delete it from the workspace.
%
%   ADDLISTENER binds the listener's lifecycle to the object that is the 
%   source of the event.  Unless you explicitly delete the listener, it is
%   destroyed only when the source object is destroyed.  To control the
%   lifecycle of the listener independently from the event source object, 
%   use listener or the event.listener constructor to create the listener.
%
%   See also LISTENER, EVENT.LISTENER, HANDLE, NOTIFY, DELETE, META.PROPERTY, EVENTS
 
%   Copyright 2008-2017 The MathWorks, Inc.
%   Built-in class method.



