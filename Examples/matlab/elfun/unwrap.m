function q = unwrap(p,cutoff,dim)
%UNWRAP Unwrap phase angle.
%   UNWRAP(P) unwraps radian phases P by changing absolute 
%   jumps greater than pi to their 2*pi complement.
%   It unwraps along the first non-singleton dimension of P
%   and leaves the first phase value along this dimension 
%   unchanged. P can be a scalar, vector, matrix, or N-D array. 
%
%   UNWRAP(P,CUTOFF) retains all jumps with absolute value less than CUTOFF. That
%   is, the difference between element i and i+1 of P is only changed if 
%      abs(P(i) - P(i+1)) >= CUTOFF.
%   By default, CUTOFF = pi.
%
%   UNWRAP(P,[],DIM) unwraps along dimension DIM using the
%   default tolerance. UNWRAP(P,CUTOFF,DIM) uses a jump tolerance
%   of CUTOFF.
%
%   Class support for input P:
%      float: double, single
%
%   See also ANGLE, ABS.

%   Copyright 1984-2016 The MathWorks, Inc. 

% Overview of the algorithm:
%    Reshape p to be a matrix of column vectors. Perform the 
%    unwrap calculation column-wise on this matrix. (Note that this is
%    equivalent to performing the calculation on dimension one.) 
%    Then reshape the output back.

ni = nargin;

% Treat row vector as a column vector (unless DIM is specified)
rflag = 0;
if ni<3 && isrow(p)
   rflag = 1; 
   p = p.';
end

% Initialize parameters.
nshifts = 0;
perm = 1:ndims(p);
switch ni
case 1
   [p,nshifts] = shiftdim(p);
   cutoff = pi;     % Original UNWRAP used pi*170/180.
case 2
   [p,nshifts] = shiftdim(p);
otherwise    % nargin == 3
    if ~isscalar(dim) || ~isnumeric(dim) || (dim ~= floor(dim))
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
    dim = min(ndims(p)+1, dim);
    perm = [dim:max(ndims(p),dim) 1:dim-1];
    p = permute(p,perm);
   if isempty(cutoff)
      cutoff = pi; 
   end
end
   
% Reshape p to a matrix.
siz = size(p);
p = reshape(p, [siz(1) prod(siz(2:end))]);

% Unwrap each column of p
q = p;
for j=1:size(p,2)
   % Find NaN's and Inf's
   indf = isfinite(p(:,j));
   % Unwrap finite data (skip non finite entries)
   q(indf,j) = LocalUnwrap(p(indf,j),cutoff);
end

% Reshape output
q = reshape(q,siz);
q = ipermute(q,perm);
q = shiftdim(q,-nshifts);
if rflag
   q = q.'; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions  %%%%%%%%%%%%%%%%%%%

function p = LocalUnwrap(p,cutoff)
%LocalUnwrap   Unwraps column vector of phase values.

m = length(p);

% Unwrap phase angles.  Algorithm minimizes the incremental phase variation 
% by constraining it to the range [-pi,pi]
dp = diff(p,1,1);                % Incremental phase variations

% Compute an integer describing how many times 2*pi we are off:
% dp in [-pi, pi]: dp_corr = 0,
% elseif dp in [-3*pi, 3*pi]: dp_corr = 1,
% else if dp in [-5*pi, 5*pi]: dp_corr = 2, ...
dp_corr = dp./(2*pi);

% We want to do round(dp_corr), except that we want the tie-break at n+0.5
% to round towards zero instead of away from zero (that is, (2n+1)*pi will
% be shifted by 2n*pi, not by (2n+2)*pi):
roundDown = abs(rem(dp_corr, 1)) <= 0.5;
dp_corr(roundDown) = fix(dp_corr(roundDown));

dp_corr = round(dp_corr);

% Stop the jump from happening if dp < cutoff (no effect if cutoff <= pi)
dp_corr(abs(dp) < cutoff) = 0;

% Integrate corrections and add to P to produce smoothed phase values
p(2:m,:) = p(2:m,:) - (2*pi)*cumsum(dp_corr,1);
