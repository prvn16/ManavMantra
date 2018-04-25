%UIPUSHTOOL Create a pushbutton in the toolbar of a figure window.
%   UIPUSHTOOL creates a pushbutton control in the last added toolbar
%   of the current figure window and returns a handle to it.
%
%   UIPUSHTOOL('PropertyName1', value1, 'PropertyName2', value2,...)
%   creates a pushbutton control with the specified properties in the
%   toolbar and returns a handle to it.
%
%   UIPUSHTOOL(TBAR, ...) creates a pushbutton control in the specified
%   toolbar.
%
%   H = UIPUSHTOOL(...) creates a pushbutton control and assigns a
%   handle to H.
%
%   UIPUSHTOOL properties can be set at object creation time using the
%   PropertyName/PropertyValue pair arguments to UIPUSHTOOL, or changed
%   later using the SET command.
%
%   Execute GET(H) to see a list of UIPUSHTOOL object properties and their
%   current values. Execute SET(H) to see a list of UIPUSHTOOL object
%   properties and legal property values. See the reference guide for more
%   information.
%
%   Example:
%         h = figure('ToolBar','none')
%         ht = uitoolbar(h)
%         a = [.05:.05:0.95];
%         b(:,:,1) = repmat(a,19,1)';
%         b(:,:,2) = repmat(a,19,1);
%         b(:,:,3) = repmat(flip(a,2),19,1);
%         hpt = uipushtool(ht,'CData',b,'TooltipString','Hello')
% 
%   See also GET, SET, UITOGGLETOOL, UITOOLBAR, UIMENU, FIGURE.

%   Copyright 1984-2006 The MathWorks, Inc. 
%   Date: 2006/03/10 01:53:54 $
%   Built-in function.
