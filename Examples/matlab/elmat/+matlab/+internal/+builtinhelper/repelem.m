function B = repelem(A, varargin)
%REPELEM Replicate elements of an array.
%   U = REPELEM(V,N), where V is a vector, returns a vector of repeated
%   elements of V.
%   - If N is a scalar, each element of V is repeated N times.
%   - If N is a vector, element V(i) is repeated N(i) times. N must be the
%     same length as V.
%
%   B = repelem(A, R1, ..., RN), returns an array with each element of A
%   repeated according to R1, ..., RN. Each R1, ..., RN must either be a
%   scalar or a vector with the same length as A in the corresponding
%   dimension.
%
%   Example: If A is a matrix, repelem(A, 2, 3) returns a matrix containing
%   a 2-by-3 block of each element of A.
%
%   See also REPMAT, BSXFUN, MESHGRID.

%   Copyright 1984-2014 The MathWorks, Inc.

if nargin < 2
    error(message('MATLAB:minrhs'))
end

if isscalar(A) && ~isobject(A)
    
    if nargin == 2
        
        p = varargin{1};
        if ~isnumeric(p) && ~islogical(p)
           error(message('MATLAB:repelem:nonNumericReplications'));
        end
        p = full(double(p));
        
        if isscalar(p)
            if p >= 0 && p == floor(p)
                szB = [1 p];
            else
                error(message('MATLAB:repelem:invalidReplications'));
            end
        elseif isvector(p)
            error(message('MATLAB:repelem:mismatchedReplicationsVector'));
        else
            error(message('MATLAB:repelem:invalidReplications'));
        end
        
    else % nargin > 2
        
        szB = ones(1, nargin-1);
        for ii=1:nargin-1
            
            p = varargin{ii};
            if ~isnumeric(p) && ~islogical(p)
                error(message('MATLAB:repelem:nonNumericReplications'));
            end
            p = full(double(p));

            if isscalar(p)
                if p >= 0 && p == floor(p)
                    szB(ii) = p;
                else
                    error(message('MATLAB:repelem:invalidReplications'));
                end
            elseif isvector(p)
                error(message('MATLAB:repelem:mismatchedReplications'));
            else
                error(message('MATLAB:repelem:invalidReplications'));
            end
        end
        
    end
    
    numelB = prod(szB);
    
    if numelB > 0 && numelB < (2^31)-1
        B(numelB) = A;
        if ~isequal(B(1), B(numelB)) || ~(isnumeric(A) || islogical(A))
            % if B(1) is the same as B(nelems), then the default value filled in for
            % B(1:end-1) is already A, so we don't need to waste time redoing
            % this operation. (This optimizes the case that A is a scalar zero of
            % some class.)
            B(:) = A;
        end
        B = reshape(B, szB);
        return;
    end
    
end

if nargin == 2
    
    szA = size(A);
    
    % Avoid calling isvector(A) to minimize the requirements on A
    if numel(szA) > 2 || (szA(1) ~= 1 && szA(2) ~= 1) % equivalent to ~isvector(A)
        error(message('MATLAB:repelem:twoInputNonVector'));
    end
    
    % Avoid calling length(A) to minimize the requirements on A
    lenA = szA(1);
    if lenA == 1
        lenA = szA(2);
    end
    
    p = varargin{1};
    if ~isnumeric(p) && ~islogical(p)
        error(message('MATLAB:repelem:nonNumericReplications'));
    end
    p = full(double(p));
    
    if ~isvector(p) || ~all(p >= 0) || ~all(p == floor(p))
        error(message('MATLAB:repelem:invalidReplications'));
    end
    
    if isscalar(p)
        tmp = 1:lenA;
        ind = tmp(ones(p, 1, 'like', p), :);
        ind = ind(:)';
    else % p is a vector
        if numel(p) == lenA
            starts = accumarray(cumsum([1; p(:)]), 1);
            ind = cumsum(starts(1:end-1));
        else
            error(message('MATLAB:repelem:mismatchedReplicationsVector'));
        end
    end
    
    B = A(ind);
    
    
else % nargin > 2
    
    szA = size(A);
    Bdims = max(nargin-1, numel(szA));
    szA(end+1:Bdims) = 1;
    
    ind = cell(1, Bdims);
    
    for ii=1:nargin-1
        
        p = varargin{ii};
        if ~isnumeric(p) && ~islogical(p)
            error(message('MATLAB:repelem:nonNumericReplications'));
        end
        p = full(double(p));
        
        if ~isvector(p) || ~all(p >= 0) || ~all(p == floor(p))
            error(message('MATLAB:repelem:invalidReplications'));
        end
        
        if isscalar(p)
            tmp = 1:szA(ii);
            ind{ii} = tmp(ones(p, 1, 'like', p), :);
            ind{ii} = ind{ii}(:);
        else % p is a vector
            if numel(p) == szA(ii)
                starts = accumarray(cumsum([1; p(:)]), 1);
                ind{ii} = cumsum(starts(1:end-1));
            else
                error(message('MATLAB:repelem:mismatchedReplications'));
            end
        end
    end
    
    for ii=nargin:Bdims
        ind{ii} = 1:szA(ii);
    end
    
    B = A(ind{:});
    
end