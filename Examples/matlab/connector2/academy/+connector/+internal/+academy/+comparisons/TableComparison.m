classdef TableComparison < connector.internal.academy.comparisons.Comparison
    methods
        function cObj = TableComparison(v1,v2,solVarName,submissionVarName)
            cObj.solutionVar = v1;
            cObj.submissionVar = v2;            
            cObj.solVarName = solVarName;
            cObj.submissionVarName = submissionVarName; 
        end
    end
    
    methods
        function feedback = generateFeedback(cObj)
            import connector.internal.academy.i18n.FeedbackTemplates;
            % check if all the column names match and are in the right order
            expectedColumns = cObj.solutionVar.Properties.VariableNames;
            actualColumns = cObj.submissionVar.Properties.VariableNames;
            if ~isequaln(expectedColumns,actualColumns)
                % Columns are not in right order
                if isempty(setdiff(expectedColumns,actualColumns))
                   feedback = ['<br/>' FeedbackTemplates.language.templates.incorrectTableVariableOrder];
                    % Column names have wrong case
                elseif all(strcmpi(expectedColumns,actualColumns))
                    feedback = ['<br/>' FeedbackTemplates.language.templates.tableVariableCapitalizationIssue];
                end
            else
                % Find which columns have wrong values
                numColumns = size(cObj.solutionVar,2);
                colEqIdx = false(1,numColumns);
                for i=1:size(cObj.solutionVar,2)
                    colEqIdx(i) = isequaln(cObj.solutionVar{:,i},cObj.submissionVar{:,i});
                end
                if ~all(colEqIdx)
                    tvlist = sprintf(['<br/>' repmat('-%s<br/>',1,(nnz(~colEqIdx)))],expectedColumns{~colEqIdx});
                    feedback = ['<br/>' FeedbackTemplates.constructFeedback('checkTableVariableValues',...
                        tvlist)];
                end
            end
        end
    end
end
