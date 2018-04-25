classdef (Abstract) CallbackFcn_SelectionChanged < handle
    % Mixin class inherited by ToggleButton, CheckBox and ListItemWithCheckBox
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ValueChangedFcn": 
        %
        %   This callback function executes when the control is selected or
        %   unselected or the shortcut key is activated.
        %
        %   Valid callback types are:
        %       * a function handle
        %       * a string
        %       * a 1xN cell array where the first element is either a function handle or a string
        %       * [], representing no callback
        %
        %   Example:
        %       btn.ValueChangedFcn = @(x,y) disp('Callback fired!');
        ValueChangedFcn
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.ValueChangedFcn(this)
            % GET function
            action = this.getAction;
            value = action.SelectionChangedFcn;
        end
        function set.ValueChangedFcn(this, value)
            % SET function
            action = this.getAction();
            action.SelectionChangedFcn = value;
        end
        
    end
    
end
