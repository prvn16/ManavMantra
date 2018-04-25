%LocalWriteProcessor
% Helper class that wraps a writer as a Data Processor.
%
% This will always write at least one chunk of input data.
%

%   Copyright 2015-2016 The MathWorks, Inc.

classdef LocalWriteProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = true;
    end
    
    properties (SetAccess = immutable)
        % The underlying writer implementation.
        Writer;
    end
    
    properties (SetAccess = private)
        % A flag that is true if and only if data has been written.
        HasWrittenData = false;
    end
    
    methods
        function obj = LocalWriteProcessor(writer)
            obj.Writer = writer;
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfInput, data, partitionIndices)
            if obj.IsFinished
                return;
            end
            
            if nargin < 4
                partitionIndices = [];
            end
            
            % We ignore empty input unless we have written no chunks and
            % this is the last of the input. This is so the corresponding
            % LocalReadProcessor always has at least one chunk.
            if size(data, 1) > 0 || isLastOfInput && ~obj.HasWrittenData
                add(obj.Writer, partitionIndices, data);
                obj.HasWrittenData = true;
            end
            
            if isLastOfInput
                commit(obj.Writer);
                obj.IsFinished = true;
            end
        end
    end
end
