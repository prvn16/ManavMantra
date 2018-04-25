function varargout = rticklabels(varargin)
%RTICKLABELS Set or query r-axis tick labels for polar axes
%   RTICKLABELS(labels) specifies the r-axis tick labels for the current
%   polar axes. Specify labels as a cell array of character vectors, for
%   example, {'January','February','March'}. This command will also set
%   both RTickMode and RTickLabelMode to 'manual'.
%   
%   rl = RTICKLABELS returns the r-axis tick labels for the current polar
%   axes.
%   
%   RTICKLABELS('auto') lets the polar axes choose the r-axis tick labels.
%   Use this option if you set the labels and then want to set them back to
%   the default values. This command sets the RTickLabelMode property for
%   the polar axes to 'auto'.
%   
%   RTICKLABELS('manual') freezes the r-axis tick labels at the current
%   values. This command sets the RTickLabelMode property for the polar
%   axes to 'manual'.
%   
%   m = RTICKLABELS('mode') returns the current value of the tick labels
%   mode, which is either 'auto' or 'manual'. By default, the mode is
%   automatic unless you specify tick labels or set the mode to manual.
%   
%   ___ = RTICKLABELS(ax, ___ ) uses the polar axes specified by ax instead
%   of the current axes.
%   
%   RTICKLABELS sets or gets the RTickLabel or RTickLabelMode property of
%   an axes.
%   
%   Unlike setting the RTickLabel property directly (which will have no
%   effect on the RTickMode), RTICKLABELS will set the RTickMode to
%   'manual' in addition to setting the RTickLabelMode properties to
%   'manual'.
%   
%   If you specify fewer labels than there are tick values, RTICKLABELS
%   will append blank labels so the number of labels matches the number of
%   tick values.
%   
%   See also RTICKS, POLARAXES, XTICKLABELS, YTICKLABELS, ZTICKLABELS,
%   THETATICKLABELS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
