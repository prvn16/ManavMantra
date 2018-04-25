classdef DropDownPropertyView < inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.FontMixin
    % This class provides the property definition and groupings for
    % Dropdown
    
    properties(SetObservable = true)              
         
        Value@internal.matlab.variableeditor.datatype.ItemsValue
         
        Items@internal.matlab.variableeditor.datatype.MoreThanZeroOptions
        ItemsData@internal.matlab.variableeditor.datatype.ItemsValue
         
        Enable
        Editable
        Visible                  
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
                
        FontColor@matlab.graphics.datatype.RGBColor
        BackgroundColor@matlab.graphics.datatype.RGBColor
    end
    
    methods
        function obj = DropDownPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            titleCatalogId = 'MATLAB:ui:propertygroups:DropDownGroup';
            inspector.internal.CommonPropertyView.createOptionsGroup(obj, titleCatalogId);

            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
            


        end
    end
end