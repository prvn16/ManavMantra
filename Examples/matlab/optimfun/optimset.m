function options = optimset(varargin)
%OPTIMSET Create/alter optimization OPTIONS structure.
%   OPTIONS = OPTIMSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates an
%   optimization options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to [] (parameters
%   with value [] indicate to use the default value for that parameter when
%   OPTIONS is passed to the optimization function). It is sufficient to type
%   only the leading characters that uniquely identify the parameter.  Case is
%   ignored for parameter names.
%   NOTE: For values that are text, the complete text is required.
%
%   OPTIONS = OPTIMSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of OLDOPTS
%   with the named parameters altered with the specified values.
%
%   OPTIONS = OPTIMSET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS.  Any parameters in NEWOPTS
%   with non-empty values overwrite the corresponding old parameters in
%   OLDOPTS.
%
%   OPTIMSET with no input arguments and no output arguments displays all
%   parameter names and their possible values, with defaults shown in {}
%   when the default is the same for all functions that use that parameter.
%   Use OPTIMSET(OPTIMFUNCTION) to see parameters for a specific function.
%
%   OPTIONS = OPTIMSET (with no input arguments) creates an options structure
%   OPTIONS where all the fields are set to [].
%
%   OPTIONS = OPTIMSET(OPTIMFUNCTION) creates an options structure with all
%   the parameter names and default values relevant to the optimization
%   function named in OPTIMFUNCTION. For example,
%           optimset('fminbnd')
%   or
%           optimset(@fminbnd)
%   returns an options structure containing all the parameter names and
%   default values relevant to the function 'fminbnd'.
%
%OPTIMSET PARAMETERS for MATLAB
%Display - Level of display [ off | iter | notify | final ]
%MaxFunEvals - Maximum number of function evaluations allowed
%                     [ positive integer ]
%MaxIter - Maximum number of iterations allowed [ positive scalar ]
%TolFun - Termination tolerance on the function value [ positive scalar ]
%TolX - Termination tolerance on X [ positive scalar ]
%FunValCheck - Check for invalid values, such as NaN or complex, from
%              user-supplied functions [ {off} | on ]
%OutputFcn - Name(s) of output function [ {[]} | function ]
%          All output functions are called by the solver after each
%          iteration.
%PlotFcns - Name(s) of plot function [ {[]} | function ]
%          Function(s) used to plot various quantities in every iteration
%
% Note to Optimization Toolbox users:
% To see the parameters for a specific function, check the documentation page
% for that function. For instance, enter
%   doc fmincon
% to open the reference page for fmincon.
%
% You can also see the options in the Optimization Tool. Enter
%   optimtool
%
%   Examples:
%     To create an options structure with the default parameters for FZERO
%       options = optimset('fzero');
%     To create an options structure with TolFun equal to 1e-3
%       options = optimset('TolFun',1e-3);
%     To change the Display value of options to 'iter'
%       options = optimset(options,'Display','iter');
%
%   See also OPTIMGET, FZERO, FMINBND, FMINSEARCH, LSQNONNEG.

%   Copyright 1984-2016 The MathWorks, Inc.

% Check to see if an optimoptions object has been passed in as the first
% input argument.
if nargin > 0 && isa(varargin{1}, 'optim.options.SolverOptions')
    error('MATLAB:optimset:OptimOptionsFirstInput',...
        getString(message('MATLAB:optimfun:optimset:OptimOptionsFirstInput')));
end

% Check to see if an optimoptions object has been passed in as the second
% input argument.
if nargin > 1 && isa(varargin{2}, 'optim.options.SolverOptions')
    error('MATLAB:optimset:OptimOptionsSecondInput',...
        getString(message('MATLAB:optimfun:optimset:OptimOptionsSecondInput')));
end

% Check to see if Optimization Toolbox options are available
[sharedoptim, fulloptim] = uselargeoptimstruct;

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
    if sharedoptim
        fprintf(['                Display: [ off | iter | iter-detailed | ', ...
            'notify | notify-detailed | final | final-detailed ]\n']);
    else
        fprintf(['                Display: [ off | iter | ', ...
            'notify | final ]\n']);
    end
    fprintf('            MaxFunEvals: [ positive scalar ]\n');
    fprintf('                MaxIter: [ positive scalar ]\n');
    fprintf('                 TolFun: [ positive scalar ]\n');
    fprintf('                   TolX: [ positive scalar ]\n');
    fprintf('            FunValCheck: [ on | {off} ]\n');
    fprintf('              OutputFcn: [ function | {[]} ]\n');
    fprintf('               PlotFcns: [ function | {[]} ]\n');

    % Display specialized options if appropriate
    if sharedoptim
        displayoptimoptions;
    else
        fprintf('\n');
    end
    return;
end

% Create a cell array of all the field names
allfields = {'Display'; 'MaxFunEvals';'MaxIter';'TolFun';'TolX'; ...
    'FunValCheck';'OutputFcn';'PlotFcns'};

% Include specialized options if appropriate
if sharedoptim
    optimfields = optimoptiongetfields;
    allfields = [allfields; optimfields];
end

% Create a struct of all the fields with all values set to []
% create cell array
structinput = cell(2,length(allfields));
% fields go in first row
structinput(1,:) = cellstr(allfields);
% []'s go in second row
structinput(2,:) = {[]};
% turn it into correctly ordered comma separated list and call struct
options = struct(structinput{:});

numberargs = nargin; % we might change this value, so assign it
% If we pass in a function name then return the defaults.
if (numberargs==1) && (ischar(varargin{1}) || (isstring(varargin{1}) && isscalar(varargin{1})) ...
        || isa(varargin{1},'function_handle') )
    
    if ischar(varargin{1}) || isstring(varargin{1})
        
        varargin{1} = char(varargin{1});
        funcname = lower(varargin{1});
        
        if ~exist(funcname,'file')
            error('MATLAB:optimset:FcnNotFoundOnPath',...
                getString(message('MATLAB:optimfun:optimset:FcnNotFoundOnPath', funcname)));
        end
        
    elseif isa(varargin{1},'function_handle')
        funcname = func2str(varargin{1});
    end
    
    % Check for solvers we know of that aren't supported by optimset
    if unsupportedSolver(funcname)
        error(message('MATLAB:optimfun:optimset:UnsupportedSolver',funcname));
    end    
    
    try
        optionsfcn = feval(varargin{1},'defaults');
    catch
        error('MATLAB:optimset:NoDefaultsForFcn',...
            getString(message('MATLAB:optimfun:optimset:NoDefaultsForFcn', funcname)));
    end
    % The defaults from the optim functions don't include all the fields
    % typically, so run the rest of optimset as if called with
    % optimset(options,optionsfcn)
    % to get all the fields.
    varargin{1} = options;
    varargin{2} = optionsfcn;
    numberargs = 2;
end

Names = string(allfields);
m = numel(Names);
names = lower(Names);

i = 1;
while i <= numberargs
    arg = varargin{i};
    
    if ischar(arg) || (isstring(arg) && isscalar(arg))  % arg is an option name
        arg = char(arg);
        break;
    end
    
    if ~isempty(arg)                      % [] is a valid options argument
        if ~isa(arg,'struct')
            error('MATLAB:optimset:NoParamNameOrStruct',...
                getString(message('MATLAB:optimfun:optimset:NoParamNameOrStruct', i)));
        end
        
        thisArgFieldnames = fieldnames(arg);
        for j = 1:m
            if any(strcmp(thisArgFieldnames,Names(j)))
                val = arg.(Names{j,:});
                
                % convert to char array if string object
                if isstring(val)
                    val = char(val);
                elseif iscell(val)
                   val = convertStringCellToCellStr(val);
                end
                
            else
                val = [];
            end
            
            if ~isempty(val)
                if ischar(val)
                    val = lower(strip(val));
                end
                options.(Names{j,:}) = checkfield(Names{j,:},val,sharedoptim);
            end
        end
    end
    i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(numberargs-i+1,2) ~= 0
    error('MATLAB:optimset:ArgNameValueMismatch',...
        getString(message('MATLAB:optimfun:optimset:ArgNameValueMismatch')));
end
expectval = 0;                          % start expecting a name, not a value
while i <= numberargs
    arg = varargin{i};

    if ~expectval
        if ~(ischar(arg) || (isstring(arg) && isscalar(arg)))
            error('MATLAB:optimset:ParamNotString',...
                getString(message('MATLAB:optimfun:optimset:ParamNotString', i)));
        end

        arg = deblank(arg);
        lowArg = char(lower(arg));
        j = startsWith(names, lowArg, 'IgnoreCase', true);
        numMatches = sum(j);
        
        if numMatches == 0
            % Check for recently deprecated options. These will be ignored
            % in a later release, but for now we will throw a specific
            % error.
            deprecatedOptionCheck(lowArg);
            if fulloptim
                % Slightly different error message if optim tbs ix
                % available.
                suggestOptimoptions(char(arg));
            end

            % Error out - compose internationalization-friendly message with hyperlinks
            linkStr = getString(message('MATLAB:optimfun:optimset:LinkToReferencePage'));
            stringWithLink = formatStringWithHyperlinks(linkStr,'doc optimset');
            error('MATLAB:optimset:InvalidParamNameWithLink',...
                getString(message('MATLAB:optimfun:optimset:InvalidParamNameWithLink', ...
                char(arg), stringWithLink)));

        elseif numMatches > 1
            % Check for any exact matches (in case any names are subsets of others)
            k = strcmp(lowArg,names);
            
            if sum(k) == 1
                j = k;
            else
                allnames = '(' + join(Names(j), ', ') + ')';
                allnames = char(allnames);
                error('MATLAB:optimset:AmbiguousParamName',...
                    getString(message('MATLAB:optimfun:optimset:AmbiguousParamName', char(arg), allnames)));
            end
            
        end

        % Check for options that are on a deprecation path.
        onDeprecationPathOptionCheck(lowArg, sharedoptim);

        % We expect a value next
        expectval = 1;
    else
        if ischar(arg) || (isstring(arg) && isscalar(arg))
            arg = deblank(lower(arg));
            arg = char(arg);
        elseif isstring(arg)
            arg = cellstr(deblank(arg(:)'));
        elseif iscell(arg)
            arg = convertStringCellToCellStr(arg);
        end
        options.(Names{j,:}) = checkfield(Names{j,:},arg,sharedoptim);
        expectval = 0;
    end
    i = i + 1;
end

if expectval
    error('MATLAB:optimset:NoValueForParam',...
        getString(message('MATLAB:optimfun:optimset:NoValueForParam', arg)));
end

%-------------------------------------------------
function value = checkfield(field,value,optimtbx)
%CHECKFIELD Check validity of structure field contents.
%   CHECKFIELD('field',V,OPTIMTBX) checks the contents of the specified
%   value V to be valid for the field 'field'. OPTIMTBX indicates if
%   the Optimization Toolbox is on the path.
%

% empty matrix is always valid
if isempty(value)
    return
end

% See if it is one of the valid MATLAB fields.  It may be both an Optim
% and MATLAB field, e.g. MaxFunEvals, in which case the MATLAB valid
% test may fail and the Optim one may pass.
validfield = true;
switch field
    case {'TolFun'} % real scalar
        [validvalue, errmsg, errid] = nonNegReal(field,value);
    case {'TolX'} % real scalar
        % this character array is for LSQNONNEG
        [validvalue, errmsg, errid] = nonNegReal(field,value,'10*eps*norm(c,1)*length(c)');
    case {'Display'} % several character strings
        [validvalue, errmsg, errid] = displayType(field,value);
    case {'MaxFunEvals','MaxIter'} % integer including inf or default character array
        % this character array is for FMINSEARCH
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'200*numberofvariables');
    case {'FunValCheck'} % off,on
        [validvalue, errmsg, errid] = onOffType(field,value);
    case {'OutputFcn','PlotFcns'}% function
        [validvalue, errmsg, errid] = functionOrCellArray(field,value);
    otherwise
        validfield = false;
        validvalue = false;
        errid = 'MATLAB:optimset:InvalidParamName';
        errmsg = getString(message('MATLAB:optimfun:optimset:InvalidParamName', field));
end

if validvalue
    return;
elseif ~optimtbx && validfield
    % Throw the MATLAB invalid value error
    ME = MException(errid,'%s',errmsg);
    throwAsCaller(ME);
else % Check if valid for Optim Tbx
    [value, optvalidvalue, opterrmsg, opterrid, optvalidfield] = optimoptioncheckfield(field,value);
    if optvalidvalue
        return;
    elseif optvalidfield
        % Throw the Optim invalid value error
        ME = MException(opterrid,'%s',opterrmsg);
        throwAsCaller(ME);
    else % Neither field nor value is valid for Optim
        % Throw the MATLAB invalid value error (can't be invalid field for
        % MATLAB & Optim or would have errored already in optimset).
        ME = MException(errid,'%s',errmsg);
        throwAsCaller(ME);
    end
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegReal(field,value,stringInput)
% Any nonnegative real scalar or sometimes a special character array
valid =  isreal(value) && isscalar(value) && (value >= 0) ;
if nargin > 2
    valid = valid || isequal(value,stringInput);
end

if ~valid
    if ischar(value)
        errid = 'MATLAB:optimset:nonNegRealStringType';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:nonNegRealStringType', field));
    else
        errid = 'MATLAB:optimset:notAnonNegReal';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAnonNegReal', field));
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegInteger(field,value,stringInput)
% Any nonnegative real integer scalar or sometimes a special character array
valid =  isreal(value) && isscalar(value) && (value >= 0) && value == floor(value) ;
if nargin > 2
    valid = valid || isequal(value,stringInput);
end
if ~valid
    if ischar(value)
        errid = 'MATLAB:optimset:nonNegIntegerStringType';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:nonNegIntegerStringType',field));
    else
        errid = 'MATLAB:optimset:notANonNegInteger';
        errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notANonNegInteger',field));
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = displayType(field,value)
% One of these strings: on, off, none, iter, final, notify
valid =  ischar(value) && any(strcmp(value, ...
    {'on';'off';'none';'iter';'iter-detailed';'final';'final-detailed';'notify';'notify-detailed';'testing';'simplex'}));
if ~valid
    errid = 'MATLAB:optimset:notADisplayType';
    errmsg = getString(message('MATLAB:optimfun:optimset:notADisplayType', field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = onOffType(field,value)
% One of these strings: on, off
valid =  ischar(value) && any(strcmp(value,{'on';'off'}));
if ~valid
    errid = 'MATLAB:optimset:notOnOffType';
    errmsg = getString(message('MATLAB:optimfun:optimset:notOnOffType', field));
else
    errid = '';
    errmsg = '';
end

%--------------------------------------------------------------------------------

function [valid, errmsg, errid] = functionOrCellArray(field,value)
% Any function handle, character array or cell array of functions
valid =  ischar(value) || isa(value, 'function_handle') || iscell(value);
if ~valid
    errid = 'MATLAB:optimset:notAFunctionOrCellArray';
    errmsg = getString(message('MATLAB:optimfun:optimset:notAFunctionOrCellArray', field));
else
    errid = '';
    errmsg = '';
end

%--------------------------------------------------------------------------------

function formattedString = formatStringWithHyperlinks(textToHyperlink,commandToRun)
% Check if user is running MATLAB desktop. In this case wrap
% textToHyperlink with HTML tags so that when user clicks on
% textToHyperlink, commandToRun gets executed. If not running
% MATLAB desktop, leave textToHyperlink unchanged.

if matlab.internal.display.isHot && ~isdeployed
    % If using MATLAB desktop and not deployed, use hyperlinks
    formattedString = sprintf('<a href="matlab: %s ">%s</a>.',commandToRun,textToHyperlink);
else
    % Use plain character array
    formattedString = sprintf('');
end

%--------------------------------------------------------------------------------

function onDeprecationPathOptionCheck(lowerCaseOption, optimtbx)
%ONDEPRECATIONPATHOPTIONCHECK Checks option against a list of options that
%are on a deprecation path. A specific warning message is thrown if there
%is a match.

if optimtbx
    switch lowerCaseOption
        % Add options here that are on a deprecation path.
    end
end

%--------------------------------------------------------------------------------

function deprecatedOptionCheck(lowerCaseOption)
%CHECKFORDEPRECATEDOPTIONS Checks option against a list of recently
%deprecated options. A specific error message is thrown if there is a
%match.
removedOptExcept = [];
switch lowerCaseOption
    case 'linesearchtype'
        removedOptExcept = MException('MATLAB:optimset:LStypeInvalid', ...
            '%s', getString(message('MATLAB:optimfun:optimset:LStypeInvalid')));
end

if ~isempty(removedOptExcept)
    throwAsCaller(removedOptExcept);
end

%--------------------------------------------------------------------------------
function suggestOptimoptions(arg)
%SUGGESTOPTIMOPTIONS Throw error and suggest to use optimoptions function
% if possible.

try
    % linkStr = 'Link to options table';
    linkStr = getString(message('MATLAB:optimfun:optimset:LinkToOptimOptionsTable'));
catch
    return
end
if feature('hotlinks') && ~isdeployed
    linkDestination = 'optim_opt_table';
    % Create explicit char array so as to avoid translation
    openTag = sprintf('<a href = "matlab: helpview([docroot ''/toolbox/optim/helptargets.map''],''%s'');">',...
        linkDestination);
    closeTag = '</a>';
    taggedString = [openTag linkStr closeTag];
else
    taggedString = linkStr;
end

errMsg = getString(message('MATLAB:optimfun:optimset:InvalidParamTryOptimoptions', ...
    arg, taggedString));
% Throw error
throwAsCaller(MException('MATLAB:optimset:InvalidParamNameWithLink', errMsg))

%--------------------------------------------------------------------------------
function TorF = unsupportedSolver(funcname)
%UNSUPPORTEDSOLVER Check for solvers not supported by optimset.

TorF = any(strcmp(funcname, ...
    {'ga';'gamultiobj';'patternsearch';'simulannealbnd';'particleswarm'; ... % Global Optimization
     'intlinprog'} ...                                                       % Optimization
     ));

%--------------------------------------------------------------------------------
function cellOut = convertStringCellToCellStr(cellIn)
    % CONVERTSTRINGCELLTOCELLSTR Loops through a cell array and converts
    % all string objects to cell arrays
    
    cellOut = cellIn(:)';
    
    if iscell(cellOut)
        % loop through all cell array inputs and convert any
        % string datatypes to character arrays
        isStringTypeInCell = cellfun(@isstring, cellOut);
        isScalarTypeInCell = cellfun(@isscalar, cellOut);
        isCharTypeInCell = cellfun(@ischar, cellOut);

        stringAndScalar = isStringTypeInCell & isScalarTypeInCell;
        stringAndArray = isStringTypeInCell & ~isScalarTypeInCell;

        % convert scalar strings to character arrays
        cellOut(stringAndScalar) = cellstr(deblank(cellOut(stringAndScalar)));
        cellOut(isCharTypeInCell) = deblank(cellOut(isCharTypeInCell));

        % convert non-scalar strings to cell arrays of
        % character vectors
        if any(stringAndArray)
            for k = find(stringAndArray)
                cellOut{k} = cellstr(cellOut{k});
            end
        end
    end

    