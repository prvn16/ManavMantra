classdef FigurePeerModelInfo < handle

    % FigurePeerModelInfo object that sets up the PeerModel infrastructure used by the FigureController
    % and its PlatformHost
    % 
    % Copyright 2016 The MathWorks, Inc.

    properties (SetAccess = private)
        URL;            % Full URL
        DebugPort;
        FigurePeerNode;
        Id;             % FigurePeerNode Id
        PeerModelManager;
        PeerModelRoot;
    end
    
    properties (Access = private)
        PeerModelChannel;
    end
    
    % Synchronizer property is used only by
    % FigureController.flushCoalescer(). This property (and the code which
    % caches it) are intended to be temporary, to be removed when drawnow
    % integration of property updates is completed. (See g1643253.)
    properties (GetAccess = { ?matlab.ui.internal.controller.FigureController }, SetAccess = private)
        Synchronizer;
    end
    
    methods (Access = public)

        % constructor
        function this = FigurePeerModelInfo(htmlFile)

            % PeerModel channel
            peerModelUUID = char(java.util.UUID.randomUUID);
            this.PeerModelChannel = ['/uifigure/' peerModelUUID];
            
            pathToHtmlFile = strcat('toolbox/matlab/uitools/uifigureappjs/',htmlFile);

            % ensure connector is on and get URL
            this.URL = connector.getUrl(['/', pathToHtmlFile, ...
                                        '?','channel=',this.PeerModelChannel]);

            % start peer model
            this.PeerModelManager = com.mathworks.peermodel.PeerModelManagers.getInstance(this.PeerModelChannel);
            this.PeerModelManager.setSyncEnabled(true);
            this.PeerModelRoot = this.PeerModelManager.setRoot('ContainerRoot');

            % configure performance settings for coalescing events
            synchronizer = com.mathworks.peermodel.PeerModelManagers.getPeerSynchronizer(this.PeerModelChannel);
            
            % set max and min to be the same.  For streaming workflows,
            % this assures that the events are not overly delayed.
            synchronizer.setCoalescerMaxDelay(synchronizer.getCoalescerMinDelay());

            % effectively diable sync by setting the coalescer
            % delay to a long value (10 days). (This may be removed at a
            % later time; see g1658467.)
            TenDaysInMS = 1000*60*60*24*10;
            synchronizer.setCoalescerMinDelay(TenDaysInMS);
            synchronizer.setCoalescerMaxDelay(TenDaysInMS);

            % Increase queue size to allow coalescer to cache a large number
            % of changes.  Current goal is to consider 200 objects, each
            % with 50 properties, and add in 2x padding.  (This may be
            % removed at a later time; see g1658467.)
            MaxChangeQueueSize = 200*50*2;
            synchronizer.setCoalescerMaxQueueSize(MaxChangeQueueSize);

            % Cache synchronizer for later access. Synchronizer property is
            % used only by FigureController.flushCoalescer(). This code
            % (and the Synchronizer property declaration) are intended to
            % be temporary, to be removed when drawnow integration of
            % property updates is completed. (See g1643253 and g1658467.)
            this.Synchronizer = synchronizer;
            
            % debug port is random.  "getOpenPort()" returns 0 (disabling debug port) in the shipped ML.
            this.DebugPort = matlab.internal.getOpenPort();

            % get the FigurePeerNode, and its ID for simplified access
            this.FigurePeerNode = this.PeerModelRoot.addChild('matlab.ui.Figure');
            this.Id = char(this.FigurePeerNode.getId);
        end % constructor

        % destructor
        function delete(this)
            % delete peer model channel
            if ~isempty(this.PeerModelChannel)
                com.mathworks.peermodel.PeerModelManagers.cleanup(this.PeerModelChannel);
            end
        end % delete()

    end % public methods

    methods (Access = {?util.FigureControllerTestHelper})
        
        % getTestHelperInfo() - called by FigureControllerTestHelper to get a struct containing data it uses
        function testHelperInfo = getTestHelperInfo(this)
            testHelperInfo.URL = this.URL;
            testHelperInfo.DebugPort = this.DebugPort;
            testHelperInfo.PeerModelManager = this.PeerModelManager;
            testHelperInfo.PeerNode = this.FigurePeerNode;
            testHelperInfo.Id = char(this.Id);
        end % getTestHelperInfo()

    end % limited access methods
 
end
