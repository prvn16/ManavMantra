function varargout = rtickformat(varargin)
%RTICKFORMAT Set or query r-axis tick label format for polar axes
%   RTICKFORMAT(fmt) specifies the format for the r-axis tick labels for
%   the current polar axes. Specify fmt as 'percentage', 'degrees', 'usd',
%   'nzd', 'eur', 'gbp', 'jpy', 'auto', or a custom numeric format. For
%   example, specify fmt as 'usd' to display the labels as US dollars, or
%   '%,g' to display commas in the thousandth place.
%   
%   RTICKFORMAT(ax, fmt) uses the polar axes specified by ax instead of the
%   current axes.
%   
%   rfmt = RTICKFORMAT returns the format style for r-axis tick labels of
%   the current polar axes.
%   
%   rfmt = RTICKFORMAT(ax) returns the format style for r-axis tick labels
%   of the polar axes specified by ax instead of the current axes.
%
%   RTICKFORMAT sets or gets the TickLabelFormat property of the RAxis of
%   an axes. Some predefined formats will also set the Exponent or
%   ExponentMode properties of the RAxis.
%
%   See also POLARAXES, XTICKFORMAT, YTICKFORMAT, ZTICKFORMAT,
%   THETATICKFORMAT.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
