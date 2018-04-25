classdef ActionManager < handle
    %ACTIONMANAGER handle class of VariableEditor
    
    % This class starts up the ActionDataService for the Variable Editor and 
    % initializes all the Variable Editor Actions.
    
    % Copyright 2017 The MathWorks, Inc.

    properties (SetAccess='protected', GetAccess='public')
        ActionDataService;
        VEActions; 
        Manager;
    end
    
    
    methods        
        % The Constructor starts up the ActionDataService with the namespace 
        % and mode specified. The Variable Editor's clientPeerManager
        % instance is used later on to instantiate the Actions.        
        function this = ActionManager(manager, namespace ,mode)
            this.ActionDataService = internal.matlab.datatoolsservices.peer.ActionDataService(mode, namespace);            
            this.Manager = manager;
            this.VEActions = containers.Map;
        end
        
        % This function scans for actions of type 'classType' from the
        % package 'startPath' and instantiates all the actions. 
        % A list of all the actions are stored in this.VEActions
        function initActions(this, startPath, classType)
            if (nargin < 1) || isempty(startPath)
              startPath = 'internal';
            end            
            mClasses = {};
            try
                mClasses = internal.findSubClasses(startPath,classType, true);                        
            catch
            end
           for i=1:length(mClasses)
                className = mClasses{i}.Name;
                % Creating Action instances by passing in an empty struct
                % for properties and the manager Instance. This properties
                % struct will be configured by individual actions.
                actionInstance = eval([className '(struct, this.Manager)']);
                this.ActionDataService.addAction(actionInstance);
                this.VEActions(className) = actionInstance;
            end 
        end
        
        function delete(this)
            actionKeys = keys(this.VEActions);
            for i=1:length(actionKeys)
                delete(this.VEActions(actionKeys{i}));
            end
            this.VEActions=[];
        end      
    end    
end

