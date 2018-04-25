classdef (Abstract) AbstractBinaryComponentInteractor < matlab.uiautomation.internal.interactors.AbstractComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = AbstractBinaryComponentInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
        function uipress(actor, varargin)
            
            narginchk(1, 1);
            
            actor.Dispatcher.dispatchEventAndWait(...
                actor.Component, 'uipress', varargin{:});
        end
        
        function uiselect(actor, value)
            
            narginchk(1, 2);
            
            if nargin < 2
                value = true;
            end
            
            validateattributes(value, {'logical'}, {'scalar'});
            
            component = actor.Component;
            
            if component.Value ~= value
                actor.uipress();
            end
            
        end
        
    end
    
end