classdef (Hidden) ComponentProxyViewFactoryManager < handle
    % COMPONENTPROXYVIEWFACTORY is a singleton which manages the current
    % instance of which ProxyViewFactory is used by HMI Components to
    % create AbstractProxyViews.
    %
    % To get the current ProxyViewFactory:
    %
    %  currentFactory =
    %  matlab.ui.control.internal.view.ComponentProxyViewFactoryManager.Instance.ProxyViewFactory
    %
    % To change the current factory:
    %
    %  matlab.ui.control.internal.view.ComponentProxyViewFactoryManager.Instance.ProxyViewFactory
    %  = newFactory

    %  Copyright 2012-2015 The MathWorks, Inc.
    
    properties(Constant)
        % Singleton instance of the class
        Instance = matlab.ui.control.internal.view.ComponentProxyViewFactoryManager;
    end
    
    properties(GetAccess='public', SetAccess = 'public', Dependent)
        % Handle to the current ProxyViewFactory
        %
        % This factory is used by uicomponent controllers when they need
        % to create a new Proxy View
        ProxyViewFactory;
    end
    
    properties(Access='private')
        % Storage for the 'ProxyViewFactory' field
        PrivateProxyViewFactory;
    end
    
    methods (Access = 'private')
        % Private constructor
        function obj = ComponentProxyViewFactoryManager
            obj.PrivateProxyViewFactory = matlab.ui.control.internal.view.ComponentProxyViewFactory;
            
            % put an mlock in this constructor to avoid any of the "clear"
            % commands from freeing up the Instance of this class.
            mlock;
        end
    end
    
    methods
        function set.ProxyViewFactory(obj, newFactory)
            % Error Check
            validateattributes(newFactory,...
                {'appdesservices.internal.interfaces.view.AbstractProxyViewFactory'}, ...
                {'scalar'})
            
            % Update
            obj.PrivateProxyViewFactory = newFactory;
        end
        
        function value = get.ProxyViewFactory(obj)
            value = obj.PrivateProxyViewFactory;
        end
    end
    
    
end


