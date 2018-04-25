classdef ParameterizedFunctionSurfacePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.function.ParameterizedFunctionSurface property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        
        AmbientStrength
        Annotation
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        CreateFcn
        DeleteFcn
        DiffuseStrength
        DisplayName
        EdgeColor
        FaceAlpha
        FaceColor
        HandleVisibility
        HitTest
        Interruptible
        LineStyle
        LineWidth
        Marker
        MarkerEdgeColor
        MarkerFaceColor
        MarkerSize
        MeshDensity
        Parent
        PickableParts
        Selected
        SelectionHighlight
        ShowContours
        SpecularColorReflectance
        SpecularExponent
        SpecularStrength
        Tag
        Type
        UIContextMenu
        URange
        URangeMode
        UserData
        VRange
        VRangeMode
        Visible
        XData
        XFunction
        YData
        YFunction
        ZData
        ZFunction
        
        
        
        
    end
    
    methods
        function this = ParameterizedFunctionSurfacePropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Faces')),'','');
            g3.addProperties('FaceColor','FaceAlpha');
            g3.Expanded = true;
            
            %...............................................................
            g31 = this.createGroup(getString(message('MATLAB:propertyinspector:Edges')),'','');
            g31.addProperties('EdgeColor','LineStyle','LineWidth');
            g31.Expanded = true;
            %...............................................................
            
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g2.addProperties('Marker','MarkerSize',...
                'MarkerEdgeColor','MarkerFaceColor');
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Function')),'','');
            g1.addProperties('XFunction',...
                'YFunction',...
                'ZFunction',...
                'URange',...
                'URangeMode',...
                'VRange',...
                'VRangeMode',...
                'MeshDensity',...
                'ShowContours');
            
            %...............................................................
            
            
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g4.addProperties('XData','YData','ZData');
            
            %...............................................................
            
            g31 = this.createGroup(getString(message('MATLAB:propertyinspector:Lighting')),'','');
            g31.addProperties('AmbientStrength',...
                'DiffuseStrength',...
                'SpecularStrength',...
                'SpecularExponent',...
                'SpecularColorReflectance');
                        
            %...............................................................            
            this.createLegendGroup();            
            %...............................................................
            
           this.createCommonInspectorGroup();

        end
    end
end