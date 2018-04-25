function eventStr = getTimeStr(this,varargin)
%GETTIMESTR Returns a cell array of strings indicating the times of all
%event objects.  
%
%   STR = GETTIMESTR(EVENTS,UNITS) where EVENTS is an array of event
%   objects and UNITS is the desired time units.  When the StartDate
%   property of an event object is empty, STR returns the times in
%   specified UNITS. Otherwise, UNITS is ignored.   

%   Copyright 2004-2006 The MathWorks, Inc.

% This could be an array of event objects
eventStr = cell(size(this));
for k=1:length(this)
    if ~isempty(this(k).StartDate)
        eventStr{k} = datestr(this(k).Time*tsunitconv('days',this(k).Units)+...
              datenum(this(k).StartDate),0);
    else
        if nargin>=2 && ~isempty(varargin{1})
            eventStr{k} = sprintf('%0.3f',this(k).Time*...
                tsunitconv(varargin{1},this(k).Units));
        else
            eventStr{k} = sprintf('%0.3f',this(k).Time);
        end
    end
end