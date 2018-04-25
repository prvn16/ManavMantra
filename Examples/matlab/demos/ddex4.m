function ddex4
%DDEX4 This example shows how to solve a neutral DDE with two delays.
%   The neutral delay differential equation solved in this example appears in
%   C.A.H. Paul, A test set of functional differential equations, Numer. Anal.
%   Rept. 243, Math. Dept., Univ. of Manchester, UK, 1994.
%   The equation
%      y'(t) = 1 + y(t) - 2*y(t/2)^2 - y'(t-pi),
%   is to be solved on [0,pi] with y(t) = cos(t) for t <= 0.  The problem
%   has an analytical solution, y = cos(t).
%
%   See also DDENSD, DEVAL, FUNCTION_HANDLE.

%   Copyright 2012-2014 The MathWorks, Inc.

sol = ddensd(@ddex4de,@ddex4ydel,@ddex4ypdel,@ddex4hist,[0,pi]);

% Form data to plot history and analytical solution:
th = linspace(-pi,0);
yh = ddex4hist(th);
ta = linspace(0,pi,10);
ya = cos(ta);

% A satisfactory plot of the numerical solution is provided by sol.x,sol.y,
% but DEVAL can be used to obtain values at specific points,
tn = linspace(0,pi);
yn = deval(sol,tn);

figure
plot(th,yh,'k',tn,yn,'b',ta,ya,'ro')
legend('history','numerical','analytical','Location','NorthWest')
xlabel('time t')
ylabel('solution y')
title('Example of Paul with 1 equation and 2 delay functions')
axis([-3.5 3.5 -1.5 1.5])

end % ddex4

% == Local functions =======================================================
function v = ddex4hist(t)
% History function for DDEX4.
v = cos(t);
end % ddex4hist
% -------------------------------------------------------------------------
function del = ddex4ydel(t,y)
% State dependent delay function for the solution value in DDEX4.
del = t/2;
end % ddex4ydel
% -------------------------------------------------------------------------
function del = ddex4ypdel(t,y)
% State dependent delay function for the solution derivative in DDEX4.
del = t-pi;
end % ddex4ypdel
% -------------------------------------------------------------------------
function dydt = ddex4de(t,y,ydel,ypdel)
% Differential equation function for DDEX4.
dydt = 1 + y - 2*ydel^2 - ypdel;
end % ddex4de