function varargout = thetalim(varargin)
%THETALIM Set or query theta-axis limits for polar axes
%   THETALIM(limits) specifies the theta-axis limits for the current polar
%   axes. Specify limits as a two-element vector of the form [thetamin
%   thetamax], where thetamax is a numeric value greater than thetamin.
%   
%   tl = THETALIM returns a two-element vector containing the theta-axis
%   limits for the current polar axes.
%   
%   THETALIM('auto') lets the polar axes choose the theta-axis limits. This
%   command sets the ThetaLimMode property for the polar axes to 'auto'.
%   
%   THETALIM('manual') freezes the theta-axis limits at the current values.
%   Use this option if you want to retain the current limits when adding
%   new data to the axes using the hold on command. This command sets the
%   ThetaLimMode property for the polar axes to 'manual'.
%   
%   m = THETALIM('mode') returns the current value of the theta-axis limits
%   mode, which is either 'auto' or 'manual'. By default, the mode is
%   automatic unless you specify limits or set the mode to manual.
%   
%   ___ = THETALIM(ax, ___ ) uses the polar axes specified by ax instead of
%   the current axes.
%
%   THETALIM sets or gets the ThetaLim or ThetaLimMode property of an axes.
%
%   See also POLARAXES, XLIM, YLIM, ZLIM, RLIM.

%   Copyright 2015-2017 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
