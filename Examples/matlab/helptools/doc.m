function doc(varargin)
    %  DOC Reference page in Help browser.
    %  
    %     DOC opens the Help browser, if it is not already running, and 
    %     otherwise brings the Help browser to the top.
    %   
    %     DOC FUNCTIONNAME displays the reference page for FUNCTIONNAME in
    %     the Help browser. FUNCTIONNAME can be a function or block in an
    %     installed MathWorks product.
    %   
    %     DOC METHODNAME displays the reference page for the method
    %     METHODNAME. You may need to run DOC CLASSNAME and use links on the
    %     CLASSNAME reference page to view the METHODNAME reference page.
    %   
    %     DOC CLASSNAME displays the reference page for the class CLASSNAME.
    %     You may need to qualify CLASSNAME by including its package: DOC
    %     PACKAGENAME.CLASSNAME.
    %   
    %     DOC CLASSNAME.METHODNAME displays the reference page for the method
    %     METHODNAME in the class CLASSNAME. You may need to qualify
    %     CLASSNAME by including its package: DOC PACKAGENAME.CLASSNAME.
    %   
    %     DOC FOLDERNAME/FUNCTIONNAME displays the reference page for the
    %     FUNCTIONNAME that exists in FOLDERNAME. Use this syntax to display the
    %     reference page for an overloaded function.
    %   
    %     DOC USERCREATEDCLASSNAME displays the help comments from the
    %     user-created class definition file, UserCreatedClassName.m, in an
    %     HTML format in the Help browser. UserCreatedClassName.m must have a
    %     help comment following the classdef UserCreatedClassName statement
    %     or following the constructor method for UserCreatedClassName. To
    %     directly view the help for any method, property, or event of
    %     UserCreatedClassName, use dot notation, as in DOC
    %     USERCREATEDCLASSNAME.METHODNAME. 
    %
    %     Examples:
    %        doc abs
    %        doc fixedpoint/abs  % ABS function in the Fixed-Point Designer Product
    %        doc handle.findobj  % FINDOBJ method in the HANDLE class
    %        doc handle          % HANDLE class
    %        doc containers.Map  % Map class in the containers method
    %        doc sads            % User-created class, sads
    %        doc sads.steer      % steer method in the user-created class, sads

    %   Copyright 1984-2013 The MathWorks, Inc.
    
    % Make sure that we can support the doc command on this platform.
    if ~usejava('mwt')
        error(message('MATLAB:doc:UnsupportedPlatform', upper(mfilename)));
    end

    % Examine the inputs to see what options are selected.
    [showClassicDoc, topic, search, isVariable] = examineInputs(varargin{:});
    if isVariable
        varName = inputname(isVariable);
    elseif ~isempty(topic) && nargin == 1
        wsVariables = evalin('caller', 'whos');
        [topic, isVariable, varName] = helpUtils.getClassNameFromWS(topic, wsVariables, true);
    end
    if search
        docsearch(topic);
        return;
    end

    % Check this before checking docroot, the -classic option is used to show doc not under docroot.
    if showClassicDoc
        com.mathworks.mlservices.MLHelpServices.invokeClassicHelpBrowser();
        return;
    end

    % Make sure docroot is valid.
    if ~helpUtils.isDocInstalled
        % If m-file help is available for this topic, call helpwin.
        if ~isempty(topic)
            if showHelpwin(topic)
                return;
            end
        end

        % Otherwise show the appropriate error page.
        htmlFile = fullfile(matlabroot,'toolbox','local','helperr.html');

        if exist(htmlFile, 'file') ~= 2
            error(message('MATLAB:doc:HelpErrorPageNotFound', htmlFile));
        end
        displayFile(htmlFile);
        return;
    end

    % Case no topic specified.
    if isempty(topic)
        % Just open the help browser and display the default startup page.
        com.mathworks.mlservices.MLHelpServices.invoke();
        return;
    end
    
    if strncmpi(topic, 'mupad/', 6)
        if ~mupaddoc(topic)
            showNoReferencePageFound;
        end
        return;
    end
    
    [operator,topic] = matlab.internal.language.introspective.isOperator(topic);
    if ~operator
        if topic(end) == '/'
            topic = topic(1:end-1);
        end

        if showProductPage(topic)
            return;
        end
        
        [possibleTopics, isPrimitive] = helpUtils.resolveDocTopic(topic, isVariable);
        
        if isPrimitive
            disp(helpUtils.getInstanceIsa(varName, topic));
            return;
        end
    else
        [~,possibleTopics.topic] = fileparts(topic);
        possibleTopics.isElement = false;
    end
    
    if ~displayDocPage(possibleTopics) && ~showHelpwin(topic)
        docsearch(topic)
    end
end

function [showClassicDoc, topic, search, varIndex] = examineInputs(varargin)
    showClassicDoc = 0;
    topic = [];
    search = 0;
    varIndex = 0;

    for i = 1:numel(varargin)
        argName = varargin{i};
        if isstring(argName)
            if ~isscalar(argName)
                MException(message('MATLAB:doc:MustBeSingleString')).throwAsCaller;
            end
            argName = char(strip(argName));
        elseif ischar(argName)
            argName = strtrim(argName);
        else
            argName = class(argName);
            varIndex = i;
        end

        if strcmp(argName, '-classic')
            showClassicDoc = 1;
        else
            % assume this is the location.
            if ~isempty(topic)
                topic = sprintf('%s %s', topic, argName);
                search = 1;
            else
                topic = argName;
            end
        end
    end
end
    
function success = showProductPage(topic)
    success = com.mathworks.mlservices.MLHelpServices.showProductPage(topic);
end

function success = displayDocPage(possibleTopics)
    success = false;
    for topic = possibleTopics
        if com.mathworks.mlservices.MLHelpServices.showReferencePage(topic.topic, topic.isElement)
            success = true;
            return;
        end
    end
end
   
function foundTopic = showHelpwin(topic)
    % turn off the warning message about helpwin being removed in a future
    % release
    s = warning('off', 'MATLAB:helpwin:FunctionToBeRemoved');
    
     if helpUtils.isLiveFunctionAndHasDocumentation(topic)
        internal.help.livecodedoc.mlxdoc(topic);
        foundTopic = true;
    else
        foundTopic = helpwin(topic, '', '', '-doc');
    end

    % turn the warning message back on if it was on to begin with
    warning(s.state, 'MATLAB:helpwin:FunctionToBeRemoved');
end

function showNoReferencePageFound(topic)
    noFuncPage = helpUtils.underDocroot('nofunc.html');
    if ~isempty(noFuncPage)
        displayFile(noFuncPage);
    else
        error(message('MATLAB:doc:InvalidTopic', topic));
    end
end

function displayFile(htmlFile)
    % Display the file inside the help browser.
    web(htmlFile, '-helpbrowser');
end
