function [b,varargout] = subsrefParens(t,s)
%SUBSREFPARENS Subscripted reference for a table.

%   Copyright 2012-2016 The MathWorks, Inc.

% '()' is a reference to a subset of a table.  If no subscripting
% follows, return the subarray.  Only dot subscripting may follow.

import matlab.internal.datatypes.isUniqueNumeric
subsType = matlab.internal.tabular.private.tabularDimension.subsType;

if ~isstruct(s), s = struct('type','()','subs',{s}); end

if numel(s(1).subs) ~= t.metaDim.length
    error(message('MATLAB:table:NDSubscript'));
elseif isscalar(s) && nargout > 1
    % Simple parenthesis indexing can only return a single thing.
    error(message('MATLAB:table:TooManyOutputs'));
end

% Create an empty output table.
b = t.cloneAsEmpty(); % respect the subclass

% Translate row labels into indices (leaves logical and ':' alone).
t_rowDim = t.rowDim;
[rowIndices,numRowIndices,~,isColonRows,b_rowDim] = t_rowDim.subs2inds(s(1).subs{1});
b.rowDim = b_rowDim;

% Translate variable (column) names into indices (translates logical and ':').
t_varDim = t.varDim;
[varIndices,numVarIndices,~,~,b_varDim] = t_varDim.subs2inds(s(1).subs{2},subsType.reference,t.data);
b.varDim = b_varDim;

% Move the data to the output.
b_data = cell(1,b.varDim.length);
t_data = t.data;
for j = 1:numVarIndices
    var_j = t_data{varIndices(j)};
    if isColonRows
        b_data{j} = var_j; % a fast shared-data copy
    elseif isa(var_j,'tabular')
        b_data{j} = var_j.subsrefParens({rowIndices ':'}); % force dispatch to overloaded table subscripting
    elseif ismatrix(var_j)
        b_data{j} = var_j(rowIndices,:); % without using reshape, may not have one
    else
        % Each var could have any number of dims, no way of knowing,
        % except how many rows they have.  So just treat them as 2D to get
        % the necessary rows, and then reshape to their original dims.
        sizeOut = size(var_j); sizeOut(1) = numRowIndices;
        b_data{j} = reshape(var_j(rowIndices,:), sizeOut);
    end
end
b.data = b_data;

% Create subscripters for the output. If the RHS subscripts are labels or numeric
% indices, they may have picked out the same row or variable more than once, but
% selectFrom creates the output labels correctly.
b.metaDim = t.metaDim;

% Move the per-array properties to the output.
b.arrayProps = t.arrayProps;

if isscalar(s)
    % If there's no additional subscripting, return the subarray.
    if nargout > 1
        nargoutchk(0,1);
    end
else
    switch s(2).type
    case '()'
        error(message('MATLAB:table:InvalidSubscriptExpr'));
    case '{}'
        error(message('MATLAB:table:InvalidSubscriptExpr'));
    case '.'
        if nargout < 2
            b = b.subsrefDot(s(2:end));
        else
            [b, varargout{1:nargout-1}] = b.subsrefDot(s(2:end));
        end
    end
end
