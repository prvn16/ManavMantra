classdef BasicTypeComparison < connector.internal.academy.comparisons.Comparison
    methods
        function cObj = BasicTypeComparison(v1,v2,solVarName,submissionVarName)
            cObj.solutionVar = v1;
            cObj.submissionVar = v2;            
            cObj.solVarName = solVarName;
            cObj.submissionVarName = submissionVarName;                    
        end
    end
    
    methods 
        function feedback = generateFeedback(cObj)
            import connector.internal.academy.i18n.FeedbackTemplates;
            feedback =  FeedbackTemplates.constructFeedback('variableHasIncorrectDataType',...
            cObj.submissionVarName,class(cObj.solutionVar),class(cObj.submissionVar));
        end
    end
end