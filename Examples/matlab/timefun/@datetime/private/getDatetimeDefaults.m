function defaultVal = getDatetimeDefaults(dateTimeAttribute, locale, skeleton)

%   Copyright 2015 The MathWorks, Inc.

if nargin == 1 % 'timezone', 'locale', 'pivotyear'
    defaultVal  = matlab.internal.datetime.getDefaults(dateTimeAttribute);
else
    defaultVal  = matlab.internal.datetime.getDefaults(dateTimeAttribute,locale,skeleton);
end
