function h = polarscatter(varargin)
%POLARSCATTER Polar scatter/bubble plot.
%   POLARSCATTER(TH,R) displays circles at the locations specified by the
%   vectors TH and R, where TH and R are the same size. This type of graph
%   is also known as a bubble plot.
%
%   POLARSCATTER(TH,R,S) sets the marker sizes, where S
%   determines the area of each marker (in points^2). To draw all the
%   markers with the same size, specify S as a scalar. To draw the markers
%   with different sizes, specify S as a vector the same length as TH. If S
%   is empty, the markers use the default size.
%
%   POLARSCATTER(TH,R,S,C) sets the marker colors using C. When C is a
%   vector the same length as TH and R, the values in C are linearly mapped
%   to the colors in the current colormap. When C is a length(TH)-by-3
%   matrix, it directly specifies the colors of the markers as RGB triplet
%   values. C can also be a character vector of a color name, such as
%   'red'.
%
%   POLARSCATTER(...,M) uses the marker M instead of 'o'.
%
%   POLARSCATTER(...,'filled') fills the markers.
%
%   POLARSCATTER(...,Name,Value) sets scatter properties using one or more
%   name-value pair arguments. For example,
%   POLARSCATTER(TH,R,'MarkerEdgeColor',[.6 0 0]) creates a plot with dark
%   red markers.
%
%   POLARSCATTER(AX,...) plots into AX instead of GCA.
%
%   PS = POLARSCATTER(...) returns the scatter objects created.
%
%   Use POLARPLOT for single color, single marker size scatter plots.
%
%   Example
%      t = 0:.05:2*pi;
%      polarscatter(t,sin(2*t).*cos(2*t),101 + 100*(sin(2*t)),cos(2*t));
%
%   See also: RLIM, POLARAXES, SCATTER, POLARPLOT
%
%   Copyright 2016 The MathWorks, Inc.

narginchk(1,inf)
[cax, args] = axescheck(varargin{:});
if ~isempty(cax) && ~isa(cax, 'matlab.graphics.axis.PolarAxes')
    error(message('MATLAB:polarplot:AxesInput'));
end
try
    cax = matlab.graphics.internal.prepareCoordinateSystem('polar', cax);   

    obj = scatter(cax, args{:});
catch e
    throw(e);
end

if nargout > 0
    h = obj;
end

