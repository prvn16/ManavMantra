function [value, validvalue, errmsg, errid, validfield] = optimoptioncheckfield(field,value)
%OPTIMOPTIONCHECKFIELD Check validity of structure field contents.
%
% This is a helper function for OPTIMSET and OPTIMGET.

%   [VALIDVALUE, ERRMSG, ERRID, VALIDFIELD] = OPTIMOPTIONCHECKFIELD('field',V)
%   checks the contents of the specified value V to be valid for the field 'field'.

%   Copyright 1990-2017 The MathWorks, Inc.

if isstring(field)
    field = char(field);
end

if isstring(value)
    value = char(value);
end

% empty matrix is always valid
if isempty(value)
    validvalue = true;
    errmsg = '';
    errid = '';
    validfield = true;
    return
end

% Some fields are checked in optimset/checkfield: Display, MaxFunEvals, MaxIter,
% OutputFcn, TolFun, TolX. Some are checked in both (e.g., MaxFunEvals).
validfield = true;
switch field
    case {'TolCon','TolPCG','ActiveConstrTol',...
            'DiffMaxChange','DiffMinChange','MaxTime', ...
            'RelLineSrchBnd','TolProjCGAbs', ...
            'TolProjCG','TolGradCon','TolConSQP'}
        % non-negative real scalar
        [validvalue, errmsg, errid] = nonNegReal(field,value);
    case {'TolFunLP'}
        % real scalar in the range [1.0e-10, 1.0e-1]
        [validvalue, errmsg, errid] = boundedReal(field,value,[1e-10, 1e-1]);
    case {'ObjectiveLimit'}
        [validvalue, errmsg, errid] = realLessThanPlusInf(field,value);
    case {'MaxFunEvals'}
        [validvalue, errmsg, errid] = nonNegInteger(field,value,{'100*numberofvariables'}); % fmincon
    case {'LargeScale','DerivativeCheck','Diagnostics','GradConstr','GradObj',...
            'Jacobian','NoStopIfFlatInfeas','PhaseOneTotalScaling'}
        % off, on
        [validvalue, errmsg, errid] = stringsType(field,value,{'on';'off'});
    case {'PrecondBandWidth','MinAbsMax','GoalsExactAchieve','RelLineSrchBndDuration'}
        % integer including inf
        [validvalue, errmsg, errid] = nonNegInteger(field,value);
    case {'MaxPCGIter'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,{'max(1,floor(numberofvariables/2))','numberofvariables'});
    case {'MaxProjCGIter'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'2*(numberofvariables-numberofequalities)');
    case {'MaxSQPIter'}
        % integer including inf or default
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'10*max(numberofvariables,numberofinequalities+numberofbounds)');
    case {'JacobPattern'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'sparse(ones(jrows,jcols))');
    case {'HessPattern'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'sparse(ones(numberofvariables))');
    case {'TypicalX'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'ones(numberofvariables,1)');
        % If an array is given, check for zero values and warn
        if validvalue && isa(value,'double') && any(value(:) == 0)
            error('MATLAB:optimoptioncheckfield:zeroInTypicalX',...
                getString(message('MATLAB:optimfun:optimoptioncheckfield:zeroInTypicalX')));
        end
    case {'HessMult','JacobMult','Preconditioner','HessFcn'}
        % function
        [validvalue, errmsg, errid] = functionType(field,value);
    case {'HessUpdate'}
        % dfp, bfgs, steepdesc
        [validvalue, errmsg, errid] = stringsType(field,value,{'dfp' ; 'steepdesc';'bfgs'});
    case {'MeritFunction'}
        % singleobj, multiobj
        [validvalue, errmsg, errid] = stringsType(field,value,{'singleobj'; 'multiobj' });
    case {'UseParallel'}
        % Logical scalar or specific strings
        [value,validvalue] = validateopts_UseParallel(value,false,true);
        if ~validvalue
          errid = 'MATLAB:optimoptioncheckfield:NotLogicalScalar';
          errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:NotLogicalScalar', field));
        else
          errid = '';
          errmsg = '';
        end
    case {'Algorithm'}
        % active-set, trust-region-reflective, interior-point, interior-point-convex,
        % levenberg-marquardt, trust-region-dogleg, 'sqp', 'dual-simplex'
        % trust-region, 'quasi-newton'
        if ~iscell(value)
            optimsetAlgNames = {'active-set' ; 'trust-region-reflective';  ...
                'interior-point'; 'interior-point-convex'; 'interior-point-legacy'; ...
                'levenberg-marquardt'; 'trust-region-dogleg'; 'sqp'; ...
                'dual-simplex';'trust-region';'quasi-newton'};
            [validvalue, errmsg, errid] = stringsType(field,value,optimsetAlgNames);
            % Check if the algorithm value is supported by optimoptions.
            % Note that at this point, toolbox/shared is guaranteed to be
            % on the path as this is checked by optimset (which is the only
            % caller of this private function).
            if ~validvalue
                optimoptionsAlgNames = getOptimoptionsAlgNames;
                optimoptionsOnlyAlgs = setdiff(optimoptionsAlgNames, optimsetAlgNames);
                if any(strcmp(value, optimoptionsOnlyAlgs))
                    errid = 'MATLAB:optimoptioncheckfield:onlyOptimoptionsAlg';
                    errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:onlyOptimoptionsAlg', value, value));
                end
            end
        else
            % Must be {'levenberg-marquardt',positive real}
            [validvalue, errmsg, errid] = stringPosRealCellType(field,value, ...
                {'levenberg-marquardt'});
        end
    case {'AlwaysHonorConstraints'}
        % none, bounds
        [validvalue, errmsg, errid] = ...
            stringsType(field,value,{'none' ; 'bounds'});
    case {'ScaleProblem'}
        % none, obj-and-constr, jacobian
        [validvalue, errmsg, errid] = ...
            stringsType(field,value,{'none' ; 'obj-and-constr' ; 'jacobian'});
    case {'FinDiffType'}
        % forward, central
        [validvalue, errmsg, errid] = stringsType(field,value,{'forward' ; 'central'});
    case 'FinDiffRelStep'
        % strictly positive vector or scalar
        [validvalue, errmsg, errid] = posMatrixType(field,value(:));
    case {'Hessian'}
        if ~iscell(value)
            % If character string, has to be user-supplied, bfgs, lbfgs,
            % fin-diff-grads, on, off
            [validvalue, errmsg, errid] = ...
                stringsType(field,value,{'user-supplied' ; 'bfgs'; 'lbfgs'; 'fin-diff-grads'; ...
                'on' ; 'off'});
        else
            % If cell-array, has to be {'lbfgs',positive integer}
            [validvalue, errmsg, errid] = stringPosIntegerCellType(field,value,'lbfgs');
        end
    case {'SubproblemAlgorithm'}
        if ~iscell(value)
            % If character string, has to be 'ldl-factorization' or 'cg',
            [validvalue, errmsg, errid] = ...
                stringsType(field,value,{'ldl-factorization' ; 'cg'});
        else
                % Either {'ldl-factorization',positive integer} or {'cg',positive integer}
                [validvalue, errmsg, errid] = stringPosRealCellType(field,value,{'ldl-factorization' ; 'cg'});
        end
    case {'MaxNodes'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'1000*numberofvariables');
    case {'InitTrustRegionRadius'}
        % sqrt(numberOfVariables), positive real
        [validvalue, errmsg, errid] = posReal(field,value,'sqrt(numberofvariables)');
    case {'InitBarrierParam'}
        % positive real
        [validvalue, errmsg, errid] = posReal(field,value);
    otherwise
        validfield = false;
        validvalue = false;
        % No need to set an error. If the field isn't valid for MATLAB or Optim,
        % will have already errored in optimset. If field is valid for MATLAB,        % then the error will be an invalid value for MATLAB.
        errid = '';
        errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegReal(field,value,string)
% Any nonnegative real scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) ;
if nargin > 2
    valid = valid || isequal(value,string);
end
if ~valid
    if ischar(value)
        errid = 'MATLAB:optimoptioncheckfield:nonNegRealStringType';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:nonNegRealStringType', field));
    else
        errid = 'MATLAB:optimoptioncheckfield:notAnonNegReal';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAnonNegReal', field));
    end
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegInteger(field,value,strings)
% Any nonnegative real integer scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) && value == floor(value) ;
if nargin > 2
    valid = valid || any(strcmp(value,strings));
end
if ~valid
    if ischar(value)
        errid = 'MATLAB:optimoptioncheckfield:nonNegIntegerStringType';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:nonNegIntegerStringType', field));
    else
        errid = 'MATLAB:optimoptioncheckfield:notANonNegInteger';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notANonNegInteger', field));
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = matrixType(field,value,strings)
% Any matrix
valid =  isa(value,'double');
if nargin > 2
    valid = valid || any(strcmp(value,strings));
end
if ~valid
    if ischar(value)
        errid = 'MATLAB:optimoptioncheckfield:matrixTypeStringType';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:matrixTypeStringType', field));
    else
        errid = 'MATLAB:optimoptioncheckfield:notAMatrix';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAMatrix', field));
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = posMatrixType(field,value)
% Any positive scalar or all positive vector
valid =  isa(value,'double') && all(value > 0) && isvector(value);
if ~valid
    errid = 'MATLAB:optimoptioncheckfield:notAPosMatrix';
    errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAPosMatrix', field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = functionType(field,value)
% Any function handle or string (we do not test if the string is a function name)
valid =  ischar(value) || isa(value, 'function_handle');
if ~valid
    errid = 'MATLAB:optimoptioncheckfield:notAFunction';
    errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAFunction', field));
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringsType(field,value,strings)
% One of the strings in cell array strings
valid =  ischar(value) && any(strcmp(value,strings));

if ~valid
    % Format strings for error message
    allstrings = formatCellArrayOfStrings(strings);

    errid = 'MATLAB:optimoptioncheckfield:notAStringsType';
    errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAStringsType', field, allstrings));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = boundedReal(field,value,bounds)
% Scalar in the bounds
valid =  isa(value,'double') && isscalar(value) && ...
    (value >= bounds(1)) && (value <= bounds(2));
if ~valid
    errid = 'MATLAB:optimoptioncheckfield:notAboundedReal';
    errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAboundedReal', field, sprintf('[%6.3g, %6.3g]', bounds(1), bounds(2))));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringPosIntegerCellType(field,value,strings)
% A cell array that is either {strings,positive integer} or {strings}
valid = numel(value) == 1 && strcmp(value{1},'lbfgs') || numel(value) == 2 && ...
    strcmp(value{1},'lbfgs') && isreal(value{2}) && isscalar(value{2}) && value{2} > 0 && value{2} == floor(value{2});

if ~valid
    errid = 'MATLAB:optimoptioncheckfield::notAStringPosIntegerCellType';
    errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield::notAStringPosIntegerCellType', field, strings));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringPosRealCellType(field,value,strings)
% A cell array that is either {strings,positive real} or {strings}
valid = (numel(value) >= 1) && any(strcmpi(value{1},strings));
if (numel(value) == 2)
   valid = valid && isreal(value{2}) && (value{2} >= 0);
end

if ~valid
    % Format strings for error message
    allstrings = formatCellArrayOfStrings(strings);

    errid = 'MATLAB:optimoptioncheckfield:notAStringPosRealCellType';
    errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAStringPosRealCellType', field,allstrings));
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = posReal(field,value,string)
% Any positive real scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value > 0) ;
if nargin > 2
   valid = valid || strcmpi(value,string);
end
if ~valid
    if ischar(value)
        errid = 'MATLAB:optimoptioncheckfield:posRealStringType';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:posRealStringType', field));
    else
        errid = 'MATLAB:optimoptioncheckfield:nonPositiveNum';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:nonPositiveNum', field));
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = realLessThanPlusInf(field,value,string)
% Any real scalar that is less than +Inf, or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value < +Inf);
if nargin > 2
    valid = valid || strcmpi(value,string);
end
if ~valid
    if ischar(value)
        errid = 'MATLAB:optimoptioncheckfield:realLessThanPlusInfStringType';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:realLessThanPlusInfStringType', field));
    else
        errid = 'MATLAB:optimoptioncheckfield:PlusInfReal';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:PlusInfReal', field));
    end
else
    errid = '';
    errmsg = '';
end

%---------------------------------------------------------------------------------
function    allstrings = formatCellArrayOfStrings(strings)
%formatCellArrayOfStrings converts cell array of strings "strings" into an
% array of strings "allstrings", with correct punctuation and "or" depending
% on how many strings there are, in order to create readable error message.

% To print out the error message beautifully, need to get the commas and "or"s
% in all the correct places while building up the string of possible string values.
    allstrings = ['''',strings{1},''''];
    for index = 2:(length(strings)-1)
        % add comma and a space after all but the last string
        allstrings = [allstrings, ', ''', strings{index},''''];
    end
    if length(strings) > 2
        allstrings = [allstrings,', or ''',strings{end},''''];
    elseif length(strings) == 2
        allstrings = [allstrings,' or ''',strings{end},''''];
    end
%----------------------------------------------------------------------------------

function optimoptionsAlgNames = getOptimoptionsAlgNames

persistent OOOAlgNames

if isempty(OOOAlgNames)
    % Get all the options meta classes
    mc = meta.class.fromName('optim.options.SolverOptions');
    AllClasses = mc.ContainingPackage.ClassList;
    OOOAlgNames = cell(1, length(AllClasses));
    for i = 1:length(AllClasses)
        % Only options classes that inherit from MultiAlgorithm support
        % the Algorithm option.
        if ~AllClasses(i).Abstract && ~isempty(AllClasses(i).SuperclassList) && ...
                strcmp(AllClasses(i).SuperclassList.Name, 'optim.options.MultiAlgorithm')
            % Add the algorithm names to a cell array holding the
            % algorithm names for the i-th solver options class
            thisOptions = feval(AllClasses(i).Name);
            thisOptionsStore = getOptionsStore(thisOptions);
            OOOAlgNames{i} = thisOptionsStore.AlgorithmNames;
        end
    end
    % List of all algorithm names in optimoptions
    OOOAlgNames = unique([OOOAlgNames{:}]);
end

optimoptionsAlgNames = OOOAlgNames;

%----------------------------------------------------------------------------------