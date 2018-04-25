function hh = ezcontour(varargin)
%EZCONTOUR   (NOT RECOMMENDED) Easy to use contour plotter
%
% ===================================================
% EZCONTOUR is not recommended. Use FCONTOUR instead.
% ===================================================
%
%   EZCONTOUR(FUN) plots the contour lines of FUN(X,Y) using CONTOUR. FUN
%   is plotted over the default domain -2*PI < X < 2*PI, -2*PI < Y < 2*PI.
%
%   EZCONTOUR(FUN,DOMAIN) plots FUN over the specified DOMAIN instead of
%   the default domain. DOMAIN can be the vector [XMIN,XMAX,YMIN,YMAX]
%   or the vector [A,B] (to plot over A < X < B and A < Y < B).
%
%   EZCONTOUR(...,N) plots FUN over the default domain using an N-by-N
%   grid. The default value for N is 60.
%
%   EZCONTOUR(AX,...) plots into AX instead of GCA.
%
%   H = EZCONTOUR(...) returns handles to contour objects in H.
%
%   Examples:
%   The easiest way to express a function is via a string:
%      ezcontour('x*exp(-x^2 - y^2)')
%
%   One programming technique is to vectorize the string expression using
%   the array operators .* (TIMES), ./ (RDIVIDE), .\ (LDIVIDE), .^ (POWER).
%   This makes the algorithm more efficient since it can perform multiple
%   function evaluations at once.
%      ezcontour('x.*exp(-x.^2 - y.^2)')
%
%   You may also use a function handle to an existing function. Function
%   handles are more powerful and efficient than string expressions.
%      ezcontour(@peaks)
%
%   EZCONTOUR plots the variables in string expressions alphabetically.
%      subplot(1,2,1), ezcontour('x.*exp(-x.^2 - y.^2)')
%   To avoid this ambiguity, specify the order with an anonymous function:
%      subplot(1,2,2), ezcontour(@(y,x)x.*exp(-x.^2 - y.^2))
%
%   If your function has additional parameters, for example k in myfun:
%      %-----------------------%
%      function z = myfun(x,y,k)
%      z = x.^k - y.^k - 1;
%      %-----------------------%
%   then you may use an anonymous function to specify that parameter:
%      ezcontour(@(x,y)myfun(x,y,2))
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOURF, EZSURF, EZMESH,
%            EZSURFC, EZMESHC, CONTOUR, VECTORIZE, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse possible Axes input
[cax,args] = axescheck(varargin{:});

if ~isempty(cax)
    h = ezgraph3(cax,'contour',args{:}); %#ok<EZGRPH3>
else
    h = ezgraph3('contour',args{:}); %#ok<EZGRPH3>
end

cax = ancestor(h(1),'axes');
rotate3d(cax,'off');

if nargout > 0
    hh = h;
end
