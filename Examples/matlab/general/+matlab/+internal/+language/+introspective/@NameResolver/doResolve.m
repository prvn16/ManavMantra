function doResolve(obj, topic, resolveWorkspace)
    
    if resolveWorkspace
        [topic, obj.foundVar, obj.topicInput] = helpUtils.getClassNameFromWS(topic, obj.wsVariables, ~obj.isCaseSensitive);
    end
    
    if ~isempty(obj.helpPath) && isvarname(topic)
        
        processedHelpPath = regexprep(obj.helpPath, '[@+]', '');
        
        if ~isempty(processedHelpPath) && isempty(obj.classInfo)
            
            obj.resolveImplicitPath(fullfile(processedHelpPath, topic));
            
            if isempty(obj.classInfo) && matlab.internal.language.introspective.containers.isClassDirectory(obj.helpPath)
                [processedHelpPath, pop] = fileparts(processedHelpPath);
                if ~isempty(pop)
                    obj.resolveImplicitPath(fullfile(processedHelpPath, topic));
                end
            end
            
            if ~isempty(obj.classInfo) && ~obj.classInfo.isAccessible
                obj.classInfo  = [];
                obj.whichTopic = '';
            end
        end
    end
    
    if isempty(obj.classInfo)
        % innerDoResolve may populate classInfo
        obj.innerDoResolve(topic);
    end
    
    if ~isempty(obj.classInfo)
        obj.whichTopic = obj.classInfo.minimizePath;
        obj.elementKeyword = obj.classInfo.getKeyword;
    elseif obj.foundVar
        obj.resolvedTopic = topic;
    end
end