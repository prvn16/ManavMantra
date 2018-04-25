%UIPANEL   Uipanel container object.
%   UIPANEL adds a uipanel container object to the current figure. If no
%   figure exists, one will be created. Uipanel objects can have the same
%   child objects as a figure, excepting toolbars and menus. In addition, 
%   uipanel objects can have additional instances of uipanels as children. 
%   This allows a multiple nested tree of objects rooted at the figure.
%
%   Uipanels have properties to control the appearance of borders
%   and titles.
%
%   Execute GET(H), where H is a uipanel handle, to see a list of uipanel
%   object properties and their current values. Execute SET(H) to see a
%   list of uipanel object properties and legal property values.
%
%   Example:
%       h = figure;
%       hp = uipanel('Title','Main Panel','FontSize',12,...
%               'BackgroundColor','white',...
%               'Position',[.25 .1 .67 .67]);
%       hsp = uipanel('Parent',hp,'Title','Subpanel','FontSize',12,...
%               'Position',[.4 .1 .5 .5]);
%       hbsp = uicontrol('Parent',hsp,'String','Push here',...
%               'Position',[18 18 72 36]);
%
%   See also UITAB, UITABGROUP.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Built-in function.
