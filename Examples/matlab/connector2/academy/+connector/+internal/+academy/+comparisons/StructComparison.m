classdef StructComparison < connector.internal.academy.comparisons.Comparison
    
    methods
        function cObj = StructComparison(v1,v2,solVarName,submissionVarName)
            import connector.internal.academy.comparisons.graders.*;
            cObj.solutionVar = v1;
            cObj.submissionVar = v2;
            cObj.solVarName = solVarName;
            cObj.submissionVarName = submissionVarName;
        end
    end
    
    methods
        function feedback = generateFeedback(cObj) % TODO - Have a showVariableNameFlag in the comparison class. Use it here to show variable names in the hints.
            import connector.internal.academy.graders.*;
            import connector.internal.academy.i18n.FeedbackTemplates;
            feedback = '';
            
            % If the variable is a structure, check if all the field names match
            expectedFields = fieldnames(cObj.solutionVar);
            actualFields = fieldnames(cObj.submissionVar);
            
            missingOrIncorrectFieldNames = setdiff(expectedFields,actualFields);
            
            if ~isempty(missingOrIncorrectFieldNames)
                if numel(missingOrIncorrectFieldNames) == 1
                    feedback = ['<br/>' FeedbackTemplates.constructFeedback(...
                        'missingStructField',missingOrIncorrectFieldNames{1})];
                else
                    feedback = ['<br/>' FeedbackTemplates.constructFeedback(...
                        'missingSeveralStructFields',...
                        sprintf(repmat('<br/>%s',1,length(missingOrIncorrectFieldNames)),missingOrIncorrectFieldNames{:}))];
                end
                % Find a possible match
                possibleMatch = cell(1,length(missingOrIncorrectFieldNames));
                for i = 1:length(missingOrIncorrectFieldNames)
                    possibleMatch{i} = GraderUtils.didYouMean(missingOrIncorrectFieldNames{i}, actualFields);
                end
                
                foundMatch = ~cellfun(@isempty,possibleMatch);
                if all(foundMatch)
                    if length(missingOrIncorrectFieldNames) == 1
                        feedback = [feedback '<br/>' FeedbackTemplates.constructFeedback('checkMisspelledFieldName',...
                            ['<code>' possibleMatch{1} '</code>'])];
                    else
                        feedback = [feedback '<br/>' FeedbackTemplates.constructFeedback('checkMisspelledFieldName',...
                            sprintf(['<code>' repmat('<br/>%s',1,length(possibleMatch)) '</code>'],possibleMatch{:}))];
                    end
                elseif any(foundMatch)
                    feedback = [feedback FeedbackTemplates.language.templates.checkMisspelledFieldNameGeneric];
                end
                
            else
                % Find which of the fields have wrong values
                if length(cObj.solutionVar) == 1
                    numFields = length(actualFields);
                    fieldsNotEq = {};
                    for j=1:numFields
                        if ~isequaln(cObj.submissionVar.(actualFields{j}),cObj.solutionVar.(actualFields{j}))
                            fieldsNotEq{end+1} = actualFields{j};
                        end
                    end
                    if ~isempty(fieldsNotEq)
                        feedback = ['<br/>' FeedbackTemplates.constructFeedback('checkFieldValue',...
                            sprintf(['<code>' repmat('%s',1,length(fieldsNotEq)) '</code>'],fieldsNotEq{:}))];
                    end
                else
                    numFields = length(actualFields);
                    fieldsNotEq = {};
                    for j=1:numFields
                        if ~isequaln({cObj.submissionVar.(actualFields{j})},{cObj.solutionVar.(actualFields{j})})
                            fieldsNotEq{end+1} = actualFields{j};
                        end
                    end
                    if ~isempty(fieldsNotEq)
                        feedback = ['<br/>' FeedbackTemplates.constructFeedback('checkFieldValue',...
                            sprintf(['<code>' repmat('%s',1,length(fieldsNotEq)) '</code>'],fieldsNotEq{:}))];
                    end                    
                end
            end
        end
    end
end
