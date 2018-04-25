classdef ActionDataService < handle
    %ACTIONDATASERVICE handle class from the ActionDataService Framework
    
    % This class can be used to perform CRUD operations on a set of actions.
    % Each ActionDataService instance is associated with a namespace. This
    % is a unique channel that can be used to create a rootNode on the
    % PeerModel tree. The ActionDataService can be instantiated in one of
    % the following two modes
    
    % 1. ActAsServer: The peermodel created using this mode has a client
    % side counterpart. Actions can be added/removed/updated using methods
    % provided below and the peermodel ensures that the server and client
    % are synchronized.
    
    % 2. ActAsClient: The peermodel is created as a client only 
    % instance and does not allow users to add/remove actions. 
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess='protected') 
       Actions;
       mode = "ActAsServer";
       Namespace = "/Actions/DefaultNameSpace";       
       Root = "Root";
       
    end
    
    properties (SetObservable=true, SetAccess='protected')       
       PeerModelServer;
    end 
    
    methods        
        function modelServer = get.PeerModelServer(this)
            modelServer = this.PeerModelServer;
        end       
        
        function this = ActionDataService(varargin)            
            if (nargin >0) 
                this.mode = string(varargin{1});
                this.Namespace = string(varargin{2});
            end    
            this.Actions = containers.Map;
            if (eq(this.mode, "ActAsServer"))
                this.PeerModelServer = peermodel.internal.PeerModelManagers.getServerManager(this.Namespace);
                this.createRoot(this.Root);
            elseif (eq(this.mode, "ActAsClient"))
                this.PeerModelServer = peermodel.internal.PeerModelManagers.getClientManager(this.Namespace);
            end
            this.PeerModelServer.SyncEnabled = true;            
        end        

        % Allows users to addAction using an action instance or a set of
        % action properties. Users cannot addAction if in 'ActAsClient'
        % mode or if the Action has already been added.
        function action = addAction(this, action)
            if (eq(this.mode,"ActAsClient"))
                error(message('MATLAB:codetools:datatoolsservices:AddActionClientMode'));
            end
            if (nargin<2) || isempty(action) 
                error(message('MATLAB:codetools:datatoolsservices:InvalidAction'))
            elseif(isKey(this.Actions, action.ID))
                error(message('MATLAB:codetools:datatoolsservices:DuplicateActionID',action.ID));
            else
                PeerAction = internal.matlab.datatoolsservices.peer.PeerActionWrapper(action, this.getRoot);
                this.Actions(action.ID) = PeerAction;
            end
        end       
        
        % Allows users to update an action's existing properties or add new properties.
        % Users cannot updateAction if the Action was not previously added
        % using addAction or if the properties specified are not {name-value} pairs.
        function updatedAction = updateAction(this, id, varargin)            
            if (isKey(this.Actions, id))
                action = this.Actions(id);
                if (rem(length(varargin{:})-2,2)) ~=0
                    error(message('MATLAB:codetools:datatoolsservices:PropertyValuePairsExpected'));                    
                end
                updatedAction = action.updateActionProperty(varargin{:});
            else               
                error(message('MATLAB:codetools:datatoolsservices:IncorrectActionID', id));                    
            end
        end
        
        % Allows users to remove an action from the ActionDataService. Users
        % cannot removeAction if in 'ActAsClient' mode or if the Action does
        % not exist.        
        function removeAction(this, id)
            if (eq(this.mode,"ActAsClient"))
                error(message('MATLAB:codetools:datatoolsservices:RemoveActionClientMode'));
            end
            if (isKey(this.Actions, id))                 
                action = this.Actions(id);
                delete(action);
                remove(this.Actions, id);
            else               
                error(message('MATLAB:codetools:datatoolsservices:IncorrectActionID', id));                    
            end
        end          
        
        function enableAction(this, id)
            this.updateAction(id, {'Enabled', true});
        end        
        
        function disableAction(this, id)
            this.updateAction(id, {'Enabled', false});
        end        
        
        % Allows users to execute an action by passing in an action instance or 
        % the ID of the Action. Users cannot executeAction if the Action
        % specified does not exist.        
        function executeAction(this, varargin)            
            if isa(varargin{1}, 'internal.matlab.datatoolsservices.Action')                
                ID = varargin{1}.ID;                
            else 
                ID = varargin{1};
            end            
            if (isKey(this.Actions, ID))
                PeerAction = this.Actions(ID);
                PeerAction.executeCallBack();
            else
                error(message('MATLAB:codetools:datatoolsservices:IncorrectActionID', ID));
            end           
        end
        
        function ActionList = getAllActions(this)
            ActionList = internal.matlab.datatoolsservices.peer.PeerActionWrapper.empty();
            if ~(isempty(this.Actions))
                actionKeys = keys(this.Actions);
                for index = 1:length(actionKeys)
                    action = this.Actions(actionKeys{index});
                    ActionList(index) = action;
                end
            end
        end
     
        
        function delete(this)
            if ~isempty(this.PeerModelServer) && isvalid(this.PeerModelServer)                 
                this.PeerModelServer.delete;                
            end            
        end 
        
        % Gets the root of the peerTree. Creates a new root on the 
        % PeerModelServer if one does not exist. 
        function root =  getRoot(this)          
            this.createRoot(this.Root);
            root = this.PeerModelServer.getRoot();
        end    
    end 
    
    % Protected methods
    methods(Access='protected')        
        function createRoot(this, RootType)
            if isempty(this.PeerModelServer.getRoot()) && ~eq(this.mode, "ActAsClient")
                this.PeerModelServer.createRoot(RootType);
            end
        end               
    end       
  
end

