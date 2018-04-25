function hh = ezsurfc(varargin)
%EZSURFC (NOT RECOMMENDED) Easy to use combination surf/contour plotter.
%
% =======================================================================
% EZSURFC is not recommended. Use FSURF with 'ShowContours','on' instead.
% =======================================================================
%
%   EZSURFC(FUN) plots a graph of the function FUN(X,Y) using SURFC. FUN is
%   plotted over the default domain -2*PI < X < 2*PI, -2*PI < Y < 2*PI.
% 
%   EZSURFC(FUN,DOMAIN) plots FUN over the specified DOMAIN instead of the
%   default domain. DOMAIN can be the vector [XMIN,XMAX,YMIN,YMAX] or the
%   [A,B] (to plot over A < X < B, A < Y < B).
%
%   EZSURFC(FUNX,FUNY,FUNZ) plots the parametric surface FUNX(S,T),
%   FUNY(S,T), and FUNZ(S,T) over the square -2*PI < S < 2*PI and
%   -2*PI < T < 2*PI. 
%
%   EZSURFC(FUNX,FUNY,FUNZ,[SMIN,SMAX,TMIN,TMAX]) or
%   EZSURFC(FUNX,FUNY,FUNZ,[A,B]) uses the specified domain.
%
%   EZSURFC(...,N) plots FUN over the default domain using an N-by-N grid.
%   The default value for N is 60.
%
%   EZSURFC(...,'circ') plots FUN over a disk centered on the domain.
%
%   EZSURFC(AX,...) plots into AX instead of GCA.
%
%   H = EZSURFC(...) returns handles to the plotted object in H.
%
%   Examples:
%   The easiest way to express a function is via a string:
%      ezsurfc('x*exp(-x^2 - y^2)')
%
%   One programming technique is to vectorize the string expression using
%   the array operators .* (TIMES), ./ (RDIVIDE), .\ (LDIVIDE), .^ (POWER).
%   This makes the algorithm more efficient since it can perform multiple
%   function evaluations at once.
%      ezsurfc('x.*exp(-x.^2 - y.^2)')
%
%   You may also use a function handle to an existing function. Function
%   handles are more powerful and efficient than string expressions.
%       ezsurfc(@peaks)
%
%   EZSURFC plots the variables in string expressions alphabetically.
%      subplot(1,2,1), ezsurfc('u.*(v.^2)./(u.^2 + v.^4)')
%   To avoid this ambiguity, specify the order with an anonymous function:
%      subplot(1,2,2), ezsurfc(@(v,u)u.*(v.^2)./(u.^2 + v.^4))
%
%   If your function has additional parameters, for example k in myfun:
%      %------------------------------%
%      function z = myfun(x,y,k1,k2,k3)
%      z = x.*(y.^k1)./(x.^k2 + y.^k3);
%      %------------------------------%
%   then you may use an anonymous function to specify that parameter:
%      ezsurfc(@(x,y)myfun(x,y,2,2,4))
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%            EZSURF, EZMESHC, SURFC, VECTORIZE, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse possible Axes input
[cax,args] = axescheck(varargin{:});

if ~isempty(cax)
    h = ezgraph3(cax,'surfc',args{:}); %#ok<EZGRPH3>
else
    h = ezgraph3('surfc',args{:}); %#ok<EZGRPH3>
end

if nargout > 0
    hh = h;
end

