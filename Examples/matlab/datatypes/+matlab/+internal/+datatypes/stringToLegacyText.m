function s = stringToLegacyText(s,scalarCellOutput)
%STRINGTOLEGACYTEXT Convert string array to char or cellstr.
%    S = STRINGTOLEGACYTEXT(S) converts the string array S to a char row vector,
%    if S is a scalar, or to a cellstr, if S is not a scalar. If S is not a
%    string array, it is returned as is. Missing strings are converted into the
%    empty character vector, ''.
%
%    S = STRINGTOLEGACYTEXT(S,TRUE) always converts a string array S to cellstr,
%    even if S is a scalar. If S is a char row vector, STRINGTOLEGACYTEXT(S,TRUE)
%    does not convert it to a scalar cellstr.

%   Copyright 2017 The MathWorks, Inc.

if isstring(s)
    % Convert missing string to empty string so that they can be converted into
    % empty character vectors.
    s(ismissing(s)) = "";
    
    if isscalar(s)
        if nargin < 2 || ~scalarCellOutput
            s = char(s);
        else
            s = cellstr(s);
        end
    else % cellstr instead of character matrix
        s = cellstr(s);
    end
end
