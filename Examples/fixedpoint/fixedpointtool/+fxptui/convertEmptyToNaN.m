function value = convertEmptyToNaN(value)
% CONVERTEMPTYTONAN Convert an empty value to NaN to be inserted in table.

% Copyright 2017 The MathWorks, Inc.

    if isempty(value)
        value = NaN;
    end
end

