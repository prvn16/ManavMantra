function varargout = rlim(varargin)
%RLIM Set or query r-axis limits for polar axes
%   RLIM(limits) specifies the r-axis limits for the current polar axes.
%   Specify limits as a two-element vector of the form [rmin rmax], where
%   rmax is a numeric value greater than rmin.
%   
%   rl = RLIM returns a two-element vector containing the r-axis limits for
%   the current polar axes.
%   
%   RLIM('auto') lets the polar axes choose the r-axis limits. This command
%   sets the RLimMode property for the polar axes to 'auto'.
%   
%   RLIM('manual') freezes the r-axis limits at the current values. Use
%   this option if you want to retain the current limits when adding new
%   data to the axes using the hold on command. This command sets the
%   RLimMode property for the polar axes to 'manual'.
%   
%   m = RLIM('mode') returns the current value of the r-axis limits mode,
%   which is either 'auto' or 'manual'. By default, the mode is automatic
%   unless you specify limits or set the mode to manual.
%   
%   ___ = RLIM(ax, ___ ) uses the polar axes specified by ax instead of the
%   current axes.
%
%   RLIM sets or gets the RLim or RLimMode property of an axes.
%
%   See also POLARAXES, XLIM, YLIM, ZLIM, THETALIM.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
