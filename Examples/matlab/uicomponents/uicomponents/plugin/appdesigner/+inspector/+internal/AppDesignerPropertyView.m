classdef AppDesignerPropertyView < ...
        inspector.internal.AppDesignerNoPositionPropertyView & ...
        inspector.internal.mixin.PositionMixin
    
    %   Copyright 2016-2017 The MathWorks, Inc.

    methods
        
        function obj = AppDesignerPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerNoPositionPropertyView(componentObject);
        end
 
    end
end


