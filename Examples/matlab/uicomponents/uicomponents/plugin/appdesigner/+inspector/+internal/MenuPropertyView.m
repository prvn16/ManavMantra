classdef MenuPropertyView < ...
		internal.matlab.inspector.InspectorProxyMixin & ...
		matlab.ui.internal.componentframework.services.optional.ControllerInterface
		
	% This class provides the property definition and groupings for UIMenu
    
    % It deviates from the architectural convention of subclassing from AppDesignerPropertyView 
    % This is because AppDesignerPropertyView mixes in PositionMixin that
    % expects Position property to be of type matlab.graphics.datatype.Position
    % but UIMenu has a Position property that means something completely
    % different
	
	properties(SetObservable = true)
        
        Accelerator@char vector     
        Separator
        Checked
        Enable
        Visible
     
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
        BusyAction
        Interruptible
        
        ForegroundColor@matlab.graphics.datatype.RGBAColor
        
    end   
    
    % The UIMenu component's API was updated to have a Text
    % property but there is still tech debt remaining to update
    % the view property (on peer-node) to reflect this
    %
    % The following configuration works around this by using the
    % Label property to look up and update the peer-node 
    % but display 'Text' in the inspector
    %
    % When this work is completed, this workaround can be removed
    properties(SetObservable = true, Description = 'Text')
        Label@char vector
    end
    
    methods
        function obj = MenuPropertyView(componentObject)
            obj = obj@internal.matlab.inspector.InspectorProxyMixin(componentObject);            
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:MenuGroup',...
                                                                                    'Label', 'Accelerator', 'Separator',...
                                                                                    'Checked');
                         
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj, false);
            
            %  Start expanded

		end               			
		
	end		
end