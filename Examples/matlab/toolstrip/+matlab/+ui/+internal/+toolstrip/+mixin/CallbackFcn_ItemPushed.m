classdef (Abstract) CallbackFcn_ItemPushed < handle
    % Mixin class inherited by ListItem

    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ItemPushedFcn": 
        %
        %   This callback function executes when the list itme is pushed or
        %   the shortcut key is activated. 
        %
        %   Valid callback types are:
        %       * a function handle
        %       * a string
        %       * a 1xN cell array where the first element is either a function handle or a string
        %       * [], representing no callback
        %
        %   Example:
        %       item.ItemPushedFcn = @(x,y) disp('Callback fired!');
        ItemPushedFcn
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.ItemPushedFcn(this)
            % GET function
            action = this.getAction;
            value = action.PushPerformedFcn;
        end
        function set.ItemPushedFcn(this, value)
            % SET function
            action = this.getAction();
            action.PushPerformedFcn = value;
        end
        
    end
    
end
