classdef CharComparison < connector.internal.academy.comparisons.Comparison
    methods
        function cObj = CharComparison(v1,v2,solVarName,submissionVarName)
            cObj.solutionVar = v1;
            cObj.submissionVar = v2;            
            cObj.solVarName = solVarName;
            cObj.submissionVarName = submissionVarName; 
        end
    end
    
    methods
        function feedback = generateFeedback(cObj)
            import connector.internal.academy.i18n.FeedbackTemplates;
            % If the variable is a character array, check if the case of the
            % letters is correct
            feedback = '';
            if strcmpi(cObj.solutionVar,cObj.submissionVar)
                feedback = FeedbackTemplates.constructFeedback('checkCapitalizationOfCharacters',cObj.submissionVarName);
            end
            if isvector(cObj.submissionVar) && length(cObj.submissionVar) < 15
                feedback = [feedback FeedbackTemplates.constructFeedback('stateDesiredValue',...
                    cObj.submissionVarName,cObj.solutionVar,cObj.submissionVar)];
            end
        end
    end
end
