function uicontainer(varargin)
% This function is undocumented and will change in a future release

%UICONTAINER  Uicontainer container object.
%   UICONTAINER adds a uicontainer container object to the current figure.
%   If no figure exists, one will be created. Uicontainer objects can have
%   the same child objects as a figure, excepting toolbars and menus. 
%   In addition, uicontainer objects can have
%   additional instances of uicontainers as children. This allows a multiple 
%   nested tree of objects rooted at the figure.
%
%   Execute GET(H), where H is a uicontainer handle, to see a list of uicontainer
%   object properties and their current values. Execute SET(H) to see a
%   list of uicontainer object properties and legal property values.
%
%   Example:
%       uicontainer('back','red','pos',[.3 .3 100 100]);
%
%   See also UIPANEL, HGTRANSFORM.

%   Copyright 1984-2007 The MathWorks, Inc.
%   Built-in function.
