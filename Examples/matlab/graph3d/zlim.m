function varargout = zlim(varargin)
%ZLIM Set or query z-axis limits
%   ZLIM(limits) specifies the z-axis limits for the current axes. Specify
%   limits as a two-element vector of the form [zmin zmax], where zmax is a
%   numeric value greater than zmin.
%   
%   zl = ZLIM returns a two-element vector containing the z-axis limits for
%   the current axes.
%   
%   ZLIM('auto') lets the axes choose the z-axis limits. This command sets
%   the ZLimMode property for the axes to 'auto'.
%   
%   ZLIM('manual') freezes the z-axis limits at the current values. Use
%   this option if you want to retain the current limits when adding new
%   data to the axes using the hold on command. This command sets the
%   ZLimMode property for the axes to 'manual'.
%   
%   m = ZLIM('mode') returns the current value of the z-axis limits mode,
%   which is either 'auto' or 'manual'. By default, the mode is automatic
%   unless you specify limits or set the mode to manual.
%   
%   ___ = ZLIM(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   ZLIM sets or gets the ZLim or ZLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, XLIM, YLIM, THETALIM, RLIM.

%   Copyright 1984-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
