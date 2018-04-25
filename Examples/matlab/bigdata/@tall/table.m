function tt = table(varargin)
%TABLE Build a tall table from tall arrays
%   TT = TABLE(T1,T2,...) creates a tall table TT from tall arrays
%   T1, T2, ... . All arrays must be tall and have the same number of
%   rows.
%
%   TT = TABLE(..., 'VariableNames', {'name1', ..., 'name_M'}) creates a
%   table containing variables that have the specified variable names.
%   The names must be valid MATLAB identifiers, and unique.
%
%   See also tall, table.

% Copyright 2015-2017 The MathWorks, Inc.

% Attempt to deal with trailing p-v pairs.
if nargin > 2 && ischar(varargin{end-1})
    flag = varargin{end-1};
    if ~isequal(flag, 'VariableNames')
        error(message('MATLAB:bigdata:array:InvalidTableFlag'));
    end
    if ~(iscellstr(varargin{end}) && numel(varargin{end}) == nargin - 2)
        error(message('MATLAB:bigdata:array:TableVariableNamesFormat', nargin - 2));
    end
    varNames = varargin{end};
    if numel(unique(varNames)) ~= numel(varNames)
        error(message('MATLAB:bigdata:array:TableVariableNamesUnique'));
    end
    varValues = varargin(1:end-2);
else
    varNames = cell(1, nargin);
    for idx = 1:nargin
        ipName = inputname(idx);
        if isempty(ipName)
            ipName = sprintf('Var%d', idx);
        end
        
        % Check for collision with preceding names
        ipBase  = ipName;
        nextIdx = 1;
        while ismember(ipName, varNames(1:idx-1))
            % Need to uniquify
            ipName  = sprintf('%s_%d', ipBase, nextIdx);
            nextIdx = nextIdx + 1;
        end
        varNames{idx} = ipName;
    end
    varValues = varargin;
    assert(numel(unique(varNames)) == numel(varNames));
end

if ~all(cellfun(@(x) isa(x, 'tall'), varValues))
    error(message('MATLAB:bigdata:array:AllTableArgsTall'));
end

tt = slicefun(@(varargin) matlab.bigdata.internal.util.makeTabularChunk(...
    @table, varargin, {'VariableNames', varNames}), varValues{:});
adaptors = cellfun(@(tx) tx.Adaptor, varValues, 'UniformOutput', false);
unsizedAdaptor = matlab.bigdata.internal.adaptors.TableAdaptor(varNames, adaptors);
tt.Adaptor = copySizeInformation(unsizedAdaptor, tt.Adaptor);
end
