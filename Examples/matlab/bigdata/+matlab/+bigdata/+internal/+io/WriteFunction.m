classdef WriteFunction < handle & matlab.mixin.Copyable
%WRITEFUNCTION A function object to support writing partitioned tall chunks.
%   This function object is used by write method of tall. This writes
%   either to MAT-files or to Sequence Files in Hadoop.
%
%   See also datastore, tall, mapreduce.

%   Copyright 2016 The MathWorks, Inc.

    properties (SetAccess = immutable)
        % A function handle of the form writer = fcn(partitionIndex);
        WriterFactory;
    end

    properties (SetAccess = private, Transient)
        % Internal writer object to write tall arrays.
        Writer;
    end

    methods
        % Constructor for this object
        function obj = WriteFunction(writerFactory)
            obj.WriterFactory = writerFactory;
        end

        % feval needed for FunctionHandle
        %
        % isFinished - is true when the input is the last chunk.
        %              until then keep writing to the same internal writer.
        % emptyOut   - always empty []
        %              At least one output is needed other than isFinished
        %              emptyOut is just to fullfill FunctionHandle api 
        function [isFinished, emptyOut] = feval(obj, info, input)
            isFinished = info.IsLastChunk;

            if isempty(obj.Writer) || ~isvalid(obj.Writer)
                % invoke either iCreateSequenceFileWriter or iCreateMatFileWriter
                obj.Writer = feval(obj.WriterFactory, info.PartitionId, info.NumPartitions);
            end
            obj.Writer.add(input);

            if isFinished
                obj.Writer.commit();
                delete(obj.Writer);
            end
            emptyOut = [];
        end
    end

    methods (Static)
        % A static method to create WriteFunction object. 
        % This creates a function handle that is invoked once per partition
        function writeFunction = createWriteToBinaryFunction(location, isHdfs)
            import matlab.bigdata.internal.io.WriteFunction;

            maxChunkSizeInBytes = matlab.bigdata.internal.io.ChunkedWriter.maxChunkSize();
            if isHdfs
                fh = @(partitionIndex, numPartitions) iCreateSequenceFileWriter(partitionIndex, numPartitions, location, maxChunkSizeInBytes);
                
            else
                fh = @(partitionIndex, numPartitions) iCreateMatFileWriter(partitionIndex, numPartitions, location, maxChunkSizeInBytes);
            end
            writeFunction = WriteFunction(fh);
        end
    end
end

% Create a writer for Sequence File writing 
function outputWriter = iCreateSequenceFileWriter(partitionIndex, numPartitions, location, maxChunkSizeInBytes)
    outputWriter = matlab.bigdata.internal.io.SequenceFileArrayWriter(partitionIndex, numPartitions, location);
    outputWriter = matlab.bigdata.internal.io.ChunkedWriter(outputWriter, maxChunkSizeInBytes);
end

% Create a writer for MAT-File writing 
function outputWriter = iCreateMatFileWriter(partitionIndex, numPartitions, location, maxChunkSizeInBytes)
    outputWriter = matlab.bigdata.internal.io.MatArrayWriter(partitionIndex, numPartitions, location, '');
    outputWriter = matlab.bigdata.internal.io.ChunkedWriter(outputWriter, maxChunkSizeInBytes);
end
