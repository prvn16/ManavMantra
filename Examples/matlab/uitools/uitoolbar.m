%UITOOLBAR Create a toolbar in a figure window.
%   UITOOLBAR creates an empty toolbar with default property values in the
%   current figure window and returns a handle to it.
%
%   UITOOLBAR('PropertyName1', value1, 'PropertyName2', value2,...)
%   creates an empty toolbar with the specified properties in the current
%   figure window and returns a handle to it.
%
%   UITOOLBAR(FIG, ...) creates an empty toolbar in the specified figure.
%
%   H = UITOOLBAR(...) creates an empty toolbar and assigns the handle to H.
%
%   UITOOLBAR properties can be set at object creation time using the
%   PropertyName/PropertyValue pair arguments to UITOOLBAR, or changed
%   later using the SET command.
%
%   Execute GET(H) to see a list of UITOOLBAR object properties and their
%   current values. Execute SET(H) to see a list of UITOOLBAR object
%   properties and legal property values. See the reference guide for more
%   information.
%
%   Example:
%       h=figure('ToolBar','none')
%       ht=uitoolbar(h)
%
%   See also GET, SET, UIPUSHTOOL, UITOGGLETOOL, UIMENU, FIGURE.

%   Copyright 1984-2006 The MathWorks, Inc. 
%   Date: 2006/03/10 01:54:04 $
%   Built-in function.
