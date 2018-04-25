function found = getHelpTextFromDoc(hp, classInfo)

    found = false;
        
    if usejava('jvm')
        hp.getDocTopic;

        docTopic = hp.docTopic;
        if isempty(docTopic) && isempty(regexp(hp.topic, '\)\s*$', 'once')) && ~isempty(which(hp.topic))
            docTopic = hp.topic;
        end
        
        refEntityType = getRefEntityType(classInfo);
        helpTopic = com.mathworks.mlwidgets.help.HelpCommandTopic(docTopic, refEntityType);

        fromDoc = char(helpTopic.getHelpText(matlab.internal.display.isHot));

        if ~isempty(fromDoc)
            hp.helpStr  = fromDoc;
            hp.docTopic = char(helpTopic.getDocCommandArgument);

            hp.objectSystemName = docTopic;        
            hp.needsHotlinking = true;

            found = true;
        end
    end
end

function refEntityType = getRefEntityType(classInfo)
    if ~isempty(classInfo) && classInfo.isClass
        refEntityType = com.mathworks.helpsearch.reference.RefEntityType.CLASS;
    else
        refEntityType = com.mathworks.helpsearch.reference.RefEntityType.FUNCTION;
    end        
end