classdef (Sealed) ToolstripService < handle
    %Common toolstrip server side service.
    
    % Author(s): Rong Chen
    % Copyright 2014 The MathWorks, Inc.
    
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
            % toolstrip root must be the FIRST root node because of the
            % refreshing order is from LAST to FIRST as of today.  The
            % other utility roots such as popup and gallery must be
            % refreshed before the toolstrip root because of the
            % dependency.  Orphan should be the LAST root.
            % if has root, add toolstrip sub-roots when necessary
            if manager.hasRoot()
                Root = manager.getRoot();
                if manager.getByType('ToolstripRoot').isEmpty
                    Root.addChild('ToolstripRoot');
                end
                if manager.getByType('QABRoot').isEmpty
                    Root.addChild('QABRoot');
                end
                if manager.getByType('GalleryRoot').isEmpty
                    GalleryRoot = Root.addChild('GalleryRoot');
                    GalleryRoot.addChild('GalleryPopupRoot');
                    GalleryRoot.addChild('GalleryFavoriteCategoryRoot');
                end
                if manager.getByType('PopupRoot').isEmpty
                    Root.addChild('PopupRoot');
                end
                if manager.getByType('OrphanRoot').isEmpty
                    Root.addChild('OrphanRoot');
                end
            % otherwise, create root and toolstrip sub-roots    
            else
                Root = manager.setRoot('Root');
                Root.addChild('ToolstripRoot');
                Root.addChild('QABRoot');
                GalleryRoot = Root.addChild('GalleryRoot');
                GalleryRoot.addChild('GalleryPopupRoot');
                GalleryRoot.addChild('GalleryFavoriteCategoryRoot');
                Root.addChild('PopupRoot');
                Root.addChild('OrphanRoot');
            end
        end
        
        function cleanup(channel)
            com.mathworks.peermodel.PeerModelManagers.cleanup(channel);
        end
        
        function reset(channel)
            % get manager
            manager = com.mathworks.peermodel.PeerModelManagers.getInstance(channel);
            % remove all
            types = {'OrphanRoot';'PopupRoot';'QABRoot';'GalleryRoot';'ToolstripRoot'};
            if manager.hasRoot()
                for ct=1:length(types)
                    node = manager.getByType(types{ct});
                    if ~node.isEmpty
                        node.get(0).destroy();
                    end
                end
                manager.getRoot.remove();
            end
            % initialize
            matlab.ui.internal.toolstrip.base.ToolstripService.initialize(channel);
        end
        
    end
        
end