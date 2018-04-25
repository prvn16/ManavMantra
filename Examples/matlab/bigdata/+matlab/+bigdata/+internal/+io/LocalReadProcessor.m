%LocalReadProcessor
% Helper class that wraps a datastore-like reader as a Data Processor.
%
% This makes the assumption that the reader will always contain at least
% one chunk.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef LocalReadProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (SetAccess = immutable)
        % The underlying reader implementation.
        Reader;
    end
    
    properties (SetAccess = private)
        % A flag that describes whether any chunks have been read from the
        % datastore.
        HasReadData = false;
        
        % A sample of empty chunk data. This is only available once
        % HasReadData is true.
        EmptyChunk;
    end
    
    methods
        % The main constructor.
        function obj = LocalReadProcessor(reader)
            obj.Reader = reader;
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, ~)
            if obj.IsFinished
                data = obj.EmptyChunk;
                return;
            end
            
            % The underlying data is expected to have at least one chunk,
            % even if that chunk is empty. This is to ensure size, type and
            % metadata info is propagated correctly.
            assert (hasdata(obj.Reader), 'Assertion failed: LocalReadProcessor found no chunks.');
            data = read(obj.Reader);
            
            obj.IsFinished = ~hasdata(obj.Reader);
            if ~obj.HasReadData
                obj.EmptyChunk = matlab.bigdata.internal.util.calculateEmptyChunk(data);
                obj.HasReadData = true;
            end
        end
    end
end
