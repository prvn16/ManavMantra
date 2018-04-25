%   Copyright 2011-2017 The MathWorks, Inc.

classdef HGEventManager
    % This class is undocumented and will change in a future release
    
    methods(Static = true, Access = private)
        
        % produces a map of corresponding old and new event names where
        % the new event names are the keys and the old event names are
        % the  values.  This is a duplicate of the map in addlistener.cpp
        function map = graphicsEventMap
            persistent EventMap;
            if isempty(EventMap)
                newevt = {'SizeChanged','WindowMousePress','WindowMouseRelease','WindowMouseMotion', 'ContinuousValueChange'};
                oldevt = {'Resize',    'WindowButtonDown','WindowButtonUp',    'WindowButtonMotion','Action'};
                EventMap = containers.Map(newevt, oldevt);
            end
            map = EventMap;
        end
    end
    
    methods(Static = true)
        % returns old event name given new event name
        function oldevt = getOldEventName(event)
            oldevt = event;
            if isKey(matlab.graphics.internal.HGEventManager.graphicsEventMap,event)
                hg1key = values(matlab.graphics.internal.HGEventManager.graphicsEventMap,{event});
                oldevt = hg1key{1};
            end
        end
        
        % returns true if event is an old event name
        function out = isOldEventName(event)
            map = matlab.graphics.internal.HGEventManager.graphicsEventMap;
            out = any(cellfun(@(x)(strcmpi(x,event) || strcmpi([x 'Event'],event)),map.values));
        end
    end
end

