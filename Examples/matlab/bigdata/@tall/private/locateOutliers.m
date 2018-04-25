function varargout = locateOutliers(A, varargin)
% LOCATEOUTLIERS Detect (and fill) outliers in tall arrays and tall tables.

% Copyright 2017 The MathWorks, Inc.

if nargout < 5
    fname = 'isoutlier'; % [TF,LB,UB,C] = tall/isoutlier(A,...)
else
    fname = 'filloutliers'; % [B,TF,LB,UB,C] = tall/filloutliers(A,...)
end

% Parse inputs and error out as early as possible.
% The first input and 'OutlierLocations' must be tall. The other inputs
% must not be tall (will be checked later on when we parse them).
tall.checkIsTall(upper(fname),1,A);
typesA = {'double','single','table','timetable'};
A = tall.validateType(A,fname,typesA,1);
opts = iParseInputs(A,fname,varargin{:});

% Match in-memory error message for complex data.
if ~opts.IsTabular
    A = lazyValidate(A,{@(a)iValidateattributesPred(a,typesA,fname)});
end

if istall(opts.Method) % Fill outliers according to 'OutlierLocations'
    if opts.IsTabular
        [varargout{1:nargout}] = iTabularWrapper(A,fname,opts,@iFillLocations);
    else
        [varargout{1:nargout}] = iFillLocations(A,opts);
    end
elseif startsWith(opts.Method, {'me', 'movme'})
    % 'median' (default), 'mean', 'movmedian', 'movmean'
    if opts.IsTabular
        [varargout{1:nargout}] = iTabularWrapper(A,fname,opts,@iOutliersMedianMean);
    else
        [varargout{1:nargout}] = iOutliersMedianMean(A,opts);
    end
else
    % 'quartiles'
    if opts.IsTabular
        [varargout{1:nargout}] = iTabularWrapper(A,fname,opts,@iOutliersQuartiles);
    else
        [varargout{1:nargout}] = iOutliersQuartiles(A,opts);
    end
end

%--------------------------------------------------------------------------
function [TF,lowerbound,upperbound,center,B] = iOutliersMedianMean(A,opts)
% Outlier detection: 'median', 'mean', 'movmedian', 'movmean'.
% 'median', 'mean', 'movmedian', and 'movmean' only need (mov)median,
% (mov)mean, (mov)std, abs, and erfcinv. Therefore, we can directly use
% the tall implementations of these functions.

if strcmpi(opts.Method,'median')
    % tall/median errors with a median-specific message if DIM cannot be
    % deduced. We avoid this and error ourselves if:
    %   (1) The DIM cannot be deduced
    %   (2) AND the first input was not a tall column vector.
    % If the first input was a tall column vector, we do compute outliers.
    [A,opts.Dim] = iDeduceFirstNonSingletonDimOrError(A,opts.Dim);
    dimAndNaN = {opts.Dim 'omitnan'};
else
    % We let the tall implementations of movmedian, (mov)mean, (mov)std
    % properly handle DIM, which we had parsed and set to [] if unknown.
    dimAndNaN(~isempty(opts.Dim)) = {opts.Dim};
    dimAndNaN = [dimAndNaN,{'omitnan'}]; % {'omitnan'} or {dim 'omitnan'}
end

switch opts.Method
    case 'median'
        center = median(A,dimAndNaN{:});
        k = -1/(sqrt(2)*erfcinv(3/2)); % ~ 1.4826
        thresh = k .* median(abs(A-center),dimAndNaN{:});
    case 'mean'
        center = mean(A,dimAndNaN{:});
        thresh = std(A,0,dimAndNaN{:});
    case 'movmedian'
        center = movmedian(A,opts.Window,dimAndNaN{:});
        k = -1/(sqrt(2)*erfcinv(3/2)); % ~ 1.4826
        thresh = k .* movmad(A,opts.Window,dimAndNaN{:});
    otherwise % 'movmean'
        center = movmean(A,opts.Window,dimAndNaN{:});
        thresh = movstd(A,opts.Window,0,dimAndNaN{:});
end

% Apply the outlier thresholds.
lowerbound = center - opts.ThresholdFactor .* thresh;
upperbound = center + opts.ThresholdFactor .* thresh;
TF = A < lowerbound | upperbound < A;

% Fill outliers if called by tall/filloutliers.
if nargout > 4
    B = iFillOutliers(A,TF,lowerbound,upperbound,center,opts);
end

%--------------------------------------------------------------------------
function [A,dim] = iDeduceFirstNonSingletonDimOrError(A,dim)
% Deduce the first non-singleton dimension. If we cannot deduce it, error
% for tall arrays that are not column vectors.
if isempty(dim)
    dim = getDefaultReductionDimIfKnown(A.Adaptor);
    if isempty(dim)
        % DIM couldn't be deduced. Error for non-column tall inputs.
        errid = 'MATLAB:bigdata:array:NoDimMustBeColumn';
        A = tall.validateColumn(A,errid);
        % But do compute for a tall column vector.
        dim = 1;
    end
end

%--------------------------------------------------------------------------
function [TF,LB,UB,C,B] = iOutliersQuartiles(A,opts)
% Branch 'quartiles' according to the tall dimension (DIM == 1).

[A,opts.Dim] = iDeduceFirstNonSingletonDimOrError(A,opts.Dim);

if opts.Dim == 1
    % Use the tall algorithm.
    [TF,LB,UB,C] = iQuartilesTallCol(A,opts.ThresholdFactor);
else
    % Use in-memory algorithm on each slice.
    fh = @(x,d)isoutlier(x,'quartiles',d,'Threshold',opts.ThresholdFactor);
    [TF,LB,UB,C] = slicefun(fh,A,opts.Dim);
    TF = iSetFirstOutputAdaptor(A,TF);
end

% Fill outliers if called by tall/filloutliers.
if nargout > 4
    B = iFillOutliers(A,TF,LB,UB,C,opts);
end

%--------------------------------------------------------------------------
function [tf,lowerbound,upperbound,center] = iQuartilesTallCol(a,factor)
% Same formula as non-tall isoutlier, but rephrased in a tall-friendly way.

% Remove NaNs, since isoutlier 'quantiles' omits NaNs.
b = filterslices(~isnan(a),a);

% Get the intervals containing the two quartiles via tall/histcounts.
[b1,q1,b3,q3] = percentileDataBin(b,25,75);

% We have reduced the problem to applying the quartiles formula on the
% first quartile interval and third quartile interval. This can be done
% in-memory, as we only need at most 4 entries of the tall column A.
[quartile1,quartile3] = clientfun(@iQuartilesClientfun,b1,q1,b3,q3);

% Apply the quartile thresholds.
center = mean([quartile1 quartile3],2);
iqr = quartile3 - quartile1;
lowerbound = quartile1 - factor .* iqr;
upperbound = quartile3 + factor .* iqr;
tf = a < lowerbound | upperbound < a;

%--------------------------------------------------------------------------
function [quart1,quart3] = iQuartilesClientfun(b1,q1,b3,q3)
quart1 = iQuartileFormula(b1,q1); % First qartile
quart3 = iQuartileFormula(b3,q3); % Third quartile

%--------------------------------------------------------------------------
function quartile = iQuartileFormula(a12,xq)
if isnan(xq)
    % Empties and scalars: return same result as in-memory isoutlier.
    quartile = NaN(class(a12));
elseif numel(a12) <= 1
    % The quartile coincides with an actual entry of the tall column A.
    quartile = a12;
else
    % The quartile is between two consecutive entries in the tall column A.
    quartile = interp1(a12,xq+1);
end

%--------------------------------------------------------------------------
function [TF,LB,UB,C,B] = iTabularWrapper(A,fname,opts,outlierFun)
% Tall array outlier computations for each tall (time)table variable.

opts.MethodIn = opts.Method; % Need to keep track for 'OutlierLocations'.

av = opts.AllVars;
dv = opts.DataVars;
numav = numel(av);
numdv = numel(dv);

% Validate table variables upfront, just like in tall/fillmissing.
adaptorA = A.Adaptor;
A = elementfun(@(T)iCheckTableVarType(T,fname,dv),A);
A.Adaptor = adaptorA;

if nargout > 4
    B = A; % First output from filloutliers.
end
% Use cells to hold individual tall table variable results.
dataTF = cell(1,numav); % TF has the same size as the table.
dataLB = cell(1,numdv);
dataUB = cell(1,numdv);
dataC = cell(1,numdv);

% Apply tall array computation with DIM = 1 to each (time)table variable.
for jj = 1:numdv
    % Get and validate the table variable.
    vj = subsref(A,substruct('.',dv{jj}));
    % Compute.
    if nargout > 4
        % tall/filloutliers
        if istall(opts.MethodIn)
            % Select appropriate column of 'OutlierLocations' logical mask.
            mj = ismember(av,dv{jj});
            opts.Method = subsref(opts.MethodIn,substruct('()',{':',mj}));
        end
        [dataTF{jj},dataLB{jj},dataUB{jj},dataC{jj},vjf] = outlierFun(vj,opts);
        % Assign back to jth (time)table variable.
        B = subsasgn(B,substruct('.',dv{jj}),vjf);
    else
        % tall/isoutlier
        [dataTF{jj},dataLB{jj},dataUB{jj},dataC{jj}] = outlierFun(vj,opts);
    end
    % Match in-memory behavior for non-column table variables.
    dataTF{jj} = any(dataTF{jj},2);
end

% TF has the same size as the table. Reconcile this with DataVariables.
if numdv < numav
    % Map computed results back to the correct columns in TF.
    colsInDataVars = ismember(av,dv);
    dataTF(colsInDataVars) = dataTF(1:numdv);
    % Set the columns that were not included in DataVariables to FALSE.
    v1 = subsref(A,substruct('.',av{1})); % av is never empty here
    falseColumn = slicefun(@(a)false(size(a,1),1),v1);
    falseColumn = setKnownType(falseColumn,'logical');
    dataTF(~colsInDataVars) = {falseColumn};
end

if numav == 0
    % For empty tables A, force TF to have the same number of rows as A.
    TF = elementfun(@(a)false(size(a,1),0),A);
else
    % Convert cells of tall columns into correct tall outputs.
    TF = [dataTF{:}];
end
TF = iSetFirstOutputAdaptor(A,TF);

% Similar approach to tall/varfun for tall (time)table outputs 2, 3, and 4.
if strcmpi(A.Adaptor.Class,'table')
    if isempty(dv)
        % Empty DataVariables or empty tables.
        LB = tall.createGathered(table.empty(1,0));
        UB = LB;
        C = LB;
    else
        LB = table(dataLB{:},'VariableNames',dv);
        UB = table(dataUB{:},'VariableNames',dv);
        C = table(dataC{:},'VariableNames',dv);
    end
else
    dn = subsref(A,substruct('.','Properties','.','DimensionNames'));
    rt = subsref(A,substruct('.','Properties','.','RowTimes'));
    % Match in-memory isoutlier and keep the first entry in Time.
    if ~startsWith(opts.Method,'mov')
        rt = head(rt,1);
    end
    LB = makeTallTimetableWithDimensionNames(dn,rt,dv,'',dataLB{:});
    UB = makeTallTimetableWithDimensionNames(dn,rt,dv,'',dataUB{:});
    C = makeTallTimetableWithDimensionNames(dn,rt,dv,'',dataC{:});
end

%--------------------------------------------------------------------------
function A = iCheckTableVarType(A,functionName,dataVars)
% Match in-memory error messages.
errid1 = ['MATLAB:',functionName,':NonColumnTableVar'];
errid2 = ['MATLAB:',functionName,':NonfloatTableVar'];
errid3 = ['MATLAB:',functionName,':ComplexTableVar'];
for jj = 1:numel(dataVars)
    vj = A.(dataVars{jj});
    if ~(isempty(vj) || iscolumn(vj))
        error(message(errid1));
    end
    if ~isfloat(vj)
        error(message(errid2,dataVars{jj},class(vj)));
    end
    if ~isreal(vj)
        error(message(errid3));
    end
end

%--------------------------------------------------------------------------
function TF = iSetFirstOutputAdaptor(A,TF)
% First output is always logical of the same size as the first input.
outAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('logical');
TF.Adaptor = copySizeInformation(outAdaptor,A.Adaptor);

%--------------------------------------------------------------------------
function opts = iParseInputs(A,fname,varargin)
% Parse and check inputs for tall/isoutlier and tall/filloutliers.

fillOutliers = strcmpi(fname,'filloutliers');

opts.IsTabular = any(strcmpi(A.Adaptor.Class,{'table', 'timetable'}));
opts.Method = 'median';
opts.Window = [];

if fillOutliers
    % Match FILLOUTLIERS(A,FILL,...) error message.
    tall.checkNotTall(upper(fname),1,varargin{1});
    if ischar(varargin{1}) || isstring(varargin{1})
        varargin{1} = validatestring(varargin{1}, {'center', 'clip', ...
            'previous', 'next', 'nearest', 'linear', 'spline', ...
            'pchip'},fname,'Fill',2);
    else
        validateattributes(varargin{1},{'numeric'},{'scalar'},fname, ...
            'Fill',2);
    end
    opts.Fill = varargin{1};
end

computeOutliers = false;
ind = 1+fillOutliers; % Account for presence of FILL method.
if nargin-1 > ind && (ischar(varargin{ind}) || isstring(varargin{ind}))
    tall.checkNotTall(upper(fname),ind,varargin{ind});
    % Match ISOUTLIER(A,METHOD,N1,V1,...) error message.
    % Match FILLOUTLIERS(A,FILL,METHOD,N1,V1,...) error message.
    validParams = {'median', 'mean', 'quartiles', 'grubbs', 'gesd', ...
        'movmedian', 'movmean', 'SamplePoints', 'DataVariables', ...
        'ThresholdFactor', 'MaxNumOutliers', 'OutlierLocations'};
    validParams = validParams(1:(end - ~fillOutliers));
    mthd = validatestring(varargin{ind},validParams,ind+1);
    if any(strcmpi(mthd,{'median', 'mean', 'quartiles'}))
        opts.Method = mthd;
        computeOutliers = true;
        ind = ind+1;
    elseif any(strcmpi(mthd,{'movmean', 'movmedian'}))
        % Parse the mov methods as in tall/fillmissing.
        % Match ISOUTLIER(A,MOVMETHOD,WINDOW,N1,V1,...) error.
        % Match FILLOUTLIERS(A,FILL,MOVMETHOD,WINDOW,N1,V1,...) error.
        if nargin-1 < 3+fillOutliers
            error(message(['MATLAB:',fname,':MissingWindowLength'],mthd));
        end
        if strcmpi(A.Adaptor.Class,'timetable')
            error(message('MATLAB:bigdata:array:OutliersMovmethodTimetable'));
        end
        tall.checkNotTall(upper(fname),ind+1,varargin{ind+1});
        movOpts = parseMovOpts(str2func(mthd),varargin{ind+1});
        opts.Window = movOpts.window;
        opts.Method = mthd;
        computeOutliers = true;
        ind = ind+2;
    elseif any(strcmpi(mthd,{'grubbs', 'gesd'}))
        error(message('MATLAB:bigdata:array:OutliersGrubbsGesd'));
    end
end

% Other defaults
if opts.IsTabular
    opts.Dim = 1;
    opts.AllVars = subsref(A,substruct('.','Properties','.','VariableNames'));
    opts.DataVars = opts.AllVars;
else
    opts.Dim = []; % [] denotes that DIM is unknown.
end

if strcmpi(opts.Method,'quartiles')
    opts.ThresholdFactor = 1.5;
else % {'median','mean','movmedian','movmean'}
    opts.ThresholdFactor = 3;
end

% No trailing optional inputs
if nargin-1 <= ind
    return;
end

% ISOUTLIER(A,DIM,...)
% ISOUTLIER(A,METHOD,DIM,...)
% ISOUTLIER(A,MOVMETHOD,WIN,DIM,...)
% FILLOUTLIERS(A,FILL,DIM,...)
% FILLOUTLIERS(A,FILL,METHOD,DIM,...)
% FILLOUTLIERS(A,FILL,MOVMETHOD,WIN,DIM,...)
if ~(ischar(varargin{ind}) || isstring(varargin{ind}))
    tall.checkNotTall(upper(fname),ind,varargin{ind});
    % Match in-memory check.
    validateattributes(varargin{ind},{'numeric'},{'scalar','integer',...
        'positive'},fname,'dim',ind+1);
    opts.Dim = varargin{ind};
    ind = ind+1;
    if opts.IsTabular && opts.Dim ~= 1
        error(message(['MATLAB:',fname,':TableDim']));
    end
end

% Trailing N-V pairs
if rem(numel(varargin(ind:end)),2) ~= 0
    error(message(['MATLAB:',fname,':ArgNameValueMismatch']));
end
validParams = {'SamplePoints', 'DataVariables', 'ThresholdFactor', ...
    'MaxNumOutliers', 'OutlierLocations'};
validParams = validParams(1:(end - ~fillOutliers));
for ii = ind:2:numel(varargin)
    tall.checkNotTall(upper(fname),ii,varargin{ii});
    parName = validatestring(varargin{ii},validParams,ii+1);
    parVal = varargin{ii+1};
    switch parName
        case 'SamplePoints'
            error(message('MATLAB:bigdata:array:SamplePointsNotSupported'));
        case 'DataVariables'
            tall.checkNotTall(upper(fname),ii+1,parVal);
            if opts.IsTabular
                varInds = checkDataVariables(A,parVal,fname);
                opts.DataVars = opts.AllVars(sort(varInds));
            else
                error(message(['MATLAB:',fname,':DataVariablesArray']));
            end
        case 'ThresholdFactor'
            tall.checkNotTall(upper(fname),ii+1,parVal);
            % Match in-memory check.
            validateattributes(parVal,{'numeric'},{'real', 'scalar', ...
                'nonnegative', 'nonnan'},fname,'ThresholdFactor',ii+2);
            opts.ThresholdFactor = double(parVal);
        case 'MaxNumOutliers'
            tall.checkNotTall(upper(fname),ii+1,parVal);
            % Match in-memory check.
            validateattributes(parVal,{'numeric'},{'scalar', ...
                'positive','integer'},fname,'MaxNumOutliers',ii+2);
            if ~strcmpi(opts.Method,'gesd')
                error(message(['MATLAB:',fname,':MaxNumOutliersGesdOnly']));
            end
        otherwise % 'OutlierLocations'
            % Must be tall and have the same size as the first input.
            tall.checkIsTall(upper(fname),ii+2,parVal);
            parVal = tall.validateType(parVal,fname,{'logical'},ii+2);
            [A,parVal] = validateSameTallSize(A,parVal);
            [A,parVal] = lazyValidate(A,parVal, ...
                {@(x,y)isequal(size(x),size(y)), ...
                'MATLAB:bigdata:array:OutliersLocation'});
            % Match in-memory check.
            if computeOutliers
                error(message('MATLAB:filloutliers:MethodNotAllowed'));
            end
            if any(strcmpi(opts.Fill,{'center', 'clip'}))
                error(message('MATLAB:filloutliers:UnsupportedFill'));
            end
            opts.Method = parVal;
    end
end

%--------------------------------------------------------------------------
function tf = iValidateattributesPred(A,typesA,fname)
% We need a predicate to return A because validateattributes has no output.
validateattributes(A,typesA,{'real'},fname,'A',1);
tf = true;

%--------------------------------------------------------------------------
function [TF,LB,UB,C,B] = iFillLocations(A,opts)
% Fill outliers according to 'OutlierLocations'.
TF = opts.Method; % 'OutlierLocations' value.

% For consistency with in-memory filloutliers, the bounds and center must
% be reduction results filled with NaNs.
dim(~isempty(opts.Dim)) = {opts.Dim}; % Empty for default dimension.

% Follow tall/sum approach to get reduced results full of NaNs and
% dimension information. Can't use @(x) x+NaN directly because reducemInDim
% only supports @sum, @min, @median ...
[LB,opts.Dim] = reduceInDim(@sum,A,dim{:});
LB.Adaptor = A.Adaptor;
LB.Adaptor = computeReducedSize(LB.Adaptor,A.Adaptor,opts.Dim,false);
LB = elementfun(@(x) x+NaN,LB); % Fill with NaNs of correct type.
UB = LB;
C = LB;

B = iFillOutliers(A,TF,LB,UB,C,opts);

%--------------------------------------------------------------------------
function B = iFillOutliers(A,TF,lowerbound,upperbound,center,opts)
% Fill outliers
B = A;
if isnumeric(opts.Fill)
    B = elementfun(@iReplaceUsingLogicalMask,B,TF,opts.Fill);
elseif strcmpi(opts.Fill,'center')
    if startsWith(opts.Method,'mov')
        % B(TF) = center(TF)
        B = elementfun(@iReplaceUsingLogicalMask,B,TF,center);
    else
        % center is a reduced array containing a single center along the
        % operating dimension, but we need to fill multiple outliers along
        % this dimension with this center value.
        % This is done in in-memory filloutliers with:
        % B(TF) = center(ceil(find(TF)/size(A,DIM)))
        B = TF.*center;
        B = elementfun(@iReplaceUsingLogicalMask,B,~TF,A);
    end
elseif strcmpi(opts.Fill,'clip')
    % Same call as in-memory filloutliers.
    B = min(max(B,lowerbound,'includenan'),upperbound,'includenan');
else
    % NaNs are ignored by isoutlier and filloutliers, so we can use
    % tall/fillmissing by changing outliers to NaN: B(TF) = NaN.
    B = elementfun(@iReplaceUsingLogicalMask,B,TF,NaN);
    dim(~isempty(opts.Dim)) = {opts.Dim}; % Empty for default dimension.
    B = fillmissing(B,opts.Fill,dim{:});
    % But do not fill the original NaNs in the data: B(isnan(A)) = NaN.
    B = elementfun(@iReplaceUsingLogicalMask,B,isnan(A),NaN);
end
B.Adaptor = A.Adaptor;

%--------------------------------------------------------------------------
function b = iReplaceUsingLogicalMask(b,tf,r)
if isscalar(r)
    b(tf) = r;
else % r has the same size as b.
    b(tf) = r(tf); % r is the array of centers from 'movmedian'/'movmean'.
end
