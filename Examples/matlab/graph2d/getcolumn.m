function y = getcolumn(x, n, expressionType, workspace)
%GETCOLUMN Get a column of data
%   Y = GETCOLUMN(X,N) returns column N of X.

%   Y = GETCOLUMN(X,N,'expression') returns an expression that
%   evaluates to column N of X. If X is a variable in the base
%   workspace then GETCOLUMN returns 'X(:,N)' and otherwise it returns
%   'getcolumn(X,N)'. If N is a vector then it returns a cell array of 
%   strings vectorized over N.
%
%   Y = GETCOLUMN(X,N,'expression',ws) where ws is either 'base' or
%   'caller' is the same as Y = GETCOLUMN(X,N,'expression') except that
%   expression evaluation is performed in the specified workspace.

%   Copyright 1984-2015 The MathWorks, Inc.

narginchk(2,4);

% If only two arguments were specified, then return column N of X.
if nargin == 2
    y = x(:,n);
    return
end

%%%%%%
% More than two arguments were specified, so we should be returning an
% expression that evaluates to column N of X.
% This cannot be moved into a sub-function because we are using 'evalin' to
% access the 'caller' workspace.
inExpression = x;
inColumns = n;

% Select the default 'base' workspace if no workspace provided.
if nargin < 4
    workspace = 'base';
end

% Remove spaces from front and back of the expression.
inExpression = strtrim(inExpression);

% Parse the expression into three parts:
% exprHead - variable name
% exprField - array, cell, or structure referencing
% exprTail - subscripts
[validExpression, exprHead, exprField, exprTail] = matlab.graphics.internal.getcolumn.parseExpression(inExpression);

% If we were able to parse the expression, check whether exprHead exists in
% the base workspace and if so, find out the size of the data.
% This cannot be moved into a sub-function because we are using 'evalin' to
% access the 'caller' workspace.
varExists = false;
if validExpression
    try
        cmd = ['exist(''' exprHead ''',''var'')'];
        varExists = (evalin(workspace,cmd) == 1);
    catch %#ok<CTCH>
        varExists = false;
    end

    % If the variable exists in the workspace, we will try to determine the
    % size of the matrix referenced, and at the same time make sure the
    % complete expression (head + field) refers to a valid variable.
    if varExists
        % Get the size of the data referenced by the input expression
        try
            cmd = ['size(' exprHead exprField ')'];
            varSize = evalin(workspace,cmd);
        catch %#ok<CTCH>
            varExists = false;
        end
    end
end

% Now we know whether the expression refers to a valid variable, and
% if so the size of the variable. Now look at the subscripts to see how
% they change the picture.
outColumns = inColumns(:)';
if validExpression && varExists
    [validExpression, exprDim1, exprDim3, subscripts] = matlab.graphics.internal.getcolumn.parseExpressionTail(exprTail, varSize);
        
    % Make sure we are not trying to access a column that is out of range.
    maxInColumn = max([0; inColumns(:)]);
    if validExpression && maxInColumn > size(subscripts,2)
        validExpression = false;
    end
    
    % Convert column numbers based on the subscripts.
    if validExpression && ~isempty(subscripts)
        outColumns = subscripts(:,inColumns);
    end
end

%%%%%%
% Create the output expression.

if validExpression
    if varExists
        outExprPrefix = [exprHead exprField '(' exprDim1];
        outExprPostfix = [exprDim3 ')'];
    elseif strcmpi(expressionType,'displayname')
        % We have a valid expression, but the variable does not exist in
        % the specified workspace, return the original input expression as
        % the DisplayName.
        outExprPrefix = inExpression;
        outExprPostfix = '';
    else
        % We have a valid expression, but the variable does not exist in
        % the specified workspace, so we do not know if it is a variable
        % name or a function name. Therefore, create an expression using
        % 'getcolumn':
        outExprPrefix = ['getcolumn(' inExpression ','];
        outExprPostfix = ')';
    end
else
    if strcmpi(expressionType,'displayname')
        % If we do not have a valid expression, then we will return the
        % original input expression as the DisplayName
        outExprPrefix = inExpression;
        outExprPostfix = '';
    else
        % If we were asked for an expression, but failed to interpret the
        % one provided, then just spit it back out wrapped in 'getcolumn'
        outExprPrefix = ['getcolumn(' inExpression ','];
        outExprPostfix = ')';
    end
end

if numel(inColumns) == 1 && isempty(outExprPostfix)
    % If we have just one expression to create, and the postfix is empty
    % (we are creating a DisplayName and something went wrong), then the
    % output expression will just equal the input expression.
    outExpression = outExprPrefix;
elseif size(outColumns,2) == 1
    % If we have just one expression to create, but we have a postfix, then
    % create a character array with the output (instead of a cell array).
    outExpression = [outExprPrefix vecToString(outColumns(:,1)) outExprPostfix];
else
    % If we have multiple expressions to create, then create a cell array
    % of strings and insert the appropriate column index into the
    % expression.
    outExpression = cell(1,size(outColumns,2));
    for k = 1:size(outColumns,2)
        outExpression{k} = [outExprPrefix vecToString(outColumns(:,k)) outExprPostfix];
    end
end

% Assign the output expression to the output variable.
y = outExpression;

end

% Convert a column vector of numbers into an expression that will evaluate
% to the same column vector of numbers.
function str = vecToString(vec)
    if numel(vec) == 1
        str = num2str(vec);
    else
        str = cellstr(num2str(vec));
        str = ['[' strjoin(strtrim(str),';') ']'];
    end
end
