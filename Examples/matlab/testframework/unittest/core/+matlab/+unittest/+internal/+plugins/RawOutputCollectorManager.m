classdef RawOutputCollectorManager < handle
    % This class is undocumented.
    
    % Copyright 2016 The MathWorks, Inc.
    properties(Access=private)
        Markers = matlab.unittest.internal.plugins.RawOutputCollectorMarker.empty(1,0);
        IsCollectingMask = true(1,0);
        RawOutputStrings = string.empty(1,0);
        
        TempFile
        RawOutputLogger
        HotLinksOffEnvironment
        
        UndistributedRawOutput = '';
    end
    
    methods(Access=private)
        function manager = RawOutputCollectorManager()
        end
    end
    
    methods(Static,Access={?matlab.unittest.internal.plugins.RawOutputCollector})
        function manager = getInstance()
            import matlab.unittest.internal.plugins.RawOutputCollectorManager;
            persistent theInstance;
            if isempty(theInstance) || ~isvalid(theInstance)
                theInstance = RawOutputCollectorManager();
            end
            manager = theInstance;
        end
    end
    
    methods(Access={?matlab.unittest.internal.plugins.RawOutputCollector})
        function addMarker(manager, marker)
            assert(~any(marker == manager.Markers)); %Sanity check
            
            manager.turnOffRemoteCollection();
            manager.distributeRemoteOutputToLocal();
            
            manager.Markers = [manager.Markers, marker];
            manager.IsCollectingMask = [manager.IsCollectingMask, false];
            manager.RawOutputStrings = [manager.RawOutputStrings, ""];
            
            manager.turnOnRemoteCollectionIfNeeded();
        end
        
        function removeMarker(manager,marker)
            manager.turnOffRemoteCollection();
            manager.distributeRemoteOutputToLocal();
            
            ind = manager.getIndexOf(marker);
            manager.Markers(ind) = [];
            manager.IsCollectingMask(ind) = [];
            manager.RawOutputStrings(ind) = [];
            
            manager.turnOnRemoteCollectionIfNeeded();
        end
        
        function turnCollectingOnFor(manager,marker)
            manager.turnOffRemoteCollection();
            manager.distributeRemoteOutputToLocal();
            
            ind = manager.getIndexOf(marker);
            manager.IsCollectingMask(ind) = true;
            
            manager.turnOnRemoteCollectionIfNeeded();
        end
        
        function turnCollectingOffFor(manager,marker)
            manager.turnOffRemoteCollection();
            manager.distributeRemoteOutputToLocal();
            
            ind = manager.getIndexOf(marker);
            manager.IsCollectingMask(ind) = false;
            
            manager.turnOnRemoteCollectionIfNeeded();
        end
        
        function clearRawOutputFor(manager,marker)
            manager.turnOffRemoteCollection();
            manager.distributeRemoteOutputToLocal();
            
            ind = manager.getIndexOf(marker);
            manager.RawOutputStrings(ind) = "";
            
            manager.turnOnRemoteCollectionIfNeeded();
        end
        
        function rawOutputStr = getRawOutputFor(manager,marker)
            manager.turnOffRemoteCollection();
            manager.distributeRemoteOutputToLocal();
            
            ind = manager.getIndexOf(marker);
            rawOutputStr = char(manager.RawOutputStrings(ind));
            
            manager.turnOnRemoteCollectionIfNeeded();
        end
        
        function bool = getIsCollectingValueFor(manager,marker)
            ind = manager.getIndexOf(marker);
            bool = manager.IsCollectingMask(ind);
        end
    end
    
    methods(Access=private)
        function ind = getIndexOf(manager,marker)
            ind = find(marker == manager.Markers);
            assert(isscalar(ind)); %Sanity check
        end
        
        function turnOnRemoteCollectionIfNeeded(manager)
            if ~any(manager.IsCollectingMask)
                return;
            end
            
            import matlab.unittest.internal.plugins.OutputLogger;
            import matlab.unittest.internal.plugins.FeatureHotLinksOffEnvironment;
            manager.TempFile = tempname();
            manager.RawOutputLogger = OutputLogger(manager.TempFile);
            manager.HotLinksOffEnvironment = FeatureHotLinksOffEnvironment();
        end
        
        function turnOffRemoteCollection(manager)
            if ~any(manager.IsCollectingMask)
                return;
            end
            
            delete(manager.HotLinksOffEnvironment);
            delete(manager.RawOutputLogger);
            rawOutput = fileread(manager.TempFile);
            delete(manager.TempFile);
            
            % On Windows, the OutputLogger saves to a file with \r\n
            % instead of only \n. We should fix this inconsistency.
            rawOutput = regexprep(rawOutput,'\r?\n\r?',newline());
            
            manager.UndistributedRawOutput = rawOutput;
        end
        
        function distributeRemoteOutputToLocal(manager)
            rawOutput = manager.UndistributedRawOutput;
            manager.RawOutputStrings(manager.IsCollectingMask) = ...
                manager.RawOutputStrings(manager.IsCollectingMask) + rawOutput;
            manager.UndistributedRawOutput = '';
        end
    end
end