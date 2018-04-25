function checkMissingIndicators(indicators, callingmfile)
%checkMissingIndicators
% Nonstandard missing-value indicators, specified as a vector or cell array
% containing the following supported types:
%
% single | double | int8 | int16 | int32 | int64 | uint8 | uint16 | uint32 | uint64 | logical | char | string | cell | datetime | duration


% Copyright 2016 The MathWorks, Inc.

% Special case to handle calendarDuration indicators
% necessary to throw matching exceptions as base matlab
if iscalendarduration(indicators)
    if strcmpi(callingmfile, 'standardizeMissing')
        error(message('MATLAB:ismissing:StdizeCalendarDuration'));
    else
        error(message('MATLAB:ismissing:IndicatorsCalendarDuration'));
    end
end

if ~isValidIndicator(indicators)
    error(message('MATLAB:ismissing:IndicatorsInvalidType', class(indicators)));
end

end

function tf = isValidIndicator(arg)
tf = ( (isempty(arg) || isvector(arg)) && isSupportedIndicatorType(arg) ) ...
    || (iscell(arg) && all(cellfun(@isSupportedIndicatorType, arg)));
end

function tf= isSupportedIndicatorType(arg)
allowedTypes = {'single','double', ...
    'int8','int16','int32','int64', ...
    'uint8','uint16','uint32','uint64', ...
    'logical','char','string','datetime','duration','missing'};

tf = ismember(class(arg), allowedTypes);
end
