function hMenu = createContextMenuItem(varargin)
% Helper function to append additional context menus

%   Copyright 2010 The MathWorks, Inc.

hMenu = uimenu('Parent',varargin{1}, ...
    'Label',varargin{2}, ...
    'Callback',varargin{3:end});
