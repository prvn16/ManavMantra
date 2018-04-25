function [b, topic] = isOperator(topic, asFunctions)
    b = length(topic)<=3 && all(~isstrprop(topic, 'alphanum'));
    if b && (nargin > 1 || nargout > 1)
        whichTopic = which(topic);
        if ~isempty(whichTopic)
            topicParts = regexp(whichTopic, '(?<function>\w+)(?<ext>\.\w+)?\)?$', 'names', 'once');
            newTopic = topicParts.function;
            if isempty(topicParts.ext)
                fullTopic = which([newTopic '.m']);
            else
                fullTopic = whichTopic;
            end
            if ~isempty(fullTopic)
                if nargin>1 && asFunctions
                    topic = newTopic;
                    b = false;
                else
                    topic = fullTopic;
                end
            end
        end
    end
end
