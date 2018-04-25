classdef (Hidden) ComponentControllerFactoryManager < handle
    % COMPONENTCONTROLLERFACTORYMANAGER is a singleton which manages the current
    % instance of which ControllerFactory is used by HMI Components to create
    % AbstractControllers.
    %
    % To get the current ControllerFactory:
    %
    %  currentFactory =
    %  matlab.ui.control.internal.controller.HmiControllerFactoryManager.Instance.ControllerFactory
    %
    % To change the current factory:
    %
    %  matlab.ui.control.internal.controller.HmiControllerFactoryManager.Instance.ControllerFactory
    %  = newFactory
    
     % Copyright 2011-2012 The MathWorks, Inc.
  
    properties(Constant)
        % Singleton instance of the class
        Instance = matlab.ui.control.internal.controller.ComponentControllerFactoryManager;
    end
    
    properties(GetAccess='public', SetAccess = 'public') 
        ControllerFactory;
    end        
    
    methods (Access = 'private')
        % Private constructor 
        function obj = ComponentControllerFactoryManager         
            obj.ControllerFactory = matlab.ui.control.internal.controller.ComponentControllerFactory;
            
            % put an mlock in this constructor to avoid any of the "clear"
            % commands from freeing up the Instance of the HMI.
            % IMPORTANT: this must be done last in this constructor after
            %            all errors are checked for otherwise some tests
            %            may fail
            mlock;
        end  
    end
end


