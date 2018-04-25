function tc = cov(varargin)
%COV Covariance matrix.
%   C = COV(X)
%   C = COV(X,Y)
%   C = COV(...,FLAG) where FLAG is 0 or 1
%   C = COV(...,NANFLAG)
%
%   Limitations:
%   1) X and Y must have the same size even if A and B are vectors.
%   2) Option 'partialrows' is not supported.
%
%   See also: COV.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1, 4);
[cellIn, normFlag, NaNFlag] = parseInputs(varargin{:});
if strcmp(NaNFlag,'partialrows')
   error(message('MATLAB:bigdata:array:CovPartialRowsNotSupported')); 
end
if length(cellIn) == 2
    aggregateFunc = @(x,y)covWithTwoDataInput(x, y, NaNFlag);
    reduceFcn = @(x) reduceCovCell(x, 1);
    tmpCell = aggregatefun(aggregateFunc,reduceFcn,cellIn{:});
else
    aggregateFcn = @(x, dim) covWithOneDataInput(x, dim, NaNFlag);
    reduceFcn = @(x, dim) reduceCovCell(x, dim);
    tmpCell = tall(reduceInDefaultDim({aggregateFcn, reduceFcn}, cellIn{:}));
end
tc = clientfun(@(x)getCovCell(x,normFlag), tmpCell);
end

function outCell = covWithOneDataInput(x, dim, NaNFlag)
% Wrapper needed to call reduceInDefaultDim with one data input.
if dim == 2
    x = x(:);  
end
[nCovCell,nCount,nMean,nNumel] = chunkCov(x, NaNFlag);
outCell = {nCovCell,nCount,nMean,nNumel};
end

function outCell = covWithTwoDataInput(x, y, NaNFlag)
% Handling the two data inputs.
[nCovCell,nCount,nMean,nNumel] = chunkCov([x(:), y(:)], NaNFlag);
outCell = {nCovCell,nCount,nMean,nNumel};
end

function [nCovCell,nCount,nMean,nNumel] = chunkCov(data, NaNFlag)
% Compute covariant matrix of a partition.
nNumel = numel(data);
h = ~any(isnan(data),2);
nCount = sum(h);   % count without rows with NaNs
if strcmp(NaNFlag,'includenan') || nCount == size(data,1) %no NaNs
    nCount = size(data,1); %data has NaN
else
    assert(strcmp(NaNFlag,'omitrows'))
    data = data(h,:);
end
nMean = sum(data,1)./max(nCount,1);  % mean
data = data - nMean;
nCovCell = {data'*data};  % Cov times n
end

function outCell = reduceCovCell(inCell, dim)
% Combine the covariance matrix from each partition.
if size(inCell,1) == 1
    outCell = inCell;
else
    assert(dim == 1);
    nCovCell = cat(1, inCell{:,1});
    nCount = cat(1, inCell{:,2});
    nMean = cat(1, inCell{:,3});
    nNumel = cat(1, inCell{:,4});
    if length(nCovCell) > 1
        nNumel = sum(nNumel,1);
        n = nCount;
        nCount = sum(n,1);
        me = nMean;
        nMean  = (n' * me)./max(nCount,1);
        d = me - nMean;
        t = d'*(d.*n);
        t = (t+t')/2;  % Ensure symmetry.
        nCovCell = {t + nCovCell{1} + nCovCell{2}};
    end
    outCell = {nCovCell,nCount,nMean,nNumel};
end
end

function X =  getCovCell(inCell,normFlag)
% Extract and update the combined result
X = inCell{1}{1};
n = inCell{2};
Numel= inCell{4};
if normFlag == 0
    X = X./max(n-1,1);
else 
    X = X./max(n,1);
end
if Numel == 0 || n == 0 % handle empty matrix or all rows are omitted.
    X(:) = NaN;
end
if ~isreal(X)
    n = size(X,1);
    X(1:n+1:end) = real(diag(X)); % handle NaN diagonal
end
end

function [cellIn, normFlag, NaNFlag] = parseInputs(varargin)
tx = varargin{1};
tx = tall.validateType(tx, mfilename, {'numeric','char','logical'}, 1);
tx = tall.validateMatrix(tx, 'MATLAB:cov:InputDim');
cellIn = {tx};
varargin = varargin(2:end);
%Set up default flag
NaNFlag = 'includenan';
normFlag = 0;
% Check second input if it is tall.
% If it is tall, assume it is COV(X,Y,...)
offset = 1;
if nargin > 1 
    if istall(varargin{1})
        ty = varargin{1};
        varargin = varargin(2:end);
        ty = tall.validateType(ty, mfilename, {'numeric','char','logical'}, 1);
        ty = tall.validateMatrix(ty, 'MATLAB:cov:InputDim');
        [tx, ty] = validateSameTallSize(tx, ty);
        [tx, ty] = lazyValidate(tx, ty, {@(x,y)size(x)==size(y), ...
            'MATLAB:cov:XYlengthMismatch'});
        cellIn = {tx, ty};
        offset = 2;
    end
    % The trailing inputs must not be tall.
    tall.checkNotTall(upper(mfilename), offset, varargin{:});
    numTrailingArg = length(varargin);
    if numTrailingArg == 1
        if isNonTallScalarString(varargin{1})
            NaNFlag = parseFlag(varargin{1});
        else
            if ~isnormfactor(varargin{1})
                error(message('MATLAB:cov:notScalarFlag'));
            end
            normFlag = varargin{1};
        end
    elseif numTrailingArg == 2
        if isNonTallScalarString(varargin{2})
            NaNFlag = parseFlag(varargin{2});
        else
            error(message('MATLAB:cov:unknownFlag'));
        end
        if ~isnormfactor(varargin{1})
            error(message('MATLAB:cov:notScalarFlag'));
        end
        normFlag = varargin{1};
    elseif numTrailingArg > 2
        error(message('MATLAB:cov:unknownFlag'));
    end 
end
end

function flag = parseFlag(flag)
option = {'omitrows', 'partialrows', 'includenan'};
s = strncmpi(flag, option, max(strlength(flag), 1));
if all(s == false) % no match 
     error(message('MATLAB:cov:unknownFlag'));
end
flag = option{s};
end

function y = isnormfactor(x)
% normfactor for cov must be 0 or 1. 
y = isscalar(x) && (isnumeric(x) || islogical(x)) && (x==0 || x==1);
end
