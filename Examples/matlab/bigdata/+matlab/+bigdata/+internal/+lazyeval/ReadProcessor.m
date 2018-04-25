%ReadProcessor
% Data Processor that reads a chunk from the datastore on each iteration.
%
% See LazyTaskGraph for a general description of input and outputs.
% Specifically, each iteration will emit a 1 x 1 cell array containing a
% chunk of data read from the internally held datastore.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) ReadProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = false(0, 1);
    end
    
    properties (SetAccess = immutable)
        % The underlying datastore consisting of all the data represented
        % by the current partition.
        Datastore;
        
        % A flag that is true if and only if each read must be wrapped in a
        % cell.
        RequiresCells;
        
        % A chunk of output from the datastore that has size zero in the
        % tall dimension. This exists to handle the case when a partition
        % contains no data, the framework makes the guarantee that it will
        % pass forward a correctly sized empty.
        EmptyChunk;
        
        % A cell array of the class and size information of EmptyChunk. This
        % is the cached output of calling iRecursiveGetMetaInfo on EmptyChunk.
        EmptyChunkMetaInfo;
        
        % The chunk size to emit from this processor. This can be NaN,
        % which indicates to use the raw Datastore reads as the chunk size.
        ChunkSize = NaN;
        
        % A buffer for building up the output chunk. This is non-empty and
        % used if and only if ChunkSize is not NaN.
        OutputBuffer;
        
        % Function handle that is called to read a chunk of data from the
        % underlying datastore
        ReadChunkFcn;
    end
    
    properties (SetAccess = private)
        % A logical scalar that is true if and only if there has been at
        % least one call to the process method.
        HasEmittedFirstChunk = false;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        %
        % Inputs:
        %  - originalDatastore is the corresponding datastore instance that
        %  this processor will read. It is used here to generate an empty
        %  chunk.
        function factory = createFactory(originalDatastore)
            previewChunk = iPreview(originalDatastore);

            % Below subsref/substruct calculates a generic empty chunk for a table,i
            % an array or a cell. It works for TallDatastore.
            if matlab.io.datastore.internal.shim.isUniformRead(originalDatastore)
                emptyChunk = matlab.bigdata.internal.util.indexSlices(previewChunk, []);
            else
                emptyChunk = cell(0, 1);
            end
            
            factory = @createReadProcessor;
            function dataProcessor = createReadProcessor(partition)
                import matlab.bigdata.internal.lazyeval.ReadProcessor;
                
                try
                    partitionedDatastore = partition.createDatastore();
                catch err
                    matlab.bigdata.internal.throw(err);
                end
                dataProcessor = ReadProcessor(partitionedDatastore, emptyChunk);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, ~)
            %PROCESS Perform the next iteration of processing
            
            % If we already know we're done, just return nothing.
            if obj.IsFinished
                data = cell(0, 1);
                return;
            end
            
            % This object emits an empty cell on the very first call
            % to process because of caching and CompositeDataProcessor.
            % There are cases where a CompositeDataProcessor owns a
            % ReadProcessor but due to caching, no data is required
            % from the datastore. However, CompositeDataProcessor
            % requires to call the process method of all underlying
            % processors at least once. For this reason, we avoid
            % calling datastore read method until the second call to
            % process, when we know the data will be used.
            if ~obj.HasEmittedFirstChunk
                data = cell(0, 1);
                obj.HasEmittedFirstChunk = true;
                return;
            end
            
            % If the datastore starts with no data, we emit an empty chunk
            % because we are required to emit at least one chunk before
            % IsFinished can be set to true. We should only hit this if the
            % partition was empty, otherwise IsFinished will have been set
            % on the previous call to read.
            if ~iHasdata(obj.Datastore) && obj.OutputBuffer.NumBufferedSlices == 0
                data = {obj.EmptyChunk};
                obj.IsFinished = true;
                return;
            end
            
            % Read some data and see if we are done.
            if isnan(obj.ChunkSize)
                data = { obj.ReadChunkFcn() };
            else
                % We do not special case the instance where datastore/read
                % emits a chunk of size exactly ChunkSize because the
                % performance loss of going through the buffer is
                % negligible compared against the IO.
                while obj.OutputBuffer.NumBufferedSlices < obj.ChunkSize && hasdata(obj.Datastore)
                    obj.OutputBuffer.add(false, { obj.ReadChunkFcn() });
                end
                data = obj.OutputBuffer.get(obj.ChunkSize);
            end
            obj.IsFinished = ~iHasdata(obj.Datastore) && obj.OutputBuffer.NumBufferedSlices == 0;
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = ReadProcessor(datastore, emptyChunk)
            obj.Datastore = datastore;
            obj.RequiresCells = ~matlab.io.datastore.internal.shim.isUniformRead(datastore) ...
                && ~matlab.io.datastore.internal.shim.isReadEncellified(datastore);
            obj.EmptyChunk = emptyChunk;
            obj.EmptyChunkMetaInfo = iRecursiveGetMetadata(emptyChunk);
            
            obj.OutputBuffer = matlab.bigdata.internal.lazyeval.InputBuffer(1, false);
            
            if matlab.io.datastore.internal.shim.isUniformRead(datastore)
                % Read from the uniform datastore and check for any data
                % uniformity violations
                obj.ReadChunkFcn = @() readWithUniformDataCheck(obj);
            else
                % Read directly from the non-uniform datastore
                obj.ReadChunkFcn = @() iRead(obj.Datastore, obj.RequiresCells);
            end
        end
        
        function data = readWithUniformDataCheck(obj)
            % Reads a chunk of data from the underlying uniform datastore
            data = iRead(obj.Datastore, obj.RequiresCells);
            
            dataMetaInfo = iRecursiveGetMetadata(data);
            if isequal(dataMetaInfo, obj.EmptyChunkMetaInfo)
                return;
            end
            
            oldWarnState = warning('off', 'MATLAB:catenate:DimensionMismatch');
            warnCleanup = onCleanup(@() warning(oldWarnState));
            try %#ok<TRYNC>
                data = [data; obj.EmptyChunk];
            end
            dataMetaInfo = iRecursiveGetMetadata(data);
            if isequal(dataMetaInfo, obj.EmptyChunkMetaInfo)
                return;
            end
            
            varName = 'data';
            details = iFindUniformMismatch(dataMetaInfo, obj.EmptyChunkMetaInfo, varName, size(data, 1));
            assert(~isempty(details), 'Assertion failed: Uniform mismatch detected but could not find where.');
            
            if isa(obj.Datastore, 'matlab.io.datastore.FileDatastore')
                errId = 'MATLAB:bigdata:array:UniformFileDatastoreMismatch';
            else
                errId = 'MATLAB:bigdata:array:UniformMismatch';
            end
            err = MException(message(errId, details{:}));
            matlab.bigdata.internal.throw(err);
        end
    end
end

% Helper function that performs a read and optionally places the data in a
% cell.
function data = iRead(ds, requiresCell)
try
    data = read(ds);
catch err
    matlab.bigdata.internal.throw(err, 'IncludeCalleeStack', true);
end

% If the datastore is not tabular, the read method will
% return the contents of a single element of a cell array.
% We need to wrap this single element back up in a cell to
% conform with readall.
if requiresCell
    data = {data};
end
end

% Call datastore/hasdata.
function tf = iHasdata(ds)
try
    tf = hasdata(ds);
catch err
    matlab.bigdata.internal.throw(err, 'IncludeCalleeStack', true);
end
end

% Call datastore/preview.
function data = iPreview(ds)
try
    data = preview(ds);
catch err
    matlab.bigdata.internal.throw(err, 'IncludeCalleeStack', true);
end
end

% Find why a chunk of data does not match the empty prototype.
function details = iFindUniformMismatch(dataMetaInfo, emptyPrototypeMetaInfo, varName, height)
if ~isequal(dataMetaInfo{1}, emptyPrototypeMetaInfo{1})
    expression = sprintf('class(%s)', varName);
    actual = ['"', dataMetaInfo{1}, '"'];
    expected = ['"', emptyPrototypeMetaInfo{1}, '"'];
    details = {expression, actual, expected};
elseif ~isequal(dataMetaInfo{2}, emptyPrototypeMetaInfo{2})
    expression = sprintf('size(%s)', varName);
    actual = mat2str([height, dataMetaInfo{2}(2 : end)]);
    expected = mat2str([height, emptyPrototypeMetaInfo{2}(2 : end)]);
    details = {expression, actual, expected};
elseif numel(emptyPrototypeMetaInfo) > 2 && ~isequal(dataMetaInfo{3}, emptyPrototypeMetaInfo{3})
    idx = find(~strcmp(dataMetaInfo{3}, emptyPrototypeMetaInfo{3}), 1, 'first');
    assert(~isempty(idx), 'Assertion failed: Variable names same length and same names but not isequal');
    expression = sprintf('%s.Properties.VariableNames(%i)', varName, idx);
    actual = ['"', dataMetaInfo{3}{idx}, '"'];
    expected = ['"', emptyPrototypeMetaInfo{3}{idx}, '"'];
    details = {expression, actual, expected};
else
    details = {};
end

for ii = 4 : numel(emptyPrototypeMetaInfo)
    if ~isempty(details)
        break;
    end
    
    subVarName = [varName, '.', emptyPrototypeMetaInfo{3}{ii - 3}];
    details = iFindUniformMismatch(dataMetaInfo{ii}, emptyPrototypeMetaInfo{ii}, subVarName, height);
end
end

% Get the class and size info of an object, then for table and timetable
% recurse into the table's variables.
function metainfo = iRecursiveGetMetadata(chunk)
s = size(chunk);
s(1) = 0;
metainfo = {class(chunk); s};
if istable(chunk) || istimetable(chunk)
    % TODO(g1580766): This is an internal API of table and should be
    % replaced by the official API table2struct(chunk,'ToScalar',true).
    % This code uses the internal version as the official API is an order
    % of magnitude slower.
    metainfo = [metainfo; {chunk.Properties.VariableNames}];
    chunk = struct2cell(getVars(chunk));
    metainfo = [metainfo; cellfun(@iRecursiveGetMetadata, chunk, 'UniformOutput', false)];
end
end

