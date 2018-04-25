function sol_extend = odextend(sol,odefun,tfinal,initial_state,options,varargin)
%ODEXTEND  Extend solution of initial value problem for differential equations. 
%   SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL) extends the solution stored in SOL to 
%   the interval [SOL.x(1), TFINAL].  SOL is an ODE solution structure created  
%   with an ODE solver.  ODEFUN is a function handle.  For a scalar T and a 
%   column vector Y, ODEFUN(T,Y) returns a column vector of the derivatives. 
%   ODEXTEND extends the solution by integrating the problem from SOL.x(end) 
%   to TFINAL, using the same ODE solver that created SOL. By default, ODEXTEND 
%   uses SOL.y(:,end) as the initial conditions for that subsequent integration.
%   The derivative function, integration properties, and additional input 
%   arguments used to compute SOL are stored as part of that solution structure.
%   Unless these values change, they do not need to be passed to ODEXTEND.
%   The values passed to ODEXTEND will be stored in SOLEXT.
%   Use DEVAL and SOLEXT to evaluate the extended solution at any point between 
%   SOL.x(1) and TFINAL.   
%
%   SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,YINIT) solves as above, but uses 
%   the column vector YINIT as new initial conditions at SOL.X(end).
%   To extend solutions obtained with ODE15I, use the syntax 
%   SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,[YINIT,YPINIT]), where the column 
%   vector YPINIT is the initial derivative of the solution.
%
%   SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,YINIT,OPTIONS) solves as above, with 
%   the integration properties specified in OPTIONS replacing the values used 
%   to compute SOL. See ODESET for details on setting OPTIONS properties.
%   Use YINIT = [] as a placeholder if no new YINIT is specified.
%
%   Example    
%         sol=ode45(@vdp1,[0 10],[2 0]); 
%         sol=odextend(sol,@vdp1,20); 
%         plot(sol.x,sol.y(1,:));
%     uses ODE45 to solve the system y' = vdp1(t,y) on the interval [0 10].
%     Then, it extends the solution to [0 20] and plots its first component.
%
%   Class support for inputs SOL, TFINAL, and YINIT:
%     float: double, single
%
%   See also ODE23, ODE45, ODE113, ODE15S, ODE23S, ODE23T, ODE23TB, ODE15I,
%            ODESET, ODEGET, DEVAL, FUNCTION_HANDLE.

%   Jacek Kierzenka
%   Copyright 1984-2011 The MathWorks, Inc.

if nargin < 3
  error(message('MATLAB:odextend:NotEnoughInputs'));
end

if ~isstruct(sol) || ~isfield(sol,'solver')
  error(message('MATLAB:odextend:SOLNotODEsolverStruct',inputname(1)));
end  
solver = sol.solver;
if ~ismember(solver,{'ode113','ode15i','ode15s','ode23',...
                     'ode23s','ode23t','ode23tb','ode45'})
  error(message('MATLAB:odextend:InvalidSolverNameInSOL',solver, inputname(1)));
end    

if isempty(odefun)
  odefun = sol.extdata.odefun;
end    

% check that tfinal is not in [sol.x(1) sol.x(end)]
if sol.x(1) < sol.x(end)
  if tfinal < sol.x(1)
    error(message('MATLAB:odextend:SolutionCannotBeExtended',inputname(1),sprintf('%g',sol.x(1)),sprintf('%g',sol.x(end)),sprintf('%g',tfinal)));
  elseif tfinal <= sol.x(end)
    warning(message('MATLAB:odextend:SolutionAlreadyAvailable', sprintf('%g',sol.x(1)),sprintf('%g',tfinal)));
    sol_extend = sol;    
    return
  end
else 
  if tfinal > sol.x(1)
    error(message('MATLAB:odextend:SolutionCannotBeExtended',inputname(1),sprintf('%g',sol.x(1)),sprintf('%g',sol.x(end)),sprintf('%g',tfinal)));
  elseif tfinal >= sol.x(end)
    warning(message('MATLAB:odextend:SolutionAlreadyAvailable', sprintf('%g',sol.x(1)),sprintf('%g',tfinal)));
    sol_extend = sol;    
    return
  end
end
tspan = [sol.x(end) tfinal];

% Remaining solver arguments
if (nargin < 4) || isempty(initial_state)
  y0 = sol.y(:,end);
  if strcmp(solver,'ode15i')
    yp0 = sol.extdata.ypfinal;
  end  
else
  if strcmp(solver,'ode15i')  % [y0 yp0]
    y0  = initial_state(:,1);
    yp0 = initial_state(:,2);
  else
    y0 = initial_state;
  end  
end    

if (nargin < 5) || isempty(options)
  options = sol.extdata.options;
end

if (nargin > 5)
  extraargs = varargin;
else  
  if isfield(sol.extdata,'varargin')
    extraargs = sol.extdata.varargin;
  else
    extraargs = {};
  end
end  

% Call ODE solver
if strcmp(solver,'ode15i')
  sol_new = ode15i(odefun,tspan,y0,yp0,options,extraargs{:});
else  
  sol_new = feval(solver,odefun,tspan,y0,options,extraargs{:});
end  

% Determine the dominant data type
dataType = superiorfloat(sol.x,sol_new.x);

if ~strcmp(class(sol.x),class(sol_new.x))
  warning(message('MATLAB:odextend:InconsistentSolType',solver));
end

% Combine the outputs
sol_extend.solver  = sol_new.solver;   % solver name
sol_extend.extdata = sol_new.extdata;  % extend data

% Stats.
sol_extend.stats.nsteps  = sol.stats.nsteps  + sol_new.stats.nsteps;
sol_extend.stats.nfailed = sol.stats.nfailed + sol_new.stats.nfailed;
sol_extend.stats.nfevals = sol.stats.nfevals + sol_new.stats.nfevals;
if ismember(solver,{'ode15i','ode15s','ode23s','ode23t','ode23tb'})
  sol_extend.stats.npds     = sol.stats.npds     + sol_new.stats.npds;
  sol_extend.stats.ndecomps = sol.stats.ndecomps + sol_new.stats.ndecomps;
  sol_extend.stats.nsolves  = sol.stats.nsolves  + sol_new.stats.nsolves;
end

% Solution. Remove duplicates, if needed.
if (sol.y(:,end) == sol_new.y(:,1))
  startidx = 2;  % smooth continuation
else 
  startidx = 1;  % jump interface, double data-point 
end  
sol_extend.x = [sol.x, sol_new.x(startidx:end)];
sol_extend.y = [sol.y, sol_new.y(:,startidx:end)];

% Events. These are never reported at tstart.
if isfield(sol,'xe')
  [xe,ye,ie] = deal(sol.xe,sol.ye,sol.ie);
else   
  [xe,ye,ie] = deal([]);
end
if isfield(sol_new,'xe')
  xe = [xe, sol_new.xe];
  ye = [ye, sol_new.ye];
  ie = [ie, sol_new.ie];
end
if ~isempty(xe)
  sol_extend.xe = xe;
  sol_extend.ye = ye;
  sol_extend.ie = ie;
end

% Interpolation data.
switch solver
 case 'ode113'
  sol_extend.idata.klastvec = cat(2, sol.idata.klastvec, sol_new.idata.klastvec(startidx:end)); 
  neq = size(sol.idata.phi3d,1);
  [k,nout] = size(sol.idata.psi2d);
  [knew,nout_new] = size(sol_new.idata.psi2d);
  kmax = max(k,knew);
  sol_extend.idata.psi2d = zeros(kmax,nout+nout_new+1-startidx,dataType);
  sol_extend.idata.psi2d(1:k,1:nout) = sol.idata.psi2d;
  sol_extend.idata.psi2d(1:knew,nout+1:end) = sol_new.idata.psi2d(:,startidx:end);
  sol_extend.idata.phi3d = zeros(neq,kmax,nout+nout_new+1-startidx,dataType);   
  sol_extend.idata.phi3d(:,1:k+1,1:nout) = sol.idata.phi3d;
  sol_extend.idata.phi3d(:,1:knew+1,nout+1:end) = sol_new.idata.phi3d(:,:,startidx:end); 
 case 'ode15i'
  sol_extend.idata.kvec = cat(2, sol.idata.kvec, sol_new.idata.kvec(startidx:end)); 
 case 'ode15s'
  sol_extend.idata.kvec = cat(2, sol.idata.kvec, sol_new.idata.kvec(startidx:end)); 
  [s1,s2,s3] = size(sol.idata.dif3d);
  [~,s2n,s3n] = size(sol_new.idata.dif3d);
  sol_extend.idata.dif3d = zeros(s1,max(s2,s2n),s3+s3n+1-startidx,dataType);
  sol_extend.idata.dif3d(:,1:s2,1:s3) = sol.idata.dif3d;
  sol_extend.idata.dif3d(:,1:s2n,s3+1:end) = sol_new.idata.dif3d(:,:,startidx:end);  
 case 'ode23'          
  sol_extend.idata.f3d = cat(3,sol.idata.f3d, sol_new.idata.f3d(:,:,startidx:end)); 
 case 'ode23s' 
  sol_extend.idata.k1 = cat(2, sol.idata.k1, sol_new.idata.k1(:,startidx:end)); 
  sol_extend.idata.k2 = cat(2, sol.idata.k2, sol_new.idata.k2(:,startidx:end)); 
 case 'ode23t'
  sol_extend.idata.z    = cat(2, sol.idata.z,   sol_new.idata.z(:,startidx:end)); 
  sol_extend.idata.znew = cat(2, sol.idata.znew, sol_new.idata.znew(:,startidx:end)); 
 case 'ode23tb'
  sol_extend.idata.t2 = cat(2, sol.idata.t2, sol_new.idata.t2(startidx:end)); 
  sol_extend.idata.y2 = cat(2, sol.idata.y2, sol_new.idata.y2(:,startidx:end)); 
 case 'ode45' 
  sol_extend.idata.f3d = cat(3, sol.idata.f3d, sol_new.idata.f3d(:,:,startidx:end)); 
end    
