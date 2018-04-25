classdef (Hidden) class2xml
    % CLASS2XML a helper class used to export class metadata and help into XML.
    
    % Copyright 2009 The MathWorks, Inc.
    properties (Access=private)
        helpContainer;
        classMetaData;
    end
    
    methods
        function this = class2xml(helpContainer)
            % class2xml constructor takes one input argument:
            % a class file help container.
            this.helpContainer = helpContainer;
            
            this.classMetaData = helpContainer.mainHelpContainer.metaData;
        end
        
        function buildClassXml(this,dom,helpNode)
            % buildClassXml builds an XML representation of a class.
            
            % First get some basic attributes of the class.
            className = this.classMetaData.Name;
            atts = struct(...
                'name',className,...
                'hidden',mat2str(this.classMetaData.Hidden),...
                'sealed',mat2str(this.classMetaData.Sealed),...
                'constructonload',mat2str(this.classMetaData.ConstructOnLoad));
            
            classElt = dom.createElement('class-info');
            helpNode.appendChild(classElt);
            
            addAttributes(dom,classElt,atts);
            
            if ~isempty(this.classMetaData.SuperClasses)
                supernode = dom.createElement('super-classes');
                appendSuperClassNodes(this.classMetaData,supernode,dom);
                classElt.appendChild(supernode);
            end
            
            %---------------- setup constructor node-------------
            constructorIterator = this.helpContainer.getConstructorIterator();
            createConstructorNodeFuncHandle = @(~, constructorMeta, docNode)createConstructorNode(constructorMeta, docNode);
            this.appendClassMemberNodes(dom, classElt, constructorIterator, 'constructors', createConstructorNodeFuncHandle);


            %---------------- setup simple element nodes-------------
            appendSimpleElementNodes(this, dom, classElt, 'properties', @createPropertyNode);
            appendSimpleElementNodes(this, dom, classElt, 'events', @createEventNode);
            appendSimpleElementNodes(this, dom, classElt, 'enumeration', @createEnumerationNode);
            
            %---------------- setup method nodes-------------
            methodIterator = this.helpContainer.getMethodIterator();
            this.appendClassMemberNodes(dom, classElt, methodIterator, 'methods', @createMethodNode);
        end
        
    end
    
    methods (Static)
        function buildConstructorXml(constructorMeta, dom,helpNode)
            % BUILDCONSTRUCTORXML - builds an XML representation of a
            % class constructor.
            constructorNode = createConstructorNode(constructorMeta, dom);
            helpNode.appendChild(constructorNode);
        end
        
        function buildMethodXml(classMetaData, metaMethod, dom, helpNode)
            % BUILDMETHODXML - builds an XML representation of a class method.
            
            methodNode = createMethodNode(classMetaData,metaMethod,dom);
            helpNode.appendChild(methodNode);
        end
        
        function buildPropertyXml(classMetaData, propMeta,dom,helpNode)
            % BUILDPROPERTYXML builds an XML representation of a class property.
            
            propertyNode = createPropertyNode(classMetaData, propMeta, dom);
            helpNode.appendChild(propertyNode);
        end

        function buildEventXml(classMetaData, eventMeta,dom,helpNode)
            % BUILDEVENTXML builds an XML representation of a class event.
            
            eventNode = createEventNode(classMetaData, eventMeta, dom);
            helpNode.appendChild(eventNode);
        end
        
        function buildEnumerationXml(classMetaData, enumMeta,dom,helpNode)
            % BUILDENUMERATIONXML builds an XML representation of a class enumeration.
            
            enumerationNode = createEnumerationNode(classMetaData, enumMeta, dom);
            helpNode.appendChild(enumerationNode);
        end
    end
    
    methods (Access=private)
        
        function appendSimpleElementNodes(this, dom, classElt, elementKeyword, createMemberNode)
            memberIterator = this.helpContainer.getSimpleElementIterator(elementKeyword);
            this.appendClassMemberNodes(dom, classElt, memberIterator, elementKeyword, createMemberNode);
        end
        
        function appendClassMemberNodes(this, dom, classElt, memberIterator, parentNodeName, createMemberNode)
            % APPENDCLASSMEMBERNODES - Creates and appends nodes
            % corresponding to class members i.e. methods and properties to
            % the DOM object.
            if memberIterator.hasNext
                ParentNode = dom.createElement(parentNodeName);
                classElt.appendChild(ParentNode);
                this.createNodesForChildren(ParentNode, memberIterator, createMemberNode, dom);
            end
        end
        
        
        function createNodesForChildren(this,parentNode,memberIterator, createMemberNode, dom)
            % CREATENODESFORCHILDREN - iterates through all the class
            % member help containers creating an XML node for each of these
            % objects through the method CREATECHILDNODE.
            while memberIterator.hasNext()
                memberHelpContainerObj = memberIterator.next();
                
                memberNode = createChildNode(this, memberHelpContainerObj, createMemberNode, dom);
                
                parentNode.appendChild(memberNode);
            end
        end
        
        function memberNode = createChildNode(this, memberHelpContainerObj, createMemberNode, dom)
            % CREATECHILDNODE - takes a class member help container object
            % and creates an XML node.
            memberNode = createMemberNode(this.classMetaData, memberHelpContainerObj.metaData, dom);
            
            helpStr = memberHelpContainerObj.getHelp;
            
            h1Flag = ~this.helpContainer.onlyLocalHelp;
            
            if h1Flag
                helpStr = correctH1Line(helpStr, memberHelpContainerObj.Name);
            end
            
            appendHelpTextNode(memberNode, helpStr, dom, h1Flag);
            
        end
    end
end

function node = createConstructorNode(constructorMeta, docNode)
    % CREATECONSTRUCTORNODE - creates an XML node for the class
    % constructor.
    node = docNode.createElement('constructor-info');
    atts = struct('name',constructorMeta.Name);
    addAttributes(docNode,node,atts);
end

function node = createMethodNode(classMetaData,metaMethod,docNode)
    % CREATEMETHODNODE - Creates an XML node representing a method.
    node = docNode.createElement('method-info');
    
    atts = struct(...
        'name', metaMethod.Name,...
        'access', mat2accStr(metaMethod.Access),...
        'static', mat2str(metaMethod.Static),...
        'abstract', mat2str(metaMethod.Abstract),...
        'sealed', mat2str(metaMethod.Sealed),...
        'hidden', mat2str(metaMethod.Hidden));
    
    if (metaMethod.DefiningClass ~= classMetaData)
        atts.definingclass = metaMethod.DefiningClass.Name;
    end
    
    addAttributes(docNode,node,atts);
end


function node = createPropertyNode(classMetaData,metaProperty,docNode)
    % createPropertyNode - Creates an XML node representing for a property.
    node = docNode.createElement('property-info');
    
    atts = struct(...
        'name', metaProperty.Name,...
        'getaccess', mat2accStr(metaProperty.GetAccess),...
        'setaccess', mat2accStr(metaProperty.SetAccess),...
        'sealed', mat2str(metaProperty.Sealed),...
        'dependent', mat2str(metaProperty.Dependent),...
        'constant', mat2str(metaProperty.Constant),...
        'abstract', mat2str(metaProperty.Abstract),...
        'transient', mat2str(metaProperty.Transient),...
        'hidden', mat2str(metaProperty.Hidden),...
        'getobservable', mat2str(metaProperty.GetObservable),...
        'setobservable', mat2str(metaProperty.SetObservable));
    
    if (metaProperty.DefiningClass ~= classMetaData)
        atts.definingclass = metaProperty.DefiningClass.Name;
    end
    
    addAttributes(docNode,node,atts);
end

function node = createEventNode(classMetaData,metaEvent,docNode)
    % createEventNode - Creates an XML node representing for an event.
    node = docNode.createElement('event-info');
    
    atts = struct(...
        'name', metaEvent.Name,...
        'notifyaccess', mat2accStr(metaEvent.NotifyAccess),...
        'listenaccess', mat2accStr(metaEvent.ListenAccess),...
        'hidden', mat2str(metaEvent.Hidden));
       
    if (metaEvent.DefiningClass ~= classMetaData)
        atts.definingclass = metaEvent.DefiningClass.Name;
    end
    
    addAttributes(docNode,node,atts);
end

function node = createEnumerationNode(~,metaEnumeration,docNode)
    % createEnumerationNode - Creates an XML node representing for an enumeration.
    node = docNode.createElement('enumeration-info');
    
    atts = struct(...
        'name', metaEnumeration.Name);
    
    addAttributes(docNode,node,atts);
end

function h1Line = correctH1Line(h1Line, itemName)
    % CORRECTH1LINE - helper function that removes the name of the property
    % or method if it precedes the class member's help comments.
    h1Regexp = ['^\s*(' itemName '(\.\w*)?\>\s*(-\s*)?)?'];
    h1Line = regexprep(h1Line,h1Regexp,'','ignorecase');
end

function addAttributes(docNode,node,attsStruct)
    % ADDATTRIBUTES - helper function that appends attributes to the input
    % XML node.
    fn = fieldnames(attsStruct);
    for i = 1:length(fn)
        fieldname = fn{i};
        xmlAtt = docNode.createAttribute(fieldname);
        xmlAtt.appendChild(docNode.createTextNode(attsStruct.(fieldname)));
        node.getAttributes.setNamedItem(xmlAtt);
    end
end

function appendSuperClassNodes(meta,node,docNode)
    % APPENDSUPERCLASSNODES - helper function that adds super class
    % information to the class XML.
    supercls = meta.SuperClasses;
    if ~isempty(supercls)
        for j = 1:length(supercls)
            super = supercls{j};
            superclsnode = docNode.createElement('super-class');
            supername = docNode.createAttribute('name');
            supername.appendChild(docNode.createTextNode(super.Name));
            superclsnode.getAttributes.setNamedItem(supername);
            node.appendChild(superclsnode);
        end
    end
end

function appendHelpTextNode(parentNode, helpStr, dom, h1Flag)
    % appendHelpTextNode - appends a node to the parent node if there is
    % non-empty help.
    if ~isempty(helpStr)
        if h1Flag
            h1 = dom.createElement('h1-line');
        else
            h1 = dom.createElement('help');
        end
        h1.appendChild(dom.createTextNode(helpStr));
        parentNode.appendChild(h1);
    end
end

function str = mat2accStr(accMat)
    % mat2accStr - helper function to produce an access string from
    % an access attribute value.
    if isa(accMat, 'char')
        str = accMat;
    elseif isempty(accMat)
        str = 'private';
    elseif isa(accMat, 'cell') 
        cnames = cell(length(accMat), 1);
        for k = 1:length(accMat)
            if isa(accMat{k}, 'meta.class')
                cnames{k} = accMat{k}.Name;
            end
        end
        str = sprintf('%s, ', cnames{:});
        str(end-1:end) = [];
    elseif isa(accMat, 'meta.class')
        str = accMat.Name;
    end
end
