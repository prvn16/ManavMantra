classdef showcaseMPCDesigner < handle
    % Demonstrate how to build toolstrip hierarchy for the MPC Designer app
    % using ToolGroup host container (not a fully-functioning app).
    %
    % Example:
    %   Run "matlab.ui.internal.desktop.showcaseMPCDesigner()"

    % Author(s): R. Chen
    % Copyright 2015 The MathWorks, Inc.

    properties (Transient = true)
        ToolGroup
        Dialog
        Figure1
        Figure2
    end

    methods
        
        function this = showcaseMPCDesigner(varargin)    
            % create tool group
            this.ToolGroup = matlab.ui.internal.desktop.ToolGroup('MPC Designer','mpcapp');
            addlistener(this.ToolGroup, 'GroupAction',@(src, event) closeCallback(this, event));
            % create plot (hg)
            this.Figure1 = figure('NumberTitle', 'off', 'Name', 'Client 1', 'Visible', 'off');
            plot(gca(this.Figure1), cumsum(rand(100,1)-0.5));
            this.Figure2 = figure('NumberTitle', 'off', 'Name', 'Client 2', 'Visible', 'off');
            plot(gca(this.Figure2), cumsum(rand(100,1)-0.5));
            % create tab group (new mcos api)
            tabgroup = matlab.ui.internal.desktop.showcaseBuildTabGroupMPCDesigner(this);
            % add tab group to toolstrip (via tool group api)
            this.ToolGroup.addTabGroup(tabgroup);
            % select current tab (via tool group api)
            this.ToolGroup.SelectedTab = 'tabHome';
            % render app
            this.ToolGroup.setPosition(100,100,1080,720);
            this.ToolGroup.open;
            % add plot as a document
            this.ToolGroup.addFigure(this.Figure1);
            this.ToolGroup.addFigure(this.Figure2);
            this.Figure1.Visible = 'on';
            this.Figure2.Visible = 'on';
            % add callback to drop event in figure 1
            h = getFiguresDropTargetHandler(this.ToolGroup);            
            addlistener(h, 'VariablesBeingDropped', @(x,y) disp(y.Variables));            
            % unregister drop lister of figure 2
            h.unregisterInterest(this.Figure2);
            
			% left-to-right document layout
			MD = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
			MD.setDocumentArrangement(this.ToolGroup.Name, MD.TILED, java.awt.Dimension(2,1));        

            % create browsers
            jdb = javaObjectEDT('com.mathworks.toolbox.shared.controllib.databrowser.TCDataBrowser');
            addWorkspace(jdb, 'Plant', {'plant1';'plant2';'plant3'});
            addWorkspace(jdb, 'Controller', {'controller1';'controller2';'controller3'});
            addWorkspace(jdb, 'Scenario', {'scenario1';'scenario2';'scenario3'});
            this.ToolGroup.setDataBrowser(jdb.getPanel());
            % store java toolgroup so that app will stay in memory
            internal.setJavaCustomData(this.ToolGroup.Peer,this);
            % must create tear off dialog after toolgroup is rendered for
            % correct parenting 
            this.Dialog = createDialog();
        end
        
        function delete(this)
            if ~isempty(this.ToolGroup) && isvalid(this.ToolGroup)
                delete(this.ToolGroup);
            end
            if ~isempty(this.Dialog) && isvalid(this.Dialog)
                delete(this.Dialog);
            end
            if ~isempty(this.Figure1) && isvalid(this.Figure1)
                delete(this.Figure1);           
            end
            if ~isempty(this.Figure2) && isvalid(this.Figure2)
                delete(this.Figure2);           
            end
        end
        
        function closeCallback(this, event)
            ET = event.EventData.EventType;
            if strcmp(ET, 'CLOSED')
                delete(this);
            end
        end            
        
    end
    
end

function addWorkspace(jdb, name, data)
    TableModel = javaObjectEDT('com.mathworks.toolbox.control.tableclasses.AttributiveCellTableModel',data,{name});
    EditableColumns = javaArray('java.lang.Boolean',1);
    EditableColumns(1) = java.lang.Boolean.FALSE;    
    TableModel.Editablecolumns = EditableColumns;
    Table = javaObjectEDT('com.mathworks.mwswing.MJTable');
    Table.setModel(TableModel);
    Table.setFillsViewportHeight(true);
    ScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',Table);
    ScrollPane.setHorizontalScrollBarPolicy(javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
    ScrollPane.setVerticalScrollBarPolicy(com.mathworks.mwswing.MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
    renderer = javaObjectEDT('javax.swing.table.DefaultTableCellRenderer');
    renderer.setPreferredSize(java.awt.Dimension(0, 0));
    Table.getTableHeader().setDefaultRenderer(renderer);
    Table.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
    Table.setShowGrid(false);
    Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
    Panel.setLayout(java.awt.BorderLayout());
    Panel.add(ScrollPane, java.awt.BorderLayout.CENTER);
    jdb.addPanel(['Panel_' name],name,Panel);
end

function dlg = createDialog()
    % create a tear off dialog with old mcos api
    panel = toolpack.component.TSPanel('2dlu,p,2dlu','2dlu,p,2dlu,p,2dlu,p,2dlu,p,2dlu');
    label = toolpack.component.TSLabel('1234567890');
    panel.add(label,'xy(2,2)');
    textfield = toolpack.component.TSTextField('Enter a number');
    panel.add(textfield,'xy(2,4)');
    radio = toolpack.component.TSRadioButton('Select or unselect an option');
    panel.add(radio,'xy(2,6)');
    checkbox = javaObjectEDT('com.mathworks.mwswing.MJCheckBox','Highlight lines');
    cc = com.jgoodies.forms.layout.CellConstraints();
    panel.Peer.add(checkbox,cc.xy(2,8));
    dlg = toolpack.component.TSTearOffPopup(); 
    dlg.Name = 'dialog'; 
    dlg.Title = 'Dialog'; 
    dlg.Floating = true;
    dlg.Panel = panel;
end

