function varargout = zticklabels(varargin)
%ZTICKLABELS Set or query z-axis tick labels
%   ZTICKLABELS(labels) specifies the z-axis tick labels for the current
%   axes. Specify labels as a cell array of character vectors, for example,
%   {'January','February','March'}. This command will also set both
%   ZTickMode and ZTickLabelMode to 'manual'.
%   
%   zl = ZTICKLABELS returns the z-axis tick labels for the current axes.
%   
%   ZTICKLABELS('auto') lets the axes choose the z-axis tick labels. Use
%   this option if you set the labels and then want to set them back to the
%   default values. This command sets the ZTickLabelMode property for the
%   axes to 'auto'.
%   
%   ZTICKLABELS('manual') freezes the z-axis tick labels at the current
%   values. This command sets the ZTickLabelMode property for the axes to
%   'manual'.
%   
%   m = ZTICKLABELS('mode') returns the current value of the tick labels
%   mode, which is either 'auto' or 'manual'. By default, the mode is
%   automatic unless you specify tick labels or set the mode to manual.
%   
%   ___ = ZTICKLABELS(ax, ___ ) uses the axes specified by ax instead of
%   the current axes.
%   
%   ZTICKLABELS sets or gets the ZTickLabel or ZTickLabelMode property of
%   an axes.
%   
%   Unlike setting the ZTickLabel property directly (which will have no
%   effect on the ZTickMode), ZTICKLABELS will set the ZTickMode to
%   'manual' in addition to setting the ZTickLabelMode properties to
%   'manual'.
%   
%   If you specify fewer labels than there are tick values, ZTICKLABELS
%   will append blank labels so the number of labels matches the number of
%   tick values.
%   
%   See also ZTICKS, XTICKLABELS, YTICKLABELS, THETATICKLABELS,
%   RTICKLABELS.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
