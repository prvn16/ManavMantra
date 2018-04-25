classdef (Abstract) ActionBehavior_Label < handle
    % Mixin class inherited by ListItemWithEditField

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
        %       item = matlab.ui.internal.toolstrip.ListItemWithEditField()
        %       item.Text = 'Degrees:'
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
            value = action.Label;
        end
        function set.Text(this, value)
            % SET function
            action = this.getAction();
            action.Label = value;
        end
        
    end
    
end
