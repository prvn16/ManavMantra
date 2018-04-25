function varargout = ischange(A,varargin)
%ISCHANGE   Detect abrupt changes in data
%   TF = ISCHANGE(A) detects abrupt changes in mean. TF is a logical array
%   the same size as A: TRUE entries indicate where the mean of the data
%   changes. A must be a vector, matrix, N-D array, table, or timetable.
%
%   TF = ISCHANGE(A,METHOD) specifies which kind of change to detect:
%      'mean'     - (default) Changes in mean.
%      'variance' - Changes in variance.
%      'linear'   - Changes in linear regime (in slope and intercept).
%
%   TF = ISCHANGE(...,DIM) specifies the dimension to operate along. By
%   default, DIM is the first array dimension whose size does not equal 1.
%   If A is a matrix, then changes are detected for each column by default.
%
%   TF = ISCHANGE(...,'Threshold',T) specifies a threshold T used for
%   determining the number of changes in the data. By default, T = 1.
%   Increasing T produces fewer changes.
%
%   TF = ISCHANGE(...,'MaxNumChanges',N) returns at most N changes.
%   'MaxNumChanges' cannot be specified together with 'Threshold'. If
%   'MaxNumChanges' is specified, then ISCHANGE uses a threshold value
%   which produces at most N changes.
%
%   TF = ISCHANGE(...,'SamplePoints',X) also specifies the sample points X
%   associated with the data in A. X must be a floating-point, duration, or
%   datetime vector. X must be sorted and contain unique points. You can
%   use X to specify time stamps for the data. By default, ISCHANGE assumes
%   the data is sampled uniformly at points X = [1 2 3 ... ].
%
%   [TF,S1,S2] = ISCHANGE(...) also returns useful information about the
%   segments delimited by the changepoints. If the METHOD is 'mean' or
%   'variance', S1 contains the mean and S2 the variance of each segment.
%   If the METHOD is 'linear', S1 contains the slope and S2 the intercept.
%
%   TF = ISCHANGE(...,'DataVariables',DV) detects changes only in the table
%   variables specified by DV. The default is all table variables in A. DV
%   must be a table variable name, a cell array of table variable names, a
%   vector of table variable indices, a logical vector, or a function
%   handle that returns a logical scalar (such as @isnumeric).
%
%   Examples:
%
%     % Detect changes in mean
%       a = [ones(1,10) 0.25*ones(1,20) ones(1,20)] + 0.5*rand(1,50);
%       [tf,m] = ischange(a);
%       plot(a,':o'), hold on                    % data
%       stairs(m)                                % mean of each segment
%       plot([1;1]*find(tf),ylim,'g')            % changes in mean
%       legend('data','mean','changes in mean','Location','SE')
%
%     % Detect changes in linear regime
%       a = [zeros(1,100) 1:100 99:-1:50  50*ones(1,250)] + 10*rand(1,500);
%       [tf,s1,s2] = ischange(a,'linear','Threshold',200);
%       plot(a), hold on                         % data
%       plot(s1.*(1:numel(a)) + s2)              % linear regime
%       plot([1;1]*find(tf),ylim,'g')            % changes in linear regime
%       legend('data','linear regime','changes')
%
%   See also ISLOCALMAX, ISLOCALMIN, ISMISSING, ISOUTLIER,
%            FILLMISSING, FILLOUTLIERS, SMOOTHDATA

%   Copyright 2017 The MathWorks, Inc.

%   References:
%
%   Jackson B., Scargle J.D., Barnes D., Arabhi S., Alt A., Gioumousis P.,
%   Gwin E., Sangtrakulcharoen P., Tan L. and Tsai T.T., "An algorithm for
%   optimal partitioning of data on an interval", IEEE Signal Processing
%   Letters, 12(2), pp.105-108, 2005.
%
%   Killick R., Fearnhead P. and Eckley I.A., "Optimal detection of
%   changepoints with a linear computational cost", Journal of the American
%   Statistical Association, 107(500), pp.1590-1598, 2012.
%
%   Chan T.F., Golub G.H., LeVeque R.J., "Algorithms for computing the
%   sample variance: analysis and recommendations",  The American
%   Statistician.  Vol 37, No. 3, pp. 242-247, 1983.
%
%   Pebay P.P., "Formulas for robust, one-pass parallel computation of
%   covariances and arbitrary-order statistical moments", Technical Report
%   Sandia National Laboratories, SAND2008-6212, doi:10.2172/1028931, 2008.

[AisTabular,method,x,numchanges,separation,threshold,dim,dataVars] = ...
    parseInputs(A,varargin{:});

if ~AisTabular
    checkSupportedArray(A,false);
    [varargout{1:nargout}] = ischangeArray(A,method,x,numchanges,separation,threshold,dim);
else
    [varargout{1:nargout}] = ischangeTable(A,method,x,numchanges,separation,threshold,dataVars);
end

%--------------------------------------------------------------------------
function [TF,S1,S2] = ischangeTable(A,method,x,numchanges,separation,theshold,dataVars)
% Changepoint detection for tables and timetables

TF = false(size(A));
if nargout > 1
    S1 = A(:,dataVars);
    if nargout > 2
        S2 = S1;
    end
end
jj = 1;
for vj = dataVars
    Avj = A.(vj);
    checkSupportedArray(Avj,true);
    if ~(iscolumn(Avj) || isempty(Avj))
        error(message('MATLAB:ischange:NonVectorTableVariable'));
    end
    if nargout < 2
        TF(:,vj) = ischangeArray(Avj,method,x,numchanges,separation,theshold,1);
    else
        if nargout < 3
            [TF(:,vj),S1.(jj)] = ischangeArray(Avj,method,x,numchanges,separation,theshold,1);
        else
            [TF(:,vj),S1.(jj),S2.(jj)] = ischangeArray(Avj,method,x,numchanges,separation,theshold,1);
        end
        jj = jj + 1;
    end
end

%--------------------------------------------------------------------------
function [TF,S1,S2] = ischangeArray(A,method,x,numchanges,separation,theshold,dim)
% Changepoint detection for arrays

sizeAin = size(A);
ndimsAin = ndims(A);
if issparse(A)
    TF = logical(sparse(sizeAin(1),sizeAin(2))); % Match isnan(sparse(A))
else
    TF = false(sizeAin);
end

if isscalar(A) || isempty(A) || dim > ndimsAin
    % All data is treated as scalar
    if nargout > 1
        S1 = A;
        S2 = A;
        for ii = 1:numel(A)
            [S1(ii),S2(ii)] = fitsegments(A(ii),TF(ii),method,x);
        end
    end
    return
end

% Permute and reshape into a matrix
perm = [dim, 1:(dim-1), (dim+1):ndimsAin];
sizeAperm = sizeAin(perm);
ncolsA = prod(sizeAperm(2:end));
nrowsA = sizeAperm(1);
B = reshape(permute(A, perm),[nrowsA, ncolsA]);
TF = reshape(permute(TF, perm),[nrowsA, ncolsA]);
if nargout > 1
    S1 = B;
    S2 = B;
end

% Apply the ischange algorithm to each column
for jj = 1:ncolsA
    TF(:,jj) = ischangeArrayColumn(B(:,jj),method,x,numchanges,separation,theshold);
end
if nargout > 1
    for jj = 1:ncolsA
        [S1(:,jj),S2(:,jj)] = fitsegments(B(:,jj),TF(:,jj),method,x);
    end
end

% Reshape and permute back to original size
TF = ipermute(reshape(TF,sizeAperm), perm);
if nargout > 1
    S1 = ipermute(reshape(S1,sizeAperm), perm);
    S2 = ipermute(reshape(S2,sizeAperm), perm);
end

%--------------------------------------------------------------------------
function tf = ischangeArrayColumn(a,statistic,x,Kmax,Lmin,penalty)
% Changepoint detection for one column

tf = false(size(a));
a = full(a);

if numel(a) < 2 % in general: numel(a) < Lmin
    % No change points if data is empty or scalar
    cp = [];
elseif ~isempty(penalty)
    % ischange(a) and ischange(a,...,'Threshold',penalty)
    cp = cpmanual(a,statistic,Lmin,penalty,x);
else
    % ischange(a,...,'MaxNumChanges',Kmax)
    cp = cpmulti(a,statistic,Lmin,Kmax,x);
end
tf(cp) = true;

%--------------------------------------------------------------------------
function cp = cpmanual(a,statistic,Lmin,penalty,x)
% Multiple changepoints using 'Threshold' = penalty

% Cost function if data had no changepoints, i.e., we have only one segment
cost0 = cpnochange(a,statistic,x);

% Cost function if data had only one changepoint, i.e., optimal cost of
% partitioning the data into the two best segments
[cp,cost1] = cpsingle(a,statistic,Lmin,x);

if isempty(cp) || (cost1 + penalty > cost0)
    % No changepoints possible: cost of two segments is not smaller
    cp = [];
else
    % Data may have one or more changepoints, find its optimal partitioning
    cp = builtin('_ischangePelt',a,statistic,penalty,x,Lmin,1);
end

%--------------------------------------------------------------------------
function cost = cpnochange(a,statistic,x)
% Evaluate cost function of segment a

n = numel(a);
if strcmp(statistic,'mean')
    % cost = Syy
    cost = n*var(a,1);
elseif strcmp(statistic,'variance')
    cost = n*log(var(a,1));
else % statistic = 'linear'
    % cost = Syy - Sxy^2 / Sxx
    cost = n*var(a,1) - sum((a-mean(a)).*(x-mean(x)))^2 / (n*var(x,1));
end

%--------------------------------------------------------------------------
function [cp,cost] = cpsingle(a,statistic,Lmin,x)
% Cost function if data had only one changepoint

% Evaluate costs for all possible combinations of two segments
if strcmp(statistic,'mean')
    [costSegment1,costSegment2] = costTwoSegmentsMean(a);
elseif strcmp(statistic,'variance')
    [costSegment1,costSegment2] = costTwoSegmentsVariance(a);
else
    [costSegment1,costSegment2] = costTwoSegmentsLinear(a,x);
end

% Find the optimal cost of partitioning the data into two segments by
% finding the minimum of cost(1:i-1) + cost(i:n) for i = 2:n
n = numel(a);
[cost,cp] = min(costSegment1(Lmin:n-Lmin) + costSegment2(Lmin+1:n-Lmin+1));
cp = cp + Lmin;

%--------------------------------------------------------------------------
function [costSegment1,costSegment2] = costTwoSegmentsMean(a)
% Evaluate cost function for all possible combinations of two segments

n = numel(a);
costSegment1 = zeros(n,1,class(a));
costSegment2 = costSegment1;

% Cost of all possible first segments:
% same iterative formula as the builtin instead of cpnochange on a(1:ix)
ymean = zeros(1,class(a));
Syy = ymean;
for ix = 1:n
    ydelta = a(ix) - ymean;
    npoints = ix;
    ymean = ymean + ydelta./npoints;
    Syy = Syy + ydelta * (a(ix) - ymean);
    costSegment1(ix) = Syy;
end

% Cost of all possible second segments:
% same iterative formula as the builtin instead of cpnochange on a(ix:n)
ymean = zeros(1,class(a));
Syy = ymean;
for ix = n:-1:1
    ydelta = a(ix) - ymean;
    npoints = n-ix+1;
    ymean = ymean + ydelta./npoints;
    Syy = Syy + ydelta * (a(ix) - ymean);
    costSegment2(ix) = Syy;
end

%--------------------------------------------------------------------------
function [costSegment1,costSegment2] = costTwoSegmentsVariance(a)
% Evaluate cost function for all possible combinations of two segments

n = numel(a);
costSegment1 = zeros(n,1,class(a));
costSegment2 = costSegment1;
logrealmin = log(realmin);

% Cost of all possible first segments:
% same iterative formula as the builtin instead of cpnochange on a(1:ix)
ymean = zeros(1,class(a));
Syy = ymean;
for ix = 1:n
    npoints = ix;
    ydelta = a(ix) - ymean;
    ymean = ymean + ydelta./npoints;
    Syy = Syy + ydelta * (a(ix) - ymean);
    costSegment1(ix) = npoints*max(logrealmin-log(npoints),log(Syy./npoints));
end

% Cost of all possible second segments:
% same iterative formula as the builtin instead of cpnochange on a(ix:n)
ymean = zeros(1,class(a));
Syy = ymean;
for ix = n:-1:1
    ydelta = a(ix) - ymean;
    npoints = n+1-ix;
    ymean = ymean + ydelta./npoints;
    Syy = Syy + ydelta * (a(ix) - ymean);
    costSegment2(ix) = npoints*max(logrealmin-log(npoints),log(Syy./npoints));
end

%--------------------------------------------------------------------------
function [costSegment1,costSegment2] = costTwoSegmentsLinear(a,x)
% Evaluate cost function for all possible combinations of two segments

n = numel(a);
costSegment1 = zeros(n,1,class(a));
costSegment2 = costSegment1;

% Cost of all possible first segments:
% same iterative formula as the builtin instead of cpnochange on a(1:ix)
xmean = zeros(1,class(x));
ymean = zeros(1,class(a));
Sxx = xmean;
Syy = ymean;
Sxy = ymean;
SxxSSE = ymean;
for ix = 1:n
    npoints = ix;
    ydelta = a(ix) - ymean;
    xdelta = x(ix) - xmean;
    ymean = ymean + ydelta/npoints;
    xmean = xmean + xdelta/npoints;
    dSyy = ydelta .* (a(ix) - ymean);
    dSxx = xdelta .* (x(ix) - xmean);
    dSxy = xdelta .* ydelta .* (npoints - 1) ./ npoints;
    Syy = Syy + dSyy;
    dSxxSSE = dSxx.*Syy + dSyy.*Sxx - dSxy.*(2*Sxy+dSxy);
    Sxx = Sxx + dSxx;
    Sxy = Sxy + dSxy;
    SxxSSE = SxxSSE + dSxxSSE;
    costSegment1(ix) = SxxSSE ./ Sxx;
end

% Cost of all possible second segments:
% same iterative formula as the builtin instead of cpnochange on a(ix:n)
xmean = zeros(1,class(x));
ymean = zeros(1,class(a));
Sxx = xmean;
Syy = ymean;
Sxy = ymean;
for ix = n:-1:1
    npoints = n+1-ix;
    ydelta = a(ix) - ymean;
    xdelta = x(ix) - xmean;
    ymean = ymean + ydelta/npoints;
    xmean = xmean + xdelta/npoints;
    Syy = Syy + ydelta * (a(ix) - ymean);
    Sxx = Sxx + xdelta * (x(ix) - xmean);
    Sxy = Sxy + xdelta .* ydelta .* (npoints - 1) ./ npoints;
    costSegment2(ix) = Syy - Sxy.^2 ./ Sxx;
end

%--------------------------------------------------------------------------
function cp = cpmulti(a,statistic,Lmin,Kmax,x)
% Multiple changepoints using 'MaxNumChanges' = Kmax

% Try one change
[cp,cost1] = cpsingle(a,statistic,Lmin,x);
if isempty(cp)
    return
end

% Cost upper bound: cost function if data had no changepoints
maxcost = cpnochange(a,statistic,x);

% Cost lower bound: overfit with penalty set to zero
[cpmax,mincost] = builtin('_ischangePelt',a,statistic,0,x,Lmin,1);
Pmin = 0;
if Kmax >= numel(cpmax)
    cp = cpmax;
    return
end

% Initial penalty: cost1 + penalty = maxcost
penalty = double(maxcost - cost1);
[cp,cost] = builtin('_ischangePelt',a,statistic,penalty,x,Lmin,1);
Pmax = Inf;

% Seek lower bound
while numel(cp) < Kmax && cost >= mincost
    Pmax = penalty;
    maxcost = cost;
    cpmax = cp;
    % Try reducing the penalty by half
    penalty = penalty/2;
    [cp,cost] = builtin('_ischangePelt',a,statistic,penalty,x,Lmin,1);
    if numel(cp) > Kmax
        Pmin = penalty;
        mincost = cost;
    end
end

% Seek upper bound
while numel(cp) > Kmax && cost <= maxcost && isinf(Pmax)
    Pmin = penalty;
    % Try doubling the penalty
    penalty = 2*penalty;
    [cp,cost] = builtin('_ischangePelt',a,statistic,penalty,x,Lmin,1);
    if numel(cp) < Kmax
        Pmax = penalty;
        cpmax = cp;
        maxcost = cost;
    end
end

if numel(cp) == Kmax
    return
end

% Search for specified number of changes
penalty = (Pmax + Pmin)/2;
while numel(cp) ~= Kmax && Pmin < penalty && penalty < Pmax
    cp = builtin('_ischangePelt',a,statistic,penalty,x,Lmin,1);
    if numel(cp) < Kmax
        cpmax = cp;
        Pmax = penalty;
    else
        Pmin = penalty;
    end
    penalty = (Pmax + Pmin)/2;
end

% Don't exceed Kmax when reporting penalties
if numel(cp) ~= Kmax
    cp = cpmax;
end

%--------------------------------------------------------------------------
function [s1,s2] = fitsegments(a,tf,method,x)
% Useful information about each segment delimited by the changepoints

s1 = a;
s2 = a;
icp = find(tf);
numsegments = numel(icp) + 1;
istart = [1; icp];
istop = [icp-1; numel(a)]; % icp ~= 1 (the first point is never a change)

if strcmp(method,'linear')
    % Turn off polyfit warnings
    oldWarningState = warning;
    warning('off','all');
    cleanupObj = onCleanup(@() warning(oldWarningState));
    % Fit a polynomial of degree 1 for each segment a1*x + a0
    for s = 1:numsegments
        ix = istart(s):istop(s);
        p = polyfit(x(ix),a(ix),1);
        s1(ix) = p(1); % a1 i.e. the slope
        s2(ix) = p(2); % a0 i.e. the y-intercept
    end
else
    for s = 1:numsegments
        ix = istart(s):istop(s);
        s1(ix) = mean(a(ix));
        s2(ix) = var(a(ix));
    end
end

%--------------------------------------------------------------------------
function [AisTabular,method,x,numchanges,separation,threshold,dim,dataVars] = ...
        parseInputs(A,varargin)
% Parse ISCHANGE inputs
AisTabular = matlab.internal.datatypes.istabular(A);

%   ISCHANGE(A) defaults:
method = 'mean';
numchanges = [];
threshold = [];
if ~AisTabular
    dim = find(size(A) ~= 1,1); % default to first non-singleton dimension
    if isempty(dim)
        dim = 2; % dim = 2 for scalar and empty A
    end
    dataVars = []; % not supported for arrays
else
    dim = 1; % Find changes in each table variable separately
    dataVars = 1:width(A);
end
x = [];

%   ISCHANGE(A,METHOD)
%   ISCHANGE(A,METHOD,DIM)
%   ISCHANGE(A,METHOD,DIM,N1 ,V1 ,N2 ,V2 ,...)
%   ISCHANGE(A,METHOD,N1 ,V1 ,N2 ,V2 ,...)
%   ISCHANGE(A,DIM)
%   ISCHANGE(A,DIM,N1 ,V1 ,N2 ,V2 ,...)
%   ISCHANGE(A,N1 ,V1 ,N2 ,V2 ,...)
if nargin > 1
    % Does not error for invalid method:
    [method,methodProvided] = parseMethod(method,varargin{1});
    
    if 1+methodProvided < nargin
        % Errors for invalid dim:
        optionalDim = varargin{1+methodProvided};
        [dim,dimProvided] = parseDim(dim,optionalDim,AisTabular);
        
        % Look for trailing Name-Value pairs:
        startNV = 1+methodProvided+dimProvided;
        if rem(nargin-startNV,2) == 0
            [x,numchanges,threshold,dataVars] = ...
                parseNV(A,AisTabular,x,numchanges,threshold,dim,dataVars,startNV,varargin{:});
        elseif nargin < 3
            % Error for invalid method in ISCHANGE(A,METHOD):
            error(message('MATLAB:ischange:MethodInvalid'));
        else
            error(message('MATLAB:ischange:NameValuePairs'));
        end
    end
end

% Still need to validate abscissa x for a timetable, because the iterative
% update formulas for the cost functions assume sequentially ordered data
if isa(A,'timetable')
    x = checkSamplePoints(A.Properties.RowTimes,A,true,dim);
end
% The x value is used only in 'linear' and is ignored by the other methods
if strcmp(method,'linear')
    if isdatetime(x)
        error(message('MATLAB:ischange:SamplePointsDatetimeLinear'));
    end
    % Always use a double abscissa x
    if isempty(x)
        x = (1:size(A,dim)).'; % Default [1 2 3 ... n]
    elseif isduration(x)
        x = milliseconds(x);
    else % single x
        x = double(x);
    end
else
    x = []; % Don't create any x
end

% Default to Threshold 1 and empty MaxNumChanges
if ~isempty(threshold) && ~isempty(numchanges)
    error(message('MATLAB:ischange:MaxNumChangesThreshold'));
end
if isempty(threshold) && isempty(numchanges)
    threshold = 1;
end
threshold = double(threshold);

% Default minimum separation is 1 for 'mean' and 2 for the others
separation = 2-strcmp(method,'mean');

%--------------------------------------------------------------------------
function checkSupportedArray(A,AisTabular)
if ~isfloat(A)
    if AisTabular
        error(message('MATLAB:ischange:UnsupportedTableVariable'));
    else
        error(message('MATLAB:ischange:FirstInputInvalid'));
    end
end
if ~isreal(A)
    error(message('MATLAB:ischange:ComplexInput'));
end

%--------------------------------------------------------------------------
function [method,methodProvided] = parseMethod(method,m)
validMethods = {'mean','variance','linear'};
indMethod = matlab.internal.math.checkInputName(m,validMethods);
methodProvided = sum(indMethod) == 1;
if methodProvided
    method = validMethods{indMethod};
end

%--------------------------------------------------------------------------
function [dim,dimProvided] = parseDim(dim,d,AisTabular)
dimNumeric = isnumeric(d) || islogical(d);
dimProvided = dimNumeric && isscalar(d) && isreal(d) && ...
                (fix(d) == d) && (d > 0) && isfinite(d);
if dimNumeric && ~dimProvided
    error(message('MATLAB:ischange:DimensionInvalid'));
end
if dimProvided 
    if AisTabular
        error(message('MATLAB:ischange:DimensionTable'));
    end
    dim = d;
end

%--------------------------------------------------------------------------
function [x,numchanges,threshold,dataVars] = ...
        parseNV(A,AisTabular,x,numchanges,threshold,dim,dataVars,startNV,varargin)
for ii = startNV:2:numel(varargin)
    if matlab.internal.math.checkInputName(varargin{ii},'SamplePoints')
        if isa(A,'timetable')
            error(message('MATLAB:ischange:SamplePointsTimeTable'));
        end
        x = checkSamplePoints(varargin{ii+1},A,false,dim);
    elseif matlab.internal.math.checkInputName(varargin{ii},'DataVariables')
        if AisTabular
            dataVars = matlab.internal.math.checkDataVariables(A,varargin{ii+1},'ischange');
        else
            error(message('MATLAB:ischange:DataVariablesArray'));
        end
    elseif matlab.internal.math.checkInputName(varargin{ii},'MaxNumChanges',2)
        % Match at least 2 characters to avoid ambiguity with 'mean'
        % ischange(A,'m',dim) is parsed as ischange(A,'mean',dim)
        numchanges = varargin{ii+1};
        if ~((isnumeric(numchanges) || islogical(numchanges)) && ...
                isscalar(numchanges) && isreal(numchanges) && ...
                (fix(numchanges) == numchanges) && (numchanges > 0))
            error(message('MATLAB:ischange:MaxNumChanges'));
        end
    elseif matlab.internal.math.checkInputName(varargin{ii},'Threshold')
        threshold = varargin{ii+1};
        if ~((isnumeric(threshold) || islogical(threshold)) && ...
                isscalar(threshold) && isreal(threshold) && ...
                (threshold >= 0) && isfinite(threshold))
            error(message('MATLAB:ischange:Threshold'));
        end
    else
        error(message('MATLAB:ischange:NameValueNames'));
    end
end

%--------------------------------------------------------------------------
function x = checkSamplePoints(x,A,AisTimeTable,dim)
% Validate SamplePoints value. Same code as in islocalmax.

if AisTimeTable
    errBase = 'RowTimes';
else
    errBase = 'SamplePoints';
end

% Empty timetables should not error
if AisTimeTable && isempty(A)
    return;
end

if ~AisTimeTable
    if (~isvector(x) && ~isempty(x)) || ...
        (~isfloat(x) && ~isduration(x) && ~isdatetime(x))
        error(message('MATLAB:ischange:SamplePointsInvalidDatatype'));
    end
    if numel(x) ~= (size(A,dim) * ~isempty(A))
        error(message(['MATLAB:ischange:', errBase, 'Length']));
    end
    if isfloat(x)
        if ~isreal(x)
            error(message(['MATLAB:ischange:', errBase, 'Complex']));
        end
        if issparse(x)
            error(message(['MATLAB:ischange:', errBase, 'Sparse']));
        end
    end
end
if any(~isfinite(x))
    error(message(['MATLAB:ischange:', errBase, 'Finite']));
end

x = x(:);
if any(diff(x) <= 0)
    if any(diff(x) == 0)
        error(message(['MATLAB:ischange:', errBase, 'Duplicate']));
    else
        error(message(['MATLAB:ischange:', errBase, 'Sorted']));
    end
end
