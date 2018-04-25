function t = tsgetrelativetime(date,dateRef,unit)
% 

% this method calculates relative time value between date absolute dateref.

%  Copyright 2004-2016 The MathWorks, Inc.

if iscellstr(dateRef)
    vecRef = datevec(dateRef); 
elseif iscell(dateRef) || isstring(dateRef)
    vecRef = datevec(cellstr(dateRef));
else
    vecRef = datevec(char(dateRef));
end
if iscellstr(date)
    vecDate = datevec(date);
elseif iscell(date) || isstring(date)
    vecDate = datevec(cellstr(date));
else
    vecDate = datevec(char(date));
end
t = tsunitconv(unit,'days')*(datenum([vecDate(:,1:3) zeros(size(vecDate,1),3)])-datenum([vecRef(1:3) 0 0 0])) + ...
    tsunitconv(unit,'seconds')*(vecDate(:,4:6)*[3600 60 1]'-vecRef(:,4:6)*[3600 60 1]');
