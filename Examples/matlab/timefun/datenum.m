function n = datenum(arg1,arg2,arg3,h,min,s)
%DATENUM Serial date number.
%	N = DATENUM(V) converts one or more date vectors V into serial date 
%	numbers N. Input V can be an M-by-6 or M-by-3 matrix containing M full 
%	or partial date vectors respectively.  DATENUM returns a column vector
%	of M date numbers.
%
%	A date vector contains six elements, specifying year, month, day, hour, 
%	minute, and second. A partial date vector has three elements, specifying 
%	year, month, and day.  Each element of V must be a positive double 
%	precision number.  A serial date number of 1 corresponds to Jan-1-0000.  
%	The year 0000 is merely a reference point and is not intended to be 
%	interpreted as a real year.
%
%	N = DATENUM(S,F) converts text representing one or more dates to serial
%	date numbers N using format F. S can be a character array where each
%	row corresponds to one date, or one dimensional cell array of strings.
%	DATENUM returns a column vector of M date numbers, where M is the
%	number of strings in S.
%
%	All of the date strings in S must have the same format F, which must be
%	composed of date format symbols according to Table 2 in DATESTR help.
%
%	Certain formats may not contain enough information to compute a date
%	number.  In those cases, hours, minutes, and seconds default to 0, days
%	default to 1, months default to January, and years default to the
%	current year. Date strings with two character years are interpreted to
%	be within the 100 years centered around the current year.
%
%	N = DATENUM(S,F,P) or N = DATENUM(S,P,F) uses the specified format F
%	and the pivot year P to determine the date number N, from S. 
%   The pivot year is the starting year of the 100-year range in 
%	which a two-character year resides.  The default pivot year is the 
%	current year minus 50 years.
%
%	N = DATENUM(Y,MO,D) and N = DATENUM([Y,MO,D]) return the serial date
%	numbers for corresponding elements of the Y,MO,D (year,month,day)
%	arrays. Y, MO, and D must be arrays of the same size (or any can be a
%	scalar).
%
%	N = DATENUM(Y,MO,D,H,MI,S) and N = DATENUM([Y,MO,D,H,MI,S]) return the
%	serial date numbers for corresponding elements of the Y,MO,D,H,MI,S
%	(year,month,day,hour,minute,second) arrays.  The six arguments must be
%	arrays of the same size (or any can be a scalar).
%
%   N = DATENUM(V) converts date represented as date vector (as defined by
%   DATEVEC) V into a serial date number.
%
%	N = DATENUM(S) converts date represented as text S into a serial date
%	number. S must be in one of the date formats 0,1,2,6,13,14,15,16,23 as
%	defined by DATESTR. This calling syntax is provided for backward
%	compatibility, and is significantly slower than the syntax which
%	specifies the format. If the format is known, the N =
%	DATENUM(S,F) syntax should be used.
%
%	N = DATENUM(S,P) converts date represented as text S, using pivot year
%	P. If the format is known, the N = DATENUM(S,F,P) or N = DATENUM(S,P,F)
%	syntax should be used.
%
%	Note:  The vectorized calling syntax can offer significant performance
%	improvement for large arrays.
%
%	Examples:
%		n = datenum('19-May-2000') returns n = 730625. 
%		n = datenum(2001,12,19) returns n = 731204. 
%		n = datenum(2001,12,19,18,0,0) returns n = 731204.75. 
%		n = datenum('19.05.2000','dd.mm.yyyy') returns n = 730625.
%
%	See also NOW, DATESTR, DATEVEC, DATETICK.

%   Copyright 1984-2016 The MathWorks, Inc.

import matlab.internal.datatypes.stringToLegacyText

narginchk(1, 6);

% Shallow adoption of string
arg1 = stringToLegacyText(arg1);

% parse input arguments
isdatestr = ~isnumeric(arg1);
isdateformat = false;
if nargin == 2
    arg2 = stringToLegacyText(arg2);
    isdateformat = ischar(arg2);
elseif nargin == 3
    arg2 = stringToLegacyText(arg2);
    arg3 = stringToLegacyText(arg3);
    isdateformat = [ischar(arg2), ischar(arg3)];
end

if isdatestr && isempty(arg1)
    n = zeros(0,1);
	warning(message('MATLAB:datenum:EmptyDate'));
    return;
end

% try to convert date character vector or date vector to a date number
try
    switch nargin
        case 1 
            if isdatestr
                n = datenummx(datevec(arg1));
            elseif ((size(arg1,2)==3) || (size(arg1,2)==6)) && ...
                    any(abs(arg1(:,1) - 2000) < 10000)
                n = datenummx(arg1);
            else
                n = arg1;
            end
        case 2
            if isdateformat
                if ischar(arg1)
					arg1 = cellstr(arg1);
                end
                if ~iscellstr(arg1)
                    %At this point we should have a cell array.  Otherwise error.
                    error(message('MATLAB:datenum:NotAStringArray'));
                end
                if isempty(arg2)
                    n = datenummx(datevec(arg1));
                else
                    n = dtstr2dtnummx(arg1,matlab.internal.datetime.cnv2icudf(arg2));             
                end
            else
                n = datenummx(datevec(arg1,arg2));
            end
        case 3
			if any(isdateformat)
				if isdateformat(1) 
					format = arg2;
					pivot = arg3;
				elseif isdateformat(2)
					format = arg3;
					pivot = arg2;
				end
				if ischar(arg1)
					arg1 = cellstr(arg1);
				end
                if ~iscellstr(arg1)
                    %At this point we should have a cell array.  Otherwise error.
                    error(message('MATLAB:datenum:NotAStringArray'));
                end
				icu_dtformat = matlab.internal.datetime.cnv2icudf(format);
				showyr =  strfind(icu_dtformat,'y'); 
                if ~isempty(showyr)
                    wrtYr =  numel(showyr);
                    checkYr = diff(showyr);
                    if any(checkYr~=1)
                        error(message('MATLAB:datenum:YearFormat'));
                    end
                    switch wrtYr
                        case 4
                            icu_dtformat = strrep(icu_dtformat,'yyyy','yy');
                        case 3
                            icu_dtformat = strrep(icu_dtformat,'yyy','yy');
                    end
                end
                if (isempty(format))
                    n = datenummx(datevec(arg1,pivot));
                else
                    if (isempty(pivot))
                        n = dtstr2dtnummx(arg1,icu_dtformat);
                    else
                        n = dtstr2dtnummx(arg1,icu_dtformat,pivot);
                    end
                end
            else
                verifySizes(arg1,arg2,arg3);
                n = datenummx(arg1,arg2,arg3);
			end
        case 6
            verifySizes(arg1,arg2,arg3,h,min,s);
            n = datenummx(arg1,arg2,arg3,h,min,s);
        otherwise
            error(message('MATLAB:datenum:Nargin'));
    end
catch exception   
    if (nargin == 1 && ~isdatestr)
        identifier = 'MATLAB:datenum:ConvertDateNumber';
    elseif (nargin == 1 && isdatestr) || (isdatestr && any(isdateformat))
        identifier = 'MATLAB:datenum:ConvertDateString';
    elseif (nargin > 1) && ~isdatestr && ~any(isdateformat)
        identifier = 'MATLAB:datenum:ConvertDateVector';
    else
        identifier = exception.identifier;
    end
    newExc = MException( identifier,'%s',getString(message('MATLAB:datenum:Failed')));
    newExc = newExc.addCause(exception);
    throw(newExc);
end

function verifySizes(varargin)
currentSize = 1;
for i = 1:nargin
    thisSize = numel(varargin{i});
    if (currentSize == 1)
        currentSize = thisSize;
    elseif (currentSize ~= thisSize && thisSize ~= 1)
        exc = MException('MATLAB:datenum:InconsistentInputs','%s',...
            getString(message('MATLAB:datenum:InconsistentInputs')));
        throwAsCaller(exc);
    end
end
