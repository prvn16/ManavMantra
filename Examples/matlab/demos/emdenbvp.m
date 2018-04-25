function emdenbvp(solver)
%EMDENBVP  Solve BVP with singular term.
%   Emden's equation arises in modeling a spherical body of gas.
%   The PDE of the model is reduced by symmetry to the ODE
%       y'' + (2/x)*y' + y^5 = 0
%   on an interval [0, 1].  The coefficient (2/x) is singular at
%   x = 0, but symmetry implies the boundary condition y'(0) = 0.
%   With this boundary condition, the term (2/x)*y'(x) is well-defined
%   as x -> 0. For the boundary condition y(1) = sqrt(3/4), the BVP has
%   an analytical solution y(x) = 1/sqrt(1+(x^2)/3) that can be compared
%   to the numerical solution.
%
%   BVP4C solves singular BVPs that have the form y' = S/x*y + f(x,y).
%   The matrix S must be constant and the boundary conditions at x = 0
%   must be consistent with the necessary condition S*y(0) = 0. S is
%   passed to BVP4C by using BVPSET to assign it as the value of the
%   'SingularTerm' property.  In all other respects the BVP is solved
%   just as if the term S/x*y were not present.
%
%   Using variables y(1) = y, y(2) = y' to write Emden's ODE as a first
%   order system results in the required form with S = [0  0; 0 -2].
%   With the boundary condition y(2) = 0 at x = 0, we have S*y(0) =
%   [0; -2y(2)] = [0; 0] as required.
%
%   By default, this example uses the BVP4C solver. Use syntax
%   EMDENBVP('bvp5c') to solve this problem using the BVP5C solver.
%
%   See also BVP4C, BVP5C, BVPSET, BVPGET, BVPINIT, DEVAL, FUNCTION_HANDLE.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2014 The MathWorks, Inc.

if nargin < 1
   solver = 'bvp4c';
end
bvpsolver = fcnchk(solver);

S = [0  0
   0 -2];
options = bvpset('SingularTerm',S);

% This constant guess satisfies the boundary conditions.
guess = [sqrt(3)/2; 0];
solinit = bvpinit(linspace(0,1,5),guess);

sol = bvpsolver(@emdenode,@emdenbc,solinit,options);

% The analytical solution for this problem.
x = linspace(0,1);
truy = 1 ./ sqrt(1 + (x.^2)/3);

% Plot the analytical and computed solutions.
figure;
plot(x,truy,sol.x,sol.y(1,:),'ro');
title('Emden problem -- BVP with singular term.')
legend('Analytical','Computed');
xlabel('x');
ylabel('solution y');

% --------------------------------------------------------------------------

function dydx = emdenode(x,y)
% EMDENODE  Evaluate the function f(x,y)
dydx = [  y(2)
   -y(1)^5 ];

% --------------------------------------------------------------------------

function res = emdenbc(ya,yb)
% EMDENBC  Evaluate the residual in the boundary conditions
res = [ ya(2)
   yb(1) - sqrt(3)/2 ];
