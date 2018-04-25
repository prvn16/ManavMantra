classdef Action < handle
% ACTION Class that holds the information to create a UI action.
    
% Copyright 2012-2014 The MathWorks, Inc.
    
    properties
       Icon
       Label
       UniqueTag
       Callback
       MenuGroup
       Enabled = true
       DefaultState = 'off';
    end
    
    methods
        function this = Action(icon, label, tag, callback, varargin)
            this.Icon = icon;
            this.Label = label;
            this.UniqueTag = tag;
            this.Callback = callback;
            if nargin > 4
                this.MenuGroup = varargin{1};
            else
                this.MenuGroup = '';
            end
        end
        
        function enableAction(this)
            this.Enabled = true;
        end
        
        function setDefaultState(this, flag)
            if ~strcmpi(flag,'on') && ~strcmpi(flag,'off') 
                [msg, id] = fxptui.message('incorrectInputValue','on/off');
                throw(MException(id, msg));
            end
            this.DefaultState = lower(flag);
        end
        
         function disableAction(this)
            this.Enabled = false;
        end
    end
end
