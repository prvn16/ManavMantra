function c = cov(x,varargin)
%COV Covariance matrix.
%   COV(X), if X is a vector, returns the variance.  For matrices, where 
%   each row is an observation, and each column a variable, COV(X) is the 
%   covariance matrix.  DIAG(COV(X)) is a vector of variances for each 
%   column, and SQRT(DIAG(COV(X))) is a vector of standard deviations. 
%   COV(X,Y), where X and Y are matrices with the same number of elements,
%   is equivalent to COV([X(:) Y(:)]). 
%   
%   COV(X) or COV(X,Y) normalizes by (N-1) if N>1, where N is the number of
%   observations.  This makes COV(X) the best unbiased estimate of the
%   covariance matrix if the observations are from a normal distribution.
%   For N=1, COV normalizes by N.
%
%   COV(X,1) or COV(X,Y,1) normalizes by N and produces the second
%   moment matrix of the observations about their mean.  COV(X,Y,0) is
%   the same as COV(X,Y) and COV(X,0) is the same as COV(X).
%
%   The mean is removed from each column before calculating the result.
%
%   C = cov(...,NANFLAG) specifies how NaN (Not-A-Number) values are 
%   treated. The default is 'includenan':
%
%   'includenan'   - if the input contains NaN, the output also contains NaN.
%                    Specifically, C(I, J) is NaN if column I or J of X 
%                    contains NaN values.
%   'omitrows'     - omit all rows of X that contain NaN values:
%                      ind = all(~isnan(X), 2);
%                      C = cov(X(ind, :));
%   'partialrows'  - compute each element C(I,J) separately, based only on
%                    the columns I and J of X. Omit rows only if they
%                    contain NaN values in column I or J of X.
%                    The resulting matrix C may not be a positive definite.
%                      ind = all(~isnan(X(:, [I J])));
%                      Clocal = cov(X(ind, [I J]));
%                      C(I, J) = Clocal(1, 2);
%
%   Class support for inputs X,Y:
%      float: double, single
%
%   See also CORRCOEF, VAR, STD, MEAN.

%   Copyright 1984-2016 The MathWorks, Inc. 

if nargin==0 
  error(message('MATLAB:cov:NotEnoughInputs')); 
end
if nargin>4
  error(message('MATLAB:cov:TooManyInputs')); 
end
if ~ismatrix(x)
  error(message('MATLAB:cov:InputDim')); 
end

nin = nargin;

% Check for cov(..., missing)
omitnan = false;
if numel(varargin)>0
    flag = varargin{end};
    if ischar(flag) || (isstring(flag) && isscalar(flag))
        
        if ~isrow(flag)
            error(message('MATLAB:cov:unknownFlag'));
        end
        
        flag = parseFlag(flag);
        
        if ~isscalar(flag)
            error(message('MATLAB:cov:unknownFlag'));
        end
        
        omitnan = (flag == "omitrows") || (flag == "partialrows");
        dopairwise = (flag == "partialrows");
        
        varargin(end) = [];
        nin = nin-1;
    end
end


% Check for cov(x,normfactor) or cov(x,y,normfactor)
if nin==4
  error(message('MATLAB:cov:unknownFlag'));
elseif nin==3
  normfactor = varargin{end};
  if ~isnormfactor(normfactor)
    error(message('MATLAB:cov:notScalarFlag'));
  end   
  nin = nin - 1;
elseif nin==2 && isnormfactor(varargin{end})
  normfactor = varargin{end};
  nin = nin - 1;
else
  normfactor = 0;
end

scalarxy = false; % cov(scalar,scalar) is an ambiguous case
if nin == 2
  y = varargin{1}; 
  if ~ismatrix(y)
     error(message('MATLAB:cov:InputDim')); 
  end
  x = x(:);
  y = y(:);
  if length(x) ~= length(y) 
    error(message('MATLAB:cov:XYlengthMismatch'));
  end
  scalarxy = isscalar(x) && isscalar(y);
  x = [x y];
end

if isvector(x) && ~scalarxy
  x = x(:);
end

if omitnan
    xnan = isnan(x);
    
    if any(xnan(:)) % otherwise, just do standard cov
        if dopairwise
            c = apply_pairwise(x, normfactor);
            return;
        else
            nanrows = any(xnan, 2);
            x = x(~nanrows, :);
        end
    end
end

[m,n] = size(x);
if isempty(x)
    if m==0 && n==0
        c = NaN('like', x);
    else
        c = NaN(n,'like', x);
    end
    return;
end

if normfactor == 0
    % The unbiased estimator: divide by (m-1).  Can't do this
    % when m == 0 or 1.
    if m > 1
        denom = m - 1;
    else
        denom = m;
    end
else
    % The biased estimator: divide by m.
    denom = m; % m==0 => return NaNs, m==1 => return zeros
end
    
xc = x - sum(x,1)./m;  % Remove mean
c = (xc' * xc) ./ denom;
if isscalar(c)
    c = real(c); % handling complex scalar NaN
end
    
function y = isnormfactor(x)
% normfactor for cov must be 0 or 1. 
y = isscalar(x) && (x==0 || x==1);


function c = apply_pairwise(x, normfactor)
% apply cov pairwise to columns of x, ignoring NaN entries

n = size(x, 2);

c = zeros(n, 'like', x([])); % using x([]) so that c is always real

% First fill in the diagonal:
c(1:n+1:end) = localcov_elementwise(x, x, normfactor);

% Now compute off-diagonal entries
for j = 2:n
    
    x1 = repmat(x(:, j), 1, j-1);
    x2 = x(:, 1:j-1);
    
    % make x1, x2 have the same nan patterns
    x1(isnan(x2)) = nan;
    x2(isnan(x(:, j)), :) = nan;
    
    c(j,1:j-1)  = localcov_elementwise(x1, x2, normfactor);
end
c = c + tril(c,-1)';


function c = localcov_elementwise(x,y,normfactor)
%LOCALCOV Return c(i) = cov of x(:, i) and y(:, i), for all i
% with no error checking and assuming NaNs are removed
% returns 1xn vector c
% x, y must be of the same size, with identical nan patterns

nr_notnan = sum(~isnan(x), 1);
xc = x - (sum(x, 1, 'omitnan') ./ nr_notnan); 
yc = y - (sum(y, 1, 'omitnan') ./ nr_notnan);

if normfactor == 0
    denom = nr_notnan - 1;
    denom(nr_notnan == 1) = 1;
    denom(nr_notnan == 0) = 0;
else
    denom = nr_notnan;
end

xy = conj(xc) .* yc;
c = sum(xy, 1, 'omitnan') ./ denom;

% Don't omit NaNs caused by computation (not missing data)
ind = any(isnan(xy) & ~isnan(x), 1);
c(ind) = nan;


function flag = parseFlag(flag)
if (ischar(flag) || (isstring(flag) && isscalar(flag))) && (strlength(flag) == 0)
    flag = string.empty;
else
    opts = ["omitrows", "partialrows", "includenan"];
    flag = opts(strncmpi(flag, opts, strlength(flag)));
end
