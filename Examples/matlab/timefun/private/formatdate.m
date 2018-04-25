function dtstrarray = formatdate(dtvector,formatstr,islocal)
%   FORMATDATE casts date vector into a specified date format
%   DATESTRING = FORMATDATE(DATEVECTOR, FORMATSTRING) turns the date
%   vector into text representing the date, according to the user's date
%   format template.
%
%   INPUT PARAMETERS:
%   DATEVECTOR: 1 x m double array, containing standard MATLAB date vector.
%   FORMATSTRING: char vector containing a user specified date format. See NOTE 1.
%
%   RETURN PARAMETERS:
%   DATESTRING: char vector, containing date and, optionally, time formated
%               as per user specified format.
%
%   EXAMPLES:
%   The date vector [2002 10 01 16 8] reformed as text representing date and time,
%   using a user format, 'dd-mm-yyyy HH:MM', will display as 
%   01-10-2002 16:08 .
%   
%   NOTE 1: The format specifier allows free-style date format, within the
%   following limits - 
%   ddd  => day is formatted as abbreviated name of weekday
%   dd   => day is formatted as two digit day of month
%   d    => day is formatted as first letter of name of weekday
%   mmm  => month is formatted as three letter abbreviation of name of month
%   mm   => month is formatted as two digit month of year
%   m    => month is formatted as one or two digit month of year
%   yyyy => year is formatted as four digit year
%   yy   => year is formatted as two digit year
%   HH   => hour is formatted as two digit hour of the day
%   MM   => minute is formatted as two digit minute of the hour
%   SS   => second is formatted as two digit second of the minute
%   The user may use any separator and other delimiters of his liking, but
%   must confine himself to the above format tokens regarding day, month,
%   year, hour, minute and second.
% 
%   
%------------------------------------------------------------------------------

% Copyright 2003-2016 The MathWorks, Inc.

if isempty(dtvector) || isempty(formatstr)
    dtstrarray = '';
    return;
else
    dtstr = formatstr;
end

showAmPm = [strfind(lower(dtstr), 'am'), strfind(lower(dtstr), 'pm')];
wrtAmPm = numel(showAmPm);

% Canonicalize and error-check dtstr by converting it to ICU format.
dtstr = matlab.internal.datetime.cnv2icudf(dtstr,false);

% To assist with formatting, use 'D' and 'S' for days and seconds,
% respectively, so as not to confuse the 'd' for day with the 'd' in '%d'
% when building the conversion character vector.  Note also that, since milliseconds
% are already defined as S, we will need to convert them to F first.
dtstr = strrep(dtstr, 'S', 'F');
dtstr = strrep(dtstr, 'd', 'D');
dtstr = strrep(dtstr, 's', 'S');

% Ensure that all hour formats are capitalized since AM/PM was handled.
dtstr = strrep(dtstr, 'h', 'H');

showYr   = strfind(dtstr,'y'); wrtYr   = numel(showYr);
showMo   = strfind(dtstr,'M'); wrtMo   = numel(showMo);
showNday = strfind(dtstr,'D'); wrtNDay = numel(showNday);
showWday = strfind(dtstr,'E'); wrtWDay = numel(showWday);
showHr   = strfind(dtstr,'H'); wrtHr   = numel(showHr);
showMin  = strfind(dtstr,'m'); wrtMin  = numel(showMin);
showSec  = strfind(dtstr,'S'); wrtSec  = numel(showSec);
showMsec = strfind(dtstr,'F'); wrtMsec = numel(showMsec);
showQrt  = strfind(dtstr,'Q'); wrtQrt  = numel(showQrt);

% Format day.
if wrtNDay > 0
    dtstr = strrep(dtstr, 'DD', '%02d');
    day = abs(dtvector(:,3));
    showNday = showNday(1);
else
    day = [];
end

% Format weekday.
if wrtWDay > 0
    if islocal
        locale = 'local';
    else
        locale = 'en_us';
    end
    [~, dayOfWeek] = weekday(datenum(dtvector), 'long', locale);
    switch wrtWDay
        case 4  % long weeday names (e.g., 'Monday')
            dtstr = strrep(dtstr, 'EEEE', '%s');
        case 3  % short weekday names (e.g., 'Mon')
            dtstr = strrep(dtstr, 'EEE', '%s');
            dayOfWeek = dayOfWeek(:, 1:3);
        case 1  % 1-letter weekday names (e.g., 'M')
            dtstr = strrep(dtstr, 'E', '%s');
            dayOfWeek = dayOfWeek(:, 1);
    end
    showWday = showWday(1);
else
    dayOfWeek = [];
end

% Format year.
% Calculating year may truncate the first element of the datevector to two
% digits, thus it must be done after any weekday calculations.
if wrtYr > 0
    if wrtYr == 4
            dtstr = strrep(dtstr,'yyyy','%.4d');
    else % wrtYr == 2
            dtstr = strrep(dtstr,'yy','%02d');
            dtvector(:,1) = mod(abs(dtvector(:,1)),100);
    end
	year = mod(dtvector(:,1),10000);
    showYr = showYr(1);
else
    year = [];
end

% Format quarter.
% This must happen after wrtNDay and wrtWDay are set.
if wrtQrt > 0
    dtstr = strrep(dtstr,'QQQ', 'Q%1d');
	qrt = floor((dtvector(:,2)-1)/3)+1;
    showQrt = showQrt(1);
else
    qrt = [];
end


% Format month.
if wrtMo > 0
    switch wrtMo
        case 4     %long month names
            if islocal
                month = getmonthnamesmx('longloc');
            else
                month = {'January';'February';'March';'April';'May'; ...
                         'June';'July';'August';'September';'October'; ...
                         'November';'December'};
            end
            monthfmt = '%s';
            dtstr = strrep(dtstr,'MMMM',monthfmt);
            month = char(month(dtvector(:,2)));
        case 3     % short month names
            if islocal
                month = getmonthnamesmx('shortloc');
            else
                month = {'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
            end
            monthfmt = '%s';
            dtstr = strrep(dtstr,'MMM',monthfmt);
            month = char(strrep(month(dtvector(:,2)), '.', '')); %remove period
        case 2    % two-digit month number
            dtstr = strrep(dtstr,'MM','%02d');
            month = abs(dtvector(:,2));
        otherwise % 1-letter month names
            if islocal
                month = getmonthnamesmx('shortloc');
            else
                month = {'J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'};
            end
            dtstr = strrep(dtstr,'M','%.1s');
            month = char(month(dtvector(:,2)));
    end
    showMo = showMo(1);
else
    month = [];
end

% Format hour.
h = dtvector(:,4);
if wrtHr > 0
    if wrtAmPm > 0
        fmt = '%2d';
        dtvector(:,4) = mod(h-1,12) + 1; % replace hour column with 12h format.
    else
        fmt = '%02d';
    end
    dtstr = strrep(dtstr,'HH',fmt);
    hour = dtvector(:,4);
    showHr = showHr(1);
else
    hour = [];
end

% Format AM/PM.
if wrtAmPm > 0
    if islocal
        amPmVals = getampmtokensmx;
    else
        amPmVals = {'AM', 'PM'};
    end
    dtstr = strrep(dtstr, 'a', '%s');
    amPm(h < 12) = amPmVals(1);
    amPm(h >= 12) = amPmVals(2);
    amPm = char(amPm);
else
    amPm = [];
end

% Format minute.
if wrtMin > 0
    dtstr = strrep(dtstr,'mm','%02d');
	minute = dtvector(:,5);
    showMin = showMin(1);
else
    minute = [];
end

% Format second.
if wrtSec > 0
    dtstr = strrep(dtstr,'SS','%02d');
	second = floor(dtvector(:,6));
    showSec = showSec(1);
else
    second = [];
end

% Format millisecond.
if wrtMsec > 0
    dtstr = strrep(dtstr,'FFF','%03d');
	millisecond = floor(1000*(dtvector(:,6) - floor(dtvector(:,6))));
    showMsec = showMsec(1);
else
    millisecond = [];
end

% build date-time array to print
dtorder = [showYr, showQrt, showMo, showNday, showWday, ...
           showAmPm, showHr, showMin, showSec, showMsec];
dtarray = {year, qrt, month, day, dayOfWeek, ...
           amPm, hour, minute, second, millisecond};
dtarray = dtarray([wrtYr, wrtQrt, wrtMo, wrtNDay, wrtWDay, ...
                   wrtAmPm, wrtHr, wrtMin, wrtSec, wrtMsec] > 0);

% sort date vector in the order of the time format fields
[~, dtorder] = sort(dtorder);

% print date vector using conversion character vector
dtarray = dtarray(dtorder);
nrows = size(dtvector,1);
if nrows == 1
    %optimize if only one member
    dtstrarray = sprintf(dtstr, dtarray{:});
else
    dtstrarray = cell(nrows,1);
    numeldtarray = length(dtarray);
    thisdate = cell(1,numeldtarray);
    for i = 1:nrows
        for j = 1:numeldtarray
            % take horzontal slice through cells
            thisdate{j} = dtarray{j}(i,:);
        end
        dtstrarray{i} = sprintf(dtstr, thisdate{:});
    end
end


