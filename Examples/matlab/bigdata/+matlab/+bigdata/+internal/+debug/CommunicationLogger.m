%CommunicationLogger
% Logs all communication in the evaluation of a tall array expression.
%
% See matlab.bigdata.internal.debug.logCommunication

%   Copyright 2017 The MathWorks, Inc.

classdef CommunicationLogger < handle
    properties (SetAccess = immutable)
        % Folder to record all trace log entries.
        OutputFolder;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % Listener object for receiving execution events.
        Listener;
    end
    
    methods
        function obj = CommunicationLogger(outputFolder, varargin)
            % Construct a communication logger. This should not be used
            % directly, instead see matlab.bigdata.internal.debug.logCommunication
            import matlab.bigdata.internal.debug.DebugSession;
            p = inputParser;
            p.addParameter('Session', []);
            p.parse(varargin{:});
            results = p.Results;
            
            if ~iIsHdfs(outputFolder) && exist(outputFolder, 'dir') ~= 7
                mkdir(outputFolder);
            end
            obj.OutputFolder = outputFolder;
            
            if isempty(results.Session)
                results.Session = DebugSession.getCurrentDebugSession();
            end
            listener = results.Session.attach();
            listener.ExecuteBeginFcn = @obj.handleExecuteBegin;
            listener.ExecuteEndFcn = @obj.handleExecuteEnd;
            listener.ProcessorCreatedFcn = @obj.handleProcessorCreated;
            listener.ProcessorDestroyedFcn = @obj.handleProcessorDestroyed;
            listener.ProcessReturnFcn = @obj.handleProcessReturn;
            listener.OutputFcn = @obj.handleOutput;
            obj.Listener = listener;
        end
    end
    
    methods (Access = private)
        function handleExecuteBegin(obj, executionId, ~)
            % Handle a ExecuteBegin event, the start of back-end execution.
            
            % This is so that all logging for serial back-end goes to the
            % same log file.
            obj.openLog(executionId);
        end
        
        function handleExecuteEnd(obj, executionId, ~)
            % Handle a ExecuteEnd event, the end of back-end execution.
            obj.closeLog(executionId);
        end

        
        function handleProcessorCreated(obj, processor, ~)
            % Handle a ProcessorCreated event, the construction of a
            % DataProcessor object.
            obj.openLog(processor.ExecutionId);
        end
        
        function handleProcessorDestroyed(obj, processor, ~)
            % Handle a ProcessorDestroyed event, the destruction of a
            % DataProcessor object.
            obj.closeLog(processor.ExecutionId);
        end
        
        function handleProcessReturn(obj, processor, invokeData)
            % Handle a ProcessReturn event, the return of a call to
            % DataProcessor/process.
            import matlab.bigdata.internal.executor.OutputCommunicationType
            
            % Ignore processors that do not generate communication.
            commType = processor.Task.OutputCommunicationType;
            if commType == OutputCommunicationType.Simple
                return;
            end
            
            taskId = string(processor.Task.Id);
            
            sourcePartitionIndex = processor.Partition.PartitionIndex;
            if processor.Task.ExecutionPartitionStrategy.IsBroadcast
                sourcePartitionIndex = 0;
            end
            source = iConvertPartitionIndexToTag(sourcePartitionIndex);
            
            destPartitionIndex = invokeData.OutputPartitionIndices;
            if isempty(destPartitionIndex)
                switch commType
                    case OutputCommunicationType.Broadcast
                        destPartitionIndex = 0;
                    case OutputCommunicationType.AllToOne
                        destPartitionIndex = 1;
                    case OutputCommunicationType.AnyToAny
                        destPartitionIndex = NaN;
                end
            end
            destination = iConvertPartitionIndexToTag(destPartitionIndex);
            
            output = num2cell(invokeData.Output, 2);
            numBytes = cellfun(@iGetSizeInBytes, output);
            
            entry = obj.createLogEntry(taskId, source, destination, numBytes);
            obj.log(processor.ExecutionId, entry);
        end
        
        function handleOutput(obj, outputHandler, outputData)
            % Handle a Output event, a call to the output handlers.
            import matlab.bigdata.internal.executor.OutputCommunicationType
            
            % If the communication type isn't simple, then we've already
            % logged this output as part of a ProcessReturn event.
            task = outputData.Task;
            commType = task.OutputCommunicationType;
            if commType ~= OutputCommunicationType.Simple
                return;
            end
            
            % Broadcast execution partition strategy is done in the client
            % process, so this does not count as communication.
            if task.ExecutionPartitionStrategy.IsBroadcast
                return;
            end
            
            taskId = string(task.Id);
            source = iConvertPartitionIndexToTag(outputData.PartitionIndex);
            destination = "Client";
            
            output = num2cell(outputData.Output, 2);
            numBytes = cellfun(@iGetSizeInBytes, output);
            
            entry = obj.createLogEntry(taskId, source, destination, numBytes);
            obj.log(outputHandler.ExecutionId, entry);
        end
        
        function entry = createLogEntry(~, taskId, source, destination, numBytes)
            % Create a log entry.
            import matlab.bigdata.internal.lazyeval.determineNumSlices;
            numRows = determineNumSlices(taskId, source, destination, numBytes);
            
            time = iScalarExpand(datetime, numRows);
            taskId = iScalarExpand(string(taskId), numRows);
            source = iScalarExpand(string(source), numRows);
            destination = iScalarExpand(string(destination), numRows);
            numBytes = iScalarExpand(numBytes, numRows);
            
            entry = timetable(time, taskId, source, destination, numBytes, ...
                'VariableNames', {'TaskId', 'Source', 'Destination', 'NumBytes'});
        end
        
        function openLog(obj, executionId)
            % Open the log writer for this object. If one is already open,
            % this will simply increment NumProcessors.
            import matlab.bigdata.internal.io.WriteFunction;
            [writeFunction, numReferences, numLogFiles] = iGetSetWriteFunction(executionId);
            if numReferences == 0
                isHdfs = iIsHdfs(obj.OutputFolder);
                workerFolder = sprintf('worker_%5i', feature('getpid'));
                if isHdfs
                    location = strcat(obj.OutputFolder, '/', workerFolder);
                else
                    location = fullfile(obj.OutputFolder, workerFolder);
                    if numLogFiles == 0
                        mkdir(location);
                    end
                end
                
                writeFunction = WriteFunction.createWriteToBinaryFunction(location, isHdfs);
                numLogFiles = numLogFiles + 1;
            end
            numReferences = numReferences + 1;
            iGetSetWriteFunction(executionId, writeFunction, numReferences, numLogFiles);
        end
        
        function log(~, executionId, entry)
            % Write a log entry to the log writer function specified by
            % execution and processor ID.
            [writeFunction, ~, numLogFiles] = iGetSetWriteFunction(executionId);
            info = struct( ...
                'PartitionId', numLogFiles, ...
                'NumPartitions', numLogFiles, ...
                'IsLastChunk', false );
            feval(writeFunction, info, entry);
        end
        
        function closeLog(obj, executionId)
            % Close the log writer for this object. If NumProcessors is
            % more than one, this will simply decrement NumProcessors.
            [writeFunction, numReferences, numLogFiles] = iGetSetWriteFunction(executionId);
            numReferences = numReferences - 1;
            if numReferences == 0
                entry = obj.createLogEntry(string.empty(0, 1), string.empty(0, 1), string.empty(0, 1), zeros(0, 1));
                info = struct( ...
                    'PartitionId', numLogFiles, ...
                    'NumPartitions', numLogFiles, ...
                    'IsLastChunk', true );
                feval(writeFunction, info, entry);
                writeFunction = [];
            end
            iGetSetWriteFunction(executionId, writeFunction, numReferences, numLogFiles);
        end
    end
end

function [writeFunction, numReferences, numLogFiles] ...
    = iGetSetWriteFunction(executionId, writeFunction, numReferences, numLogFiles)
% A process-wide store of WriteFunction objects.
%
% This is required for parallel back-ends, as on workers, one
% CommunicationLogger will be deserialized/created for each
% DataProcessorFactory deserialized. We need a way to ensure
% all CommunicationLogger objects use the same WriteFunction
% for the same execution.
%
% This map will only ever be truly cleared during an explicit
% invocation of clear/clear all.
persistent WRITE_TUPLE_MAP
if isempty(WRITE_TUPLE_MAP)
    WRITE_TUPLE_MAP = containers.Map('KeyType', 'char', 'ValueType', 'any');
end
if nargout
    if isKey(WRITE_TUPLE_MAP, executionId)
        tuple = WRITE_TUPLE_MAP(executionId);
        [writeFunction, numReferences, numLogFiles] = deal(tuple{:});
    else
        [writeFunction, numReferences, numLogFiles] = deal([], 0, 0);
    end
end
if nargin > 1
    tuple = {writeFunction, numReferences, numLogFiles};
    WRITE_TUPLE_MAP(executionId) = tuple;
end
end
function sz = iGetSizeInBytes(data) %#ok<INUSD>
% Get the size of a set of chunks in bytes.
whosData = whos('data');
sz = whosData.bytes;
end

function partitionTag = iConvertPartitionIndexToTag(partitionIndex)
% Convert a partition index into a human readable tag.
partitionTag = "Partition " + partitionIndex;
partitionTag(partitionIndex == 0) = "Broadcast";
end

function x = iScalarExpand(x, numRows)
% Expand input into a column of given number of rows.
assert(iscolumn(x), 'Input to iScalarExpand is not a column.');
if size(x, 1) == 1
    x = repmat(x, numRows, 1);
else
    assert(size(x, 1) == numRows, 'Input to iScalarExpand is neither a scalar or the correct height');
end
end

function tf = iIsHdfs(location)
% Check if the given location is a HDFS location.
tf = startsWith(location, 'hdfs:');
end
