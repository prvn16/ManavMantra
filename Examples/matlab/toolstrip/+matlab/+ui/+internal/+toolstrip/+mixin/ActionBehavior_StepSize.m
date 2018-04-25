classdef (Abstract) ActionBehavior_StepSize < handle
    % Mixin class inherited by Spinner

    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "NumberFormat": 
        %
        %   Numeric format taken by the value such as integer or double. It
        %   is a char array and the default value is 'integer'. It is
        %   writable.
        %
        %   Example:
        %       spinner = matlab.ui.internal.toolstrip.Spinner();
        %       spinner.NumberFormat = 'double';
        NumberFormat
        % Property "StepSize": 
        %
        %   The step size used when up or down arrow key is pressed. It is
        %   a real number and the default value is 1. It is writable.
        %
        %   Example:
        %       spinner = matlab.ui.internal.toolstrip.Spinner();
        %       spinner.StepSize = 0.5;
        StepSize
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.NumberFormat(this)
            % GET function for NumberFormat property.
            action = this.getAction;
            value = action.NumberFormat;
        end
        function set.NumberFormat(this, value)
            % SET function for NumberFormat property.
            action = this.getAction();
            action.NumberFormat = value;
        end
        function value = get.StepSize(this)
            % GET function for MinorStepSize property.
            action = this.getAction;
            value = action.MinorStepSize;
        end
        function set.StepSize(this, value)
            % SET function for MinorStepSize property.
            action = this.getAction();
            action.MinorStepSize = value;
            action.MajorStepSize = value;
        end
        
    end
    
end
