function varargout = zticks(varargin)
%ZTICKS Set or query z-axis tick values
%   ZTICKS(ticks) specifies the values for the tick marks along the z-axis
%   of the current axes. Specify ticks as a vector of increasing values,
%   for example, [0 2 4 6].
%   
%   zt = ZTICKS returns a vector containing the z-axis tick values for the
%   current axes.
%   
%   ZTICKS('auto') lets the axes choose the z-axis tick values. Use this
%   option if you change the tick values and then want to set them back to
%   the default values. This command sets the ZTickMode property for the
%   axes to 'auto'.
%   
%   ZTICKS('manual') freezes the z-axis tick values at the current values.
%   Use this option if you want to retain the current tick values when
%   resizing the axes or adding new data to the axes. This command sets the
%   ZTickMode property for the axes to 'manual'.
%   
%   m = ZTICKS('mode') returns the current value of the mode, which is
%   either 'auto' or 'manual'. By default, the mode is automatic unless you
%   specify tick values or set the mode to manual.
%   
%   ___ = ZTICKS(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   ZTICKS sets or gets the ZTick or ZTickMode property of an axes.
%
%   See also ZTICKLABELS, XTICKS, YTICKS, THETATICKS, RTICKS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
