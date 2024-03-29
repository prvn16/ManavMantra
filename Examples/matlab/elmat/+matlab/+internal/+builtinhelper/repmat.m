function B = repmat(A,varargin)
%REPMAT Replicate and tile an array.
%   B = repmat(A,M,N) creates a large matrix B consisting of an M-by-N
%   tiling of copies of A. The size of B is [size(A,1)*M, size(A,2)*N].
%   The statement repmat(A,N) creates an N-by-N tiling.
%
%   B = REPMAT(A,[M N]) accomplishes the same result as repmat(A,M,N).
%
%   B = REPMAT(A,[M N P ...]) tiles the array A to produce a
%   multidimensional array B composed of copies of A. The size of B is
%   [size(A,1)*M, size(A,2)*N, size(A,3)*P, ...].
%
%   REPMAT(A,M,N) when A is a scalar is commonly used to produce an M-by-N
%   matrix filled with A's value and having A's CLASS. For certain values,
%   you may achieve the same results using other functions. Namely,
%      REPMAT(NAN,M,N)           is the same as   NAN(M,N)
%      REPMAT(SINGLE(INF),M,N)   is the same as   INF(M,N,'single')
%      REPMAT(INT8(0),M,N)       is the same as   ZEROS(M,N,'int8')
%      REPMAT(UINT32(1),M,N)     is the same as   ONES(M,N,'uint32')
%      REPMAT(EPS,M,N)           is the same as   EPS(ONES(M,N))
%
%   Example:
%       repmat(magic(2), 2, 3)
%       repmat(uint8(5), 2, 3)
%
%   Class support for input A:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      char, logical
%
%   See also BSXFUN, MESHGRID, ONES, ZEROS, NAN, INF.

%   Copyright 1984-2016 The MathWorks, Inc.

if nargin < 2
    error(message('MATLAB:minrhs'))
elseif nargin == 2
    M = varargin{1};
    checkSizesType(M);
    if isscalar(M)
        siz = [M M];
    elseif isempty(M)
        siz = [1 1];
        warning(message('MATLAB:repmat:emptyReplications'));
    elseif isrow(M)
        siz = M;
    else
        error(message('MATLAB:repmat:invalidReplications'));
    end
    siz = double(full(siz));
else % nargin > 2
    siz = zeros(1,nargin-1);
    for idx = 1:nargin-1
        arg = varargin{idx};
        if isscalar(arg)
            siz(idx) = double(full(checkSizesType(arg)));
        else
            siz = checkMultipleNonscalarSizesType(varargin);
            break
        end
    end
end

if isscalar(A) && ~isobject(A)
    nelems = prod(siz);
    if nelems>0 && nelems < (2^31)-1 % use linear indexing for speed.
        % Since B doesn't exist, the first statement creates a B with
        % the right size and type.  Then use scalar expansion to
        % fill the array. Finally reshape to the specified size.
        B(nelems) = A;
        if ~isequal(B(1), B(nelems)) || ~(isnumeric(A) || islogical(A))
            % if B(1) is the same as B(nelems), then the default value filled in for
            % B(1:end-1) is already A, so we don't need to waste time redoing
            % this operation. (This optimizes the case that A is a scalar zero of
            % some class.)
            B(:) = A;
        end
        B = reshape(B,siz);
    elseif all(siz > 0) % use general indexing, cost of memory allocation dominates.
        ind = num2cell(siz);
        B(ind{:}) = A;
        if ~isequal(B(1), B(ind{:})) || ~(isnumeric(A) || islogical(A))
            B(:) = A;
        end
    else
        B = A(ones(siz));
    end
elseif ismatrix(A) && numel(siz) == 2
    [m,n] = size(A);
    if (m == 1 && siz(2) == 1)
        B = A(ones(siz(1), 1), :);
    elseif (n == 1 && siz(1) == 1)
        B = A(:, ones(siz(2), 1));
    else
        mind = (1:m)';
        nind = (1:n)';
        mind = mind(:,ones(1,siz(1)));
        nind = nind(:,ones(1,siz(2)));
        B = A(mind,nind);
    end
else
    Asiz = size(A);
    Asiz = [Asiz ones(1,length(siz)-length(Asiz))];
    siz = [siz ones(1,length(Asiz)-length(siz))];
    subs = cell(1,length(Asiz));
    for i=length(Asiz):-1:1
        ind = (1:Asiz(i))';
        subs{i} = ind(:,ones(1,siz(i)));
    end
    B = A(subs{:});
end

%-----------------------------------------------------------------------
function siz = checkSizesType(siz)
if ischar(siz)
    error(message('MATLAB:repmat:nonNumericReplications'));
elseif ~isreal(siz)
    error(message('MATLAB:repmat:complexReplications'));
end

%-----------------------------------------------------------------------
function siz = checkMultipleNonscalarSizesType(sizeArgs)
if length(sizeArgs) == 2  % this code maintains backward compatibility
    M = sizeArgs{1};
    N = sizeArgs{2};
    checkSizesType(M);
    checkSizesType(N);
    if (isrow(M) && size(M,2)>1 && (isrow(N) || isempty(N))) || ...
            (isrow(M) && size(M,2)>0 && isrow(N) && size(N,2)>1)
        siz = [M N];
        warning(message('MATLAB:repmat:rowReplications'));
    elseif isempty(N) && numel(M) <= 1
        siz = [M 1 1];
        warning(message('MATLAB:repmat:emptyReplications'));
    else
        error(message('MATLAB:repmat:invalidReplications'));
    end
else
    error(message('MATLAB:repmat:invalidReplications'));
end
