classdef (Abstract) UIDispatcher < handle
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    
    methods (Abstract)
        dispatchEventAndWait(dispatcher, model, evtName, varargin)
    end
    
    methods (Static)
        
        function dispatcher = forComponent(H)
            import matlab.uiautomation.internal.FigureHelper;
            import matlab.uiautomation.internal.UIDispatcher;
            
            assertRootDescendant(H);
            
            fig = ancestor(H, 'figure');
            
            if ~FigureHelper.isWebFigure(fig)
                error( message('MATLAB:uiautomation:Driver:MustBelongToUIFigure') );
            end
            
            dispatcher = UIDispatcher.forWeb();
        end
        
        function dispatcher = forWeb()
            import matlab.uiautomation.internal.WebDispatcher;
            dispatcher = WebDispatcher;
        end
        
    end
    
    methods (Access = protected)
        
        function okToDispatch(~, component)
            
            assertRootDescendant(component);
            assertVisibleHierarchy(component);
        end
        
    end
    
end


function assertRootDescendant(H)
if isempty( ancestor(H, 'root') )
    error( message('MATLAB:uiautomation:Driver:RootDescendant'));
end
end

function assertVisibleHierarchy(H)

% Tabs don't have a Visible property - it depends on the parent tabgroup.
% Otherwise check its Visible property.
isVisible = @(x)isa(x, 'matlab.ui.container.Tab') || strcmp(x.Visible, 'on');

while ~isempty(H) && ~isa(H, 'matlab.ui.Root')
    if ~isVisible(H)
        error( message('MATLAB:uiautomation:Driver:VisibleHierarchy'));
    end
    H = H.Parent;
end

end