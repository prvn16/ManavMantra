function varargout = ytickangle(varargin)
%YTICKANGLE Rotate y-axis tick labels
%   YTICKANGLE(angle) rotates the y-axis tick labels for the current axes
%   counterclockwise to the specified angle in degrees.
%   
%   ang = YTICKANGLE returns the rotation angle for the y-axis tick labels
%   of the current axes as a scalar value in degrees.
%   
%   YTICKANGLE('auto') lets the axes choose the y-axis tick label rotation
%   angle. This command sets the YAxis TickLabelRotationMode property for the
%   axes to 'auto'.
%   
%   YTICKANGLE('manual') freezes the y-axis tick label rotation angle at the
%   current values. This command sets the YAxis TickLabelRotationMode property
%   for the axes to 'manual'.
%   
%   m = YTICKANGLE('mode') returns the current value of the y-axis tick label
%   rotation angle mode, which is either 'auto' or 'manual'. By default, the
%   mode is automatic unless you specify the angle or set the mode to manual.
%
%   ___ = YTICKANGLE(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   YTICKANGLE sets or gets the YTickLabelRotation property of an axes.
%
%   See also XTICKANGLE, ZTICKANGLE, RTICKANGLE.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
