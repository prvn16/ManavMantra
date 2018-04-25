%MapReducerManager
% This class holds the singleton current MapReducer so it does not get
% destroyed on delete. It also has the ability to find the next current
% MapReducer.

%   Copyright 2014-2017 The MathWorks, Inc.

classdef (Sealed) MapReducerManager < handle
    properties (SetAccess = immutable)
        % A flag that is true if and only if the Parallel Computing Toolbox
        % is on the MATLAB path and available.
        IsParallelAvailable;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % A linked list of MapReducerStackNode instances. These hold
        % soft references to all existing MapReducer instances.
        % Note, the first node is a dummy node. The first true stack node is
        % StartOfStackNodes.Next.
        StartOfStackNodes;
    end
    
    properties (Access = private)
        % The current MapReducer to be returned by gcmr.
        % This can be empty or invalid, in which case findNextCurrent should
        % be called.
        Current;
        
        % A cache of the default MapReducer object to be used when a current
        % MapReducer does not exist. This exists for performance reasons
        % and the fact that a MapReducer instance might own caches and so we
        % do not want to recreate the default for every tall array method.
        CachedDefault;
    end
    
    methods (Static)
        % Get the current MapReducerManager for this MATLAB session.
        function obj = getCurrentManager()
            persistent SINGLETON;
            if isempty(SINGLETON)
                SINGLETON = iCreateCurrentManager();
                mlock();
            end
            obj = SINGLETON;
        end
    end
    
    methods
        % Retrieve the current MapReducer instance or empty if one does
        % not exist. This should only be called by gcmr.
        function mr = getCurrent(obj)
            mr = obj.Current;
            if isempty(mr) || ~isvalid(mr) || ~mr.isValidForCurrentMapReducer()
                obj.findNextCurrent();
                mr = obj.Current;
            end
        end
        
        % Set the MapReducer instance to be used for execution by default
        % by mapreduce and tall array. This should be used if the
        % mapreducer should be used as the default mapreducer in the
        % absence of calls to mapreducer/gcmr. The returned value is true
        % if and only if the default has been set.
        function tf = setDefault(obj, mr)
            assert(isempty(obj.getCurrent()), 'Attempted to set current while one already exists');
            if isa(mr, 'matlab.mapreduce.SerialMapReducer')
                % Serial is allowed to be the default environment only if
                % a parallel pool does not exist or auto-open is off.
                tf = ~(obj.IsParallelAvailable && iIsDefaultParallel());
                if tf
                    obj.CachedDefault = mr;
                end
            elseif isa(mr, 'matlab.mapreduce.ParallelMapReducer')
                % Parallel is allowed to be a back-end for mapreduce/tall
                % as the default environment.
                tf = true;
                obj.CachedDefault = mr;
            else
                tf = true;
                obj.setAsFrontOfStack(mr);
            end
        end
        
        % Retrieve the MapReducer instance to be used for execution by
        % default by mapreduce and tall arrays. This will return empty if
        % none exist.
        function mr = getDefault(obj)
            mr = obj.getCurrent();
            if ~isempty(mr)
                return;
            end
            
            mr = obj.CachedDefault;
            if isempty(mr) || ~isvalid(mr) || ~mr.isValidForCurrentMapReducer()
                mr = [];
            end
        end
        
        % Retrieve the MapReducer instance to be used for execution by
        % default by mapreduce and tall arrays. This will create one if
        % none exist.
        function mr = getOrCreateDefault(obj)
            mr = obj.getDefault();
            if isempty(mr)
                mr = iCreateDefaultMapreducer(obj.IsParallelAvailable);
                obj.CachedDefault = mr;
            end
        end
        
        % Invalidate the default mapreducer cache. The next call to
        % getOrCreateDefault will create a new instance if no current
        % mapreducer exists.
        function invalidateDefaultCache(obj)
            obj.CachedDefault = [];
        end
        
        % Bring the given MapReducer instance to the front of the stack. If
        % this mapreducer is visible, this will also have the effect of
        % setting the given MapReducer as the current MapReducer.
        function setAsFrontOfStack(obj, mapReducer)
            mapReducerStackNode = mapReducer.MapReducerStackNode;
            mapReducerStackNode.insertAfter(obj.StartOfStackNodes);
            if mapReducer.isValidForCurrentMapReducer()
                obj.Current = mapReducer;
            end
        end
    end
    
    methods (Hidden)
        % Construct a MapReducerManager. This should not be called
        % directly and is public only for testability purposes.
        function obj = MapReducerManager(isParallelAvailable)
            import matlab.mapreduce.internal.MapReducerStackNode;
            obj.IsParallelAvailable = isParallelAvailable;
            obj.StartOfStackNodes = MapReducerStackNode.hBuildEmptyNode();
        end
    end
    
    methods (Access = private)
        % Find the next current MapReducer if one exists.
        % After this call, the Current property will either be the current
        % MapReducer instance or empty.
        function findNextCurrent(obj)
            node = obj.StartOfStackNodes.Next;
            while ~isempty(node)
                nextMapReducer = get(node.SoftRef);
                if nextMapReducer.isValidForCurrentMapReducer()
                    obj.Current = nextMapReducer;
                    return;
                end
                
                node = node.Next;
            end
            
            obj.Current = [];
        end
    end
end

% Create the current MapReducerManager for this MATLAB session.
function obj = iCreateCurrentManager()
import matlab.mapreduce.internal.MapReducerManager;
isParallelAvailable = iIsParallelAvailable();
obj = MapReducerManager(isParallelAvailable);
if isParallelAvailable
    poolArrayManager = parallel.internal.pool.PoolArrayManager.getCurrentPoolArrayManager();
    addlistener(poolArrayManager, 'PoolAddedEvent', @(~,~) obj.invalidateDefaultCache());
end
end

% Check whether the Parallel Computing Toolbox is on the MATLAB path and
% available.
function isParallelAvailable = iIsParallelAvailable()
isParallelAvailable = license('test', 'distrib_computing_toolbox') ...
    && exist('matlab.mapreduce.ParallelMapReducer', 'class') == 8;
end

% Check whether the default MapReducer will be pool based. This should only
% be called if iIsParallelAvailable() returned true.
function tf = iIsDefaultParallel()
p = gcp('nocreate');
tf = ~isempty(p);
if ~tf
    tf = parallel.internal.bigdata.ParallelPoolExecutor.isAutoCreateEnabled();
end
end

% Create the default mapreducer depending on whether PCT is available and a
% SPMD-enabled pool is available or can be opened.
function obj = iCreateDefaultMapreducer(isParallelAvailable)
p = [];
if isParallelAvailable
    try
        p = gcp;
    catch err
        newErr = MException(message('MATLAB:mapreduceio:mapreducer:InvalidParallelEnvironment'));
        newErr = addCause(newErr, err);
        throw(newErr);
    end
end

if ~isempty(p) && matlab.mapreduce.ParallelMapReducer.isPoolSupported(p)
    obj = matlab.mapreduce.ParallelMapReducer(p);
else
    obj = matlab.mapreduce.SerialMapReducer;
end
end
