function packageData(this, runName, results, resultRenderingOrder)
%% PACKAGEDATA API  is responsible for interacting with Visualizer Engine to query for data matching the given results 
% and packaging them to JS Client suitable struct

%   Copyright 2016 The MathWorks, Inc.

    % Query data 
    [tableData, Zero, GlobalYLimit, WouldBeOverflows] = this.collectData(runName, results, resultRenderingOrder);

    if ~isempty(tableData)
        % Concatenate ResultId, ContainerType.DTString, HasOverflows,
        % HasUnderflows, RGB, YLimits
        % Get Result Id 
        resultId = tableData.ResultId;

        % UniqueKey and Object class required for highlighting spreadsheet
        % row clicking on a visualizer signal
        % Get uniqueKey 
        uniqueKey = {tableData.ClientData.ResultId}';
        
        % Get object class
        objectClass = {tableData.ClientData.ObjectClass}';
        
        % Get result name 
        resultName = {tableData.ClientData.ResultName}';
        
        % Get all containers
        containers = {tableData.ContainerType.origDTString}';

        % Get WholeNumber information
        wholeNumber = tableData.IsAlwaysWholeNumber;
        wholeNumber = num2cell(wholeNumber);

        % Get overflows
        overflows = tableData.HasOverflows;
        overflows = num2cell(overflows);

        % Update overflow counts
        overflowCounts = tableData.OverflowCounts;
        overflowCounts = num2cell(overflowCounts);
        
        % Get underflows
        underflows = tableData.HasUnderflows;

        % Get RGB data
        RGB = tableData.RGB;

        % Get YLimits
        YLimits = tableData.YLimits;

        % Sort result names and use the sorted order to display the initial
        % visualization of data
        resultNames = [resultName{:}];
        [~, sortedIndices] = sort(resultNames);
        
        % Cache away the struct as this.Data
        this.Data = cell(numel(sortedIndices), 1);
        
        for idx = 1:numel(sortedIndices)
            sortedIndex = sortedIndices(idx);
            this.Data{idx} = struct('Id', resultId{sortedIndex}, ...
                                        'ResultId', uniqueKey{sortedIndex}, ...
                                        'ObjectClass', objectClass{sortedIndex},...
                                        'Name', resultName{sortedIndex}, ...
                                        'DTString', containers{sortedIndex}, ...
                                        'WholeNumber', wholeNumber{sortedIndex}, ...
                                        'ActualOverflows', overflows{sortedIndex}, ...
                                        'OverflowCounts', overflowCounts{sortedIndex}, ...
                                        'PotentialOverflows', WouldBeOverflows{sortedIndex}, ...
                                        'PotentialUnderflows', underflows{sortedIndex}, ...
                                        'RGB', flipud(RGB{sortedIndex}'), ...
                                        'YLimits', YLimits{sortedIndex});
        end 
        % Concatenate ZERO bin, Global Ylimit, number of records and total
        % number of transactions into MetaData
        
        % Flip Global Limits as RGB is rendered flipped up and down in
        % visualization 
        actualGlobalYLimits = GlobalYLimit;
        flippedBins = flipud((1:256)');
        maxBin = find(flippedBins == min(actualGlobalYLimits(1)));
        minBin = find(flippedBins == max(actualGlobalYLimits(2)));
        ylimitsFlippedUD = sort([maxBin, minBin]);

        % Cache away the struct as this.MetaData
        RGBMetaData = struct('ZERO', Zero, 'GlobalYLimit', ylimitsFlippedUD, 'YAxisLimits', GlobalYLimit, 'RunName', runName );
        this.MetaData = struct('NumRecords', size(tableData, 1), 'NumTransactions', 1, 'MetaData', RGBMetaData);
    else
        this.Data = [];
        this.MetaData =[];
    end
end