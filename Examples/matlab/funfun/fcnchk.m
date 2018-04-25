function [f,msg] = fcnchk(fun,varargin)
%FCNCHK Check FUNFUN function argument.
%
%   FCNCHK will not accept string expressions for FUN in a future
%   release. Use anonymous functions for FUN instead.
%
%   FCNCHK(FUN,...) returns an inline object based on FUN if FUN
%   is a string containing parentheses, variables, and math
%   operators.  FCNCHK simply returns FUN if FUN is a function handle, 
%   or a MATLAB object with an feval method (such as an inline object). 
%   If FUN is a string name of a function (e.g. 'sin'), FCNCHK returns a
%   function handle to that function.
%
%   FCNCHK is a helper function for FMINBND, FMINSEARCH, FZERO, etc. so they
%   can compute with string expressions in addition to functions.
%
%   FCNCHK(FUN,...,'vectorized') processes the string (e.g., replacing
%   '*' with '.*') to produce a vectorized function.
%
%   When FUN contains an expression then FCNCHK(FUN,...) is the same as
%   INLINE(FUN,...) except that the optional trailing argument 'vectorized'
%   can be used to produce a vectorized function.
%
%   [F,ERR] = FCNCHK(...) returns a struct array ERR. This struct is empty
%   if F was constructed successfully. ERR can be used with ERROR to throw
%   an appropriate error message if F was not constructed successfully.
%
%   See also ERROR, INLINE, @, FUNCTION_HANDLE.

%   Copyright 1984-2012 The MathWorks, Inc.

msgident = '';

nin = nargin;
if nin > 1 && strcmp(varargin{end},'vectorized')
    vectorizing = true;
    nin = nin - 1;
else
    vectorizing = false;
end

if ischar(fun)
    fun = strtrim_local_function(fun);
    % Check for non-alphanumeric characters that must be part of an
    % expression.
    if isempty(fun),
        f = inline('[]');
    elseif ~vectorizing && isidentifier_local_function(fun)
        f = str2func(fun); % Must be a function name only
        % Note that we avoid collision of f = str2func(fun) with any local
        % function named fun, by uglifying the local function's name
        if isequal('x',fun)
            warning(message('MATLAB:fcnchk:AmbiguousX'));
        end
    else
        if vectorizing
            f = inline(vectorize(fun),varargin{1:nin-1});
            var = argnames(f);
            f = inline([formula(f) '.*ones(size(' var{1} '))'],var{1:end});
        else
            f = inline(fun,varargin{1:nin-1});
        end 
    end
elseif isa(fun,'function_handle') 
    f = fun; 
    % is it a MATLAB object with a feval method?
elseif isobject(fun)
    % delay the methods call unless we know it is an object to avoid
    % runtime error for compiler
    [meths,cellInfo] = methods(class(fun),'-full');
    if ~isempty(cellInfo)   % if fun is a MATLAB object
        meths = cellInfo(:,3);  % get methods names from cell array
    end
    if any(strmatch('feval',meths))
       if vectorizing && any(strmatch('vectorize',meths))
          f = vectorize(fun);
       else
          f = fun;
       end
    else % no feval method
        f = '';
        msgident = 'MATLAB:fcnchk:objectMissingFevalMethod';
    end
else
    f = '';
    msgident = 'MATLAB:fcnchk:invalidFunctionSpecifier';
end

% If no errors and nothing to report then we are done.
if nargout < 2 && isempty(msgident)
    return
end

% compute MSG
if isempty(msgident)
    msg.message = '';
    msg.identifier = '';
    msg = msg(zeros(0,1)); % make sure msg is the right dimension
else
    msg.identifier = msgident;
    msg.message = getString(message(msg.identifier));
end

if nargout < 2
    if ~isempty(msg)
        error(message(msg.identifier));
    end
end


%------------------------------------------
function s1 = strtrim_local_function(s)
%STRTRIM_LOCAL_FUNCTION Trim spaces from string.
% Note that we avoid collision with line 45: f = str2func('strtrim')
% by uglifying the local function's name

if isempty(s)
    s1 = s;
else
    % remove leading and trailing blanks (including nulls)
    c = find(s ~= ' ' & s ~= 0);
    s1 = s(min(c):max(c));
end

%-------------------------------------------
function tf = isidentifier_local_function(str)
% Note that we avoid collision with line 45: f = str2func('isidentifier')
% by uglifying the local function's name


tf = false;

if ~isempty(str)
    first = str(1);
    if (isletter(first))
        letters = isletter(str);
        numerals = (48 <= str) & (str <= 57);
        underscore = (95 == str);
        tf = all(letters | numerals | underscore);
    end
end

