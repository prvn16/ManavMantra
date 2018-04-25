function varargout = ytickformat(varargin)
%YTICKFORMAT Set or query y-axis tick label format
%   YTICKFORMAT(fmt) specifies the format for the y-axis tick labels for
%   the current axes. Specify fmt as 'percentage', 'degrees', 'usd', 'nzd',
%   'eur', 'gbp', 'jpy', 'auto', or a custom numeric format. For example,
%   specify fmt as 'usd' to display the labels as US dollars, or '%,g' to
%   display commas in the thousandth place.
%   
%   YTICKFORMAT(datefmt) specifies the format for y-axis tick labels that
%   show dates or times. For example, specify datefmt as 'MM-dd-yy' to
%   display dates such as 04-19-14.
%   
%   YTICKFORMAT(durationfmt) specifies the format for y-axis tick labels
%   that show durations. For example, specify durationfmt as 'm' to display
%   durations in minutes.
%   
%   YTICKFORMAT(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%   
%   yfmt = YTICKFORMAT returns the format style for y-axis tick labels of
%   the current axes.
%   
%   yfmt = YTICKFORMAT(ax) returns the format style for y-axis tick labels
%   of the axes specified by ax instead of the current axes.
%
%   YTICKFORMAT sets or gets the TickLabelFormat property of the YAxis of
%   an axes. Some predefined formats will also set the Exponent or
%   ExponentMode properties of the YAxis.
%
%   See also XTICKFORMAT, ZTICKFORMAT, THETATICKFORMAT, RTICKFORMAT.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
