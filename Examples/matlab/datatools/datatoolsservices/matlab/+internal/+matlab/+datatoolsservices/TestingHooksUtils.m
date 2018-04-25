classdef TestingHooksUtils < handle   
    % Server side TestingHooksUtils class to set up testing hooks for notifying tests.
    
    % Copyright 2017 The MathWorks, Inc.
    properties (SetObservable=true, SetAccess='protected')       
       PeerModelServer;       
       InitTestingHooks = false;
    end 
    
    properties (SetAccess='protected', GetAccess='protected')     
       Root = "TestHooksRoot";
       Namespace = "/TestingHooks";
       peerModelStarted = false;
    end
    
    methods
        
        % If namespace is provided as input argument, use that instead of
        % the default namespace. Set up peermodel and create root on
        % instantiation.        
        function this = TestingHooksUtils(varargin)
            if (nargin > 0)
                this.Namespace = string(varargin{1});
            end 
            this.peerModelSetup();
        end
        
        % If input value is set to true or not set at all, set the 
        % InitTestingHooks flag to true and false otherwise.
        % mode or if the Action has already been added.
        function setTestingHooks(this, value)         
            if nargin <1 || isempty(value) || value
                this.InitTestingHooks = true;
                this.setPeerProperty('InitTestingHooks', true);
            else
                this.InitTestingHooks = false;
                this.setPeerProperty('InitTestingHooks',false);
            end
        end        
        
        % This function gets the rootNode of the PeerModel server.        
        function root =  getRoot(this)
            this.createRoot(this.Root);
            root = this.PeerModelServer.getRoot();       
        end  
        
        % Deletes the current PeerModelServer instance when the current
        % instance is destroyed.
        function delete(this)
            if ~isempty(this.PeerModelServer) && isvalid(this.PeerModelServer)                 
                this.PeerModelServer.delete;                
            end            
        end 
    end
    
    methods(Access = protected)
         % Creates rootNode on the PeerModelServer        
        function createRoot(this, RootType)
            if isempty(this.PeerModelServer.getRoot())
                this.PeerModelServer.createRoot(RootType);
            end
        end 
        
        % This function sets up PeerModelServer by creating a ServerManager
        % instance and a rootNode. 
        function peerModelSetup(this)
            if ~(this.peerModelStarted)
                this.PeerModelServer = peermodel.internal.PeerModelManagers.getServerManager(this.Namespace);
                this.PeerModelServer.SyncEnabled = true;
                this.createRoot(this.Root);
                this.peerModelStarted = true;
            end
        end
        
        % The setPeerProperty sets the propName-propVal as a property on
        % the rootNode.        
        function setPeerProperty(this, propName, propVal)
            if isvalid(this.PeerModelServer) && this.PeerModelServer.hasRoot()
                rootNode = this.PeerModelServer.getRoot();                
                rootNode.setProperty(propName, propVal);               
            end
        end
    end       
end

