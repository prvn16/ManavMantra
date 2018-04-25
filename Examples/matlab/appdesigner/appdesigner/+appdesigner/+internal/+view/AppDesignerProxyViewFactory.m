classdef AppDesignerProxyViewFactory < appdesservices.internal.peermodel.PeerModelProxyViewFactory
    % AppDesignerProxyViewFactory manages the creation of all Proxy Views
    % for all AppDesigner - related classes.
    %
    % Instead of directly using this class, the
    % AppDesignerProxyViewFactoryManager should be used to get the current
    % factory.
    
    % Copyright 2013-2015 The MathWorks, Inc.
    
    properties (SetAccess=protected)
        % Connection object that starts the MOTW connector and composes the
        % URL for the CEF client web page
        Connection
    end
    
    methods
        function proxyView = createProxyView(obj, type, parentController, propertyNameValues)
            % Create a ProxyView for the given controller
            
            if(isempty(parentController))
                % No need for the AppDesignerProxyViewFactory to create a view because
                % it will be created outside this factory but this method
                % is abstract in the super class.
                % Can refactor later
                
                proxyView = [];
            else
                % When other components are passed in, then just need to
                % create a regular proxy view.
                %
                % This method is defined in 'PeerModelProxyViewFactory' superclass
                proxyView = createDefaultProxyView(obj, type, parentController.ProxyView.PeerNode, propertyNameValues);
            end
        end
    end
    
end




