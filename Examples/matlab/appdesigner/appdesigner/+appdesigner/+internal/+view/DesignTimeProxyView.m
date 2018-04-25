classdef DesignTimeProxyView < appdesservices.internal.peermodel.PeerNodeProxyView
    % DesignTimeProxyView The ProxyView which wraps PeerNodes
    %
    % DesignTimeProxyView processes the property data to be set on
    % a component
    
    % Copyright 2014-2016 The MathWorks, Inc.
    
    properties(GetAccess = 'public', SetAccess = 'private')
        % Proxy view's proeprties have been synced to the model or not
        HasSyncedToModel = false;
    end
    
    methods(Access=public)
        function obj = DesignTimeProxyView(peerNode, hasSyncedToModel)
            % Error Checks
            narginchk(1, 2);
            assert(isa(peerNode, 'com.mathworks.peermodel.PeerNode'));
            
            obj@appdesservices.internal.peermodel.PeerNodeProxyView(peerNode);
            
            if nargin == 2
                obj.HasSyncedToModel = hasSyncedToModel;
            end            
        end
    end
end