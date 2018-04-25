% TracePlotter
% A debug tool that generates a running plot of the serial back-end
% execution during a gather.
%
% An example of use is:
%
%  plotter = matlab.bigdata.internal.debug.TracePlotter;
%
% ds = datastore('airlinesmall.csv', 'TreatAsMissing', 'NA', ...
%     'SelectedVariableNames', {'ArrDelay'});
% tt = tall(ds);
% gather(mean(tt.ArrDelay, 'omitnan'));

%   Copyright 2016-2017 The MathWorks, Inc.

classdef TracePlotter < handle & matlab.mixin.SetGet
    
    properties (SetAccess = immutable)
        % The parent axis that owns the plot object itself.
        Parent;
    end
    
    properties
        % Show assert processors as full nodes.
        ShowAssertProcessors = false;
        
        % Show a legend of node colors. This improves readability, but
        % halves the frame rate.
        ShowLegend = true;
    end
    
    properties (GetAccess = private, SetAccess = private)
        % The handle to the current graph plot. This is reset on the start
        % of each execution trigger.
        PlotHandle;
        
        % A list of nodes in the graph. This is stored directly because
        % graph subsref is too slow.
        Nodes;
        
        % A list of edges in the graph. This is stored directly because
        % graph subsref is too slow.
        Edges;
        
        % The last "time" index of the last process event. This is
        % incremented once for each process event.
        LastProcessIndex = 1;
        
        % Listener object for receiving execution events.
        Listener;
    end
    
    methods
        % The main constructor.
        function obj = TracePlotter
            import matlab.bigdata.internal.debug.DebugSession;
            import matlab.bigdata.internal.executor.PartitionedArrayExecutor;
            
            mr = gcmr('nocreate');
            if isempty(mr)
                mapreducer(0);
            elseif ~isa(mr, 'matlab.mapreduce.SerialMapReducer')
                error('TracePlotter tool only currently supports the serial back-end. Use MAPREDUCER(0)');
            end
            
            obj.PlotHandle = plot(digraph);
            obj.Parent = obj.PlotHandle.Parent;
            obj.Parent.addlistener('ObjectBeingDestroyed', @(~, ~) delete(obj));
            if obj.ShowLegend
                iAddLegend(obj.Parent);
            end
            axis(obj.Parent, 'equal');
            
            listener = DebugSession.getCurrentDebugSession().attach();
            listener.ExecuteBeginFcn = @obj.updateExecuteBegin;
            listener.ProcessorCreatedFcn = @obj.updateProcessorCreated;
            listener.ProcessorDestroyedFcn = @obj.updateProcessorDestroyed;
            listener.ProcessBeginFcn = @obj.updateProcessBegin;
            listener.ProcessReturnFcn = @obj.updateProcessEnd;
            obj.Listener = listener;
        end
    end
    
    methods (Access = private)
        function updateExecuteBegin(obj, ~, taskGraph)
            % Update the plot in response to a new execution trigger.
            obj.initializeGraph(taskGraph);
            obj.initializePlot();
            obj.stepAnimation();
        end
        
        function updateProcessorCreated(obj, processor)
            % Update the plot in response to the creation of a processor
            % object.
            id = processor.Task.Id;
            idx = strcmp(obj.Nodes.Name, id);
            obj.Nodes.IsActive(idx) = true;
            
            idx = obj.findEdges(processor.Task.InputIds, id);
            obj.Edges.IsActive(idx) = true;
            obj.Edges.MoreRequired(idx) = processor.IsMoreInputRequired;
            
            obj.updatePlot();
            obj.stepAnimation();
        end
        
        function updateProcessorDestroyed(obj, processor)
            % Update the plot in response to the destruction of a processor
            % object.
            id = processor.Task.Id;
            idx = strcmp(obj.Nodes.Name, id);
            obj.Nodes.IsActive(idx) = false;
            obj.Nodes.IsFinished(idx) = false;
            
            idx = obj.findEdges(processor.Task.InputIds, id);
            obj.Edges.IsActive(idx) = false;
            obj.Edges.MoreRequired(idx) = false;
            
            obj.updatePlot();
            obj.stepAnimation();
        end
        
        function updateProcessBegin(obj, processor, invokeData)
            % Update the plot in response to a process event.
            obj.LastProcessIndex = obj.LastProcessIndex + 1;
            
            id = processor.Task.Id;
            idx = strcmp(obj.Nodes.Name, id);
            obj.Nodes.IsFinished(idx) = processor.IsFinished;
            obj.Nodes.NumProcessCalls(idx) = obj.Nodes.NumProcessCalls(idx) + 1;
            obj.Nodes.LastProcessIndex(idx) = obj.LastProcessIndex;
            
            inputs = invokeData.Inputs;
            
            idx = obj.findEdges(processor.Task.InputIds, id);
            obj.Edges.NumSlices(idx) = obj.Edges.NumSlices(idx) + cellfun(@iCountNumSlices, inputs(:));
            obj.Edges.MoreRequired(idx) = processor.IsMoreInputRequired;
            
            obj.updatePlot();
            obj.stepAnimation();
        end
        
        function updateProcessEnd(obj, processor, ~)
            % Update the plot in response to a process event.
            obj.LastProcessIndex = obj.LastProcessIndex + 1;
            
            id = processor.Task.Id;
            idx = strcmp(obj.Nodes.Name, id);
            obj.Nodes.IsFinished(idx) = processor.IsFinished;
            obj.Nodes.NumProcessCalls(idx) = obj.Nodes.NumProcessCalls(idx) + 1;
            obj.Nodes.LastProcessIndex(idx) = obj.LastProcessIndex;
            
            idx = obj.findEdges(processor.Task.InputIds, id);
            obj.Edges.MoreRequired(idx) = processor.IsMoreInputRequired;
            
            obj.updatePlot();
            obj.stepAnimation();
        end
        
        function initializeGraph(obj, taskGraph)
            % Initialize the graph state held by this object.
            tasks = taskGraph.Tasks;
            
            nodes = struct2table(arrayfun(@iDescribeTask, tasks));
            
            % State that is updated during execution.
            nodes.IsActive = false(height(nodes), 1);
            nodes.IsFinished = false(height(nodes), 1);
            nodes.LastProcessIndex = -Inf * ones(height(nodes), 1);
            nodes.NumProcessCalls = zeros(height(nodes), 1);
            
            edgeOrigNodes = [tasks.InputIds]';
            edgeDestNodes = repelem({tasks.Id}, cellfun(@numel, {tasks.InputIds}))';
            edges = table([edgeOrigNodes, edgeDestNodes], 'VariableNames', {'EndNodes'});
            edges.NumSlices = zeros(height(edges), 1);
            edges.IsActive = false(height(edges), 1);
            edges.MoreRequired = false(height(edges), 1);
            
            graph = digraph(edges, nodes);
            obj.Nodes = graph.Nodes;
            obj.Edges = graph.Edges;
        end
        
        function initializePlot(obj)
            % Initialize the plot from the graph state.
            nodeNames = obj.generateNodeNames();
            nodeColors = obj.generateNodeColors();
            edgeLabels = obj.generateEdgeLabels();
            edgeColors = obj.generateEdgeColors();
            edgeWidths = obj.generateEdgeWidths();
            
            graph = digraph(obj.Edges, obj.Nodes);
            graph.Nodes.Name = nodeNames;
            
            obj.PlotHandle = plot(graph, ...
                'Parent', obj.Parent, ...
                'Layout', 'Layered', 'Direction', 'right', ...
                'NodeLabel', {}, 'EdgeLabel', edgeLabels, ...
                'NodeColor', nodeColors, 'EdgeColor', edgeColors, ...
                'LineWidth', edgeWidths, ...
                'MarkerSize', 4 + 4 .* obj.getIsFullNode());
            if obj.ShowLegend
                iAddLegend(obj.Parent);
            end
            axis(obj.Parent, 'equal');
        end
        
        function updatePlot(obj)
            % Update the plot handle from the graph state.
            nodeColors = obj.generateNodeColors();
            edgeLabels = obj.generateEdgeLabels();
            edgeColors = obj.generateEdgeColors();
            edgeWidths = obj.generateEdgeWidths();
            set(obj.PlotHandle, ...
                'EdgeLabel', edgeLabels, ...
                'LineWidth', edgeWidths, ...
                'NodeColor', nodeColors, ...
                'EdgeColor', edgeColors);
        end
        
        function nodeNames = generateNodeNames(obj)
            % Generate a list of node labels based on the graph state.
            
            showFullNode = obj.getIsFullNode();
            nodes = obj.Nodes;
            
            plotIndices = zeros(height(nodes), 1);
            plotIndices(showFullNode) = 1:sum(showFullNode);
            
            functionNames = nodes.Function;
            functionNames(nodes.IsFused) = {'Fused Operation'};

            nodeNames = repelem({''}, height(nodes), 1);
            nodeNames(showFullNode) = cellstr(compose(...
                '%d. %s (%s)\n%s', ...
                plotIndices(showFullNode),...
                string(nodes.Type(showFullNode)),...
                string(functionNames(showFullNode)),...
                string(nodes.Name(showFullNode))));
            
            nodeNames(~showFullNode) = nodes.Name(~showFullNode);
        end
        
        function nodeColors = generateNodeColors(obj)
            % Generate node colors at a particular instance in time.
            nodes = obj.Nodes;
            nodeColors = iGetColor('Inactive Processor', height(nodes));
            nodeColors(nodes.IsActive, :) = iGetColor('Active But Unseen Processor', sum(nodes.IsActive));
            nodeColors(nodes.IsFinished, :) = iGetColor('Finished Processor', sum(nodes.IsFinished));
            
            isInProcessTrail = nodes.IsActive & (nodes.LastProcessIndex >= obj.LastProcessIndex - 2 * height(nodes));
            nodeColors(isInProcessTrail, :) = iGetColor('Active Processor', sum(isInProcessTrail));
            if any(nodes.LastProcessIndex == obj.LastProcessIndex)
                nodeColors(nodes.LastProcessIndex == obj.LastProcessIndex, :) = iGetColor('Processing Processor');
            end
        end
        
        function edgeLabels = generateEdgeLabels(obj)
            % Generate a list of edge labels based on the graph state.
            % Hide the labels on any edges carrying zero slices. 
            edges = obj.Edges;
            edgeLabels = cellstr(string(edges.NumSlices));
            edgeLabels(edges.NumSlices == 0) = {''};
        end
        
        function edgeColors = generateEdgeColors(obj)
            % Generate edge colors at a particular instance in time.
            edges = obj.Edges;
            edgeColors = iGetColor('Inactive Pipe', height(edges));
            edgeColors(edges.IsActive, :) = iGetColor('Currently Optional Pipe', sum(edges.IsActive));
            edgeColors(edges.MoreRequired, :) = iGetColor('Currently Required Pipe', sum(edges.MoreRequired));
        end
        
        function edgeWidths = generateEdgeWidths(obj)
            % rescale the range of edges.NumSlices to the interval [1 5]
            edges = obj.Edges;
            lineLimits = [1 ; 5];
            sliceLimits = [min(edges.NumSlices) ; max(edges.NumSlices)];
            
            if sliceLimits(1) == sliceLimits(2)
                % all slices are equal - use the smallest line width
                edgeWidths = lineLimits(1) .* ones(size(edges.NumSlices));
            else
                % Linear map - find the line that passes through the points
                % that convert the sliceLimits to the lineLimits
                A = [sliceLimits [1;1]];
                b = lineLimits;
                x = A \ b;
                edgeWidths = x(1) .* edges.NumSlices + x(2);
            end
        end
        
        function showFullNode = getIsFullNode(obj)
            % Get the list of nodes that will be named in the plot.
            nodes = obj.Nodes;
            showFullNode = ~nodes.IsAssert | obj.ShowAssertProcessors;
        end
        
        
        function idx = findEdges(obj, sourceIds, destId)
            sourceIds = string(sourceIds(:));
            destId = string(destId);
            assert(numel(destId) == 1, 'Assertion failed: Expected destId to be a scalar ID.');
            pairs = [sourceIds, repelem(destId, numel(sourceIds), 1)];
            [~, idx] = ismember(pairs, string(obj.Edges.EndNodes), 'rows');
        end
        function stepAnimation(obj) %#ok<MANU>
            drawnow limitrate
        end
    end
end

function info = iDescribeTask(task)
% Helper function to describe a task.
warningState = warning('off', 'MATLAB:structOnObject');
warningStateCleanup = onCleanup(@() warning(warningState));

info.Name = task.Id;

% 1. Create a sample processor.
ePS = task.ExecutionPartitionStrategy;
n = ePS.DesiredNumPartitions;
if isempty(n)
    n = 1;
end
partition = ePS.createPartition(1,n);
processor = feval(task.DataProcessorFactory, partition);
while regexp(class(processor), 'Decorator$')
    s = struct(processor);
    processor = s.UnderlyingProcessor;
end

% 2. Extract as much info from the sample as possible.
info.Type = regexp(class(processor), '[^\.]+(?=Processor$)', 'match', 'once');

s = struct(processor);
if isfield(s, 'FunctionHandle')
    info.Function = char(iUnwrap(s.FunctionHandle.Handle));
else
    info.Function = '';
end

info.IsAssert = contains(info.Function, 'iAssertAdaptorInfoCorrect');
info.IsFused = contains(info.Function, 'iFusedFcn');
end

function handle = iUnwrap(handle)
while true
    switch class(handle)
        case 'matlab.bigdata.internal.lazyeval.TaggedArrayFunction'
            handle = handle.Handle;
        otherwise
            break;
    end
end
end

function out = iCountNumSlices(data)
% Count the number of slices in a given processor input.
out = 0;
for ii = 1:size(data, 2)
    out = max(out, size(matlab.bigdata.internal.util.vertcatCellContents(data(:, ii)), 1));
end
end

function iAddLegend(ax)
colorData = iGetColorScheme();

lines = cell(height(colorData), 1);
for ii = 1:height(colorData)
    % Make a secret line object solely for the purposes of the legend.
    lines{ii} = line(ax, NaN, NaN, ...
        'Marker', colorData.Marker{ii}, ...
        'LineStyle', 'none', ...
        'MarkerFaceColor', colorData.Color(ii, :), ...
        'MarkerEdgeColor', colorData.Color(ii, :), ...
        'DisplayName', colorData.Name{ii});
end

legend([lines{:}]);
end

function color = iGetColor(name, count)
% Retrieve the color of the given name and duplicate it count times.
[~, colorMap] = iGetColorScheme();
color = colorMap(name);
if nargin >= 2
    color = repelem(color, count, 1);
end
end

function [colorTable, colorMap] = iGetColorScheme()
% Retrieve the color scheme used by the plot.
persistent stateTable stateMap;
if isempty(stateTable)
    stateTable = cell2table({...
        'Inactive Processor',          'O', [0, 0, 0]; ...
        'Processing Processor',        'O', [0, 1, 1]; ...
        'Active Processor',            'O', [0, 0, 1]; ...
        'Active But Unseen Processor', 'O', [1, 0, 0]; ...
        'Finished Processor',          'O', [0, 0.6, 0]; ...
        'Inactive Pipe',               '.', [0, 0, 0]; ...
        'Currently Required Pipe',     '.', [0, 0, 1]; ...
        'Currently Optional Pipe',     '.', [0.4, 0, 0]; ...
        }, 'VariableNames', {'Name', 'Marker', 'Color'});
    stateMap = containers.Map(stateTable.Name, num2cell(stateTable.Color, 2));
end
colorTable = stateTable;
colorMap = stateMap;
end
