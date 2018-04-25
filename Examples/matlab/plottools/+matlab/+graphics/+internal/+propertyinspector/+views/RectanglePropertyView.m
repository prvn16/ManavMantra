classdef RectanglePropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the matlab.graphics.shape.Rectangle property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties       
        Color
        FaceAlpha
        FaceColor
        LineStyle
        LineWidth
        Position   
    end
    
    methods
        function this = RectanglePropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('Color','FaceColor','FaceAlpha','LineStyle','LineWidth');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g2.addEditorGroup('Position');
            g2.addProperties('Units');
            g2.Expanded = true;                       
        end
    end
end