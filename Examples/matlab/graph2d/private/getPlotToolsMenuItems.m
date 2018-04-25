function h = getPlotToolsMenuItems(fig)
%GETPLOTTOOLSMENUITEMS    Returns the Plot Tools related menu items.
%   Returns the Plot Tools related menu items from the various menus 
%   present in the figure.

%   Copyright 2010 The MathWorks, Inc.

hviewmenu = findall(allchild(fig), 'flat','Type','uimenu', 'Tag', 'figMenuView');
h = [findall(hviewmenu, 'Tag', 'figMenuFigurePalette'); ...
    findall(hviewmenu, 'Tag', 'figMenuPlotBrowser'); ...
    findall(hviewmenu, 'Tag', 'figMenuPropertyEditor')];
