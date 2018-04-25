function varargout = yticklabels(varargin)
%YTICKLABELS Set or query y-axis tick labels
%   YTICKLABELS(labels) specifies the y-axis tick labels for the current
%   axes. Specify labels as a cell array of character vectors, for example,
%   {'January','February','March'}. This command will also set both
%   YTickMode and YTickLabelMode to 'manual'.
%   
%   yl = YTICKLABELS returns the y-axis tick labels for the current axes.
%   
%   YTICKLABELS('auto') lets the axes choose the y-axis tick labels. Use
%   this option if you set the labels and then want to set them back to the
%   default values. This command sets the YTickLabelMode property for the
%   axes to 'auto'.
%   
%   YTICKLABELS('manual') freezes the y-axis tick labels at the current
%   values. This command sets the YTickLabelMode property for the axes to
%   'manual'.
%   
%   m = YTICKLABELS('mode') returns the current value of the tick labels
%   mode, which is either 'auto' or 'manual'. By default, the mode is
%   automatic unless you specify tick labels or set the mode to manual.
%   
%   ___ = YTICKLABELS(ax, ___ ) uses the axes specified by ax instead of
%   the current axes.
%   
%   YTICKLABELS sets or gets the YTickLabel or YTickLabelMode property of
%   an axes.
%   
%   Unlike setting the YTickLabel property directly (which will have no
%   effect on the YTickMode), YTICKLABELS will set the YTickMode to
%   'manual' in addition to setting the YTickLabelMode properties to
%   'manual'.
%   
%   If you specify fewer labels than there are tick values, YTICKLABELS
%   will append blank labels so the number of labels matches the number of
%   tick values.
%   
%   See also YTICKS, XTICKLABELS, ZTICKLABELS, THETATICKLABELS,
%   RTICKLABELS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
