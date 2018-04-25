function varargout = thetaticklabels(varargin)
%THETATICKLABELS Set or query theta-axis tick labels for polar axes
%   THETATICKLABELS(labels) specifies the theta-axis tick labels for the
%   current polar axes. Specify labels as a cell array of character
%   vectors, for example, {'January','February','March'}. This command will
%   also set both ThetaTickMode and ThetaTickLabelMode to 'manual'.
%   
%   tl = THETATICKLABELS returns the theta-axis tick labels for the current
%   polar axes.
%   
%   THETATICKLABELS('auto') lets the polar axes choose the theta-axis tick
%   labels. Use this option if you set the labels and then want to set them
%   back to the default values. This command sets the ThetaTickLabelMode
%   property for the polar axes to 'auto'.
%   
%   THETATICKLABELS('manual') freezes the theta-axis tick labels at the
%   current values. This command sets the ThetaTickLabelMode property for
%   the polar axes to 'manual'.
%   
%   m = THETATICKLABELS('mode') returns the current value of the tick
%   labels mode, which is either 'auto' or 'manual'. By default, the mode
%   is automatic unless you specify tick labels or set the mode to manual.
%   
%   ___ = THETATICKLABELS(ax, ___ ) uses the polar axes specified by ax
%   instead of the current axes.
%   
%   THETATICKLABELS sets or gets the ThetaTickLabel or ThetaTickLabelMode
%   property of an axes.
%   
%   Unlike setting the ThetaTickLabel property directly (which will have no
%   effect on the ThetaTickMode), THETATICKLABELS will set the
%   ThetaTickMode to 'manual' in addition to setting the ThetaTickLabelMode
%   properties to 'manual'.
%   
%   If you specify fewer labels than there are tick values, THETATICKLABELS
%   will append blank labels so the number of labels matches the number of
%   tick values.
%   
%   See also THETATICKS, POLARAXES, XTICKLABELS, YTICKLABELS, ZTICKLABELS,
%   RTICKLABELS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
