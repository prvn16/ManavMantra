function [x,resnorm,resid,exitflag,output,lambda] = lsqnonneg(C,d,options,varargin)
%LSQNONNEG Linear least squares with nonnegativity constraints.
%   X = LSQNONNEG(C,d) returns the vector X that minimizes NORM(d-C*X)
%   subject to X >= 0. C and d must be real.
%
%   X = LSQNONNEG(C,d,OPTIONS) minimizes with the default optimization
%   parameters replaced by values in the structure OPTIONS, an argument
%   created with the OPTIMSET function.  See OPTIMSET for details. Used
%   options are Display and TolX. (A default tolerance TolX of 
%   10*MAX(SIZE(C))*NORM(C,1)*EPS is used.) 
%   
%   X = LSQNONNEG(PROBLEM) finds the minimum for PROBLEM. PROBLEM is a
%   structure with the matrix 'C' in PROBLEM.C, the vector 'd' in
%   PROBLEM.d, the options structure in PROBLEM.options, and solver name
%   'lsqnonneg' in PROBLEM.solver. 
%
%   [X,RESNORM] = LSQNONNEG(...) also returns the value of the squared 2-norm of 
%   the residual: norm(d-C*X)^2.
%
%   [X,RESNORM,RESIDUAL] = LSQNONNEG(...) also returns the value of the  
%   residual: d-C*X.
%   
%   [X,RESNORM,RESIDUAL,EXITFLAG] = LSQNONNEG(...) returns an EXITFLAG that
%   describes the exit condition. Possible values of EXITFLAG and the
%   corresponding exit conditions are
%
%    1  LSQNONNEG converged with a solution X.
%    0  Iteration count was exceeded. Increasing the tolerance
%       (OPTIONS.TolX) may lead to a solution.
%  
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQNONNEG(...) returns a structure
%   OUTPUT with the number of steps taken in OUTPUT.iterations, the type of 
%   algorithm used in OUTPUT.algorithm, and the exit message in OUTPUT.message.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQNONNEG(...) returns 
%   the dual vector LAMBDA  where LAMBDA(i) <= 0 when X(i) is (approximately) 0 
%   and LAMBDA(i) is (approximately) 0 when X(i) > 0.
% 
%   See also LSCOV, SLASH.

%   Copyright 1984-2016 The MathWorks, Inc. 

% Reference:
%  Lawson and Hanson, "Solving Least Squares Problems", Prentice-Hall, 1974.

% Check if more inputs have been passed. In that case error.
if nargin > 4
    error('MATLAB:lsqnonneg:TooManyInputs',...
        getString(message('MATLAB:optimfun:lsqnonneg:TooManyInputs')));
end

defaultopt = struct('Display','notify','TolX','10*eps*norm(C,1)*length(C)');
% If just 'defaults' passed in, return the default options in X
if nargin == 1 && nargout <= 1 && strcmpi(C,'defaults')
    x = defaultopt;
    return
end

if nargin < 3
    options = [];
end

if nargin == 1
    % Detect problem structure input
    if isa(C,'struct')
        [C,d,options] = separateOptimStruct(C);
    else % Single input and non-structure.
        error('MATLAB:lsqnonneg:InputArg',...
            getString(message('MATLAB:optimfun:lsqnonneg:InputArg')));
    end
end

if nargin == 0
    error('MATLAB:lsqnonneg:NotEnoughInputs',...
        getString(message('MATLAB:optimfun:lsqnonneg:NotEnoughInputs')));
end

if ~isreal(C) || ~isreal(d)
    error('MATLAB:lsqnonneg:ComplexCorD',...
        getString(message('MATLAB:optimfun:lsqnonneg:ComplexCorD')));
end

% Check for non-double inputs
if ~isa(C,'double') || ~isa(d,'double')
    error('MATLAB:lsqnonneg:NonDoubleInput',...
        getString(message('MATLAB:optimfun:lsqnonneg:NonDoubleInput')));
end

% Check if options was created with optimoptions
if ~isempty(options) && isa(options,'optim.options.SolverOptions')
    error('MATLAB:lsqnonneg:ArgNotStruct',...
        getString(message('MATLAB:optimfun:commonMessages:ArgNotStruct', 3)));
end
% Check for deprecated syntax
options = deprecateX0(options,nargin,varargin{:});

printtype = optimget(options,'Display',defaultopt,'fast');
tol = optimget(options,'TolX',defaultopt,'fast');

% In case the defaults were gathered from calling: optimset('lsqnonneg'):
if ischar(tol) || (isstring(tol) && isscalar(tol))
    if strcmpi(tol,'10*eps*norm(c,1)*length(c)')
        tol = 10*eps*norm(C,1)*length(C);
    else
        error('MATLAB:lsqnonneg:OptTolXNotPosScalar',...
            getString(message('MATLAB:optimfun:lsqnonneg:OptTolXNotPosScalar')));
    end
end

switch printtype
    case {'notify','notify-detailed'}
        verbosity = 1;
    case {'none','off'}
        verbosity = 0;
    case {'iter','iter-detailed'}
        warning('MATLAB:lsqnonneg:InvalidDisplayValueIter',...
            getString(message('MATLAB:optimfun:lsqnonneg:InvalidDisplayValueIter')));
        verbosity = 3;
    case {'final','final-detailed'}
        verbosity = 2;
    otherwise
        error('MATLAB:lsqnonneg:InvalidOptParamDisplay',...
            getString(message('MATLAB:optimfun:lsqnonneg:InvalidOptParamDisplay')));
end

n = size(C,2);
% Initialize vector of n zeros and Infs (to be used later)
nZeros = zeros(n,1);
wz = nZeros;

% Initialize set of non-active columns to null
P = false(n,1);
% Initialize set of active columns to all and the initial point to zeros
Z = true(n,1);
x = nZeros;

resid = d - C*x;
w = C'*resid;

% Set up iteration criterion
outeriter = 0;
iter = 0;
itmax = 3*n;
exitflag = 1;

% Outer loop to put variables into set to hold positive coefficients
while any(Z) && any(w(Z) > tol)
   outeriter = outeriter + 1;
   % Reset intermediate solution z
   z = nZeros; 
   % Create wz, a Lagrange multiplier vector of variables in the zero set.
   % wz must have the same size as w to preserve the correct indices, so
   % set multipliers to -Inf for variables outside of the zero set.
   wz(P) = -Inf;
   wz(Z) = w(Z);
   % Find variable with largest Lagrange multiplier
   [~,t] = max(wz);
   % Move variable t from zero set to positive set
   P(t) = true;
   Z(t) = false;
   % Compute intermediate solution using only variables in positive set
   z(P) = C(:,P)\d;
   % inner loop to remove elements from the positive set which no longer belong
   while any(z(P) <= 0)
       iter = iter + 1;
       if iter > itmax
           msg = getString(message('MATLAB:optimfun:lsqnonneg:IterationCountExceeded'));
           if verbosity
               disp(msg)
           end
           exitflag = 0;
           output.iterations = outeriter;
           output.message = msg;
           output.algorithm = 'active-set';
           resnorm = sum(resid.*resid);
           x = z;
           lambda = w;
           return
       end
       % Find indices where intermediate solution z is approximately negative
       Q = (z <= 0) & P;
       % Choose new x subject to keeping new x nonnegative
       alpha = min(x(Q)./(x(Q) - z(Q)));
       x = x + alpha*(z - x);
       % Reset Z and P given intermediate values of x
       Z = ((abs(x) < tol) & P) | Z;
       P = ~Z;
       z = nZeros;           % Reset z
       z(P) = C(:,P)\d;      % Re-solve for z
   end
   x = z;
   resid = d - C*x;
   w = C'*resid;
end

lambda = w;
resnorm = resid'*resid;
output.iterations = outeriter;
output.algorithm = 'active-set';
msg = getString(message('MATLAB:optimfun:lsqnonneg:OptimizationTerminated'));
if verbosity > 1
    disp(msg)
end
output.message = msg;


%--------------------------------------------------------------------------
function options = deprecateX0(options,numInputs,varargin)
% Code to check if user has passed in x0. If so, ignore it and warn of its
% deprecation. Also check whether the options have been passed in either
% the 3rd or 4th input.
if numInputs == 4
    % 4 inputs given; the 3rd (variable name "options") will be interpreted
    % as x0, and the 4th as options
    if ~isempty(options)
        % x0 is non-empty
        warning('MATLAB:lsqnonneg:ignoringX0',...
            getString(message('MATLAB:optimfun:lsqnonneg:ignoringX0')));
    end
    % Take the 4th argument as the options
    options = varargin{1};
elseif numInputs == 3
    % Check if a non-empty or non-struct has been passed in for options
    % If so, assume that it's an attempt to pass x0
    if ~isstruct(options) && ~isempty(options)
        warning('MATLAB:lsqnonneg:ignoringX0',...
            getString(message('MATLAB:optimfun:lsqnonneg:ignoringX0')));
        % No options passed, set to empty
        options = [];
    end
end
