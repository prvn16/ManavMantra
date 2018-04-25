function isDefault = validateFileExtensions(fileExtensions, usingDefaults)
%validateFileExtensions  Validates file extensions and returns true if
%fileExtensions are the default (-1)
%   This function is responsible to validate file extensions and also
%   return a boolean indicating if the file extensions are the default or
%   specified.

%   Copyright 2015-2016 The MathWorks, Inc.

    % imports
    import matlab.io.internal.validators.isString;
    import matlab.io.internal.validators.isCellOfStrings;
    
    % handle the default case
    isDefault = isequal(fileExtensions, -1);
    if isDefault
        if ~ismember('FileExtensions', usingDefaults)
            error(message('MATLAB:datastoreio:datastore:invalidFileExtensions'));
        end
        return;
    end
    
    % validate for strings or cellstrs
    if isString(fileExtensions)
        fileExtensions = {fileExtensions};
    end
    if isCellOfStrings(fileExtensions) && ~isempty(fileExtensions)
        emptyIdxs = strcmpi(fileExtensions, '');
        if all(cellfun(@(x) (x(1)=='.'),fileExtensions(~emptyIdxs)))
            return;
        end
    end
    error(message('MATLAB:datastoreio:datastore:invalidFileExtensions'));
end
