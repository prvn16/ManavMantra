classdef FigurePropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the figure's property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        GraphicsSmoothing,
        NextPlot,
        Renderer,
        RendererMode,
        DockControls,
        MenuBar,
        ToolBar,
        WindowStyle,
        ButtonDownFcn,
        CloseRequestFcn,
        CreateFcn,
        DeleteFcn,
        KeyPressFcn,
        KeyReleaseFcn,
        ResizeFcn,
        SizeChangedFcn,
        WindowButtonDownFcn,
        WindowButtonMotionFcn,
        WindowButtonUpFcn,
        WindowKeyPressFcn,
        WindowKeyReleaseFcn,
        WindowScrollWheelFcn,
        WindowState,
        Children,
        HandleVisibility,
        Parent,
        Visible,
        BeingDeleted,
        BusyAction,
        CurrentAxes,
        CurrentCharacter,
        CurrentObject,
        CurrentPoint,
        HitTest,
        Interruptible,
        Selected,
        SelectionHighlight,
        SelectionType,
        UIContextMenu,
        Clipping,
        InnerPosition,
        OuterPosition,
        Position,
        Resize,
        Units,
        Pointer,
        PointerShapeCData,
        PointerShapeHotSpot,
        InvertHardcopy,
        PaperOrientation,
        PaperPosition,
        PaperPositionMode,
        PaperSize,
        PaperType,
        PaperUnits,
        Name,
        Number,
        NumberTitle,
        IntegerHandle,
        Tag,
        Type,
        UserData,
        FileName,
        Alphamap,
        Color,
        Colormap
    end
    
    methods
        function this = FigurePropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            %...............................................................
            
            g13 = this.createGroup('MATLAB:propertyinspector:WindowAppearance','','');
            g13.addProperties('MenuBar','ToolBar');
            g13.addSubGroup('DockControls','Color','WindowStyle','WindowState');
            g13.Expanded = true;
            
            %...............................................................
            
            g10 = this.createGroup('MATLAB:propertyinspector:Position','','');
            g10.addEditorGroup('Position');
            g10.addProperties('Units');
            
            g13 = g10.addSubGroup();
            g13.addEditorGroup('InnerPosition');
            g13.addEditorGroup('OuterPosition');
            g13.addProperties('Clipping',...
                'Resize');
            
            g10.Expanded = true;
            %...............................................................
            
            g2 = this.createGroup('MATLAB:propertyinspector:Plotting','','');
            g2.addProperties('Colormap','Alphamap','NextPlot','Renderer','RendererMode','GraphicsSmoothing');
            
            %...............................................................
                                
            g12 = this.createGroup('MATLAB:propertyinspector:PrintingandExporting','','');
            
            g12.addEditorGroup('PaperPosition');
            g12.addProperties('PaperPositionMode');
            g12.addEditorGroup('PaperSize');
            
            g12.addProperties('PaperUnits','PaperOrientation','PaperType','InvertHardcopy');                               
            %...............................................................                                     
            
            g11 = this.createGroup('MATLAB:propertyinspector:MousePointer','','');
            g11.addProperties('Pointer','PointerShapeCData','PointerShapeHotSpot');
            
             %...............................................................                                
                   
            g8 = this.createGroup('MATLAB:propertyinspector:Interactivity','','');
            g8.addProperties('CurrentAxes','CurrentObject');
            g8.addEditorGroup('CurrentPoint');
            g8.addProperties('CurrentCharacter','Selected',...
                'SelectionHighlight','SelectionType','UIContextMenu',...
                'Visible');
            
            %...............................................................             
             
            
            g3 = this.createGroup('MATLAB:propertyinspector:CommonCallbacks','','');
            g3.addProperties('ButtonDownFcn','CreateFcn','DeleteFcn');
            
            %...............................................................
            
            g4 = this.createGroup('MATLAB:propertyinspector:KeyboardCallbacks','','');
            g4.addProperties('KeyPressFcn','KeyReleaseFcn');
            
            %...............................................................
            
            g5 = this.createGroup('MATLAB:propertyinspector:WindowCallbacks','','');
            g5.addProperties('CloseRequestFcn','SizeChangedFcn','WindowButtonDownFcn',...
                'WindowButtonMotionFcn','WindowButtonUpFcn',...
                'WindowKeyPressFcn','WindowKeyReleaseFcn',...
                'WindowScrollWheelFcn','ResizeFcn');
            
            %...............................................................
            g9 = this.createGroup('MATLAB:propertyinspector:CallbackExecutionControl','','');
            g9.addProperties('Interruptible','BusyAction','HitTest','BeingDeleted');
            %...............................................................
            
            g6 = this.createGroup('MATLAB:propertyinspector:ParentChild','','');
            g6.addProperties('Parent','Children','HandleVisibility');
            
            %...............................................................
            
            g1 = this.createGroup('MATLAB:propertyinspector:Identifiers','','');
            g1.addProperties('Name','Number','NumberTitle','IntegerHandle','FileName','Type','Tag','UserData');            
        end
    end
end