classdef PrimitiveScatterPropertyView <  matlab.graphics.internal.propertyinspector.views.CartesianPolarMixin & matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.Scatter property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Marker
        LineWidth
        MarkerEdgeColor
        MarkerFaceColor
        MarkerEdgeAlpha
        MarkerFaceAlpha
        CData
        SizeData
        CDataSource
        SizeDataSource
        Annotation
        DisplayName
        Selected
        SelectionHighlight
        UIContextMenu
        Clipping
        Visible
        ButtonDownFcn
        CreateFcn
        DeleteFcn
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
        function this = PrimitiveScatterPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g3.addProperties('Marker','LineWidth','MarkerEdgeColor','MarkerFaceColor');
            g3.addSubGroup('MarkerEdgeAlpha','MarkerFaceAlpha');
            g3.Expanded = true;
            
            %...............................................................
            
            g7 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g7.addProperties('CData','SizeData');
            g77 = g7.addSubGroup('CDataSource','SizeDataSource');
            g7.Expanded = true;
            
            % there could be multiple objects parented to different types of
            % axes: Cartesian/Polar.
            % Check if the objects share the same dataspace type, if yes, populate the Data/DataSource
            % groups, otherwise leave them empty
            allPolar = numel(findobj(obj,'-property','RData')) == numel(obj);
            allCartesian = numel(findobj(obj,'-property','XData','-and','-not','-property','RData')) == numel(obj);
            
            if allPolar
                this.addPolarProperties(obj);
                g77.addProperties('RData','RDataSource', ...
                    'ThetaData','ThetaDataMode','ThetaDataSource');
            elseif allCartesian
                % Cartesian or empty
                this.addCartesianProperties(obj);
                g77.addProperties('XData','XDataMode','XDataSource','YData','YDataSource','ZData','ZDataSource');
            end
            
            
            %...............................................................
            
            this.createLegendGroup();
            
            %...............................................................
            this.createCommonInspectorGroup();
            
        end
    end
end