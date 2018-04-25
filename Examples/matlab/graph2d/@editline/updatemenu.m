function A = updatemenu(A)
%EDITLINE/UPDATEMENU  Update context menus for editline objects
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2011 The MathWorks, Inc.

menu = get(A,'UIContextMenu');

% update style selection
lineStyle = get(A,'LineStyle');
% menu children are listed in reverse order!
styles = {...
   '-.',getString(message('MATLAB:uistring:editline:DashDot'))
   ':',getString(message('MATLAB:uistring:editline:Dot'))
   '--',getString(message('MATLAB:uistring:editline:Dash'))
   '-',getString(message('MATLAB:uistring:editline:Solid'))
   };

styleMenu = findall(menu,'Tag','ScribeEditlineObjStyleMenu');
submenus = allchild(styleMenu);
whichStyle = strcmp(lineStyle,styles(:,1));

set(submenus,'Checked','off');
set(submenus(whichStyle),'Checked','on');


% update size selection
lineSize = get(A,'LineWidth');
% menu children are listed in reverse order!
% first entry is a placeholder for the "more" option
sizes = [...
   0
   10
   9
   8
   7
   6
   5
   4
   3
   2
   1
   0.5
   ];

sizeMenu = findall(menu,'Tag','ScribeEditlineObjSizeMenu');
submenus = allchild(sizeMenu);
whichSize = lineSize==sizes;

set(submenus,'Checked','off');
set(submenus(whichSize),'Checked','on');
