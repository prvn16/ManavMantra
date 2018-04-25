function varargout = rtickangle(varargin)
%RTICKANGLE Rotate r-axis tick labels
%   RTICKANGLE(angle) rotates the r-axis tick labels for the current polar
%   axes counterclockwise to the specified angle in degrees.
%   
%   ang = RTICKANGLE returns the rotation angle for the r-axis tick labels
%   of the current polar axes as a scalar value in degrees.
%   
%   RTICKANGLE('auto') lets the axes choose the r-axis tick label rotation
%   angle. This command sets the RAxis TickLabelRotationMode property for the
%   axes to 'auto'.
%   
%   RTICKANGLE('manual') freezes the r-axis tick label rotation angle at the
%   current values. This command sets the RAxis TickLabelRotationMode property
%   for the axes to 'manual'.
%   
%   m = RTICKANGLE('mode') returns the current value of the r-axis tick label
%   rotation angle mode, which is either 'auto' or 'manual'. By default, the
%   mode is automatic unless you specify the angle or set the mode to manual.
%
%   ___ = RTICKANGLE(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   RTICKANGLE sets or gets the RTickLabelRotation property of an axes.
%
%   See also POLARAXES, XTICKANGLE, YTICKANGLE, ZTICKANGLE.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
