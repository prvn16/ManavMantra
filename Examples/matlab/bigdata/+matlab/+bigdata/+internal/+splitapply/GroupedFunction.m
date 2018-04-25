%GroupedFunction
% Function that applies an action once per group per chunk. The input is
% expected to already be split into groups.

% Copyright 2016-2017 The MathWorks, Inc.

classdef GroupedFunction < handle & matlab.mixin.Copyable
    properties (SetAccess = immutable)
        % Underlying function handle.
        Handle
        
        % Logical scalar flag that specifies if single slice per group
        % output should be wrapped as a GroupedBroadcast.
        WrapSingletonOutputAsBroadcast;
    end
    
    methods (Static)
        function functionHandle = wrap(functionHandle, varargin)
            % Wrap a FunctionHandle with the logic to invoke over groups of
            % data.
            %
            % Syntax:
            %   keyedFcn = GroupedFunction.wrap(fcnHandle, name1, value1, ..)
            %
            % Where the optional name-value parameters consist of:
            %
            %  WrapSingletonOutputAsBroadcast: A flag that specifies if the output
            %  should be wrapped as a GroupedBroadcast if it is detected that all
            %  output per group is a scalar. This is false by default.
            import matlab.bigdata.internal.splitapply.GroupedFunction;
            functionHandle = functionHandle.copyWithNewHandle(...
                GroupedFunction(functionHandle.Handle, varargin{:}));
        end
    end
    
    methods
        function [groupKeys, groupCounts, varargout] = feval(obj, groupKeys, groupCounts, varargin)
            % Apply the grouped action to the given groups of inputs.
            import matlab.bigdata.internal.splitapply.GroupedBroadcast;
            import matlab.bigdata.internal.util.validateSameOutputHeight;
            if isempty(groupKeys)
                % In the case of no groups, we simply return an empty chunk.
                varargout = repmat({cell(0, 1)}, 1, nargout - 2);
                return;
            end
            
            % If the keys are a GroupedBroadcast, the entire input is the
            % output of a reduce to single row per group. For example,
            % splitapply(@(x) sin(sum(x,1)),tX,tG) would generate a single
            % row per group output from sum(x,1). This input, both its data
            % and its keys, will be put into a GroupedBroadcast state. The
            % sin elementfun will hit the below if statement.
            areKeysFromBroadcast = isa(groupKeys, 'matlab.bigdata.internal.splitapply.GroupedBroadcast');
            if areKeysFromBroadcast
                groupKeys = groupKeys.Keys;
            end
            
            % Broadcasts originate from scalars in the splitapply function
            % handle. For example, the value 42 in:
            % splitapply(@(x) {x + 42},tX,tG)
            isInputNormalBroadcast  = cellfun(@(x) isa(x, 'matlab.bigdata.internal.BroadcastArray'), varargin);
            % Grouped Broadcasts originate from reductions of each group to
            % a single slice per group. For example, the inner mean of:
            % splitapply(@(x) mean(x - mean(x)),tX,tG)
            isInputGroupedBroadcast = cellfun(@(x) isa(x, 'matlab.bigdata.internal.splitapply.GroupedBroadcast'), varargin);
            
            % If the input consists of the vertical concatenation of two
            % chunks, it will contain the same group key multiple times. We
            % need to fuse those groups together. This is typical in most
            % reductions, e.g. splitapply(@(x) sum(x,1),tX,tG).
            [groupKeys, ~, keyIndices] = unique(groupKeys);
            if numel(keyIndices) ~= numel(groupKeys) || ~issorted(keyIndices)
                for idx = find(~isInputGroupedBroadcast & ~isInputNormalBroadcast)
                    varargin{idx} = splitapply(@iMergeCells, varargin{idx}, keyIndices);
                end
            end
            
            % Each GroupedBroadcast contains values for all known groups
            % across the tall array. We need to extract the ones that match
            % the groups that exist in this chunk. Note, this is not a
            % direct indexing operation, as 0 can also be a key. This 0 key
            % corresponds to NaN GNUM values.
            if any(isInputGroupedBroadcast)
                for idx = find(isInputGroupedBroadcast)
                    [existsInBroadcast, keyIndices] = ismember(groupKeys, varargin{idx}.Keys);
                    assert(all(existsInBroadcast), ...
                        'Assertion failed: Received GroupedBroadcast is not complete.');
                    varargin{idx} = varargin{idx}.Values(keyIndices);
                end
            end
            
            groupCounts = zeros(size(groupKeys));
            varargout = cell(size(groupKeys,1), nargout - 2);
            for ii = 1:size(groupKeys, 1)
                % We need to pull out all of the input slices associated with
                % the current unique key. If a given input consists of a single
                % slice, this will be associated with all keys.
                inputs = cell(1, numel(varargin));
                for jj = 1:numel(inputs)
                    if isInputNormalBroadcast(jj)
                        inputs{jj} = varargin{jj};
                    else
                        inputs{jj} = varargin{jj}{ii};
                    end
                end
                
                [varargout{ii, :}] = feval(obj.Handle, inputs{:});
                groupCounts(ii) = validateSameOutputHeight(varargout{ii, :});
            end
            varargout = num2cell(varargout, 1);
            
            % In this case, there is exactly one slice per group.
            if (areKeysFromBroadcast || obj.WrapSingletonOutputAsBroadcast) && all(groupCounts == 1)
                for ii = 1:numel(varargout)
                    varargout{ii} = GroupedBroadcast(groupKeys, varargout{ii});
                end
                groupCounts = GroupedBroadcast(groupKeys, num2cell(groupCounts));
                groupKeys = GroupedBroadcast(groupKeys, num2cell(groupKeys));
            end
        end
    end
    
    methods (Access = private)
        function obj = GroupedFunction(handle, varargin)
            % Private constructor for the wrap method.
            import matlab.bigdata.internal.FunctionHandle;
            
            p = inputParser;
            p.addParameter('WrapSingletonOutputAsBroadcast', false, @(x) islogical(x) && isscalar(x));
            p.parse(varargin{:});
            
            obj.Handle = handle;
            obj.WrapSingletonOutputAsBroadcast = p.Results.WrapSingletonOutputAsBroadcast;
        end
    end
    
    methods (Access = protected)
        function obj = copyElement(obj)
            % Perform a deep copy of this object and everything underlying
            % it.
            import matlab.bigdata.internal.splitapply.GroupedFunction
            if isa(obj.Handle, 'matlab.mixin.Copyable')
                obj = GroupedFunction(copy(obj.Handle), ...
                    'WrapSingletonOutputAsBroadcast', obj.WrapSingletonOutputAsBroadcast);
            end
        end
    end
end

function x = iMergeCells(x)
% Merge a vector of cells together, emitting a single cell containing all
% of the data.
import matlab.bigdata.internal.util.vertcatCellContents;
x = {vertcatCellContents(x)};
end
