classdef PanelPropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on uipanel property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        BackgroundColor
        BeingDeleted
        BorderType
        BorderWidth
        BusyAction
        ButtonDownFcn
        Children
        Clipping
        CreateFcn
        DeleteFcn
        FontAngle
        FontName
        FontSize
        FontUnits
        FontWeight
        ForegroundColor
        HandleVisibility
        HighlightColor
        InnerPosition
        Interruptible
        OuterPosition
        Parent
        Position
        ShadowColor
        SizeChangedFcn
        Tag
        Title
        TitlePosition
        Type
        UIContextMenu
        Units
        UserData
        Visible        
    end
    
    methods
        function this = PanelPropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            %...............................................................
            
            g1 = this.createGroup('Text','','');
            g1.addProperties('Title','TitlePosition');
            g1.Expanded = 'true';
            
            %...............................................................
           
            
            g4 = this.createGroup('Font','','');
            g4.addProperties('FontName','FontSize');
            g4.addSubGroup('FontWeight','FontAngle','FontUnits');
            g4.Expanded = true;
            
            %.............................................................
            
            
            g3 = this.createGroup('Color and Styling','','');
            g3.addProperties('ForegroundColor',...
                'BackgroundColor');         
            g3.addSubGroup('BorderType','BorderWidth','HighlightColor','ShadowColor');
            g3.Expanded = true;
                                    
   
            %...............................................................
            
            g5 = this.createGroup('Interactivity','','');
            g5.addProperties('Visible','Clipping','UIContextMenu');
            
            %...............................................................
              
              g5 = this.createGroup('Position','','');
              g5.addProperties('Position',...
                  'InnerPosition',....
                  'OuterPosition',...
                  'Units');                          
            %...............................................................
            
            g6 = this.createGroup('Callbacks','','');
            g6.addProperties('CreateFcn','DeleteFcn','ButtonDownFcn',...
                'SizeChangedFcn');
            
            %...............................................................
            
            g7 = this.createGroup('Callback Execution Control','','');
            g7.addProperties('BeingDeleted','BusyAction','HitTest',...
                'PickableParts','Interruptible');
            
            %...............................................................
            
            g8 = this.createGroup('Parent/Child','','');
            g8.addProperties('Children','HandleVisibility','Parent');
            
            %...............................................................
            
            g9 = this.createGroup('Identifiers','','');
            g9.addProperties('Tag','Type','UserData');
        end
    end
end