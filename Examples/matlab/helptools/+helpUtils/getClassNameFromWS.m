function [foundTopic, foundVar, topic] = getClassNameFromWS(topic, wsVariables, ignoreCase)
    foundTopic = topic;
    [topicParts, delimiters] = regexp(topic, '\W', 'split', 'match', 'once');
    [className, topicParts{1}, foundVar] = helpUtils.getClassNameFromVariable(topicParts{1},wsVariables, ignoreCase);
    if foundVar
        topic = strjoin(topicParts, delimiters);
        topicParts{1} = className;
        foundTopic = strjoin(topicParts, delimiters);
    end                
end