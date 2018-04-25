classdef (Abstract) graphcut
    % Abstract class for graph-based segmentation classes:
    % images.graphcut.internal.lazysnapping
    % images.graphcut.internal.grabcut
    
    % This class contains methods to build a graph based on a 2D or 3D
    % image with corresponding label matrix and perform a graph cut. 
    % The concrete class must implement:
    %
    % computeTerminalEdgeWeights - determine weights for each node to the
    % source and terminal nodes and assign them to self.ForegroundWeights
    % and self.BackgroundWeights, respectively.
    %
    % computeNeighborEdgeWeights - determine weights for each node to the
    % neighboring nodes and assign them to self.NeighborWeights.
    
    % The expected workflow to perform graph cut with a concrete class:
    %
    % Step 1 - Create graph-cut object
    % Call Superclass constructor when instantiating concrete class:
    % self@images.graphcut.internal.graphcut(inputImage,labelMatrix,numNodes,conn);
    %
    % Step 2 - Set edge weights
    % self = updateTerminalEdgeWeights(self);
    % self = updateNeighborEdgeWeights(self);
    %
    % Step 3 - Perform segmentation
    % self = segment(self);
    
    % To improve performance, the labelMatrix and numNodes (input arguments
    % to intialize method) can be generated using superpixels:
    %
    % [labelMatrix,numNodes] = superpixels(inputImage,N);
    %
    % where N is the desired number of superpixels. When N is below the
    % number of pixels in inputImage, the number of nodes required to build
    % the graph decreases, improving performance.
    
    % This class is intended for internal use only and behavior may change
    % in future releases.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(SetAccess = 'protected')
        
        % Binary mask
        Mask
        
    end
    
    properties (Access = 'protected')
        
        % Input image
        % 2D image - [NumRows x NumColumns x NumChannels] where NumPages = 1
        % 3D image - [NumRows x NumColumns x NumPages] where NumChannels = 1
        InputImage
        NumRows
        NumColumns
        NumPages
        NumChannels
        
        % Graph
        Graph
        SourceNode
        TerminalNode
        NeighborStartNodes
        NeighborEndNodes
        
        % Edge weights from graph nodes to source and terminal nodes.
        ForegroundWeights
        BackgroundWeights
        
        % Edge weights between neighboring nodes.
        NeighborWeights
        
        % Label matrix
        LabelMatrix
        NumNodes
        PixelIdxList
        MeanFeatures
        
        % User input for hard constraints
        ForegroundIndices
        BackgroundIndices
        
    end
    
    methods (Abstract, Access = 'protected')
        
        %---Compute terminal edge weights----------------------------------
        [foregroundWeights, backgroundWeights] = computeTerminalEdgeWeights(self,varargin)
        
        %---Compute neighbor edge weights----------------------------------
        neighborWeights = computeNeighborEdgeWeights(self,varargin)
        
    end
    
    methods (Access = 'protected')
        
        %---initialize-----------------------------------------------------
        function self = graphcut(inputImage,labelMatrix,numNodes,conn)
            % inputImage - 2D or 3D image
            % labelMatrx - label matrix for input image
            % numNodes - number of distinct labels (max value of labelMatrix)
            % conn - connectivity between neighboring nodes.
            % 2D: 4 or 8    3D: 6, 18, or 26
            
            % Convert image to double or single precision
            if ~isfloat(inputImage)
                self.InputImage = im2double(inputImage);
            else
                self.InputImage = inputImage;
            end
            
            % Cast label matrix to image class
            classIn = class(self.InputImage);            
            if ~strcmp(class(labelMatrix),classIn)
                labelMatrix = cast(labelMatrix,classIn);
            end
                
            self.LabelMatrix = labelMatrix;
            self.NumNodes = double(numNodes);           
            self.NumRows = size(inputImage,1);
            self.NumColumns = size(inputImage,2);
            
            if ndims(labelMatrix) == 3
                self.NumChannels = 1; % 3D image
                self.NumPages = size(inputImage,3);
            else
                self.NumChannels = size(inputImage,3); % vector-valued image
                self.NumPages = 1;
            end
 
            % Label matrices with only a single label cannot return
            % anything other than a false mask because the subregion must
            % contain both a foreground and background mark. In this case,
            % bypass the algorithm and return a false mask.
            if self.NumNodes > 1
                self = buildGraph(self,conn);
            else
                self = setFalseMask(self);
            end
            
        end
        
        %---Update terminal edge weights-----------------------------------
        function self = updateTerminalEdgeWeights(self,varargin)
           
            % computeTerminalEdgeWeights must be implemented in concrete class
            [self.ForegroundWeights, self.BackgroundWeights] = computeTerminalEdgeWeights(self,varargin{:});
            
            t = 1:self.NumNodes;
            
            edgeInd = findedge(self.Graph, self.SourceNode, t);
            self.Graph.Edges.Weight(edgeInd) = self.BackgroundWeights;
            
            edgeInd = findedge(self.Graph, self.TerminalNode, t);
            self.Graph.Edges.Weight(edgeInd) = self.ForegroundWeights;
            
        end
        
        %---Update neighbor edge weights-----------------------------------
        function self = updateNeighborEdgeWeights(self,varargin)
            
            % computeNeighborEdgeWeights must be implemented in concrete class
            self.NeighborWeights = computeNeighborEdgeWeights(self,varargin{:});
            
            edgeInd = findedge(self.Graph, self.NeighborStartNodes, self.NeighborEndNodes);
            self.Graph.Edges.Weight(edgeInd) = self.NeighborWeights;
                        
        end
        
    end
    
    methods
        
        %---Segment--------------------------------------------------------
        function self = segment(self)
            
            % Compute max-flow/min-cut on graph
            [~,~,CS] = maxflow(self.Graph,self.SourceNode,self.TerminalNode);
            % CS is the vector of node indices that are partitioned with
            % the source node (foreground). Remove the source node from
            % this vector to leave only the nodes of foreground subregions
            CS(CS==self.SourceNode) = [];
            % Use subregion labeling to label each of the pixels in the
            % output mask that belong to the nodes identified in CS
            self = setFalseMask(self);
            for i = 1:numel(CS)
                self.Mask(self.PixelIdxList{CS(i)}) = true;
            end
            
        end
        
        %---Add new scribbles----------------------------------------------
        function self = addHardConstraints(self,foregroundNew,backgroundNew)
            
            % Update state of algorithm to reflect additional scribble
            % information.            
            self.ForegroundIndices = foregroundNew;
            self.BackgroundIndices = backgroundNew;
            
            self = updateTerminalEdgeWeights(self);
            
            % updateNeighborEdgeWeights must be implemented in concrete class
            self = updateNeighborEdgeWeights(self);
            
        end
        
        %---Set false mask-------------------------------------------------
        function self = setFalseMask(self)
            self.Mask = false([self.NumRows self.NumColumns self.NumPages]);
        end
        
    end
    
    methods (Access = 'private')
        % Methods for constructing graph
        
        %---Build graph----------------------------------------------------
        function self = buildGraph(self,conn)
            
            % Build graph of connected pixel regions
            [s,t] = images.graphcut.internal.buildGraphNodePairs(self.LabelMatrix,conn);
            self.Graph = graph(s,t);

            self.PixelIdxList = label2idx(self.LabelMatrix);
            
            self.MeanFeatures = images.graphcut.internal.meanSuperpixelFeatures(...
                self.InputImage,self.LabelMatrix,self.NumNodes,self.NumChannels);
            
            self.NeighborStartNodes = self.Graph.Edges.EndNodes(:,1);
            self.NeighborEndNodes = self.Graph.Edges.EndNodes(:,2);
            
            % Modify graph to include terminal node connections to all
            % pixel regions
            self = addTerminalNodesToGraph(self);
            
            % Add Weights as a variable in the Edges table
            self = addDefaultWeightsToGraph(self);
            
        end
        
        %---Add terminal nodes to graph------------------------------------
        function self = addTerminalNodesToGraph(self)
            
            % Modify graph to include S and T nodes to define background and foreground
            numGridNodes = self.NumNodes;
            self.Graph = addnode(self.Graph,2);
            self.SourceNode = numGridNodes+1;
            self.TerminalNode = numGridNodes+2;
            
            % Add T-nodes connected to S
            self.Graph = addedge(self.Graph,self.SourceNode,1:numGridNodes);
            
            % Add T-nodes connected to T.
            self.Graph = addedge(self.Graph,self.TerminalNode,1:numGridNodes);
            
        end
        
        %---Add default weights to graph-----------------------------------
        function self = addDefaultWeightsToGraph(self)
            self.Graph.Edges.Weight = zeros(height(self.Graph.Edges),1);
        end
        
    end
    
    
end