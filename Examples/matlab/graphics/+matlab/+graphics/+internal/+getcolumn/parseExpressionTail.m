function [validExpression, exprDim1, exprDim3, subscripts] = parseExpressionTail(exprTail, varSize)
% This function is undocumented and may change in a future release.

% This is a utility function for use by getcolumn.

%   Copyright 1984-2015 The MathWorks, Inc.

% Using information about the variable from the workspace, try to parse the
% tail of the expression (which includes the subscripts) and identify the
% subscripts.

% If the subscripts consist of entirely "()", or are empty, then we have a
% valid expression and there is no need to parse the subscripts.
if isempty(exprTail) || strcmp(exprTail,'()')
    validExpression = true;
    exprDim1 = ':,';
    exprDim3 = '';
    subscripts = 1:varSize(2);
    return
end

% Try to parse the subscripts into three parts:
% exprDim1 - First dimension
% exprDim2 - Second dimension
% exprDim3 - Third and subsequent dimensions
[validExpression, exprDim1, exprDim2, exprDim3] = matlab.graphics.internal.getcolumn.parseSubscripts(exprTail);

% If we were successful in parsing the subscripts, we may need to
% adjust the columns to account for the subscripts.
subscripts = [];
if validExpression
    if ~isempty(exprDim1) && isempty(exprDim2) && isempty(exprDim3)
        % We only found a single subscript, which means the input
        % expression uses linear indexing instead of subscript
        % indexing, and the dimension of the input expression
        % depends on the dimensions of the subscript and the
        % variable.

        % Convert the subscript from a string to actual values.
        [validExpression, subscripts] = tryToEvalSubscript(exprDim1, prod(varSize));

        if validExpression
            % If indexing into a vector using a vector subscript, the
            % output vector will have the same orientation as the input
            % vector. Otherwise the output vector will have the same
            % size as the subscript.
            varIsVector = sum(varSize~=1)==1;
            subscriptIsVector = sum(size(subscripts)~=1)==1;
            if varIsVector && subscriptIsVector
                % Re-orient the subscript array to match the
                % orientation of the variable.
                varVectorDim = find(varSize~=1);
                subscripts = shiftdim(subscripts(:),1-varVectorDim);
            end
        end

        % The output expression will use linear indexing.
        exprDim1 = '';
    else
        % We found two or more sets of subscripts, so we are using
        % normal subscript indexing and we will evaluate the second
        % (column) subscript to determine the column indices.

        % If we are indexing with just 2 subscripts, then the second and
        % subsequent dimensions are combined.
        if isempty(exprDim3)
            numColumns = prod(varSize(2:end));
        else
            numColumns = varSize(2);
        end
        
        % Convert the second dimension subscripts into an array.
        [validExpression, subscripts] = tryToEvalSubscript(exprDim2, numColumns);
        subscripts = subscripts(:)';

        % The output expression will use subscript indexing, keep the
        % first dimension and append a comma.
        exprDim1 = [exprDim1 ','];
        
        % Prepend a comma onto the third dimension, if necessary.
        if ~isempty(exprDim3)
            exprDim3 = [',' exprDim3];
        end
    end
end

end

function [success, array] = tryToEvalSubscript(subExpression, sz)

% Use the size information to replace "end" with the size of the matrix
if numel(subExpression)>=3
    subExpression = strrep(subExpression,'end',num2str(sz));
end

if strcmp(subExpression,':')
    % Replace ":" with a column of the actual indices.
    array = (1:sz)';
    success = true;
else
    try
        % Evaluate the expression to convert it into a matrix.
        array = eval(subExpression);
        success = true;
    catch
        array = [];
        success = false;
    end
end

% Make sure none of our subscripts are out of range.
if any(array(:) > sz)
    success = false;
end

end
