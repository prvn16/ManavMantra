classdef (Abstract) ActionBehavior_Selected < handle
    % Mixin class inherited by CheckBox, RadioButton, ToggleButton and
    % ListItemWithCheckBox.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.

    properties (Dependent, Access = public)
        % Property "Value": 
        %
        %   The selected state of a control
        %   It is a logical and the default value is false.
        %   It is writable.
        %
        %   Example:
        %       chk = matlab.ui.internal.toolstrip.CheckBox('Show numbers')
        %       chk.Value = true
        %
        %       rdo = matlab.ui.internal.toolstrip.RadioButton('Show numbers')
        %       rdo.Value = true
        %
        %       tgl = matlab.ui.internal.toolstrip.ToggleButton('Show numbers')
        %       tgl.Value = true
        %   
        %       chk = matlab.ui.internal.toolstrip.ListItemWithCheckBox('Show numbers')
        %       chk.Value = true
        Value
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)

    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Value(this)
            % GET function
            action = this.getAction;
            value = action.Selected;
        end
        function set.Value(this, value)
            % SET function
            action = this.getAction();
            action.Selected = value;
        end
        
    end
    
end

