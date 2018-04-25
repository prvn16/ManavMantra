classdef lazysnapping < images.graphcut.internal.graphcut
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access = 'private')
        
        Epsilon
        Lambda
        
    end
        
    properties (Access = 'protected', Dependent)
        
        ForegroundScribbleColor
        BackgroundScribbleColor
        
    end
    
    methods
        
        function self = lazysnapping(inputImage,labelMatrix,numNodes,conn,lambda)
            
            % Call graphcut constructor to initialize graph
            self@images.graphcut.internal.graphcut(inputImage,labelMatrix,numNodes,conn);
            
            % Lazy Snapping algorithm assumes uint8 data range. Adjust
            % lambda to scaled image with range [0 1]
            self.Lambda = lambda/(255^2);
            self.Epsilon = self.Lambda/10000;
            
        end
        
    end
    
    methods(Access = 'protected')
        % Abstract methods from base class
        
        function neighborWeights = computeNeighborEdgeWeights(self)
                        
            startNodes = self.NeighborStartNodes;
            endNodes = self.NeighborEndNodes;
            
            temp = (self.MeanFeatures(startNodes,:)-self.MeanFeatures(endNodes,:)).^2;
            Cij = sum(temp,2);
            
            neighborWeights = self.Lambda./(self.Epsilon+(Cij));
                        
        end
        
        function [foregroundWeights, backgroundWeights] = computeTerminalEdgeWeights(self)
            
            [foregroundWeights,backgroundWeights] = deal(zeros(self.NumNodes,1));
            
            % Hard constraints based on user scribbles. Locations that were
            % marked as foreground or background must end up assigned as
            % foreground or background.
            hardForegroundInd = unique(self.LabelMatrix(self.ForegroundIndices));
            hardBackgroundInd = unique(self.LabelMatrix(self.BackgroundIndices));
            
            % Remove scribbles drawn on background regions of the label matrix
            hardForegroundInd(hardForegroundInd == 0) = [];
            hardBackgroundInd(hardBackgroundInd == 0) = [];
            
            if isempty(hardForegroundInd) || isempty(hardBackgroundInd)
                error(message('images:lazysnapping:invalidLabelMatrix'))
            end
            
            % Set hard constraints
            foregroundWeights(hardBackgroundInd) = Inf;
            backgroundWeights(hardForegroundInd) = Inf;
            
            % The ordering matters for regions labeled with both foreground
            % and background scribbles. Any region with both foreground and
            % background scribbles will have both unary weights set to
            % zero. This has the same effect as if the user had never
            % marked this region.
            foregroundWeights(hardForegroundInd) = 0;
            backgroundWeights(hardBackgroundInd) = 0;

            minDistanceToForegroundColor = images.graphcut.internal.minpdist2mex(self.ForegroundScribbleColor,self.MeanFeatures);
            minDistanceToBackgroundColor = images.graphcut.internal.minpdist2mex(self.BackgroundScribbleColor,self.MeanFeatures);

            softInd = 1:self.NumNodes;
            softInd = setdiff(softInd,hardForegroundInd);
            softInd = setdiff(softInd,hardBackgroundInd);
            
            normTerm = minDistanceToForegroundColor(softInd) + minDistanceToBackgroundColor(softInd);
            foregroundWeights(softInd) = minDistanceToForegroundColor(softInd) ./ normTerm;
            backgroundWeights(softInd) = minDistanceToBackgroundColor(softInd) ./ normTerm;
            
            % If foreground, background, and mean superpixel values are
            % identical, the min distance and normTerm will be zero,
            % resulting in a NaN edge weight. Catch NaN edge weights and
            % set them to zero.
            foregroundWeights(isnan(foregroundWeights)) = 0;
            backgroundWeights(isnan(backgroundWeights)) = 0;
            
        end
        
    end
    
    methods
                
        %---Get foreground scribble color----------------------------------
        function foregroundColors = get.ForegroundScribbleColor(self)
            
            foregroundColors = zeros([numel(self.ForegroundIndices),self.NumChannels],class(self.InputImage));
            
            for channelVal = 1:self.NumChannels
                foregroundColors(:,channelVal) = self.InputImage(self.ForegroundIndices + (channelVal-1)*(self.NumRows*self.NumColumns))';
            end
            
        end
        
        %---Get background scribble color----------------------------------
        function backgroundColors = get.BackgroundScribbleColor(self)
            
            backgroundColors = zeros([numel(self.BackgroundIndices),self.NumChannels],class(self.InputImage));
            
            for channelVal = 1:self.NumChannels
                backgroundColors(:,channelVal) = self.InputImage(self.BackgroundIndices + (channelVal-1)*(self.NumRows*self.NumColumns))';
            end
            
        end

    end
    
end