function innerDoResolve(obj, topic)

    obj.resolveExplicitPath(topic);

    if isempty(obj.classInfo) && ~obj.malformed
        
        if matlab.internal.language.introspective.isObjectDirectorySpecified(topic)
            obj.malformed = true;
            return;
        end

        % just a slash and dot separated list of names
        obj.resolveImplicitPath(topic);

        if isempty(obj.classInfo) && isempty(obj.whichTopic)
            
            obj.resolveUnaryClass(topic);
            
            if isempty(obj.classInfo) && ~isempty(regexp(topic, '[\\/]', 'once'))
                % which may have found an object dir
                obj.resolveExplicitPath(obj.whichTopic);
            end
        end
    end
end

%   Copyright 2013 The MathWorks, Inc

