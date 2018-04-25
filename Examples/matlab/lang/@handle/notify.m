%NOTIFY   Notify listeners of event.
%   NOTIFY(H, eventname) notifies listeners added to the event named 
%   eventname for handle object array H that the event is taking place. 
%   eventname can be a string scalar or character vector.  
%   H is the array of handles to the event source objects, and 'eventname'
%   must be a character vector.
%
%   NOTIFY(H,eventname,ed) provides a way of encapsulating information 
%   about an event which can then be accessed by each registered listener.
%   ed must belong to the EVENT.EVENTDATA class.
%
%   See also HANDLE, HANDLE/ADDLISTENER, HANDLE/LISTENER, EVENT.EVENTDATA, EVENTS
 
%   Copyright 2007-2017 The MathWorks, Inc.
%   Built-in function.



