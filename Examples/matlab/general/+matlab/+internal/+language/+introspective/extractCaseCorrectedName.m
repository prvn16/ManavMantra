function fixedName = extractCaseCorrectedName(fullName, subName)
    fixedNames = regexpi(fullName, ['\<' regexprep(subName, '\W*', '\\W*') '\>'], 'match');
    if isempty(fixedNames)
        fixedName = '';
    else
        fixedName = strrep(fixedNames{end}, '\', '/');
        fixedName = regexprep(fixedName, '(^|/)[@+]?', '$1');
    end
end

%   Copyright 2007 The MathWorks, Inc.
