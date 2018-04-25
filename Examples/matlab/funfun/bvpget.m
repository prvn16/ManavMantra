function o = bvpget(options,name,default)
%BVPGET  Get BVP OPTIONS parameters.
%   VAL = BVPGET(OPTIONS,'NAME') extracts the value of the named property
%   from integrator options structure OPTIONS, returning an empty matrix if
%   the property value is not specified in OPTIONS. It is sufficient to type
%   only the leading characters that uniquely identify the property. Case is
%   ignored for property names. [] is a valid OPTIONS argument. 
%   
%   VAL = BVPGET(OPTIONS,'NAME',DEFAULT) extracts the named property as
%   above, but returns VAL = DEFAULT if the named property is not specified
%   in OPTIONS. For example 
%   
%       val = bvpget(opts,'RelTol',1e-4);
%   
%   returns val = 1e-4 if the RelTol property is not specified in opts.
%   
%   See also BVPSET, BVPINIT, BVP4C, BVP5C, DEVAL.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2016 The MathWorks, Inc. 

if nargin < 2
  error(message('MATLAB:bvpget:NotEnoughInputs'));
end
if nargin < 3
  default = [];
end
if isstring(name) && isscalar(name)
  name = char(name);
end
if ~isempty(options) && ~isa(options,'struct')
  error(message('MATLAB:bvpget:OptsNotStruct'));
end

if isempty(options)
  o = default;
  return;
end

Names = { 'AbsTol', 'RelTol', 'SingularTerm', 'FJacobian', ...
    'BCJacobian', 'Stats', 'Nmax', 'Vectorized' };
j = strncmpi(name, Names, length(name));
if ~any(j)               % if no matches
  error(message('MATLAB:bvpget:InvalidPropName', name));
elseif nnz(j) > 1            % if more than one match
  % No names are subsets of others, so there will be no exact match
  msg = strjoin(Names(j), ', ');
  error(message('MATLAB:bvpget:AmbiguousPropName', name, msg));
end

if any(strcmp(fieldnames(options),Names{j}))
  o = options.(Names{j});
  if isempty(o)
    o = default;
  end
else
  o = default;
end

