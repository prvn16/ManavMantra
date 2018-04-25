function chars = stringToChar(strings)
% stringToChar Convert all instances of string to char vectors
%
%    OUTPUTS = stringToChar(INPUTS) converts all strings in INPUTS to
%    char vectors. INPUTS can be a char vector, an array of strings or
%    an heterogeneous cell array in which only string objects are
%    converted. Scalar strings are converted to char vectors. Arrays
%    of strings are converted to cell arrays of char vectors.

%    Copyright 2016-2017 The MathWorks, Inc.

if iscell(strings)
    chars = cellfun(@(x)convertToChar(x), strings,...
        'UniformOutput', false);
elseif isstring(strings)
    chars = convertToChar(strings);
else
    % Do nothing
    chars = strings;
end

%---------------------------------------------------------------------
function c = convertToChar(s)
if isstring(s)
    if isscalar(s)
        c = char(s);
    else
        c = arrayfun(@(x) {char(x)}, s);
    end
elseif iscell(s)
    c = cellfun(@(x) convertToChar(x), s,...
        'UniformOutput', false);
else
    c = s;
end
