classdef CommonPropertyViews < internal.matlab.inspector.InspectorProxyMixin 
    % CommonPropertyView - a helper class that creates common property groups
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods        
        
        function this = CommonPropertyViews(obj)
            this = this@internal.matlab.inspector.InspectorProxyMixin(obj);
        end
        
        function createCommonInspectorGroup(this)                   
            g10 = this.createGroup(getString(message('MATLAB:propertyinspector:Interactivity')),'','');
            
             % Editing is not always available, add it conditionally
             if isprop(this,'Editing')
                g10.addProperties('Editing');
             end
            
             % SlowAxesLimitsChange is not always available, add it conditionally
             if isprop(this,'SlowAxesLimitsChange')
                 g10.addProperties('SlowAxesLimitsChange');
             end
                                     
            g10.addProperties('Visible','UIContextMenu','Selected','SelectionHighlight');
            
            % clipping is not always available, add it conditionally
            if isprop(this,'Clipping')
                g10.addProperties('Clipping');
            end
            
            %...............................................................
            
            g11 = this.createGroup(getString(message('MATLAB:propertyinspector:Callbacks')),'','');
            
            % ItemHitFcn is not always available, add it conditionally
            if isprop(this,'ItemHitFcn')
                g11.addProperties('ItemHitFcn');
            end
            g11.addProperties('ButtonDownFcn','CreateFcn','DeleteFcn');
            
            %...............................................................            
            g12 = this.createGroup(getString(message('MATLAB:propertyinspector:CallbackExecutionControl')),'','');
            g12.addProperties('Interruptible','BusyAction','PickableParts','HitTest','BeingDeleted');
            
            %...............................................................
            
            g13 = this.createGroup(getString(message('MATLAB:propertyinspector:ParentChild')),'','');
            g13.addProperties('Parent','Children','HandleVisibility');
            
            %...............................................................
            
            g14 = this.createGroup(getString(message('MATLAB:propertyinspector:Identifiers')),'','');
            g14.addProperties('Type','Tag','UserData');
        end
               
        function createLegendGroup(this)
            g15 = this.createGroup(getString(message('MATLAB:propertyinspector:Legend')),'','');
            g15.addProperties('DisplayName','Annotation');
        end
        
    end
end