function updateFromXML(helpContainer, xmlFilePath)
    % UPDATEFROMXML - update the help comments stored in a HelpContainer
    % object with strings extracted from input XML M-help file.
    %
    % Usage:
    %   UPDATEFROMXML(HELPCONTAINER, XMLFILEPATH) takes
    %   the helpContainer and updates its help contents with text extracted
    %   from the XML file whose path is XMLFILEPATH.
    %
    
    % Copyright 2009 The MathWorks, Inc.
    narginchk(2,2);
    
    parseInputs(helpContainer, xmlFilePath);
    
    dom = xmlread(xmlFilePath);
    
    docRootNode = dom.getDocumentElement;
    
    updateMainHelp(docRootNode, helpContainer);
    
    if helpContainer.isClassHelpContainer
        classInfoNode = getUnaryNode(docRootNode, 'class-info');
        
        updateConstructorHelp(classInfoNode, helpContainer);
        
        for elementType = matlab.internal.language.introspective.getSimpleElementTypes            
            updateAllSimpleElementsHelp(classInfoNode, helpContainer, elementType.keyword, elementType.node);
        end
        
        updateAllMethodsHelp(classInfoNode, helpContainer);
    end
    
end

%%------------------------------------------------------------------------
function parseInputs(helpContainer, xmlFilePath)
    % PARSEINPUTS - checks that the input arguments are of the correct
    % type.
    if ~isa(helpContainer, 'matlab.internal.language.introspective.containers.abstractHelpContainer')
        error(message('MATLAB:introspective:updateFromXML:InvalidHelpContainer'));
    end
    
    if ~ischar(xmlFilePath)
        error(message('MATLAB:introspective:updateFromXML:InvalidXmlPath'));
    end
    
    [~, name] = fileparts(xmlFilePath);
    
    if ~strcmp(name, helpContainer.mFileName) % tested on M-functions only!
        error(message('MATLAB:introspective:updateFromXML:InconsistentInput'));
    end
    
end

%%------------------------------------------------------------------------
function updateMainHelp(docRootNode, helpContainer)
    % UPDATEMAINHELP - updates the help stored in the help container with
    % the relevant text found in the XML file.
    helpNode = getUnaryNode(docRootNode, 'mainHelp');
    
    if ~isempty(helpNode)
        mainHelpTxt = char(helpNode.getTextContent);
        
        if ~isempty(mainHelpTxt)
            helpContainer.updateHelp(mainHelpTxt);
        end
    end
end

%%------------------------------------------------------------------------
function updateConstructorHelp(classInfoNode, helpContainer)
    % UPDATECONSTRUCTORHELP - checks if the XML file contains any new text
    % for the constructor.  If it did find it, the constructor help
    % container is updated with the next text.
    ConstructorsNode = getUnaryNode(classInfoNode, 'constructors');
    
    if ~isempty(ConstructorsNode)
        constructorInfoNode = getUnaryNode(ConstructorsNode, 'constructor-info');
        
        childHelpNode = getUnaryNode(constructorInfoNode, 'help');
        
        constructorHelpTxt = char(childHelpNode.getTextContent);
        
        if ~isempty(constructorHelpTxt)
            constructorHelpContainer = helpContainer.getConstructorHelpContainer();
            constructorHelpContainer.updateHelp(constructorHelpTxt);
        end
    end
end

%%------------------------------------------------------------------------
function updateAllSimpleElementsHelp(classInfoNode, helpContainer, elementKeyword, elementTag)
    % UPDATEALLSIMPLEELEMENTSHELP - setups the inputs for and invokes
    % UPDATECLASSMEMBERHELPCONTAINERS to extract help updates for
    % simple elements.
    SimpleElementsNode = getUnaryNode(classInfoNode, elementKeyword);
    
    if ~isempty(SimpleElementsNode)
        % True if class has none updated or has none to begin with
        elementInfoNodeList = SimpleElementsNode.getElementsByTagName(elementTag);
        
        getElementHelpContainerFcnHandle = @(elementName) helpContainer.getSimpleElementHelpContainer(elementKeyword, elementName);
        
        updateClassMemberHelpContainers(elementInfoNodeList, getElementHelpContainerFcnHandle);
    end
end


%%------------------------------------------------------------------------
function updateAllMethodsHelp(classInfoNode, helpContainer)
    % UPDATEALLMETHODSHELP - setups the inputs for and invokes
    % UPDATECLASSMEMBERHELPCONTAINERS to extract help updates for
    % methods.
    MethodsNode = getUnaryNode(classInfoNode, 'methods');
    
    if ~isempty(MethodsNode)
        methodInfoNodeList = MethodsNode.getElementsByTagName('method-info');
        
        getMethodHelpContainerFcnHandle = @(methodName) helpContainer.getMethodHelpContainer(methodName);
        
        updateClassMemberHelpContainers(methodInfoNodeList, getMethodHelpContainerFcnHandle);
    end
end

%%------------------------------------------------------------------------
function updateClassMemberHelpContainers(XmlNodeList, getMember)
    % updateClassMemberHelpContainers - first extracts the updated help
    % comments for all class member nodes in the XML and for any non-empty help
    % the corresponding class member help container object is updated with the
    % newly translated help.
    
    len = XmlNodeList.getLength;
    
    for i = 0:len-1
        node = XmlNodeList.item(i);
        childHelpNode = getUnaryNode(node, 'help');
        
        if ~isempty(childHelpNode) % class member help needs updating
            
            helpTxt = char(childHelpNode.getTextContent);
            memberName = char(node.getAttribute('name'));
            
            memberHelpContainer = getMember(memberName);
            memberHelpContainer.updateHelp(helpTxt);
        end
    end
end

%%------------------------------------------------------------------------
function node = getUnaryNode(parentNode, nodeTag)
    % GETUNARYNODE - retrieves the 1st element in node list with tag name "nodetag"
    nodeList = parentNode.getElementsByTagName(nodeTag);
    if nodeList.getLength
        node = nodeList.item(0);
    else
        node = [];
    end
end