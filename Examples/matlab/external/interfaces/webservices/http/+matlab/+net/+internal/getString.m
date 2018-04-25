function str = getString(value, funcName, varName, allowEmpty, additionalTypes)
% getString Utility to check that value is a scalar string or char row vector and
% return value as a string.  If input is an empty char array (e.g., ''), returns "".
% Input of <missing> treated same as string.empty.
%
%     varName    (optional) we say "input" in error messages if missing
%     allowEmpty (optional) if set, returns "" for any empty array.  Otherwise
%                errors on empty or <missing> non-char array.
%     additionalTypes (optionsl) cell array of additional types to
%        mention in error message if value is not string or char
%
%   Note: does not trim value.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http.  Its behavior
%   may change, or the function itself may be removed in a future release.


% Copyright 2015-2016 The MathWorks, Inc.

    if isstring(value) && isscalar(value) && ismissing(value)
        value = string.empty;
    end
    if nargin > 3 && allowEmpty && isempty(value)
        str = "";
    else
        if nargin < 3
            varName = 'input';
        end
        if isstring(value)
            % Rule out nonscalar string arrays: rejects string.empty() but not
            % "".  Only 'scalar' will be mentioned in error message since
            % type agrees.
            validateattributes(value, {'string'}, {'scalar'}, funcName, varName);
            str = value;
        else
            % not a string
            % Allow empty char vectors
            if ~ischar(value) || ~isempty(value)
                % Otherwise, allow only char row vectors.  We mention 'string' here
                % just for the error message when type isn't string or char.
                types = {'char','string'};
                if nargin > 4
                    types = [types additionalTypes];
                end
                validateattributes(value, types, {'row'}, funcName, varName);
            end
            str = string(value);
        end
    end
end
