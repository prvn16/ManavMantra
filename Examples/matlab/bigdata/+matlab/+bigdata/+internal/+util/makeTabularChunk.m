function t = makeTabularChunk(constructFcn, dataArgs, parameterArgs)
%MAKETABULARCHUNK Construct a chunk of table/timetable allowing for the fact
% that data arguments might include char arrays of height one.
%
% Syntax:
%  t = makeTabularChunk(@table,{dataArg1,..,dataArgN},{name1,value1,..});
%  t = makeTabularChunk(@timetable,{dataArg1,..,dataArgN},{name1,value1,..});
%
% This exists because table/timetable constructor errors if the data
% arguments include a char array of height one.

% Copyright 2017 The MathWorks, Inc.

assert(iscell(dataArgs) && iscell(parameterArgs), ...
    'Assertion failed: makeTabularChunk expects both dataArgs and parameterArgs to be cell arrays.');

isCharRow = false;
if numel(dataArgs) >= 1 && size(dataArgs{1}, 1) == 1
    isCharRow = cellfun(@ischar, dataArgs);
end

if any(isCharRow)
    % Convert all single row char arrays into cellstr scalars by wrapping
    % each enclosing cell in another layer of cell.
    dataArgs(isCharRow) = num2cell(dataArgs(isCharRow));
end

t = constructFcn(dataArgs{:}, parameterArgs{:});

if any(isCharRow)
    % Need to unpack the char arrays now that we can do that via property
    % manipulation.
    for idx = find(isCharRow)
        t.(idx) = t.(idx){1};
    end
end
