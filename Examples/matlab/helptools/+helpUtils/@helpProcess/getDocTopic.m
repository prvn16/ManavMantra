function getDocTopic(hp)

    if usejava('jvm') && ~isempty(hp.fullTopic) 

        if isempty(hp.objectSystemName)
            [path, name] = hp.getPathItem;
            if ~isempty(path) 
                hp.docTopic = matlab.internal.language.introspective.getDocTopic(path, name, false);
            end
        end
        
        if isempty(hp.docTopic) && hp.isMCOSClass
            hp.docTopic = hp.objectSystemName;
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
