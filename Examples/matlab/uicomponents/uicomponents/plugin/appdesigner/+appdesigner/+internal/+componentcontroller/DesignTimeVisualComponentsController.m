classdef DesignTimeVisualComponentsController < ...
       appdesigner.internal.controller.DesignTimeController
    %DESIGNTIMEVISUALCOMPONENTSCONTROLLER This is the super class for all
    %Visual Components' design time controllers.  It will act as a bridge
    %between the DesignTimeController which is the interface for all
    %components integrated with AppDesigner and each indivual visual
    %component.
    
    methods
        function obj = DesignTimeVisualComponentsController(varargin)
            obj = obj@appdesigner.internal.controller.DesignTimeController(varargin{:});
        end        
    end
    
    methods(Access = 'protected')
        function handlePeerNodePeerEvent(obj, src, event)
            % Handler for 'peerEvent' from the Peer Node
            
            % Override the base class implementation            
            % VC Components only care 'PropertyEditorEdited' event
            if(strcmp(event.Data.Name, 'PropertyEditorEdited'))
                % GUIEvent which is fired by 'peerEvent' event from the
                % PeerNode
                obj.handleDesignTimeEvent(src, event);
            end
        end    
    end
end

