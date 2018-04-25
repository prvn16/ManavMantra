function [omitnan,flag] = validateMissingOption(option)

%   Copyright 2015 The MathWorks, Inc.

s = strncmpi(option, {'omitnan' 'omitnat' 'includenan' 'includenat'}, max(length(option),1));
if s(1) || s(2)
    omitnan = true;
    flag = 'omitnan';
elseif s(3) || s(4)
    omitnan = false;
    flag = 'includenan';
else
    throwAsCaller(MException(message('MATLAB:datetime:UnknownNaNFlag')));
end

