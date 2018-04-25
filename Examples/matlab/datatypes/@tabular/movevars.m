function b = movevars(a,vars,varargin)
%MOVEVARS Move the specified table variables to a new location.
%   T2 = MOVEVARS(T1, VARS, 'Before', LOCATION) 
%   T2 = MOVEVARS(T1, VARS, 'After', LOCATION) moves the variables
%   specified by VARS to the position specified by LOCATION in T. VARS is a
%   positive integer, a vector of positive integers, a variable name, a
%   cell array containing one or more variable names, or a logical vector.
%   The location is specified as 'Before' or 'After'. LOCATION is a
%   positive integer, a variable name, or a logical vector containing a
%   single true value.
%
%   See also ADDVARS, REMOVEVARS, SPLITVARS, MERGEVARS.

%   Copyright 2017 The MathWorks, Inc.

a_varDim = a.varDim;

pnames = {'Before'    'After' };
dflts =  {      []    a_varDim.length };
[before,after,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

if ~(supplied.After || supplied.Before)
    error(message('MATLAB:table:addmovevars:NoBeforeOrAfter'));
elseif supplied.After && supplied.Before
    error(message('MATLAB:table:addmovevars:BeforeAndAfter'));
end

% Find indices to move, remove them from full index list.
if isa(vars,'vartype')
    error(message('MATLAB:table:addmovevars:VartypeInvalidVars'));
end
vars = a_varDim.subs2inds(vars);
index = 1:a_varDim.length;
index(vars) = [];

% Special case for empty tables
if a_varDim.length == 0
    % When a is an empty table, the only allowed LOCATIONs are:
    % - the end: 'Before', width(t)+1, 'After' width(t),
    % - the beginning: 'After' 0, or 'Before' 1, or 'After' false
    % ('After', false is consistent with table subscripting.)
    % Note that these are degenerate for width(t) = 0
    % If before/after are not a valid value, pass it to subs2inds in order
    % to throw the right error.
    if supplied.Before
        % allow movevars(t,[],'Before',width(t)+1) or 'Before', [true false false ...]
        isValidNumericBefore = isscalar(before) && before == 1;
        isValidLogicalBefore = islogical(before) && isvector(before) && before(1);
        if  isValidNumericBefore || isValidLogicalBefore
            b = a;
        else % get subs2inds to throw the right error
            a_varDim.subs2inds(before);
        end
    else %supplied.After
        % allow movevars(t,[],'After',0) or 'After', [false false false...]
        isValidNumericAfter = isscalar(after) && after == 0;
        isValidLogicalAfter = islogical(after) && isvector(after) && ~any(after);
        if isValidNumericAfter || isValidLogicalAfter 
            b = a;
        else % get subs2inds to throw the right error
            a_varDim.subs2inds(after);
        end
    end
    % Having validated vars (must be []) and LOCATION, we are moving
    % nothing, so return.
    return
end
    
% Support edge cases of 'After' 0 and 'Before' width(t)+1 which could be
% hit programmatically with empty tables.
if supplied.Before
    if isnumeric(before) && isscalar(before) && before == a.varDim.length + 1
        pos = before - 1;
        supplied.Before = false;
        supplied.After = true;
    else
        pos = before;
    end
else % supplied.After
    if isnumeric(after) && isscalar(after) && after == 0
        pos = 1;
        supplied.Before = true;
        supplied.After = false;
    else
        pos = after;
    end
end
if isa(pos,'vartype')
    error(message('MATLAB:table:addmovevars:VartypeInvalidLocation'));
end
pos = a_varDim.subs2inds(pos);
if ~isscalar(pos)
    error(message('MATLAB:table:addmovevars:NonscalarPosition'));
end

% Unify both before/after into after, with 0 indicating front.
% If location is in vars, treat before the same as after (both mean 'at').
if supplied.Before && ~any(vars == pos)
    pos = pos - 1; 
end
% We have to update the position based on the index after removing indices
% to be moved. If LOCATION is in VARS, need to account for that.
pos = pos - nnz(unique(vars) <= pos);

b = a.subsrefParens({':' [index(1:pos) vars index(pos+1:end)]});
