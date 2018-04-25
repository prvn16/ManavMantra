function varargout = pdepe(m,pde,ic,bc,xmesh,t,options,varargin)
%PDEPE  Solve initial-boundary value problems for parabolic-elliptic PDEs in 1-D.
%   SOL = PDEPE(M,PDEFUN,ICFUN,BCFUN,XMESH,TSPAN) solves initial-boundary
%   value problems for small systems of parabolic and elliptic PDEs in one
%   space variable x and time t to modest accuracy. There are npde unknown
%   solution components that satisfy a system of npde equations of the form
%
%   c(x,t,u,Du/Dx) * Du/Dt = x^(-m) * D(x^m * f(x,t,u,Du/Dx))/Dx + s(x,t,u,Du/Dx)
%
%   Here f(x,t,u,Du/Dx) is a flux and s(x,t,u,Du/Dx) is a source term. m must
%   be 0, 1, or 2, corresponding to slab, cylindrical, or spherical symmetry,
%   respectively. The coupling of the partial derivatives with respect to
%   time is restricted to multiplication by a diagonal matrix c(x,t,u,Du/Dx).
%   The diagonal elements of c are either identically zero or positive.
%   An entry that is identically zero corresponds to an elliptic equation and
%   otherwise to a parabolic equation. There must be at least one parabolic
%   equation. An entry of c corresponding to a parabolic equation is permitted
%   to vanish at isolated values of x provided they are included in the mesh
%   XMESH, and in particular, is always allowed to vanish at the ends of the
%   interval. The PDEs hold for t0 <= t <= tf and a <= x <= b. The interval
%   [a,b] must be finite. If m > 0, it is required that 0 <= a. The solution
%   components are to have known values at the initial time t = t0, the
%   initial conditions. The solution components are to satisfy boundary
%   conditions at x=a and x=b for all t of the form
%
%       p(x,t,u) + q(x,t) * f(x,t,u,Du/Dx) = 0
%
%   q(x,t) is a diagonal matrix. The diagonal elements of q must be either
%   identically zero or never zero. Note that the boundary conditions are
%   expressed in terms of the flux rather than Du/Dx. Also, of the two
%   coefficients, only p can depend on u.
%
%   The input argument M defines the symmetry of the problem. PDEFUN, ICFUN,
%   and BCFUN are function handles.
%
%   [C,F,S] = PDEFUN(X,T,U,DUDX) evaluates the quantities defining the
%   differential equation. The input arguments are scalars X and T and
%   vectors U and DUDX that approximate the solution and its partial
%   derivative with respect to x, respectively. PDEFUN returns column
%   vectors: C (containing the diagonal of the matrix c(x,t,u,Dx/Du)),
%   F, and S (representing the flux and source term, respectively).
%
%   U = ICFUN(X) evaluates the initial conditions. For a scalar X, ICFUN
%   must return a column vector, corresponding to the initial values of
%   the solution components at X.
%
%   [PL,QL,PR,QR] = BCFUN(XL,UL,XR,UR,T) evaluates the components of the
%   boundary conditions at time T. XL and XR are scalars representing the
%   left and right boundary points. UL and UR are column vectors with the
%   solution at the left and right boundary, respectively. PL and QL are
%   column vectors corresponding to p and the diagonal of q, evaluated at
%   the left boundary, similarly PR and QR correspond to the right boundary.
%   When m > 0 and a = 0, boundedness of the solution near x = 0 requires
%   that the flux f vanish at a = 0. PDEPE imposes this boundary condition
%   automatically.
%
%   PDEPE returns values of the solution on a mesh provided as the input
%   array XMESH. The entries of XMESH must satisfy
%       a = XMESH(1) < XMESH(2) < ... < XMESH(NX) = b
%   for some NX >= 3. Discontinuities in c and/or s due to material
%   interfaces are permitted if the problem requires the flux f to be
%   continuous at the interfaces and a mesh point is placed at each
%   interface. The ODEs resulting from discretization in space are integrated
%   to obtain approximate solutions at times specified in the input array
%   TSPAN. The entries of TSPAN must satisfy
%       t0 = TSPAN(1) < TSPAN(2) < ... < TSPAN(NT) = tf
%   for some NT >= 3. The arrays XMESH and TSPAN do not play the same roles
%   in PDEPE: The time integration is done with an ODE solver that selects
%   both the time step and formula dynamically. The cost depends weakly on
%   the length of TSPAN. Second order approximations to the solution are made
%   on the mesh specified in XMESH. Generally it is best to use closely
%   spaced points where the solution changes rapidly. PDEPE does not select
%   the mesh in x automatically like it does in t; you must choose an
%   appropriate fixed mesh yourself. The discretization takes into account
%   the coordinate singularity at x = 0 when m > 0, so it is not necessary to
%   use a fine mesh near x = 0 for this reason. The cost depends strongly on
%   the length of XMESH.
%
%   The solution is returned as a multidimensional array SOL. UI = SOL(:,:,i)
%   is an approximation to component i of the solution vector u for
%   i = 1:npde. The entry UI(j,k) = SOL(j,k,i) approximates UI at
%   (t,x) = (TSPAN(j),XMESH(k)).
%
%   SOL = PDEPE(M,PDEFUN,ICFUN,BCFUN,XMESH,TSPAN,OPTIONS) solves as above
%   with default integration parameters replaced by values in OPTIONS, an
%   argument created with the ODESET function. Only some of the options of
%   the underlying ODE solver are available in PDEPE - RelTol, AbsTol,
%   NormControl, InitialStep, and MaxStep. See ODESET for details.
%
%   [SOL,TSOL,SOLE,TE,IE] = PDEPE(M,PDEFUN,ICFUN,BCFUN,XMESH,TSPAN,OPTIONS)
%   with the 'Events' property in OPTIONS set to a function handle EVENTS,
%   solves as above while also finding where event functions g(t,u(x,t))
%   are zero. For each function you specify whether the integration is to
%   terminate at a zero and whether the direction of the zero crossing
%   matters. These are the three column vectors returned by EVENTS:
%   [VALUE,ISTERMINAL,DIRECTION] = EVENTS(M,T,XMESH,UMESH).
%   XMESH contains the spatial mesh and UMESH is the solution at the mesh
%   points. Use PDEVAL to evaluate the solution between mesh points.
%   For the I-th event function: VALUE(I) is the value of the function,
%   ISTERMINAL(I) = 1 if the integration is to terminate at a zero of this
%   event function and 0 otherwise. DIRECTION(I) = 0 if all zeros are to be
%   computed (the default), +1 if only zeros where the event function is
%   increasing, and -1 if only zeros where the event function is decreasing.
%   Output TSOL is a column vector of times specified in TSPAN, prior to
%   first terminal event. SOL(j,:,:) is the solution at T(j). TE is a vector
%   of times at which events occur. SOLE(j,:,:) is the solution at TE(j) and
%   indices in vector IE specify which event occurred.
%
%   If UI = SOL(j,:,i) approximates component i of the solution at time TSPAN(j)
%   and mesh points XMESH, PDEVAL evaluates the approximation and its partial
%   derivative Dui/Dx at the array of points XOUT and returns them in UOUT
%   and DUOUTDX:  [UOUT,DUOUTDX] = PDEVAL(M,XMESH,UI,XOUT)
%   NOTE that the partial derivative Dui/Dx is evaluated here rather than the
%   flux. The flux is continuous, but at a material interface the partial
%   derivative may have a jump.
%
%   Example
%         x = linspace(0,1,20);
%         t = [0 0.5 1 1.5 2];
%         sol = pdepe(0,@pdex1pde,@pdex1ic,@pdex1bc,x,t);
%     solve the problem defined by the function pdex1pde with the initial and
%     boundary conditions provided by the functions pdex1ic and pdex1bc,
%     respectively. The solution is obtained on a spatial mesh of 20 equally
%     spaced points in [0 1] and it is returned at times t = [0 0.5 1 1.5 2].
%     Often a good way to study a solution is plot it as a surface and use
%     Rotate 3D. The first unknown, u1, is extracted from sol and plotted with
%         u1 = sol(:,:,1);
%         surf(x,t,u1);
%     PDEX1 shows how this problem can be coded using subfunctions. For more
%     examples see PDEX2, PDEX3, PDEX4, PDEX5.  The examples can be read
%     separately, but read in order they form a mini-tutorial on using PDEPE.
%
%   See also PDEVAL, ODE15S, ODESET, ODEGET, FUNCTION_HANDLE.

%   The spatial discretization used is that of R.D. Skeel and M. Berzins, A
%   method for the spatial discretization of parabolic equations in one space
%   variable, SIAM J. Sci. Stat. Comput., 11 (1990) 1-32. The time
%   integration is done with ODE15S. PDEPE exploits the capabilities this
%   code has for solving the differential-algebraic equations that arise when
%   there are elliptic equations and for handling Jacobians with specified
%   sparsity pattern.

%   Elliptic equations give rise to algebraic equations after discretization.
%   Initial values taken from the given initial conditions may not be
%   "consistent" with the discretization, so PDEPE may have to adjust these
%   values slightly before beginning the time integration. For this reason
%   the values output for these components at t0 may have a discretization
%   error comparable to that at any other time. No adjustment is necessary
%   for solution components corresponding to parabolic equations. If the mesh
%   is sufficiently fine, the program will be able to find consistent initial
%   values close to the given ones, so if it has difficulty initializing,
%   try refining the mesh.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2013 The MathWorks, Inc.
%   $Revision: 1.8.4.9.12.1 $  $Date: 2013/09/27 03:10:20 $

% Check inputs
if nargin < 7
  options = [];
  if nargin < 6
    error(message('MATLAB:pdepe:NotEnoughInputs'))
  end
end

switch m
case {0, 1, 2}
otherwise
  error(message('MATLAB:pdepe:InvalidM'))
end

nt = length(t);
if nt < 3
  error(message('MATLAB:pdepe:TSPANnotEnoughPts'))
end
if any(diff(t) <= 0)
  error(message('MATLAB:pdepe:TSPANnotIncreasing'))
end

xmesh = xmesh(:);
if m > 0 && xmesh(1) < 0
  error(message('MATLAB:pdepe:NegXMESHwithPosM'))
end
nx = length(xmesh);
if nx < 3
  error(message('MATLAB:pdepe:XMESHnotEnoughPts'))
end
if any(diff(xmesh) <= 0)
  error(message('MATLAB:pdepe:XMESHnotIncreasing'))
end

% Initialize the nx-1 points xi where functions will be evaluated
% and as many coefficients in the difference formulas as possible.
% For problems with coordinate singularity, use 'singular' formula
% on all subintervals.
singular = (xmesh(1) == 0 && m > 0);
xL = xmesh(1:end-1);
xR = xmesh(2:end);
xM = xL + 0.5*(xR-xL);
switch m
 case 0
  xi = xM;
  zeta = xi;
 case 1
  if singular
    xi = (2/3)*(xL.^2 + xL.*xR + xR.^2) ./ (xL+xR);
  else
    xi = (xR-xL) ./ log(xR./xL);
  end
  zeta = (xi .* xM).^(1/2);
 case 2
  if singular
    xi = (2/3)*(xL.^2 + xL.*xR + xR.^2) ./ (xL+xR);
  else
    xi = xL .* xR .* log(xR./xL) ./ (xR-xL);
  end
  zeta = (xL .* xR .* xM).^(1/3);
end
if singular
  xim = (zeta .^ (m+1))./xi;
else
  xim = xi .^ m;
end
zxmp1 = (zeta.^(m+1) - xL.^(m+1)) / (m+1);
xzmp1 = (xR.^(m+1) - zeta.^(m+1)) / (m+1);

% Form the initial values with a column of unknowns at each
% mesh point and then reshape into a column vector for dae.
temp = feval(ic,xmesh(1),varargin{:});
if size(temp,1) ~= length(temp)
  error(message('MATLAB:pdepe:InvalidOutputICFUN'))
end

npde = length(temp);
y0 = zeros(npde,nx);
y0(:,1) = temp;
for j = 2:nx
  y0(:,j) = feval(ic,xmesh(j),varargin{:});
end

% Classify the equations so that a constant, diagonal mass matrix
% can be formed. The entries of c are to be identically zero or
% vanish only at the entries of xmesh, so need be checked only at one
% point not in the mesh.
[U,Ux] = pdentrp(singular,m,xmesh(1),y0(:,1),xmesh(2),y0(:,2),xi(1));
[c,f,s] = feval(pde,xi(1),t(1),U,Ux,varargin{:});
if any([size(c,1),size(f,1),size(s,1)]~=npde)
  error(message('MATLAB:pdepe:UnexpectedOutputPDEFUN',sprintf('%d',npde)))
end
[pL,qL,pR,qR] = feval(bc,xmesh(1),y0(:,1),xmesh(nx),y0(:,nx),t(1),varargin{:});
if any([size(pL,1),size(qL,1),size(pR,1),size(qR,1)]~=npde)
  error(message('MATLAB:pdepe:UnexpectedOutputBCFUN',sprintf('%d',npde)))
end

D = ones(npde,nx);
D( c == 0, 2:nx-1) = 0;
if ~singular
  D( qL == 0, 1) = 0;
end
D( qR == 0, nx) = 0;
M = spdiags( D(:), 0, npde*nx, npde*nx);

% Construct block-diagonal pattern of Jacobian matrix
S = kron( spdiags(ones(nx,3),-1:1,nx,nx), ones(npde,npde));

% Extract relevant options and augment with new ones
reltol = odeget(options,'RelTol',[],'fast');
abstol = odeget(options,'AbsTol',[],'fast');
normcontrol = odeget(options,'NormControl',[],'fast');
initialstep = odeget(options,'InitialStep',[],'fast');
maxstep = odeget(options,'MaxStep',[],'fast');
events = odeget(options,'Events',[],'fast');  % events(m,t,xmesh,umesh)
hasEvents = ~isempty(events);
if hasEvents
  eventfcn = @(t,y) events(m,t,xmesh,y,varargin{:});
else
  eventfcn = [];
end
opts = odeset('RelTol',reltol,'AbsTol',abstol,'NormControl',normcontrol,...
              'InitialStep',initialstep,'MaxStep',maxstep,'Events',eventfcn,...
              'Mass',M,'JPattern',S);

% Call DAE solver
tfinal = t(end);
try
  if hasEvents
    [t,y,te,ye,ie] = ode15s(@pdeodes,t,y0(:),opts);
  else
    [t,y] = ode15s(@pdeodes,t,y0(:),opts);
  end
catch ME
  if strcmp(ME.identifier,'MATLAB:daeic12:IndexGTOne')
    error(message('MATLAB:pdepe:SpatialDiscretizationFailed'))
  else
    rethrow(ME);
  end
end

% Verify and process the solution
if t(end) ~= tfinal
  nt = length(t);
  if ~hasEvents || (te(end) ~= t(end))  % did not stop on a terminal event
    warning(message('MATLAB:pdepe:TimeIntegrationFailed',sprintf('%e',t(end))));
  end
end

sol = zeros(nt,nx,npde);
for i = 1:npde
  sol(:,:,i) = y(:,i:npde:end);
end
varargout{1} = sol;
if hasEvents % [sol,t,sole,te,ie] = pdepe(...)
  varargout{2} = t(:);
  sole = zeros(length(te),nx,npde);
  for i = 1:npde
    sole(:,:,i) = ye(:,i:npde:end);
  end
  varargout{3} = sole;
  varargout{4} = te(:);
  varargout{5} = ie(:);
end

%---------------------------------------------------------------------------
% Nested functions
%---------------------------------------------------------------------------

  function dudt = pdeodes(tnow,y)
  %PDEODES  Assemble the difference equations and evaluate the time derivative
  %   for the ODE system.

    u = reshape(y,npde,nx);
    up = zeros(npde,nx);
    [U,Ux] = pdentrp(singular,m,xmesh(1),u(:,1),xmesh(2),u(:,2),xi(1));
    [cL,fL,sL] = feval(pde,xi(1),tnow,U,Ux,varargin{:});

    %  Evaluate the boundary conditions
    [pL,qL,pR,qR] = feval(bc,xmesh(1),u(:,1),xmesh(nx),u(:,nx),tnow,varargin{:});

    %  Left boundary
    if singular
      denom = cL;
      denom(denom == 0) = 1;
      up(:,1) = (sL + (m+1) * fL / xi(1)) ./ denom;
    else
      up(:,1) = pL;
      idx = (qL ~= 0);
      denom = (qL(idx)/xmesh(1)^m) .* (zxmp1(1)*cL(idx));
      denom(denom == 0) = 1;
      up(idx,1) = ( pL(idx) + (qL(idx)/xmesh(1)^m) .* ...
                    (xim(1)*fL(idx) + zxmp1(1)*sL(idx))) ./ denom;
    end
    %  Interior points
    for ii = 2:nx-1
      [U,Ux] = pdentrp(singular,m,xmesh(ii),u(:,ii),xmesh(ii+1),u(:,ii+1),xi(ii));
      [cR,fR,sR] = feval(pde,xi(ii),tnow,U,Ux,varargin{:});

      denom = zxmp1(ii) * cR + xzmp1(ii-1) * cL;
      denom(denom == 0) = 1;
      up(:,ii) = ((xim(ii) * fR - xim(ii-1) * fL) + ...
                  (zxmp1(ii) * sR + xzmp1(ii-1) * sL)) ./ denom;

      cL = cR;
      fL = fR;
      sL = sR;
    end
    %  Right boundary
    up(:,nx) = pR;
    idx = (qR ~= 0);
    denom = -(qR(idx)/xmesh(nx)^m) .* (xzmp1(nx-1)*cL(idx));
    denom(denom == 0) = 1;
    up(idx,nx) = ( pR(idx) + (qR(idx)/xmesh(nx)^m) .* ...
                   (xim(nx-1)*fL(idx) - xzmp1(nx-1)*sL(idx))) ./ denom;

    dudt = up(:);
  end  % pdeodes

% --------------------------------------------------------------------------

end  % pdepe

