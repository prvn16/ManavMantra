function y = cplxpair(x,tol,dim)
%CPLXPAIR Sort numbers into complex conjugate pairs.
%   Y = CPLXPAIR(X) takes a vector of complex conjugate pairs and/or
%   real numbers.  CPLXPAIR rearranges the elements of X so that
%   complex numbers are collected into matched pairs of complex
%   conjugates.  The pairs are ordered by increasing real part.
%   Any purely real elements are placed after all the complex pairs.
%
%   Y = CPLXPAIR(X,TOL) uses a relative tolerance TOL to perform the
%   comparisons needed for the complex conjugate pairings. TOL must
%   be a scalar such that 0<=TOL<1. The default is TOL = 100*EPS.
%
%   For X an N-D array, CPLXPAIR(X) and CPLXPAIR(X,TOL) rearranges
%   the elements along the first non-singleton dimension of X.
%   CPLXPAIR(X,[],DIM) and CPLXPAIR(X,TOL,DIM) sorts X along 
%   dimension DIM.
%
%   Class support for input X:
%      float: double, single

%   Copyright 1984-2014 The MathWorks, Inc. 

if isempty(x)
  y = x; 
  return  % Quick exit if empty input
end
if nargin == 3
  nshifts = 0;
  if ~isscalar(dim) || ~isnumeric(dim) || (dim ~= floor(dim))
      error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
  end
  dim = min(ndims(x)+1, dim);
  perm = [dim:max(ndims(x),dim) 1:dim-1];
  x = permute(x,perm);
else
  [x,nshifts] = shiftdim(x);
  perm = [];
end

% Supply defaults for relative tolerance
if nargin < 2 || isempty(tol)
  tol = 100*eps(class(x));
end
if nargin == 2 && (~isscalar(tol) || ~isreal(tol) || ~(tol >= 0 && tol < 1))
  error(message('MATLAB:cplxpair:WrongTolerance'));
end

% Reshape x to a 2-D matrix:
xsiz   = size(x);                   % original shape of input
x      = x(:,:);                    % reshape to a 2-D matrix
y      = zeros(size(x),class(x));   % preallocate temp storage

for k = 1:size(x,2)
  % Get next column of x
  xc = x(:,k);

  % Find entries that are real with respect to the relative tolerance
  % (entries with imaginary part/absolute value <= relative tolerance)
  idx = find(abs(imag(xc)) <= tol*abs(xc));
  nr = length(idx);
  if ~isempty(idx)
    % Store sorted real's at end of column and remove them from xc
    y(end-nr+1:end,k)  = sort(real(xc(idx)));
    xc(idx) = [];
  end

  nc = length(xc); % Number of complex entries remaining in input column xc
  if nc > 0
    if rem(nc,2) == 1
      % Odd number of entries remaining
      error(message('MATLAB:cplxpair:ComplexValuesPaired'));  
    end

    % Sort complex column-vector xc, based on its real part
    [xtemp,idx] = sort(real(xc));
    xc = xc(idx);

    % Check if real parts occur in pairs
    %   Compare to xc() so imag part is considered (in case real part is nearly 0).
    %   Arbitrary choice of using abs(xc(1:2:nc)) or abs(xc(2:2:nc)) for tolerance
    if any( abs(xtemp(1:2:nc)-xtemp(2:2:nc)) > tol.*abs(xc(1:2:nc)) )
      error(message('MATLAB:cplxpair:ComplexValuesPaired'));
    end

    % Check real part pairs to see if imag parts are conjugates
    nxt_row = 1;  % next row in y(:,k) for results
    while ~isempty(xc)
      % Find all real parts identical (up to tolerance) to real(xc(1))
      idx = find( abs(real(xc) - real(xc(1))) <= tol.*abs(xc) );
      nn = length(idx);
      if nn <= 1
        % Only 1 value found - certainly not a pair!
        error(message('MATLAB:cplxpair:ComplexValuesPaired')); 
      end

      % There could be multiple pairs with "identical" real parts. Sort the
      % imaginary parts of those values with identical real parts - these
      % SHOULD be the next N entries, with N even.
      [xtemp,idx] = sort(imag(xc(idx)));
      xq = xc(idx);  % Get complex-values with identical real parts,
                     % which are now sorted by imaginary component.
      % Verify conjugate-pairing of imaginary parts
      if any( abs(xtemp + xtemp(nn:-1:1)) > tol.*abs(xq) )
        error(message('MATLAB:cplxpair:ComplexValuesPaired'));
      end
      % Keep value with positive imag part, and compute conjugate for pair.
      % List value with smallest neg imag part first, then its conjugate.
      y(nxt_row : nxt_row+nn-1, k) = reshape([conj(xq(end:-1:nn/2+1)) ...
                                                   xq(end:-1:nn/2+1)].',nn,1);
      nxt_row = nxt_row+nn;  % Bump next-row pointer
      xc(idx) = [];          % Remove entries from xc
    end

  end % of complex-values check
end % of column loop

% Reshape Y to appropriate form
y = reshape(y,xsiz);
if ~isempty(perm)
  y = ipermute(y,perm);
end
if nshifts ~= 0
  y = shiftdim(y,-nshifts);
end

% end of cplxpair.m
