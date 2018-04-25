function varargout = ylim(varargin)
%YLIM Set or query y-axis limits
%   YLIM(limits) specifies the y-axis limits for the current axes. Specify
%   limits as a two-element vector of the form [ymin ymax], where ymax is a
%   numeric value greater than ymin.
%   
%   yl = YLIM returns a two-element vector containing the y-axis limits for
%   the current axes.
%   
%   YLIM('auto') lets the axes choose the y-axis limits. This command sets
%   the YLimMode property for the axes to 'auto'.
%   
%   YLIM('manual') freezes the y-axis limits at the current values. Use
%   this option if you want to retain the current limits when adding new
%   data to the axes using the hold on command. This command sets the
%   YLimMode property for the axes to 'manual'.
%   
%   m = YLIM('mode') returns the current value of the y-axis limits mode,
%   which is either 'auto' or 'manual'. By default, the mode is automatic
%   unless you specify limits or set the mode to manual.
%   
%   ___ = YLIM(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   YLIM sets or gets the YLim or YLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, XLIM, ZLIM, THETALIM, RLIM.

%   Copyright 1984-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
