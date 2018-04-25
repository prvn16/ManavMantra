function s = table2struct(t,varargin)
%TABLE2STRUCT Convert table to structure array.
%   S = TABLE2STRUCT(T) converts the table T to a structure array S.  Each
%   variable of T becomes a field in S.  If T is an M-by-N table, then S is
%   M-by-1 and has N fields.
%
%   S = TABLE2STRUCT(T,'ToScalar',true) converts the table T to a scalar
%   structure S.  Each variable of T becomes a field in S.  If T is an
%   M-by-N table, then S has N fields, each of which has M rows.
%
%   S = TABLE2STRUCT(T,'ToScalar',false) is identical to S = TABLE2STRUCT(T).
%
%   See also STRUCT2TABLE, TABLE2CELL, TABLE.

%   Copyright 2012-2013 The MathWorks, Inc.

import matlab.internal.datatypes.validateLogical

pnames = {'ToScalar'};
dflts =  {    false };
[toScalar] = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

toScalar = validateLogical(toScalar,'ToScalar');
if toScalar
    s = getVars(t);
else
    s = cell2struct(table2cell(t),t.Properties.VariableNames,2);
end
