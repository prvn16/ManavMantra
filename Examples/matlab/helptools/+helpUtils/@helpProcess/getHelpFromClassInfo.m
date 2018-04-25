function foundHelp = getHelpFromClassInfo(hp, classInfo)
    
    foundHelp = false;
    
    if isempty(hp.helpStr)
        [hp.helpStr, hp.needsHotlinking, hp.suppressedImplicit] = classInfo.getHelp(hp.command, hp.topic, hp.wantHyperlinks);
        foundHelp = true;
        hp.topic = classInfo.minimalPath;
    end 
end

%   Copyright 2007 The MathWorks, Inc.
