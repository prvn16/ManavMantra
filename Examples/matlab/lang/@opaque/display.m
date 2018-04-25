function display(opaque_array, varname)
%DISPLAY Display a Java object.

%   Copyright 1984-2017 The MathWorks, Inc.

    %Deal with format spacing
    loose = strcmp(matlab.internal.display.formatSpacing, 'loose');
    if loose
        linefeed = newline;
    else
        linefeed = '';
    end

    %varname or 'ans ='
    if nargin < 2
        varname = inputname(1);
    else
        varname = convertStringsToChars(varname);
    end

    %Suppress "ans =" if no varname provided and inputname returns empty 
    if ~isempty(varname)
        header = [linefeed, varname, ' =', linefeed];
        disp(header);
    end

    if ~isjava(opaque_array) && isempty(opaque_array)
        dimString = matlab.internal.display.dimensionString(opaque_array);
        classname_header = [dimString, ' empty ',class(opaque_array)];
        disp(['    ',classname_header,linefeed]);
    end
    try 
        %This try/catch is needed because objects may overload disp but not
        %display, and rely on display to call the builtin disp if the object's
        %disp method errors.  This behavior is relied upon.
        disp(opaque_array);
    catch exc %#ok<NASGU>
        builtin('disp', opaque_array);
    end
end





