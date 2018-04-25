function tf = isScalarText(txt,allowEmptyOrMissing)
%ISSCALARTEXT True for a scalar text value
%   TF = ISSCALARTEXT(TXT) returns true if TXT is a scalar text value, i.e.
%   * a scalar string
%   * a 1xN character vector
%   * the 0x0 char array ''
%
%   TF = ISSCALARTEXT(S,FALSE) returns true only if TXT is a non-empty
%   non-missing text, i.e.
%   * a scalar string not equal to "", all spaces, or <missing>
%   * a 1xN character vector for N > 0, not all spaces

%   Copyright 2017 The MathWorks, Inc.

if nargin < 2 || allowEmptyOrMissing % allow empty or missing
    if isstring(txt)
        tf = isscalar(txt);
    else
        tf = ischar(txt) && (isrow(txt) || isequal(txt,'')); % empty and missing same for char
    end
else % do not allow empty or missing
    if isstring(txt)
        tf = isscalar(txt) && ~ismissing(txt) && ~all(isspace(txt));
    else
        tf = ischar(txt) && isrow(txt) && ~all(isspace(txt));
    end
end
