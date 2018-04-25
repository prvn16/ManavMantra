function data = getData(this, query, resultIds)
% GETDATA returns the rows to be sent to the client based on the sort
% column and position of the cursor

% Copyright 2017 The MathWorks, Inc.

data.rows = [];
data.total = 0;
% The Range/Proposal properties are used to manage the toolstrip state on the UI
data.resultsHaveSimRange = any(this.ResultDatabase.runHasSimRange);
data.resultsHaveDeriveRange = any(this.ResultDatabase.runHasDeriveRange);
data.resultsHaveProposals = any(this.ResultDatabase.runHasProposals);

this.SortProperty = query.SortColumn;
this.SortDirection = query.SortDir;

tableSubsysIds = this.ResultDatabase.id;

scopedIdx = false(numel(tableSubsysIds), 1);
for i = 1:numel(resultIds)
    scopedIdx = scopedIdx | strcmp(tableSubsysIds, resultIds{i});
end

% Extract the data for the runs that are enabled on the client
hiddenIdx = false(height(this.ResultDatabase), 1);
for i = 1:numel(query.HiddenRuns)
    hiddenRun = query.HiddenRuns(i);
    hiddenIdx = hiddenIdx | strcmp(this.ResultDatabase.Run, hiddenRun);
end

% Get the sub table with the result Ids specified, unhidden runs and rows
% having interesting information
subTableIdx = scopedIdx & ~hiddenIdx & this.ResultDatabase.hasInterestingInformation;
scopedTable = this.ResultDatabase(subTableIdx, :);

% Extract the column to be sorted.
toBeSorted = scopedTable.(query.SortColumn);

tableHeight = height(scopedTable);

this.LastScopedTable = scopedTable;
[~, this.LastSortIndices] = sortrows(toBeSorted, lower(query.SortDir));

% Extract the data from the table based on the start/end indices requested.
startIndex = query.StartIndex;
endIndex = startIndex + query.Count;
if endIndex > tableHeight
    endIndex = tableHeight;
end
data.total = tableHeight;
if startIndex > 0 && endIndex > 0
    if startIndex <= endIndex
        range = this.LastSortIndices(startIndex:endIndex);
        data.rows = scopedTable(range, this.SpreadsheetProperties);
    end
end
end
