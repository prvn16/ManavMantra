function sz = numArgumentsFromSubscript(t, s, context)
%numArgumentsFromSubscript Overloaded for tall arrays.

% Copyright 2016-2017 The MathWorks, Inc.

if isscalar(s) % one level of subscripting on a table
    sz = 1; % tall (incl. table) returns one array for parens, braces, and dot
            % If we supported brace indexing on a tall cell, we'd have to change that.
elseif context == matlab.mixin.util.IndexingContext.Assignment
    sz = 1; % tall (table) subsasgn only ever accepts one rhs value
    
else % multiple subscripting levels
    % This should never be called with parentheses as the last subscript
    assert(~strcmp(s(end).type,'()'), 'numArgumentsFromSubscript called with () as last substruct');
    % perform one level of indexing, then forward result to builtin numArgumentsFromSubscript
    x  = subsref(t, s(1));
    sz = numArgumentsFromSubscript(x,s(2:end),context);
end
end
