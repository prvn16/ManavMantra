function varargout = thetatickformat(varargin)
%THETATICKFORMAT Set or query theta-axis tick label format for polar axes
%   THETATICKFORMAT(fmt) specifies the format for the theta-axis tick
%   labels for the current polar axes. Specify fmt as 'percentage',
%   'degrees', 'usd', 'nzd', 'eur', 'gbp', 'jpy', 'auto', or a custom
%   numeric format. For example, specify fmt as 'usd' to display the labels
%   as US dollars, or '%,g' to display commas in the thousandth place.
%   
%   THETATICKFORMAT(ax, fmt) uses the polar axes specified by ax instead of
%   the current axes.
%   
%   thetafmt = THETATICKFORMAT returns the format style for theta-axis tick
%   labels of the current polar axes.
%   
%   thetafmt = THETATICKFORMAT(ax) returns the format style for theta-axis
%   tick labels of the polar axes specified by ax instead of the current
%   axes.
%
%   THETATICKFORMAT sets or gets the TickLabelFormat property of the
%   ThetaAxis of an axes. Some predefined formats will also set the
%   Exponent or ExponentMode properties of the ThetaAxis.
%
%   See also POLARAXES, XTICKFORMAT, YTICKFORMAT, ZTICKFORMAT, RTICKFORMAT.

%   Copyright 2015-2016 The MathWorks, Inc.

varargout = matlab.graphics.internal.ruler.rulerFunctions(mfilename, nargout, varargin);

end
