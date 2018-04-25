function overloadsLink = getOverloadsLink(hp)
    overloadsLink = '';
    overloadTopic = getOverloadTopic(hp);
    
    if isempty(overloadTopic)
        return;
    end
    
    overloadQualifiedTopic = hp.objectSystemName;
    
    if isempty(overloadQualifiedTopic)
        overloadQualifiedTopic = overloadTopic;
    end
    
    if matlab.internal.language.introspective.overloads.hasOverloads(overloadQualifiedTopic)

        shouldPrintFullOverloadsList = ~hp.commandIsHelp || ~hp.wantHyperlinks;

        overloadsLink = getOtherFunctionsNamedLink(overloadTopic, overloadQualifiedTopic, shouldPrintFullOverloadsList);
        
        if shouldPrintFullOverloadsList
            overloadsLink = [overloadsLink 10 matlab.internal.language.introspective.overloads.displayOverloads(overloadQualifiedTopic, hp.wantHyperlinks, hp.command)];
        end
    end
end

function overloadTopic = getOverloadTopic(hp)
    overloadTopic = '';

    if ~hp.helpOnInstance
        singleName = regexpi(hp.inputTopic,'^(?<name>\w+)(?<extension>\.\w+)?$','once','names');

        if ~isempty(singleName) && (isempty(singleName.extension) || ~isempty(matlab.internal.language.introspective.safeWhich(hp.inputTopic)))
            overloadTopic = matlab.internal.language.introspective.extractCaseCorrectedName(hp.topic, singleName.name);
            if isempty(overloadTopic)
                % underqualified topic is not a part of topic because topic was a typo
                overloadTopic = hp.topic;
            end
        elseif matlab.internal.language.introspective.isOperator(hp.inputTopic)
            overloadTopic = hp.topic; 
        end
    end
end

function overloadText = getOtherFunctionsNamedLink(overloadTopic, overloadQualifiedTopic, shouldPrintFullOverloadsList)

    overloadText = getString(message('MATLAB:introspective:help:OverloadedMethods', overloadTopic));
    
    if ~shouldPrintFullOverloadsList
        overloadText = helpUtils.createMatlabLink('matlab.internal.language.introspective.overloads.displayOverloads', overloadQualifiedTopic, overloadText);
    end
    
    overloadText = helpUtils.formatHelpTextLine(overloadText);
end