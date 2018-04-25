function rowIds = queryTable(tableToScan, queryingRecord)
%% QUERYTABLE function constructs a char array describing the querystring to look for rows in ScopingTable.
%
% queryingTable is a struct which contains the same fields as fxptds.FPTGUIScopingTableFactory.getTemplateObject method
% rowIds is a double array of row indices that can be indexed into
% ScopingTable member that match the querying criteria in queryingRecord
% input
%

%   Copyright 2016 The MathWorks, Inc.

    numberOfRows = size(tableToScan, 1);
    matchingIndices = zeros(numberOfRows, 1);
    
    numFieldsQueried = 0;
    
    % query for all field names
    fieldNames = fieldnames(queryingRecord);
    for idx=1:numel(fieldNames)
        % for each field value, query the table and narrow results
        fieldName = fieldNames{idx};
        fieldValue = queryingRecord.(fieldName);
        
        % if field value is non empty, look for rows that metch the
        % criteria
        if ~isempty(fieldValue) && ~isempty(tableToScan)
             % Increase the number of fields queried if field Value is not
             % empty
             numFieldsQueried = numFieldsQueried + 1;
             
             fieldColumn = tableToScan.(fieldName);
             
             newMatchingIndices = ismember(fieldColumn, fieldValue);
             
             % find intersect of matching indices
             matchingIndices = newMatchingIndices +  matchingIndices;
        end
    end
    
    rowIds = find(matchingIndices == numFieldsQueried);
end