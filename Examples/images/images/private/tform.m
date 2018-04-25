function outputs = tform(direction, numout, varargin)
% Perform either a forward or inverse spatial transformation,
% in support of TFORMFWD and TFORMINV.

%   Copyright 1993-2010 The MathWorks, Inc.

% Set up a structure to control which direction things go,
% and to provide strings to use in error calls.

if strcmp(direction,'fwd')
    f.name      = 'TFORMFWD';
    f.ndims_in  = 'ndims_in';
    f.ndims_out = 'ndims_out';
    f.fwd_fcn   = 'forward_fcn';
    f.argname   = 'U';
    f.arglist   = 'U1,U2,U3,...';
else
    f.name      = 'TFORMINV';
    f.ndims_in  = 'ndims_out';
    f.ndims_out = 'ndims_in';
    f.fwd_fcn   = 'inverse_fcn';
    f.argname   = 'X';
    f.arglist   = 'X1,X2,X3,...';
end   

narginchk(4,inf);

% Get the TFORM struct, t, and the remaining input arguments, A.
[t, A] = checkTform(f, numout, varargin{:});

P = t.(f.ndims_in);   % Dimensionality of input space.
L = t.(f.ndims_out);  % Dimensionality of output space.

% Validate and organize the input coordinate data so that:
% U contains the input coordinates in an (N + 1)-dimensional array.
% D contains the sizes of the first N dimensions of U, after correctly
% accounting for trailing singleton dimensions that may have been
% dropped or added.

if length(A) == 1
    [U, D] = checkCoordinates( f, P, A{1} );
else
    [U, D] = concatenateCoordinates( f, P, A );
end

% Reshape U to collapse the first N dimensions into a single column.
% Each row of U is now a coordinate vector (of length NDIMS_IN) in
% t's input space.

U = reshape( U, [prod(D) P] );

% Apply the transformation, mapping U from the input space to the
% output space.

X = feval( t.(f.fwd_fcn), U, t );

% X is an array in which each row is a coordinate vector in t's output
% space. Reshape X to be D(1)-by-D(2)-by-...-by-D(N)-by-NDIMS_OUT.

X = reshape( X, [D L] );

% Construct output.
if (numout <= 1)
    outputs{1} = X;
else
    outputs = separateCoordinates( X, numel(D), L );
end

%----------------------------------------------------------------------

function [t, A] = checkTform(f, numout, varargin)

% Look at varargin{1} and varargin{2} to locate the TFORM structure.
% Return the remaining arguments (coordinate arrays) in cell
% array A.

if isstruct(varargin{1})
    t = varargin{1};
    A = varargin(2:end);
elseif isstruct(varargin{2})
    % Old syntax: TFORMFWD(U,T) or TFORMINV(X,T).
    if numel(varargin) == 2
      t = varargin{2};
      A = varargin(1);
    else
      error(message('images:tform:TooManyInputs', f.name))
    end
else
    error(message('images:tform:MissingTform', f.name))
end

if ~istform(t) || (numel(t) ~= 1)
    error(message('images:tform:InvalidTform', f.name))
end

if isempty(t.(f.fwd_fcn))
    error(message('images:tform:TformMissingFcn', f.name, f.fwd_fcn))
end

if (numout > 1) && (numout ~= t.(f.ndims_out))
    error(message('images:tform:OutputCountTformMismatch', f.name, f.ndims_out))
end

%----------------------------------------------------------------------

function [U, D] = checkCoordinates(f, P, U)

% Let U have (N + 1) dimensions after allowing for dropped or extraneous
% trailing singletons.  Determine the sizes of the first N dimensions of
% U and return them in row vector D.  P is the dimensionality of the
% input space.

validateattributes(U, {'double'}, {'real','finite'}, f.name, 'U', 2);

M = ndims(U);
S = size(U);

if S(M) > 1
    if P == 1;
        N = M;         % PROD(S) points in 1-D
    elseif P == S(M)
        N = M - 1;     % PROD(S(1:M-1)) points in P-D
    else
        error(message('images:tform:ArraySizeTformMismatch', f.name, f.argname, f.ndims_in));
    end
    D = S(1:N);
else % S == [S(1) 1]
    if P == 1
        D = S(1);      % S(1) points in 1-D
    elseif P == S(1)
        D = 1;         % 1 point in P-D
    else
        error(message('images:tform:ArraySizeTformMismatch', f.name, f.argname, f.ndims_in));
    end        
end

%----------------------------------------------------------------------

function [U, D] = concatenateCoordinates(f, P, A)

% A is a cell array containing the coordinate arguments:
%
%                A = {U1, U2, U3, ...}
%
% Validate arguments U1,U2,U3,..., then concatenate them into U.
% If the Uk are column vectors, then U is a matrix (2D array) and
% D = length(Uk).  Otherwise, U is an (N + 1)-dimensional array,
% where N = ndims(Uk), including implicit trailing singletons.
% D is a row vector containing the sizes of the first N dimensions
% of U.  P is the dimensionality of the input space.

% Check argument count.
if length(A) ~= P
    error(message('images:tform:InputCountTformMismatch', f.name, f.ndims_in));
end

% Check argument class, properties, consistency.
ndims1 = ndims(A{1});
size1 = size(A{1});
for k = 1:P
    desc = sprintf('%s%d', f.argname, k);
    validateattributes(A{k}, {'double'}, {'real','finite'}, f.name, desc, k+1);
    if any(ndims(A{k}) ~= ndims1) || any(size(A{k}) ~= size1)
        error(message('images:tform:ArraySizeMismatch', f.name, f.arglist));
    end
end

% Determine the size vector, D.
D = size1;
if (numel(D) == 2) && (D(2) == 1)
    % U1,U2,... are column vectors.  They must be specified as
    % 1-D because MATLAB does not support explicit 1-D arrays.    
    D = D(1);
end

% Concatenate the coordinate arguments.
N = numel(D);
U = cat(N + 1, A{:});

%----------------------------------------------------------------------

function outputs = separateCoordinates(X, N, L)

% Distribute X to output arguments along its (N+1)-th dimension,
% which has size L.

subs = repmat( {':'}, [1 N] );
outputs = cell(1,L);
for k = 1:L
    outputs{k} = X(subs{:},k);
end
