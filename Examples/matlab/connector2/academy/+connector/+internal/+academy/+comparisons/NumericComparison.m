classdef NumericComparison < connector.internal.academy.comparisons.Comparison
    properties (Constant)
        minTol = 1e-6;
        maxTol = 1e-2;
    end
    methods
        function cObj = NumericComparison(v1,v2,solVarName,submissionVarName)
            cObj.solutionVar = v1;
            cObj.submissionVar = v2;
            cObj.solVarName = solVarName;
            cObj.submissionVarName = submissionVarName;
        end
    end
    
    methods
        function feedback = generateFeedback(cObj)
            import connector.internal.academy.i18n.FeedbackTemplates;
            feedback = FeedbackTemplates.constructFeedback('variableIsIncorrect',...
                cObj.submissionVarName);
            % Give a message related to the tolerance
            if all((abs(cObj.solutionVar - cObj.submissionVar) < cObj.maxTol)&...
                    (abs(cObj.solutionVar - cObj.submissionVar) > cObj.minTol))
                differenceOrder = max(log10(abs(cObj.solutionVar - cObj.submissionVar)));
                if isscalar(cObj.submissionVar)
                    feedback = [feedback '<br/>' FeedbackTemplates.constructFeedback(...
                        'scalarValueDifference',sprintf('1e%d',ceil(differenceOrder)))];
                else
                    feedback = [feedback '<br/>' FeedbackTemplates.constructFeedback(...
                        'nonscalarValueDifference',sprintf('1e%d',ceil(differenceOrder)))];
                end
            end
        end
    end
end