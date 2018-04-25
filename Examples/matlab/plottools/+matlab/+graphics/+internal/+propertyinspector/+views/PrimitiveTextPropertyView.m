classdef PrimitiveTextPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    
    % This class has the metadata information on the matlab.graphics.primitive.Text property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        CreateFcn,
        DeleteFcn,
        ButtonDownFcn,
        Tag,
        Type,
        UserData,
        Children,
        HandleVisibility,
        Parent,
        Visible,
        BusyAction,
        HitTest,
        Interruptible,
        PickableParts,
        BeingDeleted,
        Editing,
        Selected,
        SelectionHighlight,
        UIContextMenu,
        Clipping,
        Extent,
        Position,
        Units,
        FontAngle,
        FontSmoothing,
        FontUnits,
        Interpreter,
        Color,
        FontName,
        FontSize,
        FontWeight,
        VerticalAlignment,
        LineStyle,
        LineWidth,
        Margin,
        HorizontalAlignment,
        Rotation,
        BackgroundColor,
        EdgeColor,
        String
    end
    
    methods
        function this = PrimitiveTextPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Text')),'','');
            g1.addProperties('String','Color','Interpreter');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            g3.addProperties('FontName','FontSize','FontWeight');
            g3.addSubGroup('FontAngle','FontUnits','FontSmoothing');
            g3.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:TextBox')),'','');
            g2.addProperties('Rotation','EdgeColor','BackgroundColor');
            g2.addSubGroup('LineStyle','LineWidth','Margin','Extent');
            g2.Expanded = 'true';
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g4.addEditorGroup('Position');
            g4.addProperties('Units','HorizontalAlignment','VerticalAlignment');
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end