classdef (Abstract) ActionBehavior_ButtonGroup < handle
    % Mixin class inherited by RadioButton and ToggleButton

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, SetAccess = {?matlab.ui.internal.toolstrip.base.Component})
        % Property "ButtonGroup": 
        %
        %   The button group that the radio/toggle button belongs to
        %   It is a string and the default value ''.
        %   It is writable.
        %
        %   Example:
        %       grp1 = matlab.ui.internal.toolstrip.ButtonGroup();
        %       radio1 = matlab.ui.internal.toolstrip.RadioButton('Show number', grp1)
        %       radio2 = matlab.ui.internal.toolstrip.RadioButton('Show text', grp1)
        %
        %       grp2 = matlab.ui.internal.toolstrip.ButtonGroup();
        %       btn1 = matlab.ui.internal.toolstrip.ToggleButton('Show number', grp2)
        %       btn2 = matlab.ui.internal.toolstrip.ToggleButton('Show text', grp2)
        ButtonGroup
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % Group
        function value = get.ButtonGroup(this)
            % GET function
            action = this.getAction;
            value = action.ButtonGroup;
        end
        function set.ButtonGroup(this, value)
            % SET function
            action = this.getAction();
            action.ButtonGroup = value;
        end
        
    end
    
end

