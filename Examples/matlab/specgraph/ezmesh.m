function hh = ezmesh(varargin)
%EZMESH   (NOT RECOMMENDED) Easy to use 3-D mesh plotter
%
% =============================================
% EZMESH is not recommended. Use FMESH instead.
% =============================================
%
%   EZMESH(FUN) plots a graph of FUN(X,Y) using MESH. FUN is plotted over
%   the default domain -2*PI < X < 2*PI and -2*PI < Y < 2*PI.
% 
%   EZMESH(FUN,DOMAIN) plots FUN over the specified DOMAIN instead of the
%   default domain. DOMAIN can be the vector [XMIN,XMAX,YMIN,YMAX] or the
%   vector [A,B] (to plot over A < X < B and A < Y < B).
%
%   EZMESH(FUNX,FUNY,FUNZ) plots the parametric surface FUNX(S,T),
%   FUNY(S,T), and FUNZ(S,T) over the domain -2*PI < S < 2*PI and
%   -2*PI < T < 2*PI.
%
%   EZMESH(FUNX,FUNY,FUNZ,[SMIN,SMAX,TMIN,TMAX]) or
%   EZMESH(FUNX,FUNY,FUNZ,[A,B]) uses the specified domain.
%
%   EZMESH(...,N) plots the function over the default domain using an
%   N-by-N grid. The default value for N is 60.
%
%   EZMESH(...,'circ') plots the function over a disk centered on the
%   domain.
%
%   EZMESH(AX,...) plots into AX instead of GCA.
%
%   H = EZMESH(...) returns a handle to the plotted object in H.
%
%   Examples:
%   The easiest way to express a function is via a string:
%      ezmesh('x*exp(-x^2 - y^2)')
%
%   One programming technique is to vectorize the string expression using
%   the array operators .* (TIMES), ./ (RDIVIDE), .\ (LDIVIDE), .^ (POWER).
%   This makes the algorithm more efficient since it can perform multiple
%   function evaluations at once.
%      ezmesh('x.*exp(-x.^2 - y.^2)')
%
%   You may also use a function handle to an existing function. Function
%   handles are more powerful and efficient than string expressions.
%      ezmesh(@peaks)
%
%   EZMESH plots the variables in string expressions alphabetically.
%      subplot(1,2,1), ezmesh('exp(-x).*cos(t)',[-4*pi,4*pi,-2,2])
%   To avoid this ambiguity, specify the order with an anonymous function:
%      subplot(1,2,2), ezmesh(@(x,t)exp(-x).*cos(t),[-2,2,-4*pi,4*pi])
%
%   If your function has additional parameters, for example k in myfun:
%      %-----------------------%
%      function z = myfun(x,y,k)
%      z = - x.^k - y.^k;
%      %-----------------------%
%   then you may use an anonymous function to specify that parameter:
%      ezmesh(@(x,y)myfun(x,y,2))
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZSURF, 
%            EZSURFC, EZMESHC, MESH, VECTORIZE, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse possible Axes input
[cax,args] = axescheck(varargin{:});

if ~isempty(cax)
    h = ezgraph3(cax,'mesh',args{:}); %#ok<EZGRPH3>
else
    h = ezgraph3('mesh',args{:}); %#ok<EZGRPH3>
end

if nargout > 0
    hh = h;
end
