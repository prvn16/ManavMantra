function names = keyChoices(t)

%   Copyright 2017 The MathWorks, Inc.

% Return the row dim name only if the tabular has row labels: all
% timetables, but only some tables

suggestRowDimName = isa(t,'timetable') || ~isempty(t.Properties.RowNames);

if suggestRowDimName
    names = [t.Properties.DimensionNames{1} t.Properties.VariableNames];
else
    names = t.Properties.VariableNames;
end

