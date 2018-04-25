classdef TextBoxPropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the matlab.graphics.shape.TextBox property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Color,
        Position,
        String,
        Interpreter,
        FontName,
        FontUnits,
        FontSize,
        FontAngle,
        FontWeight,
        HorizontalAlignment,
        VerticalAlignment,
        EdgeColor,
        LineStyle,
        LineWidth,
        BackgroundColor,
        Margin,
        Units,       
        FaceAlpha,
        FitBoxToText
    end
    
    methods
        function this = TextBoxPropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Text')),'','');
            g1.addProperties('String','Color','Interpreter');
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            g2.addProperties('FontName','FontSize','FontWeight');
            g2.addSubGroup('FontAngle','FontUnits');
            g2.Expanded = true;
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:TextBox')),'','');
            g3.addProperties('FitBoxToText','EdgeColor','BackgroundColor');
            g3.addSubGroup('FaceAlpha','LineStyle','LineWidth','Margin');
            g3.Expanded = true;
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g4.addEditorGroup('Position');
            g4.addProperties('Units','HorizontalAlignment','VerticalAlignment');             
        end
    end
end