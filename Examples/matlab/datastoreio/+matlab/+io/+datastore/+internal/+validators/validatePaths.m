function pths = validatePaths(pths)
%VALIDATEPATHS Validates the input paths.

%   Copyright 2015-2017 The MathWorks, Inc.

    % imports
    import matlab.io.internal.validators.isString;
    import matlab.io.internal.validators.isCellOfStrings;

    % empty cell array {} is a valid input
    if iscell(pths) && isempty(pths)
        return;
    end

    try
        % make inputs cell arrays of strings, cellstr works on chars, cellstrs.
        pths = cellstr(pths);
    catch
        % inputs must be strings or cell array of strings (vector)
        if ~isString(pths) && ~isCellOfStrings(pths)
            error(message('MATLAB:datastoreio:pathlookup:invalidStrOrCellStr', ...
                                                                 'Files'));
        end
    end
    
    % inputs cannot contains empty elements
    if (any(cellfun('isempty', pths)))
        error(message('MATLAB:datastoreio:pathlookup:cellWithEmptyStr', ...
                                                                 'Files'));
    end
end
