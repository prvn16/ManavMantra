function varargout = thetaticks(varargin)
%THETATICKS Set or query theta-axis tick values for polar axes
%   THETATICKS(ticks) specifies the values for the tick marks along the
%   theta-axis of the current polar axes. Specify ticks as a vector of
%   increasing values, for example, [0 2 4 6].
%   
%   tt = THETATICKS returns a vector containing the theta-axis tick values
%   for the current polar axes.
%   
%   THETATICKS('auto') lets the polar axes choose the theta-axis tick
%   values. Use this option if you change the tick values and then want to
%   set them back to the default values. This command sets the
%   ThetaTickMode property for the polar axes to 'auto'.
%   
%   THETATICKS('manual') freezes the theta-axis tick values at the current
%   values. Use this option if you want to retain the current tick values
%   when resizing the polar axes or adding new data to the polar axes. This
%   command sets the ThetaTickMode property for the polar axes to 'manual'.
%   
%   m = THETATICKS('mode') returns the current value of the mode, which is
%   either 'auto' or 'manual'. By default, the mode is automatic unless you
%   specify tick values or set the mode to manual.
%   
%   ___ = THETATICKS(ax, ___ ) uses the polar axes specified by ax instead
%   of the current axes.
%
%   THETATICKS sets or gets the ThetaTick or ThetaTickMode property of an
%   axes.
%
%   See also THETATICKLABELS, POLARAXES, XTICKS, YTICKS, ZTICKS, RTICKS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
