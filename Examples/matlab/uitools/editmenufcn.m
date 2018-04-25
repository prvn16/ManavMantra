function editmenufcn(hfig, cmd)
% This function is undocumented and will change in a future release

%EDITMENUFCN Implements part of the figure edit menu.
%  EDITMENUFCN(CMD) invokes edit menu command CMD on figure GCBF.
%  EDITMENUFCN(H, CMD) invokes edit menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    EditUndo
%    EditCut
%    EditCopy
%    EditPaste
%    EditClear
%    EditDelete
%    EditSelectAll
%    EditPinning
%    EditCopyOptions
%    EditCopyFigure
%    EditFigureProperties
%    EditAxesProperties
%    EditObjectProperties
%    EditColormap

%    EditPost - internal use only

%  Copyright 1984-2015 The MathWorks, Inc.

narginchk(1,2)

if nargin > 1
    cmd = convertStringsToChars(cmd);
end

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

switch cmd
    case 'EditPost'
        localPost(hfig);
    case 'EditUndo'
        % Do Nothing. This menu will be enabled when the plotedit undo context is setup.
    case 'EditCut'
        plotedit(hfig,'Cut');
    case 'EditCopy'
        if isactiveuimode(hfig,'Standard.EditPlot')
            plotedit(hfig,'Copy');
        elseif isactiveuimode(hfig,'Exploration.Brushing')
            if datamanager.isFigureLinked(hfig)
                com.mathworks.page.datamgr.linkedplots.LinkPlotPanel.fireFigureCallback(...
                    java(handle(hfig)),'datamanager.copySelection',{[]});
            else
                datamanager.copySelection(hfig,[]);
            end
        end 
    case 'EditPaste'
        plotedit(hfig,'Paste');
    case 'EditClear'
        plotedit(hfig,'Clear');
    case 'EditDelete'
        plotedit(hfig,'Delete');
    case 'EditSelectAll'
        plotedit(hfig,'SelectAll');
    case 'EditCopyOptions'
        preferences(getString(message('MATLAB:uistring:editmenufcn:FigureCopyTemplateCopyOptions')))
    case 'EditCopyFigure'
        matlab.graphics.internal.copyFigureHelper(hfig)       
    case 'EditFigureProperties'
        % domymenu menubar figureprop
        propedit(hfig);
    case 'EditAxesProperties'
        % domymenu menubar axesprop
        ax = get(hfig,'CurrentAxes');
        if ~isempty(ax)
           propedit(ax);
        end
    case 'EditObjectProperties'
        obj = get(hfig,'CurrentObject');
        if isempty(obj) || ~ishghandle(obj)
            obj = hfig;
        end
        propedit(obj);
    case 'EditColormap'
        cmapObj = get(hfig,'CurrentAxes');
        if isempty(cmapObj)
            cmapObj = hfig;
        end
        colormapeditor(cmapObj);
    case 'EditFindFiles'
        com.mathworks.mde.find.FindFilesLauncher.launch;
    case 'EditClearFigure'
        clf(hfig);
    case 'EditClearCommandWindow'
        clc;
    case 'EditClearCommandHistory'
        localEditClearCommandHistory(hfig);     
    case 'EditClearWorkspace'
        localEditClearWorkspace(hfig);    
end

% --------------------------------------------------------------------
function  [jframe] = localGetJavaFrame(hfig)
% Get java frame for figure window

jframe = [];

% store the last warning thrown
[ lastWarnMsg, lastWarnId ] = lastwarn;

% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jpeer = get(hfig,'JavaFrame');
warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);

if ~isempty(jpeer)
   jcanvas = jpeer.getAxisComponent; 
   jframe = javax.swing.SwingUtilities.getWindowAncestor(jcanvas);
end

%--------------------------------------------------------%
function localEditClearWorkspace(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getClearWorkspaceAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

%--------------------------------------------------------%
function localEditClearCommandHistory(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getClearHistoryAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

%--------------------------------------------------------%
function localPost(hfig)

% The first time the EditPost callback is called, hide any
% non-functional items on Unix.
% Also, if necessary, enable or disable any items on the editmenu
% based on their context.
        
edit = findall(allchild(hfig),'type','uimenu','Tag','figMenuEdit');

if ~ispc
     % We want to show the Copy Figure menu only if java figures is on by
     % default on the Mac.
    if (ismac && (usejava('awt') == 1))
        set(findall(edit,'Tag','figMenuEditCopyFigure'),'Visible','on');
    else
        set(findall(edit,'Tag','figMenuEditCopyFigure'),'Visible','off');
    end

    set(findall(edit,'Tag','figMenuEditCopyOptions'),'Visible','off');
    set(findall(edit,'Tag','figMenuEditCut'),'Separator','off');
    % hide non-functional unix items
end
        
if ~usejava('mwt')
    %There are no r11 property editors for figure and most axes children,
    %so disable the figure and current object edit options on the figure
    %menu
    set(findall(edit,'Tag','figMenuEditGCA'),'Separator','on');
    set(findall(edit,'Tag','figMenuEditGCO'),'Visible','off');
end
        
% Hide callbacks that require a java frame
if usejava('awt') ~= 1
    set(findall(edit,'Tag','figMenuEditClearCmdWindow'),'Visible','off');
    set(findall(edit,'Tag','figMenuEditClearCmdHistory'),'Visible','off');      
    set(findall(edit,'Tag','figMenuEditClearWorkspace'),'Visible','off');   
end

plotedit({'update_edit_menu',hfig,false}); 

% Customize the enabled state of the Copy and Delete menus in Data Brushing
% mode
if isactiveuimode(hfig,'Exploration.Brushing')
    datamanager.postEdit(hfig);
end

% self-contained Charts don't support colormap editor
cmapObj = get(hfig,'CurrentAxes');
if isa(cmapObj,'matlab.graphics.chart.Chart')
    set(findall(edit,'Tag','figMenuEditColormap'),'Visible','off');
else
    set(findall(edit,'Tag','figMenuEditColormap'),'Visible','on');    
end
        
drawnow;


