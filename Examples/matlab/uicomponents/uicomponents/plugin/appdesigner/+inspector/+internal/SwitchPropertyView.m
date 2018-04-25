classdef SwitchPropertyView < ...
		inspector.internal.AppDesignerPropertyView & ...		 
		inspector.internal.mixin.LinearOrientationMixin & ...
		inspector.internal.mixin.FontMixin
    % This class provides the property definition and groupings for Switch
    
    properties(SetObservable = true)              

       
        Value@internal.matlab.variableeditor.datatype.ItemsValue
         
        Items@internal.matlab.variableeditor.datatype.ExactlyTwoItems
        ItemsData@internal.matlab.variableeditor.datatype.ItemsValue                
        
        Enable
        Visible
      
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        		
		FontColor@matlab.graphics.datatype.RGBColor		
    end
    
    methods
        function obj = SwitchPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);

            titleCatalogId = 'MATLAB:ui:propertygroups:SwitchGroup';
            group = inspector.internal.CommonPropertyView.createOptionsGroup(obj, titleCatalogId);
            group.addProperties('Orientation');         
                      
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
            


        end               
    end
end