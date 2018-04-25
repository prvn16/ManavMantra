function displayProperties(clz, propNames)
% Helper to display a list of properties for a given class

%   Copyright 2016-2017 The MathWorks, Inc.

formatSpacing = get(0,'FormatSpacing');
if isequal(formatSpacing,'compact')
    sep = '';
else
    sep = newline;
end

if isempty(propNames)
    fprintf('%s%s%s\n', sep, getString(message(...
        'MATLAB:ClassUstring:PROPERTIES_FUNCTION_NO_PROPS_LABEL', clz)), sep);
else
    fprintf('%s%s%s\n', sep, getString(message(...
        'MATLAB:ClassUstring:PROPERTIES_FUNCTION_LABEL',clz)), sep);
    fprintf('    %s\n', propNames{:});
    fprintf('%s', sep);
end
