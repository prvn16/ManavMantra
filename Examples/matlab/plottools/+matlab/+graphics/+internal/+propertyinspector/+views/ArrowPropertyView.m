classdef ArrowPropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the matlab.graphics.shape.Arrow property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Color,
        Position,
        LineStyle,
        LineWidth,
        Units,
        HeadWidth,
        HeadStyle,
        X,
        Y,
        HeadLength
    end
    
    methods
        function this = ArrowPropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Arrow')),'','');
            g1.addProperties('Color','LineStyle','LineWidth','HeadStyle','HeadLength','HeadWidth');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g2.addEditorGroup('X');
            g2.addEditorGroup('Y');
            g2.addEditorGroup('Position');
            g2.addProperties('Units');
            g2.Expanded = true;
        end
    end
end