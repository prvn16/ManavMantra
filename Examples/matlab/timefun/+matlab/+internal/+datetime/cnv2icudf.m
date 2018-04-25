function dtstr = cnv2icudf(formatstr,escaping)
%   CNV2ICUDF maps date format tokens to ICU date format tokens
%   ICUFORMAT = CNV2ICUDF(MLFORMAT) turns the date format into a date
%   format that uses the format tokens of the ICU Libraries
%
%   INPUT PARAMETERS:
%   MLFORMAT: char vector containing a user specified date format. See NOTE 1.
%
%   RETURN PARAMETERS:
%   ICUFORMAT: char vector, containing date and, optionally, time formatted
%              as per user specified format.
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

% Copyright 2002-2016 The MathWorks, Inc.

dtstr = formatstr;
if nargin == 1
    escaping = true;
end
% Replace AM/PM with 'a' to avoid confusion with months and minutes.
showAmPm = [strfind(lower(dtstr), 'am'), strfind(lower(dtstr), 'pm')];
wrtAmPm = numel(showAmPm);
if wrtAmPm > 0
    if wrtAmPm > 1
        error(message('MATLAB:formatdate:ampmFormat', formatstr));
    end
    dtstr(showAmPm) = [];
    dtstr(showAmPm) = 'a';
end

% Ensure that days, hours, milliseconds, quarters, seconds, and year are
% case-correct.
dtstr = strrep(dtstr, 'd', 'D');
dtstr = strrep(dtstr, 'f', 'F');
dtstr = strrep(dtstr, 'h', 'H');
dtstr = strrep(dtstr, 'q', 'Q');
dtstr = strrep(dtstr, 'S', 's');
dtstr = strrep(dtstr, 'Y', 'y');

% Escape unused characters.
if escaping
dtstr = regexprep(dtstr,'((?=[A-Za-z])([^amsyDFHMQ]))*','''$1''');
end

showYr   = strfind(dtstr,'y'); wrtYr   = numel(showYr);
showMo   = strfind(dtstr,'m'); wrtMo   = numel(showMo);
showDay  = strfind(dtstr,'D'); wrtDay  = numel(showDay);
showHr   = strfind(dtstr,'H'); wrtHr   = numel(showHr);
showMin  = strfind(dtstr,'M'); wrtMin  = numel(showMin);
showSec  = strfind(dtstr,'s'); wrtSec  = numel(showSec);
showMsec = strfind(dtstr,'F'); wrtMsec = numel(showMsec);
showQrt  = strfind(dtstr,'Q'); wrtQrt  = numel(showQrt);

dtstr = strrep(dtstr,'M','N'); % to avoid confusion with ICU month tokens

% Format date
if wrtYr > 0
    if (wrtYr ~= 4 && wrtYr ~= 2) || showYr(end) - showYr(1) >= wrtYr
        error(message('MATLAB:formatdate:yearFormat', formatstr));
    end
end
if wrtQrt > 0
    if wrtQrt ~= 2 || showQrt(2) - showQrt(1) > 1
        error(message('MATLAB:formatdate:quarterFormat', formatstr));
    end
    if any([wrtMo, wrtDay, wrtAmPm, wrtHr, wrtMin, wrtSec, wrtMsec] > 0)
        error(message('MATLAB:formatdate:quarterFormatMismatch',formatstr));
    end
    dtstr = strrep(dtstr, 'QQ', 'QQQ');
end
if wrtMo > 0
    if wrtMo > 4 || showMo(end) - showMo(1) >= wrtMo
        error(message('MATLAB:formatdate:monthFormat', formatstr));
    end
    dtstr = strrep(dtstr,'m','M');
end
if wrtDay > 0
    dtstr = strrep(dtstr, 'DDDDDD', 'EEEEdd');
    dtstr = strrep(dtstr, 'DDDDD',  'EEEdd');
    dtstr = strrep(dtstr, 'DDDD',   'EEEE');
    dtstr = strrep(dtstr, 'DDD',    'EEE');
    dtstr = strrep(dtstr, 'DD',     'dd');
    dtstr = strrep(dtstr, 'D',      'E');
    showNday = strfind(dtstr,'d'); wrtNday = numel(showNday);
    if wrtNday > 0
        if wrtNday ~= 2 || showNday(2) - showNday(1) ~= 1
            error(message('MATLAB:formatdate:dayFormat', formatstr));
        end
    end
    showWday = strfind(dtstr,'E'); wrtWday = numel(showWday);
    if wrtWday > 0
        if wrtWday > 4 || showWday(end) - showWday(1) >= wrtWday
            error(message('MATLAB:formatdate:dayFormat', formatstr));
        end
    end
end

% Format time
if wrtHr > 0
    if wrtHr == 2 && showHr(2) - showHr(1) == 1
        if wrtAmPm
            dtstr = strrep(dtstr,'H','h');
        end
    else
        error(message('MATLAB:formatdate:hourFormat', formatstr));
    end
end
if wrtMin > 0
    if wrtMin == 2 && showMin(2) - showMin(1) == 1
        dtstr = strrep(dtstr,'N','m');
    else
        error(message('MATLAB:formatdate:minuteFormat', formatstr));
    end
end
if wrtSec > 0
    if wrtSec ~= 2 || showSec(2) - showSec(1) ~= 1
        error(message('MATLAB:formatdate:secondFormat', formatstr));
    end
end
if wrtMsec > 0
    if wrtMsec == 3 && showMsec(3) - showMsec(1) == 2
        dtstr = strrep(dtstr,'F','S');
    else
        error(message('MATLAB:formatdate:millisecondFormat', formatstr));
    end
end
