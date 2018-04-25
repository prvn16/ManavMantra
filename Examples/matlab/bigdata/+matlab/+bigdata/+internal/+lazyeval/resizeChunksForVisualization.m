function varargout = resizeChunksForVisualization(varargin)
% Resize chunks for visualization. This will collect as much data as
% possible for 1 second (up-to 32 MB) then call the function.
%
% Syntax:
%   [tX,tY,..] = resizeChunksForVisualization(tX,tY,..)
%

%   Copyright 2017 The MathWorks, Inc.

import matlab.bigdata.internal.lazyeval.ChunkResizeOperation;

assert(nargin >= 1, 'Assertion failed: resizeChunksForVisualization called with no inputs.');

inputs = cellfun(@hGetValueImpl, varargin, 'UniformOutput', false);
minBytesPerChunk = ChunkResizeOperation.minBytesPerChunkForVisualization();
if iIsSerialExecutor(inputs{:})
    maxTimePerChunk = ChunkResizeOperation.maxTimePerChunkForSerialVisualization();
else
    maxTimePerChunk = ChunkResizeOperation.maxTimePerChunkForParallelVisualization();
end

[varargout{1 : nargout}] = resizechunks(...
    inputs{:}, ...
    'MinBytesPerChunk', minBytesPerChunk, ... % Try to get 32 MB per worker invocation by default.
    'MaxTimePerChunk', maxTimePerChunk);      % But only wait at most 0.5 or 10 seconds by default
                                              % depending on backend.

varargout = cellfun(@tall, varargout, 'UniformOutput', false);
for ii = 1 : numel(varargout)
    varargout{ii} = hSetAdaptor(varargout{ii}, matlab.bigdata.internal.adaptors.getAdaptor(varargin{ii}));
end

function tf = iIsSerialExecutor(varargin)
% Check if the tall arrays are backed by the serial execution environment.
executor = varargin{1}.Executor;
tf = executor.supportsSinglePartition();
