function sol = bvp4c(ode, bc, solinit, options, varargin)
%BVP4C  Solve boundary value problems for ODEs by collocation.     
%   SOL = BVP4C(ODEFUN,BCFUN,SOLINIT) integrates a system of ordinary
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
%   BVP4C produces a solution that is continuous on [a,b] and has a
%   continuous first derivative there. The solution is evaluated at points
%   XINT using the output SOL of BVP4C and the function DEVAL:
%   YINT = DEVAL(SOL,XINT). The output SOL is a structure with 
%       SOL.solver -- 'bvp4c'
%       SOL.x  -- mesh selected by BVP4C
%       SOL.y  -- approximation to y(x) at the mesh points of SOL.x
%       SOL.yp -- approximation to y'(x) at the mesh points of SOL.x
%       SOL.stats -- computational cost statistics (also displayed when 
%                    the 'Stats' option is set with BVPSET).
%
%   SOL = BVP4C(ODEFUN,BCFUN,SOLINIT,OPTIONS) solves as above with default
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
%   BVP4C solves a class of singular BVPs, including problems with 
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
%   BVP4C can solve multipoint boundary value problems.  For such problems
%   there are boundary conditions at points in [a,b]. Generally these points
%   represent interfaces and provide a natural division of [a,b] into regions.
%   BVP4C enumerates the regions from left to right (from a to b), with indices 
%   starting from 1.  In region k, BVP4C evaluates the derivative as 
%   YP = ODEFUN(X,Y,K).  In the boundary conditions function, 
%   BCFUN(YLEFT,YRIGHT), YLEFT(:,K) is the solution at the 'left' boundary
%   of region k and similarly for YRIGHT(:,K).  When an initial guess is
%   created with BVPINIT(XINIT,YINIT), XINIT must have double entries for 
%   each interface point. If YINIT is a function handle, BVPINIT calls 
%   Y = YINIT(X,K) to get an initial guess for the solution at X in region k. 
%   In the solution structure SOL returned by BVP4C, SOL.x has double entries 
%   for each interface point. The corresponding columns of SOL.y contain 
%   the 'left' and 'right' solution at the interface, respectively. 
%   See THREEBVP for an example of solving a three-point BVP.
%
%   Example
%         solinit = bvpinit([0 1 2 3 4],[1 0]);
%         sol = bvp4c(@twoode,@twobc,solinit);
%     solve a BVP on the interval [0,4] with differential equations and 
%     boundary conditions computed by functions twoode and twobc, respectively.
%     This example uses [0 1 2 3 4] as an initial mesh, and [1 0] as an initial 
%     approximation of the solution components at the mesh points.
%         xint = linspace(0,4);
%         yint = deval(sol,xint);
%     evaluate the solution at 100 equally spaced points in [0 4]. The first
%     component of the solution is then plotted with 
%         plot(xint,yint(1,:));
%   For more examples see TWOBVP, FSBVP, SHOCKBVP, MAT4BVP, EMDENBVP, THREEBVP.
%
%   See also BVP5C, BVPSET, BVPGET, BVPINIT, BVPXTEND, DEVAL, FUNCTION_HANDLE.
 
%   BVP4C is a finite difference code that implements the 3-stage Lobatto
%   IIIa formula. This is a collocation formula and the collocation 
%   polynomial provides a C1-continuous solution that is fourth order
%   accurate uniformly in [a,b]. (For multipoint BVPs, the solution is 
%   C1-continuous within each region, but continuity is not automatically
%   imposed at the interfaces.) Mesh selection and error control are based
%   on the residual of the continuous solution. Analytical condensation is
%   used when the system of algebraic equations is formed.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2011 The MathWorks, Inc.

solver_name = 'bvp4c';    

% Check input arguments
if nargin < 3 
  error(message('MATLAB:bvp4c:NotEnoughInputs'))
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
[n,npar,nregions,atol,rtol,Nmax,xyVectorized,printstats] = ...
    bvparguments(solver_name,ode,bc,solinit,options,varargin);

% Handle argument functions and additional arguments 
[ode,bc,Fjac,BCjac,Joptions,dBCoptions] = ...
    bvpfunctions(solver_name,ode,bc,options,n,npar,nregions,varargin);

% Deal with a singular BVP.
[singularBVP,ode,Fjac,solinit,PBC] = ...
    bvpsingular(solver_name,solinit,ode,Fjac,options,n,npar,nregions);

% Adjust function arguments to accommodate unknown parameters
unknownPar = (npar > 0);
ExtraArgs = {};
if unknownPar    
  ExtraArgs = [ExtraArgs,solinit.parameters(:)];
end               
nExtraArgs = length(ExtraArgs);

threshold = atol/rtol;

% Initialize counters (count test calls in BVPARGUMENTS)
nODEeval = 1; 
nBCeval = 1;  

% Mesh and solution at mesh points
x = solinit.x(:)';  % row vector
y = solinit.y;   
N = length(x);      % number of mesh points
nN = n*N;

% Recognize a multipoint BVP
nBCs = n * nregions + npar;
mbcidx = find(diff(x) == 0);  % locate internal interfaces

% Input to ODENUMJAC for vectorized problems 
vectVars = [];  
if xyVectorized     
  vectVars = [1,2]; 
end

% Algebraic solver parameters
maxNewtIter = 4;  
maxProbes = 4;    % weak line search 
needGlobalJacobian = true;

meshHistory = [0,0];            % Keep track of [N, maxres], 
residualReductionGuard = 1e-4;  % to prevent mesh oscillations.

done = false;
     
% THE MAIN LOOP:
while ~done       
  
  if unknownPar
    Y = [y(:);ExtraArgs{1}];
  else
    Y =  y(:);
  end
    
  [RHS,yp,Fmid,NF] = colloc_RHS(n,x,Y,ode,bc,npar,xyVectorized,mbcidx,nExtraArgs,ExtraArgs); 	
  nODEeval = nODEeval + NF;
  nBCeval = nBCeval + 1;
    
  for iter=1:maxNewtIter	
    if needGlobalJacobian
      % setup and factor the global Jacobian            
      [dPHIdy,NF,NBC,needSeparateBCs] = colloc_Jac(n,x,Y,yp,Fmid,ode,bc,Fjac,Joptions,...
                                                   BCjac,dBCoptions,npar,vectVars,mbcidx,...
                                                   nExtraArgs,ExtraArgs); 
      needGlobalJacobian = false;                     
      singularJacobian = false;
      
      nODEeval = nODEeval + NF;                
      nBCeval = nBCeval + NBC;      

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
        error(message('MATLAB:bvp4c:SingJac'));
      end                 
      
    else  % Jacobian reuse
      
      % Find the Newton direction    
      delY = T' * (U \ (L \ (P * (D * (T * RHS)))));              
        
    end
                    
    distY = norm(delY);        

    % weak line search with an affine stopping criterion
    lambda = 1;
    for probe = 1:maxProbes     
      Ynew = Y - lambda*delY;                

      if singularBVP     % Impose necessary BC, Sy(0) = 0.
        Ynew(1:n) = PBC*Ynew(1:n);
      end

      if unknownPar  
        ExtraArgs{1} = Ynew(nN+1:end);
      end
      
      [RHS,yp,Fmid,NF] = colloc_RHS(n,x,Ynew,ode,bc,npar,xyVectorized,mbcidx,nExtraArgs,ExtraArgs);
      
      nODEeval = nODEeval + NF;
      nBCeval = nBCeval + 1;
      
      distYnew = norm(U \ (L \ (P * (D * (T * RHS)))));
            
      if (distYnew < 0.9*distY)       
        break		
      else
        lambda = 0.5*lambda;		
      end
    end  

    needGlobalJacobian = (distYnew > 0.1*distY);
          
    if distYnew < 0.1*rtol   
      break
    else
      Y = Ynew;
    end        
  end  
  
  y = reshape(Ynew(1:nN),n,N); % yp, ExtraArgs, and RHS are consistent with y
     
  [res,NF] = residual(ode,x,y,yp,Fmid,RHS,threshold,xyVectorized,nBCs, ...
                      mbcidx,ExtraArgs);
  nODEeval = nODEeval + NF;     
  
  maxres = max(res);
  if maxres < rtol      
    done = true;
    
  else 	% redistribute the mesh
    
    % Detect mesh oscillations:  Was there a mesh with 
    % the same number of nodes and a similar residual?
    idx = meshHistory(:,1) == N;
    residualReduction = abs(meshHistory(idx,2) - maxres)/maxres;
    oscLikely = any( residualReduction < residualReductionGuard);    
    
    % modify the mesh, interpolate the solution
    meshHistory(end+1,:) = [N,maxres];      
    canRemovePoints = ~oscLikely;
    [N,x,y,mbcidx] = new_profile(n,x,y,yp,res,mbcidx,rtol,Nmax,canRemovePoints);

    if N > Nmax    
      warning(message('MATLAB:bvp4c:RelTolNotMet',Nmax,length(x),sprintf('%g',max(res)),sprintf('%g',rtol))); 
      sol.x = x;
      sol.y = y;
      sol.yp = yp;
      sol.solver = solver_name; 
      if unknownPar
        sol.parameters = ExtraArgs{1};
      end          
      return  
    end     
    
    nN = n*N;
  
    needGlobalJacobian = true;	
    
  end  

end    % while

% Output
sol.solver = solver_name; 
sol.x = x;
sol.y = y;
sol.yp = yp;
if unknownPar
  sol.parameters = ExtraArgs{1};
end  

% Stats
if printstats
  fprintf(getString(message('MATLAB:bvp4c:SolutionWasObtainedn',sprintf('%g',N))));
  fprintf(getString(message('MATLAB:bvp4c:MaximumResidual',sprintf('%10.3e',max(res))))); 
  fprintf(getString(message('MATLAB:bvp4c:CallsToODEFunction',sprintf('%g',nODEeval)))); 
  fprintf(getString(message('MATLAB:bvp4c:CallsToBCFunction',sprintf('%g',nBCeval)))); 
end

sol.stats = struct('nmeshpoints',N,'maxres',max(res),...
                   'nODEevals',nODEeval,'nBCevals',nBCeval);


%---------------------------------------------------------------------------

function [Sx,Spx] = interp_Hermite (hnode,diffx,y,yp)
%INTERP_HERMITE  Evaluate the cubic Hermite interpolant and its first 
%   derivative at x+hnode*diffx. 
N = size(y,2);
diffx = diffx(:);  % column vector
diagscal = spdiags(1./diffx,0,N-1,N-1);
slope = (y(:,2:N) - y(:,1:N-1)) * diagscal;
c = (3*slope - 2*yp(:,1:N-1) - yp(:,2:N)) * diagscal;
d = (yp(:,1:N-1)+yp(:,2:N)-2*slope) * (diagscal.^2);

diagscal = spdiags(hnode*diffx,0,diagscal);
d = d*diagscal;

Sx = ((d+c)*diagscal+yp(:,1:N-1))*diagscal+y(:,1:N-1);
Spx = (3*d+2*c)*diagscal+yp(:,1:N-1);

%---------------------------------------------------------------------------

function [res,nfcn] = residual (Fcn, x, y, yp, Fmid, RHS, threshold, ...
                                xyVectorized, nBCs, mbcidx, ExtraArgs)
%RESIDUAL  Compute L2-norm of the residual using 5-point Lobatto quadrature.

% multi-point BVP support
ismbvp = ~isempty(mbcidx);
nregions = length(mbcidx) + 1;
Lidx = [1, mbcidx+1];
Ridx = [mbcidx, length(x)];
if ismbvp
  FcnArgs = {0,ExtraArgs{:}};  % pass region idx
else  
  FcnArgs = ExtraArgs;
end

% Lobatto quadrature
lob4 = (1+sqrt(3/7))/2;  
lob2 = (1-sqrt(3/7))/2;                               
lobw24 = 49/90;   
lobw3 = 32/45;    

[n,N] = size(y);

res = [];
nfcn = 0;

% Residual at the midpoints is related to the error
% in satisfying the collocation equations.
NewtRes = zeros(n,N-1);
% Do not populate the interface intervals for multi-point BVPs.
intidx = setdiff(1:N-1,mbcidx);
NewtRes(:,intidx) = reshape(RHS(nBCs+1:end),n,[]);

for region = 1:nregions
  if ismbvp
    FcnArgs{1} = region;    % Pass the region index to the ODE function.
  end  
  
  xidx = Lidx(region):Ridx(region);    % mesh point index  
  Nreg = length(xidx);
  xreg = x(xidx); 
  yreg = y(:,xidx);
  ypreg = yp(:,xidx);
  hreg = diff(xreg);
  
  iidx = xidx(1:end-1);   % mesh interval index
  Nint = length(iidx);

  thresh = threshold(:,ones(1,Nint));

  % the mid-points
  temp =  (NewtRes(:,iidx) * spdiags(1.5./hreg(:),0,Nint,Nint)) ./ ...
           max(abs(Fmid(:,iidx)),thresh); 
  res_reg = lobw3*dot(temp,temp,1);    
  
  % Lobatto L2 points
  xLob = xreg(1:Nreg-1) + lob2*hreg;
  [yLob,ypLob] = interp_Hermite(lob2,hreg,yreg,ypreg);      
  if xyVectorized
    fLob = Fcn(xLob,yLob,FcnArgs{:});
    nfcn = nfcn + 1;
  else
    fLob = zeros(n,Nint);
    for i = 1:Nint
      fLob(:,i) = Fcn(xLob(i),yLob(:,i),FcnArgs{:});
    end 
    nfcn = nfcn + Nint;
  end    
  temp = (ypLob - fLob) ./ max(abs(fLob),thresh);
  resLob = dot(temp,temp,1);
  res_reg = res_reg + lobw24*resLob;
  
  % Lobatto L4 points
  xLob = xreg(1:Nreg-1) + lob4*hreg;
  [yLob,ypLob] = interp_Hermite(lob4,hreg,yreg,ypreg);      
  if xyVectorized
    fLob = Fcn(xLob,yLob,FcnArgs{:});
    nfcn = nfcn + 1;
  else
    for i = 1:Nint
      fLob(:,i) = Fcn(xLob(i),yLob(:,i),FcnArgs{:});
    end  
    nfcn = nfcn + Nint;
  end    
  temp = (ypLob - fLob) ./ max(abs(fLob),thresh);
  resLob = dot(temp,temp,1);  
  res_reg = res_reg + lobw24*resLob;
  
  % scaling
  res_reg = sqrt( abs(hreg/2) .* res_reg);

  res(iidx) = res_reg;  
end  
    

%---------------------------------------------------------------------------

function [NN,xx,yy,mbcidxnew] = new_profile(n,x,y,yp,res,mbcidx,rtol,Nmax,canRemovePoints)
%NEW_PROFILE  Redistribute mesh points and approximate the solution.

% multi-point BVP support
nregions = length(mbcidx) + 1;
Lidx = [1, mbcidx+1];
Ridx = [mbcidx, length(x)];

mbcidxnew = [];

xx = [];
yy = [];
NN = 0;

for region = 1:nregions

  xidx = Lidx(region):Ridx(region);  % mesh point index  
  xreg = x(xidx);
  yreg = y(:,xidx);
  ypreg = yp(:,xidx);  
  hreg = diff(xreg);
  Nreg = length(xidx);

  iidx = xidx(1:end-1);    % mesh interval index
  resreg = res(iidx);  
  i1 = find(resreg > rtol);
  i2 = find(resreg(i1) > 100*rtol);
  NNmax = Nreg + length(i1) + length(i2);
  xxreg = zeros(1,NNmax);
  yyreg = zeros(n,NNmax);
  last_int = Nreg - 1;
  
  xxreg(1) = xreg(1);
  yyreg(:,1) = yreg(:,1);
  NNreg = 1;
  i = 1;
  while i <= last_int
    if resreg(i) > rtol     % introduce points   
      if resreg(i) > 100*rtol   
        Ni = 2;           
      else
        Ni = 1;     
      end  
      hi = hreg(i) / (Ni+1);
      j = 1:Ni;
      xxreg(NNreg+j) = xxreg(NNreg) + j*hi;
      yyreg(:,NNreg+j) = ntrp3h(xxreg(NNreg+j),xreg(i),yreg(:,i),xreg(i+1),...
                          yreg(:,i+1),ypreg(:,i),ypreg(:,i+1));          
      NNreg = NNreg + Ni;
    else    
      if canRemovePoints && (i <= last_int-2) && all(resreg(i+1:i+2) < rtol)  
        % try removing points        
        hnew = (hreg(i)+hreg(i+1)+hreg(i+2))/2;
        C1 = resreg(i)/(hreg(i)/hnew)^(7/2);
        C2 = resreg(i+1)/(hreg(i+1)/hnew)^(7/2);
        C3 = resreg(i+2)/(hreg(i+2)/hnew)^(7/2);
        pred_res = max([C1,C2,C3]); 
        
        if pred_res < 0.5 * rtol   % replace 3 intervals with 2 
          xxreg(NNreg+1) = xxreg(NNreg) + hnew;
          yyreg(:,NNreg+1) = ntrp3h(xxreg(NNreg+1),xreg(i+1),yreg(:,i+1),xreg(i+2),...
                              yreg(:,i+2),ypreg(:,i+1),ypreg(:,i+2));
          NNreg = NNreg + 1;  
          i = i + 2;    
        end        
      end      
    end
    NNreg = NNreg + 1;
    xxreg(NNreg) = xreg(i+1);   % preserve the next mesh point
    yyreg(:,NNreg) = yreg(:,i+1);
    i = i + 1;
  end    
  
  NN = NN + NNreg;
  if (NN > Nmax)
    % return the previous solution 
    xx = x; 
    yy = y;   
    mbcidxnew = mbcidx;
    break
  else 
    xx = [xx, xxreg(1:NNreg)];
    yy = [yy, yyreg(:,1:NNreg)];
    if region < nregions    % possible only for multipoint BVPs
      mbcidxnew = [mbcidxnew, NN];
    end
  end
end


%---------------------------------------------------------------------------

function [Phi,F,Fmid,nfcn] = colloc_RHS(n, x, Y, Fcn, Gbc, npar, xyVectorized, ...
                                        mbcidx, nExtraArgs, ExtraArgs)
%COLLOC_RHS  Evaluate the system of collocation equations Phi(Y).  
%   The derivative approximated at the midpoints and returned in Fmid is
%   used to estimate the residual. 

% multi-point BVP support
ismbvp = ~isempty(mbcidx);
nregions = length(mbcidx) + 1;
Lidx = [1, mbcidx+1];
Ridx = [mbcidx, length(x)];
if ismbvp
  FcnArgs = {0,ExtraArgs{:}};    % Pass the region index to the ODE function.
else  
  FcnArgs = ExtraArgs;
end

y = reshape(Y(1:end-npar),n,[]);  

[n,N] = size(y);
nBCs = n*nregions + npar;

F = zeros(n,N);
Fmid = zeros(n,N-1);    % include interface intervals
Phi = zeros(nBCs+n*(N-nregions),1);    % exclude interface intervals

% Boundary conditions
% Do not pass info about singular BVPs in ExtraArgs to BC function.
Phi(1:nBCs) = Gbc(y(:,Lidx),y(:,Ridx),ExtraArgs{1:nExtraArgs});    
phiptr = nBCs;    % active region of Phi

for region = 1:nregions
  if ismbvp
    FcnArgs{1} = region;
  end   
  xidx = Lidx(region):Ridx(region);   % mesh point index
  Nreg = length(xidx);
  xreg = x(xidx); 
  yreg = y(:,xidx);
  
  iidx = xidx(1:end-1);   % mesh interval index
  Nint = length(iidx);
  
  % derivative at the mesh points
  if xyVectorized
    Freg = Fcn(xreg,yreg,FcnArgs{:});  
    nfcn = 1;
  else
    Freg = zeros(n,Nreg);
    for i = 1:Nreg
      Freg(:,i) = Fcn(xreg(i),yreg(:,i),FcnArgs{:});  
    end  
    nfcn = Nreg;
  end
  
  % derivative at the midpoints
  h = diff(xreg);
  H = spdiags(h(:),0,Nint,Nint);
  xi = xreg(1:end-1);
  yi = yreg(:,1:end-1);
  xip1 = xreg(2:end);
  yip1 = yreg(:,2:end);
  Fi = Freg(:,1:end-1);
  Fip1 = Freg(:,2:end);

  xip05 = (xi + xip1)/2;  
  yip05 = (yi + yip1)/2 - (Fip1 - Fi)*(H/8);
  if xyVectorized 
    Fip05 = Fcn(xip05,yip05,FcnArgs{:}); 
    nfcn = nfcn + 1;    
  else % not vectorized 
    Fip05 = zeros(n,Nint);      
    for i = 1:Nint
      Fip05(:,i) = Fcn(xip05(i),yip05(:,i),FcnArgs{:}); 
    end  
    nfcn = nfcn + Nint;
  end
  
  % the Lobatto IIIa formula  
  Phireg = yip1 - yi - (Fip1 + 4*Fip05 + Fi)*(H/6);

  % output assembly 
  Phi(phiptr+1:phiptr+n*Nint) = Phireg(:);
  F(:,xidx) = Freg;
  Fmid(:,iidx) = Fip05;
  phiptr = phiptr + n*Nint; 
  
end  
    
%---------------------------------------------------------------------------

function [dPHIdy,nfcn,nbc,doSeparateBCs] = ...
        colloc_Jac(n, x, Y, F, Fmid, ode, bc, ...
                   Fjac, Joptions, BCjac, dBCoptions, ...
                   npar, vectVars, mbcidx, nExtraArgs, ExtraArgs)
%COLLOC_JAC  Form the global Jacobian of collocation eqns.

% multi-point BVP support
ismbvp = ~isempty(mbcidx);
nregions = length(mbcidx) + 1;
Lidx = [1, mbcidx+1];
Ridx = [mbcidx, length(x)];
if ismbvp
  FcnArgs = {0,ExtraArgs{:}};  % pass region idx
else  
  FcnArgs = ExtraArgs;
end

% Sizes 
N = length(x);
nBCs = n*nregions + npar;

y = reshape(Y(1:n*N),n,N);

doSeparateBCs = false;  % Reorder Jacobian rows-columns to get a band matrix?

% BC Jacobian
JACbcI = zeros(nBCs,2*nregions*n);
JACbcJ = zeros(nBCs,2*nregions*n);
JACbcV = zeros(nBCs,2*nregions*n); 

JACbcPar = [];
nbc = 0;
ya = y(:,Lidx);
yb = y(:,Ridx);
% evaluate
if npar == 0
  if isempty(BCjac)  % Use numerical approx
    [dGdya,dGdyb,nbc] = BCnumjac(bc,ya,yb,n,npar,dBCoptions,nExtraArgs,ExtraArgs); 
  elseif iscell(BCjac)  % Constant partial derivatives {dGdya,dGdyb}
    dGdya = BCjac{1};
    dGdyb = BCjac{2};        
  else  % Use analytical Jacobian 
    [dGdya,dGdyb] = BCjac(ya,yb,ExtraArgs{1:nExtraArgs});
  end   
    
  % Check if BCs can be 'separated' by reordering the Jacobian
  if ~ismbvp
    doSeparateBCs = any( any(dGdya,2) & any(dGdyb,2) );
  end    
else  % There are unknown parameters    
  if isempty(BCjac)   % use numerical approx
    [dGdya,dGdyb,nbc,dGdpar] = BCnumjac(bc,ya,yb,n,npar,dBCoptions,nExtraArgs,ExtraArgs);
  elseif iscell(BCjac)     % Constant partial derivatives {dGdya,dGdyb}
    dGdya  = BCjac{1};
    dGdyb  = BCjac{2};     
    dGdpar = BCjac{3};    
  else  % use analytical Jacobian 
    [dGdya,dGdyb,dGdpar] = BCjac(ya,yb,ExtraArgs{1:nExtraArgs});
  end   
end
% assembly
blockI = repmat(transpose(1:nBCs),1,n);
blockJ = repmat(1:n,nBCs,1);
colidx = 0;
idx = 0;
for region = 1 : nregions            
    
  % left BC
  JACbcV(:,idx+1:idx+n) = dGdya(:,colidx+1:colidx+n);
  JACbcI(:,idx+1:idx+n) = blockI;
  JACbcJ(:,idx+1:idx+n) = blockJ + (Lidx(region) - 1)*n;
  idx = idx + n;
  
  % right BC
  JACbcV(:,idx+1:idx+n) = dGdyb(:,colidx+1:colidx+n);
  JACbcI(:,idx+1:idx+n) = blockI;
  JACbcJ(:,idx+1:idx+n) = blockJ + (Ridx(region) - 1)*n;
  idx = idx + n;
  
  colidx = colidx + n;
end 
% wrt. parameters
if npar > 0
  JACbcPar = dGdpar;
end

% ODE Jacobian
dPoptions = [];
if isempty(Fjac)  % use numerical approx
  if npar > 0   % unknown parameters
    threshval = 1e-6;
    if ismbvp
      dPoptions.diffvar = 4;  % dF(x,y,region,p)/dp
    else
      dPoptions.diffvar = 3;  % dF(x,y,p)/dp
    end  
    dPoptions.vectvars = vectVars;
    dPoptions.thresh = threshval(ones(npar,1));
    dPoptions.fac = [];        
  end  
end

if ismbvp
    
  % Provide storage for non-zero entries of global Jacobian
  % ODE Jacobian
  JACodeI = zeros(n,(N-nregions)*2*n);
  JACodeJ = zeros(n,(N-nregions)*2*n);
  JACodeV = zeros(n,(N-nregions)*2*n); 
  
  % Jacobian of ODE wrt parameters
  if npar > 0
    JACodePar = zeros((N-nregions)*n,npar);
  else
    JACodePar = [];
  end

  nfcn = 0;
  idx = 0;
  rowOffset = 0;
  colOffset = 0;
  parIdx = 0;
  for region = 1 : nregions
      
    if ismbvp
      FcnArgs{1} = region; % Pass the region index to the ODE function.
    end  
        
    % Get region data
    xidx = Lidx(region):Ridx(region);    % mesh point index  
    xreg = x(xidx); 
    yreg = y(:,xidx);
    freg = F(:,xidx);
    
    iidx = xidx(1:end-1);    % mesh interval index
    fmidreg = Fmid(:,iidx);
    
    % Evaluate non-zero entries of regional Jacobian  
    [JACregI,JACregJ,JACregV,JACregPar,nFcalls] = ...
        colloc_JacODE_region(region, xreg, yreg, freg, fmidreg, ...
                             Fjac, Joptions, dPoptions, ...
                             npar,  ode, FcnArgs);  
    nfcn = nfcn + nFcalls;

    % Write into the global Jacobian
    ncols = size(JACregI,2);                    
    JACodeV(:,idx+1:idx+ncols) = JACregV;
    JACodeI(:,idx+1:idx+ncols) = JACregI + rowOffset;
    JACodeJ(:,idx+1:idx+ncols) = JACregJ + colOffset;
    
    if npar > 0
      parrows = size(JACregPar,1);
      JACodePar(parIdx+1:parIdx+parrows,:) = JACregPar; 
      parIdx = parIdx + parrows;
    end
    
    idx = idx + ncols;
    rowOffset = (Ridx(region)-region)*n;
    colOffset =  Ridx(region)*n;
    
  end
  
else 
    
  [JACodeI,JACodeJ,JACodeV,JACodePar,nfcn] = ...
      colloc_JacODE_region( 1, x, y, F, Fmid, ...
                            Fjac, Joptions, dPoptions, ...
                            npar, ode, FcnArgs);  
end

% Final assembly of the collocation Jacobian
Jac = [ sparse(JACbcI,JACbcJ,JACbcV); ...
        sparse(JACodeI,JACodeJ,JACodeV) ];    
dPHIdy = [Jac,[JACbcPar;JACodePar]];

%---------------------------------------------------------------------------

function [JACodeI,JACodeJ,JACodeV,JACpar,nfcn] = ...
        colloc_JacODE_region(region, xreg, yreg, freg, fmidreg, ...
                             Fjac, Joptions, dPoptions, ...
                             npar,  odeFcn, FcnArgs)
%COLLOC_JACODE_REGION  Form the collocation Jacobian for a region.

% Dimensions and storage
[n,nreg] = size(yreg);
nint = nreg - 1;
JACodeI = zeros(n,nint*2*n);
JACodeJ = zeros(n,nint*2*n);
JACodeV = zeros(n,nint*2*n);

blockI = repmat(transpose(1:n),1,n);
blockJ = repmat(1:n,n,1);
if npar == 0
  JACpar = [];
else
  JACpar = zeros(nint*n,npar);    
end

In = eye(n);
hreg = diff(xreg);

nfcn = 0;

idx = 0;
if npar == 0

  % Collocation equations
  if isempty(Fjac)  % use numerical approx
      
    Joptions.fac = [];  
    [Ji,Joptions.fac,~,nFcalls] = ...
        odenumjac(odeFcn,{xreg(1),yreg(:,1),FcnArgs{:}},freg(:,1),Joptions);
    nfcn = nfcn+nFcalls;    
    nrmJi = norm(Ji,1);
    
    for i = 1:nint
      % the left mesh point
      xi = xreg(i);            
      yi = yreg(:,i);
      Fi = freg(:,i);
      % the right mesh point
      xip1 = xreg(i+1);
      yip1 = yreg(:,i+1);
      Fip1 = freg(:,i+1);        
      [Jip1,Joptions.fac,~,nFcalls] = ...
          odenumjac(odeFcn,{xip1,yip1,FcnArgs{:}},Fip1,Joptions); 
      nfcn = nfcn + nFcalls;
      nrmJip1 = norm(Jip1,1);      
      
      % the midpoint
      hi = hreg(i);
      xip05 = (xi + xip1)/2; 
      if norm(Jip1 - Ji,1) <= 0.25*(nrmJi + nrmJip1)
        twiceJip05 = Ji + Jip1;
      else
        yip05 = (yi + yip1)/2 - hi/8*(Fip1 - Fi);  
        Fip05 = fmidreg(:,i);
        [Jip05,Joptions.fac,~,nFcalls] = ...
            odenumjac(odeFcn,{xip05,yip05,FcnArgs{:}},Fip05,Joptions);            
        nfcn = nfcn + nFcalls;
        twiceJip05 = 2*Jip05;
      end      
      
      JACodeV(:,idx+1:idx+n) = -(In+hi/6*(Ji+twiceJip05*(In+hi/4*Ji))); 
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockJ = blockJ + n;
      idx = idx + n;
      
      JACodeV(:,idx+1:idx+n) = In-hi/6*(Jip1+twiceJip05*(In-hi/4*Jip1));
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockI = blockI + n;
      idx = idx + n;
      
      Ji = Jip1;
      nrmJi = nrmJip1;
    end        
    
  elseif isnumeric(Fjac) % constant Jacobian
    J = Fjac(:,(region-1)*n+(1:n));            
    J2 = J*J;    
    for i = 1:nint
      h2J   = hreg(i)/2*J;
      h12J2 = hreg(i)^2/12*J2;   
      
      JACodeV(:,idx+1:idx+n) = -(In+h2J+h12J2);
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockJ = blockJ + n;
      idx = idx + n;
      
      JACodeV(:,idx+1:idx+n) = In-h2J+h12J2;
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockI = blockI + n;
      idx = idx + n;             
      
    end    
    
  else % use analytical Jacobian        
      
    Ji = Fjac(xreg(:,1),yreg(:,1),FcnArgs{:});
      
    for i = 1:nint
      % the left mesh point
      xi = xreg(i);
      yi = yreg(:,i);
      Fi = freg(:,i);
      % the right mesh point
      xip1 = xreg(i+1);
      yip1 = yreg(:,i+1);
      Fip1 = freg(:,i+1);
      Jip1 = Fjac(xip1,yip1,FcnArgs{:});    
      % the midpoint
      hi = hreg(i);
      xip05 = (xi + xip1)/2; 
      yip05 = (yi + yip1)/2 - hi/8*(Fip1 - Fi);  
      Jip05 = Fjac(xip05,yip05,FcnArgs{:});  % recompute the Jacobian
      twiceJip05 = 2*Jip05;
      
      JACodeV(:,idx+1:idx+n) = -(In+hi/6*(Ji+twiceJip05*(In+hi/4*Ji))); 
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockJ = blockJ + n;
      idx = idx + n;
      
      JACodeV(:,idx+1:idx+n) = In-hi/6*(Jip1+twiceJip05*(In-hi/4*Jip1));
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockI = blockI + n;
      idx = idx + n;
      
      Ji = Jip1;
    end        
  end
  
else  % there are unknown parameters

  pidx = 0;
  
  % Collocation equations
  if isempty(Fjac)  % use numerical approx
      
    Joptions.fac = [];  
    dPoptions.fac = [];
    [Ji,Joptions.fac,dFdpar_i,dPoptions.fac,nFcalls] = ...
        Fnumjac(odeFcn,{xreg(1),yreg(:,1),FcnArgs{:}},freg(:,1),...
                Joptions,dPoptions);
    nfcn = nfcn+nFcalls;
    nrmJi = norm(Ji,1);
    nrmdFdpar_i = norm(dFdpar_i,1);
    
    for i = 1:nint
      % the left mesh point   
      xi = xreg(i);            
      yi = yreg(:,i); 
      Fi = freg(:,i);
      % the right mesh point
      xip1 = xreg(i+1);
      yip1 = yreg(:,i+1);
      Fip1 = freg(:,i+1);
      [Jip1,Joptions.fac,dFdpar_ip1,dPoptions.fac,nFcalls] = ...
          Fnumjac(odeFcn,{xip1,yip1,FcnArgs{:}},Fip1,Joptions,dPoptions);    
      nfcn = nfcn + nFcalls; 
      nrmJip1 = norm(Jip1,1);
      nrmdFdpar_ip1 = norm(dFdpar_ip1,1);
      % the midpoint 
      hi = hreg(i);
      xip05 = (xi + xip1)/2; 
      if (norm(Jip1 - Ji,1) <= 0.25*(nrmJi + nrmJip1)) && ...
              (norm(dFdpar_ip1 - dFdpar_i,1) <= 0.25*(nrmdFdpar_i + nrmdFdpar_ip1))
        Jip05 = 0.5*(Ji + Jip1);
        dFdpar_ip05 = 0.5*(dFdpar_i + dFdpar_ip1);         
      else
        yip05 = (yi+yip1)/2-hi/8*(Fip1-Fi);  
        Fip05 = fmidreg(:,i);
        [Jip05,Joptions.fac,dFdpar_ip05,dPoptions.fac,nFcalls] = ...
            Fnumjac(odeFcn,{xip05,yip05,FcnArgs{:}},Fip05,Joptions,dPoptions);   
        nfcn = nfcn + nFcalls;
      end
      twiceJip05 = 2*Jip05;   
      
      JACodeV(:,idx+1:idx+n) = -(In+hi/6*(Ji+twiceJip05*(In+hi/4*Ji))); 
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockJ = blockJ + n;
      idx = idx + n;
      
      JACodeV(:,idx+1:idx+n) = In-hi/6*(Jip1+twiceJip05*(In-hi/4*Jip1));
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockI = blockI + n;
      idx = idx + n;
      
      JACpar(pidx+1:pidx+n,:) = -hi*dFdpar_ip05 + hi^2/12*Jip05*...
          (dFdpar_ip1-dFdpar_i);
      pidx = pidx + n;
      
      Ji = Jip1;
      nrmJi = nrmJip1;
      dFdpar_i = dFdpar_ip1;
      nrmdFdpar_i = nrmdFdpar_ip1;
    end
    
  elseif iscell(Fjac)     % Constant partial derivatives {dFdY,dFdp}
    J = Fjac{1}(:,(region-1)*n+(1:n));
    dFdp = Fjac{2}(:,(region-1)*npar+(1:npar));
    J2 = J*J;      
    for i = 1:nint
      h2J   = hreg(i)/2*J;
      h12J2 = hreg(i)^2/12*J2;   
      
      JACodeV(:,idx+1:idx+n) = -(In+h2J+h12J2);
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockJ = blockJ + n;
      idx = idx + n;
      
      JACodeV(:,idx+1:idx+n) = In-h2J+h12J2;        
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockI = blockI + n;
      idx = idx + n;
      
      JACpar(pidx+1:pidx+n,:) = -hreg(i)*dFdp; 
      pidx = pidx + n;
      
    end    
    
  else % use analytical Jacobian                           
      
    [Ji,dFdpar_i] = Fjac(xreg(1),yreg(:,1),FcnArgs{:});
    
    for i = 1:nint
      % the left mesh point
      xi = xreg(i);            
      yi = yreg(:,i);
      Fi = freg(:,i);
      % the right mesh point
      xip1 = xreg(i+1);
      yip1 = yreg(:,i+1);
      Fip1 = freg(:,i+1);
      [Jip1, dFdpar_ip1] = Fjac(xip1,yip1,FcnArgs{:});    
      % the midpoint
      hi = hreg(i);
      xip05 = (xi + xip1)/2; 
      yip05 = (yi + yip1)/2 - hi/8*(Fip1 - Fi);  
      [Jip05, dFdpar_ip05] = Fjac(xip05,yip05,FcnArgs{:});  % recompute the Jacobian
      twiceJip05 = 2*Jip05;
      
      JACodeV(:,idx+1:idx+n) = -(In+hi/6*(Ji+twiceJip05*(In+hi/4*Ji))); 
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockJ = blockJ + n;
      idx = idx + n;
      
      JACodeV(:,idx+1:idx+n) = In-hi/6*(Jip1+twiceJip05*(In-hi/4*Jip1));
      JACodeI(:,idx+1:idx+n) = blockI;
      JACodeJ(:,idx+1:idx+n) = blockJ;
      blockI = blockI + n;
      idx = idx + n;
      
      JACpar(pidx+1:pidx+n,:) = -hi*dFdpar_ip05 + hi^2/12*Jip05*...
          (dFdpar_ip1-dFdpar_i);
      pidx = pidx + n;
      
      Ji = Jip1;
      dFdpar_i = dFdpar_ip1;
    end
  end  
  
end

%---------------------------------------------------------------------------

function res = bcaux(Ya,Yb,n,bcfun,varargin)
ya = reshape(Ya,n,[]);
yb = reshape(Yb,n,[]);
res = bcfun(ya,yb,varargin{:});

%---------------------------------------------------------------------------

function [dBCdya,dBCdyb,nCalls,dBCdpar] = BCnumjac(bc,ya,yb,n,npar,dBCoptions,...
                                                   nExtraArgs,ExtraArgs)
%BCNUMJAC  Numerically compute dBC/dya, dBC/dyb, and dBC/dpar, if needed.

% Do not pass info about singular BVPs in ExtraArgs to BC function.
bcArgs = {ya(:),yb(:),n,bc,ExtraArgs{1:nExtraArgs}};  

bcVal  = bcaux(bcArgs{:});
nCalls = 1;

dBCoptions.fac = [];      

dBCoptions.diffvar = 1;  % d(bc(ya,yb))/dya
[dBCdya,~,~,nbc] = odenumjac(@bcaux,bcArgs,bcVal,dBCoptions);
nCalls = nCalls + nbc;

dBCoptions.diffvar = 2;
[dBCdyb,~,~,nbc] = odenumjac(@bcaux,bcArgs,bcVal,dBCoptions);
nCalls = nCalls + nbc;

if npar > 0
  bcArgs = {ya,yb,ExtraArgs{1:nExtraArgs}};  
  dPoptions.thresh = repmat(1e-6,npar,1);
  dPoptions.diffvar = 3;  
  dPoptions.vectvars = [];
  dPoptions.fac = [];        
  [dBCdpar,~,~,nbc] = odenumjac(bc,bcArgs,bcVal,dPoptions);
  nCalls = nCalls + nbc;
end
  
%---------------------------------------------------------------------------

function [dFdy,dFdy_fac,dFdp,dFdp_fac,nFcalls] = Fnumjac(ode,odeArgs,odeVal,...
                                                    Joptions,dPoptions)
%FNUMJAC  Numerically compute dF/dy and dF/dpar. 

[dFdy,dFdy_fac,~,dFdy_nfcn] = odenumjac(ode,odeArgs,odeVal,Joptions);  

[dFdp,dFdp_fac,~,dFdp_nfcn] = odenumjac(ode,odeArgs,odeVal,dPoptions);

nFcalls = dFdy_nfcn + dFdp_nfcn;
  
%---------------------------------------------------------------------------

