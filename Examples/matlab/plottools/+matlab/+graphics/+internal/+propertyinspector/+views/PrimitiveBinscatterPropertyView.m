classdef PrimitiveBinscatterPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.Binscatter property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Annotation
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        CreateFcn
        DeleteFcn
        DisplayName
        FaceAlpha
        HandleVisibility
        HitTest
        Interruptible
        NumBins
        NumBinsMode
        Parent
        PickableParts
        Selected
        SelectionHighlight
        ShowEmptyBins
        Tag
        Type
        UIContextMenu
        UserData
        Values
        Visible
        XBinEdges
        XData
        XLimits
        XLimitsMode
        YBinEdges
        YData
        YLimits
        YLimitsMode
    end
    
    methods
        function this = PrimitiveBinscatterPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Bins')),'','');
            g1.addProperties('NumBins',...
                'NumBinsMode','ShowEmptyBins');
            g1.addSubGroup('XBinEdges',...
                'YBinEdges',...
                'XLimits',...
                'XLimitsMode',...
                'YLimits',...
                'YLimitsMode');
            
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g2.addProperties('XData','YData','Values');
            g2.Expanded = true;
            
            %...............................................................
            
            g5 = this.createGroup(getString(message('MATLAB:propertyinspector:Transparency')),'','');
            g5.addProperties('FaceAlpha');
            
            %...............................................................
            
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end