function varargout = executionGraph(varargin)
%executionGraph visualize lazy evaluation graph for tall array
%   matlab.bigdata.internal.util.executionGraph(X) plots an execution
%   graph for tall array X.
%
%   [G,P] = matlab.bigdata.internal.util.executionGraph(X) returns in G a graph
%   object and in P the resulting plot object.

% Copyright 2016-2017 The MathWorks, Inc.

% Argument checking
nargoutchk(0, 2);
[tallArgs, doSimplify, doOptimize, varNames] = iParseInputs(varargin{:});

partitionedArrays = cellfun(@hGetValueImpl, tallArgs, ...
                            'UniformOutput', false);
if doOptimize
    optimizer = matlab.bigdata.internal.Optimizer.default();
    optimizer.optimize(partitionedArrays{:});
end

% Get and (optionally) simplify the graph of closures.
closureGraph = matlab.bigdata.internal.optimizer.ClosureGraph(partitionedArrays{:});
graph        = closureGraph.Graph;
if doSimplify
    % This stage removes promises/futures from the graph.
    graph = iSimplifyGraph(graph);
end

% Grab all input argument names
if isempty(varNames)
    inputNames = cell(numel(tallArgs), 1);
    for idx = 1:numel(tallArgs)
        inputNames{idx} = inputname(idx);
    end
else
    inputNames = varNames;
end

% Update node names and labels to show extra information
graph = iUpdateNodeNamesAndLabels(graph, tallArgs, inputNames);

% Plot the resulting graph
p = plot(graph, ...
         'Layout', 'layered', ...
         'MarkerSize', graph.Nodes.MarkerSize, ...
         'Marker', graph.Nodes.Marker, ...
         'NodeLabel', graph.Nodes.Label, ...
         'NodeColor', graph.Nodes.Color);
ax = p.Parent;
iAddLegend(ax, unique(graph.Nodes.OpType));
axis(ax, 'equal');
if nargout > 0
    varargout = {graph, p};
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tallArgs, doSimplify, doOptimize, varNames] = iParseInputs(varargin)
% Strip off P-V pairs
firstP = find(cellfun(@ischar, varargin), 1, 'first');
if isempty(firstP)
    tallArgs = varargin;
    pvPairs  = {};
else
    tallArgs = varargin(1:(firstP-1));
    pvPairs  = varargin(firstP:end);
end

for ii = 1:numel(tallArgs)
    if isa(tallArgs{ii}, 'matlab.bigdata.internal.PartitionedArray')
        tallArgs{ii} = tall(tallArgs{ii});
    end
end
assert(all(cellfun(@istall, tallArgs)), ...
       'All data inputs to %s must be tall arrays.', upper(mfilename));
numTallArgs = numel(tallArgs);

% Interpret P-V pairs.
p = inputParser;
scalarLogicalValidator = @(x) validateattributes(x, {'logical'}, {'scalar'});
addParameter(p, 'Simplify', true, scalarLogicalValidator);
addParameter(p, 'Optimize', false, scalarLogicalValidator);
varNamesValidator = @(x) validateattributes(x, {'cell', 'string'}, {'row', 'numel', numTallArgs});
addParameter(p, 'VariableNames', [], varNamesValidator);
p.parse(pvPairs{:});
doSimplify = p.Results.Simplify;
doOptimize = p.Results.Optimize;
varNames   = p.Results.VariableNames;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simplify graph by attempting to skip over the promise/future pairs that are
% interspersed between closures.
function g = iSimplifyGraph(g)
% Walk the graph in topologically-sorted order so we can start at the top.
g = reordernodes(g, toposort(g));
isClosure = g.Nodes.IsClosure;
% Default is to keep nodes, until we work out that we've skipped over them.
keepNodes = true(numnodes(g), 1);
dists = distances(g);
for idx = 1:numnodes(g)
    if isClosure(idx)
        % Downstream closures are at distance 3 (1 for promise, 2 for future).
        distsThisNode = dists(idx, :);
        downstreamClosures = find(distsThisNode == 3);
        g = addedge(g, idx, downstreamClosures);
        % Trim nodes we skipped over
        if ~isempty(downstreamClosures)
            dropThisTime = any(distsThisNode == [1;2]);
            keepNodes(dropThisTime) = false;
        end
    end
end
g = rmnode(g, find(~keepNodes));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update node names and labels for all remaining elements in the graph.
function graph = iUpdateNodeNamesAndLabels(graph, inputTallArrays, inputNames)

numNodes  = height(graph.Nodes);

% Compute a marker size. 1 for future/promise (not many remain); 5 for closures;
% 7 for sources/sinks.
markerSize = ones(numNodes, 1);
markerSize(graph.Nodes.IsClosure) = 5;
sources = indegree(graph) == 0;
sinks   = outdegree(graph) == 0;
markerSize(sources | sinks) = 7;
constants = sources & ~graph.Nodes.IsClosure;

% Update 'OpType' to include Constants / Outputs / Others.
graph.Nodes.OpType(constants) = categorical({'Constant'});
graph.Nodes.OpType(~graph.Nodes.IsClosure & sinks) = categorical({'Output'});
graph.Nodes.OpType(ismissing(graph.Nodes.OpType)) = categorical({'Other'});
opType = regexprep(cellstr(graph.Nodes.OpType), 'Operation$', '');
graph.Nodes.OpType = categorical(opType);

% Join in color and marker
graph.Nodes = join(graph.Nodes, iOpTypeMappingTable);
graph.Nodes.MarkerSize = markerSize;

% Set up default label to be index in topological sort.
graph.Nodes.Label = cellstr(num2str((1:numNodes)'));

% Compute labels and names for closures, sources, sinks
graph = iUpdateClosureNamesAndLabels(graph);
graph = iUpdateSinkNamesAndLabels(graph, inputTallArrays, inputNames);
graph = iUpdateConstantNamesAndLabels(graph);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name and labels for closure nodes.
function graph = iUpdateClosureNamesAndLabels(graph)
isClosure    = graph.Nodes.IsClosure;
nodeObjs     = graph.Nodes{isClosure, 'NodeObj'};
opTypes      = graph.Nodes{isClosure, 'OpType'};
closureNames = cell(1, numel(nodeObjs));

% We keep closure labels only for nodes that are not single-input-single-output.
keepLabel    = isClosure & (indegree(graph) > 1 | outdegree(graph) > 1);
graph.Nodes.Label(~keepLabel) = {''};

for idx = 1:numel(nodeObjs)
    nodeObj = nodeObjs{idx};
    opType  = opTypes(idx);
    % Starting point for the name is based on the underlying Id, but we'll override
    % this.
    n       = nodeObj.Id;
    switch opType
      case 'Read'
        n = iReadDescription(nodeObj);
      case {'Slicewise', 'Elementwise'}
        n = iFunctionDescription(nodeObj.Operation.FunctionHandle);
      case {'Filter', 'Chunkwise', 'Partitionwise'}
        n = iFunctionDescription(nodeObj.Operation.FunctionHandle);
      case {'Aggregate', 'AggregateByKey'}
        n = sprintf('Aggregate: %s\nReduce: %s\n', ...
                    iFunctionDescription(nodeObj.Operation.PerChunkFunctionHandle), ...
                    iFunctionDescription(nodeObj.Operation.ReduceFunctionHandle));
        case {'FusedAggregateByKey'}
            cell2strfcn = @(c) strjoin(cellfun(@iFunctionDescription, c, ...
                'UniformOutput', false), '\n');
            n = sprintf('Aggregates: %s\nReduces: %s\n', ...
                cell2strfcn(nodeObj.Operation.PerChunkFunctionHandles), ...
                cell2strfcn(nodeObj.Operation.ReduceFunctionHandles));
      case {'Cache'}
      case {'NonPartitioned'}
        n = iFunctionDescription(nodeObj.Operation.FunctionHandle);
    end
    closureNames{idx} = sprintf('%s (%d):\n%s\n', opType, idx, n);
end
graph.Nodes.Name(isClosure) = closureNames;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Names and labels for sink nodes. Try and match up to the original inputname to
% the tall array.
function graph = iUpdateSinkNamesAndLabels(graph, inputArgsTall, inputNamesCell)
isSink    = outdegree(graph) == 0;
sinkObjs  = graph.Nodes{isSink, 'NodeObj'};
labelCell = repmat({''}, numel(sinkObjs), 1);
nameCell  = strcat('Output: ', cellstr(num2str((1:numel(sinkObjs))')));

graph.Nodes.Name(isSink) = nameCell;

% Look through the input names and see if we can match things up.
if numel(sinkObjs) == numel(inputArgsTall)
    inputPA  = cellfun(@hGetValueImpl, inputArgsTall, 'UniformOutput', false);
    inputFut = cellfun(@(x) x.ValueFuture, inputPA, 'UniformOutput', false);
    inputFut = [inputFut{:}];
    for sIdx = 1:numel(sinkObjs)
        match = inputFut == sinkObjs{sIdx};
        if sum(match) == 1
            if ~isempty(inputNamesCell{match})
                labelCell(sIdx) = inputNamesCell(match);
            else
                labelCell{sIdx} = 'ans';
            end
        end
    end
    graph.Nodes.Label(isSink) = labelCell;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Names and labels for constants
function graph = iUpdateConstantNamesAndLabels(graph)
constantIdxs = find(indegree(graph) == 0 & ~graph.Nodes.IsClosure);
constantObjs = graph.Nodes{constantIdxs, 'NodeObj'};

[names, labels] = cellfun(@iConstantInfo, constantObjs, num2cell(constantIdxs), ...
    'UniformOutput', false);

graph.Nodes.Name(constantIdxs) = names;
graph.Nodes.Label(constantIdxs) = labels;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function l = iAddLegend(ax, types)
  mapping = iOpTypeMappingTable;
  lines = cell(numel(types, 1));
  for idx = 1:numel(types)
      if types(idx) == 'Other'
          continue
      end
      marker = mapping{mapping.OpType == types(idx), 'Marker'};
      color  = mapping{mapping.OpType == types(idx), 'Color'};
      % Make a secret line object solely for the purposes of the legend.
      lines{idx} = line(ax, NaN, NaN, 'Marker', marker{1}, ...
                        'LineStyle', 'none', ...
                        'MarkerFaceColor', color, ...
                        'MarkerEdgeColor', color, ...
                        'DisplayName', char(types(idx)));
  end
  l = legend([lines{:}]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of color and marker for each operation type.
function t = iOpTypeMappingTable
persistent MAPPING_TABLE
if isempty(MAPPING_TABLE)
    data = { 'Read',           [0.8, 0.8, 0.8], 'v';
             'Slicewise',      [1,   1,   0],   'o';
             'FusedSlicewise', [1,   0.5,   0.5], 'o';
             'Elementwise',    [0,   1,   0],   'o';
             'Vertcat',        [0,   1,   0],   'o';
             'Filter',         [0,   1,   1],   'o';
             'ChunkResize',    [1,   0.5, 1],   'o';
             'Chunkwise',      [0,   0.5, 1],   'o';
             'FixedChunkwise', [0.5,   0.5, 1], 'o';
             'Encellification',[0,   0.5, 1],   'o';
             'Partitionwise',  [0,   0,   1],   'o';
             'GeneralizedPartitionwise', [0.5,   0,   1],   'o';
             'Passthrough',    [0,   0,   0],   'o';
             'Aggregate',      [1,   0.2, 0],   'd';
             'FusedAggregate', [1,   0.2, 0],   'd';
             'AggregateByKey', [1,   0,   0.2], 's';
             'Repartition',    [1,   0.2, 0.2], 'd';
             'FusedAggregateByKey', [0.6,   0,   0.2], 'd';
             'Cache',          [0,   0.5, 1],   'o';
             'NonPartitioned', [0,   0.5, 0.5], 'd';
             'Ternary',        [0,   0.5, 0.5], '^';
             'Constant',       [0.5, 0,   0.5], 'v';
             'Output',         [0,   0,   0],   'p';
             'Gather',         [0,   0,   0],   'd';
             'Other',          [0.5, 0.5, 0.5], '.' };
    MAPPING_TABLE = cell2table(data, ...
                               'VariableNames', {'OpType', 'Color', 'Marker'});
    MAPPING_TABLE.OpType = categorical(MAPPING_TABLE.OpType);
end
t = MAPPING_TABLE;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Describes a read operation.
function txt = iReadDescription(nodeObj)
try
    files = nodeObj.Operation.Datastore.Files;
    files = strrep(files, matlabroot, '<matlab>');
    txt = sprintf('Read from: %s\n', strjoin(files, '\n'));
catch E
    txt = sprintf('Error occurred: %s', E.message);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Describes a function - shows the stack.
function txt = iFunctionDescription(functionObj)
try
    txt = sprintf('%s\n', func2str(functionObj.Handle));
    stackLines = arrayfun(@iFrameDescription, functionObj.ErrorStack, ...
                          'UniformOutput', false);
    txt = [txt, strjoin(stackLines, '\n')];
catch E
    txt = sprintf('Error occurred: %s', E.message);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Describe a single stack frame.
function txt = iFrameDescription(frame)
if isempty(frame.file)
    txt = sprintf('%s:%d', frame.name, frame.line);
else
    % Got file & frame
    framefile = strrep(frame.file, matlabroot, '<matlab>');
    [fpath, fname] = fileparts(framefile);
    if isequal(fname, frame.name)
        txt = sprintf('%s:%d', framefile, frame.line);
    else
        txt = sprintf('%s/%s:%d', fpath, frame.name, frame.line);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the name and label for a constant source.
function [txt, label] = iConstantInfo(nodeObj, nodeIdx)

assert(isa(nodeObj, 'matlab.bigdata.internal.lazyeval.ClosurePromise'));
label = sprintf('Constant:%s', nodeIdx);
if nodeObj.IsDone
    val = nodeObj.CachedValue;
    if isa(val, 'matlab.bigdata.internal.BroadcastArray')
        val = val.Value;
    end
    if isscalar(val) && (isnumeric(val) || islogical(val))
        shortVal = ['[', num2str(val), ']'];
        longVal  = ['value: ', shortVal];
    else
        shortVal = sprintf('%s [%s]', class(val), ...
                           matlab.bigdata.internal.util.formatBigSize(size(val)));
        longVal  = sprintf('%s\nvalue:\n%s', shortVal, ...
                           iTruncatedDisplay(val));
    end
else
    % How does one get here?
    shortVal = '';
    longVal  = '';
end
txt   = sprintf('%s\n%s', label, longVal);
label = shortVal;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Come up with a simple display for a constant value.
function txt = iTruncatedDisplay(val)
truncated = false;
if ~ismatrix(val)
    val = val(:,:,1);
    truncated = true;
end

limit = 8;
[m, n] = size(val);
if any([m, n] > limit)
    truncated = true;
    val = val(1:min(m, limit), 1:min(n, limit)); %#ok<NASGU> used in EVALC
end
txt = evalc('disp(val)');
if truncated
    txt = sprintf('truncated:\n%s', txt);
end
end
