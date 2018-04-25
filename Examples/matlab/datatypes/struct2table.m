function t = struct2table(s,varargin)
%STRUCT2TABLE Convert structure array to table.
%   T = STRUCT2TABLE(S) converts the structure array S to a table T.  Each field
%   of S becomes a variable in T.  When S is a scalar structure with N fields,
%   all of which have M rows, then T is an M-by-N table.  When S is a non-scalar
%   structure array with M elements and N fields, then T is M-by-N.
%
%   T = STRUCT2TABLE(S, 'PARAM1', VAL1, 'PARAM2', VAL2, ...) specifies optional
%   parameter name/value pairs that determine how the data in S are converted.
%
%      'RowNames'      A cell array of character vectors containing row 
%                      names for T.  The names need not be valid MATLAB 
%                      identifiers, but must be unique.
%      'AsArray'       A logical value.  Setting this to true causes STRUCT2TABLE
%                      to always convert S to a table with LENGTH(S) rows, and
%                      not treat a scalar structure specially as described above.
%                      Default is false when S is a scalar structure, true otherwise.
%
%   See also TABLE2STRUCT, CELL2TABLE, ARRAY2TABLE, TABLE.

%   Copyright 2012-2017 The MathWorks, Inc.

import matlab.internal.datatypes.validateLogical

if ~isstruct(s)
    error(message('MATLAB:struct2table:NotVector'));
end

pnames = {'RowNames' 'AsArray'};
dflts =  {       []        [] };
[rownames,asArray,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

if supplied.AsArray
    asArray = validateLogical(asArray,'AsArray');
    if ~asArray && ~isscalar(s)
        error(message('MATLAB:struct2table:NonScalar'));
    end
else
    asArray = ~isscalar(s);
end

if asArray
    % Because structures grow as rows by default, don't be pedantic about
    % shape.  Accept either a row or a col.
    if ~isvector(s)
        error(message('MATLAB:struct2table:NotVector'));
    end

    vars = tabular.container2vars(s);

    nrows = numel(s);
    if isempty(vars) % creating a table with no variables
        % Give the output table the same number of rows as the input struct ...
        t = table.empty(nrows,0);
    else
        t = table.fromScalarStruct(cell2struct(vars,fieldnames(s),2)); % cell -> scalarStruct -> table
    end

else
    if isempty(fieldnames(s)) && supplied.RowNames
        % Size the array according to the row names
        t = table.empty(length(rownames),0);
    else
        try
            t = table.fromScalarStruct(s);
        catch ME
            matlab.internal.datatypes.throwInstead(ME,'MATLAB:table:UnequalFieldLengths',message('MATLAB:struct2table:UnequalFieldLengths'));
        end
    end

end

if supplied.RowNames, t.Properties.RowNames = rownames; end

