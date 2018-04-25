function fem1ode(N)
%FEM1ODE  Stiff problem with a time-dependent mass matrix, M(t)*y' = f(t,y).
%   The parameter N controls the discretization, and the resulting system
%   consists of N equations. By default, N is 19.
%
%   In this example, the nested function f(T,Y) returns the derivatives
%   vector for a finite element discretization of a partial differential
%   equation. The function mass(T) returns the time-dependent mass matrix M
%   evaluated at time T. By default, the solvers of the ODE Suite solve
%   systems of the form y' = f(t,y).  To solve a system M(t)y' = f(t,y),
%   use ODESET to set the property 'Mass' to a function that evaluates M(t)
%   and set 'MStateDependence' to 'none'.
%
%   In this problem the Jacobian df/dy is a constant, tri-diagonal
%   matrix. The 'Jacobian' property is used to provide df/dy to the solver.
%
%   See also ODE15S, ODE23T, ODE23TB, ODESET, FUNCTION_HANDLE.

%   Mark W. Reichelt and Lawrence F. Shampine, 11-11-94.
%   Copyright 1984-2014 The MathWorks, Inc.

if nargin < 1
   N = 19;
end

h = pi/(N+1);
y0 = sin(h*(1:N)');
tspan = [0; pi];

% The Jacobian is constant.
e = repmat(1/h,N,1);    %  e = [(1/h) ... (1/h)];
d = repmat(-2/h,N,1);   %  d = [(-2/h) ... (-2/h)];
J = spdiags([e d e], -1:1, N, N);
% J will be shared with the derivative function.

d = repmat(h/6,N,1);
M = spdiags([d 4*d d], -1:1, N, N);
% M will be shared with the mass matrix function.

options = odeset('Mass',@mass,'MStateDependence','none','Jacobian',J);

[t,y] = ode15s(@f,tspan,y0,options);

figure;
surf((1:N)/(N+1),t,y);
zlim([0 1]);
view(142.5,30);
title(['Finite element with time-dependent mass matrix, ' ...
   'solved by ODE15S']);
xlabel('space ( x/\pi )');
ylabel('time');
zlabel('solution');

% -----------------------------------------------------------------------
% Nested functions
%

   function yp = f(t,y)
      % Derivative function.
      yp = J*y;  % Constant Jacobian is provided by the outer function.
   end
% -----------------------------------------------------------------------

   function Mt = mass(t)
      % Mass matrix function.
      Mt = exp(-t)*M;  % M is provided by the outer function.
   end
% -----------------------------------------------------------------------

end  % fem1ode
