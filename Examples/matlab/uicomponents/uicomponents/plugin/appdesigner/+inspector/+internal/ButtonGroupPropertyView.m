classdef ButtonGroupPropertyView < ... 
		inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.TitlePositionMixin & ...
		inspector.internal.mixin.BorderTypeMixin & ...
		inspector.internal.mixin.FontMixin
    % This class provides the property definition and groupings for Button
    % group
    
    properties(SetObservable = true)                                       
        Visible
		
		Title@char vector        		                                                      
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
        ForegroundColor@matlab.graphics.datatype.RGBColor        
        BackgroundColor@matlab.graphics.datatype.RGBColor        						
	end
    
    methods
        function obj = ButtonGroupPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:TitleGroup',...
                                                                                    'Title', ...
                                                                                    'TitlePosition' ...                                                                                    
                                                                                    );            
            
            % Create groups common to panel - like components
            inspector.internal.CommonPropertyView.createPanelPropertyGroups(obj);            

        end               
    end
end