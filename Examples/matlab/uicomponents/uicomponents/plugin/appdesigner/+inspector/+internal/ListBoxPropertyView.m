classdef ListBoxPropertyView < inspector.internal.AppDesignerPropertyView & ...
        inspector.internal.mixin.FontMixin
    % This class provides the property definition and groupings for Listbox
    
    properties(SetObservable = true)
        
        % Value allows multiple inputs (based on multi select)
        Value@internal.matlab.variableeditor.datatype.MultipleItemsValue
        
        Items@internal.matlab.variableeditor.datatype.MoreThanZeroItems
        ItemsData@internal.matlab.variableeditor.datatype.ItemsValue
        Multiselect
        
        Enable
        Visible
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
        
        FontColor@matlab.graphics.datatype.RGBColor
        BackgroundColor@matlab.graphics.datatype.RGBColor
    end
    
    methods
        function obj = ListBoxPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            titleCatalogId = 'MATLAB:ui:propertygroups:ListBoxGroup';
            inspector.internal.CommonPropertyView.createOptionsGroup(obj, titleCatalogId);
            
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
        end
    end
end