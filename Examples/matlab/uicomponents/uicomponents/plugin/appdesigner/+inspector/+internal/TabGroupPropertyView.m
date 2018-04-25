classdef TabGroupPropertyView < inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.TabLocationMixin
    % This class provides the property definition and groupings for Tab
    % Group
    
    properties(SetObservable = true)        
        
        Visible
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
		
    end
    
    methods
        function obj = TabGroupPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
			
			inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:TabsGroup',...
				'TabLocation' ...				
				);
			

            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
            


        end               
    end
end