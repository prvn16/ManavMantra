classdef CompetingRegionGeodesicSegmenter
%COMPETINGREGIONGEODESICSEGMENTER Class for geodesic distance-based image segmentation.
% This is an internal class and subject to change without notice. 

%   Copyright 2014 The MathWorks, Inc.    
        
    properties
                
        featureImage
        numLabels
        numChannels
        labelIdx
        
        W
        D
        L
        
    end
    
    properties(Dependent = true)
        
        alphamat
        
    end
    
    properties(Hidden, Access = private)
        
        nrows
        ncols
        doChannelWeighting
        pdfParamMatrix        
        localExtentRadius
        
        isSegmentedOnce = false;
    end
    
    methods
        
        function obj = CompetingRegionGeodesicSegmenter(A)
                        
            obj.featureImage = A;           
            obj.numChannels = size(obj.featureImage,3);
            obj.nrows = size(A,1);
            obj.ncols = size(A,2);
            
        end
        
        function obj = segment(obj,labelIdx,varargin)
            
            if nargin > 2
                obj.doChannelWeighting = varargin{1};
            else
                obj.doChannelWeighting = false;
            end                        
            
            obj.numLabels = length(labelIdx);
            obj.labelIdx = labelIdx;
            % Estimate PDFs for all labels and for all channels
            obj.pdfParamMatrix = estimateGaussianPDFfromLabelIdx(...
                obj.featureImage, obj.labelIdx);
            
            % Calculate the weights for geodesic distance for all labels
            obj.W = calcWeightMatrixForLabels(obj);
            
            % Compute probabilities of a pixel belonging to labels
            obj.D = calcGeodesicDistanceForLabels(obj);                        
            
            % Get labels from distances
            [~, obj.L] = min(obj.D,[],3);                        
            
            % Set flag that an intial segmentation has been done. This
            % allows updateSegments to be called. 
            obj.isSegmentedOnce = true; 
            
        end
        
        function obj = updateSegments(obj, whichLabel, newIdxs, varargin)
            
            if ~obj.isSegmentedOnce                
                error(message('images:CompetingRegionGeodesicSegmenter:noInitialSegmentation'));
            end
            if (whichLabel > obj.numLabels) || (whichLabel < 1)
                error(message('images:CompetingRegionGeodesicSegmenter:inValidLabel'));
            end
                
            if nargin > 3
                obj.doChannelWeighting = varargin{1};
            else
                obj.doChannelWeighting = false;
            end
            
            if nargin > 4
                obj.localExtentRadius = varargin{3};
            else
                obj.localExtentRadius = [];
            end
                                    
            % Estimate PDFs for all labels and for all channels 
            existingPDFParams = obj.pdfParamMatrix(:,whichLabel,:);
            obj.pdfParamMatrix(:,whichLabel,:) = estimateGaussianPDFfromLabelIdx(...
                obj.featureImage, {newIdxs});
            
            % Calculate the weights for geodesic distance for all labels
            obj.W = calcWeightMatrixForLabels(obj);
            
            % Once weights are calculated, merge the new pixels of the
            % region with the existing pixels of the region.            
            obj.pdfParamMatrix(:,whichLabel,:) = combineTwoGaussianPDFs(...
                squeeze(existingPDFParams), length(obj.labelIdx{whichLabel}), ...
                squeeze(obj.pdfParamMatrix(:,whichLabel,:)), length(newIdxs));
            obj.labelIdx{whichLabel} = union(obj.labelIdx{whichLabel}, newIdxs);    
            
            Lnew = obj.L;
            for currLabel = 1:obj.numLabels
                if (currLabel == whichLabel)
                    Lnew(newIdxs) = whichLabel;
                    continue;
                end
                
                isOutSideCurrLabel = (obj.L ~= currLabel);
                
                wTemp1 = obj.W(:,:,whichLabel);
                wTemp1(isOutSideCurrLabel) = 0;
                Dnewpointlabel = images.internal.fastmarchingmex(wTemp1, newIdxs-1);
            
                wTemp2 = obj.W(:,:,currLabel);
                wTemp2(isOutSideCurrLabel) = 0;
                Dcurrlabel = images.internal.fastmarchingmex(wTemp2, newIdxs-1);
                
                Lnew(Dnewpointlabel < Dcurrlabel) = whichLabel;                                    
                                                   
            end
            obj.L = Lnew;
                   
        end
        
        function alphamat = get.alphamat(obj)
            
            alphamat = calcProbabilitiesForLabels(obj.D);
            
        end
    end
    
    methods(Hidden, Access = private)                        
                                                        
        function W = calcWeightMatrixForLabels(obj)
                        
            W = zeros([obj.nrows obj.ncols obj.numLabels],'double');            
            labelPairs = nchoosek(1:obj.numLabels,2);            
            for q = 1:size(labelPairs,1)
                
                pdfParamsForPair = obj.pdfParamMatrix(:,labelPairs(q,:),:);
                % Get weighting factor for each channel
                channelWeights = getChannelWeightingFactor(obj.doChannelWeighting, pdfParamsForPair);
                P = getProbabilitiesForLabelPair(obj, pdfParamsForPair, channelWeights);
                W(:,:,labelPairs(q,1)) = W(:,:,labelPairs(q,1)) + P(:,:,1);
                W(:,:,labelPairs(q,2)) = W(:,:,labelPairs(q,2)) + P(:,:,2);
                
            end
            
        end

        
        function P = getProbabilitiesForLabelPair(obj, pdfParamPair, channelWeights)
                        
            P = zeros([obj.nrows obj.ncols 2],'double');            
            for i = 1:obj.numChannels
                Pi = getUnnormalizedLikelihood(obj.featureImage(:,:,i), squeeze(pdfParamPair(i,:,:)));
                sumPi = sum(Pi,3);
                Pi = bsxfun(@rdivide,Pi,sumPi);
                
                % For pixels that have zero probability of belonging to
                % either of the two labels in the pair (this can happen
                % when a pixel clearly belongs to a third category), set
                % the probability explicitly to zero to prevents NaNs from
                % entering comptuation.
                isPiZero = (sumPi == 0);
                Pi(cat(3,isPiZero,isPiZero)) = 0;
                
                P = P + channelWeights(i).*Pi; % W = P and not 1-P to work with the fast marching solver.
            end
            
        end
        
               
        function D = calcGeodesicDistanceForLabels(obj, varargin)
            wForGeodDist = obj.W;
            if nargin > 1
                labelToFreeze = varargin{1};
                wForGeodDist(repmat(obj.L == labelToFreeze,[1 1 obj.numLabels])) = 0;            
            end
            % Compute distance from different labels
            D = zeros(size(wForGeodDist),'like',wForGeodDist);
            for i = 1:size(wForGeodDist,3)
                D(:,:,i) = images.internal.fastmarchingmex(wForGeodDist(:,:,i), obj.labelIdx{i}-1);
            end
            
        end                         
        
    end
    
end
%---------End of class--------------------

function paramMatrix = estimateGaussianPDFfromLabelIdx(channels, labelIdx)

numChannels = size(channels,3);
numPixels = size(channels,1)*size(channels,2);
numLabels = length(labelIdx);
paramMatrix = NaN(numChannels,numLabels,2);
for i = 1:numLabels
    currLabelIdx = labelIdx{i};
    numCurrLabelIdx = length(currLabelIdx);
    elemIdx = kron(currLabelIdx,ones(numChannels,1)) + ...
        kron(ones(numCurrLabelIdx,1),(0:numChannels-1)'*numPixels);
    dataForLabel = reshape(channels(elemIdx),numChannels,numCurrLabelIdx);
    paramMatrix(:,i,1) = mean(dataForLabel,2,'double');
    paramMatrix(:,i,2) = std(dataForLabel,1,2); % '1' to normalize by N and not N-1 (needed when combining pdfs later on).
end

end

function P = getUnnormalizedLikelihood(channel, channelPDFParams)

minAllowedSigma = 1e-16;
channelPDFParams(channelPDFParams(:,2) <= minAllowedSigma,2) = minAllowedSigma;
nLabels = size(channelPDFParams,1);
mu = repmat(reshape(channelPDFParams(:,1),[1 1 nLabels]), size(channel));
sigma = repmat(reshape(channelPDFParams(:,2),[1 1 nLabels]), size(channel));

P = exp(-((repmat(channel,[1 1 nLabels]) - mu).^2)./ ...
    (2.*sigma.*sigma))./(sqrt(2*pi).*sigma);

end

function channelWeights = getChannelWeightingFactor(doChannelWeighting, pdfParamMatrix)

nchannels = size(pdfParamMatrix,1);
channelWeights = ones(nchannels,1);
if doChannelWeighting
    % Find weights for individual channels
    for i = 1:nchannels
        channelWeights(i) = 1/images.internal.gaussoverlapcoeff(pdfParamMatrix(i,1,1), ...
            pdfParamMatrix(i,2,1),pdfParamMatrix(i,1,2),pdfParamMatrix(i,2,2));
    end
    % Handle case when channelWeights is Inf
    isInfCW = isinf(channelWeights);
    if any(isInfCW)
        channelWeights = double(isInfCW);        
    end
        
end

channelWeights = channelWeights./sum(channelWeights); % Normalize weights

end

function P = calcProbabilitiesForLabels(D)

% Compute probabilities
P = 1./(D + eps(1));
P = bsxfun(@rdivide,P,sum(P,3));

end

function newparams = combineTwoGaussianPDFs(params1, n1, params2, n2)
newparams = zeros(size(params1));
for i = 1:size(params1,1)
    mu1 = params1(i,1); mu2 = params2(i,1);
    sigma1 = params1(i,2); sigma2 = params2(i,2);
    newparams(i,1) = (mu1*n1 + mu2*n2)/(n1 + n2);
    newparams(i,2) = sqrt((((sigma1.*sigma1 + mu1.*mu1)*n1 + ...
                      (sigma2.*sigma2 + mu2.*mu2)*n2)/(n1 + n2)) - ...
                       (newparams(i,1).*newparams(i,1)));   
end
                
end

