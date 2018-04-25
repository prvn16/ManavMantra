function varargout = rticks(varargin)
%RTICKS Set or query r-axis tick values for polar axes
%   RTICKS(ticks) specifies the values for the tick marks along the r-axis
%   of the current polar axes. Specify ticks as a vector of increasing
%   values, for example, [0 2 4 6].
%   
%   rt = RTICKS returns a vector containing the r-axis tick values for the
%   current polar axes.
%   
%   RTICKS('auto') lets the polar axes choose the r-axis tick values. Use
%   this option if you change the tick values and then want to set them
%   back to the default values. This command sets the RTickMode property
%   for the polar axes to 'auto'.
%   
%   RTICKS('manual') freezes the r-axis tick values at the current values.
%   Use this option if you want to retain the current tick values when
%   resizing the polar axes or adding new data to the polar axes. This
%   command sets the RTickMode property for the polar axes to 'manual'.
%   
%   m = RTICKS('mode') returns the current value of the mode, which is
%   either 'auto' or 'manual'. By default, the mode is automatic unless you
%   specify tick values or set the mode to manual.
%   
%   ___ = RTICKS(ax, ___ ) uses the polar axes specified by ax instead of
%   the current axes.
%
%   RTICKS sets or gets the RTick or RTickMode property of an axes.
%
%   See also RTICKLABELS, POLARAXES, XTICKS, YTICKS, ZTICKS, THETATICKS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
