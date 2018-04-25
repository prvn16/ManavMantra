function [variableName, subscript, err] = validateTableSubscript(tbl, subscript, propName)
% This is an undocumented function and may be removed in a future release.

% Validate that a table subscript is valid and refers to a single variable
% in the table. Upon success return a character vector with the variable
% name. Upon failure, return the MException to throw.

%   Copyright 2016-2017 The MathWorks, Inc.

% Default return values.
variableName = '';
err = MException.empty();

% The property name is only used for error messages, so if no property name
% was specified, use an empty string.
if nargin < 3
    propName = '';
end

% Table does not yet support strings as subscripts.
if isstring(subscript)
    if isscalar(subscript)
        subscript = char(subscript);
    else
        subscript = cellstr(subscript);
        err = MException(message('MATLAB:Chart:NonScalarTableSubscript', propName));
    end
end

% We can do some initial validation of the subscript even without the
% table.
if iscellstr(subscript) || isnumeric(subscript)
    % Numeric vectors or cell arrays of character vectors must be scalar.
    if numel(subscript)>1
        err = MException(message('MATLAB:Chart:NonScalarTableSubscript', propName));
    end
elseif islogical(subscript)
    % Logical vectors must select only a single element.
    if sum(subscript)~=1
        err = MException(message('MATLAB:Chart:NonScalarTableSubscript', propName));
    end
elseif isempty(err) && ischar(subscript)
    % Character vectors must be legal variable names.
    if ~isempty(subscript) && ~isvarname(subscript)
        err = MException(message('MATLAB:Chart:InvalidTableSubscript', propName));
    end
end

% Attempt to generate a subtable based on the supplied subscript to
% determine whether it is a valid subscript and whether it refers to a
% single variable.
if isempty(err) && width(tbl)>0 && ~isempty(subscript)
    try
        subTable = tbl(:,subscript);
        if size(subTable, 2) ~= 1
            % Subscript referred to multiple variables in the table.
            err = MException(message('MATLAB:Chart:NonScalarTableSubscript', propName));
        else
            % Copy the variable name for use later.
            variableName = subTable.Properties.VariableNames{1};
            
            % Make sure that the table variable is a single column of data.
            % Any empty variable can be either [0 x 1] or [0 x 0], but not [0 x 2].
            % Character matrices can be any width.
            sz = size(subTable.(variableName));
            if (numel(sz) > 2) || (~ischar(subTable.(variableName)) && (sz(2) ~= 1 && ~all(sz==0)))
                variableName = '';
                err = MException(message('MATLAB:Chart:NotColumnVector', propName));
            end
        end
    catch tableErr
        % Subscript was invalid.
        % MException returned to the caller.
        
        % If working with a timetable, the 'RowTimes' vector cannot be used
        % as a table subscript.
        if strcmp(tableErr.identifier, 'MATLAB:table:UnrecognizedVarName') && ...
                isa(tbl,'timetable') && ...
                strcmp(tbl.Properties.DimensionNames{1}, subscript)
            err = MException(message('MATLAB:Chart:RowTimesNotSupported'));
        else
            % Subscript was not found in the table.
            err = MException(message('MATLAB:Chart:TableSubscriptInvalid', propName));
            
            % Create a new MException to clear the stack.
            tableErr = MException(tableErr.identifier, tableErr.message);
            err = err.addCause(tableErr);
        end
    end
end

end
