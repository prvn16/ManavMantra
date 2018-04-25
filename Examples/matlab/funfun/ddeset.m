function options = ddeset(varargin)
%DDESET  Create/alter DDE OPTIONS structure.
%   OPTIONS = DDESET('NAME1',VALUE1,'NAME2',VALUE2,...) creates an integrator
%   options structure OPTIONS in which the named properties have the
%   specified values. Any unspecified properties have default values. It is
%   sufficient to type only the leading characters that uniquely identify the
%   property. Case is ignored for property names. 
%   
%   OPTIONS = DDESET(OLDOPTS,'NAME1',VALUE1,...) alters an existing options
%   structure OLDOPTS.
%   
%   OPTIONS = DDESET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS. Any new properties
%   overwrite corresponding old properties. 
%   
%   DDESET with no input arguments displays all property names and their
%   possible values.
%   
%DDESET PROPERTIES
%   
%RelTol - Relative error tolerance  [ positive scalar {1e-3} ]
%   This scalar applies to all components of the solution vector, and
%   defaults to 1e-3 (0.1% accuracy).  The estimated error in each 
%   integration step satisfies e(i) <= max(RelTol*abs(y(i)),AbsTol(i)).
%
%AbsTol - Absolute error tolerance  [ positive scalar or vector {1e-6} ]
%   A scalar tolerance applies to all components of the solution vector.
%   Elements of a vector of tolerances apply to corresponding components of
%   the solution vector.  AbsTol defaults to 1e-6.
%
%NormControl - Control error relative to norm of solution  [ on | {off} ]
%   Set this property 'on' to request that the solver controls the error in
%   each integration step with norm(e) <= max(RelTol*norm(y),AbsTol). By
%   default the solver uses a more stringent component-wise error control. 
%
%Events - Locate events  [ function_handle ]
%   To detect events, set this property to the event function.
%   
%InitialStep - Suggested initial step size  [ positive scalar ]
%   The solver will try this first.  By default the solver determines an
%   initial step size automatically.
%
%MaxStep - Upper bound on step size  [ positive scalar ]
%   MaxStep defaults to one-tenth of the tspan interval.
%   
%OutputFcn - Installable output function  [ function_handle ]
%   This output function is called by the solver after each time step. When
%   the solver is called with no output arguments, OutputFcn defaults to 
%   @odeplot. Otherwise, OutputFcn defaults to [].
%   
%OutputSel - Output selection indices  [ vector of integers ]
%   This vector of indices specifies which components of the solution vector
%   are passed to the OutputFcn. OutputSel defaults to all components.
%   
%Refine - Output refinement factor  [ positive integer {1} ]
%   This property increases the number of points passed to the OutputFcn 
%   after each integration step, resulting in a smoother output. Refine 
%   does not apply if length(TSPAN) > 2. 
%
%Stats - Display computational cost statistics  [ on | {off} ]
%   
%InitialY - Initial value of solution [ vector ]
%   By default the initial value of the solution is the value returned by
%   HISTORY at the initial point.  A different initial value can be supplied
%   as the value of the InitialY property.
%
%Jumps - Discontinuities in solution [ vector ]
%   Points t where the history or solution may have a jump discontinuity
%   in a low order derivative. This property is available only in DDE23.
%   
%   See also DDEGET, DDE23, DDESD, DDENSD, FUNCTION_HANDLE.

%   Copyright 1984-2016 The MathWorks, Inc.

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
  fprintf('          AbsTol: [ positive scalar or vector {1e-6} ]\n');
  fprintf('          Events: [ function_handle ]\n');
  fprintf('     InitialStep: [ positive scalar ]\n');
  fprintf('        InitialY: [ vector ]\n');
  fprintf('           Jumps: [ vector ]\n');  
  fprintf('         MaxStep: [ positive scalar ]\n');
  fprintf('     NormControl: [ on | {off} ]\n');
  fprintf('       OutputFcn: [ function_handle ]\n');
  fprintf('       OutputSel: [ vector of integers ]\n');
  fprintf('          Refine: [ positive integer {1} ]\n');  
  fprintf('          RelTol: [ positive scalar {1e-3} ]\n');
  fprintf('           Stats: [ on | {off} ]\n');
  fprintf('\n');
  return;
end

Names = { 'AbsTol', 'Events', 'InitialStep', 'InitialY', 'Jumps', ...
    'MaxStep', 'NormControl', 'OutputFcn', 'OutputSel', 'Refine', ...
    'RelTol', 'Stats' };
m = length(Names);

% Combine all leading options structures o1, o2, ... in ddeset(o1,o2,...).
options = [];
for j = 1:m
  options.(Names{j}) = [];
end
i = 1;
while i <= nargin
  arg = varargin{i};
  if ischar(arg) || (isstring(arg) && isscalar(arg)) % arg is an option name
    break;
  end
  if ~isempty(arg)                      % [] is a valid options argument
    if ~isa(arg,'struct')
      error(message('MATLAB:ddeset:NoPropNameOrStruct', i));
    end
    for j = 1:m
      if any(strcmp(fieldnames(arg),Names{j}))
        val = arg.(Names{j});
      else
        val = [];
      end
      if ~isempty(val)
        options.(Names{j}) =  val;
      end
    end
  end
  i = i + 1;
end
% Convert string arguments and options.
for ii = 1:nargin
    if isstring(varargin{ii}) && isscalar(varargin{ii})
        varargin{ii} = char(varargin{ii});
    end
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
  error(message('MATLAB:ddeset:ArgNameValueMismatch'));
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin
  arg = varargin{i};
    
  if ~expectval
    if ~ischar(arg)
      error(message('MATLAB:ddeset:PropNameNotString', i));
    end
    j = strncmpi(arg, Names, length(arg));
    if ~any(j)                       % if no matches
      error(message('MATLAB:ddeset:InvalidPropName', arg));
    elseif nnz(j) > 1                % if more than one match
      % No names are subsets of others, so there will be no exact match
      msg = strjoin(Names(j), ', ');
      error(message('MATLAB:ddeset:AmbiguousPropName', arg, msg));
    end
    expectval = 1;                      % we expect a value next
    
  else
    options.(Names{j}) = arg;
    expectval = 0;
      
  end
  i = i + 1;
end

if expectval
  error(message('MATLAB:ddeset:NoValueForProp', arg));
end
