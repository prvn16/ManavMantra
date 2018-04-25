function getBuiltinHelp(hp)

    mcosResolver = matlab.internal.language.introspective.MCOSMetaResolver(hp.inputTopic);
    [metaInfo, resolvedName] = mcosResolver.executeResolve();

    if ~isempty(metaInfo)
        
        hp.needsHotlinking = true;
        if isa(metaInfo,'meta.package')
            hp.helpStr = getBuiltinPackageContentHelpText(metaInfo);
        else
            hp.helpStr = getBuiltinHelpText(metaInfo);
        end
        
        if ~isempty(hp.helpStr)
            hp.fullTopic        = resolvedName;
            hp.objectSystemName = resolvedName;
        elseif isa(metaInfo, 'meta.method')
            % Check to see if this is shadowing an ordinary function
            [hp.helpStr, hp.needsHotlinking] = builtin('helpfunc', '-casesensitive', metaInfo.Name, '-hotlink', hp.command);
            if ~isempty(hp.helpStr)
                hp.topic = metaInfo.Name;
                hp.fullTopic =  matlab.internal.language.introspective.safeWhich(metaInfo.Name);
            end
        end
        
        if ~isempty(hp.helpStr)
            hp.suppressedImplicit = false; 
            hp.isBuiltin          = true;
        end
    end
end

%% ------------------------------------------------------------------------
function helpText = getBuiltinHelpText(metaInfo)
    
    helpText = '';

    if ~isempty(metaInfo) && ~isempty(metaInfo.Description)
        helpText = metaInfo.Description;
        if ~isempty(metaInfo.DetailedDescription)
            helpText = [helpText, newline, metaInfo.DetailedDescription];
        end
    end
end

%% ------------------------------------------------------------------------
function contentText = getBuiltinPackageContentHelpText(metaInfo)

    contentText = '';
    
    if any({metaInfo.FunctionList.Name} == "Contents")
        % Do not generate Contents if the Contents.m file has been skipped
        return;
    end
    
    packageText = getPackagedMetaInfoDescriptions(metaInfo.PackageList, metaInfo.Name);
    if ~isempty(packageText)
        contentText = [contentText sprintf('\nPackages contained in %s:\n', metaInfo.Name) packageText];
    end

    classText = getPackagedMetaInfoDescriptions(metaInfo.ClassList, metaInfo.Name);
    if ~isempty(classText)
        contentText = [contentText sprintf('\nClasses contained in %s:\n', metaInfo.Name) classText];
    end

    functionText = getPackagedMetaInfoDescriptions(metaInfo.FunctionList, metaInfo.Name);
    if ~isempty(functionText)
        contentText = [contentText sprintf('\nFunctions contained in %s:\n', metaInfo.Name) functionText];
    end
end

%% ------------------------------------------------------------------------
function result = getPackagedMetaInfoDescriptions(metaInfoList, packageName)

    result = '';

    if isempty(metaInfoList) || ~all(isprop(metaInfoList,'Description')) || ~all(isprop(metaInfoList,'Name'))
        return;
    end

    lineItem = cell(1,numel(metaInfoList));

    for i = 1:numel(metaInfoList)        
        name = strsplit(metaInfoList(i).Name,'.');
        name = name{end};
        
        qualifiedName = [packageName '.' name];
        description   = metaInfoList(i).Description;

        link    = createHotlink(qualifiedName, name);
        linkPad = repmat(' ', 1, 30-numel(name));

        lineItem{i} = [link linkPad ' - ' description];
    end

    result = [strjoin(lineItem, newline) newline];
end

%% ------------------------------------------------------------------------
function name = createHotlink(qualifiedName, name)
    if matlab.internal.display.isHot
        name = helpUtils.createMatlabLink('help', qualifiedName, name);
    end
end