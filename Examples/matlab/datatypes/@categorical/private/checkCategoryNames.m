function names = checkCategoryNames(names,dupFlag)
%CHECKCATEGORYNAMES Validate a list of category names.

%   Copyright 2013-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

% Allow 0x0 or 1x0 char, but not 0x1 or any other empty char
if isCharString(names)
    names = strtrim({names});
elseif matlab.internal.datatypes.isCharStrings(names)
    names = strtrim(names(:)); % force cellstr to a column
else
    throwAsCaller(msg2exception('MATLAB:categorical:InvalidNames', upper(inputname(1))));
end

if any(strcmp(categorical.undefLabel,names))
    throwAsCaller(msg2exception('MATLAB:categorical:UndefinedLabel', upper(inputname(1)), categorical.undefLabel));
elseif any(strcmp(categorical.missingLabel,names))
    throwAsCaller(msg2exception('MATLAB:categorical:UndefinedLabel', upper(inputname(1)), categorical.missingLabel));
elseif any(strcmp('',names))
    throwAsCaller(msg2exception('MATLAB:categorical:EmptyName', upper(inputname(1))));
end

if dupFlag > 0 && length(names) > 1
    [sortedCategories,ord] = sort(names);
    d = [true; ~strcmp(sortedCategories(2:end),sortedCategories(1:end-1))];
    if ~all(d)
        switch dupFlag
        case 1 % remove duplicate names
            names = names(sort(ord(d))); % leave in original order
        case 2 % error if any duplicate names
            throwAsCaller(msg2exception('MATLAB:categorical:DuplicateNames', upper(inputname(1))));
        end
    end
end
