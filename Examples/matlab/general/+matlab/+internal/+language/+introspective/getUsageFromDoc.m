function usage = getUsageFromDoc(functionName)
    %GETUSAGEFROMDOC Get usage syntax from documentation
    %   USAGE = GETUSAGEFROMDOC(FUNCTIONNAME) returns a string array of the
    %   syntaxes found for functionName. 
    %
    %   GETUSAGEFROMDOC attempts to get the syntax information from the 
    %   function reference page.
    %
    %   GETUSAGEFROMDOC will return syntaxes only for the first function 
    %   that WHICH finds. To get syntaxes for overloaded methods, provide
    %   the full classname and methodname to GETUSAGEFROMDOC.
    %
    %   Examples:
    %      usage = matlab.internal.language.introspective.getUsageFromDoc("magic");
    %
    %         returns a string:
    %
    %           "M = magic(n)"
    %
    %      usage = matlab.internal.language.introspective.getUsageFromDoc("LinearModel.Plot");
    %
    %         returns a 1×2 string array with:
    %
    %         usage(1) =
    %           "plot(mdl)"
    %
    %         usage(2) =
    %           "h = plot(mdl)"
    %
    %   See also DOC, GETUSAGE, GETUSAGEFROMHELP, GETUSAGEFROMSOURCE.
    
    %   Copyright 2017 The MathWorks, Inc.
    
    functionName = convertStringsToChars(functionName);
    
    usage = strings(1,0);
    
    possibleTopics = helpUtils.resolveDocTopic(functionName, false);

    for topic = possibleTopics
        if topic.isElement
            refType = com.mathworks.helpsearch.reference.RefEntityType.METHOD;
        else
            refType = com.mathworks.helpsearch.reference.RefEntityType.FUNCTION;
        end
        helpTopic = com.mathworks.mlwidgets.help.HelpTopic(char(topic.topic), refType);
        results = helpTopic.getReferenceData;
        if ~results.isEmpty
            lines = results.get(0).getSyntaxLines;
            numSigs = lines.size;
            usage = strings(1,numSigs);
            for i = 1:numSigs
                usage(i) = lines.get(i-1); 
            end
            return;
        end
    end    
end
