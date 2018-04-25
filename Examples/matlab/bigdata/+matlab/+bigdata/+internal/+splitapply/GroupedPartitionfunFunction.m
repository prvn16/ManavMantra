%GroupedPartitionfunFunction
% An object that obeys the feval contract and performs the grouped version
% of the partitionfun call.
%
% This expects to be called within a partitionfun on a partitioned array of
% keys and one or more partitioned array of data. It works by wrapping the
% internal function handle in code that is called once per group, that
% maintains an info struct per group.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) GroupedPartitionfunFunction < handle & matlab.mixin.Copyable
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying FunctionHandle object to be called per group per
        % collection of chunks in partition.
        UnderlyingFunction;
    end
    
    properties (Access = private, Transient)
        % The set of currently known keys.
        Keys;
        
        % A vector of relative indices into the partition for each group.
        RelativeIndices;
        
        % A vector of logicals that specifies whether each group is
        % finished.
        IsGroupFinished;
        
        % A cache of the keyed function handle that wraps
        % UnderlyingFunction and does most of the work.
        GroupedFunction;
    end
    
    methods (Static)
        % Construct a FunctionHandle containing a
        % GroupedPartitionfunFunction from a FunctionHandle. This requires
        % to be given a logical vector of whether each input is expected to
        % have broadcast partitioning.
        function fcn = create(fcnHandle)
            import matlab.bigdata.internal.FunctionHandle;
            import matlab.bigdata.internal.splitapply.GroupedPartitionfunFunction;
            obj = GroupedPartitionfunFunction(fcnHandle);
            fcn = FunctionHandle(obj);
        end
    end
    methods
        %FEVAL Call the function handle. This is expected to be called by a
        %partitionfun that has no knowledge of the fact that groups exist.
        function [isFinished, keys, counts, varargout] = feval(obj, info, keys, counts, varargin)
            if info.IsLastChunk && isempty(keys)
                [isFinished, keys, counts, varargout{1 : nargout - 3}] = fevalEmpty(obj, info, keys, counts, varargin{:});
            else
                [isFinished, keys, counts, varargout{1 : nargout - 3}] = fevalNormal(obj, info, keys, counts, varargin{:});
            end
        end
    end
    
    methods (Access = private)
        % Private constructor for the create method.
        function obj = GroupedPartitionfunFunction(fcnHandle)
            assert(isa(fcnHandle, 'matlab.bigdata.internal.FunctionHandle'), ...
                'Assertion failed: GroupedPartitionfunFunction was given something not a function handle');
            obj.UnderlyingFunction = fcnHandle;
        end
        
        % Implementation of feval when there exists more data.
        function [isFinished, keys, counts, varargout] = fevalNormal(obj, info, keys, counts, varargin)
            import matlab.bigdata.internal.BroadcastArray;
            % This is to ensure we have a full list of keys.
            if iscellstr(keys) %#ok<ISCLSTR>
                keys = string(keys);
            end
            newKeys = unique(keys);
            if isempty(obj.Keys)
                obj.Keys = newKeys;
            else
                obj.Keys = union(obj.Keys, newKeys, 'rows', 'stable');
            end
            obj.IsGroupFinished(end + 1 : size(obj.Keys, 1)) = false;
            obj.RelativeIndices(end + 1 : size(obj.Keys, 1)) = 1;
            
            if isempty(obj.GroupedFunction)
                obj.GroupedFunction = iCreateKeyedPartitionfunHandle(obj.UnderlyingFunction);
            end
            
            % For each key, also pass the index into obj.Keys alongside.
            % This is used later to retrieve partition-wide metadata about
            % the corresponding group.
            [~, keyIndices] = ismember(keys, obj.Keys);
            keyIndices = num2cell(keyIndices);
            % obj is passed in a cell because function_handle is inferior
            % to this class.
            [keys, counts, varargout{1 : nargout - 3}] = feval(...
                obj.GroupedFunction, keys, counts,...
                keyIndices,...
                BroadcastArray(obj), ...
                BroadcastArray(info), ...
                varargin{:});
            
            isFinished = info.IsLastChunk && all(obj.IsGroupFinished);
        end
        
        % Implementation of feval when there does not exist any more data.
        % This simply runs through to discover which groups are not yet
        % finished.
        function [isFinished, keys, counts, varargout] = fevalEmpty(obj, outerInfo, keys, counts, varargin)
            
            fcn = obj.UnderlyingFunction.Handle;
            out = cell(size(obj.Keys, 1), nargout - 3);
            wasGroupFinished = obj.IsGroupFinished;
            for ii = 1:size(obj.Keys, 1)
                if ~wasGroupFinished(ii)
                    info = createInfoStruct(obj, ii, outerInfo);
                    [obj.IsGroupFinished(ii), out{ii, :}] = feval(fcn, info, varargin{:});
                end
            end
            
            varargout = cell(1, size(out, 2));
            for ii = 1:size(out, 2)
                varargout{ii} = vertcat(out{:, ii});
            end
            
            isFinished = outerInfo.IsLastChunk && all(obj.IsGroupFinished);
        end
        
        % Helper function that creates the info struct for one group.
        function info = createInfoStruct(obj, keyIndex, outerInfo)
            info = struct(...
                'PartitionId', outerInfo.PartitionId, ...
                'RelativeIndexInPartition', obj.RelativeIndices(keyIndex), ...
                'IsLastChunk', outerInfo.IsLastChunk);
        end
    end
end

% Wrap a function handle in such a way to get partitionfun per group
% behavior.
function groupedKeyFcn = iCreateKeyedPartitionfunHandle(fcnHandle)
import matlab.bigdata.internal.FunctionHandle;
import  matlab.bigdata.internal.splitapply.GroupedFunction;

underlyingFcnHandle = fcnHandle.Handle;

groupedFcn = FunctionHandle(@fcn, 'MaxNumSlices', fcnHandle.MaxNumSlices, ...
    'ErrorFree', fcnHandle.ErrorFree, 'ErrorStack', fcnHandle.ErrorStack);
groupedKeyFcn = GroupedFunction.wrap(groupedFcn);
groupedKeyFcn = groupedKeyFcn.Handle;

% This function is called once per group. It receives:
%  - keyIndex: The index into obj{1}.Keys that represents the current
%  groups key.
%  - obj: A scalar cell containing the GroupedPartitionfunFunction object.
%  - outerInfo: The info struct passed to GroupedPartitionfunFunction by
%  LazyPartitionedArray/partitionfun.
%  - varargin: The input data associated with the current group.
    function varargout = fcn(keyIndex, obj, outerInfo, varargin)
        obj = obj.Value;
        outerInfo = outerInfo.Value;
        info = obj.createInfoStruct(keyIndex, outerInfo);
        [obj.IsGroupFinished(keyIndex), varargout{1:nargout}] = feval(underlyingFcnHandle, info, varargin{:});
        
        sz = 1;
        for ii = 1:numel(varargin)
            if size(varargin{ii}, 1) ~= 1
                sz = size(varargin{ii}, 1);
                break;
            end
        end
        obj.RelativeIndices(keyIndex) = obj.RelativeIndices(keyIndex) + sz;
    end
end
