classdef (Sealed) ActionService < handle
    % Singleton message center handles communications between web browser
    % and MATLAB via connector messaging API.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    methods (Static)
        
        function manager = get(channel)
            manager = com.mathworks.peermodel.PeerModelManagers.getInstance(channel);
        end
        
        function manager = initialize(channel)
            % get manager
            manager = com.mathworks.peermodel.PeerModelManagers.getInstance(channel);
            % ensure synchronized
            if ~manager.isSyncEnabled
                manager.setSyncEnabled(true);
            end
            % add root if it does not exists
            if ~manager.hasRoot()
                manager.setRoot('Root', java.util.HashMap);
            end
        end
        
        function cleanup(channel)
            com.mathworks.peermodel.PeerModelManagers.cleanup(channel);
        end
        
        function reset(channel)
            % get manager
            manager = com.mathworks.peermodel.PeerModelManagers.getInstance(channel);
            % remove all
            if manager.hasRoot()
                manager.getRoot.remove();
            end
            % initialize
            matlab.ui.internal.toolstrip.base.ActionService.initialize(channel);
        end
        
    end
    
end