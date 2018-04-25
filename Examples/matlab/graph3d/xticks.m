function varargout = xticks(varargin)
%XTICKS Set or query x-axis tick values
%   XTICKS(ticks) specifies the values for the tick marks along the x-axis
%   of the current axes. Specify ticks as a vector of increasing values,
%   for example, [0 2 4 6].
%   
%   xt = XTICKS returns a vector containing the x-axis tick values for the
%   current axes.
%   
%   XTICKS('auto') lets the axes choose the x-axis tick values. Use this
%   option if you change the tick values and then want to set them back to
%   the default values. This command sets the XTickMode property for the
%   axes to 'auto'.
%   
%   XTICKS('manual') freezes the x-axis tick values at the current values.
%   Use this option if you want to retain the current tick values when
%   resizing the axes or adding new data to the axes. This command sets the
%   XTickMode property for the axes to 'manual'.
%   
%   m = XTICKS('mode') returns the current value of the mode, which is
%   either 'auto' or 'manual'. By default, the mode is automatic unless you
%   specify tick values or set the mode to manual.
%   
%   ___ = XTICKS(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   XTICKS sets or gets the XTick or XTickMode property of an axes.
%
%   See also XTICKLABELS, YTICKS, ZTICKS, THETATICKS, RTICKS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
