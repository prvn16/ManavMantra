function hh = ezpolar(varargin)
% EZPOLAR Easy to use polar coordinate plotter.
%   EZPOLAR(FUN) plots the polar curve RHO = FUN(THETA) over the default
%   domain 0 < theta < 2*pi.
%
%   EZPOLAR(FUN,[A,B]) plots FUN for A < THETA < B.
%
%   EZPOLAR(AX,...) plots into AX instead of GCA.
%
%   H = EZPOLAR(...) returns a handle to the plotted object in H.
%
%   Examples
%   The easiest way to express a function is via a string:
%      ezpolar('sin(2*t)*cos(3*t)',[0 pi])
%
%   One programming technique is to vectorize the string expression using
%   the array operators .* (TIMES), ./ (RDIVIDE), .\ (LDIVIDE), .^ (POWER).
%   This makes the algorithm more efficient since it can perform multiple
%   function evaluations at once.
%      ezpolar('sin(2*t).*cos(3*t)',[0 pi])
%
%   You may also use a function handle to an existing function or an
%   anonymous function. These are more powerful and efficient than string
%   expressions.
%      ezpolar(@cos)
%      ezpolar(@(t)sin(3*t))
%
%   If your function has additional parameters, for example k1,k2 in myfun:
%      %-------------------------%
%      function s = myfun(t,k1,k2)
%      s = sin(k1*t).*cos(k2*t);
%      %-------------------------%
%   then you may use an anonymous function to specify the parameters:
%      ezpolar(@(t)myfun(t,2,3))
%
%  See also EZPLOT3, EZPLOT, EZSURF, PLOT, PLOT3, POLAR, VECTORIZE,
%           FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

% If r = f(theta) is an inline function, then vectorize it as need be.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

% Create plot 
cax = newplot(cax);

[rho,rho0,rhoargs] = ezfcnchk(args{1},0,'t');
if (length(rhoargs)>1)
   error(message('MATLAB:ezpolar:TooManyVariables'));
end

Npts = 314;

% Determine the domain in t:
switch nargs
   case 1
      T =  linspace(0,2*pi,Npts);
   case 2
      T = linspace(args{2}(1),args{2}(2),Npts);
end

RHO = ezplotfeval(rho,T);

% If RHO is constant (i.e., 1 by 1), then ...
if all( size(RHO) == 1 ), RHO = RHO.*ones(size(T)); end
if ~isempty(cax)
    h = polar(cax,T,RHO);
else
    h = polar(T,RHO);
end

text(0,-1.35*max(abs(RHO)),['r = ', texlabel(rho0)], ...
    'HorizontalAlignment','Center','Parent',cax);

if nargout > 0
    hh = h;
end