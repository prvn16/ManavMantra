function displayNonScalarObject(obj)
%DISPLAYNONSCALAROBJECT    Display a non-scalar Setting object

%   Copyright 2015-2018 The MathWorks, Inc.

    % construct a string for dimensions
    dimStr = matlab.mixin.CustomDisplay.convertDimensionsToString(obj);
    % display header line for an array of Setting objects.
    settingHeader =  matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
    sp = matlab.internal.display.formatSpacing;

    if strcmp(sp,'loose')
        cr = newline;
    else
        cr = '';
    end
    m = message('MATLAB:ObjectText:DISPLAY_ARRAY_WITH_NO_PROPS', dimStr, settingHeader); 
    fprintf('%s%c%c', getString(m), cr, newline);

end
