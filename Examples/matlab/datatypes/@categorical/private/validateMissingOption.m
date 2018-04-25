function [omitUndefined,option] = validateMissingOption(option)

%   Copyright 2017 The MathWorks, Inc.

s = strncmpi(option, {'includenan' 'includeundefined' 'omitnan' 'omitundefined'}, max(length(option),1));
if s(1) || s(2) % 'includenan' or 'includeundefined'
    omitUndefined = false;
    option = 'includenan';
else
    omitUndefined = true;
    if s(3) || s(4) % 'omitnan' or 'omitundefined'
        option = 'omitnan';
    else
        % leave any other string, or DIM, alone
    end
end