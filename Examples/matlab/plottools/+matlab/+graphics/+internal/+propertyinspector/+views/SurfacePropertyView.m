classdef SurfacePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.Surface property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        AlignVertexCenters,
        AlphaData,
        AlphaDataMapping,
        AmbientStrength,
        Annotation,
        BackFaceLighting,
        BeingDeleted,
        BusyAction,
        ButtonDownFcn,
        CData,
        CDataMapping,
        CDataMode,
        CDataSource,
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
        HandleVisibility,
        HitTest,
        Interruptible,
        LineStyle,
        LineWidth,
        Marker,
        MarkerEdgeColor,
        MarkerFaceColor,
        MarkerSize,
        MeshStyle,
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
        Visible,
        XData,
        XDataMode,
        XDataSource,
        YData,
        YDataMode,
        YDataSource,
        ZData,
        ZDataSource
        
    end
    
    methods
        function this = SurfacePropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Faces')),'','');
            g1.addProperties('FaceColor','FaceAlpha');
            g1.addSubGroup('FaceLighting','BackFaceLighting');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Edges')),'','');
            g2.addProperties('MeshStyle','EdgeColor','EdgeAlpha');
            g2.addSubGroup('LineStyle','LineWidth','AlignVertexCenters','EdgeLighting');
            g2.Expanded = 'true';
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g3.addProperties('Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor');
            
            
            %...............................................................
            
            g7 = this.createGroup(getString(message('MATLAB:propertyinspector:CoordinateData')),'','');
            g7.addProperties('XData',...
                'XDataMode',...
                'XDataSource',...
                'YData',...
                'YDataMode',...
                'YDataSource',...
                'ZData',...
                'ZDataSource');
            %...............................................................
            
            g71 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandTransparencyData')),'','');
            g71.addProperties('CData',...
                'CDataMode',...
                'CDataSource',...
                'CDataMapping',...
                'AlphaData',...
                'AlphaDataMapping');
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Normals')),'','');
            g4.addProperties('VertexNormals','VertexNormalsMode',...
                'FaceNormals','FaceNormalsMode');
            %...............................................................
            
            g5 = this.createGroup(getString(message('MATLAB:propertyinspector:Lighting')),'','');
            g5.addProperties('AmbientStrength','DiffuseStrength','SpecularStrength',...
                'SpecularExponent','SpecularColorReflectance');
            
            %...............................................................
            
            this.createLegendGroup();
            
            %...............................................................
            this.createCommonInspectorGroup();
        end
    end
end