function fmt = getDisplayFormat(obj)
% GETDISPLAYFORMAT is used to get the default format used by the given
% datetime. If the given datetime object does not have a default format
% set, it will return the default format used by the datetime class.
%
% Copyright 2014-2015 The MathWorks, Inc.

if ~isempty(obj.fmt)
    fmt = obj.fmt;
elseif ~obj.isDateOnly
    fmt = getDatetimeSettings('defaultformat');
else
    fmt = getDatetimeSettings('defaultdateformat');
end
end
