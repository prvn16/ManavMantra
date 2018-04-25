classdef MLWorkspaceBrowser < handle
    % A class defining MATLAB Workspace Browser Manager
    % 

    % Copyright 2013-2014 The MathWorks, Inc.

    % Manager
    properties (SetObservable=false, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=false)
        Manager_I;
    end
    
    properties (SetObservable=false, SetAccess='protected', GetAccess='public', Dependent=true, Hidden=false)
        Manager;
    end
    methods
        function storedValue = get.Manager(this)
            if isempty(this.Manager_I) || ~isvalid(this.Manager_I)
                this.Manager_I = internal.matlab.workspace.MLWorkspaceBrowserManager('caller');
            end
            storedValue = this.Manager_I;
        end
        
        function set.Manager(this, newValue)
            reallyDoCopy = ~isequal(this.Manager_I, newValue);
            if reallyDoCopy
                this.Manager_I = newValue;
            end
        end
    end

    % WorkspaceDocument
    properties (SetObservable=false, SetAccess='private', GetAccess='public', Dependent=true, Hidden=false)
        WorkspaceDocument;
    end
    methods
        function storedValue = get.WorkspaceDocument(this)
            storedValue = this.Manager.Documents(1);
        end 
    end

    methods(Access='protected')
        function this = MLWorkspaceBrowser()
            this.initialize();
        end
        
        function initialize(this)
            % Force an initial update from the base workspace g1044049
            this.Manager.Documents(1).DataModel.Workspace = 'base';
            this.Manager.Documents(1).DataModel.workspaceUpdated();
            this.Manager.Documents(1).DataModel.Workspace = 'caller';
        end
    end

    % Public Static Methods
    methods(Static, Access='public')
        % getInstance
        function obj = getInstance()
            mlock; % Keep persistent variables until MATLAB exits
            persistent managerInstance;
            if isempty(managerInstance) || ~isvalid(managerInstance)
                managerInstance = internal.matlab.workspace.MLWorkspaceBrowser();
                managerInstance.initialize();
            end
            
            obj = managerInstance;
        end
    end    
end
