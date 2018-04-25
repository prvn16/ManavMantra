function resolveWithTypos(obj)
    if obj.fixTypos && isempty(matlab.internal.language.introspective.hashedDirInfo(obj.topicInput))
        [path, file, ext] = fileparts(obj.topicInput);
        if isempty(path)
            candidateList = {obj.wsVariables.name};
            possibleTopic = matlab.internal.language.errorrecovery.namesuggestion(file, candidateList);
            if ~isempty(possibleTopic)
                possibleTopic = [possibleTopic, ext];
                obj.doResolve(possibleTopic, true);
                if obj.isResolved
                    obj.isUnderqualified = true;
                    obj.resolvedTopic = possibleTopic;
                end
            end
        end
    end
end

%   Copyright 2015 The MathWorks, Inc
