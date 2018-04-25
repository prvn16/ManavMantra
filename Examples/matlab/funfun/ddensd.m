function sol = ddensd(ddefun,dely,delyp,history,tspan,options)
%DDENSD  Solve delay differential equations of neutral type.
%   SOL = DDENSD( DDEFUN, DELY, DELYP, HISTORY, TSPAN) integrates a system
%   of delay differential equations of neutral type (NDDEs), that has the form 
%       y'(t) = f(t,y(t),y(dy(1)),...,y(dy(ndy)),y'(dyp(1)),...,y'(dyp(ndyp))) 
%   DELY is a function handle, that for t and y, returns a column vector of 
%   length ndy containing the solution delays dy. Similarly, DELYP is a 
%   function handle, that for t and y, returns a column vector of length ndyp 
%   containing derivative delays dyp. DDENSD imposes the requirement that each 
%   solution delay, dy, is less than or equal to t. Except for "initial-value" 
%   DDEs, the derivative delays, dyp, must satisfy dyp < t. 
%   If all delays have the form dy(j) = t - tau_j, you can set the argument 
%   DELY to a constant vector DELY(j) = tau_j, and similarly for dyp and DELYP. 
%   Use the placeholder [] for DELY or DELYP if dy or dyp is not present in 
%   the problem.  
%   DDEFUN is a function handle for the derivative function. It must return 
%   a column vector corresponding to: 
%       f(t,y(t),y(dy(1)),...,y(dy(ndy)),y'(dyp(1)),...,y'(dyp(ndyp))).             
%   In the calls DDEFUN(T,Y,YDEL,YPDEL), DELY(T,Y), and DELYP(T,Y), a scalar
%   T is the current t and a column vector Y approximates y(t). In DDEFUN, 
%   the columns YDEL(:,j) approximate y(dy(j)), while columns YPDEL(:,k) 
%   approximate y'(dyp(k)). 
%   The DDEs are integrated from T0 to TF where T0 < TF and TSPAN = [T0,TF]. 
%   The solution at t <= T0 is specified by HISTORY in one of four ways: 
%   HISTORY can be a function handle, where for a scalar T, HISTORY(T) returns 
%   the column vector y(t). If y(t) is constant, HISTORY can be this column 
%   vector. If this call to DDENSD continues a previous integration to T0, 
%   HISTORY can be the solution, SOL, from the previous call. An "initial-value" 
%   DDE has dy(j) >= T0 and dyp(k) >= T0, for all j and k. At t = T0, all 
%   delayed terms reduce to y(dy(j)) = y(T0) and y'(dyp(k) = y'(T0). For t > T0, 
%   all derivative delays must satisfy dyp < t. For initial-value DDEs, HISTORY 
%   must be a cell array {Y0,YP0}. Here, Y0 is the column vector of initial 
%   values, y(T0), and YP0 is a column vector of initial derivatives, y'(T0). 
%   These vectors must be "consistent", meaning that they satisfy the DDE at T0:
%       y'(T0) = f(T0,y(T0),y(T0),...,y(T0),y'(T0),...,y'(T0)).  
%   You must supply y'(T0) for an initial-value DDE because there might not
%   be a unique value y'(T0) consistent with y(T0).
%
%   DDENSD produces a solution that is continuous on [T0,TF]. You can evaluate 
%   the solution at points TINT using YINT = DEVAL(SOL,TINT), where SOL is the 
%   structure returned by DDENSD. SOL has the following fields: 
%       SOL.x  -- mesh selected by DDENSD
%       SOL.y  -- approximation to y(t) at the mesh points of SOL.x
%       SOL.yp -- approximation to y'(t) at the mesh points of SOL.x
%       SOL.solver -- 'ddensd'
%
%   SOL = DDENSD(DDEFUN,DELY,DELYP,HISTORY,TSPAN,OPTIONS) solves as above 
%   with default parameters replaced by values in OPTIONS, a structure 
%   created with the DDESET function. See DDESET for details. Commonly used 
%   options are scalar relative error tolerance 'RelTol' (1e-3 by default) 
%   and vector of absolute error tolerances 'AbsTol' (all components 1e-6 by 
%   default). The method implemented in DDENSD is intended only for modest 
%   accuracy, so a value of 'RelTol' less than 1e-5 is increased to 1e-5.
%
%   With the 'Events' property in OPTIONS set to a function handle EVENTS, 
%   DDENSD solves as above while also finding where event functions 
%   g(t,y(t),y(dy(1)),...,y(dy(ndy)),y'(dyp(1)),...,y'(dyp(ndyp))) are zero. 
%   For each function you specify whether the integration is to terminate 
%   at a zero and whether the direction of the zero crossing matters. These 
%   are the three vectors returned by EVENTS: 
%       [VALUE,ISTERMINAL,DIRECTION] = EVENTS(T,Y,YDEL,YPDEL). 
%   For the I-th event function: VALUE(I) is the value of the function, 
%   ISTERMINAL(I) = 1 if the integration is to terminate at a zero of this 
%   event function and 0 otherwise. DIRECTION(I) = 0 if all zeros are to
%   be computed (the default), +1 if only zeros where the event function is
%   increasing, and -1 if only zeros where the event function is decreasing. 
%   The field SOL.xe is a row vector of times at which events occur. Columns
%   of SOL.ye are the corresponding solutions, and indices in vector SOL.ie
%   specify which event occurred.   
%
%   Two example programs are available for DDENSD. Each solves a problem 
%   with default tolerances and plots a numerical solution along with some 
%   values of an analytical solution.
%       DDEX4 solves 1 equation with 2 delay functions. DEVAL is used to
%             get values of the numerical solution at specific times.
%       DDEX5 solves an initial-value DDE with the delay function t/2. It
%             solves for both of the 2 consistent values of y'(T0).
%   See examples DDEX1, DDEX2, and DDEX3 for use of DDE23 and DDESD solvers.    
%
%   Class support for inputs TSPAN, HISTORY, and the results of DELY(T,Y),
%   DELYP(T,Y), and DDEFUN(T,Y,YDEL,YPDEL):
%     float: double, single
%
%   See also DDE23, DDESD, DDESET, DDEGET, DEVAL.

%   DDE23/DDESD integrate DDEs with delayed arguments in y -- retarded DDEs.
%   DDENSD integrates DDEs with delayed arguments in y and y' -- neutral
%   DDEs. DDEs generally have solutions y(t) with discontinuities in low 
%   order derivatives that propagate. The order of a discontinuity in the 
%   solution of a retarded DDE increases every time it propagates, but that 
%   does not happen for a neutral DDE. DDENSD approximates a neutral DDE 
%   with a retarded DDE, so discontinuities in y(t) are eventually smoothed 
%   in the numerical solution. This is somewhat like using a dissipative 
%   numerical method to approximate a shock in fluid flow.

%   Details are to be found in Dissipative Approximations to Neutral DDEs, 
%   L.F. Shampine, Applied Mathematics and Computation, 203 (2008).

%   Copyright 2012 The MathWorks, Inc.

solver_name = 'ddensd';

% Check inputs
if nargin < 6
    options = [];
    if nargin < 5
        error(message('MATLAB:ddensd:NotEnoughInputs'));    
    end
end

if ~isa(ddefun,'function_handle')
    error(message('MATLAB:ddensd:DdefunNotFunctionHandle'));  
end

a = tspan(1);
Nhistory = history;

IVP = false;
IVP_T0 = []; 
IVP_Y0 = [];
IVP_YP0 = [];

if isa(history,'function_handle')
    ya = history(a); 
elseif iscell(history)
    ya  = history{1}; 
    ypa = history{2};     
    IVP = true;
    IVP_T0 = a;
    IVP_Y0 = ya(:);
    IVP_YP0 = ypa(:);
    Nhistory = ya;  
elseif isnumeric(history)
    ya = history;
elseif isa(history,'struct')
    if ~isfield(history,'solver') || ~strcmp(history.solver,solver_name) 
        error(message('MATLAB:ddensd:HistoryNotFromDDENSD'))
    end           
    if history.x(end) ~= a   
        error(message('MATLAB:ddensd:NotContinueFromHistoryEnd'))
    end       
    ya = history.y(:,end);
    IVP = history.IVP;
    if IVP
        IVP_T0 = history.x(1);
        IVP_Y0 = history.history{1};
        IVP_YP0 = history.history{2};
        Nhistory.history = IVP_Y0;  % Nhistory.history must conform to DDESD
    end
else
    error(message('MATLAB:ddensd:HistoryInvalidType'));
end
ya = ya(:);

if isa(dely,'function_handle')
    ydel = dely;
elseif isempty(dely)
    ydel = @(~,~) [];
elseif isnumeric(dely) && isvector(dely)
    ydel = @(t,~) t - dely(:);  
else
    error(message('MATLAB:ddensd:DelyInvalidType'));  
end

if isa(delyp,'function_handle')
    ypdel = delyp;
elseif isempty(delyp)
    ypdel = @(~,~) [];
elseif isnumeric(delyp) && isvector(delyp)
    ypdel = @(t,~) t - delyp(:);
else
    error(message('MATLAB:ddensd:DelypInvalidType')); 
end

% Sizes and indices
D = ydel(a,ya);
Dp = ypdel(a,ya);
nydel = numel(D);
nypdel = numel(Dp);

yIdx = 1:nydel;
ypIdx = nydel+(1:nypdel);
ypdIdx = nydel+nypdel+(1:nypdel);

% Determine the dominant data type
classT  = class(tspan);
classY  = class(ya);
classD  = class(D);   
classDP = class(Dp);
dataType = superiorfloat(a,ya,D,Dp);
if ~( strcmp(classT,dataType) && strcmp(classY,dataType)  && ...
      strcmp(classD,dataType) && strcmp(classDP,dataType))
    warning(message('MATLAB:ddensd:InconsistentDataType'));
    % Mute corresponding DDESD warning
    ws = warning('off','MATLAB:ddesd:InconsistentDataType');
    restoreWarningInconsistentDataType = onCleanup(@() warning(ws));
end    

epsT = eps(classT);
DELTA = sqrt(epsT);
MINCHANGE = DELTA*norm(tspan,inf);

% Check for option found in DDE23, but not DDENSD.
jumps = ddeget(options,'Jumps',[],'fast');
if ~isempty(jumps)
    error(message('MATLAB:ddensd:JumpsOptionNotAvailable')); 
end

% Adjust RelTol if needed
rtol = ddeget(options,'RelTol',1e-3,'fast');
if ~isscalar(rtol) || (rtol <= 0)
    error(message('MATLAB:ddensd:OptRelTolNotPosScalar'));
end
if rtol < 1e-5
    rtol = 1e-5; 
    warning(message('MATLAB:ddensd:RelTolIncrease',sprintf('%g',rtol)))
    options = ddeset(options,'RelTol',rtol);
end

% Handle event detection
events = ddeget(options,'Events',[],'fast');
if ~isempty(events)
    options = ddeset(options,'Events',@Nevents);
end

ws = warning('off','MATLAB:deval:NonuniqueSolution');
restoreWarningNonuniqueSolution = onCleanup(@() warning(ws));

try
    sol = ddesd(@Ndde,@Ndelays,Nhistory,tspan,options);  
catch e
    id = strrep(e.identifier,':ddesd:',':ddensd:');
    if isempty(id)  
        error(e.message);
    else
        error(id,e.message);
    end
end

sol.IVP = IVP;
if IVP
    sol.history = {IVP_Y0,IVP_YP0};
end
sol.solver = solver_name;   

%== Nested Functions ======================================================

function v = Ndelays(t,y)
% Evaluate delays    
    D = ydel(t,y);
    Dp = ypdel(t,y);
    
    if any(Dp > t)
        error(message('MATLAB:ddensd:DELYPGreaterThanT',sprintf('%g',t)));
    end

    if IVP  
        if any(D < IVP_T0)
            error(message('MATLAB:ddensd:DELYLessThanT0',sprintf('%g',t)));
        end
        if any(Dp < IVP_T0)
            error(message('MATLAB:ddensd:DELYPLessThanT0',sprintf('%g',t)));
        end
        if (any(Dp == t) && (t > IVP_T0))  
            error(message('MATLAB:ddensd:IVPDELYPEqualT',sprintf('%g',t)));  
        end
    else
        if any(Dp == t) 
            error(message('MATLAB:ddensd:DELYPEqualT',sprintf('%g',t)));  
        end
    end
    Dpd = Dp - max(DELTA*abs(Dp),MINCHANGE);
    v = [D(:);Dp(:);Dpd(:)];  
end % Ndelays

%--------------------------------------------------------------------------

function ypdel = Nypdel(t,y,ydel,ydeld)
% Approximate yp(del) with (y(del)-y(del-d))/d    
    D = Ndelays(t,y);    
    del = D(ypIdx);
    deld = D(ypdIdx); 
    d = del - deld;
    ypdel = (ydel - ydeld)*diag(1./d);     
    if IVP
        % If perturbed argument is less than IVP_T0, use  
        % IVP_YP0 instead of difference quotient for derivative.
        ndx = (deld <= IVP_T0);
        ypdel(:,ndx) = repmat(IVP_YP0,1,nnz(ndx));
    end    
end % Nypdel

%--------------------------------------------------------------------------

function dydt = Ndde(t,y,Z)
% Evaluate differential equations    
    [Z,Zp,Zpd] = deal(Z(:,yIdx),Z(:,ypIdx),Z(:,ypdIdx));
    ZP = Nypdel(t,y,Zp,Zpd);  % approx delayed derivative
    dydt = ddefun(t,y,Z,ZP);    
end % Ndde

%--------------------------------------------------------------------------

function [value,isterminal,direction] = Nevents(t,y,Z)
% Evaluate events function    
    [Z,Zp,Zpd] = deal(Z(:,yIdx),Z(:,ypIdx),Z(:,ypdIdx));
    ZP = Nypdel(t,y,Zp,Zpd);  % approx delayed derivative
    [value,isterminal,direction] = events(t,y,Z,ZP);    
end % Nevents

%==========================================================================
end % ddensd
