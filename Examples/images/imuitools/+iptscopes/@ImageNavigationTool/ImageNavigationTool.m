classdef ImageNavigationTool < matlabshared.scopes.tool.Tool
    %IMAGENAVIGATIONTOOL - Class definition for ImageNavigationTool
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Dependent=true)
        Mode
    end
    
    properties(Hidden=true)
        privMode = 'off'
        AppliedMode = 'off'
        OldPosition
    end
    
    properties(Access=protected)
        CallbackID
        hVisualChangedListener
    end
    
    properties(SetAccess=protected,Hidden=true)
        ScrollPanel = -1
        ZoomInMenu
        ZoomOutMenu
        PanMenu
        MaintainMenu
        ZoomInButton
        ZoomOutButton
        PanButton
        MaintainButton
        ZoomPanButtonGroup
        MagButtonGroup
        ZoomButtonGroup
        ScrollPanelAPI
    end
    
    properties (SetAccess = protected)
        MagCombobox
    end
    
    methods
        %Constructor
        function this = ImageNavigationTool(varargin)
            
            this@matlabshared.scopes.tool.Tool(varargin{:});
            
            propertyChanged(this, 'FitToView');
                        
        end
        
    end
    
    methods
        
        function this = set.Mode(this, mode)
            
            this.privMode = mode;
            hFitToView = this.findProp('FitToView');
            
            if strcmpi(mode,'FitToView')
                set(hFitToView, 'Value', true);
            elseif hFitToView.Value
                hFitToView.Value = false;
                hapi = iptgetapi(this.ScrollPanel);
                %TODO: Where does setPropValue come from?
                setPropertyValue(this, 'Magnification', hapi.getMagnification());
            end
            
            react(this);
            
        end
        
        function mode = get.Mode(this)
            
            mode = this.privMode;
            
        end
        
    end
    
    methods(Access=protected)
        
        enableGUI(this, enabState)
        
        plugInGUI = createGUI(this)
        
    end
    
    methods(Static)
        propSet = getPropertySet
    end
end
