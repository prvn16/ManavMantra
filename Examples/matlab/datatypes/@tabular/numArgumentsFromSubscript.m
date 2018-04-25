function sz = numArgumentsFromSubscript(t,s,context)
%NUMARGUMENTSFROMSUBSCRIPT Number of output arguments for a table subscript.

% This function is for internal use only and will change in a
% future release.  Do not use this function.

%   Copyright 2016-2017 The MathWorks, Inc.

if isscalar(s) % one level of subscripting on a table
    sz = 1; % table returns one array for parens, braces, and dot
elseif context == matlab.mixin.util.IndexingContext.Assignment
    sz = 1; % table subsasgn only ever accepts one rhs value
elseif strcmp(s(end).type,'()')
    % This should never be called with parentheses as the last
    % subscript, but return 1 for that just in case
    sz = 1;
else % multiple subscripting levels
    recurseAtLevel = 2;
    % Perform one level of indexing, then forward result to builtin numArgumentsFromSubscript
    if strcmp(s(1).type,'{}')
        x = t.subsrefBraces(s(1));
    elseif strcmp(s(1).type,'.')
        if strcmp(s(1).subs,'Properties')
            if isequal(s(2).type,'.')
                if length(s) == 2 % t.Properties.PropertyName
                    sz = 1; % no need to validate the name, subsref will do that
                    return
                else % t.Properties.PropertyName...
                    % Strip off _two_ levels of subscripting, this makes common cases like
                    % t.Properties.VariableNames{1} significantly faster
                    x = t.getProperty(s(2));
                    recurseAtLevel = 3;
                    % If this is 1-D parens/braces subscripting on a property, convert names to indices
                    % for properties that support named indexing, e.g.t.Properties.RowNames{'SomeName'}
                    if ~strcmp(s(3).type,'.') && isscalar(s(3).subs)
                        propertyIndices = s(3).subs{1};
                        if isnumeric(propertyIndices) || islogical(propertyIndices) || tabular.iscolon(propertyIndices)
                            % Can leave these alone to save overhead of calling subs2inds
                        else % named subscripting
                            switch s(2).subs
                            case {'VariableNames' 'VariableDescriptions' 'VariableUnits'}
                                s(3).subs{1} = t.varDim.subs2inds(propertyIndices);
                            case 'RowNames'
                                s(3).subs{1} = t.rowDim.subs2inds(propertyIndices);
                            case 'DimensionNames'
                                s(3).subs{1} = t.metaDim.subs2inds(propertyIndices);
                            end
                        end
                    end
                end
            else % t.Properties(...) or t.Properties{...}
                x = t.getProperties(); % let t.Properties's numArgumentsFromSubscript throw the error
            end
        else
            x = t.subsrefDot(s(1));
            if ~isequal(s(2).type,'.') % t.Var(...) or t.Var{...}
                % Dot-parens or dot-braces subscripting might use row labels inherited from the
                % table, translate those to indices.
                rowIndices = s(2).subs{1};
                if isnumeric(rowIndices) || islogical(rowIndices) || tabular.iscolon(rowIndices)
                    % Can leave these alone to save overhead of calling subs2inds
                else
                    if ~iscolumn(x) && isscalar(s(2).subs)
                        error(message('MATLAB:table:InvalidLinearIndexing'));
                    end
                    numericRowIndices = t.rowDim.subs2inds(rowIndices); % (leaves ':' alone)
                    % subs2inds returns the indices as a col vector, but subscripting on a table
                    % variable (as opposed to on a table) should follow the usual reshaping rules.
                    % Nothing to do for one (char) name, including ':', but preserve a cellstr
                    % subscript's original shape.
                    if iscell(rowIndices), numericRowIndices = reshape(numericRowIndices,size(rowIndices)); end
                    s(2).subs{1} = numericRowIndices;
                end
            else % t.Var.Field
                % OK
            end
        end
    else % strcmp(s(1).type,'()'), e.g. t(...,...).Var
        x = t.subsrefParens(s(1));
    end
    s = s(recurseAtLevel:end);
    sz = matlab.internal.tabular.private.numArgumentsFromSubscriptRecurser(x,s,context);
end
