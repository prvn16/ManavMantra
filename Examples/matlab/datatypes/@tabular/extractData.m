function b = extractData(t,vars)
%EXTRACTDATA Extract data from a table.
%   B = EXTRACTDATA(T,VARS) returns the contents of the variables table T
%   specified by VARS, converted to an array whose type is that of the first
%   variable. The classes of the remaining variables must support the
%   conversion. VARS is a positive integer, a vector of positive integers, a
%   variable name, a cell array containing one or more variable names, or a
%   logical vector.
%
%   See also TABLE.

%   Copyright 2012-2017 The MathWorks, Inc.

vars = t.varDim.subs2inds(vars);
if isempty(vars)
    b = zeros(t.rowDim.length,0,'double');
    return
end
varsData = t.data(vars);

dims = cellfun('ndims',varsData);
if any(diff(dims)) % verify all veriables have same number of dimensions
    error(message('MATLAB:table:ExtractDataDimensionMismatch'));
end
sizes = zeros(length(varsData), dims(1));
for i = 1:length(varsData)
    sizes(i,:) = size(varsData{i});
end
if any(any(diff(sizes(:,[1 3:end]),[],1),1))
    error(message('MATLAB:table:ExtractDataSizeMismatch'));
end

% If there are any string vars, allow them to concatenate with cell arrays and
% whatever else they want to (primarily to support text stored as a mix of
% cellstr and string).
if ~any( cellfun('isclass', varsData, 'string') )
    % If there are cell vars (such as text in cellstr), the built-in horzcat can
    % confusingly concatenate them with non-cell vars (such as double), and some
    % horzcat overloads can cause that too (such as categorical and datetime).
    % It's very unlikely to be intended, so prevent it and give a specific error
    % about those vars.
    areCells = cellfun('isclass',varsData, 'cell');
    [~,firsts] = unique(areCells,'first'); % first non-cell, first cell
    if length(firsts) > 1
        throwIncompatibleTypeError(sort(vars(firsts)),t.varDim.labels,t.data)
    end
end
% Concatenate the cell array of variables.  If the vars are empty, the concatenation
% results in a 0x0 empty, not a 0xNvars empty.
try 
    b = [ varsData{:} ];
catch ME
    if strcmp(ME.identifier,'MATLAB:table:horzcat:InvalidInput')
        % One of the table's vars must have itself been a table, which is
        % supported only if they _all_ are. Give a specific error for this one,
        % because the generic MATLAB:table:ExtractDataCatError error below would
        % confusingly say, "All input arguments must be tables".
        areTabular = cellfun(@(x)isa(x,'tabular'),varsData);
        [~,firsts] = unique(areTabular,'first'); % first tabular, first non-tabular
        throwIncompatibleTypeError(sort(vars(firsts)),t.varDim.labels,t.data)
        end
    % This is most often a conversion error. 'MATLAB:UnableToConvert' is one
    % that's thrown by the built-in horzcat but only for char/logical and
    % struct/anything, and most conversion errors will come from horzcat
    % overloads and it's impossible to enumerate all of them. Could look for one
    % or two common 'MATLAB:<classname>:horzcat:...' errors, but that only
    % identifies one of the problematic vars (the class whose horzcat threw the
    % exception), and it's not simple to figure out the other one without adding
    % class-specific logic. Give a somewhat generic error with details in a
    % cause. The exception might also be some other unexpected error, this error
    % works for that too.
    throw(addCause(MException(message('MATLAB:table:ExtractDataCatError')),ME));
    end

%-----------------------------------------------------------------------
function throwIncompatibleTypeError(j,varNames,varData)
error(message('MATLAB:table:ExtractDataIncompatibleTypeError', ...
    varNames{j(1)},varNames{j(2)},class(varData{j(1)}),class(varData{j(2)})));

