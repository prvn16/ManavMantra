function [y, winsz] = smoothdata(A, varargin)
%SMOOTHDATA   Smooth noisy data.
%   B = SMOOTHDATA(A) for a vector A returns a smoothed version of A using
%   a moving average with a fixed window length. The length of the moving
%   average is determined based on the values of A.
%
%   For N-D arrays, SMOOTHDATA operates along the first array dimension
%   whose size does not equal 1.
%
%   SMOOTHDATA(A,DIM) smooths A along dimension DIM.
%
%   SMOOTHDATA(A,METHOD) and SMOOTHDATA(A,DIM,METHOD) smooth the entries of
%   A using the specified moving window method METHOD. METHOD can be one of
%   the following:
%
%     'movmean'     - (default) smooths by averaging over each window of A.
%                     This method can reduce periodic trends in data.
%                     
%     'movmedian'   - smooths by taking the median over each window of A.
%                     This method can reduce periodic trends in the
%                     presence of outliers.
%                     
%     'gaussian'    - smooths by filtering A with a Gaussian window.
%                     
%     'lowess'      - smooths by computing a linear regression in each
%                     window of A. This method is more computationally
%                     expensive but results in fewer discontinuities.
%                     
%     'loess'       - is similar to 'lowess', but uses local quadratic
%                     regressions.
%                     
%     'rlowess'     - smooths data using 'lowess' but is more robust to
%                     outliers at the cost of more computation.
%                     
%     'rloess'      - smooths data using 'loess' but is more robust to
%                     outliers at the cost of more computation.
%                     
%     'sgolay'      - smooths A using a Savitzky-Golay filter, which may be
%                     more effective than other methods for data that
%                     varies rapidly.
%
%   SMOOTHDATA(A,METHOD,WINSIZE) and SMOOTHDATA(A,DIM,METHOD,WINSIZE)
%   specify the moving window length used for METHOD. WINSIZE can be a
%   scalar or two-element vector. By default, WINSIZE is determined 
%   automatically from the entries of A.
%
%   SMOOTHDATA(...,NANFLAG) specifies how NaN (Not-a-Number) values are
%   treated and can be one of the following:
%
%     'omitnan'      - (default) NaN elements in the input data are ignored
%                      in each window. If all input elements in any window
%                      are NaN, the result for that window is NaN.
%     'includenan'   - NaN values in the input data are not ignored when
%                      smoothing.
%
%   SMOOTHDATA(...,'SmoothingFactor',FACTOR) specifies a smoothing factor
%   that may be used to adjust the level of smoothing by tuning the default
%   window size. FACTOR must be between 0 (producing smaller moving window
%   lengths and less smoothing) and 1 (producing larger moving window
%   lengths and more smoothing). By default, FACTOR = 0.25.
%   
%   The smoothing factor cannot be specified if WINSIZE is given.
%
%   SMOOTHDATA(...,'SamplePoints',X) also specifies the sample points X
%   used by the smoothing method. X must be a numeric, duration, or
%   datetime vector. X must be sorted and contain unique points. You can
%   use X to specify time stamps for the data. By default, SMOOTHDATA uses
%   data sampled uniformly at points X = [1 2 3 ... ].
%   
%   When 'SamplePoints' are specified, the moving window length is defined
%   relative to the sample points. If X is a duration or datetime vector,
%   then the moving window length must be a duration.
%
%   SMOOTHDATA(...,'DataVariables',DV) smooths the data only in the table
%   variables specified by DV. The default is all table variables in A.
%   DV must be a table variable name, a cell array of table variable names,
%   a vector of table variable indices, a logical vector, or a function 
%   handle that returns a logical scalar (such as @isnumeric).
%   The output table B has the same size as input table A.
%
%   SMOOTHDATA(...,'sgolay',...,'Degree',D) specifies the degree for the
%   Savitzky-Golay filter. For uniform sample points, D must be a
%   nonnegative integer less than WINSIZE. For nonuniform sample points, D
%   must be a nonnegative integer less than maximum number of points in
%   any window of length WINSIZE.
%
%   [B, WINSIZE] = SMOOTHDATA(...) also returns the moving window length.
%
%   EXAMPLE: Smooth a noisy exponential
%       a = 6*exp(-((-50:49)/20).^2) + 0.5*randn(1,100);
%       b = smoothdata(a);
%       plot(1:100, a, '-o', 1:100, b, '-x');
%
%   EXAMPLE: Smooth data with outliers using a moving median filter
%       a = 2*cos(2*pi*0.023*(1:100)) + randn(1,100);
%       a([15 35 46]) = -20*(rand(1,3)-0.5);
%       b = smoothdata(a, 'movmedian', 7);
%       plot(1:100, a, '-o', 1:100, b, '-x');
%
%   EXAMPLE: Smooth nonuniform data with a Gaussian filter
%       t = 100*sort(rand(1, 100));
%       x = cos(2*pi*0.04*t+2*pi*rand) + 0.4*randn(1,100);
%       y = smoothdata(x, 'gaussian', 15, 'SamplePoints', t);
%       plot(t, x, '-o', t, y, '-x');
%
%
%    See also FILLMISSING, RMMISSING, FILLOUTLIERS, ISOUTLIER
%   

% Copyright 2016 The MathWorks, Inc.

    narginchk(1,inf);

    if ~isnumeric(A) && ~islogical(A) && ~isa(A,'tabular')
        error(message("MATLAB:smoothdata:badArray"));
    end
    if isinteger(A) && ~isreal(A)
        error(message("MATLAB:smoothdata:complexIntegers"));
    end

    sparseInput = issparse(A);
    if sparseInput
        A = full(A);
    end

    [dim,method,winsz,nanflag,t,sgdeg,dvars] = parseInputs(A, varargin{:});

    if isempty(A) || (dim > ndims(A)) || (size(A,dim) < 2)
        % Non-floating point variables converted to double in output
        if isa(A, 'tabular')
            y = A;
            for j = dvars
                y.(j) = convertToFloat(y.(j));
            end
        else
            y = convertToFloat(A);
            if sparseInput
                y = sparse(y);
            end
        end
        return;
    end

    if isa(A, 'tabular')
        y = A;
        if isempty(dvars)
            return;
        end
        % Homogeneous tables can be filled as arrays
        singleCheck = varfun(@(x) isa(x, 'single'), A, ...
            'InputVariables', dvars, 'OutputFormat', 'uniform');
        sparseCheck = varfun(@issparse, A, 'InputVariables', dvars, ...
            'OutputFormat', 'uniform');
        if (all(singleCheck) || ~any(singleCheck)) && ~any(sparseCheck)
            if ~any(singleCheck)
                for j = dvars
                    y.(j) = double(y.(j));
                end
            end
            y{:,dvars} = smoothNumericArray(y{:, dvars}, method, dim, ...
                winsz, nanflag, t, sgdeg);
        else
            for j = dvars
                if issparse(y.(j))
                    y.(j) = sparse(smoothNumericArray(full(y.(j)), method, ...
                        dim, winsz, nanflag, t, sgdeg));
                else 
                    y.(j) = smoothNumericArray(y.(j), method, dim, winsz,...
                        nanflag, t, sgdeg);
                end
            end
        end
    else
        y = smoothNumericArray(A, method, dim, winsz, nanflag, t, sgdeg);
    end

    if sparseInput
        y = sparse(y);
    end

end

%--------------------------------------------------------------------------
function y = smoothNumericArray(A, method, dim, winsz, nanflag, t, degree)
% Smooth a single numeric array

    if ~isnumeric(A) && ~islogical(A)
        error(message("MATLAB:smoothdata:nonNumericTableVar"));
    end

    % Dispatch to the correct method
    if method == "gaussian"
        y = matlab.internal.math.smoothgauss(A,winsz,dim,nanflag,t);
    % Moving mean or median
    elseif startsWith(method, "mov")
        spargs = {};
        if ~isempty(t)
            spargs = { 'SamplePoints', t };
        end
        if contains(method, "mean")
            y = movmean(A, winsz, dim, char(nanflag), spargs{:});
        else
            % Smoothing always converts integers to doubles
            if isinteger(A)
                y = movmedian(double(A), winsz, dim, char(nanflag), spargs{:});
            else
                y = movmedian(A, winsz, dim, char(nanflag), spargs{:});
            end
        end
    % One of the (r)lo(w)ess methods
    elseif contains(method, "ess")
        degree = 1 + ~contains(method, "wess");
        y = matlab.internal.math.localRegression(A, winsz, dim, ...
            nanflag, degree, method, t);
    % Savitzky-Golay
    else
        y = matlab.internal.math.localRegression(A, winsz, dim, ...
            nanflag, degree, method, t);
    end

end

%--------------------------------------------------------------------------
function [dim,method,winsz,nanflag,t,sgdeg,dvars]=parseInputs(A, varargin)
% Parse and check input arguments

    method = "movmean";
    smoothingFactor = 0.25;
    dvars = [];
    if isa(A, 'tabular')
        dim = 1;
        dvars = 1:size(A,2);
    else
        % First non-singleton dimension
        dim = find(size(A) ~= 1, 1, 'first');
        if isempty(dim)
            dim = 1;
        end
    end
    winsz = [];
    sgdeg = 2;
    nanflag = "omitnan";
    currentErrorTerm = "Method";

    charHelper = @(x) (ischar(x) && isrow(x)) || (isstring(x) && isscalar(x));
    argIdx = 1;

    if (argIdx < nargin) && ~charHelper(varargin{1})
        if isa(A, 'tabular')
            error(message("MATLAB:smoothdata:noDimForTable"));
        end
        dim = varargin{argIdx};
        if ~(isnumeric(dim) || islogical(dim)) || ~isscalar(dim) || ...
             ~isreal(dim) || ((dim < 1) || (dim ~= round(dim)))
            error(message("MATLAB:getdimarg:dimensionMustBePositiveInteger"));
        end
        argIdx = 2;
    end

    methodNames = ["movmean", "movmedian", "gaussian", "lowess", "loess",...
        "rlowess", "rloess", "sgolay"];
    userGaveMethod = false;
    % Method and span parsing
    if argIdx < nargin
        if charHelper(varargin{argIdx})
            methodID = partialMatch(methodNames, varargin{argIdx});
            if nnz(methodID) > 1
                error(message("MATLAB:smoothdata:invalidMethod"));
            elseif nnz(methodID) == 1
                method = methodNames(methodID);
                userGaveMethod = true;
                argIdx = argIdx + 1;
                currentErrorTerm = "Winsize";
                % Window size parsing
                if (argIdx < nargin) && ( isnumeric(varargin{argIdx}) || ...
                    islogical(varargin{argIdx}) || ...
                    isdatetime(varargin{argIdx}) || ...
                    isduration(varargin{argIdx}) )
                    winsz = checkWindowSize(varargin{argIdx});
                    argIdx = argIdx + 1;
                    currentErrorTerm = "Nanflag";
                end
            end
        else
            error(message("MATLAB:smoothdata:invalidMethod"));
        end
    end

    % Set error ID for Name-Value pair errors
    NVPairID = "NVPair";
    if isa(A, 'tabular')
        NVPairID = NVPairID + "Table";
    end
    if method == 'sgolay'
        NVPairID = NVPairID + "SGolay";
    end

    % 'omitnan' / 'includenan' parsing
    userGaveNaNCondition = false;
    if (argIdx < nargin) && charHelper(varargin{argIdx})
        nanflagID = partialMatch(["omitnan", "includenan"], varargin{argIdx});
        if any(nanflagID)
            currentErrorTerm = NVPairID;
            if nanflagID(2)
                nanflag = "includenan";
            end
            userGaveNaNCondition = true;
            argIdx = argIdx + 1;
        end
    end

    if isa(A, 'timetable')
        t = checkSamplePoints([], A, 1);
    else
        t = [];
    end

    validParams = ["SamplePoints", "SmoothingFactor"];
    allParams = [validParams, "DataVariables", "Degree"];
    if isa(A, 'tabular')
        validParams(end+1) = "DataVariables";
    end
    if method == 'sgolay'
        validParams(end+1) = "Degree";
    end

    % Name-Value pair parsing
    userGaveDegree = false;
    while argIdx < nargin
        if ~charHelper(varargin{argIdx})
            error(message("MATLAB:smoothdata:invalid" + currentErrorTerm));
        else
            if currentErrorTerm == "Winsize"
                currentErrorTerm = "Nanflag";
            end
        end
        if ~userGaveMethod && any(partialMatch(methodNames, varargin{argIdx}))
            error(message("MATLAB:smoothdata:methodAfterOptions"));
        elseif any(partialMatch(["omitnan", "includenan"], varargin{argIdx}))
            if userGaveNaNCondition
                error(message("MATLAB:smoothdata:duplicateNanflag"));
            else
                error(message("MATLAB:smoothdata:nanflagAfterOptions"));
            end
        elseif nnz(partialMatch(allParams, varargin{argIdx})) > 1
            % Case where user specifies "D" as the name
            error(message("MATLAB:smoothdata:invalid" + currentErrorTerm));
        elseif ~(nnz(partialMatch(validParams, varargin{argIdx})) == 1)
            if partialMatch("DataVariables", varargin{argIdx}, 2) && ~isa(A, 'tabular')
                error(message("MATLAB:smoothdata:DataVariablesArray"));
            elseif partialMatch("Degree", varargin{argIdx}, 2) && (method ~= "sgolay")
                error(message("MATLAB:smoothdata:degreeNoSgolay"));
            else
                % Error message might be about invalid method, option, or
                % Name-Value pair depending on the input arguments
                error(message("MATLAB:smoothdata:invalid" + currentErrorTerm));
            end
        elseif partialMatch("SamplePoints", varargin{argIdx}, 2)
            currentErrorTerm = NVPairID;
            argIdx = argIdx + 1;
            if argIdx >= nargin
                error(message("MATLAB:smoothdata:nameNoValue", 'SamplePoints'));
            else
                if isa(A, 'timetable')
                    error(message("MATLAB:smoothdata:SamplePointsTimeTable"));
                end
                t = varargin{argIdx};
                checkSamplePoints(t, A, dim);
            end
        elseif partialMatch("SmoothingFactor", varargin{argIdx}, 2)
            currentErrorTerm = NVPairID;
            if ~isempty(winsz)
                error(message("MATLAB:smoothdata:tuneAndWindow"));
            end
            argIdx = argIdx + 1;
            if argIdx >= nargin
                error(message("MATLAB:smoothdata:nameNoValue", 'SmoothingFactor'));
            else
                smoothingFactor = checkSmoothingFactor(varargin{argIdx});
            end
        elseif partialMatch("DataVariables", varargin{argIdx})
            currentErrorTerm = NVPairID;
            argIdx = argIdx + 1;
            if argIdx >= nargin
                error(message("MATLAB:smoothdata:nameNoValue", 'DataVariables'));
            else
                dvars = matlab.internal.math.checkDataVariables(A, ...
                    varargin{argIdx}, 'smoothdata');
            end
        else
            % 'Degree' Name-Value pair
            argIdx = argIdx + 1;
            currentErrorTerm = NVPairID;
            if argIdx >= nargin
                error(message("MATLAB:smoothdata:nameNoValue", 'Degree'));
            else
                sgdeg = varargin{argIdx};
            end
            userGaveDegree = true;
        end
        argIdx = argIdx + 1;
    end

    % Check the data variables:
    if isa(A, 'tabular')
        dvarsValid = varfun(@validDataVariableType, A, 'InputVariables',...
            dvars, 'OutputFormat', 'uniform');
        if ~all(dvarsValid)
            % Check if any variables are complex integers:
            if any(varfun(@(x) isinteger(x) && ~isreal(x), A, 'InputVariables', ...
                dvars, 'OutputFormat', 'uniform'))
                error(message("MATLAB:smoothdata:complexIntegers"));
            end
            error(message("MATLAB:smoothdata:nonNumericTableVar"));
        end
    end

    % Check the type matching for sample points
    tIsTimeBased = ~isempty(t) && (isdatetime(t) || isduration(t));
    if tIsTimeBased
        % Non-uniform data that is timestamped
        if ~isempty(winsz) && ~isduration(winsz)
            error(message("MATLAB:smoothdata:winsizeNotDuration", class(t)));
        end
    else
        % Non timestamped data
        if ~isempty(winsz) && isduration(winsz)
            error(message("MATLAB:smoothdata:winsizeIsDuration"));
        end
    end

    autoPickedSize = isempty(winsz);
    nonEmptyInput = ~isempty(A) && ~(isa(A, 'tabular') && isempty(dvars));
    
    if autoPickedSize && nonEmptyInput
        winsz = tuneWindowSize(A, dim, t, 1 - smoothingFactor, dvars);
    end

    % Check the Degree parameter
    if nonEmptyInput
        sgdeg = checkDegree(method, sgdeg, t, winsz, autoPickedSize, ...
            userGaveDegree);
    end

end

%--------------------------------------------------------------------------
function winsz = checkWindowSize(winsz)
% Check the window size input parameter
    if ~(isvector(winsz) || isempty(winsz)) || ...
       ~(isnumeric(winsz) || isduration(winsz) || islogical(winsz)) || ...
        (numel(winsz) > 2)
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
    end
    if (isfloat(winsz) || isduration(winsz)) && any(~isfinite(winsz))
        error(message("MATLAB:smoothdata:needsFiniteWindows"));
    end
    if ~isduration(winsz)
        winsz = double(winsz);
    end
end

%--------------------------------------------------------------------------
function t = checkSamplePoints(t, A, dim)
% Check the sample points input parameter
    if isa(A, 'timetable')
        t = A.Properties.RowTimes;
    end

    if ~(isvector(t) || isempty(t)) || ...
       ~(isnumeric(t) || isduration(t) || isdatetime(t))
        error(message("MATLAB:smoothdata:invalidSamplePoints"));
    end

    if isempty(t)
        if isempty(A)
            return;
        else
            error(message("MATLAB:smoothdata:SamplePointsLength"));
        end
    end
    
    N = size(A,dim);

    term = '''SamplePoints''';
    if istimetable(A)
        term = '''RowTimes''';
    end

    if (isfloat(t) || isduration(t)) && any(~isfinite(t))
        error(message("MATLAB:smoothdata:needsFinites",term));
    end

    if isdatetime(t) && any(~isfinite(t))
        error(message("MATLAB:smoothdata:needsFinites",term));
    end

    if length(t) ~= N
        error(message("MATLAB:smoothdata:SamplePointsLength"));
    end

    if isfloat(t)
        if ~isreal(t)
            error(message("MATLAB:smoothdata:noComplex", '''SamplePoints'''));
        end
        if issparse(t)
            error(message("MATLAB:smoothdata:noSparseSamplePoints"));
        end
    end
    if any(diff(t) <= 0)
        if any(diff(t) == 0)
            error(message("MATLAB:smoothdata:SamplePointsDuplicate", term));
        else
            error(message("MATLAB:smoothdata:SamplePointsSorted", term));
        end
    end
end

%--------------------------------------------------------------------------
function smFactor = checkSmoothingFactor(smFactor)
% Check the tuning factor input

    if isfloat(smFactor)
        if ~isreal(smFactor)
            error(message("MATLAB:smoothdata:noComplex", '''SmoothingFactor'''));
        end
        if issparse(smFactor)
            smFactor = full(smFactor);
        end
    end
    if ~isscalar(smFactor) || ~((isnumeric(smFactor) && ...
        (smFactor >= 0) && (smFactor <= 1)) || islogical(smFactor))
        error(message("MATLAB:smoothdata:invalidSmoothingFactor"));
    end

end

%--------------------------------------------------------------------------
function sgdeg = checkDegree(method, sgdeg, t, winsz, autoSize, gaveDegree)
% Check the Savitzky-Golay degree

    % Additional checks for Savitzky-Golay
    if method ~= 'sgolay'
        return;
    end
    if isempty(winsz)
        % Handle errors for empty cases
        winsz = 0;
    end

    if isfloat(sgdeg)
        if ~isreal(sgdeg)
            error(message("MATLAB:smoothdata:noComplex", '''Degree'''));
        end
        if ~isfinite(sgdeg)
            error(message("MATLAB:smoothdata:needsFinites", '''Degree'''));
        end
    end
    if ~isscalar(sgdeg) || ~isnumeric(sgdeg) || ...
        (fix(sgdeg) ~= sgdeg) || (sgdeg < 0)
        error(message("MATLAB:smoothdata:negativeDegree"));
    end
    sgdeg = full(double(sgdeg));

    % Non-uniform data or time-stamped data
    if ~isempty(t)
        wl = maxWindowLength(t, winsz);
        if (sgdeg >= wl)
            if autoSize
                % Cap the maximum degree, warn if degree was specified
                sgdeg = wl-1;
                if gaveDegree
                    warning(message('MATLAB:smoothdata:degreeAutoClash',...
                        wl, sgdeg));
                end
            else
                if gaveDegree
                    error(message("MATLAB:smoothdata:degreeTooLarge", wl));
                else
                    sgdeg = wl-1;
                end
            end
        end
    else
        % User specified window with [kb kf] syntax
        if numel(winsz) > 1
            winsz = sum(winsz) + 1;
        end
        if (sgdeg >= winsz)
            if autoSize
                % Cap the maximum degree, warn if degree was specified
                sgdeg = fix(winsz-1);
                if gaveDegree
                    warning(message("MATLAB:smoothdata:degreeAutoClash",...
                       winsz, sgdeg));
                end
            else
                if gaveDegree
                    error(message("MATLAB:smoothdata:degreeTooLarge",...
                        winsz));
                else
                    sgdeg = fix(winsz-1);
                end
            end
        end
    end
end

%--------------------------------------------------------------------------
function wl = maxWindowLength(t, winsz)
% Compute the maximum window length of non-uniform data

    if numel(winsz) > 1
        leftComp = @(i,j) t(i) < (t(j) - winsz(1));
        rightComp =  @(i,j) t(i) <= (t(j) + winsz(2));
    else
        leftComp = @(i,j) t(i) < (t(j) - winsz/2);
        rightComp =  @(i,j) t(i) < (t(j) + winsz/2);
    end

    first = 1;
    last = 1;
    n = length(t);
    wl = 0;

    % Update the boundaries of each window shift and compute the number of
    % points in the window
    for i = 1:n
        while leftComp(first, i)
            first = first + 1;
        end
        while (last < n) && rightComp(last+1, i)
            last = last + 1;
        end
        wl = max(wl, last - first + 1);
    end
end

%--------------------------------------------------------------------------
function tf = isuniform(t)
% Determine if sample points are uniformly spaced

    if numel(t) == 1
        tf = false;
    else
        dt = diff(t);
        tf = (max(dt) == min(dt));
    end

end

%--------------------------------------------------------------------------
function winsz = tuneWindowSize(A, dim, t, tau, dvars)
% Determine a winsz based on the tuning factor
% TAU is actually 1 - tuning factor, since it indicates how much energy
% must be preserved

    if ~isempty(t) && isuniform(t)
        % Tune on uniform nodes, scale the window size
        winsz = tuneWindowSize(A, dim, [], tau, dvars);
        winsz = winsz * (t(2) - t(1));
        return;
    end

    if (dim <= ndims(A)) && (size(A,dim) > 1)
        if ~isempty(t)
            if tau == 0
                winsz = (t(end) - t(1));
                return;
            elseif tau == 1
                winsz = min(diff(t))/2;
                return;
            end

            % Convert the whole table to double for FFT
            if isa(A, 'tabular')
                A = varfun(@double, A, 'InputVariables', dvars);
                A = full(A{:, 1:width(A)});
            end
            
            % Interpolate onto a uniform grid
            Ai = A;
            if dim ~= 1
                Ai = permute(Ai, [dim, 1:(dim-1), (dim+1):ndims(A)]);
            end
            if isinteger(t)
                scaleFactor = getIntegerScaleFactor(t);
                if max(t) > flintmax
                    t = rescaleIntegerData(t, true);
                else
                    t = double(t);
                end
            else
                scaleFactor = (t(end) - t(1))/(length(t)-1);
            end
            tgrid = linspace(t(1), t(end), length(t))';
            
            % Have to convert integer data to double
            if isinteger(Ai)
                if (max(Ai(:)) > flintmax)
                    Ai = rescaleIntegerData(Ai, false);
                else
                    Ai = double(Ai);
                end
            end
            Ai = fillmissing(Ai, 'pchip', 'SamplePoints', t, ...
                'EndValues', 'extrap');
            Ai = interp1(t, Ai, tgrid, 'pchip');
            
            % Use uniform tuning and scale
            winsz = tuneWindowSize(Ai, 1, [], tau);
            winsz = winsz * scaleFactor;
            return;
        else
            if tau == 0
                winsz = size(A, dim);
                return;
            elseif tau == 1
                winsz = 1;
                return;
            end

            % Convert the whole table to double for FFT
            if isa(A, 'tabular')
                A = varfun(@double, A, 'InputVariables', dvars);
                A = full(A{:, 1:width(A)});
            end

            % Get an estimate of the average cutoff frequency below which
            % most of the input's energy is contained
            if ~isfloat(A)
                Ac = double(A);
                if dim ~= 1
                    Ac = permute(Ac, [dim, 1:(dim-1), (dim+1):ndims(A)]);
                end
            else
                Ac = A;
                if dim ~= 1
                    Ac = permute(A, [dim, 1:(dim-1), (dim+1):ndims(A)]);
                end
                Ac = fillmissing(Ac, 'pchip');
            end

            % Re-center the values
            Ac = Ac - mean(Ac);
            N = size(Ac, 1);
            Ac = abs(fft(Ac, 2*N)).^2 / (2*N);
            if ~isreal(A)
                % Average the negative and positive frequencies for complex
                Ac(2:end,:) = 0.5*(Ac(2:end, :) + flipud(Ac(2:end,:)));
            end
            Ac = Ac(1:N,:);

            % Compute normalized cumulative sum, average it over columns
            Ac = Ac ./ sum(Ac);
            Ac = cumsum(Ac, 'omitnan');
            Ac = mean(Ac(:, :), 2);

            % Determine cutoff bandwidth
            rho = find(Ac > tau, 1, 'first');
            % Columns are constant -- nothing to do
            if isempty(rho)
                winsz = 1;
            else
                % Convert to moving average filter width
                winsz = ceil(sqrt((0.44294*2*N/max(rho-1,1))^2+1));
            end
        end
    else
        if ~isempty(t)
            if isa(t, 'datetime')
                winsz = milliseconds(1);
            elseif isinteger(t)
                winsz = cast(1, 'like', t);
            else
                winsz = eps(t(1));
            end
        else
            winsz = 1;
        end
    end
    
end

%--------------------------------------------------------------------------
function tf = partialMatch(strChoices, strInput, minLength)
% Case-insensitive partial matching for option strings
    if ~isstring(strInput)
        strInput = string(strInput);
    end
    if nargin < 3
        minLength = 1;
    end
    if strlength(strInput) < minLength
        tf = false(size(strChoices));
    else
        tf = startsWith(strChoices, strInput, 'IgnoreCase', true);
    end
end

%--------------------------------------------------------------------------
function y = convertToFloat(x)
% Convert non-float inputs to double
    if ~isfloat(x)
        y = double(x);
    else
        y = x;
    end
end

%--------------------------------------------------------------------------
function td = rescaleIntegerData(t, mustBeSorted)
% Rescale int64/uint64 sample points

    if isa(t, 'int64')
        % Convert the int64 to be positive and cast to uint64
        minVal = uint64(0);
        if min(t) < 0
            minVal = cast(-min(t), 'uint64');
        end
        idx = t > 0;
        td = zeros(size(t), 'uint64');
        td(idx) = cast(t(idx), 'uint64') + minVal;
        td(~idx) = minVal - cast(-t(~idx), 'uint64');
        t = td;
    end

    td = t - min(t);
    if max(td) > flintmax
        % Approximate sample points if we can't get things aligned
        % exactly
        td = (double(td) / double(max(td)));
        if mustBeSorted
            for i = 2:length(td)
                if (td(i) <= td(i-1))
                    td(i) = td(i-1) + eps(td(i-1));
                end
            end
        end
    else
        td = double(td);
    end

end

%--------------------------------------------------------------------------
function sf = getIntegerScaleFactor(t)
% Return the scaling factor for the window size used for auto-tuned selection
    N = length(t) - 1;
    if (t(1) < 0) && (t(end) < 0)
        % May lose 1 in the cast if t(1) == intmin('int64'), so determine
        % if it needs to be added back in
        padBit = t(1) == intmin('int64');
        sf = cast((padBit + uint64(-t(1)) - uint64(-t(end))) / N, 'like', t);
    elseif (t(1) > 0) && (t(end) > 0)
        % Whole vector is positive, so cast to uint64 to compute the
        % difference
        sf = cast((uint64(t(end)) - uint64(t(1))) / N, 'like', t);
    else % t(1) < 0, t(end) > 0
        % May lose 1 in the cast if t(1) == intmin('int64')
        padBit = t(1) == intmin('int64');
        sf = cast((uint64(t(end)) + padBit + uint64(-t(1))) / N, 'like', t);
    end
end

%--------------------------------------------------------------------------
function tf = validDataVariableType(x)
% Indicates valid data types for table variables
    tf = (isnumeric(x) || islogical(x)) && ~(isinteger(x) && ~isreal(x));
end