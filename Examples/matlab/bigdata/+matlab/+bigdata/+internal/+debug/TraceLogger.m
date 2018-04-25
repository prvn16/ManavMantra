%TraceLogger
% Implementation of trace-level logging of tall array execution using the
% debug annotations.
%
% This support parallel back-ends. It creates a TallDatastore writer for
% each processor to the given location and fills this with a table of a
% specific form.

%   Copyright 2017 The MathWorks, Inc.

classdef TraceLogger < handle
    properties (SetAccess = immutable)
        % Folder to record all trace log entries.
        OutputFolder;
        
        % Enumeration that specifies how much of the inputs/outputs should
        % be inserted into the logs. This can be 'All', 'Slice' or 'None'.
        KeepData;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % Listener object for receiving execution events.
        Listener;
    end
    
    properties (Access = private, Transient)
        % A function handle that will emit all log results for a processor.
        % This is local to a single process.
        WriteFunctionMap;
    end
    
    methods
        function obj = TraceLogger(outputFolder, varargin)
            % Construct a trace logger. This should not be used directly,
            % instead see matlab.bigdata.internal.debug.trace.
            import matlab.bigdata.internal.debug.DebugSession;
            p = inputParser;
            p.addParameter('Session', []);
            p.addParameter('KeepData', 'Slice', @(x) validatestring(x, {'All', 'Slice', 'None'}));
            p.parse(varargin{:});
            results = p.Results;
            
            assert(exist(outputFolder, 'file') == 0, 'Location ''%s'' already exists.', outputFolder);
            mkdir(outputFolder);
            obj.OutputFolder = outputFolder;
            
            obj.KeepData = results.KeepData;
            if isempty(results.Session)
                results.Session = DebugSession.getCurrentDebugSession();
            end
            listener = results.Session.attach();
            listener.ExecuteBeginFcn = @obj.handleExecuteBegin;
            listener.ExecuteEndFcn = @obj.handleExecuteEnd;
            listener.ProcessorCreatedFcn = @obj.handleProcessorCreated;
            listener.ProcessorDestroyedFcn = @obj.handleProcessorDestroyed;
            listener.ProcessBeginFcn = @obj.handleProcessBegin;
            listener.ProcessErrorFcn = @obj.handleProcessError;
            listener.ProcessReturnFcn = @obj.handleProcessReturn;
            obj.Listener = listener;
        end
        
        function writeFunctionMap = get.WriteFunctionMap(obj)
            % Lazy construction of property as copies of an object can be
            % sent to MATLAB Workers.
            if isempty(obj.WriteFunctionMap)
                obj.WriteFunctionMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            end
            writeFunctionMap = obj.WriteFunctionMap;
        end
    end
    
    methods (Access = private)
        function handleExecuteBegin(obj, executionId, taskGraph)
            % Handle a ExecuteTriggered event.
            entry = obj.createEmptyLogEntry('ExecutionTriggered');
            entry.ExecutionId = string(executionId);
            entry.TaskGraphObject = {taskGraph};
            
            obj.openLog(executionId, 'taskGraph', 1, 1);
            try
                obj.log(executionId, 'taskGraph', entry);
            catch err
                obj.forceCloseAllLogs();
                rethrow(err);
            end
            obj.closeLog(executionId, 'taskGraph');
        end
        
        function handleExecuteEnd(obj, ~, ~)
            % Handle a ExecuteEnd event.
            obj.forceCloseAllLogs();
        end
        
        function handleProcessorCreated(obj, processor, ~)
            % Handle a ProcessorCreated event.
            obj.openLog(processor.ExecutionId, processor.Id, processor.Partition.PartitionIndex, processor.Partition.NumPartitions);
            entry = obj.createEmptyLogEntry('ProcessorCreated');
            entry = obj.fillProcessorInfo(entry, processor);
            obj.log(processor.ExecutionId, processor.Id, entry);
        end
        
        function handleProcessorDestroyed(obj, processor, ~)
            % Handle a ProcessorDestroyed event.
            entry = obj.createEmptyLogEntry('ProcessorDestroyed');
            entry = obj.fillProcessorInfo(entry, processor);
            obj.log(processor.ExecutionId, processor.Id, entry);
            obj.closeLog(processor.ExecutionId, processor.Id);
        end
        
        function handleProcessBegin(obj, processor, invokeData)
            % Handle a ProcessBegin event.
            entry = obj.createEmptyLogEntry('ProcessBegin');
            entry = obj.fillProcessorInfo(entry, processor);
            entry = obj.fillProcessInvokeInfo(entry, invokeData);
            obj.log(processor.ExecutionId, processor.Id, entry);
        end
        
        function handleProcessError(obj, processor, invokeData)
            % Handle a ProcessError event.
            entry = obj.createEmptyLogEntry('ProcessError');
            entry = obj.fillProcessorInfo(entry, processor);
            entry = obj.fillProcessInvokeInfo(entry, invokeData);
            obj.log(processor.ExecutionId, processor.Id, entry);
        end
        
        function handleProcessReturn(obj, processor, invokeData)
            % Handle a ProcessReturn event.
            entry = obj.createEmptyLogEntry('ProcessReturn');
            entry = obj.fillProcessorInfo(entry, processor);
            entry = obj.fillProcessInvokeInfo(entry, invokeData);
            obj.log(processor.ExecutionId, processor.Id, entry);
        end
        
        function entry = fillProcessorInfo(~, entry, processor)
            % Fill a log entry with all details specific to a processor.
            entry.ExecutionId = string(processor.ExecutionId);
            entry.TaskId = string(processor.Task.Id);
            entry.ProcessorId = string(processor.Id);
            entry.PartitionIndex = processor.Partition.PartitionIndex;
            entry.NumPartitions = processor.Partition.NumPartitions;
            entry.IsFinished = processor.IsFinished;
            entry.IsMoreInputRequired = {processor.IsMoreInputRequired};
        end
        
        function entry = fillProcessInvokeInfo(obj, entry, invokeData)
            % Fill a log entry with all details specific to one
            % DataProcessor/process invocations.
            entry.InvokeIndex = invokeData.InvokeIndex;
            entry.IsLastChunk = {invokeData.IsLastChunk};
            entry.InputChunkHeights = {cellfun(@iGetChunkHeight, invokeData.Inputs, 'UniformOutput', false)};
            if obj.KeepData == "All"
                entry.Inputs = {invokeData.Inputs};
            elseif obj.KeepData == "Slice"
                entry.Inputs = {cellfun(@iGetChunkSlice, invokeData.Inputs, 'UniformOutput', false)};
            else
                entry.Inputs = {cellfun(@iGetChunkEmpty, invokeData.Inputs, 'UniformOutput', false)};
            end
            
            if ~isempty(invokeData.Output)
                entry.OutputChunkHeights = iGetChunkHeight(invokeData.Output);
                if obj.KeepData == "All"
                    entry.Output = {invokeData.Output};
                elseif obj.KeepData == "Slice"
                    entry.Output = {iGetChunkSlice(invokeData.Output)};
                else
                    entry.Output = iGetChunkEmpty(invokeData.Output);
                end
            end
            
            if ~isempty(invokeData.Error)
                entry.ErrorId = string(invokeData.Error.identifier);
                entry.ErrorReport = string(invokeData.Error.getReport());
            end
        end
        
        function entry = createEmptyLogEntry(~, entryType)
            % Create an empty log entry.
            persistent emptyEntryCache
            if isempty(emptyEntryCache)
                emptyEntryCache = timetable(datetime(missing));
                
                emptyEntryCache.EntryType = string(missing);
                emptyEntryCache.WorkerPid = feature('getpid');
                emptyEntryCache.ExecutionId = string(missing);
                emptyEntryCache.TaskId = string(missing);
                
                emptyEntryCache.ProcessorId = string(missing);
                emptyEntryCache.PartitionIndex = NaN;
                emptyEntryCache.NumPartitions = NaN;
                
                emptyEntryCache.TaskGraphObject = {[]};
                
                emptyEntryCache.InvokeIndex = NaN;
                emptyEntryCache.IsFinished = false;
                emptyEntryCache.IsMoreInputRequired = {logical([])};
                
                emptyEntryCache.IsLastChunk = {logical([])};
                emptyEntryCache.Inputs = {{}};
                emptyEntryCache.InputChunkHeights = {{}};
                emptyEntryCache.Output = {[]};
                emptyEntryCache.OutputChunkHeights = {[]};
                
                emptyEntryCache.ErrorId = string(missing);
                emptyEntryCache.ErrorReport = string(missing);
            end
            entry = emptyEntryCache;
            entry.Time = datetime;
            entry.EntryType = string(entryType);
        end
        
        function openLog(obj, executionId, processorId, partitionIndex, numPartitions)
            % Open a log writer for the specific combination of execution
            % and processor ID.
            import matlab.bigdata.internal.io.WriteFunction;
            location = fullfile(obj.OutputFolder, executionId, processorId);
            if exist(location, 'dir') ~= 7
                mkdir(location);
            end
            obj.WriteFunctionMap(processorId) = ...
                {WriteFunction.createWriteToBinaryFunction(location, false), ...
                partitionIndex, ...
                numPartitions};
        end
        
        function log(obj, ~, processorId, entry)
            % Write a log entry to the log writer function specified by
            % execution and processor ID.
            writeFcnTuple = obj.WriteFunctionMap(processorId);
            info = struct( ...
                'PartitionId', writeFcnTuple{2}, ...
                'NumPartitions', writeFcnTuple{3}, ...
                'IsLastChunk', false );
            feval(writeFcnTuple{1}, info, entry);
        end
        
        function closeLog(obj, ~, processorId)
            % Close the log writer for the specific combination of execution
            % and processor ID.
            writeFcnTuple = obj.WriteFunctionMap(processorId);
            entry = obj.createEmptyLogEntry('');
            entry = entry([], :);
            info = struct( ...
                'PartitionId', writeFcnTuple{2}, ...
                'NumPartitions', writeFcnTuple{3}, ...
                'IsLastChunk', true );
            feval(writeFcnTuple{1}, info, entry);
            remove(obj.WriteFunctionMap, processorId);
        end
        
        function forceCloseAllLogs(obj)
            % Close all log writers owned by this object.
            obj.WriteFunctionMap = [];
        end
    end
end

function heights = iGetChunkHeight(chunks)
% Get the height of each chunk in a cell array of chunks.
heights = cellfun(@(x) size(x, 1), chunks);
end

function slices = iGetChunkSlice(chunks)
% Get a single slice for each chunk for a cell array of chunks.
import matlab.bigdata.internal.util.indexSlices;
slices = cellfun(@(x) indexSlices(x, 1 : min(size(x,1), 1)), chunks, 'UniformOutput', false);
end
function emptyChunks = iGetChunkEmpty(chunks)
% Get an empty chunk for each chunk in a cell array of chunks.
import matlab.bigdata.internal.util.indexSlices;
emptyChunks = cellfun(@(x) indexSlices(x, []), chunks, 'UniformOutput', false);
end
