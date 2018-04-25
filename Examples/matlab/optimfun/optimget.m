function o = optimget(options,name,default,flag,alldefaults)
%OPTIMGET Get OPTIM OPTIONS parameters.
%   VAL = OPTIMGET(OPTIONS,'NAME') extracts the value of the named parameter
%   from optimization options structure OPTIONS, returning an empty matrix if
%   the parameter value is not specified in OPTIONS.  It is sufficient to
%   type only the leading characters that uniquely identify the
%   parameter.  Case is ignored for parameter names.  [] is a valid OPTIONS
%   argument.
%
%   VAL = OPTIMGET(OPTIONS,'NAME',DEFAULT) extracts the named parameter as
%   above, but returns DEFAULT if the named parameter is not specified (is [])
%   in OPTIONS.  For example
%
%     val = optimget(opts,'TolX',1e-4);
%
%   returns val = 1e-4 if the TolX parameter is not specified in opts.
%
%   See also OPTIMSET.

%   Copyright 1984-2017 The MathWorks, Inc.

% Undocumented usage for bypassing all error checking when caller passes no
% options
if (nargin == 5) && alldefaults
    o = default.(name);
    return
end

% Undocumented usage for fast access with minimal error checking
if (nargin >= 4) && strcmp(flag,'fast')
    o = optimgetfast(options,name,default);
    return
end

if nargin < 2
    error('MATLAB:optimget:NotEnoughInputs',...
        getString(message('MATLAB:optimfun:optimget:NotEnoughInputs')));
end

if nargin < 3
    default = [];
end

if ~isempty(options) && ~isa(options,'struct')
    error('MATLAB:optimget:Arg1NotStruct',...
        getString(message('MATLAB:optimfun:optimget:Arg1NotStruct')));
end

% Make the name attribute a character array so we can access
% structure properties.
if isstring(name)
    name = char(name);
end

% Make the output a character array for compatibility with old code.
if isstring(default)
    default = char(default);
end

if isempty(options)
    o = default;
    return;
end

allfields = ["Display";"MaxFunEvals";"MaxIter";"TolFun";"TolX";"FunValCheck";"OutputFcn";"PlotFcns"];

% Include specialized options if appropriate
if uselargeoptimstruct
    optimfields = string(optimoptiongetfields);  
    allfields = [allfields; optimfields];
end

Names = allfields;

name = deblank(name(:)'); % force this to be a row vector
j = startsWith(Names, name, 'IgnoreCase', true);
numMatches = sum(j);
if numMatches == 0
    error('MATLAB:optimget:InvalidPropName',...
        getString(message('MATLAB:optimfun:optimget:InvalidPropName', name)));
elseif numMatches > 1
    % Check for any exact matches (in case any names are subsets of others)
    k = strcmpi(name,Names);

    if sum(k) == 1
        j = k;
    else
        msg = '(' + join(Names(j), ', ') + '.)';
        msg = char(msg);
        error('MATLAB:optimget:AmbiguousPropName',...
            getString(message('MATLAB:optimfun:optimget:AmbiguousPropName', name, msg)));
    end
    
end

if any(strcmp(Names,Names(j)))
    o = options.(Names{j,:});
    if isempty(o) || any(strcmp(o, ''))
        o = default;
    end
else
    o = default;
end

%------------------------------------------------------------------
function value = optimgetfast(options,name,defaultopt)
%OPTIMGETFAST Get OPTIM OPTIONS parameter with no error checking so fast.
%   VAL = OPTIMGETFAST(OPTIONS,FIELDNAME,DEFAULTOPTIONS) will get the
%   value of the FIELDNAME from OPTIONS with no error checking or
%   fieldname completion. If the value is [], it gets the value of the
%   FIELDNAME from DEFAULTOPTIONS, another OPTIONS structure which is
%   probably a subset of the options in OPTIONS.
%

% Convert to character array in case input is a string class.
name = char(name);

if isempty(options)
     % Keep everything in character arrays for compatibility reasons.
     if (isstring(defaultopt.(name)))
         defaultopt.(name) = char(defaultopt.(name));
     end
     
     value = defaultopt.(name);
     return;
end

% We need to know if name is a valid field of options. If not, just bail.
% If the options structure is from an older version of the toolbox, it
% could be missing a newer field.
if isfield(options,name)
    value = options.(name);
    % Convert string values to char for the solvers
    if isstring(value)
        value = char(value);
    end
else
    value = [];
end

% Make sure that if the user specifies empty text 
% we ignore it and use default values.
if isempty(value)
    value = defaultopt.(name);
end





