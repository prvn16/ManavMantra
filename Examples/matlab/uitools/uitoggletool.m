%UITOGGLETOOL Create a togglebutton in the toolbar of a figure window.
%   UITOGGLETOOL creates a togglebutton control in the last added toolbar
%   of the current figure window and returns a handle to it.
%
%   UITOGGLETOOL('PropertyName1', value1, 'PropertyName2', value2,...)
%   creates a togglebutton control with the specified properties in the
%   toolbar and returns a handle to it.
%
%   UITOGGLETOOL(TBAR, ...) creates a togglebutton control in the specified
%   toolbar.
%
%   H = UITOGGLETOOL(...) creates a togglebutton control and assigns a
%   handle to H.
%
%   UITOGGLETOOL properties can be set at object creation time using the
%   PropertyName/PropertyValue pair arguments to UITOGGLETOOL, or changed
%   later using the SET command.
%
%   Execute GET(H) to see a list of UITOGGLETOOL object properties and their
%   current values. Execute SET(H) to see a list of UITOGGLETOOL object
%   properties and legal property values. See the reference guide for more
%   information.
%
%   Example:
%       This example creates a uitoolbar object and places a uitoggletool 
%       object on it. 
%         
%        h = figure('ToolBar','none');
%        ht = uitoolbar(h);
%        a = rand(20,20,3);
%        htt = uitoggletool(ht,'CData',a,'TooltipString','Hello');
%
%   See also GET, SET, UIPUSHTOOL, UITOOLBAR, UIMENU, FIGURE.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   Date: 2008/08/14 01:38:21 $
%   Built-in function.
