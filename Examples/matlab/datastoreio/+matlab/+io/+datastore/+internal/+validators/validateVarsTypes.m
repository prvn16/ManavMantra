function varsOrTypes = validateVarsTypes(varsOrTypes, propName, onConsturction, usingDefaults)
%VALIDATEVARSTYPES Validates variable names and types
%   This is a helper function that validates the VariableNames,
%   SelectedVariableNames, TextscanFormats, SelectedFormats, VariableTypes,
%   SelectedVariableTypes.

%   Copyright 2015-2016 The MathWorks, Inc.

    % imports
    import matlab.io.internal.validators.isString;
    import matlab.io.internal.validators.isCellOfStrings;
    
    % validate arguments
    if nargin < 3
        onConsturction = false;
        usingDefaults = {};
    end
    
    if nargin < 4
        usingDefaults = {};
    end
    
    % error for cases when {} is explicitly passed during construction
    if onConsturction
        isDefault = isequal(varsOrTypes, {});
        if isDefault
            if ~ismember(propName, usingDefaults)
                error(message('MATLAB:datastoreio:tabulartextdatastore:invalidStrOrCellStr', propName));
            end
            return;
        end
    end
    
    % '', {}, [] must error, {} passed during construction already handled
    % above
    if isempty(varsOrTypes)
        error(message('MATLAB:datastoreio:tabulartextdatastore:emptyVar', propName));
    end

    try
    	% make inputs cell arrays of strings, cellstr works on chars, cellstrs.
    	varsOrTypes = cellstr(varsOrTypes);
    catch
	    % inputs must be strings or cell array of strings
    	if ~isString(varsOrTypes) && ~isCellOfStrings(varsOrTypes)
        	error(message('MATLAB:datastoreio:tabulartextdatastore:invalidStrOrCellStr', propName));
    	end
    end
    
    
    % convert column vectors to row vectors
    varsOrTypes = varsOrTypes(:)';

    % inputs cannot contains empty elements
    if (any(cellfun('isempty', varsOrTypes)))
        error(message('MATLAB:datastoreio:tabulartextdatastore:cellWithEmptyStr', propName));
    end
end
