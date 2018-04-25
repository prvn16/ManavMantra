classdef ExistenceComparison < connector.internal.academy.comparisons.Comparison
    methods
        function cObj = ExistenceComparison(v1,v2,solVarName,submissionVarName)
            cObj.solutionVar = v1;
            cObj.submissionVar = v2;            
            cObj.solVarName = solVarName;
            cObj.submissionVarName = submissionVarName; 
        end
    end
    
    methods
        function feedback = generateFeedback(cObj,submissionWS)
            import connector.internal.academy.graders.*;
            import connector.internal.academy.i18n.FeedbackTemplates;
            feedback = FeedbackTemplates.constructFeedback('variableWasNotCreated',cObj.solVarName);
            if nargin == 2         
                % If a variable doesn't exist, find a possible match from the student's
                % workspace
                
                % Variable names from student's workspace
                studentVarNames = fieldnames(submissionWS);
                                
                possibleMatch = GraderUtils.didYouMean(cObj.solVarName, studentVarNames);
                
                if ~isempty(possibleMatch)
                    feedback = [feedback '<br/>' FeedbackTemplates.constructFeedback('checkMisspelledVariableName',possibleMatch)];
                end
            end
            
        end
    end
end