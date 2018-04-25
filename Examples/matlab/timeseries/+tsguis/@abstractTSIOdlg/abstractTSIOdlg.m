classdef abstractTSIOdlg < matlab.mixin.SetGet & matlab.mixin.Copyable
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=protected, SetObservable, GetObservable)
        ScreenSize = [];
    end
    
    properties (SetObservable, GetObservable)
        Visible@matlab.graphics.datatype.on_off = 'off';
        Handles = [];
        Figure = [];
        Parent = [];
        Listeners = [];
        DeleteListener = [];
        DefaultPos = [];
    end
    
    methods
        function set.Visible(obj,value)
            obj.Visible = value;
        end
        
        function set.Parent(obj,value)
            obj.Parent = value;
        end
    end
    
    methods (Hidden)
        addlisteners(h,L)
        generic_listeners(h)
        update(h)
    end
end