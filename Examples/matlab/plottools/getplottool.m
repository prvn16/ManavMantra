function comp = getplottool (h, name)
% This undocumented function may be removed in a future release.
  
% GETPLOTTOOL  Utility function for creating and obtaining the
% figure tools used for plot editing.
%
% c = GETPLOTTOOL (h, 'figurepalette') returns the Java figure palette.
% c = GETPLOTTOOL (h, 'plotbrowser') returns the Java plot browser.
% c = GETPLOTTOOL (h, 'propertyeditor') returns the Java property editor.
%
% In each case, the component is created if it does not already exist, 
% but it isn't shown by default.
% If you want to both create it and show it, use SHOWPLOTTOOL.

% Copyright 2003-2014 The MathWorks, Inc.


% Called by showplottool, which in turn is called by the component-specific
% functions (propertyeditor, plotbrowser, figurepalette).

comp = [];

if ispref('plottools', 'isdesktop')
    rmpref('plottools', 'isdesktop');
end

if isempty(h) || ~ishandle(h) 
    return
end

% Find the correct group name:
jf = javaGetFigureFrame(h);
if ~isempty(jf)
    groupName = jf.getGroupName;
    dt = jf.getDesktop;
else
    groupName = 'Figures';
    dt=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
end

cmd = lower (name);
switch cmd
    case {'propertyeditor', 'property editor'}
       comp =  com.mathworks.page.plottool.PropertyEditor.addAsDesktopClient(...
           dt,groupName);
    case {'plotbrowser', 'plot browser'}
       comp =  com.mathworks.page.plottool.PlotBrowser.addAsDesktopClient(...
           dt,groupName);
    case {'figurepalette', 'figure palette'}
       comp =  com.mathworks.page.plottool.FigurePalette.addAsDesktopClient(...
           dt,groupName);
    case 'selectionmanager'
        if isempty(h) || ~ishandle(h)
            comp = null;
        else
            comp = createOrGetSelectionManager (h);
        end
end

%-------------------------
function selMgr = createOrGetSelectionManager (h)
if isempty (javaGetFigureFrame(h))
    error(message('MATLAB:getplottool:FileNotFound'));
end
if (~isprop (h, 'SelectionManager'))
    localEnablePlotEdit(h);
    selMgr = com.mathworks.page.plottool.SelectionManager.createSelectionManager(java(handle(h)));
    if (isprop (h, 'SelectionManager'))
        % check again; might have run twice in quick succession
        selMgr = get (handle(h), 'SelectionManager');
        return;
    end
    p = addprop(h,'SelectionManager');
    p.Transient = true;
    p.Hidden = true;
    set (handle(h), 'SelectionManager', selMgr);
    drawnow;
else
    selMgr = get (handle(h), 'SelectionManager');
end

%------------------------------------------------------------------------%
function localEnablePlotEdit(hFig)
% Enable plot edit mode only if the plot edit toolbar button is present
% See g327324 

behavePlotEdit = hggetbehavior(hFig,'PlotTools','-peek');
if isempty(behavePlotEdit) || behavePlotEdit.ActivatePlotEditOnOpen
    plotedit(hFig,'on');
end

