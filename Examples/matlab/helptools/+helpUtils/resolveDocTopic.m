function [possibleTopics, isPrimitive] = resolveDocTopic(topic, isVariable)
    [possibleTopics, isPrimitive] = resolveTopic(topic, isVariable);

    if isPrimitive
        return;
    end
    
    simpleTopic.topic = topic;
    simpleTopic.isElement = false;
    possibleTopics = [possibleTopics, simpleTopic];
    
    altTopic = createAltTopic(topic);
    if ~strcmp(topic,altTopic)
        altStruct.topic = altTopic;
        altStruct.isElement = false;
        possibleTopics = [possibleTopics, altStruct];
    end
end

function [topicStruct, isPrimitive] = resolveTopic(topic, isVariable)
    topicStruct = [];
    isPrimitive = false;
    
    classResolver = matlab.internal.language.introspective.resolveName(topic, '', false);
    classInfo = classResolver.classInfo;
    [topicPath,topicName] = fileparts(classResolver.whichTopic);

    if ~isempty(classInfo)
         toolboxTopicName = findToolboxTopic(topicPath, classInfo.fullTopic);
         if ~isempty(toolboxTopicName)
            topicStruct.topic = toolboxTopicName;
         else
            topicStruct.topic = classInfo.fullTopic;
         end
         topicStruct.isElement = classInfo.isMethod || classInfo.isSimpleElement;
    elseif isVariable
        [~, comment] = which(topic);
        % doc on a variable which is a primitive type
        isPrimitive = isempty(comment);
    else
        toolboxTopicName = findToolboxTopic(topicPath,topicName);
        if ~isempty(toolboxTopicName) 
            topicStruct.topic = toolboxTopicName;
            topicStruct.isElement = false;
        end
    end
end

function toolboxTopic = findToolboxTopic(path, name)
    toolboxTopic = '';
    pathToToolboxes = [matlabroot, filesep, 'toolbox', filesep];
    escapedPathToToolboxes = regexptranslate('escape', pathToToolboxes);
    refBookPattern = ['^' escapedPathToToolboxes, '(?<refBook>\w+)'];
    splitPath = regexp(path, refBookPattern, 'names');
    if ~isempty(splitPath)
        toolboxTopic = sprintf('(%s)/%s', splitPath.refBook, name);
    end
end

function altTopic = createAltTopic(topic)
    altTopic = regexprep(topic,'\.m(lx)?$','');
    altTopic = lower(altTopic);
    altTopic = regexprep(altTopic,'[\s-\(\)]','');
end
