classdef helpProcess < handle
    
    properties (SetAccess=public, GetAccess=public)
        wsVariables = struct('name', {});
        topic = '';
        displayBanner = false;
        inputTopic = '';
    end
    
    properties (SetAccess=private, GetAccess=public)
        helpStr  = '';
        docTopic = '';
        helpOnInstance = false;
    end

    properties (SetAccess=private, GetAccess=private)
        command          = '';
        fullTopic        = '';
        objectSystemName = '';
        elementKeyword   = '';

        isBuiltin                = false;
        isDir                    = false;
        isContents               = false;
        isOperator               = false;
        isMCOSClassOrConstructor = false;
        isMCOSClass              = false;
        isInaccessible           = false;
        
        suppressDisplay    = false;
        suppressedImplicit = false;
        wantHyperlinks     = false;
        commandIsHelp      = true;
        needsHotlinking    = false;
        noDefault          = false;
    end

    methods
        function hp = helpProcess(nlhs, nrhs, prhs)
            hp.suppressDisplay = (nlhs ~= 0);
            if ~hp.suppressDisplay
                hp.wantHyperlinks = matlab.internal.display.isHot; 
                if hp.wantHyperlinks
                    hp.command = 'help';
                end
            end

            commandSpecified = false;

            try
                for i = 1:nrhs
                    arg = prhs{i};
                    if isstring(arg)
                        if ~isscalar(arg)
                            error(message('MATLAB:help:MustBeSingleString'));
                        end
                        commandSpecified = processTextInput(hp, char(arg), commandSpecified);
                    elseif ischar(arg)
                        commandSpecified = processTextInput(hp, arg, commandSpecified);
                    else
                        hp.specifyTopic(class(arg));
                        hp.inputTopic = i;
                        hp.displayBanner = true;
                        hp.helpOnInstance = true;
                    end
                end
            catch Ex
                hp.suppressDisplay = true;
                throwAsCaller(Ex);
            end
            
            % enable the directory hashtable
            matlab.internal.language.introspective.hashedDirInfo(true);
        end

        getHelpText(hp);
        prepareHelpForDisplay(hp);

        function delete(hp)
            % disable the directory hashtable
            matlab.internal.language.introspective.hashedDirInfo(false);

            hp.displayHelp;
        end
    end

    methods (Access=private)
        function commandSpecified = processTextInput(hp, arg, commandSpecified)
            switch arg
            case '-noDefault'
                hp.noDefault = true;
            case {'-help', '-helpwin', '-doc', '-updateHelpPopup'}
                if commandSpecified
                    error(message('MATLAB:help:TooManyCommands'));
                end
                hp.command = arg(2:end);
                hp.commandIsHelp = strcmp(hp.command, 'help');
                hp.wantHyperlinks = true;
                commandSpecified = true;
            otherwise
                hp.specifyTopic(arg);
                hp.inputTopic = arg;
            end
        end
        
        function specifyTopic(hp, topic)
            if ~isempty(hp.topic)
                error(message('MATLAB:help:TooManyInputs'));
            end
            hp.topic = topic;
        end
        
        link = getOverloadsLink(hp);
        link = getReferenceLink(hp);
        
        getTopicHelpText(hp);
        getDocTopic(hp);
        getBuiltinHelp(hp);
        getDefaultHelpFromSource(hp);
        
        extractFromClassInfo(hp, classInfo);
        found = getHelpTextFromDoc(hp, classInfo);
        found = getHelpFromClassInfo(hp, classInfo);   
        
        demoTopic = getDemoTopic(hp);
        [qualifyingPath, pathItem] = getPathItem(hp);
        
        hotlinkHelp(hp);
        displayHelp(hp);
    end
end

%   Copyright 2007 The MathWorks, Inc.
