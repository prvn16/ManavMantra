function varargout = xticklabels(varargin)
%XTICKLABELS Set or query x-axis tick labels
%   XTICKLABELS(labels) specifies the x-axis tick labels for the current
%   axes. Specify labels as a cell array of character vectors, for example,
%   {'January','February','March'}. This command will also set both
%   XTickMode and XTickLabelMode to 'manual'.
%   
%   xl = XTICKLABELS returns the x-axis tick labels for the current axes.
%   
%   XTICKLABELS('auto') lets the axes choose the x-axis tick labels. Use
%   this option if you set the labels and then want to set them back to the
%   default values. This command sets the XTickLabelMode property for the
%   axes to 'auto'.
%   
%   XTICKLABELS('manual') freezes the x-axis tick labels at the current
%   values. This command sets the XTickLabelMode property for the axes to
%   'manual'.
%   
%   m = XTICKLABELS('mode') returns the current value of the tick labels
%   mode, which is either 'auto' or 'manual'. By default, the mode is
%   automatic unless you specify tick labels or set the mode to manual.
%   
%   ___ = XTICKLABELS(ax, ___ ) uses the axes specified by ax instead of
%   the current axes.
%   
%   XTICKLABELS sets or gets the XTickLabel or XTickLabelMode property of
%   an axes.
%   
%   Unlike setting the XTickLabel property directly (which will have no
%   effect on the XTickMode), XTICKLABELS will set the XTickMode to
%   'manual' in addition to setting the XTickLabelMode properties to
%   'manual'.
%   
%   If you specify fewer labels than there are tick values, XTICKLABELS
%   will append blank labels so the number of labels matches the number of
%   tick values.
%   
%   See also XTICKS, YTICKLABELS, ZTICKLABELS, THETATICKLABELS,
%   RTICKLABELS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
