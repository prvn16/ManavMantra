function displayCellArrayAsTable(encodedCell, variableNames)

% Copyright 2014 The MathWorks, Inc.

tags = cellfun(@char, encodedCell, 'UniformOutput', false);
t = cell2table(tags, 'VariableNames', variableNames);
disp(t);

end
