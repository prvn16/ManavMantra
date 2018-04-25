classdef BasicSizeComparison < connector.internal.academy.comparisons.Comparison
    methods
        function cObj = BasicSizeComparison(v1,v2,solVarName,submissionVarName)
            cObj.solutionVar = v1;
            cObj.submissionVar = v2;            
            cObj.solVarName = solVarName;
            cObj.submissionVarName = submissionVarName;            
        end
    end
    
    methods 
        function feedback = generateFeedback(cObj)
            import connector.internal.academy.i18n.FeedbackTemplates;
            feedback = FeedbackTemplates.constructFeedback('variableHasIncorrectDimensions',...
            cObj.submissionVarName,num2str(size(cObj.solutionVar)),num2str(size(cObj.submissionVar)));
        end
    end
end