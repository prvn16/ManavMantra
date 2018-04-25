function [out] = uigettoolbar(fig,id)
%UIGETTOOLBAR Obsolete function.
%   UIGETTOOLBAR  may be removed in a future version.

%UIGETTOOLBAR Gets the figure's toolbar(s).
% C = UIGETTOOLBAR(H,'GroupName.ComponentName')
%     H is a figure or toolbar handle
%     'GroupName' is the name of the toolbar group
%     'ComponentName' is the name of the toolbar component
%     C is a toolbar component
%
%  Enter UITOOLBARFACTORY with no arguments to see a full listing
%  of possible Groups and Components.
%
% Example:
%
% h = figure;
% c = uigettoolbar(h,'Exploration.ZoomIn');
%
% See also UITOOLBARFACTORY

% Copyright 2002-2008 The MathWorks, Inc.

obsolete = true;

% Note: All code here must have fast performance
% since this function will be used in callbacks.
htoolbar = findall(fig,'type','uitoolbar');
out = findall(htoolbar,'Tag',id);
