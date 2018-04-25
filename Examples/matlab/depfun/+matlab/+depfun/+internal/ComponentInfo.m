classdef ComponentInfo < handle
    properties
        DataFile = fullfile(fileparts(mfilename('fullpath')), ...
                            'component_data.xml');
    end
    
    properties(Access = private)
        info
        ixf = matlab.depfun.internal.IxfVariables('/');
    end
    
    methods (Access = private)
       
        function ReadDataFile(ci)
            xDoc = xmlread(ci.DataFile); 
            ProcessNode(xDoc, 'component', @ProcessComponentNode, ci.info);
        end
        
        function nName = normalizeComponentName(ci, cName)
            % Substitute variables into the name
            nName = ci.ixf.unbind(cName);
            % Chop off any terminating file separators
            if nName(end) == '\' || nName(end) == '/'
                nName(end) = '';
            end
        end
        
        function tf = componentHasData(ci, component, field)
            tf = false;
            component = ci.normalizeComponentName(component);
            if isKey(ci.info, component)
                tf = isfield(ci.info(component),field);
            end            
        end
        
        function data = getComponentData(ci, component, field)
            data = '';
            component = ci.normalizeComponentName(component);
            if isKey(ci.info, component)
                if isfield(ci.info(component),field)
                    data = ci.info(component);
                    data = data.(field);
                end
            end
        end
        
    end
    
    methods
        
        function c = ComponentInfo
             c.info = containers.Map('KeyType','char','ValueType','any');
             ReadDataFile(c);
        end
        
        function tf = AugmentSearchPath(ci, component)
            tf = componentHasData(ci, component, 'SearchPath');
        end
        
        function c = ContentsDirectory(ci, component)
            c = getComponentData(ci, component, 'ContentsDir');
            c = ci.ixf.bind(c);
        end
        
        function c = ToolboxLocation(ci, component)
            c = getComponentData(ci, component, 'SearchPath');
        end
        
        function r = ComponentDirectory(ci, component)
            r = getComponentData(ci, component, 'ComponentDir');
            r = ci.ixf.bind(r);
        end
        
        function c = ComponentName(ci, component)
            c = getComponentData(ci, component, 'Name');
        end
    end
end

function ProcessNode(xDoc, name, fcn, info)

    list = xDoc.getElementsByTagName(name);
    count = 0;

    % Zero-based indexing, courtesy of XERCES library.
    for k=0:list.getLength-1
        % Get the root of the element list (which XERCES has given to us
        % in the form of a tree).
        node = list.item(k);
        
        % If the node has type ELEMENT_NODE, it is one of the nodes
        % we asked for in getElementByTagName. Call the element-specific
        % processing function.
        if node.getNodeType == node.ELEMENT_NODE 
            fcn(node, info);
            count = count + 1;
        end
    end
end

function ProcessComponentNode(node, info)
    component = char(node.getAttribute('name'));
    ProcessNode(node, 'searchpath', ...
        @(xDoc, info)ProcessSearchPathNode(component, xDoc, info), info);
end
        
function ProcessSearchPathNode(cLoc, node, info)
    cname = char(node.getAttribute('component'));
    pth = char(node.getAttribute('componentDir'));
    contentsDir = char(node.getAttribute('contentsDir'));
    if isKey(info, cLoc)
        data = info(cLoc);
    end
    
    data.Name = cname;
    data.ComponentDir = pth;
    if ~isempty(contentsDir) 
        data.ContentsDir = [pth '/' contentsDir];
    else
        data.ContentsDir = pth;
    end
    [~, data.SearchPath] = fileparts(pth);
    info(cLoc) = data;  %#ok
end
