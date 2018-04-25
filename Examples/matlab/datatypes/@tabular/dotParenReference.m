function b = dotParenReference(t,varName,rowIndices,colIndices,varargin)
%DOTPARENREFERENCE Dot-parens subscripted reference for a table.

% This function is for internal use only and will change in a
% future release.  Do not use this function.

%   Copyright 2015-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isScalarInt

% dotParenReference is called directly for RHS subscripting expressions such as
%    t.Var(rowindices) or t.Var(rowindices,...)
%    t.Var(rownames)   or t.Var(rownames,...)
% but not (yet) for dynamic field references. This method is also called directly
% when there is deeper subscripting
%    t.Var(...)[anything else]
% where [anything else] is handled afterwards by the caller (assuming it
% is not illegal to begin with:"()-indexing must appear last"). With parens
% as the last level of subscripting, no need to worry about varargout.

% Translate variable (column) name into an index. Avoid overhead of
% t.varDim.subs2inds in this simple case.
if isnumeric(varName)
    % Allow t.(i) where i is an integer
    varIndex = varName;
    if ~isScalarInt(varIndex,1)
        error(message('MATLAB:table:IllegalVarIndex'));
    elseif varIndex > t.varDim.length
        error(message('MATLAB:table:VarIndexOutOfRange'));
    end
    % Allow t.(i) where i is an integer
    varIndex = varName;
elseif ischar(varName) && (isrow(varName) || isequal(varName,'')) % isCharString(varName)
    varIndex = find(strcmp(varName,t.varDim.labels));
    if isempty(varIndex)
        if strcmp(varName,t.metaDim.labels{1})
            % If it's the row dimension name, index into the row labels
            varIndex = 0;
        elseif strcmp(varName,t.metaDim.labels{2})
            % If it's the vars dimension name, subscripting into that is not supported,
            % must use explicit braces for that.
            error(message('MATLAB:table:NestedSubscriptingWithDotVariables',t.metaDim.labels{2}));
        
        else
            % If there's no such var, it may be a reference to a property, but
            % without the '.Properties'. Give a helpful error message. Neither
            % t.Properties or t.Properties.PropName end up here, those go to
            % subsrefDot.
            match = find(strcmpi(varName,t.propertyNames),1);
            if ~isempty(match)
                match = t.propertyNames{match};
                if strcmp(varName,match) % a valid property name
                    error(message('MATLAB:table:IllegalPropertyReference',varName,varName));
                else % a property name, but with wrong case
                    error(message('MATLAB:table:IllegalPropertyReferenceCase',varName,match,match));
                end
            else
                match = find(strcmpi(varName,t.varDim.labels),1);
                if ~isempty(match) % an existing variable name
                    match = t.varDim.labels{match};
                    error(message('MATLAB:table:UnrecognizedVarNameCase',varName,match));
                else
                    methodList = methods(t);
                    match = find(strcmpi(varName,methodList),1);
                    if ~isempty(match) % a method name
                        match = methodList{match};
                        error(message('MATLAB:table:IllegalDotMethod',varName,match,match));
                    else % no obvious match
                        error(message('MATLAB:table:UnrecognizedVarName',varName));
                    end
                end
            end
        end
    end
else
    error(message('MATLAB:table:IllegalVarSubscript'));
end

if varIndex > 0
    b = t.data{varIndex};
elseif varIndex == 0
    b = t.rowDim.labels;
else % varIndex == -1, all variables
    assert(false);
end

if isnumeric(rowIndices) || islogical(rowIndices) || tabular.iscolon(rowIndices)
    % Can leave these alone to save overhead of calling subs2inds
else
    % Dot-parens or dot-braces subscripting might use row labels inherited from the
    % table, translate those to indices.
    if ~iscolumn(b) && (nargin < 4)
        error(message('MATLAB:table:InvalidLinearIndexing'));
    end
    numericRowIndices = t.rowDim.subs2inds(rowIndices);
    % subs2inds returns the indices as a col vector, but subscripting on a table
    % variable (as opposed to on a table) should follow the usual reshaping rules.
    % Nothing to do for one (char) name, including ':', but preserve a cellstr
    % subscript's original shape.
    if iscell(rowIndices), numericRowIndices = reshape(numericRowIndices,size(rowIndices)); end
    rowIndices = numericRowIndices;
end

if nargin == 3
    if isa(b,'tabular')
        b = b.subsrefParens({rowIndices}); % get the tabular error for linear indexing
    else
        b = b(rowIndices);
    end
elseif nargin == 4
    if isa(b,'tabular')
        b = b.subsrefParens({rowIndices colIndices});
    else
        b = b(rowIndices,colIndices);
    end
else
    if isa(b,'tabular')
        b = b.subsrefParens([rowIndices colIndices varargin{:}]); % get the tabular error for N-D indexing
    else
        b = b(rowIndices,colIndices,varargin{:});
    end
end
