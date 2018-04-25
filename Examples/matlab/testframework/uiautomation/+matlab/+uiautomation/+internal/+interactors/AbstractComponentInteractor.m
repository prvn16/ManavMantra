classdef (Abstract) AbstractComponentInteractor < handle
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        Component
    end
    
    properties
        Dispatcher
    end
    
    methods
        
        function actor = AbstractComponentInteractor(H, dispatcher)
            actor.Component = H;
            actor.Dispatcher = dispatcher;
        end
        
        function uipress(actor, varargin)
            me = MException( message('MATLAB:uiautomation:Driver:GestureNotSupportedForClass', ...
                'press', class(actor.Component)) );
            throwAsCaller(me);
        end
        
        function uiselect(actor, varargin)
            me = MException( message('MATLAB:uiautomation:Driver:GestureNotSupportedForClass', ...
                'choose', class(actor.Component)) );
            throwAsCaller(me);
        end
        
        function uidrag(actor, varargin)
            me = MException( message('MATLAB:uiautomation:Driver:GestureNotSupportedForClass', ...
                'drag', class(actor.Component)) );
            throwAsCaller(me);
        end
        
        function uitype(actor, varargin)
            me = MException( message('MATLAB:uiautomation:Driver:GestureNotSupportedForClass', ...
                'type', class(actor.Component)) );
            throwAsCaller(me);
        end
        
    end
    
end