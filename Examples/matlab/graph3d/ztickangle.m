function varargout = ztickangle(varargin)
%ZTICKANGLE Rotate z-axis tick labels
%   ZTICKANGLE(angle) rotates the z-axis tick labels for the current axes
%   counterclockwise to the specified angle in degrees.
%   
%   ang = ZTICKANGLE returns the rotation angle for the z-axis tick labels
%   of the current axes as a scalar value in degrees.
%   
%   ZTICKANGLE('auto') lets the axes choose the z-axis tick label rotation
%   angle. This command sets the ZAxis TickLabelRotationMode property for the
%   axes to 'auto'.
%   
%   ZTICKANGLE('manual') freezes the z-axis tick label rotation angle at the
%   current values. This command sets the ZAxis TickLabelRotationMode property
%   for the axes to 'manual'.
%   
%   m = ZTICKANGLE('mode') returns the current value of the z-axis tick label
%   rotation angle mode, which is either 'auto' or 'manual'. By default, the
%   mode is automatic unless you specify the angle or set the mode to manual.
%
%   ___ = ZTICKANGLE(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%
%   ZTICKANGLE sets or gets the ZTickLabelRotation property of an axes.
%
%   See also XTICKANGLE, YTICKANGLE, RTICKANGLE.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
