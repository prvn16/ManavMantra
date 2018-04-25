function S = dateformverify(dtnumber, dateformstr, islocal)
%Helper function for datevec, to determine if a format is right or not.
%This is a simplified copy of datestr.  Takes as input a date number, and a
%dateformat, and whether to localize or not.  

% Copyright 2003-2011 The MathWorks, Inc.

%This is an internal function only.

if isempty(dtnumber)
   S = reshape('', 0, length(dateformstr)); 
   return;
end

if ~isfinite(dtnumber)
    %Don't bother to go through mex file, since datestr can not handle
    %non-finite dates.
    error(message('MATLAB:datestr:ConvertDateNumber'));
end

try
    % Obtain components using mex file
    [y,mo,d,h,minute,s] = datevecmx(dtnumber,true);  mo(mo==0) = 1;
catch exception 
    newExc = MException('MATLAB:datestr:ConvertDateNumber','%s',...
                        getString(message('MATLAB:datestr:ConvertDateNumberVerify')));
    newExc = newExc.addCause(exception);
    throw(newExc);
end

% format date according to data format template
S = char(formatdate([y,mo,d,h,minute,s],dateformstr,islocal));