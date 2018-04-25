function args = convertStringToCharArgs(args)
% This undocumented function may be removed in a future release.

% This function converts a cell array containing strings values, or a string
% array, to a cell array of character vectors. To convert a scalar string to a
% character vector use the char function. This function is necessary
% because various functions (like set, get, etc.) do not currently
% accept strings.

% Copyright 2017 MathWorks, Inc.

if isstring(args)
    % convertStringsToChars - Converts a string array to a cell array of char vectors.
    args = convertStringsToChars(args);
elseif iscell(args)
    % The following converts a cell array containing string arrays to a
    % cell array of char arrays.
    [args{:}] = convertStringsToChars(args{:});
end

end