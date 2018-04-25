function varargout = ztickformat(varargin)
%ZTICKFORMAT Set or query z-axis tick label format
%   ZTICKFORMAT(fmt) specifies the format for the z-axis tick labels for
%   the current axes. Specify fmt as 'percentage', 'degrees', 'usd', 'nzd',
%   'eur', 'gbp', 'jpy', 'auto', or a custom numeric format. For example,
%   specify fmt as 'usd' to display the labels as US dollars, or '%,g' to
%   display commas in the thousandth place.
%   
%   ZTICKFORMAT(datefmt) specifies the format for z-axis tick labels that
%   show dates or times. For example, specify datefmt as 'MM-dd-yy' to
%   display dates such as 04-19-14.
%   
%   ZTICKFORMAT(durationfmt) specifies the format for z-axis tick labels
%   that show durations. For example, specify durationfmt as 'm' to display
%   durations in minutes.
%   
%   ZTICKFORMAT(ax, ___ ) uses the axes specified by ax instead of the
%   current axes.
%   
%   zfmt = ZTICKFORMAT returns the format style for z-axis tick labels of
%   the current axes.
%   
%   zfmt = ZTICKFORMAT(ax) returns the format style for z-axis tick labels
%   of the axes specified by ax instead of the current axes.
%
%   ZTICKFORMAT sets or gets the TickLabelFormat property of the ZAxis of
%   an axes. Some predefined formats will also set the Exponent or
%   ExponentMode properties of the ZAxis.
%
%   See also XTICKFORMAT, YTICKFORMAT, THETATICKFORMAT, RTICKFORMAT.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
