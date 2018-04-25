classdef PanBehavior < matlab.graphics.internal.PanAndZoomBehaviorBase
    % This undocumented class may be removed in a future release.
    
    properties (SetAccess=protected, Transient)
        %NAME Property is of type 'string' (read only)
        Name = 'Pan';
    end
    
    events
        BeginDrag
        EndDrag
    end  % events
    
    methods (Hidden)
        function sendBeginDragEvent(hThis)
            % notify the listeners of BeginDrag event
            notify(hThis,'BeginDrag');
        end
        
        function sendEndDragEvent(hThis)
            % notify the listeners of EndDrag event
            notify(hThis,'EndDrag');
        end
    end
end