classdef TablePropertyView <  ... 
		inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.EnableMixin & ...
		inspector.internal.mixin.FontMixin
	% This class provides the property definition and groupings for Table
	
	properties(SetObservable = true)				
		
        RowStriping@matlab.graphics.datatype.on_off
        		
        ForegroundColor@matlab.graphics.datatype.RGBColor
        
		Visible@matlab.graphics.datatype.on_off
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
	end    
        
    properties(SetAccess = private, SetObservable = true)	
        % By making these private, it has the effect that users 
        % will not be able to edit these widgets in the inspector
        % This is temporary until Data Tools delivers editors that support
        % the data-types corresponding to the below properties
        ColumnName@matlab.graphics.datatype.UINumericOrString
        ColumnWidth@matlab.graphics.datatype.NumericOrString
        ColumnEditable@matlab.graphics.datatype.NumericOrString
        % g1389637 - Data property will be shown in the inspector
        % to aid discoveribility of this property
        Data@matlab.graphics.datatype.NumericOrString
    end
	
	methods
		function obj = TablePropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj,'MATLAB:ui:propertygroups:TableGroup', ...                
                'Data', ...
                'ColumnName', ...
                'ColumnWidth', ...
                'ColumnEditable' ...
                );
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:FontGroup', ...
                'FontName', ...
                'FontSize',...
                'FontWeight', ...
                'FontAngle'...
                );            
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:ColorAndStylingGroup', ...
                'ForegroundColor',...
                'BackgroundColor',...
                'RowStriping' ...
                );                                                
            
			% Common properties across all components			 
            inspector.internal.CommonPropertyView.createInteractivityGroup(obj);                        
            inspector.internal.CommonPropertyView.createPositionGroup(obj);                        
            inspector.internal.CommonPropertyView.createCallbackExecutionControlGroup(obj);
            inspector.internal.CommonPropertyView.createParentChildGroup(obj);            
			
			

		end
	end
end