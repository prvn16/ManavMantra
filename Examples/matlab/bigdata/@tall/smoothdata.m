function y = smoothdata(A, varargin)
% SMOOTHDATA   Smooth noisy data.
%
%   B = SMOOTHDATA(A, METHOD, WINSIZE)
%   B = SMOOTHDATA(A, DIM, METHOD, WINSIZE)
%   B = SMOOTHDATA(..., NANFLAG)
%   B = SMOOTHDATA(..., Name, Value)
%
%   Limitations:
%   1) Tall timetables are not supported.
%   2) The 'rlowess' and 'rloess' methods are not supported.
%   3) Multiple outputs are not supported.
%   4) You must specify the window size.  Automatic selection of the window
%      size is not supported.
%   5) The 'SamplePoints' and 'SmoothingFactor' name-value pairs are not
%      supported.
%   6) The value of 'DataVariables' cannot be a function_handle.
%
%   See also SMOOTHDATA, TALL/ISOUTLIER, TALL/FILLMISSING, TALL/ISMISSING

% Copyright 2017 The MathWorks, Inc.

% Parse inputs and error out as early as possible.
fname = mfilename;
% Only the first input can be tall.
tall.checkIsTall(upper(fname),1,A);
tall.checkNotTall(upper(fname),1,varargin{:});


% We have a specific error for timetable. Other unsupported types go
% through the normal type check.
if strcmpi(A.Adaptor.Class, 'timetable')
    error(message('MATLAB:bigdata:array:SmoothdataTimetableUnsupported'));
end
typesA = {'double','single','uint8','int8','uint16','int16','uint32',...
    'int32','uint64','int64','logical','table'};
A = tall.validateType(A,fname,typesA,1);
opts = iParseInputs(A,varargin{:});

if startsWith(opts.Method, "mov")
    fcn = @iSmoothdataMoving;
elseif opts.Method == "gaussian"
    fcn = @iSmoothdataGaussian;
else
    % 'sgolay', 'lowess', 'loess'
    fcn = @iSmoothdataRegression;
end

if opts.IsTabular
    y = iTabularWrapper(A,opts,fcn);
else
    y = fcn(A,opts);
end

%--------------------------------------------------------------------------
function B = iSmoothdataMoving(A, opts)
% We let the tall implementations of movmedian and movmean properly handle
% DIM, which we had parsed and set to [] if unknown.
dimAndNaN(~isempty(opts.Dim)) = {opts.Dim};
dimAndNaN = [dimAndNaN, {opts.Nanflag} ];

if opts.Method == "movmedian"
    % "movmedian" in smoothdata requires non-singles to be converted to
    % double first.
    A = elementfun(@iCastIntegerToDouble, A);
    % "movmedian" will properly set the output type.
    B = movmedian(A,opts.Window,dimAndNaN{:});
else
    % "movmean" will properly set the output type.
    B = movmean(A,opts.Window,dimAndNaN{:});
end

%--------------------------------------------------------------------------
function x = iCastIntegerToDouble(x)
% Promote integer/logical data to double for movmedian.
if ~isa(x, 'single')
    x = double(x);
end

%--------------------------------------------------------------------------
function B = iSmoothdataGaussian(A, opts)
% Perform Gaussian smoothing.

% We let the tall implementations of movcommon properly handle DIM,
% which we had parsed and set to [] if unknown.
dimAndNaN(~isempty(opts.Dim)) = {opts.Dim};
dimAndNaN = [dimAndNaN, {opts.Nanflag} ];
% Build a moving function to pass to movcommon.
movFcn = @(varargin) iMovingWindowGaussianSmooth(opts.Window, varargin{:});
B = movcommon(A, opts.Window, movFcn, dimAndNaN{:});
if ~isempty(A.Adaptor.Class) && ~strcmpi('single', A.Adaptor.Class)
    % For smoothdata: output is always double except when input is single
    B = setKnownType(B, 'double');
end

%--------------------------------------------------------------------------
function B = iSmoothdataRegression(A, opts)
% Perform smoothing via local regression.

% We let the tall implementations of movcommon properly handle DIM,
% which we had parsed and set to [] if unknown.
dimAndNaN(~isempty(opts.Dim)) = {opts.Dim};
dimAndNaN = [dimAndNaN, {opts.Nanflag} ];
% Build a moving function to pass to movcommon.
movFcn = @(X,k,varargin) iMovingWindowRegression(opts.Degree, ...
    opts.Window, opts.Method, X, k, varargin{:});
% Convert the window size into a vector if necessary.
if numel(opts.Window) == 1
    % The exact window size matters; the fractional portions must be
    % preserved to agree with the in-memory version.
    opts.Window = opts.Window ./ [2 2];
end
% Call movcommon with double the window size to ensure endpoints are
% handled properly.
B = movcommon(A, fix(opts.Window + flip(opts.Window)), movFcn, dimAndNaN{:});
if ~isempty(A.Adaptor.Class) && ~strcmpi('single', A.Adaptor.Class)
    % For smoothdata: output is always double except when input is single
    B = setKnownType(B, 'double');
end

%--------------------------------------------------------------------------
function discardOption = iCheckEndpointArguments(varargin)
% Check and parse endpoint options.
assert(nargin == 2);
assert(strcmpi(varargin{1}, 'Endpoints'));
discardOption = strcmpi(varargin{2}, 'discard');

%--------------------------------------------------------------------------
function B = iThrowOutEndpoints(A, k, dim)
% Throw out endpoints from a moving window function

assert(numel(k)>1, "MOVCOMMON always provides a vector window size");
istart = 1 + k(1);
istop = size(A,dim) - k(2);
% Subselect the portion we want.
B = matlab.bigdata.internal.util.indexSlices(A, istart:istop);

%--------------------------------------------------------------------------
function B = iMovingWindowGaussianSmooth(kOrig, A, k, dim, nanflag, varargin)
% Gaussian smoothing as moving window method.
discardOption = false;
if nargin > 5
    discardOption = iCheckEndpointArguments(varargin{:});
end
% Account for differences between built-in and m-code.
B = smoothdata(A, dim, 'gaussian', kOrig, nanflag);
if discardOption
    B = iThrowOutEndpoints(B, k, dim);
end

%--------------------------------------------------------------------------
function B = iMovingWindowRegression(degree, kOrig, methodName, A, k, dim, ...
    nanflag, varargin)
% Local regression smoothing as moving window method.
discardOption = false;
if nargin > 6
    discardOption = iCheckEndpointArguments(varargin{:});
end
degreeOpt = {};
if methodName == "sgolay"
    degreeOpt = { 'Degree', degree };
end
B = smoothdata(A, dim, methodName, kOrig, nanflag, degreeOpt{:});
if discardOption
    % Center portion, throw out based on the augmented window size.
    B = iThrowOutEndpoints(B, k, dim);
end

%--------------------------------------------------------------------------
function y = iTabularWrapper(A,opts,smoothFun)
% Tall array smoothing computations for each tall table variable.

av = opts.AllVars;
dv = opts.DataVars;
if isempty(dv)
    y = A;
    return;
end
numav = numel(av);

% Use cells to hold individual tall table variable results.
yr = cell(1,numav); % y has the same size as the table.

% Apply tall array computation with DIM = 1 to each table variable.
errid = 'MATLAB:smoothdata:nonNumericTableVar';
for jj = 1:numav
    if ismember(av{jj}, dv)
        % This variable is one of the data variables.
        % Get and validate the table variable.
        vj = subsref(A,substruct('.',av{jj}));
        vj = lazyValidate(vj,{@(x)isnumeric(x) || islogical(x),errid});
        % Compute.
        yr{jj} = smoothFun(vj,opts);
    else
        % Copy the input table variable.
        yr{jj} = subsref(A,substruct('.',av{jj}));
    end
end
y = table(yr{:},'VariableNames',av);

%--------------------------------------------------------------------------
function opts = iParseInputs(A,varargin)
% Parse and check inputs for tall/smoothdata.

opts.IsTabular = strcmpi(A.Adaptor.Class, 'table');
opts.Method = "movmean";
opts.Nanflag = 'omitnan';
opts.Window = [];
opts.Degree = [];
if opts.IsTabular
    opts.Dim = 1;
    opts.AllVars = subsref(A,substruct('.','Properties','.','VariableNames'));
    opts.DataVars = opts.AllVars;
else
    opts.Dim = []; % [] denotes that DIM is unknown.
end
if nargin < 3
    error(message('MATLAB:bigdata:array:SmoothdataNoMethod'));
end

argIdx = 1;

% Parse dimension argument.
if ~isNonTallScalarString(varargin{1})
    if nargin < 4
        error(message('MATLAB:bigdata:array:SmoothdataNoMethod'));
    end
    if opts.IsTabular
        error(message("MATLAB:smoothdata:noDimForTable"));
    end
    opts.Dim = matlab.internal.math.getdimarg(varargin{argIdx});
    argIdx = 2;
end

% List of valid method names.
methodNames = ["movmean", "movmedian", "gaussian", "lowess", "loess",...
    "rlowess", "rloess", "sgolay"];

% Method and span parsing.
if isNonTallScalarString(varargin{argIdx})
    % Get index of provided smoothing method.
    methodID = iPartialMatchStringChoices(methodNames, varargin{argIdx});
    if nnz(methodID) == 1
        opts.Method = methodNames(methodID);
        if startsWith(opts.Method, "rlo")
            error(message('MATLAB:bigdata:array:SmoothdataRobustRegressionUnsupported'));
        end
        argIdx = argIdx + 1;
        % Window size parsing
        if (isnumeric(varargin{argIdx}) || islogical(varargin{argIdx}))
            opts.Window = iValidateWindowSize(varargin{argIdx});
            argIdx = argIdx + 1;
        end
    else
        error(message('MATLAB:bigdata:array:SmoothdataInvalidMethod'));
    end
else
    error(message("MATLAB:bigdata:array:SmoothdataInvalidMethod"));
end
if isempty(opts.Window)
    error(message('MATLAB:bigdata:array:SmoothdataNoMethod'));
end

currentErrorTerm = "Nanflag";

% Set error ID for Name-Value pair errors
NVPairID = "NVPair";
if opts.IsTabular
    NVPairID = NVPairID + "Table";
end
if opts.Method == "sgolay"
    NVPairID = NVPairID + "SGolay";
end

% Parse 'omitnan' / 'includenan' option.
userGaveNaNCondition = false;
if (argIdx < nargin) && isNonTallScalarString(varargin{argIdx})
    nanflagID = iPartialMatchStringChoices(["omitnan", "includenan"], ...
        varargin{argIdx});
    if any(nanflagID)
        currentErrorTerm = NVPairID;
        if nanflagID(2)
            opts.Nanflag = 'includenan';
        end
        userGaveNaNCondition = true;
        argIdx = argIdx + 1;
    end
end

% Include these parameters in the valid parameter list to issue the
% right error message.
validParams = ["SmoothingFactor", "SamplePoints"];
allParams = ["DataVariables", "Degree", "SmoothingFactor", "SamplePoints"];
if opts.IsTabular
    validParams(end+1) = "DataVariables";
end
if opts.Method == "sgolay"
    validParams(end+1) = "Degree";
end

% Name-Value pair parsing
while argIdx < nargin
    % Non-char/string input argument.
    if ~isNonTallScalarString(varargin{argIdx})
        error(message("MATLAB:smoothdata:invalid" + currentErrorTerm));
    end
    % Invalid specification of the NaN flag.
    if any(iPartialMatchStringChoices(["omitnan", "includenan"], varargin{argIdx}))
        if userGaveNaNCondition
            error(message("MATLAB:smoothdata:duplicateNanflag"));
        else
            error(message("MATLAB:smoothdata:nanflagAfterOptions"));
        end
    elseif nnz(iPartialMatchStringChoices(allParams, varargin{argIdx})) > 1
        % Case where "D" or "S" given as parameter name.
        error(message("MATLAB:smoothdata:invalid" + currentErrorTerm));
    elseif ~(nnz(iPartialMatchStringChoices(validParams, varargin{argIdx})) == 1)
        if iPartialMatchStringChoices("DataVariables", varargin{argIdx}) && ~opts.IsTabular
            error(message("MATLAB:smoothdata:DataVariablesArray"));
        elseif iPartialMatchStringChoices("Degree", varargin{argIdx}) && (opts.Method ~= "sgolay")
            error(message("MATLAB:smoothdata:degreeNoSgolay"));
        else
            % Error message might be about invalid option or Name-Value
            % pair depending on the input arguments
            error(message("MATLAB:smoothdata:invalid" + currentErrorTerm));
        end
    elseif iPartialMatchStringChoices("SamplePoints", varargin{argIdx})
        error(message('MATLAB:bigdata:array:SmoothdataSamplePointsUnsupported'));
    elseif iPartialMatchStringChoices("SmoothingFactor", varargin{argIdx})
        error(message('MATLAB:bigdata:array:SmoothdataSmoothingFactorUnsupported'));
    elseif iPartialMatchStringChoices("DataVariables", varargin{argIdx})
        currentErrorTerm = NVPairID;
        argIdx = argIdx + 1;
        if argIdx >= nargin
            error(message("MATLAB:smoothdata:nameNoValue", 'DataVariables'));
        else
            varInds = checkDataVariables(A,varargin{argIdx},mfilename);
            opts.DataVars = opts.AllVars(sort(varInds));
        end
    else
        % 'Degree' Name-Value pair
        argIdx = argIdx + 1;
        currentErrorTerm = NVPairID;
        if argIdx >= nargin
            error(message("MATLAB:smoothdata:nameNoValue", 'Degree'));
        else
            opts.Degree = varargin{argIdx};
        end
    end
    argIdx = argIdx + 1;
end

% Check the Degree parameter.
opts.Degree = iValidateOrDetermineDegree(opts.Degree, opts.Window,...
    opts.Method);

%--------------------------------------------------------------------------
function winsz = iValidateWindowSize(winsz)
% Check the window size input parameter

if isempty(winsz)
    error(message('MATLAB:bigdata:array:SmoothdataNoAutoSize'));
end

if ~isvector(winsz) || (numel(winsz) > 2)
    error(message("MATLAB:smoothdata:invalidWinsize"));
end
if ((any(winsz < 0)) || (isscalar(winsz) && (winsz == 0)))
    error(message("MATLAB:smoothdata:invalidWinsize"));
end
if isfloat(winsz)
    if ~isreal(winsz)
        error(message("MATLAB:smoothdata:noComplexWindows"));
    end
    if issparse(winsz)
        winsz = full(winsz);
    end
    if any(~isfinite(winsz))
        error(message("MATLAB:smoothdata:needsFiniteWindows"));
    end
end
winsz = double(winsz);

%--------------------------------------------------------------------------
function degree = iValidateOrDetermineDegree(degree, winsz, method)
% Check the Savitzky-Golay degree
if isempty(degree)
    winszTot = sum(winsz) + numel(winsz) - 1;
    if method == "lowess"
        degree = min(1, winszTot-1);
    else
        degree = min(2, winszTot-1);
    end
    return;
end

if isfloat(degree)
    if ~isreal(degree)
        error(message("MATLAB:smoothdata:noComplex", '''Degree'''));
    end
    if ~isfinite(degree)
        error(message("MATLAB:smoothdata:needsFinites", '''Degree'''));
    end
end
if ~isscalar(degree) || ~isnumeric(degree) || ...
        (fix(degree) ~= degree) || (degree < 0)
    error(message("MATLAB:smoothdata:negativeDegree"));
end
degree = full(double(degree));

% User specified window with [kb kf] syntax.
if numel(winsz) > 1
    winsz = sum(winsz) + 1;
end

% Check if degree is too large.
if (degree >= winsz)
    error(message("MATLAB:smoothdata:degreeTooLarge", winsz));
end

%--------------------------------------------------------------------------
function tf = iPartialMatchStringChoices(strChoices, strInput)
% Case-insensitive partial matching for option strings

if ~isstring(strInput)
    strInput = string(strInput);
end
if strlength(strInput) < 1
    tf = false(size(strChoices));
else
    tf = startsWith(strChoices, strInput, 'IgnoreCase', true);
end