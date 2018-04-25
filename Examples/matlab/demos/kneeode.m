function kneeode
%KNEEODE  The "knee problem" with non-negativity constraints.
%
%   For 0 < epsilon << 1, the solution of the initial value problem
%
%       epsilon*y' = (1-x)*y - y^2,    y(0) = 1
%
%   approaches null isoclines y = 1 - x and y = 0, for x < 1 and
%   x > 1, respectively. The numerical solution, computed with
%   default tolerances, follows the y = 1 - x isocline for the
%   whole interval of integration. Imposing non-negativity
%   constraints results in the correct solution.
%
%   G. Dahlquist, L. Edsberg, G. Skollermo, G. Soderlind, Are the
%   Numerical Methods and Software Satisfactory for Chemical
%   Kinetics?, in Numerical Integration of Differential Equations
%   and Large Linear Systems, J. Hinze ed., Springer, Berlin, 1982,
%   pp. 149-164.
%
%   See also ODE15S, ODE23T, ODE23TB, ODESET, FUNCTION_HANDLE.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2014 The MathWorks, Inc.

% Problem parameter
epsilon = 1e-6;

y0 = 1;
xspan = [0, 2];

% Solve without imposing constraints
options = [];
[x1,y1] = ode15s(@odefcn,xspan,y0,options);

% Impose non-negativity constraint
options = odeset('NonNegative',1);
[x2,y2] = ode15s(@odefcn,xspan,y0,options);

figure
plot(x1,y1,x2,y2)
axis([0,2,-1,1]);
title('The "knee problem"');
legend('No constraints','Non-negativity')
xlabel('x');
ylabel('solution y')

% -----------------------------------------------------------------------
% Nested function -- epsilon provided by the outer function.
%

   function yp = odefcn(x,y)
      yp = ((1 - x)*y - y^2)/epsilon;
   end

% -----------------------------------------------------------------------

end  % kneeode
