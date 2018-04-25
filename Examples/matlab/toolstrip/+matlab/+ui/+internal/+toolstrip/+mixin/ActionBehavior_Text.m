classdef (Abstract) ActionBehavior_Text < handle
    % Mixin class inherited by Buttons, ListItems, Label, CheckBox,
    % RadioButton and PopupListHeader

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "Text": 
        %
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button
        %       btn.Text = 'Submit'
        Text
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Text(this)
            % GET function
            action = this.getAction;
            value = action.Text;
        end
        function set.Text(this, value)
            % SET function
            action = this.getAction();
            action.Text = value;
        end
        
    end
    
end
