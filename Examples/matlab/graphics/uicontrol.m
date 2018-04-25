%UICONTROL Create user interface control.
%   UICONTROL('PropertyName1',value1,'PropertyName2',value2,...) 
%   creates a user interface control in the current figure 
%   window and returns a handle to it.
%
%   UICONTROL(FIG,...) creates a user interface control in the
%   specified figure.
%
%   UICONTROL properties can be set at object creation time using
%   PropertyName/PropertyValue pair arguments to UICONTROL, or 
%   changed later using the SET command.
%
%   Execute GET(H) to see a list of UICONTROL object properties and
%   their current values. Execute SET(H) to see a list of UICONTROL
%   object properties and legal property values. See a reference
%   guide for more information.
%
%   Examples:
%      Example 1:
%           %creates uicontrol specified in a new figure
%           uicontrol('Style','edit','String','hello'); 
%     
%      Example 2:
%           %creates three figures and only puts uicontrol in the second figure
%           fig1 = figure;
%           fig2 = figure;
%           fig3 = figure;
%           uicontrol('Parent', fig2, 'Style', 'edit','String','hello');
%
%   See also SET, GET, UIMENU.

%   Copyright 1984-2006 The MathWorks, Inc. 
%   Built-in function.
