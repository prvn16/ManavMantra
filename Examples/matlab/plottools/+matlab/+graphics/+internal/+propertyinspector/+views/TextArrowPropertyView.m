classdef TextArrowPropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the matlab.graphics.shape.TextArrow property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Color,
        Position,
        String,
        Interpreter,
        TextRotation,
        FontName,
        FontUnits,
        FontSize,
        FontAngle,
        TextEdgeColor,
        FontWeight,
        TextColor,
        TextBackgroundColor,
        HorizontalAlignment,
        VerticalAlignment,
        LineStyle,
        LineWidth,
        Units,        
        TextLineWidth,
        TextMargin,
        HeadWidth,
        HeadStyle,
        X,
        Y,
        HeadLength
    end
    
    methods
        function this = TextArrowPropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Text')),'','');
            g1.addProperties('String','TextRotation','TextColor');
            g1.addSubGroup('TextEdgeColor','TextBackgroundColor',...
                'TextLineWidth','TextMargin','Interpreter');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            g3.addProperties('FontName','FontSize','FontWeight');
            g3.addSubGroup('FontAngle','FontUnits');
            g3.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Arrow')),'','');
            g2.addProperties('Color','LineStyle','LineWidth');
            g2.addSubGroup('HeadStyle','HeadLength','HeadWidth');
            g2.Expanded = 'true';
                        
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g4.addEditorGroup('X');
            g4.addEditorGroup('Y');
            g4.addEditorGroup('Position');
            g4.addProperties('Units','HorizontalAlignment','VerticalAlignment');
        end
    end
end