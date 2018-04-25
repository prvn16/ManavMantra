function getTopicHelpText(hp)
    [hp.isOperator, hp.topic] = matlab.internal.language.introspective.isOperator(hp.topic, true);

    if hp.isOperator
        hasLocalFunction = false;
    else
        [hp.topic, hasLocalFunction, shouldLink, ~, ~, alternateHelpFunction] = matlab.internal.language.introspective.fixLocalFunctionCase(hp.topic);

        if hasLocalFunction && shouldLink
            hp.fullTopic = hp.topic;
        else
            nameResolver = matlab.internal.language.introspective.resolveName(hp.topic, '', false, hp.wsVariables, hp.commandIsHelp);
            
            classInfo         = nameResolver.classInfo;
            hp.fullTopic      = nameResolver.whichTopic;
            hp.topic          = nameResolver.resolvedTopic;
            hp.elementKeyword = nameResolver.elementKeyword;
            hp.isInaccessible = nameResolver.isInaccessible;
            
            if nameResolver.foundVar
                hp.inputTopic = nameResolver.topicInput; % may be case corrected var
                hp.helpOnInstance = true;
                hp.displayBanner = true;
            end
            
            hp.displayBanner = hp.displayBanner || nameResolver.isUnderqualified;
            
            if ~isempty(classInfo)
                hp.extractFromClassInfo(classInfo);
            end
            
            if useSingleSource(hp) && hp.getHelpTextFromDoc(classInfo)
                return;
            end

            if isempty(classInfo)
                [hp.topic, ~, hp.fullTopic, ~, alternateHelpFunction] = matlab.internal.language.introspective.fixFileNameCase(hp.topic, '', hp.fullTopic);

                if nameResolver.malformed
                   return; 
                end
            else
                hp.getHelpFromClassInfo(classInfo);
                getAlternateSourcedHelp(hp, classInfo);
                return;
            end
        end
        if ~isempty(alternateHelpFunction)
            hp.helpStr = matlab.internal.language.introspective.callHelpFunction(alternateHelpFunction, hp.fullTopic);
            hp.needsHotlinking = true;
            [~, hp.topic, fileExt] = fileparts(hp.fullTopic);
            split = regexp(fileExt, filemarker, 'split', 'once');
            if ~isscalar(split)
                hp.topic = [hp.topic, filemarker, split{2}];
            end
            return;
        end
    end

    if strcmpi(hp.inputTopic, hp.topic)
        caseTopic = hp.inputTopic;
    else
        caseTopic = hp.topic;
    end
    [hp.helpStr, hp.needsHotlinking] = builtin('helpfunc', '-casesensitive', caseTopic, '-hotlink', hp.command);
    
    if isempty(hp.helpStr)
        [hp.helpStr, hp.needsHotlinking] = builtin('helpfunc', hp.topic, '-hotlink', hp.command);
    end
    
    getAlternateSourcedHelp(hp, []);

    if ~isempty(hp.helpStr) && ~hasLocalFunction
        dirInfos = matlab.internal.language.introspective.hashedDirInfo(hp.topic)';
        if isempty(hp.fullTopic)
            for dirInfo = dirInfos
                hp.fullTopic = matlab.internal.language.introspective.extractCaseCorrectedName(dirInfo.path, hp.topic);
                if ~isempty(hp.fullTopic)
                    hp.topic = matlab.internal.language.introspective.minimizePath(hp.fullTopic, true);
                    hp.isDir = true;
                    return;
                end
            end
        elseif ~isempty(hp.objectSystemName)
            hp.topic = hp.objectSystemName;
        else
            [~, hp.topic] = hp.getPathItem;
            if strcmp(hp.topic, 'handle')
                hp.isMCOSClassOrConstructor = true;
            elseif ~hp.isDir
                hp.isDir = ~isempty(dirInfos);
            end
        end
    end
end

function getAlternateSourcedHelp(hp, classInfo)
    if isempty(hp.helpStr)
        hp.getHelpTextFromDoc(classInfo);
    end
    
    if isempty(hp.helpStr)
        hp.getBuiltinHelp();
    end
    
    if isempty(hp.helpStr) && ~hp.isInaccessible
        hp.getDefaultHelpFromSource();
    end
end

function singleSource = useSingleSource(hp)
    singleSource = ~hp.suppressDisplay && usejava('jvm');
    if singleSource && com.mathworks.mlwidgets.help.HelpUtils.isEnglish
        s = settings;
        singleSource = s.matlab.desktop.help.SingleSource.ActiveValue;
    end
end
%   Copyright 2007-2015 The MathWorks, Inc.
