%StreamingOutputHandler
% An output handler that simply passes all chunks of one output to an
% underlying function handle.

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) StreamingOutputHandler < matlab.bigdata.internal.executor.OutputHandler
    properties (SetAccess = immutable)
        % A logical scalar that is true if and only if this output handler
        % benefits from streaming.
        IsStreamingHandler = true;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The task ID of the one output task that this StreamingOutputHandler
        % will handle.
        OutputTaskId;
        
        % The index into the outputs of the one output task that this
        % StreamingOutputHandler will handle.
        OutputArgoutIndex;
        
        % Function handle to be called each time a chunk of an output
        % arrives.
        %
        % This must have signature:
        %   function fcn(taskId, argoutIndex, info, chunk)
        % Where:
        %   - taskId is the ID string of the corresponding task being
        %   outputted.
        %   - argoutIndex is the index into varargout of this task.
        %   - info is a struct with properties:
        %     - PartitionIndex is the index of the partition that this
        %     chunk originates from. It is a scalar in the range
        %     1:NumPartitions.
        %     - NumPartitions is the number of partitions of this output.
        %     - IsLastChunk is a logical scalar that is true if and only if
        %     this is the last chunk of the corresponding partition.
        %     - CompletedPartitions is a logical vector, each element is
        %     true if and only if the corresponding partition has no more
        %     data.
        %   - chunk is one chunk of output corresponding to
        %   info.PartitionIndex, taskId and argoutIndex.
        HandlerFcn;
    end
    
    properties (Access = private)
        % Logical vector, each element is true if and only if the
        % corresponding partition has no more data.
        CompletedPartitions;
    end
    
    methods
        function obj = StreamingOutputHandler(taskId, outputIndex, handlerFcn)
            % Construct an output handler with the given default handler
            % function handle.
            obj.OutputTaskId = taskId;
            obj.OutputArgoutIndex = outputIndex;
            obj.HandlerFcn = handlerFcn;
        end
    end
    
    % Methods overridden in the OutputHandler interface.
    methods (Access = protected)
        % Handle one set of chunks for the output of index outputIndex
        % of task corresponding to taskId.
        function [isHandled, cancel] = doHandle(obj, taskId, outputIndex, info, data)
            % Handle a chunk of data corresponding to the output of given
            % taskId and argoutIndex.
            
            % StreamingOutputHandler only will handle the one output that
            % matches the identity information given at construction.
            isHandled = (outputIndex == obj.OutputArgoutIndex) ...
                && strcmp(taskId, obj.OutputTaskId);
            if ~isHandled
                isHandled = false;
                cancel = false;
                return;
            end
            
            if isempty(obj.CompletedPartitions)
                obj.CompletedPartitions = false(1, info.NumPartitions);
            end
            
            info.CompletedPartitions = obj.CompletedPartitions;
            isFinished = feval(obj.HandlerFcn, taskId, outputIndex, info, data);
            if info.IsLastChunk
                obj.CompletedPartitions(info.PartitionIndex) = true;
            end
            
            cancel = isFinished && ~all(obj.CompletedPartitions);
        end
    end
end
