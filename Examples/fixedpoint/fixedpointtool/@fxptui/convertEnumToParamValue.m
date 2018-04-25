function paramValue = convertEnumToParamValue(paramName, enum)
%CONVERTSTRINGTOPARAMVALUE <short description>
%   OUT = CONVERTSTRINGTOPARAMVALUE(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

switch paramName
    case 'DataTypeOverride'
        switch enum
            case 0
                paramValue = 'UseLocalSettings';
            case 1
                paramValue = 'ScaledDouble';
            case 2
                paramValue = 'Double';
            case 3
                paramValue = 'Single';
            case 4
                paramValue = 'Off';
        end
    case 'MinMaxOverflowLogging'
        switch enum
            case 0
                paramValue = 'UseLocalSettings';
            case 1
                paramValue = 'MinMaxAndOverflow';
            case 2
                paramValue = 'OverflowOnly';
            case 3
                paramValue = 'ForceOff';
        end
   
    case 'DataTypeOverrideAppliesTo'
        switch enum
            case 0
                paramValue = 'AllNumericTypes';
            case 1
                paramValue = 'Floating-point';
            case 2
                paramValue = 'Fixed-point';
        end
end



% [EOF]
