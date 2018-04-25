classdef BoundaryMaskOverlay < handle

    % Copyright 2016 The MathWorks, Inc.
    
    properties (Access = public)       
        AlphaMaskOpacity        
    end
    
    properties (Access = private)
        imSize
        BoundaryMask
    end
    
    methods
        function self = BoundaryMaskOverlay(hAx,imSize)
            
            self.AlphaMaskOpacity = 1;
            self.imSize = imSize;
           
            self.initializeMask(hAx);
            
        end
        
        function initializeMask(self,hAx)
            
            % Figure will be docked before imshow is invoked. We want
            % to avoid warning about fit mag in context of a docked
            % figure.
            warnState1 = warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');
            warnState2 = warning('off', 'images:initSize:adjustingMag');
            
            boundaryColorMask = self.makeBoundaryColorMask();
            
            hold(hAx,'on')
            self.BoundaryMask = imshow(boundaryColorMask, 'Parent', hAx);
            hold(hAx,'off')
            
            warning(warnState1);
            warning(warnState2);
            
            self.BoundaryMask.Tag = 'BoundarygroundImage';
            self.BoundaryMask.PickableParts = 'none';
            self.setBoundaryVisibility('off');
            
        end
        
        function delete(self)
            delete(self.BoundaryMask);
        end
        
        function redrawBoundary(self,superpixelBoundary)
            self.BoundaryMask.AlphaData = superpixelBoundary.*(self.AlphaMaskOpacity);          
        end
        
        function setBoundaryVisibility(self, visibility)
            set(self.BoundaryMask, 'Visible', visibility)
        end
        
        function boundaryColorMask = makeBoundaryColorMask(self)
            % purple
            boundaryColorMask = zeros([self.imSize(1) self.imSize(2) 3],'uint8');
            boundaryColorMask(:,:,1) = 126;
            boundaryColorMask(:,:,2) = 47;
            boundaryColorMask(:,:,3) = 142;
        end
    end
    
end

