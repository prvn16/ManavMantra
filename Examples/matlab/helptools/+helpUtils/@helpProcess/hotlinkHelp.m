function hotlinkHelp(hp)
    %HOTLINKHELP Reformat help output so that the content has hyperlinks
    
    %   Copyright 1984-2006 The MathWorks, Inc.
    
    packageName = '';
    className = '';
    inClass = false;
    
    [pathName, fcnName] = fileparts(hp.topic);
    if hp.isOperator
        if isempty(pathName)
            fcnName = hp.topic;
        end
    else
        if hp.isDir
            if hp.suppressedImplicit
                pathName = '';
            else
                pathName = hp.topic;
            end
            fcnName = regexp(fcnName, '\w+', 'match', 'once');
        elseif hp.isBuiltin
            pathName = hp.topic;
        elseif any(fcnName==filemarker)
            methodSplit = regexp(fcnName, filemarker, 'split', 'once');
            if ~matlab.internal.language.introspective.containers.isClassDirectory(pathName)
                pathName = fullfile(pathName, ['@' methodSplit{1}]);
            end
            fcnName = methodSplit{2};
        elseif strcmp(getFinalObjectEntity(pathName), fcnName)
            % @ dir Class
            inClass = true;
            packageName = matlab.internal.language.introspective.getPackageName(fileparts(pathName));
            className = fcnName;
        elseif ~isempty(fcnName)
            if isempty(pathName) && contains(hp.objectSystemName, '.')
                packageName = fcnName;
                fcnName = regexp(hp.topic, '\w*$', 'match', 'once');
            else
                packageName = matlab.internal.language.introspective.getPackageName(pathName);
            end
            if hp.isMCOSClassOrConstructor
                inClass = true;
                className = fcnName;
                if isempty(pathName)
                    pathName = className;
                else
                    pathName = [pathName '/@' className];
                end
            end
        end
    end
    
    % hotlink all URLs in the help
    hp.helpStr = linkURLs(hp.helpStr, hp.command);
    
    [dirHelps, dirSplit] = regexp(hp.helpStr, '\{\b (?<text>.*?)\}\b ', 'names', 'split');
        
    for i = 1:length(dirHelps) 
        dirHelps(i).text = linkContents(hp, dirHelps(i).text, pathName, fcnName, false);
    end
    
    if hp.isOperator || hp.isContents || strcmp(fcnName,'debug')
        % hotlink these files like directories
        dirSplit{end} = linkContents(hp, dirSplit{end}, pathName, fcnName, false);
    else
        dirSplit{end} = linkSeeAlsos(hp, dirSplit{end}, pathName, fcnName, inClass);
        if inClass
            dirSplit{end} = linkClassMembers(hp, dirSplit{end}, packageName, className, pathName);            
        end
    end
    
    helpPieces = [dirSplit; {dirHelps.text, ''}];
    hp.helpStr = [helpPieces{:}];

    if hp.commandIsHelp
        hp.helpStr = helpUtils.highlightHelp(hp.helpStr, hp.objectSystemName, fcnName, '<strong>', '</strong>');
    end
end

%% ------------------------------------------------------------------------
function helpStr = linkSeeAlsos(hp, helpStr, pathName, fcnName, inClass)
    helpParts = matlab.internal.language.introspective.helpParts(helpStr, fcnName);
    seeAlsoPart = helpParts.getPart('seeAlso');
    if ~isempty(seeAlsoPart)
        % Parse the "See Also" portion of help output to isolate function names.
        seealsoStr = seeAlsoPart.getText;
        
        seealsoStr = linkList(hp, seealsoStr, pathName, fcnName, false, inClass);
        
        seeAlsoPart.replaceText(seealsoStr);

        % Replace "See Also" section with modified string (with links)
        helpStr = helpParts.getFullHelpText;
    end
end
    
%% ------------------------------------------------------------------------
function helpStr = linkURLs(helpStr, actionName)
    replaceLink = @(url)makeURLLink(url, actionName); %#ok<NASGU>
    helpStr = regexprep(helpStr, '(<a\s*href.*?</a>)?((?<!'')\<\w{2,}://\S*(?<=[\w\\/])\>(?!''))?', '$1${replaceLink($2)}', 'ignorecase');
end

%% ------------------------------------------------------------------------
function linkText = makeURLLink(url, actionName)
    if isempty(url)
        linkText = '';
    else
        if strcmp(actionName, 'help')
            linkText = helpUtils.createMatlabLink('web', url, url);
        else
            linkText = ['<a href="' url '">' url '</a>'];
        end
    end
end

%% ------------------------------------------------------------------------
function helpStr = linkClassMembers(hp, helpStr, packageName, className, pathName)
    % linkClassMembers links the list of class members in helpStr if a list exists
    
    if ~isempty(packageName)
        packageName = [packageName '.'];
    end
    
    matchPattern = generateHotlinkMatchPattern({'Methods','Properties','Events','Enumerations'}, className);
    
    hotlinkStart = regexpi(helpStr, ['^\s*(' packageName ')?(?:' matchPattern ').*:\s*$'], 'dotexceptnewline', 'lineanchors', 'once');
    
    if ~isempty(hotlinkStart)
        % Parse the "Class Member" portion of help output to link like a Contents.m file.
        linkThisString = helpStr(hotlinkStart:end);
        linkThisString = linkContents(hp, linkThisString, pathName, className, true);
        
        % Replace "Class Member" section with modified string (with links)
        helpStr = [helpStr(1:hotlinkStart-1) linkThisString];
    end
end

%% ------------------------------------------------------------------------
function pattern = generateHotlinkMatchPattern(matchers, className)
    % generateHotlinkMatchPattern generates a match pattern from message
    % catalog messages based upon the cell array of matchers passed in

    patternList = cell(1,2*numel(matchers));
    
    for i = 1:numel(matchers)
        patternList{2*i-1}   = regexptranslate('escape', getString(message(['MATLAB:helpUtils:helpProcess:' matchers{i}], className)));
        patternList{2*i  }   = getString(message(['MATLAB:helpUtils:helpProcess:' matchers{i} 'English'], className));
    end
    
    pattern = strjoin(patternList,'|');    
    pattern = regexprep(pattern, '\s+', '\\s+');
end

%% ------------------------------------------------------------------------
function helpStr = linkContents(hp, helpStr, pathName, fcnName, inClass)
    if ~inClass
        helpStr = linkSeeAlsos(hp, helpStr, pathName, fcnName, inClass);
    end
    replaceList = @(list)linkList(hp, list, pathName, fcnName, true, inClass); %#ok<NASGU>
    helpStr = regexprep(helpStr, '^(.*?)([ \t]-[ \t])', '${replaceList($1)}$2', 'lineanchors', 'dotexceptnewline');
end

%% ------------------------------------------------------------------------
function list = linkList(hp, list, pathName, fcnName, inContents, inClass)
    list = strrep(list, '&amp;', '&');
    replaceLink = @(name)makeHyperlink(hp, name, pathName, fcnName, inContents, inClass); %#ok<NASGU>
    list = regexprep(list, ['(<a\s*href.*?</a>)?([\w\\/.' filemarker ']+(?<!\.))?'], '$1${replaceLink($2)}', 'ignorecase');
end

%% ------------------------------------------------------------------------
function linkText = makeHyperlink(hp, word, pathName, fcnName, inContents, inClass)
    linkText = word;
    if isempty(word)
        return;
    end
    % Make sure the function exists before hyperlinking it.
    if strcmpi(word, fcnName) && (~inContents || inClass)
        if hp.isMCOSClassOrConstructor
            alternateHelpFunction = matlab.internal.language.introspective.getAlternateHelpFunction(hp.fullTopic);
            if hasHelp(hp.fullTopic, alternateHelpFunction)
                if isempty(alternateHelpFunction) 
                    [~,~,ext] = fileparts(hp.fullTopic);
                    constructorTopic = [hp.fullTopic(1:end-length(ext)) '>' fcnName];
                else
                    constructorTopic = [hp.fullTopic '>' fcnName];
                end
                if hasHelp(constructorTopic, alternateHelpFunction)
                    % class or constructor self link, in which both exist
                    if inClass
                        % link to the constructor
                        linkTarget = [hp.objectSystemName '/' fcnName];
                    else
                        % link to the class
                        linkTarget = regexp(hp.objectSystemName, '[^/]*', 'match', 'once');
                    end
                    linkText = helpUtils.createMatlabLink(hp.command, linkTarget, fcnName);
                    return;
                end
            end
        end
        pathName = '';
    end
    if inContents || ~strcmp(word,'and')
        [shouldLink, fname, qualifyingPath, whichTopic] = isHyperlinkable(word, pathName);
        if shouldLink
            linkWord = matlab.internal.language.introspective.extractCaseCorrectedName(fname, word);
            if isempty(linkWord)
                % word is overqualified
                [overqualifiedPath, linkWord] = matlab.internal.language.introspective.splitOverqualification(fname, word, whichTopic);
                linkWord = [overqualifiedPath, linkWord];
            elseif ~isempty(qualifyingPath)
                % word is underqualified
                qualifyingPath(qualifyingPath=='\') = '/';
                fname = [qualifyingPath, '/', fname];
            end
            linkText = helpUtils.createMatlabLink(hp.command, fname, linkWord);
        end
    end
end

%% ------------------------------------------------------------------------
function b = hasHelp(fullTopic, alternateHelpFunction)
    if isempty(alternateHelpFunction)
        b = builtin('helpfunc', fullTopic, '-justChecking');
    else
        b = ~isempty(matlab.internal.language.introspective.callHelpFunction(alternateHelpFunction, fullTopic));        
    end
end

%% ------------------------------------------------------------------------
function [shouldLink, fname, qualifyingPath, whichTopic] = isHyperlinkable(fname, helpPath)
    whichTopic = '';
    
    % Make sure the function exists before hyperlinking it.
    [fname, hasLocalFunction, shouldLink, qualifyingPath] = matlab.internal.language.introspective.fixLocalFunctionCase(fname, helpPath);
    if hasLocalFunction
        return;
    end
    
    [fname, shouldLink, qualifyingPath, whichTopic] = isHyperlinkableMethod(fname, helpPath);
    if ~shouldLink
        % Check for directories on the path
        dirInfo = matlab.internal.language.introspective.hashedDirInfo(fname);
        if ~isempty(dirInfo)
            fname = matlab.internal.language.introspective.extractCaseCorrectedName(dirInfo(1).path, fname);
            if exist(fname, 'file') == 7
                shouldLink = true;
                return;
            end
        end
        
        % Check for files on the path
        [fname, qualifyingPath, ~, hasMFileForHelp, alternateHelpFunction] = matlab.internal.language.introspective.fixFileNameCase(fname, helpPath, whichTopic);
        shouldLink = hasMFileForHelp || ~isempty(alternateHelpFunction);
    end
end

%% ------------------------------------------------------------------------
function [fname, shouldLink, qualifyingPath, whichTopic] = isHyperlinkableMethod(fname, helpPath)
    shouldLink = false;
    qualifyingPath = '';
    
    nameResolver = matlab.internal.language.introspective.resolveName(fname, helpPath);
    
    classInfo    = nameResolver.classInfo;
    whichTopic   = nameResolver.whichTopic; 
    
    if ~isempty(classInfo)
        shouldLink = true;
        % qualifyingPath includes the object dirs, so remove them
        qualifyingPath = regexp(fileparts(classInfo.minimalPath), '^[^@+]*(?=[\\/])', 'match', 'once');
        newName = classInfo.fullTopic;
        
        if classInfo.isConstructor && isempty(regexpi(fname, '\<(\w+)[\\/.]\1(\.[mp])?$', 'once'))
            fname = regexprep(newName, '\<(\w+)/\1$', '$1');
        else
            fname = newName;
        end
    end
end

%% ------------------------------------------------------------------------
function entity = getFinalObjectEntity(objectPath)
    entity = regexp(objectPath, '(?<=[@+])[^@+]*$', 'match', 'once');
end

%   Copyright 2007 The MathWorks, Inc.
