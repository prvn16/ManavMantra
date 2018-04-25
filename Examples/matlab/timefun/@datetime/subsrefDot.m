function value = subsrefDot(this,s)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datetime.getDateFields
import matlab.internal.datatypes.isCharString

ucal = datetime.dateFields;
if ~isstruct(s), s = struct('type','.','subs',s); end

name = s(1).subs;
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
    value = datetime.getsetLocalTimeZone('uncanonical');
otherwise
    if isCharString(name)
        error(message('MATLAB:datetime:UnrecognizedProperty',name));
    else
        error(message('MATLAB:datetime:InvalidPropertyName'));
    end
end

% None of the properties can return a CSL, so a single output is sufficient. 
if ~isscalar(s)
    value = subsref(value,s(2:end));
end
