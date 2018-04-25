classdef ContextMenuManager < handle
    % CONTEXTMENUMANAGER handle class from the ContextMenuFramework
    
    % This class takes care of creating a peermodel server instance for the
    % ContextMenuNamespace provided. It creates peernodes for context menus
    % that are to be displayed on the client side by scanning through an
    % XML file containing a list of all the context menu options. 
    % Given below is a sample xml structure from the XML file. 
    % <ContextMenu ID="ContextMenu">        
    %   <Context MatchContext="component1,row" ID="Context1">
    %     <ActionGroup Expanded="True" ID="copyAction" >
    %        <Action ID="Action1" MessageID="Copy Action"/
    %     </ActionGroup>  
    %     <MenuSeparator/>
    %   </Context>    
    % </ContextMenu>
  
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetObservable=true, SetAccess='protected')       
       PeerModelServer;       
    end 
    
    properties (SetAccess='protected')     
       Root = "ContextMenuRoot";
       Namespace = "/ContextMenuManager";
    end

    
    methods(Access='protected')    
        % Creates a rootNode of the given rootType specfied
        function createRoot(this, RootType)
            if isempty(this.PeerModelServer.getRoot())
                this.PeerModelServer.createRoot(RootType);
            end
        end 
    
        % This function creates the ContextPeerMenu by iterating recurively
        % starting from the xmlDoc. actionNamespace is used to check if
        % <Action> entires are valid actions in the provided namespace.
        function addMenuActionsToPeerNode(this, xmlDoc, actionNamespace)
            actionPeerModelServer = peermodel.internal.PeerModelManagers.getServerManager(actionNamespace);
            rootNode = this.getRoot();
            if ~isempty(actionPeerModelServer)
                this.createPeerContextMenu(xmlDoc, rootNode, actionPeerModelServer);                
            end                
        end 
        
        % Given a string, this function fetches the value of the key from
        % the message catalog.        
        function value = getMessageCatalogString(~, key)
           try
               value = getString(message(sprintf(...
                        'MATLAB:codetools:contextmenus:%s',key)));
           catch
               value = key;
           end                        
        end
        
        % Given an xmlNode, this function returns the tag name as the name
        % and a list of all the node properties are returned as a structure
        % 'attributes'. If True or False are node attribute values, they
        % are converted to logicals in MATLAB. MessageID attribute fetches
        % the value from MessageCatalog and stores them as 'DisplayName'
        % properties. This is the label that would show up as ContextMenu
        % options on the client side. 
        function [name, attributes] = getMenuProperties(this, xmlNode)
            name = toCharArray(getNodeName(xmlNode))';            
            attributes = struct;
            if hasAttributes(xmlNode)
               childAttr = getAttributes(xmlNode);                       
               for count = 1: getLength(childAttr)
                   attr = toCharArray(toString(item(childAttr,count-1)))';                
                   values = strsplit(attr, '='); 
                   if ~isempty(values) && (length(values)==2)
                       attrName = values{1}; 
                       attrVal = regexprep(values{2}, '(^"|"$)', '');
                       if (any(strcmpi(attrVal,{'true','false'})))
                           attrVal = str2num(lower(attrVal));
                       end                      
                       if strcmpi(attrName, 'MessageID')
                           attrName = 'DisplayName';
                           attrVal = this.getMessageCatalogString(attrVal);                      
                       end
                       attributes.(attrName) = attrVal ;
                   end                   
               end                       
            end
        end
        
        % This is the recursive function that parses through the entire xml tree and 
        % adds them as children to parentNode starting from the rootNode. 
        % XML Tags 'ContextMenu', 'Context' and 'ActionGroup' have recursive
        % calls. 'Action' types are just added as leaf nodes.
        % The peernode is created with Type as the XML Tag name and
        % properties are a list of XML attributes. 
        function createPeerContextMenu(this, xmlDoc, parentNode,actionPeerModelServer)
            if hasChildNodes(xmlDoc)
                childNodes = getChildNodes(xmlDoc);
                for index = 1: getLength(childNodes)
                   childNode = item(childNodes, index-1); 
                   [name, attributes] = this.getMenuProperties(childNode);                   
                   if (~strcmp(name,'#text') && ~strcmp(name,'#comment'))
                        if (strcmp(name, 'ActionGroup') || strcmp(name, 'Context'))                        
                            actionGroup = this.addPeerChild(parentNode, name, attributes);  
                            this.createPeerContextMenu(childNode, actionGroup, actionPeerModelServer);  
                        elseif strcmp(name,'Action')
                             if (this.validateAction(attributes, actionPeerModelServer))
                                this.addPeerChild(parentNode, name, attributes);  
                             end
                        elseif strcmp(name, 'MenuSeparator')
                            this.addPeerChild(parentNode, name, attributes);
                        elseif strcmp(name, 'ContextMenu')
                            parentNode.setProperties(attributes);
                            this.createPeerContextMenu(childNode, parentNode, actionPeerModelServer);  
                        end
                   end
                end
            end
        end
        
        % Adds child of type 'name' along with attributes if present to
        % node and returns newly created childNode.        
        function peerNode = addPeerChild(~, node, name, attributes)
            if isstruct(attributes) && ~isempty(fieldnames(attributes))
                peerNode = node.addChild(name, attributes);
            else
                peerNode = node.addChild(name);
            end
        end
              
        % For a given list of attributes, this function validates whether the ID specified is a valid
        % registered action with the ActionDataService. The peerModelServer
        % of the ActionDataService should have a child peernode with the same ID. 
        function isValid = validateAction(~, actionProps, peerModelServer)
            isValid = false;
            if ~(isfield(actionProps, 'ID'))
                warning(message('MATLAB:codetools:datatoolsservices:NoActionID'));
            else 
                actionID = actionProps.ID;
                peerNode = peerModelServer.getNodeByProperty('id',actionID);
                if ~isempty(peerNode)                                            
                    isValid = true;
                else
                    warning(message('MATLAB:codetools:datatoolsservices:InvalidActionForID',actionID));
                end
            end
        end                   
    end        
    
    methods (Access = 'public')
        % This function creates the contextmenu options by adding them as
        % children to the rootNode. 
        % queryString: This is the queryString selector of the target node on the client side. 
        % actionNamespace: The namspace containing a list of all registered
        % actions that are to be defined as context menus. 
        % fileName: Absolute Path of the xml file containing the predefined contextmenu options.
        function createContextMenus(this, queryString, actionNamespace, fileName)
            if exist(fileName,'file')
                xmlDoc = xmlread(fileName);                 
                nodeProps = struct('queryString',queryString,'actionNamespace',actionNamespace);
                this.getRoot().setProperties(nodeProps);
                this.addMenuActionsToPeerNode(xmlDoc, actionNamespace);              
            end           
        end
        
        % Constructor fn that creates the PeerModelServer instance.
        function this = ContextMenuManager(varargin)
            if (nargin>0)
                this.Namespace = string(varargin{1});
            end
            this.PeerModelServer = peermodel.internal.PeerModelManagers.getServerManager(this.Namespace);
            this.PeerModelServer.SyncEnabled = true;
            this.createRoot(this.Root);            
        end        
       
        % Gets the root of the PeerModelServer. Creates a new root if one does not exist. 
        function root =  getRoot(this)
            this.createRoot(this.Root);
            root = this.PeerModelServer.getRoot();       
        end                     
        
    end
end

