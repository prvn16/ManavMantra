classdef (Abstract) ActionBehavior_QuickAccessIcon < handle
    % Mixin class inherited by Button, DropDownButton, SplitButton,
    % ToggleButton, ListItem and ListItemWithPopup
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public, Hidden)
        % Property "QuickAccessIcon": 
        %
        %   QuickAccessIcon used in a control. It is a
        %   matlab.ui.internal.toolstrip.Icon object and the default value
        %   is []. It is writable. 
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button()
        %       btn.QuickAccessIcon = matlab.ui.internal.toolstrip.Icon.MATLAB_16
        QuickAccessIcon
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.QuickAccessIcon(this)
            % GET function
            action = this.getAction;
            value = action.QuickAccessIcon;
        end
        
        function set.QuickAccessIcon(this, value)
            % SET function
            action = this.getAction();
            action.QuickAccessIcon = value;
        end
        
    end
    
end

