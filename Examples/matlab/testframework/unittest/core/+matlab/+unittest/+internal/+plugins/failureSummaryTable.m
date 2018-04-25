function str = failureSummaryTable(headers, data)
%Undocumented.

% Copyright 2012-2015 The MathWorks, Inc.

import matlab.internal.display.wrappedLength;

% Table formatting constants
MARKER = 'X';
SPACE = ' ';
HORIZONTAL_SPACER = repmat(SPACE, 1, 2);
HALF_HORIZONTAL_SPACER = HORIZONTAL_SPACER(1:ceil(end/2));
ROW_DIVIDER_HEAVY = '=';
ROW_DIVIDER_LIGHT = '-';

if isempty(data)
    str = '';
    return;
end

paddedTableSize = cellfun(@numDisplayRows, data);
    function n = numDisplayRows(value)
        if ischar(value)
            n = 1;
            return;
        end
        n = numel(value);
    end

% Total number of display rows is given by the largest number of entries in
% each row plus one row for the headers
nRows = sum(max(paddedTableSize, [], 2)) + 1;

% Total number of display columns is twice the number of data rows to
% allow for space between each column
nCols = 2*size(data,2);

tableCell = repmat({''}, nRows, nCols);

% Fill in the column header names
tableCell(1,2:2:end) = headers;

% Fill in the whitespace in the table.
tableCell(:,1) = {HALF_HORIZONTAL_SPACER};
tableCell(:, 3:2:end) = {HORIZONTAL_SPACER};

% Fill in the data
lastEntryRow = false(nRows, 1);
currentTableRow = 2;
for rIdx = 1:size(data,1)
    for cIdx = 1:size(data,2)
        entry = data{rIdx, cIdx};
        if ischar(entry)
            tableCell{currentTableRow, 2*cIdx} = entry;
        elseif islogical(entry)
            if entry
                tableCell{currentTableRow, 2*cIdx} = MARKER;
            end
        else
            currentTableRow = currentTableRow - 1;
            for eIdx = 1:numel(entry)
                currentTableRow = currentTableRow + 1;
                tableCell{currentTableRow, 2*cIdx} = entry{eIdx};
            end
        end
    end
    currentTableRow = currentTableRow + 1;
    lastEntryRow(currentTableRow) = true;
end

% Find the maximum width of each column
columnWidths = zeros(1, nCols);
for idx = 1:nCols
    columnWidths(idx) = max(cellfun(@(str)ceil(wrappedLength(str)), tableCell(:,idx)));
end
totalTableWidth = sum(columnWidths);

% Pad each column to the same width
for rowIdx = 1:nRows
    for colIdx = 1:size(data,2)-1
        tableIdx = colIdx*2;
        width = columnWidths(tableIdx);
        if islogical(data{1,colIdx})
            padCentered(rowIdx, tableIdx, width);
        else
            padLeftAlign(rowIdx, tableIdx, width);
        end
    end
end

    function padLeftAlign(row, col, totalLength)
        tableCell{row,col} = [tableCell{row,col}, ...
            repmat(SPACE, 1, totalLength-numel(tableCell{row,col}))];
    end
    function padCentered(row, col, totalLength)
        spaces = repmat(SPACE, 1, totalLength-numel(tableCell{row,col}));
        tableCell{row,col} = [spaces(1:floor(end/2)), ...
            tableCell{row,col}, spaces(floor(end/2)+1:end)];
    end

% Convert the cell array to one big string, adding row dividers and newlines
dividerWidth = totalTableWidth + numel(HORIZONTAL_SPACER) - numel(HALF_HORIZONTAL_SPACER);
heavyDivider = repmat(ROW_DIVIDER_HEAVY, 1, dividerWidth);
lightDivider = repmat(ROW_DIVIDER_LIGHT, 1, dividerWidth);
str = [tableCell{1,:}];  % headers
str = sprintf('%s\n%s\n', str, heavyDivider);
for idx = 2:nRows
    % Print the divider for the previous entry
    if lastEntryRow(idx)
        str = sprintf('%s%s\n', str, lightDivider);
    end
    str = sprintf('%s%s\n', str, [tableCell{idx,:}]);
end
end

