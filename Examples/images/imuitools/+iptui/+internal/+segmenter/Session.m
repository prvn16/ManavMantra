classdef Session < handle
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (Access = private)
        Segmentations = [];
        Image
        labImage
        textureFeatures
    end
    
    properties
        ActiveSegmentationIndex
        WasRGB
        WasNormalized = false;
        HadInfNanRemoved = false;
        UseTexture = false;
    end
    
    properties (Dependent = true, SetAccess = private)
        NumberOfSegmentations
    end
    
    methods
        
        function self = Session(im, hApp, varargin)
            self.Image = im;
            self.ActiveSegmentationIndex = self.newSegmentation(hApp);
            
            if isempty(self.WasRGB)
                if nargin > 2
                    self.WasRGB = logical(varargin{1});
                else
                    self.WasRGB = false;
                end
            end
            
            if self.WasRGB
                self.labImage = rgb2lab(im);
            end
            
            self.textureFeatures = [];
            
        end
        
        function newIndex = newSegmentation(self, hApp)
            [theSegmentation, newIndex] = self.createSegmentation(hApp);
            
            newMask = self.createDefaultMask();
            description = iptui.internal.segmenter.getMessageString('loadImage');
            theSegmentation.addToHistory_(newMask, description, '');
            
            theSegmentation.Name = self.createNameForSegmentation();
        end
        
        function newIndex = cloneCurrentSegmentation(self)
            oldSegmentation = self.CurrentSegmentation();
            newSegmentation = oldSegmentation.clone();
            
            self.Segmentations(end+1) = newSegmentation;
            newIndex = numel(self.Segmentations);
            
            newSegmentation.Name = self.createNameForSegmentation();
        end
        
        function im = getImage(self)
            im = self.Image;
        end
        
        function im = getLabImage(self)
            im = self.labImage;
        end
        
        function im = getTextureFeatures(self)
            im = self.textureFeatures;
        end
        
        function TF = createTextureFeatures(self)

            if isempty(self.textureFeatures)
                if self.WasRGB
                    self.textureFeatures = iptui.internal.segmenter.createGaborFeatures(self.labImage);
                else
                    self.textureFeatures = iptui.internal.segmenter.createGaborFeatures(self.Image);
                end
            end
            
            TF = ~isempty(self.textureFeatures);

        end
        
        function load(self, sessionName)
        end
        
        function save(self)
        end
        
        function segmentation = CurrentSegmentation(self)
            segmentation = self.Segmentations(self.ActiveSegmentationIndex);
        end
        
        function numSegmentations = get.NumberOfSegmentations(self)
            numSegmentations = numel(self.Segmentations);
        end
        
        function seg = getSegmentationByIndex(self, index)
            assert(index <= self.NumberOfSegmentations)
            seg = self.Segmentations(index);
        end

        function BW = createDefaultMask(self)
            imageSize = size(self.Image);
            BW = false(imageSize(1), imageSize(2));
        end
        
        function segmentationDetailsCell = convertToDetailsCell(self)
            numSegmentations = self.NumberOfSegmentations;
            segmentationDetailsCell = cell(numSegmentations, 2);
            
            for i = 1:numSegmentations
                thisSegmentation = self.getSegmentationByIndex(i);
                
                theMask = thisSegmentation.getMask();
                segmentationDetailsCell{i, 1} = iptui.internal.segmenter.createThumbnail(theMask);
                segmentationDetailsCell{i, 2} = thisSegmentation.Name;
            end
        end
    end
    
    methods (Static)
        function TF = isValidImageType(im)
            
            supportedDataType       = isa(im,'uint8') || isa(im,'uint16') || (isa(im,'int16') && ismatrix(im)) || isfloat(im);
            supportedAttributes     = isreal(im) && all(isfinite(im(:))) && ~issparse(im);
            
            TF = supportedDataType && supportedAttributes;
        end
    end
    
    methods (Access = private)
        function [theSegmentation, newIndex] = createSegmentation(self, hApp)
            theSegmentation = iptui.internal.segmenter.Segmentation(hApp);

            if isempty(self.Segmentations)
                self.Segmentations = theSegmentation;
            else
                self.Segmentations(end+1) = theSegmentation;
            end
            
            newIndex = numel(self.Segmentations);
        end
        
        function name = createNameForSegmentation(self)
            name = sprintf('%s %d', ...
                iptui.internal.segmenter.getMessageString('segmentation'), ...
                numel(self.Segmentations));
        end
    end
end