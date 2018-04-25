classdef PrimitiveLightPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.primitive.Light property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        Color
        CreateFcn
        DeleteFcn
        HandleVisibility
        HitTest
        Interruptible
        Parent
        PickableParts
        Position
        Selected
        SelectionHighlight
        Style
        Tag
        Type
        UIContextMenu
        UserData
        Visible      
    end
    
    methods
        function this = PrimitiveLightPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('Color','Style','Position');
            g1.Expanded = true;
            
            %...............................................................
           
            this.createCommonInspectorGroup();
        end
    end
end