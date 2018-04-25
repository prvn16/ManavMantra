classdef ChartLinePropertyView <  matlab.graphics.internal.propertyinspector.views.CommonPropertyViews &  matlab.graphics.internal.propertyinspector.views.CartesianPolarMixin
    % This class has the metadata information on the matlab.graphics.chart.primitive.Line property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Color
        LineStyle
        LineWidth
        AlignVertexCenters
        LineJoin
        Clipping
        Marker
        MarkerSize
        MarkerEdgeColor
        MarkerFaceColor
        MarkerIndices
        Annotation
        DisplayName
        Selected
        SelectionHighlight
        UIContextMenu
        Visible
        CreateFcn
        DeleteFcn
        ButtonDownFcn
        BeingDeleted
        BusyAction
        HitTest
        PickableParts
        Interruptible
        Children
        HandleVisibility
        Parent
        Tag
        Type
        UserData
    end
    
    methods
        function this = ChartLinePropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g2.addProperties('Color','LineStyle','LineWidth');
            g2.addSubGroup('LineJoin','AlignVertexCenters');
            g2.Expanded = true;
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g1.addProperties('Marker','MarkerIndices','MarkerSize');
            g1.addSubGroup('MarkerEdgeColor','MarkerFaceColor');
            g1.Expanded = true;
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            
            % there could be multiple objects parented to different types of
            % axes: Cartesian/Polar.
            % Check if the objects share the same dataspace type, if yes, populate the Data/DataSource
            % groups, otherwise leave them empty
            allPolar = numel(findobj(obj,'-property','RData')) == numel(obj);
            allCartesian = numel(findobj(obj,'-property','XData','-and','-not','-property','RData')) == numel(obj);
           
            if allPolar
                this.addPolarProperties(obj);
                g3.addProperties('RData','RDataSource',...
                    'ThetaData','ThetaDataMode','ThetaDataSource');
            elseif allCartesian
                % Cartesian or empty
                this.addCartesianProperties(obj);
                g3.addProperties('XData','XDataSource','XDataMode','YData','YDataSource','ZData','ZDataSource');
            end
                         
            %...............................................................           
            
            this.createLegendGroup();
            
            %...............................................................                       
           this.createCommonInspectorGroup();
         
        end
    end
end