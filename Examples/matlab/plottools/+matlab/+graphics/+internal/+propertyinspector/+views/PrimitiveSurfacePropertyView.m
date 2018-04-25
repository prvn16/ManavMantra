classdef PrimitiveSurfacePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.primitive.Surface property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        FaceColor,
        FaceAlpha,
        FaceLighting,
        BackFaceLighting,
        EdgeColor,
        LineStyle,
        LineWidth,
        AlignVertexCenters,
        MeshStyle,
        EdgeAlpha,
        EdgeLighting,
        Marker,
        MarkerSize,
        MarkerEdgeColor,
        MarkerFaceColor,
        VertexNormalsMode,
        VertexNormals,
        FaceNormalsMode,
        FaceNormals,
        AmbientStrength,
        DiffuseStrength,
        SpecularStrength,
        SpecularExponent,
        SpecularColorReflectance,
        CData,
        CDataMode,
        XData,
        YData,
        ZData,
        XDataMode,
        YDataMode,
        ZDataMode,
        AlphaData,
        CDataMapping,
        AlphaDataMapping,       
        Annotation,
        DisplayName,
        Selected,
        SelectionHighlight,
        UIContextMenu,
        Clipping,
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
        UserData
    end
    
    methods
        function this = PrimitiveSurfacePropertyView(obj)
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
            g7.addProperties('XData','XDataMode','YData','YDataMode','ZData',...
                'ZDataMode');
            
            %...............................................................
            
            g71 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandTransparencyData')),'','');
            g71.addProperties('CData',...
                'CDataMode',...
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