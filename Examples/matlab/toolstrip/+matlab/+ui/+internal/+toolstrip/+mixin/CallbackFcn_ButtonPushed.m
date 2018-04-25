classdef (Abstract) CallbackFcn_ButtonPushed < handle
    % Mixin class inherited by Button and SplitButton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ButtonPushedFcn": 
        %
        %   This callback function executes when the button is pushed. 
        %
        %   Valid callback types are:
        %       * a function handle
        %       * a string
        %       * a 1xN cell array where the first element is either a function handle or a string
        %       * [], representing no callback
        %
        %   Example:
        %       btn.ButtonPushedFcn = @(x,y) disp('Callback fired!');
        ButtonPushedFcn
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.ButtonPushedFcn(this)
            % GET function
            action = this.getAction;
            value = action.PushPerformedFcn;
        end
        function set.ButtonPushedFcn(this, value)
            % SET function
            action = this.getAction();
            action.PushPerformedFcn = value;
        end
        
    end
    
end
