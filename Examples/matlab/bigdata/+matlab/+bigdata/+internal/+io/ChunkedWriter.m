%CHUNKEDWRITER A writer that chunks the input according to a maximum size in bytes.
%
% This exists as MAT/Sequence file writers put each chunk into a cell. A
% future worker can only read one cell at a minimum. In order to ensure a
% future worker can read part of the data, we chunk the input by size in
% bytes.

%   Copyright 2016 The MathWorks, Inc.

classdef ChunkedWriter < matlab.bigdata.internal.io.Writer & matlab.mixin.Copyable
    
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying writer that will place the data to disk.
        UnderlyingWriter;
        
        % The maximum chunk size in bytes for each chunk.
        MaxChunkSizeInBytes;
    end
    
    properties (Constant)
        % The default maximum size in bytes for each written chunk.
        DEFAULT_MAX_SIZE_IN_BYTES = 1024 ^ 2;
    end
    
    methods
        function obj = ChunkedWriter(underlyingWriter, maxChunkSizeInBytes)
            obj.UnderlyingWriter = underlyingWriter;
            if ~nargin
                maxChunkSizeInBytes = obj.maxChunkSize();
            end
            obj.MaxChunkSizeInBytes = maxChunkSizeInBytes;
        end
        
        %ADD Add the provided input to the underlying storage in chunked form
        function add(obj, value)
            import matlab.bigdata.internal.util.indexSlices
            numSlices = size(value, 1);
            numBytes = iGetNumBytes(value);
            if numSlices <= 1 || numBytes <= obj.MaxChunkSizeInBytes
                obj.UnderlyingWriter.add(value);
                return;
            end
            
            numSlicesPerChunk = ceil(obj.MaxChunkSizeInBytes / numBytes * numSlices);
            for startIndex = 1 : numSlicesPerChunk : numSlices
                endIndex = min(startIndex + numSlicesPerChunk - 1, numSlices);
                obj.UnderlyingWriter.add(indexSlices(value, startIndex : endIndex));
            end
        end
        
        %COMMIT Perform final commit actions.
        function commit(obj)
            obj.UnderlyingWriter.commit();
        end
    end
    
    methods (Static)
        function out = maxChunkSize(in)
            % The maximum size in bytes for each written chunk.
            
            import matlab.bigdata.internal.io.ChunkedWriter;
            persistent value;
            if isempty(value)
                value = ChunkedWriter.DEFAULT_MAX_SIZE_IN_BYTES;
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
    end
end

function sz = iGetNumBytes(in) %#ok<INUSD>
% Retrieve the size in bytes of a given array using whos
narginchk(1,1);
whosData = whos('in');
sz = whosData.bytes;
end
