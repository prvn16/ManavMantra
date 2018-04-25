function fhandle = uiflowcontainer(varargin)
% This function is undocumented and will change in a future release
  
%UIFLOWCONTAINER   Uiflowcontainer object.
%   UIFLOWCONTAINER adds a flow container object to the current figure.  If
%   no figure exits, one will be created. Uiflow objects can have the
%   same child objects as figure, excepting toolbars and menus.  In
%   addition, uiflow objects can have additional instances of uiflow
%   as children. This allows a multiple nested tree of objects rooted
%   at the figure.
%
%   Uiflowcontainers have properties to control child layout in new ways.
%
%   Execute GET(H), where H is a uiflowcontainer handle, to see a list
%   of uiflowcontainer object properties and their current values. Execute
%   SET(H) to see a list of uiflowcontainer object properties and legal
%   property values.
%
%   NOTICE: uiflowcontainer is experimental and interfaces will probably
%           change in future versions of MATLAB.
%   
%   Example:
%       f = figure;
%       h = uiflowcontainer('v0', 'parent',f); drawnow;
%       c1 = uicontrol('string','OK','callback','disp(''OK'')','parent',h);
%       c2 = uicontrol('string','Cancel','callback','disp(''Cancel'')','parent',h);
%       % properties only visible when parent is uiflowcontainer
%       c1.HeightLimits = 20;
%       c2.HeightLimits = 20;
%       c1.WidthLimits = 60;
%       c2.WidthLimits = 60;
%
%   See also UICONTAINER, UIPANEL, UIGRIDCONTAINER.

%   Copyright 1984-2014 The MathWorks, Inc.
%   Built-in function.

% If using the 'v0' switch, use the undocumented uiflowcontainer explicitly.
if (usev0dialog(varargin{:}))
    fhandle = builtin('uiflowcontainer', varargin{2:end});
else
    % Replace this with a call to the documented uiflowcontainer when ready.
    warning(message('MATLAB:uiflowcontainer:MigratingFunction'));
    fhandle = builtin('uiflowcontainer', varargin{:});
end
