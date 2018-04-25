classdef buttonUpMonitor < handle
    % This undocumented class may be removed in a future release.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    
    properties
        isUp
        hFig
        buttonUpListener
    end
    
    methods
        
        function obj = buttonUpMonitor(hFig)
            % buttonUpMonitor is only for use is specific contexts where you need
            % to monitor whether a buttonUp event has already been queued
            % from within a buttonDown callback.
            obj.isUp = false;
            obj.buttonUpListener = iptui.iptaddlistener(hFig,...
                'WindowMouseRelease',@(varargin) obj.cacheButtonUp());
            
            obj.hFig = hFig;
        end
        
        function cacheButtonUp(obj)
            obj.isUp = true;
        end
        
        function isUp = isButtonUp(obj)
            % Drawnow is required here. The whole idea of this small object
            % is to encapsulate a simple means of testing whether a
            % buttonUp event is already in the event queue. We add a
            % buttonUp listener. Whenever the client asks isButtonUp, the
            % drawnow flushes the event queue. If a buttonUp is in the
            % queue, it will fire, causing the state of isUp to change.
            drawnow;
            isUp = obj.isUp;   
        end
        
    end
    
end
