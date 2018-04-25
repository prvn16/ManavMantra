function t_data = convertFrom(value,type,tz,epoch)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

if ~isCharString(type) && ~(isstring(type) && isscalar(type))
    error(message('MATLAB:datetime:InvalidConversionType'));
end
if ~isreal(value)
    error(message('MATLAB:datetime:InputMustBeReal'));
end

% All of these conversions are done in "local time", i.e. ignoring tz
% and dst, except for julian date and posix time, which are assumed
% measured with respect to UTC. In other words, all but the latter
% two are treated as unzoned input values, and must be adjusted to UTC
% if the output is zoned.
unzonedInput = true;

isUTCLeapSecs = strcmp(tz,datetime.UTCLeapSecsZoneID);

millisPerDay = 86400 * 1000;
millisPerSec = 1000;

value = full(double(value));
switch lower(type)
case 'datenum'
    % Because they count days, datenums can't represent whole hours, minutes, or
    % seconds exactly, "nice" times are represented with round-off (datenum's
    % resolution for contemporary dates is about 1.006e-5s). datetime _can_
    % represent such times exactly, but the original (rounded-off) datenum is also
    % representable. So the mathewmatically correct conversion often leads to a
    % datetime that differs by fractional seconds from the time that the datenum
    % was intended to represent. This is not helpful. Instead, find datenums
    % that correspond to exact milliseconds, and round to the exact ms. This is
    % less draconian than rounding everything to the nearest .1ms, and preserves
    % a round trip.
    t_data = (value - datetime.epochDN)*millisPerDay;
    t_dataRounded = round(t_data);
    i = (value == (t_dataRounded + datetime.epochDN*millisPerDay) / millisPerDay);
    t_data(i) = t_dataRounded(i);
    
case 'posixtime'
    t_data = value*millisPerSec; % s -> ms
    if isUTCLeapSecs
        % POSIX time does not count leap seconds, add them.
        t_data = addLeapSeconds(t_data);
    end
    unzonedInput = false;
    
case {'excel' 'excel1900'}
    if any(value(:) < 0)
        error(message('MATLAB:datetime:ExcelTimeOutOfRange'));
    end
    % Day number (including fractional days) since 0-Jan-1900
    %
    % Round Excel day numbers to the nearest microsec, just above their
    % resolution for contemporary dates (about 6e-7s).
    excelOffset1900 = 25568;
    value = value - (value > 60); % Correction for Excel's 1900 leap year bug
    t_data = round2microsecs((value - excelOffset1900)*millisPerDay);
    
case 'excel1904'
    if any(value(:) < 0)
        error(message('MATLAB:datetime:ExcelTimeOutOfRange'));
    end
    % Day number (including fractional days) since 0-Jan-1904
    %
    % Round Excel day numbers to the nearest microsec, just above their
    % resolution for contemporary dates (about 6e-7s).
    excelOffset1904 = 24107;
    t_data = round2microsecs((value - excelOffset1904)*millisPerDay);
    
case {'jd' 'juliandate'}
    JDoffset = 2440587.5; % the Julian date for 00:00:00 1-Jan-1970
    % Shift the origin to 1970, and scale from days to millis.
    if ~isUTCLeapSecs
        t_data = (value - JDoffset)*millisPerDay;
    else
        t_data = days2MillisWithLeapSecs(value - JDoffset);
    end
    unzonedInput = false;
    
case {'mjd' 'modifiedjuliandate'}
    MJDoffset = 40587; % the modified Julian date for 00:00:00 1-Jan-1970
    % Shift the origin to 1970, and scale from days to millis.
    if ~isUTCLeapSecs
        t_data = (value - MJDoffset)*millisPerDay;
    else
        t_data = days2MillisWithLeapSecs(value - MJDoffset);
    end
    unzonedInput = false;
    
case 'yyyymmdd'
    if any(value(:) < 0)
        error(message('MATLAB:datetime:YYYYMMDDOutOfRange'));
    end
    % Let the month and day numbers roll just as they would for datevecs
    value = double(full(value));
    year = round(value/10000);
    value = value - year*10000;
    month = round(value/100);
    day = value - month*100;
    t_data = matlab.internal.datetime.createFromDateVec({year month day},'');
    
    % Handle NaT, Inf, or -Inf datetimes
    nonfinites = ~isfinite(value);
    t_data(nonfinites) = year(nonfinites);
    
case 'epochtime'
    if isCharString(epoch) || (isstring(epoch) && isscalar(epoch))
        epoch = datetime(epoch); epoch = epoch.data;
    elseif isa(epoch,'datetime')
        epoch = epoch.data;
    elseif ~isnumeric(epoch) || ~isreal(epoch)
        error(message('MATLAB:datetime:InvalidEpoch'));
    end
    if ~isscalar(epoch)
        error(message('MATLAB:datetime:NonScalarEpoch'));
    end
    t_data = double(epoch) + value*millisPerSec; % s -> ms
    
otherwise
    error(message('MATLAB:datetime:UnrecognizedConversionType',matlab.internal.datatypes.stringToLegacyText(type)));
end

if unzonedInput && ~isempty(tz)
    % For inputs that are treated as unzoned, adjust the internal value
    % if the output should be zoned.
    t_data = timeZoneAdjustment(t_data,'',tz);
end


function data = round2microsecs(millis)
% Round millisecs to nearest microsec
wholeMillis = floor(millis);
fracMillis = round(millis - wholeMillis,3); % round fractional part for smaller round-off error
fracMillis(isinf(millis)) = 0; % preserve Infs
data = matlab.internal.datetime.datetimeAdd(wholeMillis,fracMillis);


function data = days2MillisWithLeapSecs(day)
% Convert a day count from 1970 to an internal value, accounting for leap seconds
millisPerDay = 86400 * 1000;
millisPerSec = 1000;
wholeDay = floor(day);
dayFrac = day - wholeDay;
% Adjust the beginning of the day to account for previous for leap seconds,
% and decide if the day ends in a leap second.
[data,~,isLeapSecDay] = addLeapSeconds(wholeDay*millisPerDay);
% Add on the day fraction, normalized by the appropriate day length.
data = data + dayFrac.*(millisPerDay + millisPerSec*isLeapSecDay);
