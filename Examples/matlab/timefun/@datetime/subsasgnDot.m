function this = subsasgnDot(this,s,rhs)

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datetime.getDateFields
import matlab.internal.datatypes.isCharString

ucal = datetime.dateFields;
if ~isstruct(s), s = struct('type','.','subs',s); end

name = s(1).subs;

% For nested subscript, get the property and call subsasgn on it
if ~isscalar(s)
    switch name
    case 'Format'
        value = getDisplayFormat(this);
    case 'TimeZone'
        value = this.tz;
    case 'Year'
        value = getDateFields(this.data,ucal.EXTENDED_YEAR,this.tz);
    case 'Month'
        value = getDateFields(this.data,ucal.MONTH,this.tz);
    case 'Day'
        value = getDateFields(this.data,ucal.DAY_OF_MONTH,this.tz);
    case 'Hour'
        value = getDateFields(this.data,ucal.HOUR_OF_DAY,this.tz);
    case 'Minute'
        value = getDateFields(this.data,ucal.MINUTE,this.tz);
    case 'Second'
        value = getDateFields(this.data,ucal.SECOND,this.tz);
    case 'SystemTimeZone'
        error(message('MATLAB:datetime:ReadOnlyProperty',name));
    otherwise
        if isCharString(name)
            error(message('MATLAB:datetime:UnrecognizedProperty',name));
        else
            error(message('MATLAB:datetime:InvalidPropertyName'));
        end
    end
    rhs = builtin('subsasgn',value,s(2:end),rhs);
end

% Assign the rhs to the property
switch name
case 'Format'
    try
        [this.fmt,this.isDateOnly] = verifyFormat(rhs,this.tz,false,true);
    catch ME
        if strcmp(this.tz,datetime.UTCLeapSecsZoneID)
            error(message('MATLAB:datetime:InvalidUTCLeapSecsFormatString',datetime.ISO8601Format));
        else
            rethrow(ME);
        end
    end
case 'TimeZone'
    % Canonicalize the TZ name. This make US/Eastern ->
    % America/New_York, but it will also make EST -> Etc/GMT-5,
    % because EST is an offset, not a time zone.
    rhs = verifyTimeZone(rhs);
    this.data = timeZoneAdjustment(this.data,this.tz,rhs);
    if strcmp(rhs,datetime.UTCLeapSecsZoneID)
        this.fmt = datetime.ISO8601Format; % force this required format
    elseif strcmp(this.tz,datetime.UTCLeapSecsZoneID)
        this.fmt = ''; % use default setting
    end
    this.tz = rhs;
case 'Year'
    this.data = assignHelper(this.data,rhs,ucal.EXTENDED_YEAR,this.tz,name);
case 'Month'
    this.data = assignHelper(this.data,rhs,ucal.MONTH,this.tz,name);
case 'Day'
    this.data = assignHelper(this.data,rhs,ucal.DAY_OF_MONTH,this.tz,name);
case 'Hour'
    this.data = assignHelper(this.data,rhs,ucal.HOUR_OF_DAY,this.tz,name);
case 'Minute'
    this.data = assignHelper(this.data,rhs,ucal.MINUTE,this.tz,name);
case 'Second'
    this.data = assignHelper(this.data,rhs,ucal.SECOND,this.tz,name);
case 'SystemTimeZone'
    error(message('MATLAB:datetime:ReadOnlyProperty',name));
otherwise
    if isCharString(name)
        error(message('MATLAB:datetime:UnrecognizedProperty',name));
    else
        error(message('MATLAB:datetime:InvalidPropertyName'));
    end
end

function data = assignHelper(data,rhs,field,tz,name)
import matlab.internal.datatypes.throwInstead

if ~isreal(rhs)
    error(message('MATLAB:datetime:InputMustBeReal'));
end

try
    data = matlab.internal.datetime.setDateField(data,full(double(rhs)),field,tz);
catch ME
    throwInstead(ME,'MATLAB:datetime:InputSizeMismatch',message('MATLAB:datetime:PropertyAssignmentResize',name));
end
