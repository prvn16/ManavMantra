function [F, TF] = fillmissingInterpStencil(A, interpMethod, dataVars)
%FILLMISSINGINTERPSTENCIL Fill missing values using an interp stencil

% Copyright 2017 The MathWorks, Inc.


import matlab.bigdata.internal.broadcast
import matlab.bigdata.internal.FunctionHandle
import matlab.bigdata.internal.util.StatefulFunction

% Build option struct containing interp options depending on input type
opts.Method = interpMethod;
opts.Window = iGetWindowSize(interpMethod);
inputClass = tall.getClass(A);

if ismember(inputClass, {'table', 'timetable'})
    initialSummaryState = {0, cell(1, numel(dataVars))};
    opts.InputIsTabular = true;
    opts.DataVars = dataVars;
    opts.ExtractHaloFcn = ...
        @(varargin) iExtractTabularHalo(varargin{:}, dataVars);
    
    opts.MergeHalosFcn = @iMergeTableSummaryHalos;
    opts.InsertHalosFcn = @iInsertTabularHalos;
    
    if strcmpi(inputClass, 'timetable')
        opts.ApplyFillFcn = @(varargin) iFillInterpTimetable(varargin{:}, dataVars);
    else
        opts.ApplyFillFcn = @(varargin) iFillInterpTable(varargin{:}, dataVars);
    end
else
    initialSummaryState = {0, []};
    opts.InputIsTabular = false;
    opts.ExtractHaloFcn = @iExtractChunkHalo;
    opts.MergeHalosFcn = @iMergeSummaryHalo;
    opts.InsertHalosFcn = @iInsertChunkHalos;
    opts.ApplyFillFcn = @iFillInterpArray;
end

summaryFcn = @(varargin) iSummarizePartitions(varargin{:}, opts);
summaryFunctor = FunctionHandle(StatefulFunction(summaryFcn, initialSummaryState));
summaryTable = partitionfun(summaryFunctor, A);
summaryTable.Adaptor = iMkSummaryTableAdaptor();

summaryTable = clientfun(@(t) iAdjustSliceIds(t, opts.InputIsTabular), summaryTable);
summaryTable.Adaptor = iMkSummaryTableAdaptor();

doInterpFcn = @(varargin) iDoInterp(varargin{:}, opts);
interpFunctor = FunctionHandle(StatefulFunction(doInterpFcn));
[F, TF] = partitionfun(interpFunctor, A, broadcast(summaryTable));
% The framework will assume F and TF are partition dependent because they
% derived from partitionfun. They are not, so we must correct this.
[F, TF] = copyPartitionIndependence(F, TF, A);
% No need to set adaptors as they are set by the caller
end

%--------------------------------------------------------------------------
function [state, hasFinished, summaryTableRow] = ...
    iSummarizePartitions(state, info, A, opts)
% Summarize each partition to produce a mapping from PartitionId to the
% total number of data slices and the valid halos for the partition.

% unpack the state cell
[numDataSlices, halo] = state{:};

numDataSlices = numDataSlices + size(A,1);

chunkHalo = opts.ExtractHaloFcn(A, info.RelativeIndexInPartition, opts.Window);
halo = opts.MergeHalosFcn(halo, chunkHalo, opts.Window);

state = {numDataSlices, halo};
hasFinished = info.IsLastChunk;

if hasFinished
    % Final chunk - emit a table row for this partition containing the
    % total number of data slices as well as the column-wise halos
    if ~opts.InputIsTabular
        halo = {halo};
    end
    
    summaryTableRow = iMakeSummaryTable(info.PartitionId, numDataSlices, halo);
else
    % Return an empty table row within the partition
    summaryTableRow = iMakeSummaryTable([], [], {});
end
end

%--------------------------------------------------------------------------
function halo = iMergeSummaryHalo(halo, chunkHalo, validWindow)

halo = [halo; chunkHalo];

% Prune unnecessary rows
halo = sortrows(halo, {'SliceIndex', 'ColIndex'});
filter = false(height(halo),1);
colIds = unique(halo.ColIndex)';
NB = validWindow(1);
NF = validWindow(2);

for jj = colIds
    heads = iFindSlices(halo.ColIndex == jj, NF, 'first');
    tails = iFindSlices(halo.ColIndex == jj, NB, 'last');
    slicesToKeep = unique([heads; tails]);
    filter(slicesToKeep) = true;
end

halo = halo(filter, :);
end

%--------------------------------------------------------------------------
function halo = iMergeTableSummaryHalos(halo, chunkHalo, validWindow)

for jj=1:numel(halo)
    halo{jj} = iMergeSummaryHalo(halo{jj}, chunkHalo{jj}, validWindow);
end
end

%--------------------------------------------------------------------------
function T = iAdjustSliceIds(T, inputIsTabular)
% Update the slice indices stored within the halo table so that the slice
% index column contains the overall partitioned array index

offset = circshift(T.NumDataSlices, 1);
offset(1) = 0; % first partition has no offset
offset = cumsum(offset);

for ii = 2:numel(offset)
    halo = T{ii, 'ValidHalos'};
    
    if inputIsTabular
        for jj = 1:numel(halo)
            halo{jj}.SliceIndex = halo{jj}.SliceIndex + offset(ii);
        end
    else
        halo{:}.SliceIndex = halo{:}.SliceIndex + offset(ii);
    end
    
    T{ii, 'ValidHalos'} = halo;
end
end

%--------------------------------------------------------------------------
function window = iGetWindowSize(interpMethod)
% Get the window extent for the given interp method.  The window is defined
% as [NB NF] where NB and NF are the number of backwards and forwards valid
% slices needed to satisfy the interp method.

switch interpMethod
    case 'next'
        window = [0 1];
    case 'previous'
        window = [1 0];
    case 'nearest'
        window = [1 1];
    case 'linear'
        window = [2 2];
    case 'pchip'
        window = [4 4];
end
end

%--------------------------------------------------------------------------
function [obj, hasFinished, F, TF] = iDoInterp(obj, info, A, summaryTable, opts)

import matlab.bigdata.internal.io.ExternalInputBuffer
import matlab.bigdata.internal.util.indexSlices

if isempty(obj)
    obj.InputBuffer = ExternalInputBuffer();
    obj.Halos = iExtractPartitionHalo(summaryTable, info.PartitionId, opts.Window, opts.InputIsTabular);
    obj.IsInputFinished = false;
    obj.PartitionStartIndex = iGetPartitionStartIndex(summaryTable, info.PartitionId);
    obj.BufferedIndexInPartition = 1;
end

if ~obj.IsInputFinished
    obj.InputBuffer.add(A);
    
    chunkHalo = opts.ExtractHaloFcn(A, info.RelativeIndexInPartition, opts.Window);
    obj.Halos = opts.InsertHalosFcn(obj.Halos, chunkHalo, obj.PartitionStartIndex);

    if info.IsLastChunk
        obj.IsInputFinished = true;
    end
end

if obj.IsInputFinished
    [hasFinished, A] = obj.InputBuffer.getnext();
    startIndex = obj.PartitionStartIndex + obj.BufferedIndexInPartition - 1 ;
    obj.BufferedIndexInPartition = obj.BufferedIndexInPartition + size(A,1);
    [F, TF] = opts.ApplyFillFcn(A, opts.Method, opts.Window, obj.Halos, startIndex);
else
    hasFinished = false;
    F = indexSlices(A, []);
    TF = false(size(F));
end
end

%--------------------------------------------------------------------------
function [F, TF] = iFillInterpArray(A, fillMethod, validWindow, halos, startIndex)

szA = size(A);
numCols = prod(szA(2:end));
endIndex = startIndex + szA(1) - 1;

F = A;
TF = false(szA);

if isempty(A)
    % Nothing to fill
    return;
end

% Create sample points vector
X = startIndex - 1 + (1:szA(1))';

NB = validWindow(1);
NF = validWindow(2);

isCharArray = ischar(A);

for jj=1:numCols
    head = iGetHeadHalo(halos, jj, startIndex, NB);
    tail = iGetTailHalo(halos, jj, endIndex, NF);
    
    if isCharArray
        % Halos for char arrays are stored as strings so we need to convert
        % them back to chars prior to using them as padding
        head.Values = matlab.internal.math.string2charRows(head.Values);
        tail.Values = matlab.internal.math.string2charRows(tail.Values);
    end
    
    haloA = [head.Values; A(:,jj); tail.Values];
    haloX = [head.SliceIndex; X; tail.SliceIndex];
    [fCol, tfCol] = fillmissing(haloA, fillMethod, 'SamplePoints', haloX);
    
    % Remove padding slices
    F(:, jj) = fCol(1+height(head) : end-height(tail), :);
    TF(:,jj) = tfCol(1+height(head) : end-height(tail), :);
end
end

%--------------------------------------------------------------------------
function [F, TF] = iFillInterpTable(A, fillMethod, validWindow, halos, startIndex, dataVars)
F = A;
TF = false(size(A));

if isempty(A)
    % Nothing to fill
    return;
end

for jj = 1:numel(dataVars)
    colId = dataVars(jj);
    Avar = A.(colId);
    undoCharConversion = false;
    
    if ischar(Avar)
        % char table variables behave like string arrays so convert to
        % string prior to filling
        Avar = matlab.internal.math.charRows2string(Avar);
        undoCharConversion = true;
    end
    
    Fvar = iFillInterpArray(Avar, fillMethod, validWindow, halos{jj}, startIndex);
    
    if undoCharConversion
        % undo the previous conversion of char to string
        F.(colId) = matlab.internal.math.string2charRows(Fvar);
    else
        F.(colId) = Fvar;
    end
    
    TF(:, colId) = xor(ismissing(F(:, colId)), ismissing(A(:, colId)));
end
end

%--------------------------------------------------------------------------
function [F, TF] = iFillInterpTimetable(A, fillMethod, validWindow, halos, startIndex, dataVars)
F = A;
TF = false(size(A));

if isempty(A)
    % Nothing to fill
    return;
end

NB = validWindow(1);
NF = validWindow(2);

for jj = 1:numel(dataVars)
    colId = dataVars(jj);
    Avar = A.(colId);
    undoCharConversion = false;
    
    if ischar(Avar)
        % char timetable variables behave like string arrays so convert to
        % string prior to filling
        Avar = matlab.internal.math.charRows2string(Avar);
        undoCharConversion = true;
    end
    
    varSize = size(Avar);
    numVarCols = prod(varSize(2:end));
    endIndex = startIndex + varSize(1) - 1;
    
    Fvar = Avar;
    
    % Use RowTimes as the sample points vector
    X = A.Properties.RowTimes;
    
    for kk = 1:numVarCols
        head = iGetHeadHalo(halos{jj}, kk, startIndex, NB);
        tail = iGetTailHalo(halos{jj}, kk, endIndex, NF);
        
        haloA = [head.Values; Avar(:,kk); tail.Values];
        haloX = [head.Time; X; tail.Time];
        fCol = fillmissing(haloA, fillMethod, 'SamplePoints', haloX);
        
        % Remove padding slices
        Fvar(:, kk) = fCol(1+height(head) : end-height(tail), :);
    end
    
    if undoCharConversion
        % undo the previous conversion of char to string
        F.(colId) = matlab.internal.math.string2charRows(Fvar);
    else
        F.(colId) = Fvar;
    end
    
    TF(:, colId) = xor(ismissing(F(:, colId)), ismissing(A(:, colId)));
end
end

%--------------------------------------------------------------------------
function summaryTable = iMakeSummaryTable(PartitionId, NumDataSlices, ValidHalos)
% SummaryTable: an internal table used to store a mapping between
% PartitionIds and the following variables
%
% 1) NumDataSlices: the total number of slices in the partition.  This
%    variable is used to determine the slice index relative to the start
%    of the tall array.
% 2) ValidHalos: the valid halo values that need to be communicated to
%    neighboring partitions.

summaryTable = table(PartitionId, NumDataSlices, ValidHalos);
end

%--------------------------------------------------------------------------
function adaptor = iMkSummaryTableAdaptor()
% Creates the necessary table adaptor for the internal summary table

import matlab.bigdata.internal.adaptors.getAdaptorForType
import matlab.bigdata.internal.adaptors.TableAdaptor

varNames = {'PartitionId', 'NumDataSlices', 'ValidHalos'};
genericAdaptor = getAdaptorForType('');
varAdaptors = repmat({genericAdaptor}, size(varNames));
adaptor = TableAdaptor(varNames, varAdaptors);
end

%--------------------------------------------------------------------------
function startIndex = iGetPartitionStartIndex(summaryTable, partitionId)
% Uses the NumDataSlices variable of the given summaryTable to determine
% the first slice index for the given parititonId relative to the start of
% the tall array.

offset = circshift(summaryTable.NumDataSlices, 1);
offset(1) = 0; % first partition has no offset
offset = cumsum(offset);

offset = offset(summaryTable.PartitionId == partitionId);
startIndex = offset + 1;
end

%--------------------------------------------------------------------------
function halo = iExtractPartitionHalo(summaryTable, partitionId, validWindow, inputIsTabular)
% Extract only the neighboring halos for the given partition from the
% summary table.

% First work out the first and last slice indices for this partition
partitionStartId = iGetPartitionStartIndex(summaryTable, partitionId);
numSlices = summaryTable.NumDataSlices(summaryTable.PartitionId == partitionId);
partitionEndId = partitionStartId + numSlices - 1;

extractFcn = @(h) iExtractNeighbors(h, partitionStartId, partitionEndId, validWindow);

if inputIsTabular
    halo = cell(1, size(summaryTable.ValidHalos, 2));
    
    for jj = 1:numel(halo)
        halo{jj} = vertcat(summaryTable.ValidHalos{:, jj});
        halo{jj} = extractFcn(halo{jj});
    end
else
    % Unpack all the valid halos
    halo = vertcat(summaryTable.ValidHalos{:});
    halo = extractFcn(halo);
end
end

%--------------------------------------------------------------------------
function halo = iExtractNeighbors(halo, startId, endId, validWindow)
% Reduce the supplied halo to only contain the halos neighboring to the
% supplied start and end indices.

halo = sortrows(halo, {'SliceIndex', 'ColIndex'});

% For each column of input, find the necessary partition halos
colIds = unique(halo.ColIndex)';
headFilter = false(size(halo,1), 1);
tailFilter = false(size(halo,1), 1);

NB = validWindow(1);
NF = validWindow(2);

for jj = colIds
    isEarlier = halo.SliceIndex < startId;
    headHaloIds = iFindSlices(halo.ColIndex == jj & isEarlier, NB, 'last');
    headFilter(headHaloIds) = true;
    
    isLater = halo.SliceIndex > endId;
    tailHaloIds = iFindSlices(halo.ColIndex == jj & isLater, NF, 'first');
    tailFilter(tailHaloIds) = true;
end

halo = halo(headFilter | tailFilter, :);
end

%--------------------------------------------------------------------------
function tableHalo = iExtractTabularHalo(A, startIndex, validWindow, dataVars)

tableHalo = cell(1, numel(dataVars));

for jj = 1:numel(dataVars)
    Avar = A.(dataVars(jj));
    tableHalo{jj} = iExtractVariableHalo(Avar, startIndex, validWindow);
    
    if istimetable(A)
        % Store the time values as well to use as sample points when we get
        % to applying the interp
        timeIds = tableHalo{jj}.SliceIndex - startIndex + 1;
        tableHalo{jj}.Time = A.Properties.RowTimes(timeIds);
    end
end
end

%--------------------------------------------------------------------------
function varHalo = iExtractVariableHalo(Avar, startIndex, validWindow)
% char table variables behave like string arrays so convert to
% string prior to extracting halos

if ischar(Avar)
    Avar = matlab.internal.math.charRows2string(Avar);
end

varHalo = iExtractChunkHalo(Avar, startIndex, validWindow);
end

%--------------------------------------------------------------------------
function halo = iExtractChunkHalo(A, startIndex, validWindow)
% Extract the valid halo from a chunk of input data.  We store the valid
% values as defined by validWindow for each column of input data in a table
% with the following variables:
%
% 1) SliceIndex: the slice index of the valid value
% 2) ColIndex: the column index of the valid value
% 3) Values: the valid halo value that needs to be communicated to
%    neighboring chunks or partitions.

if isempty(A)
    % Early return for empty chunk, return an empty table with the correct
    % variables and column types
    SliceIndex = zeros(0,1);
    ColIndex = zeros(0,1);
    Values = A(zeros(0,1)); % column empty with correct type
    halo = table(SliceIndex, ColIndex, Values);
    return;
end

[numSlices, numCols] = size(A);
sliceId = startIndex - 1 + (1:numSlices)';

halo = cell(1, numCols);

NB = validWindow(1);
NF = validWindow(2);

for jj=1:numCols
    Acol = A(:,jj);
    
    isValid = ~ismissing(Acol);
    
    headSlices = iFindSlices(isValid, NF, 'first');
    tailSlices = iFindSlices(isValid, NB, 'last');
    
    haloSlices = unique([headSlices; tailSlices]);
    
    SliceIndex = sliceId(haloSlices);
    ColIndex = repmat(jj, size(SliceIndex));
    Values = Acol(haloSlices);
    
    if ischar(Values)
        % Must convert char to strings to store in a table
        Values = matlab.internal.math.charRows2string(Values);
    end

    halo{jj} = table(SliceIndex, ColIndex, Values);
end

halo = vertcat(halo{:});
end

%--------------------------------------------------------------------------
function halos = iInsertTabularHalos(halos, chunkHalos, partitionStartIndex)

for jj = 1:numel(halos)
    halos{jj} = iInsertChunkHalos(halos{jj}, chunkHalos{jj}, partitionStartIndex);
end
end

%--------------------------------------------------------------------------
function halo = iInsertChunkHalos(halo, chunkHalo, partitionStartIndex)
% Add chunk halo into halo table while maintaining a sorted order
chunkHalo.SliceIndex = chunkHalo.SliceIndex + partitionStartIndex - 1;
halo = sortrows([chunkHalo; halo], {'SliceIndex', 'ColIndex'});
end

%--------------------------------------------------------------------------
function headHalo = iGetHeadHalo(halo, colId, startIndex, NB)
% Find the valid padding for the head of the given column

headIds = iFindSlices(...
    halo.ColIndex == colId & ...
    halo.SliceIndex < startIndex, ...
    NB, 'last');

headHalo = halo(headIds, :);
end

%--------------------------------------------------------------------------
function tailHalo = iGetTailHalo(halo, colId, endIndex, NF)
% Find the valid padding for the tail of the given column

tailIds = iFindSlices(...
    halo.ColIndex == colId & ...
    halo.SliceIndex > endIndex, ...
    NF, 'first');

tailHalo = halo(tailIds, :);
end

%--------------------------------------------------------------------------
function ids = iFindSlices(cond, N, opt)
% Simple wrapper around find that allows searching for N == 0 indices
import matlab.bigdata.internal.util.indexSlices

if N == 0
    % Return empty with the correct shape and type double
    ids = double(indexSlices(cond, []));
else
    ids = find(cond, N, opt);
end
end
