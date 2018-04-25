classdef MaskView < handle
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Access = private)
        Mask
    end
    
    methods
        function self = MaskView(im)
            self.Mask = im;
        end
        
        function updateMask(self, newMask)
            assert(isempty(self.Mask) || isequal(size(self.Mask), size(newMask)), ...
                'Size mismatch when updating mask')
            self.Mask = newMask;
        end
        
        function mask = getMask(self)
            mask = self.Mask;
        end
        
        function TF = isempty(self)
            TF = ~any(self.Mask(:));
        end
    end
    
end