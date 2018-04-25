classdef (Abstract) CallbackFcn_ValueChanged < handle
    % Mixin class inherited by Slider and Spinner
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ValueChangedFcn": 
        %
        %   This callback function executes when the value stops changing.
        %
        %   Valid callback types are:
        %       * a function handle
        %       * a string
        %       * a 1xN cell array where the first element is either a function handle or a string
        %       * [], representing no callback
        %
        %   Example:
        %       slider.ValueChangedFcn = @(x,y) disp('Callback fired!');
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
            value = action.ValueChangedFcn;
        end
        function set.ValueChangedFcn(this, value)
            % SET function
            action = this.getAction();
            action.ValueChangedFcn = value;
        end
        
    end
    
end
