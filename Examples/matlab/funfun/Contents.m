% Function functions and ODE solvers.
%
% Numerical integration (quadrature).
%   integral   - Numerically evaluate integral.
%   integral2  - Numerically evaluate double integral.
%   integral3  - Numerically evaluate triple integral.
%   quad       - Numerically evaluate integral, low order method.
%   quadgk     - Numerically evaluate integral, adaptive Gauss-Kronrod quadrature.
%   quadl      - Numerically evaluate integral, higher order method.
%   quadv      - Vectorized QUAD.
%   quad2d     - Numerically evaluate double integral over a planar region.
%   dblquad    - Numerically evaluate double integral over a rectangle.
%   triplequad - Numerically evaluate triple integral.
%
% Plotting.
%   ezplot     - Easy to use function plotter.
%   ezplot3    - Easy to use 3-D parametric curve plotter.
%   ezpolar    - Easy to use polar coordinate plotter.
%   ezcontour  - Easy to use contour plotter.
%   ezcontourf - Easy to use filled contour plotter.
%   ezmesh     - Easy to use 3-D mesh plotter.
%   ezmeshc    - Easy to use combination mesh/contour plotter.
%   ezsurf     - Easy to use 3-D colored surface plotter.
%   ezsurfc    - Easy to use combination surf/contour plotter.
%   fplot      - Plot function.
%
% Inline function object.
%   inline     - Construct INLINE function object.
%   argnames   - Argument names.
%   formula    - Function formula.
%   char       - Convert INLINE object to character array.
%
% Differential equation solvers.
% Initial value problem solvers for ODEs. (If unsure about stiffness, try ODE45
% first, then ODE15S.)
%   ode45     - Solve non-stiff differential equations, medium order method.
%   ode23     - Solve non-stiff differential equations, low order method.
%   ode113    - Solve non-stiff differential equations, variable order method.
%   ode23t    - Solve moderately stiff ODEs and DAEs Index 1, trapezoidal rule.
%   ode15s    - Solve stiff ODEs and DAEs Index 1, variable order method.
%   ode23s    - Solve stiff differential equations, low order method.
%   ode23tb   - Solve stiff differential equations, low order method.
%
% Initial value problem solver for fully implicit ODEs/DAEs F(t,y,y')=0.
%   decic     - Compute consistent initial conditions.
%   ode15i    - Solve implicit ODEs or DAEs Index 1.
%
% Initial value problem solver for delay differential equations (DDEs). 
%   dde23     - Solve delay differential equations (DDEs) with constant delays.
%   ddesd     - Solve delay differential equations (DDEs) with variable delays.
%   ddensd    - Solve delay differential equations (DDEs) of neutral type.
%
% Boundary value problem solver for ODEs.
%   bvp4c     - Solve boundary value problems by collocation, 3-stage Lobatto formula.
%   bvp5c     - Solve boundary value problems by collocation, 4-stage Lobatto formula.
%
% 1D Partial differential equation solver.
%   pdepe     - Solve initial-boundary value problems for parabolic-elliptic PDEs.
% 
% Option handling.
%   odeset    - Create/alter ODE OPTIONS structure.
%   odeget    - Get ODE OPTIONS parameters.
%   ddeset    - Create/alter DDE OPTIONS structure.
%   ddeget    - Get DDE OPTIONS parameters.
%   bvpset    - Create/alter BVP OPTIONS structure.
%   bvpget    - Get BVP OPTIONS parameters.
%
% Input and Output functions.
%   deval     - Evaluates the solution of a differential equation problem.
%   odextend  - Extends the solutions of a differential equation problem.
%   odeplot   - Time series ODE output function.
%   odephas2  - 2-D phase plane ODE output function.
%   odephas3  - 3-D phase plane ODE output function.
%   odeprint  - Command window printing ODE output function.
%   bvpinit   - Forms the initial guess for BVP4C and BVP5C.
%   bvpxtend  - Forms a guess structure for extending BVP solution. 
%   pdeval    - Evaluates by interpolation the solution computed by PDEPE.

% Helper functions.
%   numjac     - Numerically compute the Jacobian dF/dY of function F(t,y).
%   fcnchk     - Check FUNFUN function argument.
%   symvar     - List of symbolic variables.
%   isvarname  - True for valid variable name.
%   vectorize  - Vectorize string expression or INLINE function object.
%   inlineeval - Evaluate inline expression outside @inline directory.

%   Copyright 1984-2011 The MathWorks, Inc. 
