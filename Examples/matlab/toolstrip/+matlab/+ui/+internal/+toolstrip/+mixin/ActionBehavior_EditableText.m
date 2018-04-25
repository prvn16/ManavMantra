classdef (Abstract) ActionBehavior_EditableText < handle
    % Mixin class inherited by EditField and TextArea

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "Value": 
        %
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.EditField
        %       btn.Value = 'Submit'
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
            value = action.Text;
        end
        function set.Value(this, value)
            % SET function
            action = this.getAction();
            action.Text = value;
        end
        
    end
    
end
