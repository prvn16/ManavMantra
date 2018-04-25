function b = addvars(a,varargin)
%ADDVARS Add variables to table or timetable.
%   T2 = ADDVARS(T1, VAR1, ..., VARN) appends the arrays VAR1,...,VARN as
%   variables to the table T1. VAR1,...,VARN can include arrays of any
%   type, including tables and timetables. All input arguments must have
%   the same number of rows.
%
%   T2 = ADDVARS(..., 'Before', LOCATION) 
%   T2 = ADDVARS(..., 'After',  LOCATION) inserts the variables either
%   before or after the position specified by LOCATION. LOCATION is a
%   positive integer, a variable name, or a logical vector containing a
%   single true value. ADDVARS(..., 'After', width(T1)) is equivalent to
%   the default behavior.
%
%   T2 = ADDVARS(..., 'NewVariableNames', NEWNAMES) specifies the names of
%   the variables added in T2. NEWNAMES is a cell array containing the same
%   number of names as the number of added variables.
%
%   See also REMOVEVARS, MOVEVARS, SPLITVARS, MERGEVARS.

%   Copyright 2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

a_varDim = a.varDim;

pnames = {'NewVariableNames'  'Before'           'After' };
dflts =  {               []        []    a_varDim.length };

partialMatchPriority = [0 0 0]; % no partial match overlap
[numVars, newvarnames, before, after,supplied] ...
    = matlab.internal.datatypes.reverseParseArgs(pnames,dflts,partialMatchPriority,varargin{:}); 

if supplied.After && supplied.Before
    error(message('MATLAB:table:addmovevars:BeforeAndAfter'));
end
if numVars == numel(varargin) % No NV pairs: set defaults.
    supplied.NewVariableNames = false;
    supplied.Before = false;
    supplied.After = false;
    after = a_varDim.length;
end

% Figure out the positions of the new variables now so that generated var
% names can be correctly numbered.
% Support edge cases of 'After' 0 and 'Before' width(t)+1 which could be
% hit programmatically with empty tables.
if ~supplied.Before && isnumeric(after) && isscalar(after) && after == 0 % 'After', 0 becomes 'Before', 1
    addIndex = 1;
    supplied.Before = true;
    supplied.After = false;
elseif supplied.Before && isnumeric(before) && isscalar(before) && before == a_varDim.length + 1 
    if a_varDim.length ~= 0 % non-empty table: 'After', width(t)
        addIndex = before - 1;
        supplied.Before = false;
        supplied.After = true;
    else % empty table: 'Before', 1
        addIndex = 1;
    end
else % 
    if supplied.Before
        pos = before;
    else
        pos = after;
    end
    if isa(pos,'vartype')
        error(message('MATLAB:table:addmovevars:VartypeInvalidLocation'))
    end
    addIndex = a_varDim.subs2inds(pos);
end
% cast other numeric types
addIndex = double(addIndex);

if ~isscalar(addIndex)
    error(message('MATLAB:table:addmovevars:NonscalarPosition'))
end

% Generate default names for the added data var(s) if needed, avoiding conflicts
% with existing var or dim names. If NewVariableNames was given, duplicate names
% are an error, caught by setLabels here or by checkAgainstVarLabels below.
if ~supplied.NewVariableNames
    % Get the workspace names of the input arguments from inputname
    newvarnames = cell(1,numVars);
    for i = 1:numVars, newvarnames{i} = inputname(i+1); end
    % Fill in default names for data args where inputname couldn't.
    empties = cellfun('isempty',newvarnames);
    if any(empties)
        % Adjust names to reflect position - shift to where they're added, shift back one if 'Before'.
        newvarnames(empties) = a_varDim.dfltLabels(find(empties) + addIndex - supplied.Before); 
    end
    % Make sure default names or names from inputname don't conflict with
    % existing variables names.
    newvarnames = matlab.lang.makeUniqueStrings(newvarnames,[a_varDim.labels a.metaDim.labels],namelengthmax);
else % supplied.NewVariableNames
    [tf,newvarnames] = matlab.internal.datatypes.isCharStrings(newvarnames);
    if ~tf
        error(message('MATLAB:table:InvalidVarNames'));
    elseif length(newvarnames) ~= numVars
        % Check that there are the right number of supplied varnames.
        error(message('MATLAB:table:addmovevars:IncorrectNumberOfVarNames'));
    end
    % New vars cannot clash with a's dim names. We know they don't if we
    % create them. Only check when user-supplied.
    a.metaDim.checkAgainstVarLabels(newvarnames,'error');
end

b = a;
% Adding no variables is a no-op. Do this after going through newvarnames
% to provide a helpful error if numVars differs from number of newvarnames.
if numVars == 0
    return
end

newvars = table(varargin{1:numVars},'VariableNames',newvarnames);

% If a is a 0x0 timetable, it will get gobbled up in horzcat, so work around it:
% - Lengthen the rows to match newvars so it's not 0x0.
% - When newvars is also zero height, just convert it to a timetable.
if b.rowDim.length == 0 && b.varDim.length == 0 && newvars.rowDim.length > 0
        b.rowDim = b.rowDim.lengthenTo(newvars.rowDim.length);
end

% Make sure it is safe to assign newvars into b:
% - same height(if newvars has one row, subsasgnParens
%   will scalar expand newvars to the height of b)
% - no common names (otherwise, subsasgnParens will overwrite)
if b.rowDim.length ~= newvars.rowDim.length
    error(message('MATLAB:table:addmovevars:SizeMismatch'));
end    

duplicates = ismember(b.varDim.labels,newvars.varDim.labels);
if any(duplicates)
    error(message('MATLAB:table:DuplicateVarNames',b.varDim.labels{find(duplicates,1)}))
end

b = b.subsasgnParens({':',newvars.varDim.labels},newvars);

if supplied.Before
    b = movevars(b,a_varDim.length + 1:b.varDim.length,'Before',addIndex);
else
    b = movevars(b,a_varDim.length + 1:b.varDim.length,'After',addIndex);
end