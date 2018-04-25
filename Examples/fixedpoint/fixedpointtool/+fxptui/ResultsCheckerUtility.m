classdef ResultsCheckerUtility < handle
    %RESULTHANDLER handles the results in a model
    %  provides helper functions to check results for certain properties 
    %  and take necessary action in a model
    
    % Copyright 2016 The MathWorks, Inc.
    
  methods(Static) 
        
        function b = hasUnacceptedProposals(mdl, run)
            %HASUNACCEPTEDFL return a boolean value
            % check if the results have ProposedDT and applicable proposals for a given run in a model
            b = false;
            allDatasets = fxptds.getAllDatasetsForModel(mdl);
            results = fxptui.ResultsCheckerUtility.getResults(allDatasets, run);
            
            for r = 1:numel(results)
                if (results{r}.hasApplicableProposals)
                    b = true;
                    break;
                end
                
            end
            
        end
        
        function b = hasProposedDT(mdl, run)
            % check if the results have ProposedDT for a given run in a model
            b = false;
            allDatasets = fxptds.getAllDatasetsForModel(mdl);
            results = fxptui.ResultsCheckerUtility.getResults(allDatasets, run);
            
            for r = 1:numel(results)
                if(results{r}.hasProposedDT)
                    b = true;
                    break;
                end
                
            end
            
        end
        
        function results = getResults(datasets, run)
            % return the results associated with all datasets in a given model           
            results = [];
            
            for idx = 1:length(datasets)
                runObj = datasets{idx}.getRun(run);
                getResultsForDataSet = runObj.getResultsAsCellArray();     
                results = [results getResultsForDataSet];  %#ok<AGROW>
            end
            
        end    
        
        function results = getResultsFromAllRuns(datasets)
            % return the results from all the runs associated with 
            % all datasets in a given model           
            results = [];
            
            for idx = 1:length(datasets) 
                resultsForDataset = datasets(idx).getResultsFromRuns;    
                results = [results resultsForDataset];  %#ok<AGROW>
            end
            
        end       
        
    end
    
end

