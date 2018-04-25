classdef AppDesignerProxyViewFactoryManager < handle
    % AppDesignerProxyViewFactoryManager is a singleton which manages the current
    % instance of which ProxyViewFactory is used by App Designer.
    %
    % To get the current ProxyViewFactory:
    %
    %  currentFactory =
    %  appdesigner.internal.view.AppDesignerProxyViewFactoryManager.Instance.ProxyViewFactory
    %
    % To change the current factory:
    %
    %  appdesigner.internal.view.AppDesignerProxyViewFactoryManager.Instance.ProxyViewFactory
    %  = newFactory

    % Copyright 2013-2015 The MathWorks, Inc.
    
    properties(Constant)
        % Singleton instance of the class
        Instance = appdesigner.internal.view.AppDesignerProxyViewFactoryManager;
    end
    
    properties(Dependent)
        % Handle to the current ProxyViewFactory
        %
        % This factory is used by hmicomponent controllers when they need
        % to create a new Proxy View
        ProxyViewFactory;
    end
    
    properties(Access='private')
        % Storage for the 'ProxyViewFactory' field
        PrivateProxyViewFactory;
    end
    
    methods (Access = 'private')
        % Private constructor
        function obj = AppDesignerProxyViewFactoryManager
            obj.PrivateProxyViewFactory = appdesigner.internal.view.AppDesignerProxyViewFactory;
            
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
            
            % Update storage
            obj.PrivateProxyViewFactory = newFactory;
        end
        
        function value = get.ProxyViewFactory(obj)
            value = obj.PrivateProxyViewFactory;
        end
    end        
end


