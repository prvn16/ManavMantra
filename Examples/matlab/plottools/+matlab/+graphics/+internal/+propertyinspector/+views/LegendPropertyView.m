classdef LegendPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.illustration.Legend property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        String,
        Title,
        AutoUpdate,
        Location,
        Orientation,
        Position,
        Units,
        Color,
        EdgeColor,
        TextColor,
        Box,
        LineWidth,
        FontName,
        FontSize,
        FontAngle,
        FontWeight,
        Interpreter,
        Selected,
        SelectionHighlight,
        UIContextMenu,
        Visible,
        CreateFcn,
        DeleteFcn,
        ButtonDownFcn,
        BeingDeleted,
        BusyAction,
        HitTest,
        PickableParts,
        Interruptible,
        Children,
        HandleVisibility,
        Parent,
        Tag,
        Type,
        UserData,
        NumColumns,
        NumColumnsMode,
        ItemHitFcn
    end
    
    methods
        function this = LegendPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:PositionandLayout')),'','');
            g1.addProperties('Location','Orientation','NumColumns');
            g21 = g1.addSubGroup('');
            g21.addProperties('NumColumnsMode');
            % Position property has a rich editor
            g21.addEditorGroup('Position');
            g21.addProperties('Units');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Labels')),'','');
            g2.addProperties('AutoUpdate','String','Title','Interpreter');
            g2.Expanded = 'true';
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            g3.addProperties('FontName','FontSize','FontWeight','FontAngle');
            
            %...............................................................                        
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g4.addProperties('TextColor','Color','EdgeColor');
            g4.addSubGroup('Box','LineWidth');
                       
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end