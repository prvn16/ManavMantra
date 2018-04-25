function varargout = xtickangle(varargin)
%XTICKANGLE Rotate x-axis tick labels
%   XTICKANGLE(angle) rotates the x-axis tick labels for the current axes
%   counterclockwise to the specified angle in degrees.
%   
%   ang = XTICKANGLE returns the rotation angle for the x-axis tick labels
%   of the current axes as a scalar value in degrees.
%   
%   XTICKANGLE('auto') lets the axes choose the x-axis tick label rotation
%   angle. This command sets the XAxis TickLabelRotationMode property for the
%   axes to 'auto'.
%   
%   XTICKANGLE('manual') freezes the x-axis tick label rotation angle at the
%   current values. This command sets the XAxis TickLabelRotationMode property
%   for the axes to 'manual'.
%   
%   m = XTICKANGLE('mode') returns the current value of the x-axis tick label
%   rotation angle mode, which is either 'auto' or 'manual'. By default, the
%   mode is automatic unless you specify the angle or set the mode to manual.
%
%   ___ = XTICKANGLE(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   XTICKANGLE sets or gets the XTickLabelRotation property of an axes.
%
%   See also YTICKANGLE, ZTICKANGLE, RTICKANGLE.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
