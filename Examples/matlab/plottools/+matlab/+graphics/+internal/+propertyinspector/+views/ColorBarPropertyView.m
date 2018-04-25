classdef ColorBarPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.illustration.ColorBar property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        AxisLocation
        AxisLocationMode
        BeingDeleted
        Box
        BusyAction
        ButtonDownFcn
        Children
        Color
        CreateFcn
        DeleteFcn
        Direction
        FontAngle
        FontName
        FontSize
        FontWeight
        HandleVisibility
        HitTest
        Interruptible
        Label
        Limits
        LimitsMode
        LineWidth
        Location
        Parent
        PickableParts
        Position
        Selected
        SelectionHighlight
        Tag
        TickDirection
        TickLabelInterpreter
        TickLabels@internal.matlab.variableeditor.datatype.TicksLabelType,
        TickLabelsMode
        TickLength
        Ticks
        TicksMode
        Type
        UIContextMenu
        Units
        UserData
        Visible
        
    end
    
    methods
        function this = ColorBarPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:TicksandLabels')),'','');
            
            g1.addEditorGroup('Ticks','TickLabels');
            g1.addProperties('TicksMode');
            g1.addSubGroup('TickLabelsMode','TickLabelInterpreter','Limits',...
                'LimitsMode','Label','Direction','TickLength','TickDirection');
            
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            g2.addProperties('FontName','FontSize','FontWeight','FontAngle');
            g2.Expanded = true;
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g3.addProperties('Location','AxisLocation');
            g31 = g3.addSubGroup();
            g31.addProperties('AxisLocationMode');
            g31.addEditorGroup('Position');
            g31.addProperties('Units');            
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g4.addProperties('Color','Box','LineWidth');
            
            %...............................................................
            
            this.createCommonInspectorGroup();
            
        end
        
        function value = get.TickLabels(this)
            value = this.OriginalObjects.TickLabels;
        end
        
        function set.TickLabels(this, value)
            if ~this.InternalPropertySet
                for idx = 1:length(this.OriginalObjects)
                    if ~isequal(this.OriginalObjects(idx).TickLabels,value.getText)
                        this.OriginalObjects(idx).TickLabels = value.getText;
                    end
                end
            end
            
        end
        
    end
end