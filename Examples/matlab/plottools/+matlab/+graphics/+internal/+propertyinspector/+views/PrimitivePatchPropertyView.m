classdef PrimitivePatchPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.primitive.Patch property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        AlignVertexCenters,
        AlphaDataMapping,
        AmbientStrength,
        Annotation,
        BackFaceLighting,
        BeingDeleted,
        BusyAction,
        ButtonDownFcn,
        CData,
        CDataMapping,
        Children,
        Clipping,
        CreateFcn,
        DeleteFcn,
        DiffuseStrength,
        DisplayName,
        EdgeAlpha,
        EdgeColor,
        EdgeLighting,
        FaceAlpha,
        FaceColor,
        FaceLighting,
        FaceNormals,
        FaceNormalsMode,
        FaceVertexAlphaData,
        FaceVertexCData,
        Faces,
        HandleVisibility,
        HitTest,
        Interruptible,
        LineStyle,
        LineWidth,
        Marker,
        MarkerEdgeColor,
        MarkerFaceColor,
        MarkerSize,
        Parent,
        PickableParts,
        Selected,
        SelectionHighlight,
        SpecularColorReflectance,
        SpecularExponent,
        SpecularStrength,
        Tag,
        Type,
        UIContextMenu,
        UserData,
        VertexNormals,
        VertexNormalsMode,
        Vertices,
        Visible,
        XData,
        YData,
        ZData
    end
    
    methods
        function this = PrimitivePatchPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Color')),'','');
            g1.addProperties('FaceColor','EdgeColor','CData');
            g1.addSubGroup('FaceVertexCData','CDataMapping');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Transparency')),'','');
            g2.addProperties('FaceAlpha','EdgeAlpha','FaceVertexAlphaData','AlphaDataMapping');
            g2.Expanded = 'true';
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:LineStyling')),'','');
            g3.addProperties('LineStyle','LineWidth','AlignVertexCenters');
            g3.Expanded = true;
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g4.addProperties('Marker','MarkerSize','MarkerEdgeColor',...
                'MarkerFaceColor');
            
            %...............................................................
            
            g5 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g5.addProperties('Faces','Vertices','XData','YData','ZData');
            
            %...............................................................
            
            g6 = this.createGroup(getString(message('MATLAB:propertyinspector:Normals')),'','');
            g6.addProperties('VertexNormalsMode','VertexNormals','FaceNormalsMode','FaceNormals');
            
            %...............................................................
            
            
            g6 = this.createGroup(getString(message('MATLAB:propertyinspector:Lighting')),'','');
            g6.addProperties('FaceLighting','BackFaceLighting','EdgeLighting',...
                'AmbientStrength','DiffuseStrength','SpecularStrength',...
                'SpecularExponent','SpecularColorReflectance');
            
            %...............................................................
            
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end