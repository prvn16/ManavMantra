function sol = bvp5c(ode, bc, solinit, options)
%BVP5C  Solve boundary value problems for ODEs by collocation.     
%   SOL = BVP5C(ODEFUN,BCFUN,SOLINIT) integrates a system of ordinary
%   differential equations of the form y' = f(x,y) on the interval [a,b],
%   subject to general two-point boundary conditions of the form
%   bc(y(a),y(b)) = 0. ODEFUN and BCFUN are function handles. For a scalar X
%   and a column vector Y, ODEFUN(X,Y) must return a column vector representing
%   f(x,y). For column vectors YA and YB, BCFUN(YA,YB) must return a column 
%   vector representing bc(y(a),y(b)).  SOLINIT is a structure with fields  
%       x -- ordered nodes of the initial mesh with 
%            SOLINIT.x(1) = a, SOLINIT.x(end) = b
%       y -- initial guess for the solution with SOLINIT.y(:,i)
%            a guess for y(x(i)), the solution at the node SOLINIT.x(i)       
%
%   BVP5C produces a solution that is continuous on [a,b] and has a
%   continuous first derivative there. The solution is evaluated at points
%   XINT using the output SOL of BVP5C and the function DEVAL:
%   YINT = DEVAL(SOL,XINT). The output SOL is a structure with 
%       SOL.solver -- 'bvp5c'
%       SOL.x  -- mesh selected by BVP5C
%       SOL.y  -- approximation to y(x) at the mesh points of SOL.x
%       SOL.stats -- computational cost statistics (also displayed when 
%                    the 'Stats' option is set with BVPSET).
%
%   SOL = BVP5C(ODEFUN,BCFUN,SOLINIT,OPTIONS) solves as above with default
%   parameters replaced by values in OPTIONS, a structure created with the
%   BVPSET function. To reduce the run time greatly, use OPTIONS to supply 
%   a function for evaluating the Jacobian and/or vectorize ODEFUN. 
%   See BVPSET for details and SHOCKBVP for an example that does both.
%
%   Some boundary value problems involve a vector of unknown parameters p
%   that must be computed along with y(x):
%       y' = f(x,y,p)
%       0  = bc(y(a),y(b),p) 
%   For such problems the field SOLINIT.parameters is used to provide a guess
%   for the unknown parameters. On output the parameters found are returned
%   in the field SOL.parameters. The solution SOL of a problem with one set 
%   of parameter values can be used as SOLINIT for another set. Difficult BVPs 
%   may be solved by continuation: start with parameter values for which you can 
%   get a solution, and use it as a guess for the solution of a problem with 
%   parameters closer to the ones you want. Repeat until you solve the BVP 
%   for the parameters you want.
%
%   The function BVPINIT forms the guess structure in the most common 
%   situations:  SOLINIT = BVPINIT(X,YINIT) forms the guess for an initial 
%   mesh X as described for SOLINIT.x, and YINIT either a constant vector 
%   guess for the solution or a function handle. If YINIT is a function handle 
%   then for a scalar X, YINIT(X) must return a column vector, a guess for 
%   the solution at point x in [a,b]. If the problem involves unknown parameters
%   SOLINIT = BVPINIT(X,YINIT,PARAMS) forms the guess with the vector PARAMS of 
%   guesses for the unknown parameters.  
%
%   BVP5C solves a class of singular BVPs, including problems with 
%   unknown parameters p, of the form
%       y' = S*y/x + f(x,y,p)
%       0  = bc(y(0),y(b),p) 
%   The interval is required to be [0, b] with b > 0. 
%   Often such problems arise when computing a smooth solution of 
%   ODEs that result from PDEs because of cylindrical or spherical 
%   symmetry. For singular problems the (constant) matrix S is
%   specified as the value of the 'SingularTerm' option of BVPSET,
%   and ODEFUN evaluates only f(x,y,p). The boundary conditions
%   must be consistent with the necessary condition S*y(0) = 0 and
%   the initial guess should satisfy this condition.   
%    
%   BVP5C can solve multipoint boundary value problems.  For such problems
%   there are boundary conditions at points in [a,b]. Generally these points
%   represent interfaces and provide a natural division of [a,b] into regions.
%   BVP5C enumerates the regions from left to right (from a to b), with indices 
%   starting from 1.  In region k, BVP5C evaluates the derivative as 
%   YP = ODEFUN(X,Y,K).  In the boundary conditions function, 
%   BCFUN(YLEFT,YRIGHT), YLEFT(:,K) is the solution at the 'left' boundary
%   of region k and similarly for YRIGHT(:,K).  When an initial guess is
%   created with BVPINIT(XINIT,YINIT), XINIT must have double entries for 
%   each interface point. If YINIT is a function handle, BVPINIT calls 
%   Y = YINIT(X,K) to get an initial guess for the solution at X in region k. 
%   In the solution structure SOL returned by BVP5C, SOL.x has double entries 
%   for each interface point. The corresponding columns of SOL.y contain 
%   the 'left' and 'right' solution at the interface, respectively. 
%   See THREEBVP for an example of solving a three-point BVP.    
%
%   Example
%         solinit = bvpinit([0 1 2 3 4],[1 0]);
%         sol = bvp5c(@twoode,@twobc,solinit);
%     solve a BVP on the interval [0,4] with differential equations and 
%     boundary conditions computed by functions twoode and twobc, respectively.
%     This example uses [0 1 2 3 4] as an initial mesh, and [1 0] as an initial 
%     approximation of the solution components at the mesh points.
%         xint = linspace(0,4);
%         yint = deval(sol,xint);
%     evaluate the solution at 100 equally spaced points in [0 4]. The first
%     component of the solution is then plotted with 
%         plot(xint,yint(1,:));
%   For more examples see FSBVP, SHOCKBVP, MAT4BVP, EMDENBVP. To use the 
%   BVP5C solver, you must pass 'bvp5c' as input argument: 
%         fsbvp('bvp5c')
%
%   BVP5C is used exactly like BVP4C, but error tolerances do not mean the
%   same in the two solvers. If S(x) approximates the solution y(x), BVP4C 
%   controls the residual |S'(x) - f(x,S(x))|. This controls indirectly the 
%   true error |y(x) - S(x)|.  BVP5C controls the true error directly.
%   BVP5C is more efficient than BVP4C for small error tolerances.
%
%   See also BVP4C, BVPSET, BVPGET, BVPINIT, BVPXTEND, DEVAL, FUNCTION_HANDLE.
 
%   BVP5C is a finite difference code that implements the 4-stage Lobatto
%   IIIa formula.  This is a collocation formula and the collocation 
%   polynomial provides a C1-continuous solution that is fifth order
%   accurate uniformly in [a,b]. The formula is implemented as an implicit
%   Runge-Kutta formula.  BVP5C solves the algebraic equations directly;
%   BVP4C uses analytical condensation. BVP4C handles unknown parameters
%   directly; BVP5C augments the system with trivial differential equations
%   for unknown parameters.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2011 The MathWorks, Inc.
            
solver_name = 'bvp5c';    
    
% Check input arguments
if nargin < 3 
  error(message('MATLAB:bvp5c:NotEnoughInputs'))
elseif nargin < 4
  options = [];
end  

% Adjust status of warnings
warnoffId = { 'MATLAB:singularMatrix', 'MATLAB:nearlySingularMatrix'}; 
for warnidx = 1:length(warnoffId)    
  warnstat(warnidx) = warning('query',warnoffId{warnidx});
  warnoff(warnidx) = warnstat(warnidx);
  warnoff(warnidx).state = 'off';
end

% Validate arguments and options
[neqn,nparam,nregions,atol,rtol,Nmax,xyVectorized,printstats] = ...
    bvparguments(solver_name,ode,bc,solinit,options);

% Modify equations to accommodate unknown parameters
[ode,bc,jac,bcjac,Joptions,dBCoptions] = ...
    bvpfunctions(solver_name,ode,bc,options,neqn,nparam,nregions);

% Deal with a singular BVP.
[singularBVP,ode,jac,solinit,PBC] = ...
    bvpsingular(solver_name,solinit,ode,jac,options,neqn,nparam,nregions);

% Recognize a multipoint BVP
ismbvp = (nregions > 1);
MBVP = [];

% Adjust the problem to accommodate unknown parameters
if nparam > 0
  neqn = neqn + nparam;        
  ptol = rtol(ones(nparam,1)); 
  atol = [atol;ptol];
end

threshold = atol/rtol;

% Initialize counters (count test calls in BVPARGUMENTS)
nODEeval = 1; 
nBCeval = 1;  

% Four-stage Lobatto IIIa collocation formula (non-trivial coefficients only.)
sq5 = sqrt(5);
c = [ (5 - sq5)/10, (5 + sq5)/10];
A = [[(11 + sq5)/120,    (25 - sq5)/120, (25 - 13*sq5)/120, (-1 + sq5)/120]; ...
     [(11 - sq5)/120, (25 + 13*sq5)/120,    (25 + sq5)/120, (-1 - sq5)/120]; ...
     [         1/12,              5/12,              5/12            1/12 ]];
B = [[-(5+17*sq5)/10,   (5+sq5)/2,   (-5+3*sq5)/2, (5-3*sq5)/10]; ...
     [(-5+17*sq5)/10, -(5+3*sq5)/2,   (5-sq5)/2,   (5+3*sq5)/10]; ...
     [    -7,             5*sq5,      -5*sq5,           7      ]];
nstages = 3;  % The number of points per mesh subinterval.

% Constant matrices for the collocation Jacobian
bigA = kron(A,ones(neqn));
JacI = [1,-1, 0, 0;
        1, 0,-1, 0;
        1, 0, 0,-1];
bigI = kron(JacI,eye(neqn));

% Interpolate solution at collocation points
[X,Y] = interpGuess(solinit);
if ismbvp
  MBVP = updateMBVP(X);
end

% Algebraic solver parameters
maxNewtIter = 4;  
maxProbes = 4;    % weak line search 
needGlobalJacobian = true;
refinedMesh = false;

meshHistory = [0,0];         % Keep track of [N, maxerr], 
errorReductionGuard = 1e-4;  % to prevent mesh oscillations.

% Sample the residual at a single point while adapting the mesh,
% but use three samples during final solution verification stage.
solutionVerificationStage = false;

done = false;

% THE MAIN LOOP:
while ~done
  
  for iter = 1 : maxNewtIter	

    if ~refinedMesh
      F = odeFcn(X,Y);  
    end
    refinedMesh = false;
    [RHS,BCval] = colloc_RHS(X,Y,F);
    
    if needGlobalJacobian
      % setup and factor the global Jacobian            
      [dPHIdy,needSeparateBCs] = colloc_Jac(X,Y,F,BCval);   
      needGlobalJacobian = false;   
      singularJacobian = false;
            
      if needSeparateBCs
        % The BCs are not clearly separated.  Reorder the variables
        % to get a band matrix T*dPHIdy*T' = dPHIdy(p,p). Factor 
        % dPHIdy as T'*L*U*T and solve dPHIdy*f = X with
        % f = T' * (U \ (L \ (T * X)));
        rows = size(dPHIdy,1);
        p = zeros(1,rows);
        mid = round(rows/2);
        p(1:2:rows) = 1:mid;
        p(2:2:rows) = rows:-1:mid+1;
        [~,sp] = sort(p);
        T = sparse(sp,1:rows,ones(1,rows));
        dPHIdy = dPHIdy(p,p);
      else
        T = speye(size(dPHIdy));           
      end

      % Explicit row scaling        
      wt = max(abs(dPHIdy),[],2);      
      if any(wt == 0) || ~all(isfinite(nonzeros(dPHIdy)))
        singularJacobian = true;
      else
        D = spdiags(1 ./ wt,0,numel(wt),numel(wt));
        dPHIdy = D * dPHIdy; 
      end 
      
      % Find the Newton direction. Intercept singularity warnings.
      if ~singularJacobian
        [lastmsg,lastid] = lastwarn('');
        warning(warnoff);        
        
        % Find the Newton direction   
        [L,U,P] = lu(dPHIdy);         
        delY = T' * (U \ (L \ (P * (D * (T * RHS)))));              
        
        warning(warnstat);
        
        [msg,msgid] = lastwarn;
        if isempty(msg)
          lastwarn(lastmsg,lastid);
        elseif any(strcmp(msgid,warnoffId))        
          singularJacobian = true;  
        end          
      end            
      
      if singularJacobian 
        error(message('MATLAB:bvp5c:SingJac'));
      end                 
      
    else  % Jacobian reuse    
      
      % Find the Newton direction    
      delY = T' * (U \ (L \ (P * (D * (T * RHS)))));              
      
    end

    distY = norm(delY); 
    
    % weak line search with an affine-invariant stopping criterion
    lambda = 1;
    for probe = 1 : maxProbes     
      Ynew = Y - lambda*reshape(delY,neqn,[]); 
      if singularBVP     % Impose necessary BC, Sy(0) = 0.
        Ynew(1:neqn-nparam,1) = PBC*Ynew(1:neqn-nparam,1);
      end                  
      Fnew = odeFcn(X,Ynew);  
      RHSnew = colloc_RHS(X,Ynew,Fnew);
      
      distYnew = norm(U \ (L \ (P * (D * (T * RHSnew)))));
            
      if (distYnew < 0.9*distY)   
        break		
      else
        lambda = 0.5*lambda;		
      end
    end

    needGlobalJacobian = (distYnew > 0.1*distY);

    if distYnew < 0.1*rtol
      maxInterpResidual = colloc_maxresidual(X,Ynew,Fnew);   
      if maxInterpResidual < 0.1*rtol                    
        break
      end
    end

    Y = Ynew;  % Continue Newton iterations.
        
  end  % Newton iterations 

  Y = Ynew;
  F = Fnew;

  ymid = interpolateYmid(X,Y,F);
 
  if solutionVerificationStage
    % Use three error samples per mesh interval.
    nsamples = 3;
    res = residualEstimate(X,Y,ymid,F,nsamples);
  else
    % Use single error sample per mesh interrval.  
    nsamples = 1;
    res = residualEstimate(X,Y,ymid,F,nsamples);
    if max(res) < rtol
      % Enter the final verification stage.
      solutionVerificationStage = true;  
      % Compute the remaining two samples.
      nsamples = 2;
      res2 = residualEstimate(X,Y,ymid,F,nsamples);
      res = max(res,res2);
    end
  end
        
  if solutionVerificationStage && ( max(res) <= rtol)
    done = true;
  else
    [XX,YY,FF] = newSolutionProfile(X,Y,ymid,F,res);
    if numel(XX) > Nmax
      warning(message('MATLAB:bvp5c:RelTolNotMet', ...
          Nmax,numel(res)+1,sprintf('%g',max(res)),sprintf('%g',rtol))); 
      done = true;
    else
      refinedMesh = true;
      X = XX;
      Y = YY;
      F = FF;
      if ismbvp
        MBVP = updateMBVP(X);
      end
      needGlobalJacobian = true;	
    end
  end  
  
end  % while 
    
% Output solution structure
sol = outputSol(X,Y,F,ymid);

% Stats
if printstats 
  fprintf(getString(message('MATLAB:bvp5c:SolutionWasObtained',sprintf('%g',numel(sol.x)))));
  fprintf(getString(message('MATLAB:bvp5c:MaximumError',sprintf('%10.3e',max(res))))); 
  fprintf(getString(message('MATLAB:bvp5c:CallsToODEFunctionn',sprintf('%g',nODEeval)))); 
  fprintf(getString(message('MATLAB:bvp5c:CallsToBCFunctionn',sprintf('%g',nBCeval)))); 
end

sol.stats = struct('nmeshpoints',numel(sol.x),'maxerr',max(res),...
                   'nODEevals',nODEeval,'nBCevals',nBCeval);

%---------------------------------------------------------------------------
% Nested functions
%---------------------------------------------------------------------------
  
  function [X,Y] = interpGuess(sol)
  %INTERP_GUESS  Evaluate/interpolate the initial guess at collocation points.

    if ~isfield(sol,'solver')
      sol.solver = 'unknown';
    end
    
    if ismbvp      
      X = []; Y = [];
      mbcidx = find(diff(sol.x) == 0);
      Lidx = [1, mbcidx+1];
      Ridx = [mbcidx, length(sol.x)];
      for region = 1 : nregions
        xidx = Lidx(region):Ridx(region);
        xreg = sol.x(xidx);
        yreg = sol.y(:,xidx);
        [Xreg,Yreg] = interpGuess_region(sol,xreg,yreg,{region});
        X = cat(2,X,Xreg);
        Y = cat(2,Y,Yreg);
      end
    else 
      [X,Y] = interpGuess_region(sol,sol.x,sol.y,{});  
    end
  end  % interpGuess 
 
  %---------------------------------------------------------------------------  
  
  function [X,Y] = interpGuess_region(sol,sol_xreg,sol_yreg,region)
  % In a region, evaluate/interpolate the initial guess at collocation points.
    h = diff(sol_xreg);
    x0  = sol_xreg(1:end-1);  % left subinerval boundaries
    xc1 = x0 + c(1)*h;
    xc2 = x0 + c(2)*h;
    X = [x0; xc1; xc2];
    X = [X(:); sol_xreg(end)];    
    X = reshape(X,1,[]);
    
    y0 = sol_yreg(:,1:end-1);  % solution at left subinterval boundaries

    switch sol.solver
      case 'unknown'
        % linear interpolation between mesh points
        dely = diff(sol_yreg,1,2);
        yc1 = y0 + c(1)*dely;
        yc2 = y0 + c(2)*dely;
      case 'bvpinit'
        yinit = sol.yinit;
        if isa(yinit,'function_handle') 
          % evaluate the initial guess at collocation points
          yc1 = zeros(size(y0));
          yc2 = zeros(size(y0));
          for i = 1 : size(y0,2)
            yc1(:,i) = yinit(xc1(i),region{:});
            yc2(:,i) = yinit(xc2(i),region{:});      
          end  
        else % yinit is a constant guess
          yc1 = repmat(yinit(:),1,size(y0,2));
          yc2 = yc1;
        end
      otherwise
        % evaluate solution in SOL
        yc1 = deval(sol,xc1);
        yc2 = deval(sol,xc2);
    end  
    yend = sol_yreg(:,end);
    
    if nparam > 0 % augment y with unknown parameters
      params = repmat(sol.parameters(:),1,size(y0,2));
      y0  = [y0;params];
      yc1 = [yc1;params];
      yc2 = [yc2;params];
      yend = [yend; sol.parameters(:)];
    end    
    
    Y = [y0; yc1; yc2];
    Y = [Y(:); yend];
    Y = reshape(Y,neqn,[]);            
  end  % interpGuess_region 

  %---------------------------------------------------------------------------
  
  function F = odeFcn(X,Y)
  %ODE_FCN  Evaluate the ODE function for all points in X,Y.
    if ismbvp          
      F = zeros(size(Y));
      for region = 1 : nregions
        xidx = MBVP.LBCidx(region):MBVP.RBCidx(region);
        xreg = X(xidx);
        yreg = Y(:,xidx);            
        F(:,xidx) = odeFcn_region(xreg,yreg,{region});
      end      
    else
      F = odeFcn_region(X,Y,{});
    end          
  end  % odeFcn  
  
  %---------------------------------------------------------------------------
  
  function F = odeFcn_region(X,Y,region)
  % In a region, evaluate the ODE function for all points in X,Y.
    if ~ismbvp
      region = {};
    end
    if xyVectorized
      F = ode(X,Y,region{:});
      nODEeval = nODEeval + 1; % stats
    else  
      F = zeros(size(Y));
      for i = 1 : numel(X)
        F(:,i) = ode(X(i),Y(:,i),region{:});
      end 
      nODEeval = nODEeval + numel(X); % stats
    end
  end  % odeFcn_region
        
  %---------------------------------------------------------------------------
  
  function [Jn,Jnc1,Jnc2,Jnp1] = odeJac_region(x,y,f,Jpropagated,region)
  % In a region, compute the ODE Jacobian at points in a mesh interval.          
    if isempty(jac)
      if isempty(Jpropagated)
        [Jn,Joptions.fac,~,nF] = ...
            odenumjac(ode,{x(1),y(:,1),region{:}},f(:,1),Joptions);
        nODEeval = nODEeval + nF;
      else
        Jn = Jpropagated;          
      end   
      [Jnp1,Joptions.fac,~,nF] = ...
          odenumjac(ode,{x(4),y(:,4),region{:}},f(:,4),Joptions);  
      nODEeval = nODEeval + nF;
      if norm(Jnp1 - Jn,1) <= 0.25*(norm(Jnp1,1) + norm(Jn,1)) 
        Jnc1 = (1 - c(1))*Jn + c(1)*Jnp1;
        Jnc2 = (1 - c(2))*Jn + c(2)*Jnp1;
      else
        [Jnc1,Joptions.fac,~,nF1] = ...
            odenumjac(ode,{x(2),y(:,2),region{:}},f(:,2),Joptions);
        [Jnc2,Joptions.fac,~,nF2] = ...
            odenumjac(ode,{x(3),y(:,3),region{:}},f(:,3),Joptions);
        nODEeval = nODEeval + nF1 + nF2;
      end
    elseif isnumeric(jac)
      Jn   = jac;
      Jnc1 = jac;
      Jnc2 = jac;
      Jnp1 = jac;          
    else
      if isempty(Jpropagated)
        Jn = jac(x(1),y(:,1),region{:});
      else
        Jn = Jpropagated;          
      end    
      Jnc1 = jac(x(2),y(:,2),region{:});
      Jnc2 = jac(x(3),y(:,3),region{:});
      Jnp1 = jac(x(4),y(:,4),region{:});          
    end  
  end  % odeJac_region  
    
  %---------------------------------------------------------------------------
  
  function res = bcaux(Ya,Yb)
  %BCAUX  Reshape the arguments for the BC function.
    local_ya = reshape(Ya,neqn,[]);
    local_yb = reshape(Yb,neqn,[]);
    res = bc(local_ya,local_yb);
  end  % bcaux
  
  %---------------------------------------------------------------------------
  
  function [dBCdya,dBCdyb] = bcJac(ya,yb,bcVal)
  %BC_JAC  Compute the BC Jacobian.
    if isempty(bcjac)
      dBCoptions.diffvar = 1;  % d(bc(ya,yb))/dya
      dBCoptions.fac = dBCoptions.fac_dya;
      [dBCdya,dBCoptions.fac_dya,~,nF] = ...
          odenumjac(@bcaux,{ya(:),yb(:)},bcVal,dBCoptions);      
      nBCeval = nBCeval + nF;
      dBCoptions.diffvar = 2;  % d(bc(ya,yb))/dyb
      dBCoptions.fac = dBCoptions.fac_dyb;
      [dBCdyb,dBCoptions.fac_dyb,~,nF] = ...
          odenumjac(@bcaux,{ya(:),yb(:)},bcVal,dBCoptions);
      nBCeval = nBCeval + nF;
    elseif iscell(bcjac)
      dBCdya = bcjac{1};
      dBCdyb = bcjac{2};
    else
      [dBCdya,dBCdyb] = bcjac(ya,yb);
    end  
  end  % bcJac

  %---------------------------------------------------------------------------
  
  function [RHS,RHSbc]= colloc_RHS(X,Y,F)   
  %COLLOC_RHS  Evaluate the system of collocation equations.  
  %   Separately return the residual in the boundary conditions.  
      
    % boundary conditions 
    if ismbvp
      ya = Y(:,MBVP.LBCidx);
      yb = Y(:,MBVP.RBCidx);        
    else    
      ya = Y(:,1);
      yb = Y(:,end);        
    end
    RHSbc = bc(ya,yb);
    nBCeval = nBCeval + 1;

    % collocation equations
    [xreg,yreg,freg] = getRegionData(1,X,Y,F);  
    RHSode = colloc_RHS_region(xreg,yreg,freg);

    for region = 2 : nregions  % MBVP
      [xreg,yreg,freg] = getRegionData(region,X,Y,F);  
      RHSreg = colloc_RHS_region(xreg,yreg,freg);
      RHSode = cat(1,RHSode,RHSreg);
    end    
    
    RHS = [RHSbc(:); RHSode(:)];      
  end  % colloc_RHS

  %---------------------------------------------------------------------------
    
  function RHSode = colloc_RHS_region(X,Y,F)
  % In a region, evaluate the system of collocation equations.  
    h = diff(X(1:nstages:end));    
    RHSode = zeros(neqn,numel(X)-1);
    
    idx = 0;
    for i = 1 : numel(h)
      ynn = Y(:, idx + ones(1,nstages));
      ync = Y(:, idx+2 : idx+nstages+1);
      
      hi = h(i);
      hA = hi*A;
      K = F(:, idx+1 : idx+nstages+1);
      
      % Form the residual in the Runge-Kutta formulas (collocation 
      % equations) in terms of the intermediate solution values.
      RHSode(:, idx+1 : idx+nstages) = ynn + K*hA' - ync;
                 
      idx = idx + nstages;
    end  
    
    RHSode = RHSode(:);
  end  % colloc_RHS_region
        
  %---------------------------------------------------------------------------
    
  function [Jac,doSeparateBCs] = colloc_Jac(X,Y,F,bcVal)           
  %COLLOC_JAC  Form the global Jacobian of the collocation equations.  

    if isempty(jac)
      Joptions.fac = [];  
    end  

    doSeparateBCs = false; % Reorder Jacobian rows-columns to get a band matrix
    
    % BC Jacobian
    JACbcI = zeros(neqn*nregions,2*neqn*nregions);
    JACbcJ = zeros(neqn*nregions,2*neqn*nregions);
    JACbcV = zeros(neqn*nregions,2*neqn*nregions); 
    hblock = neqn*nregions;
    lblock = neqn;
    blockI = repmat(transpose(1:hblock),1,lblock);
    blockJ = repmat(1:lblock,hblock,1);

    idx = 0;
    if ismbvp
      ya = Y(:,MBVP.LBCidx);
      yb = Y(:,MBVP.RBCidx);        
      [JACbcL, JACbcR] = bcJac(ya,yb,bcVal);                                                       
      
      colidx = 0;
      for region = 1 : nregions            

        % Left BC
        JACbcV(:,idx+1:idx+lblock) = JACbcL(:,colidx+1:colidx+neqn);
        JACbcI(:,idx+1:idx+lblock) = blockI;
        JACbcJ(:,idx+1:idx+lblock) = blockJ + (MBVP.LBCidx(region) - 1)*neqn;
        idx = idx + lblock;
        
        % Right BC
        JACbcV(:,idx+1:idx+lblock) = JACbcR(:,colidx+1:colidx+neqn);
        JACbcI(:,idx+1:idx+lblock) = blockI;
        JACbcJ(:,idx+1:idx+lblock) = blockJ + (MBVP.RBCidx(region) - 1)*neqn;
        idx = idx + lblock;
        
        colidx = colidx + neqn;
      end 
      
    else % two-point BVP
      ya = Y(:,1);
      yb = Y(:,end);                
      [JACbcL, JACbcR] = bcJac(ya,yb,bcVal);                                

      % Check if BCs can be 'separated' by reordering the Jacobian
      doSeparateBCs = any( any(JACbcL,2) & any(JACbcR,2) );
            
      % Left BC
      JACbcV(:,idx+1:idx+lblock) = JACbcL;
      JACbcI(:,idx+1:idx+lblock) = blockI;
      JACbcJ(:,idx+1:idx+lblock) = blockJ;
      idx = idx + lblock;
      blockJ = blockJ + numel(Y)-neqn;
      
      % Right BC
      JACbcV(:,idx+1:idx+lblock) = JACbcR;
      JACbcI(:,idx+1:idx+lblock) = blockI;
      JACbcJ(:,idx+1:idx+lblock) = blockJ;
      
    end
    
    % ODE Jacobian
    if ismbvp

      % Provide storage for non-zero entries of global Jacobian
      ncols = sum(MBVP.RBCidx - MBVP.LBCidx)/nstages*(nstages+1)*neqn;   
      JACodeI = zeros(nstages*neqn,ncols);
      JACodeJ = zeros(nstages*neqn,ncols);
      JACodeV = zeros(nstages*neqn,ncols);              
        
      idx = 0;      
      rowOffset = 0;
      colOffset = 0;
      for region = 1 : nregions    
          
        % Evaluate non-zero entries of regional Jacobian  
        [xreg,yreg,freg] = getRegionData(region,X,Y,F);
        [JACregI,JACregJ,JACregV] = colloc_JacODE_region(xreg,yreg,freg,{region}); 
        
        % Write into the global Jacobian
        ncols = size(JACregI,2);                    
        JACodeV(:,idx+1:idx+ncols) = JACregV;
        JACodeI(:,idx+1:idx+ncols) = JACregI + rowOffset;
        JACodeJ(:,idx+1:idx+ncols) = JACregJ + colOffset;
        
        idx = idx + ncols;
        rowOffset = (MBVP.RBCidx(region)-region)*neqn;
        colOffset = MBVP.RBCidx(region)*neqn;
      end                                
            
    else  % two-point BVP

      [JACodeI,JACodeJ,JACodeV] = colloc_JacODE_region(X,Y,F,{});                     
        
    end    
    
    % Final assembly of the collocation Jacobian
    Jac = [ sparse(JACbcI,JACbcJ,JACbcV); ...
            sparse(JACodeI,JACodeJ,JACodeV) ];    
        
  end  % colloc_Jac 
  
  %---------------------------------------------------------------------------

  function [JacI,JacJ,JacV] = colloc_JacODE_region(X,Y,F,region)           
  % In a region, form the Jacobian of collocation equations.

    h = diff(X(1:nstages:end));    

    blockh = neqn*nstages;
    blockw = neqn*(nstages+1);
    blockI = repmat((1:blockh)',1,blockw);
    blockJ = repmat((1:blockw),blockh,1);
    JacI = zeros(blockh,blockw*numel(h));
    JacJ = zeros(blockh,blockw*numel(h));
    JacV = zeros(blockh,blockw*numel(h));

    idx = 0;
    xidx = 0;
    Jnp1 = [];
    for i = 1 : numel(h)

      x = X(  xidx+1 : xidx+nstages+1);
      y = Y(:,xidx+1 : xidx+nstages+1);
      f = F(:,xidx+1 : xidx+nstages+1);
      xidx = xidx + nstages;

      % Evaluate Jacobians
      [Jn,Jnc1,Jnc2,Jnp1] = odeJac_region(x,y,f,Jnp1,region);  
      
      % Assembly a non-zero block for global Jacobian
      hJ = h(i)*[Jn,Jnc1,Jnc2,Jnp1];
      bigJ = [hJ;hJ;hJ];
      
      % Write block into the global Jacobian
      JacV(:,idx+1:idx+blockw) = bigI + bigA.*bigJ;
      JacI(:,idx+1:idx+blockw) = blockI;
      JacJ(:,idx+1:idx+blockw) = blockJ;
      
      idx = idx + blockw;
      blockI = blockI + blockh;
      blockJ = blockJ + blockh;
                  
    end                  
    
  end  % colloc_JacODE_region
   
  %---------------------------------------------------------------------------

  function maxInterpResidual = colloc_maxresidual(X,Y,F)   
  %COLLOC_MAXRESIDUAL  Compute max residual in the collocation equations. 

    [xreg,yreg,freg] = getRegionData(1,X,Y,F);            
    maxInterpResidual = colloc_maxresidual_region(xreg,yreg,freg);          
      
    for region = 2 : nregions  % MBVP      
      [xreg,yreg,freg] = getRegionData(region,X,Y,F);
      regionInterpResidual = colloc_maxresidual_region(xreg,yreg,freg);
      maxInterpResidual = max(maxInterpResidual,regionInterpResidual);
    end  
    
  end  % colloc_maxresidual
  
  %---------------------------------------------------------------------------

  function maxInterpResidual = colloc_maxresidual_region(X,Y,F)   
  % In a region, compute max residual in the collocation equations.

    maxInterpResidual = 0;
      
    h = diff(X(1:nstages:end));    
    thresh = threshold(:,ones(1,nstages));
      
    idx = 0;
    for i = 1 : numel(h)        
      ync = Y(:,  idx+2 : idx+nstages+1);      
      K   = F(:,  idx+1 : idx+nstages+1);
      
      % Form the residual in the collocation equations in terms of the 
      % intermediate derivative values and compute a weighted norm scaled
      % by the mesh spacing. 
      K1 = K(:,1);   
      Boh = B/h(i);
      K2_4 = [ -sq5/5*K1, sq5/5*K1, -K1] + Y(:,idx+1:idx+4)*Boh';
      
      residual = K2_4 - K(:,2:4);
      
      wtdRes = residual ./ max(abs(ync),thresh); 
      normRes = max(max(abs(wtdRes)));    
      scaledRes = abs(h(i)) * normRes;
      
      maxInterpResidual = max(maxInterpResidual,scaledRes);
      
      idx = idx + nstages;
    end            
    
  end  % colloc_maxresidual_region
  
  %---------------------------------------------------------------------------  

  function ymid = interpolateYmid(X,Y,F)   
  %INTERPOLATE_YMID  Interpolate Y at the midpoints of mesh subintervals.  

    [xreg,yreg,freg] = getRegionData(1,X,Y,F);
    ymid = interpolateYmid_region(xreg,yreg,freg);    
    
    for region = 2 : nregions  % MBVP      
      [xreg,yreg,freg] = getRegionData(region,X,Y,F);
      ymidreg = interpolateYmid_region(xreg,yreg,freg);          
      ymid = cat(2,ymid,zeros(neqn,1),ymidreg);   % pad with zeros      
    end          
      
  end  % interpolateYmid

  %---------------------------------------------------------------------------
     
  function ymid = interpolateYmid_region(X,Y,F)   
  % In a region, interpolate Y at the midpoints of mesh subintervals.
    h = diff(X(1:nstages:end));
    y = Y(:,1:nstages:end);
    K1 = F(:,1:nstages:end);
    K2 = F(:,2:nstages:end);
    K3 = F(:,3:nstages:end);
    ymid = y(:,1:end-1) + ...
           ( 17/192*K1(:,1:end-1) + (40+15*sq5)/192*K2 + ...
             (40-15*sq5)/192*K3 - 1/192*K1(:,2:end)) * ...
           spdiags(h(:),0,numel(h),numel(h));  
  end  % interpolateYmid_region

  %---------------------------------------------------------------------------
  
  function res = residualEstimate(X,Y,Ymid,F,nsamples)   
  %RESIDUAL_ESTIMATE  Estimate the residual in each mesh subinterval.

    [xreg,yreg,freg,ymidreg] = getRegionData(1,X,Y,F,Ymid);      
    res = residualEstimate_region(xreg,yreg,ymidreg,freg,nsamples,{1});
    
    for region = 2 : nregions  % MBVP          
      [xreg,yreg,freg,ymidreg] = getRegionData(region,X,Y,F,Ymid);          
      res_reg = residualEstimate_region(xreg,yreg,ymidreg,freg,nsamples,{region});          
      res = cat(2,res,0,res_reg);  % pad with 0
    end
    
  end  % residualEstimate
  
  %---------------------------------------------------------------------------  

  function res = residualEstimate_region(X,Y,ymid,F,nsamples,region)   
  % In a region, estimate the residual in each mesh subinterval.
            
  % Compute the max norm of the residual at Cres points in each subinterval.
  % The norm is computed with the value of the solution (and thresh) as weights.
  % When we trust the asymptotic behavior, the residual is only sampled at
  % the midpoint. Otherwise, the residual is sampled at its three local max.
  % ymid is the solution at midpoints.      
    switch nsamples
      case 1
        cres = 1/2;
      case 2
        cres = [ 1/2 - sqrt(15)/10, 1/2 + sqrt(15)/10];
      case 3
        cres = [ 1/2 - sqrt(15)/10, 1/2, 1/2 + sqrt(15)/10];      
    end  
        
    x = X(1:nstages:end);
    y = Y(:,1:nstages:end);
    yp = F(:,1:nstages:end);
    
    h = diff(x);

    thresh = threshold(:,ones(1,numel(cres)));
    res = zeros(size(h));
    
    for i = 1 : numel(h)
      xres = x(i) + cres*h(i);
      [yres,ypres] = ntrp4h(xres,x(i),y(:,i),x(i+1),y(:,i+1),...
                            ymid(:,i),yp(:,i),yp(:,i+1));
      residual = ypres - odeFcn_region(xres,yres,region);  
            
      wtdRes = residual ./ max(abs(yres),thresh); 
      normRes = max(max(abs(wtdRes)));         
      scaledRes = abs(h(i)) * normRes;      
      
      res(i) = scaledRes;
    end            
  end  % residualEstimate_region
      
  %---------------------------------------------------------------------------
  
  function [XX,YY,FF] = newSolutionProfile(X,Y,Ymid,F,errEst)
  %NEW_SOLUTION_PROFILE  Redistribute mesh points and approximate the solution.

    % Detect mesh oscillations: Was there a mesh with 
    % the same number of nodes and a similar residual? 
    % If so, only allow for adding mesh points.
    nintervals = length(errEst);    
    maxerr = max(errEst);    
    idx = meshHistory(:,1) == nintervals;  % idx could be empty
    errorReduction = abs(meshHistory(idx,2) - maxerr)/maxerr; 
    oscLikely = any( errorReduction < errorReductionGuard);    

    meshHistory(end+1,:) = [nintervals,maxerr];
    canRemovePoints = ~oscLikely;                

    % modify the mesh, interpolate the solution    
    [xreg,yreg,freg,ymidreg,errEstReg] = getRegionData(1,X,Y,F,Ymid,errEst);
    [XX,YY,FF] = newSolutionProfile_region(xreg,yreg,ymidreg,freg,errEstReg,...
                                           {1},canRemovePoints);
    
    for region = 2 : nregions  % MBVP        
      [xreg,yreg,freg,ymidreg,errEstReg] = getRegionData(region,X,Y,F,Ymid,errEst);        
      [xxreg,yyreg,ffreg] = ...
          newSolutionProfile_region(xreg,yreg,ymidreg,freg,errEstReg,...
                                    {region},canRemovePoints);      
      XX = cat(2,XX,xxreg);
      YY = cat(2,YY,yyreg);
      FF = cat(2,FF,ffreg);          
    end      
      
  end  % newSolutionProfile  
        
  %---------------------------------------------------------------------------  
  
  function [XX,YY,FF] = newSolutionProfile_region(X,Y,ymid,F,errEst,region,...
                                                  canRemovePoints)
  % In a region, redistribute mesh points and approximate the solution.

    pow = 5;
    
    % extract the derivative at mesh points 
    yp = F(:,1:nstages:end);
    
    XX(1) = X(1);
    YY(:,1) = Y(:,1);
    FF(:,1) = F(:,1);
    
    dirx = sign(X(end)-X(1));
    xidx = 1;
    i = 1;
    
    while i <= numel(errEst)
        
      if errEst(i) <= rtol
          
        if canRemovePoints && ...
                ((i+2) <= numel(errEst)) && all(errEst(i:i+2) < 0.1*rtol)
          % consider consolidating mesh intervals
          
          xi = X(xidx);
          yi = Y(:,xidx);
          xip1 = X(xidx+nstages);
          yip1 = Y(:,xidx+nstages);
          xip2 = X(xidx+2*nstages);
          yip2 = Y(:,xidx+2*nstages);   
          xip3 = X(xidx+3*nstages);
          yip3 = Y(:,xidx+3*nstages);   
          fip3 = F(:,xidx+3*nstages);   
          hnew = (xip3 - xi)/2;
          
          % predict new residuals
          C1 = errEst(i)   / abs(xip1-xi)^pow;
          C2 = errEst(i+1) / abs(xip2-xip1)^pow;
          C3 = errEst(i+2) / abs(xip3-xip2)^pow;
          predEst = max([C1,C2,C3])*abs(hnew)^pow;
          
          if predEst < 0.5 * rtol  % replace 3 intervals with 2                  
            xx = xi + hnew*[c,1,(1+c)];
            yy = zeros(neqn,numel(xx));
            % interpolate xx from xi,xip1; then from xip1,xip2; then from xip2,xip3
            idx = find(dirx*(xx - xip1) <= 0); 
            if ~isempty(idx)
              yy(:,idx) = ntrp4h(xx(idx),xi,yi,xip1,yip1,...
                                 ymid(:,i),yp(:,i),yp(:,i+1));  
            end
            idx = find( (dirx*(xx -xip1) > 0) & (dirx*(xx - xip2) <= 0)); 
            if ~isempty(idx)
              yy(:,idx) = ntrp4h(xx(idx),xip1,yip1,xip2,yip2,...
                                 ymid(:,i+1),yp(:,i+1),yp(:,i+2));  
            end
            idx = find( dirx*(xx - xip2) > 0);
            if ~isempty(idx)
              yy(:,idx) = ntrp4h(xx(idx),xip2,yip2,xip3,yip3,...
                                 ymid(:,i+2),yp(:,i+2),yp(:,i+3));  
            end
            ff = odeFcn_region(xx,yy,region);
            
            xx(  end+1) = xip3;
            yy(:,end+1) = yip3;
            ff(:,end+1) = fip3;
            
            i = i + 3;
            xidx = xidx + 3*nstages;            
            
          else                      
            xx = X(   xidx+1 : xidx+nstages);
            yy = Y(:, xidx+1 : xidx+nstages);
            ff = F(:, xidx+1 : xidx+nstages);
            i = i + 1;
            xidx = xidx + nstages;                             
            
          end
                      
        else
          xx = X(   xidx+1 : xidx+nstages);
          yy = Y(:, xidx+1 : xidx+nstages);
          ff = F(:, xidx+1 : xidx+nstages);
          i = i + 1;
          xidx = xidx + nstages;       
                  
        end    
        
      else  % errEst(i) > rtol
        % split mesh interval  
        xi = X(xidx);
        yi = Y(:,xidx);   
        xip1 = X(  xidx+nstages);
        yip1 = Y(:,xidx+nstages);
        fip1 = F(:,xidx+nstages);
        
        if errEst(i) > 250 * rtol
          % split into three -- introduce two points
          hnew = (xip1 - xi)/3;
          xx = xi + hnew*[c,1,(1+c),2,(2+c)];            
        else
          % split into two -- introduce one point
          hnew = (xip1 - xi)/2;
          xx = xi + hnew*[c,1,(1+c)];
        end    
        yy = ntrp4h(xx,xi,yi,xip1,yip1,ymid(:,i),yp(:,i),yp(:,i+1));  
        ff =  odeFcn_region(xx,yy,region);        
        xx(  end+1) = xip1;
        yy(:,end+1) = yip1;
        ff(:,end+1) = fip1; 
        i = i + 1;
        xidx = xidx + nstages;
      end  
      XX(   end+1 : end+numel(xx)) = xx;
      YY(:, end+1 : end+numel(xx)) = yy;
      FF(:, end+1 : end+numel(xx)) = ff;
    end
    
  end  % newSolutionProfile_region  

  %---------------------------------------------------------------------------

  function sol = outputSol(X,Y,F,ymid)
  %OUTPUT_SOL  Assembly the solution structure.      
    sol.solver = solver_name;

    x = reshape(X,1,[]);
    y = reshape(Y,neqn,[]);
    
    if nparam > 0
      neqn = neqn - nparam;
      parameters = y( neqn+1 : neqn+nparam, 1);
      sol.parameters = parameters;
    end
            
    [xreg,yreg,freg,ymidreg] = getRegionData(1,x,y,F,ymid);      
    [xout,yout,ypout,ymidout] = outputData(xreg,yreg,freg,ymidreg);                                                                      
    
    for region = 2 : nregions   % MBVP          
      [xreg,yreg,freg,ymidreg] = getRegionData(region,x,y,F,ymid);          
      [xoutreg,youtreg,ypoutreg,ymidoutreg] = outputData(xreg,yreg,freg,ymidreg);                                                                            
      xout = cat(2,xout,xoutreg);
      yout = cat(2,yout,youtreg);
      ypout = cat(2,ypout,ypoutreg);
      % add zeros for internal interface intervals 
      ymidout = cat(2,ymidout,zeros(neqn,1),ymidoutreg);  
    end
                
    sol.x = xout;
    sol.y = yout;

    sol.idata.ymid = ymidout;          
    sol.idata.yp = ypout;
  end  % outputSol    
  
  %---------------------------------------------------------------------------
  
  function [xout,yout,ypout,ymidout] = outputData(x,y,f,ymid)
  %OUTPUT_DATA  Prepare data for the solution structure.      
    xout = x(1:nstages:end);
    yout = y(1:neqn,1:nstages:end);    
    ypout   = f(1:neqn,1:nstages:end);
    ymidout = ymid(1:neqn,:);    
  end  % outputData
  
  %---------------------------------------------------------------------------

  function MBVP = updateMBVP(X)
  %UPDATE_MBVP  Update indices of the internal boundary points for MBVPs.

    idx = find(diff(X) == 0);
    MBVP.LBCidx = [1, idx+1];        % Index of left boundary points in X
    MBVP.RBCidx = [idx, length(X)];  % Index of right boundary points in X

    % Index of mesh intervals corresponding to the internal interfaces
    MBVP.MIDidx = [0, (MBVP.RBCidx - (1:nregions))/nstages + (1:nregions)];    
  end  % updateMBVP

  %---------------------------------------------------------------------------

  function [xreg,yreg,freg,ymidreg,errest] = getRegionData(region,X,Y,F,Ymid,ErrEst)
  %GET_REGION_DATA  Extract mesh points and solution data for a given region.
    if ismbvp
      xidx = MBVP.LBCidx(region):MBVP.RBCidx(region);
      xreg = X(xidx);
      yreg = Y(:,xidx);
      freg = F(:,xidx);        
      if nargout > 3
        mididx = MBVP.MIDidx(region)+1:MBVP.MIDidx(region+1)-1;
        ymidreg = Ymid(:,mididx);
        if nargout > 4
          errest = ErrEst(:,mididx);
        end
      end
    else  % pass through for two-point BVPs
      xreg = X;
      yreg = Y;
      freg = F;
      if nargout > 3
        ymidreg = Ymid;
        if nargout > 4
          errest = ErrEst;
        end
      end
    end
    
  end  % getRegionData
 
%---------------------------------------------------------------------------
  
end  % bvp5c
