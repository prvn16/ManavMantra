function varargout = yticks(varargin)
%YTICKS Set or query y-axis tick values
%   YTICKS(ticks) specifies the values for the tick marks along the y-axis
%   of the current axes. Specify ticks as a vector of increasing values,
%   for example, [0 2 4 6].
%   
%   yt = YTICKS returns a vector containing the y-axis tick values for the
%   current axes.
%   
%   YTICKS('auto') lets the axes choose the y-axis tick values. Use this
%   option if you change the tick values and then want to set them back to
%   the default values. This command sets the YTickMode property for the
%   axes to 'auto'.
%   
%   YTICKS('manual') freezes the y-axis tick values at the current values.
%   Use this option if you want to retain the current tick values when
%   resizing the axes or adding new data to the axes. This command sets the
%   YTickMode property for the axes to 'manual'.
%   
%   m = YTICKS('mode') returns the current value of the mode, which is
%   either 'auto' or 'manual'. By default, the mode is automatic unless you
%   specify tick values or set the mode to manual.
%   
%   ___ = YTICKS(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   YTICKS sets or gets the YTick or YTickMode property of an axes.
%
%   See also YTICKLABELS, XTICKS, ZTICKS, THETATICKS, RTICKS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
