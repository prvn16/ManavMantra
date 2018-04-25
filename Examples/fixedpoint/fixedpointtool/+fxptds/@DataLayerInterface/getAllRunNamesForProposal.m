function runNames = getAllRunNamesForProposal(this, dataset)
    % GETALLRUNNAMESFORPROPOSAL this function returns all the run names in
    % the dataset that have valid results and are not embedded
    
    % Copyright 2017 The MathWorks, Inc.
    
    runNames = this.getAllRunNamesWithResults(dataset);
    embeddedRunNames = dataset.EmbeddedRunNames;
    
    % remove all run names that have been marked as embedded
    for rIndex = 1:numel(embeddedRunNames)
        indices = ismember(runNames, embeddedRunNames{rIndex});
        if any(indices)
            runNames(indices) = '';
        end
    end
end