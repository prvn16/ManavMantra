function value = removeLineBreaksFromName(strValue)
% REMOVELINEBREAKSFROMNAME removes new line characters and replaces it with
% a space

% Copyright 2015 The MathWorks, Inc.

space = ' ';
newLineChar = char(10);
value = strrep(strValue, newLineChar, space);
end