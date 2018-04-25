classdef PrimitiveHistogramPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the histogram property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties        
        Annotation
        BeingDeleted
        BinCounts
        BinCountsMode
        BinEdges
        BinLimits
        BinLimitsMode
        BinMethod
        BinWidth
        BusyAction
        ButtonDownFcn
        Children
        CreateFcn
        Data
        DeleteFcn
        DisplayName
        DisplayStyle
        EdgeAlpha
        EdgeColor
        FaceAlpha
        FaceColor
        HandleVisibility
        HitTest
        Interruptible
        LineStyle
        LineWidth
        Normalization
        NumBins
        Orientation
        Parent
        PickableParts
        Selected
        SelectionHighlight
        Tag
        Type
        UIContextMenu
        UserData
        Values
        Visible        
    end
    
    methods
        function this = PrimitiveHistogramPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Bins')),'','');
            g1.addProperties('NumBins','BinWidth','BinEdges');
            
            g1.addSubGroup('BinLimits',...               
                'BinLimitsMode',...
                'BinMethod');
            
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g2.addProperties('Data','Values','Normalization');
            g2.addSubGroup('BinCounts',...
                'BinCountsMode');
            g2.Expanded = true;
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g3.addProperties('DisplayStyle',...
                'Orientation',...
                'FaceColor');
            
            g3.addSubGroup('EdgeColor','FaceAlpha',... 
                'EdgeAlpha',...
                'LineStyle',...
                'LineWidth');
            g3.Expanded = true;
            
            %...............................................................
            
            
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end