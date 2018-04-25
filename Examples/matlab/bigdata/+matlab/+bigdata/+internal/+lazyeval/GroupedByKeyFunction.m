%GroupedByKeyFunction
% Function that applies an action to groups of data, where the grouping is
% defined by a key variable input. Unlike the splitapply version, this
% supports keys of any type as well as type/size propagation of empties.

%   Copyright 2017 The MathWorks, Inc.

classdef GroupedByKeyFunction < handle & matlab.mixin.Copyable
    properties (SetAccess = immutable)
        % Underlying function handle that will be invoked on each group
        % within each chunk.
        Handle
    end
    
    methods (Static)
        function functionHandle = wrap(functionHandle)
            % Wrap the given FunctionHandle object in a
            % GroupedByKeyFunction. The underlying handle will be invoked
            % once per group.
            import matlab.bigdata.internal.lazyeval.GroupedByKeyFunction;
            
            functionHandle = functionHandle.copyWithNewHandle(...
                GroupedByKeyFunction(functionHandle.Handle));
        end
    end
    
    methods
        function varargout = feval(obj, keys, varargin)
            % Apply function to the given chunk of inputs.
            import matlab.bigdata.internal.util.indexSlices;
            import matlab.bigdata.internal.util.splitSlices;
            import matlab.bigdata.internal.util.validateSameOutputHeight;
            % If no keys, assume no groups and attempt to forward
            % propagate size and type only.
            if isempty(keys)
                [varargout{1:nargout - 1}] = feval(obj.Handle, varargin{:});
                varargout = [{keys}, varargout];
                for ii = 1:numel(varargout)
                    varargout{ii} = indexSlices(varargout{ii}, []);
                end
                return;
            end
            
            % The function handle will be called once for each unique key in
            % the chunk, with all of the data associated with that unique key.
            [uniqueKeys, idx] = iGetGroups(keys);
            
            for ii = 1 : numel(varargin)
                varargin{ii} = splitSlices(varargin{ii}, idx);
            end
            varargin = [varargin{:}];
            
            out = cell(size(uniqueKeys, 1), nargout);
            for ii = 1:size(uniqueKeys, 1)
                [out{ii, 2:end}] = feval(obj.Handle, varargin{ii, :});
                height = validateSameOutputHeight(out{ii, 2:end});
                out{ii, 1} = repmat(uniqueKeys(ii, :), height, 1);
            end
            
            varargout = cell(1, nargout);
            for ii = 1:nargout
                varargout{ii} = vertcat(out{:, ii});
            end
        end
    end
    
    methods (Access = protected)
        function obj = copyElement(obj)
            % Perform a deep copy of this object and everything
            % underlying it.
            import matlab.bigdata.internal.lazyeval.GroupedByKeyFunction;
            if isa(obj.Handle, 'matlab.mixin.Copyable')
                obj = GroupedByKeyFunction(copy(obj.Handle));
            end
        end
    end
    
    methods (Access = private)
        function obj = GroupedByKeyFunction(handle)
            % Private constructor.
            obj.Handle = handle;
        end
    end
end


% Helper function to get the unique group keys and an array of indices from
% the original array into groups.
function [groupKey, indices] = iGetGroups(keys)

isKeysCellstr = iscellstr(keys); %#ok<ISCLSTR>
if isKeysCellstr
    keys = string(keys);
end

if iscolumn(keys)
    [groupKey, ~, indices] = unique(keys);
else
    [groupKey, ~, indices] = unique(keys, 'rows');
end

groupKey(iIsNotAKey(groupKey)) = [];
indices(iIsNotAKey(keys)) = [];
if isKeysCellstr
    groupKey = cellstr(groupKey);
end

end

% Helper function that for each slice of keys, returns true if that row
% contains any missing (or NaN/NaT/undefined) values.
function tfArray = iIsNotAKey(keys)
if ischar(keys)
    tfArray = false(size(keys, 1), 1);
else
    tfArray = any(ismissing(keys(:, :)), 2);
end
end
