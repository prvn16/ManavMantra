function varargout = xlim(varargin)
%XLIM Set or query x-axis limits
%   XLIM(limits) specifies the x-axis limits for the current axes. Specify
%   limits as a two-element vector of the form [xmin xmax], where xmax is a
%   numeric value greater than xmin.
%   
%   xl = XLIM returns a two-element vector containing the x-axis limits for
%   the current axes.
%   
%   XLIM('auto') lets the axes choose the x-axis limits. This command sets
%   the XLimMode property for the axes to 'auto'.
%   
%   XLIM('manual') freezes the x-axis limits at the current values. Use
%   this option if you want to retain the current limits when adding new
%   data to the axes using the hold on command. This command sets the
%   XLimMode property for the axes to 'manual'.
%   
%   m = XLIM('mode') returns the current value of the x-axis limits mode,
%   which is either 'auto' or 'manual'. By default, the mode is automatic
%   unless you specify limits or set the mode to manual.
%   
%   ___ = XLIM(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   XLIM sets or gets the XLim or XLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, YLIM, ZLIM, THETALIM, RLIM.

%   Copyright 1984-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
