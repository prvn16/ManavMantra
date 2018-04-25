%CompositeDataProcessorBuilder
% A helper class that builds a graph of DataProcessor instances and wraps
% them in a CompositeDataProcessor.
%
% To construct a CompositeDataProcessor, the caller must build up a graph
% of CompositeDataProcessorBuilder instances. Then, the caller must call
% feval on the final or most downstream builder, which will return a
% CompositeDataProcessor representing the graph of everything upstream.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) CompositeDataProcessorBuilder < handle
    properties (SetAccess = immutable)
        % A unique ID for this builder.
        Id;
        
        % An array of CompositeDataProcessorBuilder instances that
        % represent the direct inputs to the DataProcessorFactory held by
        % this instance.
        InputBuilders;
        
        % A factory that will construct a data processor or empty. If
        % non-empty, this will be used to construct one of the data
        % processor instances inside the CompositeDataProcessor built by
        % this class.
        DataProcessorFactory;
        
        % Either a string ID, numeric or empty. If non-empty, this builder
        % will construct a placeholder node that will emit all of one
        % upstream dependency of the CompositeDataProcessor.
        %
        % The callee must connect the dependency matching this InputId to
        % the input argument of same position as InputId in AllInputIds.
        % Note, AllInputIds will be sorted by value.
        InputId;
        
        % A scalar logical that describes whether the processor should
        % return partition indices.
        RequireOutputPartitionIndices;
        
        % A scalar logical that describes whether the processor should be
        % passed the partition indices output of the previous input tasks.
        RequireInputPartitionIndices;
        
        % Number of output partitions expected from the underlying data
        % processor. This is passed to the data processor factory function.
        % This can be empty.
        NumOutputPartitions = [];
    end
    
    properties (Dependent)
        % An ordered array of all InputId values that will represent the
        % list of dependency inputs to the constructed CompositeDataProcessor.
        AllInputIds;
        
        % Whether this Builder contains only an input node.
        IsGlobalInput;
    end
    
    properties (Access = private)
        % Cache of the digraph view of this object and its dependencies.
        Graph = [];
    end
    
    properties (Access = private, Constant)
        % The means by which this class receives unique IDs.
        IdFactory = matlab.bigdata.internal.util.UniqueIdFactory('CompositeDataProcessorBuilder');
    end
    
    methods
        % Construct a CompositeDataProcessorBuilder that represents the
        % graph of all the inputBuilders in combination with
        % dataProcessorFactory. The elements of inputBuilder correspond
        % with the inputs of dataProcessorFactory.
        function obj = CompositeDataProcessorBuilder(inputBuilders, dataProcessorFactory, ...
                requireOutputPartitionIndices, requireInputPartitionIndices, numOutputPartitions)
            import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
            if isempty(inputBuilders)
                inputBuilders = CompositeDataProcessorBuilder.empty();
            end
            obj.InputBuilders = inputBuilders;
            
            if isnumeric(dataProcessorFactory) || ischar(dataProcessorFactory)
                obj.InputId = dataProcessorFactory;
            else
                obj.DataProcessorFactory = dataProcessorFactory;
            end
            if nargin < 3
                requireOutputPartitionIndices = false;
            end
            obj.RequireOutputPartitionIndices = requireOutputPartitionIndices;
            if nargin < 4
                requireInputPartitionIndices = false;
            end
            obj.RequireInputPartitionIndices = requireInputPartitionIndices;
            if nargin < 5
                numOutputPartitions = [];
            end
            obj.NumOutputPartitions = numOutputPartitions;
            
            obj.Id = obj.IdFactory.nextId();
        end
        
        % Build the graph of DataProcessors and wrap them in an enclosing
        % CompositeDataProcessor.
        function processor = feval(obj, partition, varargin)
            import matlab.bigdata.internal.executor.CompositeDataProcessor;
            g = obj.getAsGraph();
            
            numNodes = numnodes(g);
            numInputNodes = sum([g.Nodes.IsGlobalInput]);
            
            [s, t] = findedge(g);
            adjacencyWithOrder = sparse(s, t, g.Edges.OrderIndex, numNodes, numNodes);
            
            builders = g.Nodes.Builder;
            nodeProcessors = cell(numNodes, 1);
            for nodeIdx = numInputNodes + 1 : numel(builders) - 1
                nodeProcessors{nodeIdx} = buildUnderlyingProcessor(builders(nodeIdx), partition);
            end
            nodeProcessors{end} = buildUnderlyingProcessor(builders(end), partition, varargin{:});
            
            processor = CompositeDataProcessor(nodeProcessors, adjacencyWithOrder, numInputNodes);
        end
        
        function globalInputIds = get.AllInputIds(obj)
            g = obj.getAsGraph();
            inputBuilders = g.Nodes.Builder(g.Nodes.IsGlobalInput);
            globalInputIds = {inputBuilders.InputId};
        end
        
        function tf = get.IsGlobalInput(obj)
            tf = isempty(obj.DataProcessorFactory);
        end
    end
    
    methods (Access = private)
        function processor = buildUnderlyingProcessor(obj, partition, varargin)
            % Build the underlying DataProcessor associated with this one builder.
            import matlab.bigdata.internal.executor.CompositeDataProcessorNode;
            if nargin <= 2 && ~isempty(obj.NumOutputPartitions)
                varargin = {obj.NumOutputPartitions};
            end
            processor = feval(obj.DataProcessorFactory, partition, varargin{:});
            processor = CompositeDataProcessorNode(processor, ...
                obj.RequireOutputPartitionIndices, obj.RequireInputPartitionIndices);
        end
        
        function g = getAsGraph(obj)
            % Retrieve a digraph object that represents the graph of
            % underlying builders.
            if isempty(obj.Graph)
                obj.buildGraph();
            end
            g = obj.Graph;
        end
        
        function buildGraph(obj)
            % Build a digraph object that represents the graph of
            % underlying builders. This digraph will be in topological
            % order, with all nodes that represent global inputs at the
            % beginning of the node table.
            
            builders = obj.findAllBuilders();
            nodeTable = table({builders.Id}', builders, vertcat(builders.IsGlobalInput),...
                'VariableNames', {'Name', 'Builder', 'IsGlobalInput'});
            
            [dependencies, orderIndices] = findAllDependencies(builders);
            edgeTable = table(dependencies, orderIndices, ...
                'VariableNames', {'EndNodes', 'OrderIndex'});
            
            g = digraph(edgeTable, nodeTable);
            
            topoSortIdx = toposort(g);
            isGlobalInput = g.Nodes.IsGlobalInput(topoSortIdx);
            numGlobalInputs = sum(isGlobalInput);
            if numGlobalInputs > 0
                % The inputs are moved to the beginning as this is required
                % by CompositeDataProcessor.
                topoSortIdx = [topoSortIdx(isGlobalInput), topoSortIdx(~isGlobalInput)];
                % SparkExecutor expects inputs to be in order of InputId.
                inputBuilders = g.Nodes.Builder(topoSortIdx(1:numGlobalInputs));
                if isnumeric(inputBuilders(1).InputId)
                    inputIds = [inputBuilders.InputId];
                else
                    inputIds = string({inputBuilders.InputId});
                end
                [~, inputSortIdx] = sort(inputIds);
                topoSortIdx(1:numGlobalInputs) = topoSortIdx(inputSortIdx);
            end
            
            g = reordernodes(g, topoSortIdx);
            
            obj.Graph = g;
        end
        
        function builders = findAllBuilders(obj)
            % Find all builder objects referenced by this object.
            import matlab.bigdata.internal.executor.CompositeDataProcessorBuilder;
            builders = CompositeDataProcessorBuilder.empty(0, 1);
            
            stack = obj;
            while ~isempty(stack)
                currentNode = stack(end);
                stack(end) = [];
                
                if any(builders == currentNode)
                    continue;
                end
                builders(end + 1, 1) = currentNode; %#ok<AGROW>
                
                stack = [stack; currentNode.InputBuilders(:)]; %#ok<AGROW>
            end
        end
        
        function [dependencies, orderIndices] = findAllDependencies(builders)
            % Find all dependencies where both dependency and dependent are
            % in the array of builders.
            dependencies = cell(numel(builders), 1);
            orderIndices = cell(numel(builders), 1);
            for ii = 1:numel(builders)
                if ~isempty(builders(ii).InputBuilders)
                    dependencies{ii} = {builders(ii).InputBuilders.Id}';
                    dependencies{ii}(:, 2) = {builders(ii).Id};
                    
                    orderIndices{ii} = (1 : size(dependencies{ii}, 1))';
                end
            end
            dependencies = vertcat(cell(0, 2), dependencies{:});
            orderIndices = vertcat(zeros(0,1), orderIndices{:});
        end
    end
end
