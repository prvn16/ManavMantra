classdef (Abstract) ActionBehavior_IsInQuickAccess < handle
    % Mixin class inherited by Button, DropDownButton, SplitButton,
    % ToggleButton, ListItem and ListItemWithPopup
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, SetAccess = protected, Hidden)
        % Property "IsInQuickAccess": 
        %
        %   Whether the control is in quick access bar. It is a logical and
        %   the default value is false. It is a read-only property.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button();
        %       btn.IsInQuickAccess % returns false
        %       btn.addToQuickAccess();
        %       btn.IsInQuickAccess % returns true
        %
        IsInQuickAccess
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)        
        
    end
    
    methods (Abstract, Hidden)
        
        getType(this)        
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % IsFavorite
        function value = get.IsInQuickAccess(this)
            % GET function
            action = this.getAction;
            value = action.IsInQuickAccess;
        end
        
    end
    
    methods (Hidden)
        
        function addToQuickAccess(this, varargin)
            % Method "addToQuickAccess":
            %
            %   "addToQuickAccess(btn)": add this control to the quick
            %   access bar. 
            %   Example:
            %       btn = matlab.ui.internal.toolstrip.Button('New',Icon.NEW_16)
            %       btn.addToQuickAccess()

            action = this.getAction();
            if action.IsInQuickAccess
                return
            end
            parent = this.Parent;
            while ~isempty(parent)
                parent = parent.Parent;
                if isa(parent, 'matlab.ui.internal.toolstrip.TabGroup')
                    break;
                end
            end
            if isempty(parent)
                error(message('MATLAB:toolstrip:control:failToAddToQuickAccess'));
            end
            switch this.getType()
                case 'PushButton'
                    ctrl = matlab.ui.internal.toolstrip.impl.QABPushButton(action);
                case 'DropDownButton'
                    ctrl = matlab.ui.internal.toolstrip.impl.QABDropDownButton(action);
                case 'SplitButton'
                    ctrl = matlab.ui.internal.toolstrip.impl.QABSplitButton(action);
                case 'ToggleButton'
                    ctrl = matlab.ui.internal.toolstrip.impl.QABToggleButton(action);
            end
            ctrl.Tag = this.Tag;
            qagroup = parent.getQuickAccessGroup();
            qagroup.add(ctrl, varargin{:});
            action.IsInQuickAccess = true;
        end
        
        function removeFromQuickAccess(this)
            % Method "removeFromQuickAccess":
            %
            %   "removeFromQuickAccess(btn)": remove this control from
            %   the quick access bar.
            %   Example:
            %       btn = matlab.ui.internal.toolstrip.Button('New',Icon.NEW_16)
            %       btn.addToQuickAccess()
            %       btn.removeFromQuickAccess()
            
            action = this.getAction();
            if ~action.IsInQuickAccess
                return
            end
            parent = this.Parent;
            while ~isempty(parent)
                parent = parent.Parent;
                if isa(parent, 'matlab.ui.internal.toolstrip.TabGroup')
                    break;
                end
            end
            if isempty(parent)
                error(message('MATLAB:toolstrip:control:failToRemoveFromQuickAccess'));
            end
            qagroup = parent.getQuickAccessGroup();
            for ct=1:length(qagroup.Children)
                ctrl = qagroup.Children(ct);
                if ctrl.getAction()==action
                    qagroup.remove(ctrl);
                    break
                end
            end
            action.IsInQuickAccess = false;                    
        end
        
    end
    
end