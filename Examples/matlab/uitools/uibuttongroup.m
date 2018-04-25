function h = uibuttongroup(varargin)
% UIBUTTONGROUP Component to exclusively manage radiobuttons/togglebuttons.
%
%   UIBUTTONGROUP('PropertyName1, Value1, 'PropertyName2', Value2, ...)
%   creates a visible group component in the current figure window. This
%   component is capable of managing exclusive selection behavior for
%   uicontrols of style 'Radiobutton' and 'Togglebutton'. Other styles of
%   uicontrols may be added to the UIBUTTONGROUP, but they will not be
%   managed by the component.
%
%   HANDLE = UIBUTTONGROUP(...)
%   creates a group component and returns a handle to it in HANDLE.
%
%   Run GET(HANDLE) to see a list of properties and their current values.
%   Execute SET(HANDLE) to see a list of object properties and their legal
%   values. See the reference guide for detailed property information.
%
%   Examples:
%       h = uibuttongroup('visible','off','Position',[0 0 .2 1]);
%       u0 = uicontrol('Style','Radio','String','Option 1',...
%            'pos',[10 350 100 30],'parent',h,'HandleVisibility','off');
%       u1 = uicontrol('Style','Radio','String','Option 2',...
%            'pos',[10 250 100 30],'parent',h,'HandleVisibility','off');
%       u2 = uicontrol('Style','Radio','String','Option 3',...
%            'pos',[10 150 100 30],'parent',h,'HandleVisibility','off');
%       h.SelectionChangeFcn = 'disp selectionChanged';
%       h.SelectedObject = [];  % No selection
%       h.Visible = 'on';
%
%   See also UICONTROL, UIPANEL

%   Copyright 2003-2015 The MathWorks, Inc.

h = usev0buttongroup(varargin{:});

end
