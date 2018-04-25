
classdef HistogramGroupedView < internal.matlab.inspector.InspectorProxyMixin
    
    properties(SetObservable = true)
        Data
        NumBins
        BinEdges
        BinWidth
        BinMethod
        BinLimits
        BinLimitsMode
        Normalization
        FaceColor
        EdgeColor
        DisplayStyle
        Orientation
        FaceAlpha
        Values
        Children
        Parent
        Visible
        HandleVisibility
        DisplayName
        Annotation
        Selected
        SelectionHighlight
        HitTest
        PickableParts
        UIContextMenu
        BusyAction
        BeingDeleted
        Interruptible
        CreateFcn
        DeleteFcn
        ButtonDownFcn
        Type
        Tag
        UserData
    end
    
    methods
        function this = HistogramGroupedView(obj)
            % By calling the superclass constructor, any properties without
            % a get/set method will automatically be directed to the
            % get/set methods of the original object (obj)
            % Properties defined here need to be SetObservable = true
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            histGroup = this.createGroup('HistogramGroup', 'Histogram Type', ...
                'Histogram Type Description');
            histGroup.addProperties('DisplayStyle','Orientation');
            
            binsGroup = this.createGroup('BinsGroup', 'Bins', 'Bins Description');
            binsGroup.addProperties('BinEdges','BinLimits','BinLimitsMode', ...
                'BinMethod','BinWidth','Normalization','NumBins','EdgeColor', ...
                'FaceColor','FaceAlpha');
            
            dataGroup = this.createGroup('DataGroup', 'Data', 'Data Description');
            dataGroup.addProperties('Data','Values');
            
            identifiersGroup = this.createGroup('IdentifiersGroup', 'Identifiers', ...
                'Identifiers Group Description');
            identifiersGroup.addProperties('Type','Tag','UserData','DisplayName', ...
                'Annotation');
            
            visibilityGroup = this.createGroup('VisibilityGroup', 'Visibility', ...
                'Visibility Group Description');
            visibilityGroup.addProperties('Visible');
            
            handleVisibilityGroup = this.createGroup('HandleVisibilityGroup', ...
                'Handle Visibility', 'Visibility Description');
            handleVisibilityGroup.addProperties('Parent','Children', ...
                'HandleVisibility');
            
            interactiveGroup = this.createGroup('InteractiveGroup',  ...
                'Interactive Control', 'Interactive Group Description');
            interactiveGroup.addProperties('ButtonDownFcn','UIContextMenu', ...
                'Selected', 'SelectionHighlight');
            
            callbackGroup = this.createGroup('CallbackGroup',  ...
                'Callback Execution Control', 'Callback Group Description');
            callbackGroup.addProperties('PickableParts','HitTest','HitTestArea', ...
                'Interruptible', 'BusyAction');
            
            functionGroup = this.createGroup('FunctionGroup',  ...
                'Creation and Deletion Control', 'Function Group Description');
            functionGroup.addProperties('CreateFcn','DeleteFcn','BeingDeleted');
        end
    end
end
