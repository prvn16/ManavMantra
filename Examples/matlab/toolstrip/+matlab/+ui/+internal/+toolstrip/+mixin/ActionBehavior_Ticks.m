classdef (Abstract) ActionBehavior_Ticks < handle
    % Mixin class inherited by Slider

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Labels": 
        %
        %   The N-by-2 cell vector.  First column consists of strings
        %   displayed as labels under the slider.  Second column consists
        %   of corresponding locations.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider
        %       slider.Labels = {'low' 0;'medium' 30;'high' '100'};
        Labels
        % Property "Ticks": 
        %
        %   The number of minor ticks that are evenly displayed under the
        %   slider, including both ends.  The value must be a non-negative
        %   finite integer.  When it is zero, there is no minor ticks
        %   displayed.  The default value is 11.
        %
        %   Note that property "Steps" and "MinorTicks" are not related.
        %   However, "MinorTicks" should be no greater than "Steps"+1 for
        %   visualization.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider
        %       slider.Ticks = 5;
        Ticks
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Labels(this)
            % GET function for Labels property.
            action = this.getAction;
            value = action.Labels;
        end
        function set.Labels(this, value)
            % SET function for Labels property.
            action = this.getAction();
            action.Labels = value;
        end
        
        function value = get.Ticks(this)
            % GET function for MinorTicks property.
            action = this.getAction;
            value = action.Ticks;
        end
        function set.Ticks(this, value)
            % SET function for MinorTicks property.
            action = this.getAction();
            action.Ticks = value;
        end
        
    end
    
end
