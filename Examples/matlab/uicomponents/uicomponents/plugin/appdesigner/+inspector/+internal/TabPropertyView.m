classdef TabPropertyView < inspector.internal.AppDesignerPropertyView
    % This class provides the property definition and groupings for Tab
    
    properties(SetObservable = true)        
        
        Title@char vector
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
        ForegroundColor@matlab.graphics.datatype.RGBAColor
        BackgroundColor@matlab.graphics.datatype.RGBAColor
    end    
   
    
    methods
        function obj = TabPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:TitleAndColorGroup',...
                'Title', ...
                'ForegroundColor', ...
                'BackgroundColor');                                                                                            
            
            
            inspector.internal.CommonPropertyView.createCallbackExecutionControlGroup(obj);
            inspector.internal.CommonPropertyView.createParentChildGroup(obj);            

        end               
    end
end