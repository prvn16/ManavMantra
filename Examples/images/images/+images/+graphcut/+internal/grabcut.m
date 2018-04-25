classdef grabcut < images.graphcut.internal.graphcut
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Access = 'private')

        % Algorithm parameters
        ConvergenceCriterion = 1e-4;
        Gamma = 50;
        NumGaussianMixtures = 5;
        NumClusterReplicates = 4;
        ScaleFactor = 255;
        
        % Maximum iterations
        MaxIterations
        
        % Gaussian mixture model for foreground and background clusters
        ForegroundGMM
        BackgroundGMM
        
        % Subregions inside and outside user-defined area
        SuperpixelsInsideBbox
        SuperpixelsOutsideBbox
        
        % Segmentation state for subregions
        TrimapBackground
        TrimapForeground
        TrimapUnknown
        
        % Kmeans clustering information
        ForegroundClusterCenters
        BackgroundClusterCenters
        ComponentClusterIndex
        
    end
    
     methods
        
        function self = grabcut(inputImage,labelMatrix,numNodes,conn,maxIters)

            % Call graphcut constructor to initialize graph
            self@images.graphcut.internal.graphcut(inputImage,labelMatrix,numNodes,conn);
            self.MaxIterations = maxIters;
            
            % Original algorithm assumes RGB uint8 data. Scale floating
            % point data to uint8 data range and pad grayscale data for
            % gaussian distributions
            self.MeanFeatures = self.MeanFeatures * self.ScaleFactor;
            
            if size(self.MeanFeatures,2) == 1
                self.MeanFeatures = repmat(self.MeanFeatures,[1,3]);
            end
            
        end
        
        function self = addBoundingBox(self,bbox)
            
            % Identify superpixels inside/outside bounding box
            [self.SuperpixelsInsideBbox, self.SuperpixelsOutsideBbox] = self.findSuperpixelsInsideBoundingBox(bbox);
            
            self.TrimapForeground = [];
            self.TrimapBackground = self.SuperpixelsOutsideBbox;
            self.TrimapUnknown = self.SuperpixelsInsideBbox;
            
            emptyArray = num2cell(zeros([1,self.NumGaussianMixtures]));
            
            self.ForegroundGMM = struct('Pi',emptyArray,...
                'Mu',emptyArray,...
                'InvSigma',emptyArray,...
                'DetSigma',emptyArray);
            
            self.BackgroundGMM = struct('Pi',emptyArray,...
                'Mu',emptyArray,...
                'InvSigma',emptyArray,...
                'DetSigma',emptyArray);
            
            if isBoundingBoxValid(self)
                self = initializeGrabCut(self);
                self = updateNeighborEdgeWeights(self);
                self = iterateGrabCut(self);
            end
            
            self = terminateGrabCut(self);
            
        end
        
    end
    
    methods(Access = 'protected')
        % Abstract methods from base class
        
        function neighborWeights = computeNeighborEdgeWeights(self)
                        
            startNodes = self.NeighborStartNodes;
            endNodes = self.NeighborEndNodes;
            
            temp = (self.MeanFeatures(startNodes,:)-self.MeanFeatures(endNodes,:)).^2;
            beta = 1./(2*mean(sum(temp,2)));
            euclideanDistance = 1;
            
            neighborWeights = (self.Gamma/euclideanDistance).*exp(-beta.*sum(temp,2));
            neighborWeights(isnan(neighborWeights)) = 0;
        end
        
        function [foregroundWeights, backgroundWeights] = computeTerminalEdgeWeights(self,varargin)
            
            if nargin > 1
                % Gaussian Mixture Models passed in directly during
                % iterative process
                fGMM = varargin{1};
                bGMM = varargin{2};
            else
                % Gaussian Mixture Models cached in class for additional
                % cuts with additional user input after iterative process
                fGMM = self.ForegroundGMM;
                bGMM = self.BackgroundGMM;
            end
                        
            [foregroundWeights,backgroundWeights] = deal(zeros(self.NumNodes,1));
            trimapUnknownPixels = self.MeanFeatures(self.TrimapUnknown,:);
            
            if ~isempty(trimapUnknownPixels) && isBoundingBoxValid(self)

                % Foreground
                D = zeros([numel(self.TrimapUnknown),1]);
                
                for idx = 1:self.NumGaussianMixtures
                    D = D + images.graphcut.internal.grabcutmex(trimapUnknownPixels, fGMM(idx).Pi,...
                        fGMM(idx).Mu, fGMM(idx).DetSigma, ...
                        fGMM(idx).InvSigma);   
                end

                foregroundWeights(self.TrimapUnknown) = -log(D);

                % Background
                D = zeros([numel(self.TrimapUnknown),1]);

                for idx = 1:self.NumGaussianMixtures
                    D = D + images.graphcut.internal.grabcutmex(trimapUnknownPixels, bGMM(idx).Pi,...
                        bGMM(idx).Mu, bGMM(idx).DetSigma, ...
                        bGMM(idx).InvSigma);
                end

                backgroundWeights(self.TrimapUnknown) = -log(D);
            
            end
            
            % Hard constraints based on user scribbles. Locations that were
            % marked as foreground or background must end up assigned as
            % foreground or background.
            hardForegroundInd = unique(self.LabelMatrix(self.ForegroundIndices));
            hardBackgroundInd = unique(self.LabelMatrix(self.BackgroundIndices));
            
            % Remove scribbles drawn on background regions of the label matrix
            hardForegroundInd(hardForegroundInd == 0) = [];
            hardBackgroundInd(hardBackgroundInd == 0) = [];
            
            % Set hard constraints
            if ~isempty(hardBackgroundInd)
                foregroundWeights(hardBackgroundInd) = Inf;
            end
            if ~isempty(hardForegroundInd)
                backgroundWeights(hardForegroundInd) = Inf;
            end
            
            % The ordering matters for regions labeled with both foreground
            % and background scribbles. Any region with both foreground and
            % background scribbles will have both unary weights set to
            % zero. This has the same effect as if the user had never
            % marked this region.
            if ~isempty(hardForegroundInd)
                foregroundWeights(hardForegroundInd) = 0;
            end
            if ~isempty(hardBackgroundInd)
                backgroundWeights(hardBackgroundInd) = 0;
            end
            
            % Set hard constraints derived from bounding box location.
            % These take priority over user-drawn foreground and background
            % marks
            backgroundWeights(self.TrimapBackground) = 0;
            foregroundWeights(self.TrimapBackground) = Inf;
            
            backgroundWeights(self.TrimapForeground) = Inf;
            foregroundWeights(self.TrimapForeground) = 0;
            
            % Catch NaN or negative edge weights and set them to zero.
            foregroundWeights(isnan(foregroundWeights) | foregroundWeights < 0) = 0;
            backgroundWeights(isnan(backgroundWeights) | backgroundWeights < 0) = 0;
            
        end
        
    end
    
    methods (Access = 'private')
        
        function self = initializeGrabCut(self)
            
            self.ComponentClusterIndex = zeros(self.NumNodes,1);
            
            [foregroundClusterIndex, self.ForegroundClusterCenters] = images.internal.ocvkmeans(...
                single(self.MeanFeatures(self.SuperpixelsInsideBbox,:)),self.NumGaussianMixtures,self.NumClusterReplicates);
            
            [~,self.BackgroundClusterCenters] = images.internal.ocvkmeans(...
                single(self.MeanFeatures(self.SuperpixelsOutsideBbox,:)),self.NumGaussianMixtures,self.NumClusterReplicates);
            
            self.ComponentClusterIndex(self.SuperpixelsInsideBbox) = single(foregroundClusterIndex+1);
            
        end
        
        function self = iterateGrabCut(self)
            
            terminateIterations = false;
            numIters = 1;
            lastE = Inf;
            w(1) = warning('off','MATLAB:nearlySingularMatrix');
            w(2) = warning('off','MATLAB:singularMatrix');
            
            while ~terminateIterations
                
                [self, foregroundGMM, backgroundGMM] = updateGaussianMixtureModel(self,numIters);              
                self = updateTerminalEdgeWeights(self, foregroundGMM, backgroundGMM);
                
                % Compute max-flow/min-cut on graph
                [E,~,newInsideBBox,newOutsideBbox] = maxflow(self.Graph,self.SourceNode,self.TerminalNode);
                % CS is the vector of node indices that are partitioned with
                % the source node (foreground). Remove the source node from
                % this vector to leave only the nodes of foreground subregions
                newInsideBBox(newInsideBBox == self.SourceNode) = [];
                newOutsideBbox(newOutsideBbox == self.TerminalNode) = [];
                
                deltaE = (abs(lastE - E)/lastE);
                
                terminateIterations = (deltaE < self.ConvergenceCriterion) || (numIters >= self.MaxIterations);
                numIters = numIters + 1;
                lastE = E;
                
                if isempty(newInsideBBox) || isempty(newOutsideBbox)
                    terminateIterations = true;
                else
                    self.SuperpixelsInsideBbox = newInsideBBox;
                    self.SuperpixelsOutsideBbox = newOutsideBbox;
                    self.ForegroundGMM = foregroundGMM;
                    self.BackgroundGMM = backgroundGMM;
                end
                
            end
            
            warning(w);
            
        end
        
        function self = terminateGrabCut(self)
            
            CS = self.SuperpixelsInsideBbox;
            % Use subregion labeling to label each of the pixels in the
            % output mask that belong to the nodes identified in CS
            self = setFalseMask(self);
            for i = 1:numel(CS)
                self.Mask(self.PixelIdxList{CS(i)}) = true;
            end
            
        end
        
        function [inBbox, outBbox] = findSuperpixelsInsideBoundingBox(self,bbox)
            
            if islogical(bbox)
                assert(isequal(size(self.LabelMatrix),size(bbox)),'Mask and label matrix dimensions must match.');
                in = bbox;
            else
                assert(size(bbox,2) == 2,'ROI points must be specified as Nx2 array of (x,y) coordinates');
                assert(size(bbox,1) >= 3,'ROI must have at least 3 points');
                in = poly2mask(bbox(:,1),bbox(:,2),self.NumRows,self.NumColumns);
            end
            
            [inBbox,outBbox] = images.graphcut.internal.uniqueLabelsInMask(self.LabelMatrix,in,self.NumNodes);
            inBbox(inBbox == 0) = [];
            outBbox(outBbox == 0) = [];
            inBbox = setdiff(inBbox,outBbox);
            
        end
        
        function [self, foregroundGMM, backgroundGMM] = updateGaussianMixtureModel(self,numIters)
            
            % Update Component indices. If a superpixel has been reassigned
            % from the foreground to the background (or vice versa), find
            % which cluster from the GMM the reassigned superpixel best
            % fits.
            
            % TODO: This isn't much of a bottleneck now, but could be mexed
            % to improve performance
            if numIters == 1
                newBackground = self.ComponentClusterIndex(self.SuperpixelsInsideBbox);

                for ii = 1:numel(newBackground)
                    if newBackground(ii) > 0
                        distanceToCenters = sum(((self.BackgroundClusterCenters - self.MeanFeatures(self.SuperpixelsInsideBbox(ii),:)).^2),2);
                        [~,I] = min(distanceToCenters);
                        self.ComponentClusterIndex(self.SuperpixelsInsideBbox(ii)) = -I;
                    end
                end
            else
                newForeground = self.ComponentClusterIndex(self.SuperpixelsInsideBbox);

                for ii = 1:numel(newForeground)
                    if newForeground(ii) < 0
                        distanceToCenters = sum(((self.ForegroundClusterCenters - self.MeanFeatures(self.SuperpixelsInsideBbox(ii),:)).^2),2);
                        [~,I] = min(distanceToCenters);
                        self.ComponentClusterIndex(self.SuperpixelsInsideBbox(ii)) = I;
                    end
                end

                newBackground = self.ComponentClusterIndex(self.SuperpixelsOutsideBbox);

                for ii = 1:numel(newBackground)
                    if newBackground(ii) > 0
                        distanceToCenters = sum(((self.BackgroundClusterCenters - self.MeanFeatures(self.SuperpixelsOutsideBbox(ii),:)).^2),2);
                        [~,I] = min(distanceToCenters);
                        self.ComponentClusterIndex(self.SuperpixelsOutsideBbox(ii)) = -I;
                    end
                end
            
            end
            
            classIn = class(self.MeanFeatures);
            
            foregroundGMM = self.ForegroundGMM;
            backgroundGMM = self.BackgroundGMM;
            
            for idx = 1:self.NumGaussianMixtures
                
                % Compute parameters for regions inside bounding box
                foregroundGMM = self.assignGMMParameters(foregroundGMM,idx,self.MeanFeatures(self.ComponentClusterIndex == idx,:),classIn);
                
                % Compute parameters for regions outside bounding box
                backgroundGMM = self.assignGMMParameters(backgroundGMM,idx,self.MeanFeatures(self.ComponentClusterIndex == -idx,:),classIn);

            end
            
            if numIters == 1
                self.ForegroundGMM = foregroundGMM;
                self.BackgroundGMM = backgroundGMM;
            end
        end
        
        function GMM = assignGMMParameters(self,GMM,idx,meanFeatures,classIn)
            
            % Fraction of superpixels inside bbox that are associated with this GMM component
            GMM(idx).Pi = cast(length(meanFeatures)/length(self.SuperpixelsInsideBbox),classIn);
            GMM(idx).Mu = cast(mean(meanFeatures,1),classIn);
            
            C = cov(meanFeatures,1);
            
            if isscalar(C) || det(C) == 0
                C = eye(size(meanFeatures,2));
            else
                C = C + (eye(3)*0.01); % Add variance to prevent singular matrix
            end
            
            if any(isnan(C))
                GMM(idx).InvSigma = cast(C,classIn);
            else
                GMM(idx).InvSigma = cast(inv(C),classIn);
            end
            
            GMM(idx).DetSigma = cast(sqrt(det(C)),classIn);
            
        end
        
        function TF = isBoundingBoxValid(self)
            % Grabcut requires the same or more subregions inside and
            % outside bounding box as number of gaussian mixtures.
            TF = (numel(self.SuperpixelsInsideBbox) >= self.NumGaussianMixtures) && (numel(self.SuperpixelsOutsideBbox) >= self.NumGaussianMixtures);
            
        end
            
    end
    
end