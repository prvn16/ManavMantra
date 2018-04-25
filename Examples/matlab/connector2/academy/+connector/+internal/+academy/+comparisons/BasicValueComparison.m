classdef BasicValueComparison < connector.internal.academy.comparisons.Comparison
    methods
        function cObj = BasicValueComparison(v1,v2,solVarName,submissionVarName)
            cObj.solutionVar = v1;
            cObj.submissionVar = v2;            
            cObj.solVarName = solVarName;
            cObj.submissionVarName = submissionVarName; 
        end
    end
    
    methods 
        function feedback = generateFeedback(cObj)
            import connector.internal.academy.i18n.FeedbackTemplates;
            feedback = FeedbackTemplates.constructFeedback('variableIsIncorrect',cObj.submissionVarName);
        end
    end
end