function [helpNode, helpstr, fcnName, found] = help2xml(dom, topic, pagetitle, helpCommandOption)
%HELP2HTML Convert M-help to an HTML form.
%
%   This file is a helper function used by the HelpPopup Java component.
%   It is unsupported and may change at any time without notice.

%   Copyright 2007-2010 The MathWorks, Inc.

% Some initializations
if nargin > 1 && isstring(topic)
    topic = char(topic);
end

if nargin > 2 && isstring(pagetitle)
    pagetitle = char(pagetitle);
end

if nargin > 3
    if isstring(helpCommandOption)
        helpCommandOption = char(helpCommandOption);
    end
else
    helpCommandOption = '-helpwin';
end

helpNode = dom.createElement('help-topic');
dom.getDocumentElement.appendChild(helpNode);

% Is this a help string to display?
if (nargin>0 && (iscell(topic) || size(topic,1) > 1 || any(find(topic==newline))))
    % Set title to default, or use the one provided
    if nargin < 2 || isempty(pagetitle)
        pgtitle = getString(message('MATLAB:help2xml:MATLABHelp'));
    else
        pgtitle = pagetitle;
    end
    pgtitle = fixsymbols(pgtitle);

    if iscell(topic) || size(topic,1) > 1
       helpstr = '';
       for y = 1:size(topic,1)
           helpstr = sprintf('%s%s\n',helpstr,deblank(char(topic(y,:))));
       end
    else
       helpstr = char(topic);
    end

    helpstr = fixsymbols(helpstr);

    addHeaderInfo(dom, helpNode, pgtitle, pgtitle, {}, {});
    % TODO: Is this OK?
    fcnName = '';
    found = ~isempty(helpstr);
    return;
end

[isOperator, topic] = matlab.internal.language.introspective.isOperator(topic, true);

[helpstr, docTopic] = help(topic, helpCommandOption);
found = ~isempty(helpstr);

classInfo = [];
titleFormat = getString(message('MATLAB:help2xml:MATLABFileHelpFormat'));
viewFormat = getString(message('MATLAB:help2xml:ViewCodeFormat'));
openFunction = 'edit';
nameForTitle = '';

[localTopic, hasLocalFunction] = matlab.internal.language.introspective.fixLocalFunctionCase(topic);

if hasLocalFunction
    fcnName =  matlab.internal.language.introspective.extractCaseCorrectedName(localTopic, topic);
    qualifiedTopic = localTopic;
else
    if ~isOperator
        nameResolver = matlab.internal.language.introspective.resolveName(topic,'',false);
        
        if ~nameResolver.isUnderqualified
            classInfo = nameResolver.classInfo;
        end
        
        if ~isempty(nameResolver.classInfo) && nameResolver.classInfo.isMethod
            nameForTitle = buildMethodTitleName(nameResolver.classInfo);
        end
    end
    if ~isempty(classInfo)
        fcnName = classInfo.fullTopic;
        if classInfo.isPackage
            viewFormat = [];
        else
            % For local methods and properties, we won't have a file path
            % here, so replace the method name with .m to see if we have
            % a MATLAB file containing help.
            location = which(regexprep(classInfo.definition, '>[^>]*$', ''));
            [~,titleFormat,viewFormat,openFunction] = prepareHeader(location);
        end
        qualifiedTopic = fcnName;
    else
        % Create the formats that we will use for the header text.
        [fcnName,titleFormat,viewFormat,openFunction] = prepareHeader(topic);

        % If there is a format to view, there needs to be a path to view
        if isempty(viewFormat)
            if isOperator
                [~, qualifiedTopic] = fileparts(topic);
                if strcmp(qualifiedTopic, topic)
                    % This is help for a special character
                    qualifiedTopic = 'matlab\ops';
                else
                    fcnName = qualifiedTopic;
                end
            else
                qualifiedTopic = topic;
            end
        else
            [qualifyingPath, fcnName, extension] = fileparts(fcnName);
            [fcnName, qualifyingPath] = matlab.internal.language.introspective.fixFileNameCase([fcnName, extension], qualifyingPath);
            qualifiedTopic = fullfile(qualifyingPath, fcnName);
        end
    end
end

if ~found
    if ~strcmp(helpCommandOption, '-doc')
        addHeaderInfo(dom, helpNode, fcnName, 'MATLAB File Help', {}, {});
    end
    return;
end

if isempty(topic)
    title = getString(message('MATLAB:help2xml:MATLABFileHelpDefaultTopics'));
else
    if isempty(nameForTitle)
        nameForTitle = fcnName;
    end
    title = sprintf(titleFormat, nameForTitle);
end

headerText = {};
headerActions = {};

% Setup the left side link (view code for...)
if ~isempty(qualifiedTopic)
    if ~isempty(viewFormat)
        headerText = {sprintf(viewFormat, fcnName)};
        headerActions = {helpUtils.makeDualCommand(openFunction, qualifiedTopic)};
    end
end

if ~isempty(docTopic)
    headerText = [headerText, {getString(message('MATLAB:help2xml:GoToOnlineDoc', fcnName))}];
    headerActions = [headerActions, {helpUtils.makeDualCommand('doc', docTopic)}];
end

addHeaderInfo(dom, helpNode, fcnName, title, headerText, headerActions);

if ~isempty(classInfo) && displayClass(classInfo)
    % We'll display class information even if no help was found, since
    % there is likely to be interesting information in the metadata.
    try
        fcnName = handleClassInfo(classInfo,fcnName,dom,helpNode);
    catch
        % revert to function help
        found = ~isempty(helpstr);
    end
end

%==========================================================================
function [fcnName,titleFormat,viewFormat,openFunction] = prepareHeader(fcnName)
% determine the class of help, and prepare header strings for it
titleFormat = getString(message('MATLAB:help2xml:MATLABFileHelpFormat'));
viewFormat = '';
openFunction = 'edit';
switch exist(fcnName, 'file')
case 0
    % do nothing
case 2
    % M File or text file
    viewFormat = getString(message('MATLAB:help2xml:ViewCodeFormat'));
case 4
    % MDL File
    viewFormat = getString(message('MATLAB:help2xml:OpenModelFormat'));
    titleFormat = getString(message('MATLAB:help2xml:ModelHelpFormat'));
    openFunction = 'open';
case 6
    % P File
    mFcnName = which(fcnName);
    mFcnName(end) = 'm';
    if exist(mFcnName, 'file')
        % P File with the M File still available
        % This should always be the case, since there is no help without the M
        viewFormat = getString(message('MATLAB:help2xml:ViewCodeFormat'));
        % strip the .p extension if it had been specified
        fcnName = regexprep(fcnName, '\.p$', '');
    end
otherwise
    % this item exists, but is not viewable, so there is no location or format
    % however, fcnName can still be case corrected if there is a which value
    newFcnName = matlab.internal.language.introspective.extractCaseCorrectedName(which(fcnName), fcnName);
    if ~isempty(newFcnName)
        fcnName = newFcnName;
    end
end

%==========================================================================
function addHeaderInfo(dom,helpNode,topic,title,headerText,headerActions)
addTextNode(dom,helpNode,'topic',topic);
addTextNode(dom,helpNode,'title',title);

if ~isempty(headerText)
    headersNode = dom.createElement('headers');
    for i = 1:length(headerText)
        headerNode = dom.createElement('header');
        addTextNode(dom,headerNode,'text',headerText{i});
        if ~isempty(headerActions{i})
            addTextNode(dom,headerNode,'action',headerActions{i});
        end
        headersNode.appendChild(headerNode);
    end
    helpNode.appendChild(headersNode);
end

%==========================================================================
function topic = handleClassInfo(classInfo,topic,dom,helpNode)
className = matlab.internal.language.introspective.makePackagedName(classInfo.packageName, classInfo.className);

metacls = meta.class.fromName(className);
if ~isempty(metacls)
    if classInfo.isConstructor
        topic = classInfo.className;
        constructorMeta = findClassMemberMeta(metacls.Methods, topic);
        helpUtils.class2xml.buildConstructorXml(constructorMeta, dom, helpNode);

    elseif classInfo.isMethod
        methodName = regexp(topic,'\w+$','once','match');

        methodMeta = findClassMemberMeta(metacls.Methods, methodName);
        helpUtils.class2xml.buildMethodXml(metacls, methodMeta, dom, helpNode);

    elseif classInfo.isSimpleElement
        elementName = regexp(topic,'\w+$','once','match');
        [classElement, elementKeyword] = matlab.internal.language.introspective.getSimpleElement(metacls, elementName);
        switch elementKeyword
        case 'properties'
            helpUtils.class2xml.buildPropertyXml(metacls, classElement, dom, helpNode);
        case 'events'
            helpUtils.class2xml.buildEventXml(metacls, classElement, dom, helpNode);
        case 'enumeration'
            helpUtils.class2xml.buildEnumerationXml(metacls, classElement, dom, helpNode);
        end

    elseif classInfo.isClass
        classFilePath = classInfo.minimizePath;
        c2x = getClass2XmlObj(classFilePath, metacls);
        c2x.buildClassXml(dom,helpNode);
    end
end


%==========================================================================
function ret = displayClass(classInfo)
ret = classInfo.isClass || classInfo.isMethod || classInfo.isSimpleElement;

%==========================================================================
function addTextNode(dom,parent,name,text)
child = dom.createElement(name);
child.appendChild(dom.createTextNode(text));
parent.appendChild(child);

%==========================================================================
function class2xmlObj = getClass2XmlObj(classFilePath, metaInfo)
% GETCLASS2XMLOBJ - helper method that constructs a HELPUTILS.CLASS2XML
% object.
helpContainerObj = matlab.internal.language.introspective.containers.HelpContainerFactory.create(classFilePath, 'metaInfo', metaInfo);
class2xmlObj = helpUtils.class2xml(helpContainerObj);


%==========================================================================
function metaData = findClassMemberMeta(metaArray, memberName)
% FINDCLASSMEMBERMETA - given an array of class member meta data objects,
% FINDCLASSMEMBERMETA returns the meta data object with the name
% MEMBERNAME.
metaData = metaArray{cellfun(@(c)strcmp(c.Name, memberName), metaArray)};

% Truncate to only first found meta data object because class members may appear multiple
% times.
metaData = metaData(1);

%==========================================================================
function nameForTitle = buildMethodTitleName(classInfo)
fullClassName = matlab.internal.language.introspective.makePackagedName(classInfo.packageName, classInfo.className);
nameForTitle = sprintf('%s (%s)', classInfo.element, fullClassName);

