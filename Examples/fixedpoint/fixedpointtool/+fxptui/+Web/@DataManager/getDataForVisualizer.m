function data = getDataForVisualizer(this, query, queryRunName)
% GETDATAFORVISUALIZER returns the rows to be sent to the client based on the sort
% column and position of the cursor

% Copyright 2017 The MathWorks, Inc.
    
    data.rows = [];
    data.total = 0;

    this.SortProperty = query.SortColumn;
    this.SortDirection = query.SortDir;
    
    % Extract the data for the runs that are enabled on the client
    isRunHidden = false;
    for i = 1:numel(query.HiddenRuns)
        hiddenRun = query.HiddenRuns(i);
        if strcmp(queryRunName, hiddenRun)
            isRunHidden = true;
            break;
        end
    end
    % Another server side hack to ensure, data is not sent for hidden runs
    % when a query to DataManager is done on Dgrid store refresh.
    if isRunHidden
        data.total = 0;
        data.rows = [];
    else
        % Fetch all results that map to the given run
        matchingIndices = strcmpi(this.ResultDatabase.Run, queryRunName);
        dataForLastUpdatedRun = this.ResultDatabase(matchingIndices, :);

        % Extract the column to be sorted and get the sorted order of results 
        toBeSorted = dataForLastUpdatedRun.(query.SortColumn);
        tableHeight = height(dataForLastUpdatedRun);

        [~, sortedIndices] = sortrows(toBeSorted, lower(query.SortDir));

        % Reorder the filtered results in the same sorted order
        data.total = tableHeight;
        data.rows = dataForLastUpdatedRun(sortedIndices, this.VisualizerProperties);     
    end
end
