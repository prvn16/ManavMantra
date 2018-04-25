function sol = ddesd(ddefun,delays,history,tspan,options) 
%DDESD  Solve delay differential equations (DDEs) with general delays.
%   SOL = DDESD(DDEFUN,DELAYS,HISTORY,TSPAN) integrates a system of DDEs 
%   y'(t) = f(t,y(t),y(d(1)),...,y(d(k))). The delays d(j) can depend on 
%   both t and y(t).  DDEFUN and DELAYS are function handles. DELAYS(T,Y)  
%   must return a column vector of delays d(j). DDESD imposes the requirement 
%   that d(j) <= t by using min(d(j),t).  The function DDEFUN(T,Y,Z) must 
%   return a column vector corresponding to f(t,y(t),y(d(1)),...,y(d(k))).  
%   In the call to DDEFUN and DELAYS, a scalar T is the current t, a column 
%   vector Y approximates y(t), and a column Z(:,j) approximates y(d(j)) for 
%   delay d(j) given as component j of DELAYS(T,Y). The DDEs are integrated 
%   from T0=TSPAN(1) to TF=TSPAN(end) where T0 < TF. The solution at t <= T0 
%   is specified by HISTORY in one of three ways: HISTORY can be a function 
%   handle, where for a scalar T, HISTORY(T) returns the column vector y(t). 
%   If y(t) is constant, HISTORY can be this column vector. If this call to 
%   DDESD continues a previous integration to T0, HISTORY can be the solution 
%   SOL from that call.
%
%   DDESD produces a solution that is continuous on [T0,TF]. The solution is
%   evaluated at points TINT using the output SOL of DDESD and the function
%   DEVAL: YINT = DEVAL(SOL,TINT). The output SOL is a structure with 
%       SOL.x  -- mesh selected by DDESD
%       SOL.y  -- approximation to y(t) at the mesh points of SOL.x
%       SOL.yp -- approximation to y'(t) at the mesh points of SOL.x
%       SOL.solver -- 'ddesd'
%
%   SOL = DDESD(DDEFUN,DELAYS,HISTORY,TSPAN,OPTIONS) solves as above with 
%   default parameters replaced by values in OPTIONS, a structure created 
%   with the DDESET function. See DDESET for details. Commonly used options 
%   are scalar relative error tolerance 'RelTol' (1e-3 by default) and vector
%   of absolute error tolerances 'AbsTol' (all components 1e-6 by default).
%
%   By default the initial value of the solution is the value returned by
%   HISTORY at T0. A different initial value can be supplied as the value of
%   the 'InitialY' property. 
%
%   With the 'Events' property in OPTIONS set to a function handle EVENTS, 
%   DDESD solves as above while also finding where event functions 
%   g(t,y(t),y(d(1)),...,y(d(k))) are zero. For each function you specify 
%   whether the integration is to terminate at a zero and whether the 
%   direction of the zero crossing matters. These are the three vectors 
%   returned by EVENTS: [VALUE,ISTERMINAL,DIRECTION] = EVENTS(T,Y,Z). 
%   For the I-th event function: VALUE(I) is the value of the function, 
%   ISTERMINAL(I) = 1 if the integration is to terminate at a zero of this 
%   event function and 0 otherwise. DIRECTION(I) = 0 if all zeros are to
%   be computed (the default), +1 if only zeros where the event function is
%   increasing, and -1 if only zeros where the event function is decreasing. 
%   The field SOL.xe is a row vector of times at which events occur. Columns
%   of SOL.ye are the corresponding solutions, and indices in vector SOL.ie
%   specify which event occurred.   
%
%   If all the delay functions have the form d(j) = t - tau_j, you can set 
%   the argument DELAYS to a constant vector DELAYS(j) = tau_j. With delay 
%   functions of this form, DDESD is used exactly like DDE23.
%   
%   Example 
%         sol = ddesd(@ddex1de,@ddex1delays,@ddex1hist,[0, 5]);
%     solves a DDE on the interval [0, 5] with delays specified by the 
%     function ddex1delays and differential equations computed by ddex1de. 
%     The history is evaluated for t <= 0 by the function ddex1hist. 
%     The solution is evaluated at 100 equally spaced points in [0 5]  
%         tint = linspace(0,5);
%         yint = deval(sol,tint);
%     and plotted with 
%         plot(tint,yint);
%     This problem involves constant delays. The help section of DDE23 and 
%     the example DDEX1 show how this problem can be solved using DDE23. 
%     For more examples of solving delay differential equations see DDEX2 
%     and DDEX3.
%
%   Class support for inputs TSPAN, HISTORY, and the results of DELAYS(T,Y) 
%   and DDEFUN(T,Y,Z):
%     float: double, single
%
%   See also DDE23, DDESET, DDEGET, DEVAL.

%   DDESD integrates with the classic four stage, fourth order explicit 
%   Runge-Kutta method and controls the size of the residual of a natural
%   interpolant.  It uses iteration to take steps longer than the delays.

%   Details are to be found in Solving ODEs and DDEs with Residual Control, 
%   L.F. Shampine, Applied Numerical Mathematics, 52 (2005).

%   Jacek Kierzenka, Lawrence F. Shampine
%   Copyright 1984-2010 The MathWorks, Inc.

solver_name = 'ddesd';

% Check inputs
if nargin < 5
  options = [];
  if nargin < 4
    error(message('MATLAB:ddesd:NotEnoughInputs'));    
  end
end

% Stats
nsteps   = 0;
nfailed  = 0;
nfevals  = 0; 

t0 = tspan(1);
tfinal = tspan(end);   % Ignore all entries of tspan except first and last.
if tfinal <= t0
  error(message('MATLAB:ddesd:TspandEndLTtspan1'));
end

sol.solver = solver_name;

if ~isa(ddefun,'function_handle')
  error(message('MATLAB:ddesd:DdefunNotFunctionHandle'));  
end

if ~(isnumeric(delays) || isa(delays,'function_handle'))
  error(message('MATLAB:ddesd:DelaysInvalidType'));  
end

if isnumeric(history)
  temp = history;
  sol.history = history;
elseif isstruct(history)
  if history.x(end) ~= t0
    error(message('MATLAB:ddesd:NotContinueFromHistoryEnd'));
  end
  temp = history.y(:,end);
  sol.history = history.history;  
elseif isa(history,'function_handle')
  temp = history(t0);
  sol.history = history;
else
  error(message('MATLAB:ddesd:HistoryInvalidType'));
end 
y0 = temp(:);
initialy = ddeget(options,'InitialY',[],'fast');
if ~isempty(initialy)
  y0 = initialy(:);
end

neq = length(y0);

% Initialize method parameters.
pow = 1/4;       %  Error is O(h^4) over a step.
sm = [(1/2 - sqrt(3)/6), (1/2 + sqrt(3)/6)];

% Evaluate initial history at delayed arguments, then the slope.
Z0 = lagvals(t0,y0,delays,history,t0,y0,[]);
f0 = ddefun(t0,y0,Z0);
nfevals = nfevals + 1;             
[m,n] = size(f0);
if n > 1
  error(message('MATLAB:ddesd:DDEOutputNotCol'));
elseif m ~= neq
  error(message('MATLAB:ddesd:DDELengthMismatchHistory'));
end

% Determine the dominant data type
classT0 = class(t0);
classY0 = class(y0);
classZ0 = class(Z0);   % class y(d(t0,y0))
classF0 = class(f0);
dataType = superiorfloat(t0,y0,Z0,f0);
if ~( strcmp(classT0,dataType) && strcmp(classY0,dataType) && ...
      strcmp(classZ0,dataType) && strcmp(classF0,dataType))
  warning(message('MATLAB:ddesd:InconsistentDataType'));
end    

% Get options, and set defaults.
% First, check for option found in DDE23, but not DDESD.
jumps = ddeget(options,'Jumps',[],'fast');
if ~isempty(jumps)
  error(message('MATLAB:ddesd:JumpsOptionNotAvailable')); 
end

rtol = ddeget(options,'RelTol',1e-3,'fast');
if ~isscalar(rtol) || (rtol <= 0)
  error(message('MATLAB:ddesd:OptRelTolNotPosScalar'));
end
if rtol < 100 * eps(dataType)
  rtol = 100 * eps(dataType);
  warning(message('MATLAB:ddesd:RelTolIncrease', sprintf( '%g', rtol )))
end

atol = ddeget(options,'AbsTol',1e-6,'fast');
if any(atol <= 0)
  error(message('MATLAB:ddesd:OptAbsTolNotPos'));
end

normcontrol = strcmp(ddeget(options,'NormControl','off','fast'),'on');   

if normcontrol
  if ~isscalar(atol)
    error(message('MATLAB:ddesd:NonScalarAbsTolNormControl'));
  end
  normy = norm(y0);
else
  if ~isscalar(atol) && (numel(atol) ~= neq)
    error(message('MATLAB:ddesd:AbsTolSize', funstring( ddefun ), neq));   
  end
  atol = atol(:);
end
threshold = atol / rtol;
threshold = cast(threshold,dataType);

% By default, hmax is 1/10 of the interval of integration.
hmax = min(tfinal-t0, ddeget(options,'MaxStep',0.1*(tfinal-t0),'fast'));
if hmax <= 0
  error(message('MATLAB:ddesd:OptMaxStepNotPos'));
end

htry = ddeget(options,'InitialStep',[],'fast');
if ~isempty(htry) && (htry <= 0)
  error(message('MATLAB:ddesd:OptInitialStepNotPos'));
end

% Allocate storage for output arrays and initialize them.
chunk = min(100,floor((2^13)/neq));

tout = zeros(1,chunk,dataType);
yout = zeros(neq,chunk,dataType);
ypout = zeros(neq,chunk,dataType);

fnew = zeros(neq,4,dataType);

nout = 1;
tout(nout) = t0;
yout(:,nout) = y0;
ypout(:,nout) = f0;

events = ddeget(options,'Events',[],'fast');
haveeventfun = ~isempty(events);
if haveeventfun
  if ~isa(events,'function_handle')
    error(message('MATLAB:ddesd:OptEventsNotFunctionHandle'));        
  end        
  valt = events(t0,y0,Z0);
end
teout = [];
yeout = [];
ieout = [];

% Handle the output
if nargout > 0
  outputFcn = ddeget(options,'OutputFcn',[],'fast');
else
  outputFcn = ddeget(options,'OutputFcn',@odeplot,'fast');
end
if isempty(outputFcn)
  haveOutputFcn = false;
else
  if ~isa(outputFcn,'function_handle')
    error(message('MATLAB:ddesd:OptOutputFcnNotFunctionHandle'));        
  end    
  haveOutputFcn = true;
  outputs = ddeget(options,'OutputSel',1:neq,'fast');
end
outputArgs = {}; % required by ODEFINALIZE
refine = max(1,ddeget(options,'Refine',1,'fast'));
ntspan = numel(tspan);
if ntspan > 2
  outputAt = 'RequestedPoints';         % output only at tspan points
elseif refine <= 1
  outputAt = 'SolverSteps';             % computed points, no refinement
else
  outputAt = 'RefinedSteps';            % computed points, with refinement
  S = (1:refine-1) / refine;
end
printstats = strcmp(ddeget(options,'Stats','off','fast'),'on');

hmin = 16*eps(t0);
if isempty(htry)
  % Compute an initial step size h using y'(t).
  h = min(hmax, tfinal - t0);
  if normcontrol
    rh = (norm(f0) / max(normy,threshold)) / (0.8 * rtol^pow);
  else
    rh = norm(f0 ./ max(abs(y0),threshold),inf) / (0.8 * rtol^pow);
  end
  if h * rh > 1
    h = 1 / rh;
  end
  h = max(h, hmin);
else
  h = min(hmax, max(hmin, htry));
end
% Initialize the output function.
if haveOutputFcn
  outputFcn([t0 tfinal],y0(outputs),'init');
  next = 2;
end

% THE MAIN LOOP
t = t0;
y = y0;
fnew(:,1) = f0;

firststep = true;
done = false;
while ~done
  
  % By default, hmin is a small number such that t+hmin is only slightly
  % different than t.  It might be 0 if t is 0.
  hmin = 16*eps(t);
  h = min(hmax, max(hmin, h));    % couldn't limit h until new hmin
  
  % Adjust step size to hit tfinal.
  laststep = false;
  distance = tfinal - t;
  if min(1.1*h,hmax) >= distance          % stretch
    h = distance;
    laststep = true;
  elseif 2*h >= distance                  % look-ahead
    h = distance/2; 
  end

  % LOOP FOR ADVANCING ONE STEP.
  nofailed = true;                      % no failed attempts
  
  while true
    % Hit end point exactly.
    if laststep
      tnew = tfinal;          
    else
      tnew = t + h;
    end
    
    % Predict the stages and slopes.
    if firststep
      % Linear prediction.
      ypred = y + h*f0;
      yppred = f0;
    else
      % Hermite extrapolation from previous step.
      [ypred, yppred] = ntrp3h(tnew,tout(nout-1),yout(:,nout-1),...
                        tout(nout),yout(:,nout),ypout(:,nout-1),ypout(:,nout));
    end
    % Load predicted extension of the solution into the solution arrays.
    Tnout = nout + 1;
    if Tnout > length(tout)
      tout  = [tout, zeros(1,chunk,dataType)];
      yout  = [yout, zeros(neq,chunk,dataType)];
      ypout = [ypout, zeros(neq,chunk,dataType)];
    end
    tout(Tnout) = tnew;
    yout(:,Tnout) = ypred;
    ypout(:,Tnout) = yppred;
    
    % Four stage, fourth order formula.
    hB = h*[0, 1/2, 1/2, 1];
    hC = h*[1/6; 1/3; 1/3; 1/6];
    fnew(:,1) = ypout(:,nout);
    % Iterate once if the step is defined implicitly.
    implicit = false;
    for i = 1:2
        
      for j = 2:4
        ytemp = yout(:,nout) + hB(j)*fnew(:,j-1);
        [Z,implicit_step] = lagvals(t+hB(j),ytemp,delays,history,...
                          tout(1:Tnout),yout(:,1:Tnout),ypout(:,1:Tnout));
        fnew(:,j) = ddefun(t+hB(j),ytemp,Z);
        implicit = implicit || implicit_step;
      end
      ynew = yout(:,nout) + fnew*hC;
      [Z,implicit_step] = lagvals(tnew,ynew,delays,history,...
                        tout(1:Tnout),yout(:,1:Tnout),ypout(:,1:Tnout));
      ypout(:,Tnout) = ddefun(tnew,ynew,Z);
      implicit = implicit || implicit_step;
      yout(:,Tnout) = ynew;
      nfevals = nfevals + 4;
      
      if ~implicit
        break;
      end
      
    end
    % Assess the size of the residual.
    err = zeros(dataType);
    if normcontrol
      normynew = norm(ynew);
      wt = max(max(normy,normynew),threshold);      
    else    
      wt = max(max(abs(y),abs(ynew)),threshold);      
    end
    for i = 1:2
      xm = t + h*sm(i);
      [ym,ypm] = ntrp3h(xm,tout(Tnout-1),yout(:,Tnout-1),...
                        tout(Tnout),yout(:,Tnout),ypout(:,Tnout-1),ypout(:,Tnout));  
      Z = lagvals(xm,ym,delays,history,...
                  tout(1:Tnout),yout(:,1:Tnout),ypout(:,1:Tnout)); 
      res = ypm - ddefun(xm,ym,Z);
      nfevals = nfevals + 1;  
      if normcontrol
        err = 2.1342*max(err, h*norm(res) / wt);  
      else
        err = 2.1342*max(err, h*norm(res ./ wt,inf));            
      end      
      if (err > rtol) && ~nofailed
        break;
      end
    end

    % Accept the solution only if the weighted error is no more than the
    % tolerance rtol.  Estimate an h that will yield an error of rtol on
    % the next step or the next try at taking this step, as the case may be,
    % and use 0.8 of this value to avoid failures.
    if err > rtol   
      nfailed = nfailed + 1; 
      if h <= hmin
        warning(message('MATLAB:ddesd:IntegrationTolNotMet', sprintf( '%e', t ), sprintf( '%e', hmin )));        


        sol = odefinalize(solver_name, sol,...
                          outputFcn, outputArgs,...
                          printstats, [nsteps, nfailed, nfevals],...
                          nout, tout, yout,...
                          haveeventfun, teout, yeout, ieout,...
                          {history,ypout});
        return;        
      else 
        if nofailed
          h = h * max(cast(0.5,dataType), 0.8*(rtol/err)^pow);    % "Optimal" reduction
        else
          h = h * 0.5;                             % Potential discontinuity
        end 
        h = max(hmin, h);
        nofailed = false;
        laststep = false;
      end        
    else      % Successful step
      done = laststep;
      break  
    end  
  end
  nsteps = nsteps + 1;                
  % Accept tentative results of step.
  nout = Tnout;

  if haveeventfun
    eventargs = {events, delays, history, tout(1:nout), ...
                 yout(:,1:nout), ypout(:,1:nout)};
    [te,ye,ie,valt,stop] = odezero(@ntrp3h,@events_aux,eventargs,valt,...
                        tout(nout-1),yout(:,nout-1),tout(nout),yout(:,nout),...
                        tout(1),ypout(:,nout-1),ypout(:,nout));
    if ~isempty(te)
      teout = [teout, te];
      yeout = [yeout, ye];
      ieout = [ieout, ie];
      if stop 
        % Stop on a terminal event after the initial point.
        % Make the output arrays end there.
        [yte,ypte] = ntrp3h(te(end),tout(nout-1),yout(:,nout-1),...
                     tout(nout),yout(:,nout),ypout(:,nout-1),ypout(:,nout));   
        tout(nout) = te(end);
        yout(:,nout) = yte;
        ypout(:,nout) = ypte;
        done = true;
      end
    end
  end
  
  if haveOutputFcn
    switch outputAt
     case 'SolverSteps'        % computed points, no refinement
      nout_new = 1;
      tout_new = tout(nout);
      yout_new = yout(:,nout);
     case 'RefinedSteps'       % computed points, with refinement
      tref = tout(nout-1) + (tout(nout)-tout(nout-1))*S;
      nout_new = refine;
      tout_new = [tref, tout(nout)];
      yout_new = [ntrp3h(tref,tout(nout-1),yout(:,nout-1),...
                         tout(nout),yout(:,nout),...
                         ypout(:,nout-1),ypout(:,nout)), yout(:,nout)];
     case 'RequestedPoints'    % output only at tspan points
      nout_new =  0;
      tout_new = [];
      yout_new = [];
      while next <= ntspan  
        if tnew < tspan(next)
          if haveeventfun && stop     % output tstop,ystop
            nout_new = nout_new + 1;
            tout_new = [tout_new, tout(nout)];
            yout_new = [yout_new, yout(:,nout)];            
          end
          break;
        end
        nout_new = nout_new + 1;              
        tout_new = [tout_new, tspan(next)];
        if tspan(next) == tout(nout)
          yout_new = [yout_new, yout(:,nout)];            
        else 
          yout_new = [yout_new, ntrp3h(tspan(next),tout(nout-1),yout(:,nout-1),...
                                       tout(nout),yout(:,nout),ypout(:,nout-1),...
                                       ypout(:,nout))];
        end
        next = next + 1;
      end
    end
    if nout_new > 0
      stop = outputFcn(tout_new,yout_new(outputs,:),'');
      if stop  % Stop per user request.
        done = true;
      end
    end
  end
    
  if ~done
    firststep = false;
    
    % Advance the integration one step.
    t = tout(nout);
    y = yout(:,nout);
    if normcontrol
      normy = normynew;
    end 
    
    % If there were no failures, compute a new h.
    if nofailed 
      % Require that 0.8 <= hnew/h <= 2. 
      h = h / max(cast(0.5,dataType),1.25*(err/rtol)^pow); 
      h = min(max(hmin,h),hmax);
    end
    
  end
  
end

% Successful integration
sol = odefinalize(solver_name, sol,...
                  outputFcn, outputArgs,...
                  printstats, [nsteps, nfailed, nfevals],...
                  nout, tout, yout,...
                  haveeventfun, teout, yeout, ieout,...
                  {history,ypout});

% --------------------------------------------------------------------------

function [Z,implicit_step] = lagvals(tnow,ynow,delays,history,X,Y,YP)
% For each I, Z(:,I) is the solution corresponding to to the value of
% the Ith delay function evaluated at (TNOW, YNOW). This solution can 
% be computed in several ways: the initial history, interpolation of 
% the computed solution, extrapolation of the computed solution, 
% interpolation of the computed solution plus the tentative solution 
% at the end of the current step.  The various ways are set in the 
% calling program when X,Y,YP are formed.

if isnumeric(delays)
  d = tnow - delays;
else % function handle
  d = delays(tnow,ynow);
end
xint = min(tnow,d);

% Check whether any argument is determined implicitly in the current step.
if length(X) == 1
  implicit_step = false;
else
  implicit_step = any(xint > X(end-1));
end

% Typically there are few lags, so it is reasonable to process 
% them one at a time.  NOTE that the delays may not be ordered and 
% that it is necessary to preserve their order in Z.

Nxint = length(xint);
if isstruct(history)
  given_history = history.history;
  tstart = history.x(1);
  neq = length(history.y(:,1));
else
  neq = length(ynow(:,1));
end
Z = zeros(neq,Nxint,class(Y));

for j = 1:Nxint
  if xint(j) < X(1)
    if isnumeric(history)
      temp = history;
    elseif isstruct(history)
      % Is xint(j) in the given history?          
      if xint(j) < tstart
        if isnumeric(given_history)
          temp = given_history;
        else % function handle
          temp = given_history(xint(j));
        end
      else    
        % Evaluate computed history by interpolation. Mute unwanted warning.
        ws = warning('off','MATLAB:deval:NonuniqueSolution');
        temp = deval(history,xint(j));
        warning(ws);
      end
    else % function handle
      temp = history(xint(j));
    end
    Z(:,j) = temp(:); 
  elseif xint(j) == X(1)   % Special case for initialization.
    Z(:,j) = Y(:,1);  
  else
    % Find n for which X(n) <= xint(j) <= X(n+1).  xint(j) bigger
    % than X(end) are evaluated by extrapolation, so n = end-1 then.
    n = find(xint(j) >= X(1:end-1),1,'last');
    Z(:,j) = ntrp3h(xint(j),X(n),Y(:,n),X(n+1),Y(:,n+1),YP(:,n),YP(:,n+1));
  end
end

% --------------------------------------------------------------------------

function [vtry,isterminal,direction] = events_aux(ttry,ytry,eventfun,...
                                         delays,history,X,Y,YP)
% Auxiliary function used to detect events.
Z = lagvals(ttry,ytry,delays,history,X,Y,YP);
[vtry,isterminal,direction] = eventfun(ttry,ytry,Z);

