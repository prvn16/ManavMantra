function tf = validateLogicalOption(tf, errormessage)
%VALIDATELOGICALOPTION Check if the given option is logical
%   The input can be a numeric value which will be cast
%   to a logical value.
%
%   See also matlab.io.datastore.internal.validators.isNumLogical.

%   Copyright 2017 The MathWorks, Inc.
    import matlab.io.datastore.internal.validators.isNumLogical
    if ~isNumLogical(tf)
        error(message(errormessage));
    end
    tf = logical(tf);
end
