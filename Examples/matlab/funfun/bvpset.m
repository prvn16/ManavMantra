function options = bvpset(varargin)
%BVPSET  Create/alter BVP OPTIONS structure.
%   OPTIONS = BVPSET('NAME1',VALUE1,'NAME2',VALUE2,...) creates an integrator
%   options structure OPTIONS in which the named properties have the
%   specified values. Any unspecified properties have default values. It is 
%   sufficient to type only the leading characters that uniquely identify the
%   property. Case is ignored for property names. 
%   
%   OPTIONS = BVPSET(OLDOPTS,'NAME1',VALUE1,...) alters an existing options
%   structure OLDOPTS. 
%   
%   OPTIONS = BVPSET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS. Any new properties overwrite 
%   corresponding old properties. 
%   
%   BVPSET with no input arguments displays all property names and their
%   possible values. 
%   
%BVPSET PROPERTIES
%   
%RelTol - Relative tolerance for the residual [ positive scalar {1e-3} ]
%   This scalar applies to all components of the residual vector, and
%   defaults to 1e-3 (0.1% accuracy). The computed solution S(x) is the exact
%   solution of S'(x) = F(x,S(x)) + res(x). In BVP4C, on each subinterval 
%   of the mesh, component i of the residual satisfies  
%          norm( res(i) / max( [abs(F(i)) , AbsTol(i)/RelTol] ) ) <= RelTol.
%   In BVP5C, the residual satisfies  
%     norm( h(j)*res(i) / max( [abs(y(i)) , AbsTol(i)/RelTol] ) ) <= RelTol,
%   where h(j) is the length of subinterval j. Generally component i of the
%   error e(x) = y(x) - S(x) then satisfies
%     norm( e(i) / max( [abs(y(i)) , AbsTol(i)/RelTol] ) ) <= RelTol.
%
%AbsTol - Absolute tolerance for the residual [ positive scalar or vector {1e-6} ]
%   A scalar tolerance applies to all components of the residual vector. 
%   Elements of a vector of tolerances apply to corresponding components of
%   the residual vector. AbsTol defaults to 1e-6. See RelTol. 
%
%SingularTerm - Singular term of singular BVPs [ matrix ]
%   Set to the constant matrix S for equations of the form y' = S*y/x + f(x,y,p).
%
%FJacobian - Analytical partial derivatives of ODEFUN 
%          [ function_handle | matrix | cell array ]
%   For example, when solving y' = f(x,y), set this property to @FJAC if
%   DFDY = FJAC(X,Y) evaluates the Jacobian of f with respect to y.
%   If the problem involves unknown parameters, [DFDY,DFDP] = FJAC(X,Y,P)
%   must also return the partial derivative of f with respect to p.  
%   For problems with constant partial derivatives, set this property to
%   the value of DFDY or to a cell array {DFDY,DFDP}.
%
%BCJacobian - Analytical partial derivatives of BCFUN 
%           [ function_handle | cell array ]
%   For example, for boundary conditions bc(ya,yb) = 0, set this property to
%   @BCJAC if [DBCDYA,DBCDYB] = BCJAC(YA,YB) evaluates the partial
%   derivatives of bc with respect to ya and to yb. If the problem involves
%   unknown parameters, [DBCDYA,DBCDYB,DBCDP] = BCJAC(YA,YB,P) must also
%   return the partial derivative of bc with respect to p. 
%   For problems with constant partial derivatives, set this
%   property to a cell array {DBCDYA,DBCDYB} or {DBCDYA,DBCDYB,DBCDP}.
%
%Nmax - Maximum number of mesh points allowed [positive integer {floor(10000/n)}]
%
%Stats - Display computational cost statistics  [ on | {off} ]
%
%Vectorized - Vectorized ODE function  [ on | {off} ]
%   Set this property 'on' if the derivative function 
%   ODEFUN([x1 x2 ...],[y1 y2 ...]) returns [ODEFUN(x1,y1) ODEFUN(x2,y2) ...].  
%   When parameters are present, the derivative function
%   ODEFUN([x1 x2 ...],[y1 y2 ...],p) should return 
%   [ODEFUN(x1,y1,p) ODEFUN(x2,y2,p) ...].  
%
%   See also BVPGET, BVPINIT, BVP4C, BVP5C, DEVAL, FUNCTION_HANDLE.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2016 The MathWorks, Inc.

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
  fprintf('          AbsTol: [ positive scalar or vector {1e-6} ]\n');
  fprintf('          RelTol: [ positive scalar {1e-3} ]\n');  
  fprintf('    SingularTerm: [ matrix ]\n'); 
  fprintf('       FJacobian: [ function_handle ]\n');
  fprintf('      BCJacobian: [ function_handle ]\n');
  fprintf('           Stats: [ on | {off} ]\n');
  fprintf('            Nmax: [ nonnegative integer {floor(10000/n)} ]\n'); 
  fprintf('      Vectorized: [ on | {off} ]\n'); 
  fprintf('\n');
  return;
end

Names = { 'AbsTol', 'RelTol', 'SingularTerm', 'FJacobian', ...
    'BCJacobian', 'Stats', 'Nmax', 'Vectorized' };
m = length(Names);

% Combine all leading options structures o1, o2, ... in odeset(o1,o2,...).
options = [];
i = 1;
while i <= nargin
  arg = varargin{i};
  if ischar(arg) || (isstring(arg) && isscalar(arg)) % arg is an option name
    break;
  end
  if ~isempty(arg)                      % [] is a valid options argument
    if ~isa(arg,'struct')
      error(message('MATLAB:bvpset:NoPropNameOrStruct', i));
    end
    if isempty(options)
      options = arg;
    else
      for j = 1:m
        val = arg.(Names{j});
        if ~isequal(val,[])             % empty strings '' do overwrite
          options.(Names{j}) = val;
        end
      end
    end
  end
  i = i + 1;
end
if isempty(options)
  for j = 1:m
    options.(Names{j}) = [];
  end
end
% Convert string arguments and options.
for ii = 1:nargin
    if isstring(varargin{ii}) && isscalar(varargin{ii})
        varargin{ii} = char(varargin{ii});
    end
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
  error(message('MATLAB:bvpset:ArgNameValueMismatch'));
end
expectval = 0;                      % start expecting a name, not a value
while i <= nargin
  arg = varargin{i};    
  if ~expectval
    if ~ischar(arg)
      error(message('MATLAB:bvpset:PropNameNotString', i));
    end
    j = strncmpi(arg, Names, length(arg));
    if ~any(j)                       % if no matches
      error(message('MATLAB:bvpset:InvalidPropName', arg));
    elseif nnz(j) > 1                % if more than one match
      % No names are subsets of others, so there will be no exact match
      msg = strjoin(Names(j), ', ');
      error(message('MATLAB:bvpset:AmbiguousPropName', arg, msg));
    end
    expectval = true;                      % we expect a value next    
  else
    options.(Names{j}) = arg;
    expectval = false;      
  end
  i = i + 1;
end

if expectval
  error(message('MATLAB:bvpset:NoValueForProp', arg));
end
