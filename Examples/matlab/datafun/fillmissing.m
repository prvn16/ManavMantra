function [B,FA] = fillmissing(A,fillMethod,varargin)
%FILLMISSING   Fill missing entries
%   First argument must be numeric, datetime, duration, calendarDuration,
%   string, categorical, character array, cell array of character vectors,
%   a table, or a timetable.
%   Standard missing data is defined as:
%      NaN                   - for double and single floating-point arrays
%      NaN                   - for duration and calendarDuration arrays
%      NaT                   - for datetime arrays
%      <missing>             - for string arrays
%      <undefined>           - for categorical arrays
%      blank character [' '] - for character arrays
%      empty character {''}  - for cell arrays of character vectors
%
%   B = FILLMISSING(A,'constant',C) fills missing entries in A with the
%   constant scalar value C. You can also use a vector C to specify
%   different fill constants for each column (or table variable) in A: C(i)
%   represents the fill constant used for the i-th column of A. For tables
%   A, C can also be a cell containing fill constants of different types.
%
%   B = FILLMISSING(A,INTERP) fills standard missing entries using the
%   interpolation method specified by INTERP, which must be:
%      'previous'  - Previous non-missing entry.
%      'next'      - Next non-missing entry.
%      'nearest'   - Nearest non-missing entry.
%      'linear'    - Linear interpolation of non-missing entries.
%      'spline'    - Piecewise cubic spline interpolation.
%      'pchip'     - Shape-preserving piecewise cubic spline interpolation.
%
%   B = FILLMISSING(A,MOV,K) fills standard missing entries using a
%   centered moving window formed from neighboring non-missing entries.
%   K specifies the window length and must be a positive integer scalar.
%   MOV specifies the moving window method, which must be:
%      'movmean'   - Moving average of neighboring non-missing entries.
%      'movmedian' - Moving median of neighboring non-missing entries.
%   
%   B = FILLMISSING(A,MOV,[NB NF]) uses a moving window defined by the
%   previous NB elements, the current element, and the next NF elements.
%
%   Optional arguments:
%
%   B = FILLMISSING(A,METHOD,...,'EndValues',E) also specifies how to
%   extrapolate leading and trailing missing values. E must be:
%      'extrap'    - (default) Use METHOD to also extrapolate missing data.
%      'previous'  - Previous non-missing entry.
%      'next'      - Next non-missing entry.
%      'nearest'   - Nearest non-missing entry.
%      'none'      - No extrapolation of missing values.
%      VALUE       - Use an extrapolation constant. VALUE must be a scalar
%                    or a vector of type numeric, duration, or datetime.
%
%   B = FILLMISSING(A,METHOD,...,'SamplePoints',X) also specifies the
%   sample points X used by the fill method. X must be a floating-point,
%   duration, or datetime vector. X must be sorted. X must contain unique
%   points. You can use X to specify time stamps for the data. By default,
%   FILLMISSING uses data sampled uniformly at points X = [1 2 3 ... ].
%
%   B = FILLMISSING(A,METHOD,DIM,...) also specifies a dimension DIM to
%   operate along. A must be an array.
%
%   [B,FA] = FILLMISSING(A,...) also returns a logical array FA indicating
%   the missing entries of A that were filled. FA has the same size as A.
%
%   Arguments supported only for table inputs:
%
%   B = FILLMISSING(A,...,'DataVariables',DV) fills missing data only in
%   the table variables specified by DV. The default is all table variables
%   in A. DV must be a table variable name, a cell array of table variable
%   names, a vector of table variable indices, a logical vector, or a
%   function handle that returns a logical scalar (such as @isnumeric).
%   Output table B has the same size as input table A.
%
%   Examples:
%
%     % Linear interpolation of NaN entries
%       a = [NaN 1 2 NaN 4 NaN]
%       b = fillmissing(a,'linear')
%
%     % Fill leading and trailing NaN entries with their nearest neighbors
%       a = [NaN 1 2 NaN 4 NaN]
%       b = fillmissing(a,'linear','EndValues','nearest')
%
%     % Fill NaN entries with their previous neighbors (zero-order-hold)
%       A = [1000 1 -10; NaN 1 NaN; NaN 1 NaN; -1 77 5; NaN(1,3)]
%       B = fillmissing(A,'previous')
%
%     % Fill NaN entries with the mean of each column
%       A = [NaN(1,3); 13 1 -20; NaN(4,1) (1:4)' NaN(4,1); -1 7 -10; NaN(1,3)]
%       C = mean(A,'omitnan');
%       B = fillmissing(A,'constant',C)
%
%     % Linear interpolation of NaN entries for non-uniformly spaced data
%       x = [linspace(-3,1,120) linspace(1.1,7,30)];
%       a = exp(-0.1*x).*sin(2*x); a(a > -0.2 & a < 0.2) = NaN;
%       [b,id] = fillmissing(a,'linear','SamplePoints',x);
%       plot(x,a,'.', x(id),b(id),'o')
%       title('''linear'' fill')
%       xlabel('Sample points x');
%       legend('original data','filled missing data')
%
%     % Fill missing entries in tables with their previous neighbors
%       temperature = [21.1 21.5 NaN 23.1 25.7 24.1 25.3 NaN 24.1 25.5]';
%       windSpeed = [12.9 13.3 12.1 13.5 10.9 NaN NaN 12.2 10.8 17.1]';
%       windDirection = categorical({'W' 'SW' 'SW' '' 'SW' 'S' ...
%                           'S' 'SW' 'SW' 'SW'})';
%       conditions = {'PTCLDY' '' '' 'PTCLDY' 'FAIR' 'CLEAR' ...
%                           'CLEAR' 'FAIR' 'PTCLDY' 'MOSUNNY'}';
%       T = table(temperature,windSpeed,windDirection,conditions)
%       U = fillmissing(T,'previous')
%
%   See also ISMISSING, STANDARDIZEMISSING, RMMISSING, ISNAN, ISNAT
%            FILLOUTLIERS, SMOOTHDATA

%   Copyright 2015-2017 The MathWorks, Inc.

[A,AisTable,intM,intConstOrWinSize,extM,x,dim,dataVars] = parseInputs(A,fillMethod,varargin{:});

if ~AisTable
    [intConstOrWinSize,extM] = checkArrayType(A,intM,intConstOrWinSize,extM,x,false);
    if nargout < 2
        B = fillArray(A,intM,intConstOrWinSize,extM,x,dim,false);
    else
        [B,FA] = fillArray(A,intM,intConstOrWinSize,extM,x,dim,false);
    end
else
    if nargout < 2
        B = fillTable(A,intM,intConstOrWinSize,extM,x,dataVars);
    else
        [B,FA] = fillTable(A,intM,intConstOrWinSize,extM,x,dataVars);
    end
end
%--------------------------------------------------------------------------
function [B,FA] = fillTable(A,intMethod,intConst,extMethod,x,dataVars)
% Fill table according to DataVariables
B = A;
if nargout > 1
    FA = false(size(A));
end
useJthFillConstant = strcmp(intMethod,'constant') && ~isscalar(intConst) && ~ischar(intConst);
useJthExtrapConstant = ~ischar(extMethod) && ~isscalar(extMethod);
indVj = 1;
for vj = dataVars
    if nargout < 2
        B.(vj) = fillTableVar(indVj,A.(vj),intMethod,intConst,extMethod,x,useJthFillConstant,useJthExtrapConstant);
    else
        [B.(vj),FA(:,vj)] = fillTableVar(indVj,A.(vj),intMethod,intConst,extMethod,x,useJthFillConstant,useJthExtrapConstant);
    end
    indVj = indVj+1;
end
end % fillTable
%--------------------------------------------------------------------------
function [Bvj,FAvj] = fillTableVar(indVj,Avj,intMethod,intConst,extMethod,x,useJthFillConstant,useJthExtrapConstant)
% Fill each table variable
intConstVj = intConst;
extMethodVj = extMethod;
if useJthFillConstant
    intConstVj = intConst(indVj);
end
if iscell(intConstVj)
    intConstVj = checkConstantsSize(Avj,false,true,intConstVj{1},1,[],'');
end
if useJthExtrapConstant
    extMethodVj = extMethod(indVj);
end
% Validate types of array and fill constants
[intConstVj,extMethodVj] = checkArrayType(Avj,intMethod,intConstVj,extMethodVj,x,true);
% Treat row in a char table variable as a string
AisCharTableVar = ischar(Avj);
if AisCharTableVar
    AvjCharInit = Avj;
    Avj = matlab.internal.math.charRows2string(Avj);
    if strcmp(intMethod,'constant')
        intConstVj = matlab.internal.math.charRows2string(intConstVj);
    end
end
% Fill
if nargout < 2
    Bvj = fillArray(Avj,intMethod,intConstVj,extMethodVj,x,1,true);
else
    [Bvj,FAvj] = fillArray(Avj,intMethod,intConstVj,extMethodVj,x,1,true);
end
% Convert back to char table variable
if AisCharTableVar
    if all(ismissing(Avj(:)))
        % For completely blank char table variables, force B to equal A
        Bvj = AvjCharInit;
    else
        Bvj = matlab.internal.math.string2charRows(Bvj);
    end
end
end % fillTableVar
%--------------------------------------------------------------------------
function [B,FA] = fillArray(A,intMethod,intConstOrWinSize,extMethod,x,dim,AisTableVar)
% Perform FILLMISSING of standard missing entries in an array A
B = A;
FA = ismissing(A);
sizeBin = size(B);
ndimsBin = ndims(B);
% Generate default X once
useDefaultX = isempty(x);
if useDefaultX
    x = (1:size(A,dim)).';
end
% Quick return
if ~AisTableVar && dim > ndimsBin
    if isnumeric(B) && ~isreal(B)
        B(true(size(B))) = B;
    end
    B = extrapolateWithConstant(B,intMethod,intConstOrWinSize,extMethod,FA,FA);
    return
end
% Permute and reshape into a matrix
perm = [dim, 1:(dim-1), (dim+1):ndimsBin];
sizeBperm = sizeBin(perm);
ncolsB = prod(sizeBperm(2:end));
nrowsB = sizeBperm(1);
B = reshape(permute(B, perm),[nrowsB, ncolsB]);
FA = reshape(permute(FA, perm),[nrowsB, ncolsB]);
% Fill each column
for jj = 1:ncolsB
    B(:,jj) = fillArrayColumn(jj,B(:,jj),FA(:,jj),intMethod,intConstOrWinSize,extMethod,x,useDefaultX);
end
% Reshape and permute back to original size
if AisTableVar && nargout > 1
    FA = xor(any(FA,2),any(ismissing(B),2));
end
B = ipermute(reshape(B,sizeBperm), perm);
if ~AisTableVar && nargout > 1
    FA = ipermute(reshape(FA,sizeBperm), perm);
    FA(FA) = xor(FA(FA),ismissing(B(FA)));
end
end % fillArray
%--------------------------------------------------------------------------
function b = fillArrayColumn(jj,a,ma,intMethod,intConstOrWinSize,extMethod,x,useDefaultX)
% Fill one column. Do not error if we cannot fill all missing entries.
% jj = j-th column numeric index. Used to select the j-th fill constant.
% a  = the j-th column itself. Can be numeric, logical, duration, datetime,
%      calendarDuration, char, string, cellstr, or categorical.
% ma = logical mask of missing entries found in a.
% intMethod = interpolation method.
% intConstOrWinSize = interpolation constant for 'constant' or window size
%      for 'movmean'. [] if intMethod is not 'constant'/'mov*'.
% extMethod = extrap method. If not a char, it holds the extrap constant.
% x = the abscissa ('SamplePoints'). Can be float, duration, or datetime.
b = a;
% Quick return
if isinteger(b) || islogical(b)
    return
end
nma = find(~ma);
numNonMissing = numel(nma);
if numNonMissing == 0
    % Columns full of missing data can only be filled with a constant.
    b = extrapolateWithConstant(b,intMethod,intConstOrWinSize,extMethod,ma,jj);
    return
end
% (1) Interpolate
if issparse(b)
    b = full(b);
end
if strcmp(intMethod,'constant')
    b = assignConstant(b,intConstOrWinSize,ma,jj);
elseif strcmp(intMethod,'movmean')
    if useDefaultX
        newb = movmean(b,intConstOrWinSize,'omitnan');
    else
        newb = movmean(b,intConstOrWinSize,'omitnan','SamplePoints',x);
    end
    b(ma) = newb(ma);
elseif strcmp(intMethod,'movmedian')
    if useDefaultX
        newb = movmedian(b,intConstOrWinSize,'omitnan');
    else
        newb = movmedian(b,intConstOrWinSize,'omitnan','SamplePoints',x);
    end
    b(ma) = newb(ma);
else
    % griddedInterpolant/interp1 require at least 2 grid points.
    % Do not error if we cannot fill. Instead, return the original array.
    % For example, fillmissing([NaN 1 NaN],'linear') returns [NaN 1 NaN].
    if numNonMissing > 1
        isfloatb = isfloat(b);
        if isfloatb && isfloat(x)
            G = griddedInterpolant(x(nma),b(nma),intMethod);
            b(ma) = G(x(ma)); % faster than interp1
        elseif isfloatb || isduration(b) || isdatetime(b)
            b(ma) = interp1(x(nma),b(nma),x(ma),intMethod,'extrap');
        else
            % calendarDuration, char, string, cellstr, or categorical:
            % No griddedInterpolant because x may be datetime/duration
            vq = interp1(x(nma),nma,x(ma),intMethod,'extrap');
            indvq = ~isnan(vq); % vq may have leading or trailing NaN
            iatmp = find(ma);
            b(iatmp(indvq)) = b(vq(indvq)); % copy non-missing to missing
        end
    end
end
% (2) Correct for EndValues
indBeg = nma(1); % numNonMissing > 0
indEnd = nma(end);
if ischar(extMethod) || (isstring(extMethod) && isscalar(extMethod))
    if strcmp(extMethod,'none')
        b(1:indBeg-1)   = a(1:indBeg-1);
        b(indEnd+1:end) = a(indEnd+1:end);
    elseif strcmp(extMethod,'nearest') || (strcmp(extMethod,'extrap') && strcmp(intMethod,'nearest'))
        b(1:indBeg-1)   = a(indBeg);
        b(indEnd+1:end) = a(indEnd);
    elseif strcmp(extMethod,'previous') || (strcmp(extMethod,'extrap') && strcmp(intMethod,'previous'))
        b(1:indBeg-1)   = a(1:indBeg-1);
        b(indEnd+1:end) = a(indEnd);
    elseif strcmp(extMethod,'next')  || (strcmp(extMethod,'extrap') && strcmp(intMethod,'next'))
        b(1:indBeg-1)   = a(indBeg);
        b(indEnd+1:end) = a(indEnd+1:end);
    end
else
    if isscalar(extMethod)
        b([1:indBeg-1, indEnd+1:end]) = extMethod;
    else
        b([1:indBeg-1, indEnd+1:end]) = extMethod(jj);
    end
end
end % fillArrayColumn
%--------------------------------------------------------------------------
function B = extrapolateWithConstant(B,intMethod,intConst,extMethod,lhsIndex,rhsIndex)
% Fill all missings with a constant. Used if B is full of missing data, or
% for array B with dim > ndims(B). rhsIndex may be logical or numeric.
% Fill only when we have specified an extrapolation constant:
if ~ischar(extMethod) && ~(isstring(extMethod) && isscalar(extMethod))
    % Either through EndValues:
    % fillmissing(A,METHOD,'EndValues',ConstVals)
    B = assignConstant(B,extMethod,lhsIndex,rhsIndex);
elseif strcmp(intMethod,'constant') && strcmp(extMethod,'extrap')
    % Or through the 'constant' fill method:
    % fillmissing(A,'constant',ConstVals)
    % fillmissing(A,'constant',ConstVals,'EndValues','extrap')
    B = assignConstant(B,intConst,lhsIndex,rhsIndex);
end
end % extrapolateWithConstant
%--------------------------------------------------------------------------
function B = assignConstant(B,ConstVals,lhsIndex,rhsIndex)
if isscalar(ConstVals)
    B(lhsIndex) = ConstVals;
else
    B(lhsIndex) = ConstVals(rhsIndex);
end
end
%--------------------------------------------------------------------------
function [A,AisTable,intMethod,intConstOrWindowSize,extMethod,x,dim,dataVars] = ...
        parseInputs(A,fillMethod,varargin)
% Parse FILLMISSING inputs
AisTable = matlab.internal.datatypes.istabular(A);
if ~isSupportedArray(A) && ~AisTable
    error(message('MATLAB:fillmissing:FirstInputInvalid'));
end
% Parse fill method. Empty '' or [] fill method is not allowed.
validIntMethods = {'constant','previous','next','nearest','linear',...
                   'spline','pchip','movmean','movmedian'};
indIntMethod = matlab.internal.math.checkInputName(fillMethod,validIntMethods);
if sum(indIntMethod) ~= 1
    % Also catch ambiguities for fillmissing(A,'ne') and fillmissing(A,'p')
    error(message('MATLAB:fillmissing:MethodInvalid'));
end
intMethod = validIntMethods{indIntMethod};
indIntMethod = find(indIntMethod);
intConstOrWindowSize = [];
% Parse fillmissing(A,'constant',c) and fillmissing(A,MOVFUN,windowSize)
intConstOffset = 0;
if any(indIntMethod == [1 8 9])
    if nargin > 2
        intConstOrWindowSize = varargin{1};
    else
        error(message(['MATLAB:fillmissing:',intMethod,'Input']));
    end
    intConstOffset = 1;
end
% Parse optional inputs
extMethod = 'extrap';
x = [];
if ~AisTable
    dim = find(size(A) ~= 1,1); % default to first non-singleton dimension
    if isempty(dim)
        dim = 2; % dim = 2 for scalar and empty A
    end
    dataVars = []; % not supported for arrays
else
    dim = 1; % Fill each table variable separately
    dataVars = 1:width(A);
end
if nargin > 2+intConstOffset
    % Third input can be a constant, a window size, the dimension, or an
    % argument Name from a Name-Value pair:
    %   fillmissing(A,'constant',C,...) and C may be a char itself
    %   fillmissing(A,'movmean',K,...) with K numeric, numel(K) == 1 or 2
    %   fillmissing(A,'linear',DIM,...)
    %   fillmissing(A,'linear','EndValues',...)
    firstOptionalInput = varargin{1+intConstOffset};
    % The dimension
    dimOffset = 0;
    if isnumeric(firstOptionalInput) || islogical(firstOptionalInput)
        if AisTable
            error(message('MATLAB:fillmissing:DimensionTable'));
        end
        dimOffset = 1;
        dim = firstOptionalInput;
        if ~isscalar(dim) || ~isreal(dim) || fix(dim) ~= dim || dim < 1 || ~isfinite(dim)
            error(message('MATLAB:fillmissing:DimensionInvalid'));
        end
    end
    % Trailing N-V pairs
    indNV = (1+intConstOffset+dimOffset):numel(varargin);
    if rem(length(indNV),2) ~= 0
        error(message('MATLAB:fillmissing:NameValuePairs'));
    end
    for i = indNV(1:2:end)
        if matlab.internal.math.checkInputName(varargin{i},'EndValues')
            extMethod = varargin{i+1};
            if ischar(extMethod) || (isstring(extMethod) && isscalar(extMethod))
                validExtMethods = {'extrap','previous','next','nearest','none'};
                indExtMethod = matlab.internal.math.checkInputName(extMethod,validExtMethods);
                if sum(indExtMethod) ~= 1 
                    % Also catch ambiguities between nearest and next
                    error(message('MATLAB:fillmissing:EndValuesInvalidMethod'));
                end
                extMethod = validExtMethods{indExtMethod};
            end
        elseif matlab.internal.math.checkInputName(varargin{i},'SamplePoints')
            if isa(A,'timetable')
                error(message('MATLAB:fillmissing:SamplePointsTimeTable'));
            end
            x = matlab.internal.math.checkSamplePoints(varargin{i+1},A,false,dim,'fillmissing');
        elseif matlab.internal.math.checkInputName(varargin{i},'DataVariables')
            if AisTable
                dataVars = matlab.internal.math.checkDataVariables(A,varargin{i+1},'fillmissing');
            else
                error(message('MATLAB:fillmissing:DataVariablesArray'));
            end
        else
            error(message('MATLAB:fillmissing:NameValueNames'));
        end
    end
end
% Validate fill constants size
if indIntMethod == 1 % 'constant' fill method
    intConstOrWindowSize = checkConstantsSize(A,AisTable,false,intConstOrWindowSize,dim,dataVars,'');
end
if ~ischar(extMethod) && ~(isstring(extMethod) && isscalar(extMethod))
    extMethod = checkConstantsSize(A,AisTable,false,extMethod,dim,dataVars,'Extrap');
end
% Default abscissa
if isempty(x) && isa(A,'timetable')
    x = matlab.internal.math.checkSamplePoints(A.Properties.RowTimes,A,true,dim,'fillmissing');
end
end % parseInputs
%--------------------------------------------------------------------------
function tf = isSupportedArray(A)
% Check if array type is supported
tf = isnumeric(A) || islogical(A) || ...
     isstring(A) || iscategorical(A) || iscellstr(A) || ischar(A) || ...
     isdatetime(A) || isduration(A) || iscalendarduration(A);
end % isSupportedArray
%--------------------------------------------------------------------------
function C = checkConstantsSize(A,AisTable,AisTableVar,C,dim,dataVars,eid)
% Validate the size of the fill constant. We can fill all columns with the
% same scalar, or use a different scalar for each column.
if isempty(A) && ~isempty(C)
    error(message(['MATLAB:fillmissing:SizeConstantEmpty',eid]));
end
if ischar(C) && (~ischar(A) || AisTableVar)
    % A char fill constant is treated as a scalar for string, categorical
    % and cellstr (arrays or table variables), and char table variables
    if ~isrow(C) && ~isempty(C) % '' is not a row
        error(message('MATLAB:fillmissing:CharRowVector'));
    end
elseif ~isscalar(C)
    sizeA = size(A);
    if AisTable
        % numel(constant) must equal numel 'DataVariables' value
        sizeA(2) = length(dataVars);
    end
    if dim <= ndims(A)
        sizeA(dim) = [];
        nVects = prod(sizeA);
    else
        % fillmissing(A,'constant',c) supported
        % fillmissing(A,METHOD,'EndValues',constant_value) supported
        nVects = numel(A);
    end
    if (numel(C) ~= nVects)
        if nVects <= 1
            error(message(['MATLAB:fillmissing:SizeConstantScalar',eid]));
        else
            error(message(['MATLAB:fillmissing:SizeConstant',eid],nVects));
        end
    end
	C = C(:);
end
end % checkConstantsSize
%--------------------------------------------------------------------------
function [intConst,extMethod] = checkArrayType(A,intMethod,intConst,extMethod,x,AisTableVar)
% Check if array types match
if AisTableVar && ~isSupportedArray(A)
    error(message('MATLAB:fillmissing:UnsupportedTableVariable',class(A)));
end
if ~(isnumeric(A) || islogical(A) || isduration(A) || isdatetime(A)) && ...
        ~any(strcmp(intMethod,{'nearest','next','previous','constant'}))
    if AisTableVar
        error(message('MATLAB:fillmissing:InterpolationInvalidTableVariable',intMethod));
    else
        error(message('MATLAB:fillmissing:InterpolationInvalidArray',intMethod,class(A)));
    end
end
try
    if strcmp(intMethod,'constant')
        intConst = checkConstantType(A,intConst,'');
    end
    if ~ischar(extMethod) && ~(isstring(extMethod) && isscalar(extMethod))
        extMethod = checkConstantType(A,extMethod,'Extrap');
    end
catch ME
    if AisTableVar && matlab.internal.math.checkInputName('MATLAB:fillmissing:Constant',ME.identifier)
        % Generic error message for tables
        error(message('MATLAB:fillmissing:ConstantInvalidType'));
    else
        % Specific error message for arrays
        throw(ME);
    end
end
if isa(x,'single') && (isduration(A) || isdatetime(A))
    error(message('MATLAB:fillmissing:SamplePointsSingle'));
end
end % checkArrayType
%--------------------------------------------------------------------------
function C = checkConstantType(A,C,eid)
% Check if constant type matches the array type
if ~isempty(eid) && ~isnumeric(C) && ~islogical(C) && ...
        ~isdatetime(C) && ~isduration(C) && ~iscalendarduration(C)
    error(message('MATLAB:fillmissing:ConstantInvalidTypeExtrap'));
end
if isnumeric(A) && ~isnumeric(C) && ~islogical(C)
    error(message(['MATLAB:fillmissing:ConstantNumeric',eid]));
elseif isdatetime(A) && ~isdatetime(C)
    error(message(['MATLAB:fillmissing:ConstantDatetime',eid]));
elseif isduration(A) && ~isduration(C)
    error(message(['MATLAB:fillmissing:ConstantDuration',eid]));
elseif iscalendarduration(A) && ~iscalendarduration(C)
    error(message(['MATLAB:fillmissing:ConstantCalendarDuration',eid]));
elseif iscategorical(A)
    if ischar(C)
        C = string(C); % make char a scalar string
    elseif (~iscellstr(C) && ~isstring(C))
        % categorical fill constants not supported
        error(message(['MATLAB:fillmissing:ConstantCategorical',eid]));
    end
elseif ischar(A) && ~ischar(C)
    error(message(['MATLAB:fillmissing:ConstantChar',eid]));
elseif iscellstr(A)
    if ischar(C)
        C = {C}; % make char a scalar cellstr
    elseif ~iscellstr(C)
        % string constants not supported
        error(message(['MATLAB:fillmissing:ConstantCellstr',eid]));
    end
elseif isstring(A) && ~isstring(C)
    % char and cellstr constants not supported
    error(message(['MATLAB:fillmissing:ConstantString',eid]));
end
end % checkConstantType
end % fillmissing