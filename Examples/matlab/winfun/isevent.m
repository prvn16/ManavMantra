function ret = isevent(h, userInput)
%ISEVENT  True if COM object event.
%   ISEVENT(OBJ,NAME) returns 1 if string NAME is an event of object
%   OBJ, and 0 otherwise.
%
%   Example:
%     h = actxcontrol('mwsamp.mwsampctrl.2');
%     f = isevent(h, 'click')
%
%   See also ISMETHOD, ISPROP.  
  
%   Copyright 1999-2008 The MathWorks, Inc.

narginchk(2,2)

ret = 0;

if ~ (iscom(h) || isinterface(h))
    error(message('MATLAB:isevent:InvalidHandle'));
end

events = get(h.classhandle.Events);
eventNames = {events.Name};

ret = ismember(lower(userInput),lower(eventNames));

    