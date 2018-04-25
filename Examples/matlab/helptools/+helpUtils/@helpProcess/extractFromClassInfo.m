function extractFromClassInfo(hp, classInfo)
    
    hp.isMCOSClassOrConstructor = classInfo.isMCOSClassOrConstructor;
    hp.isMCOSClass              = classInfo.isMCOSClass;
    hp.isDir                    = classInfo.isPackage;
    hp.objectSystemName         = classInfo.fullTopic;
    
    if ~isempty(classInfo.getDocTopic(true))
        hp.docTopic = hp.objectSystemName;
    end
end

%   Copyright 2007 The MathWorks, Inc.
