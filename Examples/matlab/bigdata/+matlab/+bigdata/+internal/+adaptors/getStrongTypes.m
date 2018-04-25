function types = getStrongTypes()
%getStrongTypes Returns cellstr of known-strong types
%   Types that are "strong" must be known at the client.

%   Copyright 2016-2017 The MathWorks, Inc.

types = { 
    'calendarDuration'
    'categorical'
    'datetime'
    'duration'
    'string'
    'table'
    'timetable'
    }';
end
