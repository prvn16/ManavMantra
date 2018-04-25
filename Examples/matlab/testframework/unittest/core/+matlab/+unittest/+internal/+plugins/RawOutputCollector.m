classdef RawOutputCollector < handle
    % This class is undocumented.
    
    % CURRENT RESTRICTIONS: Since RawOutputCollector uses "diary" behind
    % the scenes, the collected output may be different than what was in
    % the command window. For example, diary does not save unicode
    % characters (like char(960)) but instead replaces them with char(26).
    
    % Copyright 2016 The MathWorks, Inc.
    properties(GetAccess=private,SetAccess=immutable)
        Marker
        Manager
    end
    
    properties(Dependent,SetAccess=immutable)
        IsCollecting
        RawOutput
    end
    
    methods
        function collector = RawOutputCollector()
            import matlab.unittest.internal.plugins.RawOutputCollectorManager;
            import matlab.unittest.internal.plugins.RawOutputCollectorMarker;
            
            % Note that a separate marker is needed. If the Manager instead
            % held onto the handle of the instance, then the delete method
            % would not be called when it is cleared from a workspace.
            collector.Marker = RawOutputCollectorMarker();
            collector.Manager = RawOutputCollectorManager.getInstance();
            collector.Manager.addMarker(collector.Marker);
        end
        
        function delete(collector)
            collector.Manager.removeMarker(collector.Marker);
        end
        
        function bool = get.IsCollecting(collector)
            bool = collector.Manager.getIsCollectingValueFor(collector.Marker);
        end
        
        function turnCollectingOn(collector)
            collector.Manager.turnCollectingOnFor(collector.Marker);
        end
        
        function turnCollectingOff(collector)
            collector.Manager.turnCollectingOffFor(collector.Marker);
        end
        
        function clearRawOutput(collector)
            collector.Manager.clearRawOutputFor(collector.Marker);
        end
        
        function rawOutput = get.RawOutput(collector)
            rawOutput = collector.Manager.getRawOutputFor(collector.Marker);
            rawOutput = strrep(rawOutput,char(26),'');
        end
    end
end