function strs = getStringVector(value, funcName, varName, allowEmpty, additionalTypes)
% getStringVector Utility to check that value is a string, string vector,
% cellstr or cell array of strings.  An empty string is allowed but [] is not.
%  
%   Returns a string vector, which may be empty or have empty strings in it.
%     value              the value to check
%     funcName, varName  input to validateattributes for error messages
%     allowEmpty         (optional) if set, [] in cell or <missing> in string treated 
%                        as '' (default false)
%     additionalTypes    (optional) additional allowed types to display in error 
%                        message when value is bad (not processed by this function)
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

    % Copyright 2015-2016 The MathWorks, Inc.
    varName = char(varName);
    if isstring(value)
        % if string, must be empty or a vector
        if ~isempty(value)
            validateattributes(value, {'string'}, {'vector'}, funcName, varName);
        end
        % must not contain <missing> unless allowEmpty is set
        hasMissing = false;
        if (nargin < 4 || ~allowEmpty) 
            hasMissing = any(ismissing(value));
            if hasMissing
                % this forces a "expected to be nonempty" message
                validateattributes(string.empty, {'string'}, {'nonempty'}, funcName, varName);
            end
        end
        % Now if array contains any <missing>, allowEmpty must be set, so set
        % <missing> members to "".  Don't do this for empty value because of g1459420,
        % which incorrectly changes the dimension (e.g., string.empty(0,0) becomes 1x0)
        if hasMissing && ~isempty(value)
            value(ismissing(value)) = "";
        end
        strs = value;
    elseif iscellstr(value)
        % all cellstrs good
        strs = string(value);
    elseif ischar(value)
        % if char, must be '' or a row
        if ~isempty(value)
            validateattributes(value, {'char'}, {'row'}, funcName, varName);
        end
        strs = string(value);
    else
        % It's not a string, cellstr or char.  
        % If we should allow [] in cell, check that all cells are char vectors or []
        if ~exist('additionalTypes','var')
            additionalTypes = {};
        end
        if iscell(value) && isvector(value)
            import matlab.net.http.internal.*;
            if nargin < 4
                allowEmpty = false;
            end
            len = numel(value);
            strs(len) = "";
            for i = 1 : len
                strs(i) = matlab.net.internal.getString(value{i}, funcName, [varName '(' num2str(i) ')'], allowEmpty, additionalTypes);
            end
        else
            % Since we know it's bad, just use validateattributes to list the types.
            types = [{'char vector', 'string vector', 'cell array of strings'} additionalTypes];
            validateattributes(value, types, {}, funcName, varName);
        end
    end
end
