classdef DesignTimeComponentProxyView < appdesigner.internal.view.DesignTimeProxyView
    % DesignTimeComponentProxyView The ProxyView which wraps PeerNodes
    %
    % DesignTimeComponentProxyView processes the property data to be set on
    % a component
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties  
        % The adapter to process the properties before they are set on the
        % component when a model is driven to create from client side. It
        % happens in controller's constructor to get properties to set to
        % the model.
        Adapter
    end
    
    methods(Access=public)
        function obj = DesignTimeComponentProxyView(peerNode, adapter, varargin)
            % Error Checks
            narginchk(2, 3);
            assert(isa(peerNode, 'com.mathworks.peermodel.PeerNode'));
            assert(isa(adapter,'appdesigner.internal.componentadapterapi.VisualComponentAdapter'));
            
            obj@appdesigner.internal.view.DesignTimeProxyView(peerNode, varargin{:});
            
            % save the adapter
            obj.Adapter = adapter;
        end
        
        function processedProperties = getProperties(obj)
            originalProperties = getProperties@appdesservices.internal.peermodel.PeerNodeProxyView(obj);
            
            % let the adapter process the properties returned from the
            % PeerNodeProxyView base class
            processedProperties =...
               obj.Adapter.processPropertiesToSet(originalProperties);
        end
    end
    
end


