function hh = ezmeshc(varargin)
%EZMESHC   (NOT RECOMMENDED) Easy to use combination mesh/contour plotter
%
% ==========================================================================
% EZMESHC is not recommended. Use FMESH with 'ContoursVisible','on' instead.
% ==========================================================================
%
%   EZMESHC(FUN) plots a graph of FUN(X,Y) using MESHC. FUN is plotted over
%   the default domain -2*PI < X < 2*PI and -2*PI < Y < 2*PI.
% 
%   EZMESHC(FUN,DOMAIN) plots FUN over the specified DOMAIN instead of the
%   default domain. DOMAIN can be the vector [XMIN,XMAX,YMIN,YMAX] or the
%   vector [A,B] (to plot over A < X < B and A < Y < B).
%
%   EZMESHC(FUNX,FUNY,FUNZ) plots the parametric surface FUNX(S,T),
%   FUNY(S,T), FUNZ(S,T) over the domain -2*PI < S < 2*PI and
%   -2*PI < T < 2*PI. 
%
%   EZMESHC(FUNX,FUNY,FUNZ,[SMIN,SMAX,TMIN,TMAX]) or
%   EZMESHC(FUNX,FUNY,FUNZ,[A,B]) uses the specified domain.
%
%   EZMESHC(...,N) plots the function over the default domain using an
%   N-by-N grid. The default value for N is 60.
%
%   EZMESHC(...,'circ') plots the function over a disk centered on the
%   domain.
%
%   EZMESHC(AX,...) plots into AX instead of GCA.
%
%   H = EZMESHC(...) returns handles to plotted objects in H.
%
%   Examples:
%   The easiest way to express a function is via a string:
%      ezmeshc('x*exp(-x^2 - y^2)')
%
%   One programming technique is to vectorize the string expression using
%   the array operators .* (TIMES), ./ (RDIVIDE), .\ (LDIVIDE), .^ (POWER).
%   This makes the algorithm more efficient since it can perform multiple
%   function evaluations at once.
%      ezmeshc('x.*exp(-x.^2 - y.^2)')
%
%   You may also use a function handle to an existing function. Function
%   handles are more powerful and efficient than string expressions.
%      ezmeshc(@peaks)
%
%   EZMESHC plots the variables in string expressions alphabetically.
%      subplot(1,2,1), ezmeshc('exp(-x).*cos(t)',[-4*pi,4*pi,-2,2])
%   To avoid this ambiguity, specify the order with an anonymous function:
%      subplot(1,2,2), ezmeshc(@(x,t)exp(-x).*cos(t),[-2,2,-4*pi,4*pi])
%
%   If your function has additional parameters, for example k in myfun:
%      %-----------------------%
%      function z = myfun(x,y,k)
%      z = - x.^k - y.^k;
%      %-----------------------%
%   then you may use an anonymous function to specify that parameter:
%      ezmeshc(@(x,y)myfun(x,y,2))
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%            EZSURF, EZSURFC, MESHC, VECTORIZE, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse possible Axes input
[cax,args] = axescheck(varargin{:});

if ~isempty(cax)
    h = ezgraph3(cax,'meshc',args{:}); %#ok<EZGRPH3>
else
    h = ezgraph3('meshc',args{:}); %#ok<EZGRPH3> 
end

if nargout > 0
    hh = h;
end
