function [event, k] = findEvent(this,name,varargin)
%FINDEVENT Returns an event object based on the specified name
%
%   [E INDEX]=FINDEVENT(EVENTS,NAME) returns the first event object found 
%   in EVENTS, an array of event objects, with NAME as its name. The
%   function also returns the corresponding array index. If no object is
%   found, E is empty and INDEX is 0.
%
%   [E INDEX]=FINDEVENT(EVENTS,NAME,N) returns the Nth event object found 
%   in the EVENTS array with NAME as its name.
%
%   See also TSDATA.EVENT/EVENT, TSDATA.TIMESERIES/ADDEVENT

%   Copyright 2005-2016 The MathWorks, Inc.


% This could be an array of event objects
if nargin == 2
    pick_which_dups = 1;
else
    pick_which_dups = varargin{1};
    if isempty(pick_which_dups)
        pick_which_dups = 1;
    end
end

event = [];

if ~ischar(name) && ~(isstring(name) && isscalar(name)) 
    error(message('MATLAB:tsdata:event:findevent:misname'))
end
if ~isnumeric(pick_which_dups)
    error(message('MATLAB:tsdata:event:findevent:dups'))
end

j=1;
for k=1:length(this)
    if strcmp(this(k).name,name) 
        if j==pick_which_dups
            event = this(k);
            return;
        else
            j=j+1;            
        end
    end
end

k=0;