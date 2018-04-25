classdef MenuInteractor < matlab.uiautomation.internal.interactors.AbstractComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        
        function actor = MenuInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
        function uipress(actor, varargin)
            
            narginchk(1,1);
            
            menu = actor.Component;
            if ~isempty(menu.Children)
                error( message('MATLAB:uiautomation:Driver:NotALeafMenu') );
            end
            
            if isempty( ancestor(menu, 'root') )
                error( message('MATLAB:uiautomation:Driver:RootDescendant') );
                % Otherwise we can assume standard parenting-rules apply
            end
            
            doTopDown(menu)
            
            function doTopDown(menu)
                parent = menu.Parent;
                if parent.Type == "uimenu"
                    doTopDown(parent)
                end
                
                actor.Dispatcher.dispatchEventAndWait(menu, 'uiselect');
            end
            
        end
        
    end
    
end

