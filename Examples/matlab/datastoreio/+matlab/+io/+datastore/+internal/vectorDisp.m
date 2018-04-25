function vectorStr = vectorDisp(vector)
% vectorDisp helper function to extract vector values and
% display some elements.
% Supported types:
%    1. categorical
%    2. logical
%    3. numerical
%

%   Copyright 2015 The MathWorks, Inc.

% maximum number of elements we display.
MAX_ELEMENTS_DISPLAYED = 3;

ind = MAX_ELEMENTS_DISPLAYED;
numItems = numel(vector);
if numItems < ind
   ind = numItems;
end

% extract values to display
values = vector(1:ind);

stringSeparator = ', ';
if iscolumn(vector)
    % if a column vector, display with a semicolon ';'.
    stringSeparator = '; ';
    % Display like a row vector
    values = values';
end
vectorC = class(vector);
switch vectorC
    case 'categorical'
        vectorStr = cellstr(values);
        vectorStr = strjoin(vectorStr, stringSeparator);
    otherwise
        vectorStr = mat2str(values);
        vectorStr = strrep(vectorStr, ' ', stringSeparator);
        % remove surrounding square braces: '[' and ']'
        vectorStr = vectorStr(2:end-1);
end
appendStr = ']';
if numItems > ind
    % just display number of remaining elements
    remaining = num2str(numItems - ind);
    % display the vector type only when numItems more than MAX_ELEMENTS_DISPLAYED
    appendStr = [' ... and ', remaining, ' more ', vectorC, appendStr];
end
vectorStr = ['[', vectorStr, appendStr];
