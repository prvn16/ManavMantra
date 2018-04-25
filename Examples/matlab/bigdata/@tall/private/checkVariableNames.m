function checkVariableNames(names)
%CHECKVARIABLENAMES Helper function that checks the provided names are
%valid and contain no duplicates.

% Copyright 2016 The MathWorks, Inc.

names = names(:)';
if ~iscellstr(names) || any(cellfun(@isempty, names))
    error(message('MATLAB:table:InvalidVarNames'));
end

isGoodName = strcmp(names, matlab.lang.makeValidName(names));
if any(~isGoodName)
    idx = find(~isGoodName, 1, 'first');
    error(message('MATLAB:table:VariableNameNotValidIdentifier', names{idx}));
end

isUniqueName = strcmp(names, matlab.lang.makeUniqueStrings(names));
if any(~isUniqueName)
    idx = find(~isUniqueName, 1, 'first');
    error(message('MATLAB:table:DuplicateVarNames', names{idx}));
end
