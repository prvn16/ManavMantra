classdef (Abstract) ActionBehavior_Value < handle
    % Mixin class inherited by Slider and Spinner

    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Limits": 
        %
        %   Slider minimum and maximum values. It is row vector of 2 real
        %   numbers and the default value is [0 100]. It is writable.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider
        %       slider.Limits = [-10 10];
        Limits
    end
    
    properties (Dependent, Access = public)
        % Property "Value": 
        %
        %   It is a real number and the default value is 50.
        %   It is writable.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider(0,100,50)
        %       slider.Value = 70
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
            % GET function for Value property.
            action = this.getAction;
            value = action.Value;
        end
        function set.Value(this, value)
            % SET function for Value property.
            action = this.getAction();
            action.Value = value;
        end
        
        function value = get.Limits(this)
            % GET function for Limits property.
            action = this.getAction;
            value = [action.Minimum action.Maximum];
        end
        function set.Limits(this, value)
            % SET function for Limits property.
            action = this.getAction();
            action.Minimum = value(1);
            action.Maximum = value(2);
        end
    end
    
end
