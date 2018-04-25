function out = getAdaptorForType(typeName)
%getAdaptorForType Return adaptor for named type

% Copyright 2016-2017 The MathWorks, Inc.

switch typeName
    case 'table'
        assert(false, 'MATLAB:bigdata:array:AssertTabularAdaptorFromType', ...
            'Cannot create table adaptor from type name alone.');
    case 'timetable'
        assert(false, 'MATLAB:bigdata:array:AssertTabularAdaptorFromType', ...
            'Cannot create timetable adaptor from type name alone.');
    case {'datetime', 'duration', 'calendarDuration'}
        out = matlab.bigdata.internal.adaptors.DatetimeFamilyAdaptor(typeName);
    case 'categorical'
        out = matlab.bigdata.internal.adaptors.CategoricalAdaptor();
    case 'string'
        out = matlab.bigdata.internal.adaptors.StringAdaptor();
    otherwise
        out = matlab.bigdata.internal.adaptors.GenericAdaptor(typeName);
end
end
