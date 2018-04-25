function ddex5
%DDEX5 This example shows how to solve a neutral DDE of initial value type.
%   The problem appears in Z. Jackiewicz, One step methods of any order for
%   neutral functional differential equations, SINUM 21 (1984), pp. 486-511.
%   The equation
%      y'(t) = 2*cos(2*t)*y(t/2)^(2*cos(t)) + log(y'(t/2))
%              - log(2*cos(t)) - sin(t)
%   has delay function t/2 and t0 = 0, so it is an initial-value NDDE.
%   With y(0) = 1, a consistent initial slope s = y'(0) must satisfy the
%   NDDE at t0, which is here s = 2+log(s)-log(2). Jackiewicz uses s = 2
%   for which there is an analytical solution of the NDDE. However, there
%   exists another consistent initial slope for this problem,
%      s = 0.4063757399599599...
%
%   See also DDENSD, FUNCTION_HANDLE.

%   Copyright 2012-2014 The MathWorks, Inc.

% Anonymous function calculating the delay
delay = @(t,y) t/2;

y0 = 1;
s1 = 2;
s2 = 0.4063757399599599;  % Two consistent initial slopes

t0 = 0;
tf = 0.1;
tspan = [t0, tf];

% Solve as initial-value neutral DDE.
sol1 = ddensd(@ddex5de,delay,delay,{y0,s1},tspan);
% Changing the initial slope changes the computed solution.
sol2 = ddensd(@ddex5de,delay,delay,{y0,s2},tspan);

% Analytical solution for initial slope s1:
t = linspace(t0,tf,10);
y1 = exp(sin(2*t));

figure
plot(sol1.x,sol1.y,'b',t,y1,'ro',sol2.x,sol2.y,'k')
legend('numerical, y''(0) = 2','analytical, y''(0) = 2',...
   'numerical, y''(0) \approx 0.4','Location','NorthWest')
xlabel('time t')
ylabel('solution y')
title('Two solutions of Jackiewicz'' initial-value NDDE')

end % ddex5

% == Local function =========================================================
function dydt = ddex5de(t,y,ydel,ypdel)
% Differential equation function for DDEX5.
dydt = 2*cos(2*t)*ydel^(2*cos(t)) + log(ypdel) - log(2*cos(t)) - sin(t);
end % ddex5de